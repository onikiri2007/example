import 'dart:async';

import 'package:meta/meta.dart';
import 'package:rxdart/rxdart.dart';
import 'package:yodel/src/api/index.dart';
import 'package:yodel/src/common/models/bloc_base.dart';
import 'package:yodel/src/shift/index.dart';

class CreateShiftStep3FormBloc implements BlocBase {
  final Worker worker;
  final CreateShiftStep1FormBloc step1FormBloc;

  BehaviorSubject<List<Worker>> _workersController;
  final BehaviorSubject<ShiftApprovalMode> _modeController =
      BehaviorSubject<ShiftApprovalMode>.seeded(ShiftApprovalMode.manual);
  final BehaviorSubject<ShiftApprovalPermission> _approvalPrivacyController =
      BehaviorSubject<ShiftApprovalPermission>.seeded(
          ShiftApprovalPermission.all_managers);

  CreateShiftStep3FormBloc({
    @required this.worker,
    @required this.step1FormBloc,
  }) {
    _workersController = BehaviorSubject<List<Worker>>.seeded([]);
  }

  @override
  void dispose() {
    _workersController?.close();
    _modeController?.close();
    _approvalPrivacyController?.close();
  }

  Worker get currentWorker => worker;

  bool _isValid = false;

  ShiftApprovalMode get selectedMode => _modeController.value;
  ShiftApprovalPermission get selectedApprovalPrivacyMode =>
      _approvalPrivacyController.value;
  List<Worker> get selectedWorkers => _workersController.value;
  bool get valid => _isValid;

  Stream<List<Worker>> get workers => _workersController;

  void Function(ShiftApprovalMode mode) get selectMode => _modeController.add;
  void Function(ShiftApprovalPermission privacy) get selectPrivacyMode =>
      _approvalPrivacyController.add;

  void Function(List<Worker> workers) get addWorkers => _workersController.add;

  void removeWorker(Worker worker) {
    final workers = _workersController.value;
    workers.removeWhere((w) => w == worker);
    _workersController.add(List.from(workers));
  }

  Stream<ShiftApprovalMode> get mode => _modeController;
  Stream<ShiftApprovalPermission> get approvalPrivacy =>
      _approvalPrivacyController;

  Stream<bool> get isValid => Observable.combineLatest2(
          mode,
          approvalPrivacy,
          (ShiftApprovalMode mode, ShiftApprovalPermission privacy) =>
              mode != null && privacy != null)
      .doOnData((isValid) => _isValid = isValid)
      .startWith(false)
      .asBroadcastStream();
}
