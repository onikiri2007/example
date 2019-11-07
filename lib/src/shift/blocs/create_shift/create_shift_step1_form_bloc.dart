import 'dart:async';

import 'package:rxdart/rxdart.dart';
import 'package:yodel/src/api/index.dart';
import 'package:yodel/src/authentication/index.dart';
import 'package:yodel/src/bootstrapper.dart';
import 'package:yodel/src/common/models/bloc_base.dart';
import 'package:yodel/src/common/models/models.dart';
import 'package:yodel/src/services/services.dart';
import 'package:yodel/src/shift/index.dart';

class CreateShiftStep1FormBloc implements BlocBase {
  final BehaviorSubject<String> _shiftNameController =
      BehaviorSubject<String>();
  final BehaviorSubject<DateTime> _startDateController =
      BehaviorSubject<DateTime>();
  final BehaviorSubject<DateTime> _endDateController =
      BehaviorSubject<DateTime>();
  final BehaviorSubject<String> _descriptionController =
      BehaviorSubject<String>();

  BehaviorSubject<Site> _locationController;

  final CompanyService companyService;
  final SessionTracker sessionTracker;

  CreateShiftStep1FormBloc({
    CompanyService companyService,
    SessionTracker sessionTracker,
  })  : this.companyService = companyService ?? sl<CompanyService>(),
        this.sessionTracker = sessionTracker ?? sl<SessionTracker>() {
    _locationController = BehaviorSubject.seeded(_getDefaultLocation());
  }

  @override
  void dispose() {
    _shiftNameController.close();
    _startDateController.close();
    _endDateController.close();
    _descriptionController.close();
    _locationController.close();
  }

  bool _isValid = false;

  String get currentName => _shiftNameController.value;
  DateTime get currentStartDate => _startDateController.value;
  DateTime get currentEndDate => _endDateController.value;
  String get currentDescription => _descriptionController.value;
  Site get currentLocation => _locationController.value;
  bool get valid => _isValid;

  Observable<String> get shiftName => _shiftNameController.transform(
          StreamTransformer<String, String>.fromHandlers(
              handleData: (data, sink) {
        if (data == null || data.trim().isEmpty) {
          sink.addError("Shift name is required");
        } else if (data.length > 50) {
          sink.addError("Shift name must be less than 50 characters");
        } else {
          sink.add(data);
        }
      }));

  void Function(String value) get onNameChanged => _shiftNameController.add;

  Observable<DateTime> get startDate => _startDateController.transform(
          StreamTransformer<DateTime, DateTime>.fromHandlers(
              handleData: (data, sink) {
        if (data == null) {
          sink.addError("Start time is required");
        } else if (data.isBefore(DateTime.now())) {
          sink.add(DateTimeHelper.convertToIntervalMinutesDateTime(
              DateTime.now(), kShiftMinuteInterval));
        } else if (_endDateController.value != null &&
                data.isAfter(_endDateController.value) ||
            data == _endDateController.value) {
          _endDateController
              .addError("End time must be greater than start time");
          sink.add(data);
        } else if (_endDateController.value != null &&
            _endDateController.value.difference(data).inHours > 24) {
          _endDateController
              .addError("Shift duration can not be longer than 24 hours");
          sink.add(data);
        } else {
          sink.add(data);
        }
      }));

  void Function(DateTime value) get onStartDateChanged =>
      _startDateController.add;

  Observable<DateTime> get endDate => _endDateController.transform(
          StreamTransformer<DateTime, DateTime>.fromHandlers(
              handleData: (data, sink) {
        if (data == null) {
          sink.addError("End time is required");
        } else if (_startDateController.value != null &&
                data.isBefore(_startDateController.value) ||
            data == _startDateController.value) {
          sink.addError("End time must be greater than start time");
        } else if (_startDateController.value != null &&
            data.difference(_startDateController.value).inHours > 24) {
          sink.addError("Shift duration can not be longer than 24 hours");
        } else {
          sink.add(data);
        }
      }));

  void Function(DateTime value) get onEndDateChanged => _endDateController.add;

  Stream<bool> get isValid => Observable.combineLatest3(startDate, endDate,
          shiftName, (startDate, endDate, shiftName) => true)
      .doOnData((isValid) => _isValid = isValid)
      .startWith(false)
      .asBroadcastStream();

  void Function(String value) get onDescriptionChanged =>
      _descriptionController.add;

  Stream<String> get description => _descriptionController;

  Stream<Site> get location => _locationController;

  void Function(Site value) get onLocationChanged => _locationController.add;

  Site _getDefaultLocation() => companyService.company?.sites?.firstWhere(
      (s) => sessionTracker.session.value.siteIds.isNotEmpty
          ? s.id == sessionTracker.session.value.siteIds?.first
          : s,
      orElse: () => companyService.company?.sites?.first);
}
