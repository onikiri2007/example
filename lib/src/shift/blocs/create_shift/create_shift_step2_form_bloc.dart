import 'dart:async';

import 'package:meta/meta.dart';
import 'package:rxdart/rxdart.dart';
import 'package:yodel/src/api/index.dart';
import 'package:yodel/src/bootstrapper.dart';
import 'package:yodel/src/common/models/bloc_base.dart';
import 'package:yodel/src/home/index.dart';
import 'package:yodel/src/services/services.dart';
import 'package:yodel/src/shift/index.dart';
import 'package:intl/intl.dart';

class CreateShiftStep2FormBloc implements BlocBase {
  final CompanyBloc companyBloc;
  final CreateShiftStep1FormBloc step1FormBloc;
  final ManageShiftService shiftService;
  BehaviorSubject<Duty> _roleController;
  final BehaviorSubject<List<Skill>> _skillsController =
      BehaviorSubject<List<Skill>>.seeded([]);
  final BehaviorSubject<List<Site>> _sitesController =
      BehaviorSubject<List<Site>>.seeded([]);
  final BehaviorSubject<int> _headCountController =
      BehaviorSubject<int>.seeded(1);
  final BehaviorSubject<int> _eligibleWorkers = BehaviorSubject.seeded(-1);
  final BehaviorSubject<String> _eligiblity = BehaviorSubject();
  final BehaviorSubject<bool> _eligiblityValidating =
      BehaviorSubject.seeded(false);

  StreamSubscription _subscription;

  CreateShiftStep2FormBloc({
    @required this.companyBloc,
    @required this.step1FormBloc,
    ManageShiftService shiftService,
  })  : this.shiftService = shiftService ?? sl<ManageShiftService>(),
        assert(companyBloc != null) {
    final duties = companyBloc.company?.sortedDuties ?? [];

    final duty = duties.isNotEmpty
        ? duties.firstWhere((d) => d.isDefault ?? false,
            orElse: () => duties.first)
        : null;

    _roleController = BehaviorSubject<Duty>.seeded(duty);

    _sitesController.add([step1FormBloc.currentLocation]);

    _subscription = step1FormBloc.location.listen((site) {
      if (!_isSiteListChanged) {
        _sitesController.add([site]);
      }
    });
  }

  @override
  void dispose() {
    _roleController?.close();
    _skillsController?.close();
    _sitesController?.close();
    _headCountController?.close();
    _subscription?.cancel();
    _eligibleWorkers?.close();
    _eligiblity?.close();
    _eligiblityValidating?.close();
  }

  bool _isValid = false;
  bool _isSiteListChanged = false;

  Duty get selectedRole => _roleController.value;
  List<Skill> get selectedSkills => _skillsController.value;
  List<Site> get selectedSites => _sitesController.value;
  int get currentHeadCountRequired => _headCountController.value;
  bool get valid => _isValid;

  Stream<List<Skill>> get skills => _skillsController.stream;

  Stream<List<Site>> get sites => _sitesController.stream;

  ValueObservable<int> get eligibleWorkers => _eligibleWorkers.stream;

  void Function(List<Skill> skills) get addSkills {
    _eligiblity.add(null);
    return _skillsController.add;
  }

  void Function(List<Site> sites) get addSites {
    _isSiteListChanged = true;
    _eligiblity.add(null);
    return _sitesController.add;
  }

  void removeSkill(Skill skill) {
    _eligiblity.add(null);
    final skills = List.from(_skillsController.value);
    skills.removeWhere((s) => s == skill);
    _skillsController.add(List.from(skills));
  }

  void removeSite(Site site) {
    _eligiblity.add(null);
    final sites = List.from(_sitesController.value);
    sites.removeWhere((s) => s == site);
    _sitesController.add(List.from(sites));
  }

  Stream<Duty> get shiftRole => _roleController.stream;

  void Function(Duty role) get selectRole => (role) {
        addSkills([]);
        _roleController.add(role);
      };

  void Function(int headCount) get onHeadCountChanged {
    _eligiblity.add(null);

    return _headCountController.add;
  }

  Stream<int> get headCount => _headCountController;
  Stream<bool> get isValidating => _eligiblityValidating.stream;

  Stream<bool> get isValid => Observable.combineLatest4(
          skills,
          sites,
          headCount,
          shiftRole,
          (List<Skill> skills, List<Site> sites, int headCount,
                  Duty selectedRole) =>
              sites.length > 0 && headCount > 0 && selectedRole != null)
      .doOnData((isValid) => _isValid = isValid)
      .startWith(false)
      .asBroadcastStream();

  Future<bool> hasEnoughEligibleWorkers() async {
    _eligiblityValidating.add(true);
    final r = await shiftService.getEligibleHeadCount(
        siteIds: selectedSites.map((s) => s.id).toList(),
        skillIds: selectedSkills.map((s) => s.id).toList());
    _eligiblityValidating.add(false);

    if (!r.isSuccessful) {
      _eligiblity.addError(r.error);
      return false;
    } else {
      _eligibleWorkers.add(r.result);

      final text = Intl.plural(
        r.result,
        zero: "employee",
        one: "employee",
        other: "employees",
      );

      if (r.result < currentHeadCountRequired) {
        _eligiblity.addError(
            "${r.result} eligible $text found but less than the number of people required.");
        return false;
      } else {
        _eligiblity.add("${r.result} eligible $text found.");
      }

      return true;
    }
  }

  Stream<String> get eligibility => _eligiblity.stream;
}
