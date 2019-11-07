import 'package:equatable/equatable.dart';
import 'package:yodel/src/api/index.dart';

class ShiftDetails extends Equatable {
  final DateTime startDate;
  final DateTime endDate;
  final String description;
  final String name;
  final Site location;
  final Worker manager;

  ShiftDetails({
    this.name,
    this.startDate,
    this.endDate,
    this.description,
    this.location,
    this.manager,
  });

  ShiftDetails copyWith({
    DateTime startDate,
    DateTime endDate,
    String description,
    String name,
    Site location,
    Worker manager,
  }) =>
      ShiftDetails(
        startDate: startDate ?? this.startDate,
        endDate: endDate ?? this.endDate,
        description: description ?? this.description,
        name: name ?? this.name,
        location: location ?? this.location,
        manager: manager ?? this.manager,
      );

  @override
  // TODO: implement props
  List<Object> get props => [
        name,
        startDate,
        endDate,
        description,
        location,
      ];
}

class ShiftPeopleRequirements extends Equatable {
  final Duty role;
  final List<Site> sites;
  final int noOfPeople;
  final List<Skill> skills;

  ShiftPeopleRequirements({
    this.role,
    this.sites = const [],
    this.skills = const [],
    this.noOfPeople = 1,
  });

  ShiftPeopleRequirements copyWith({
    Duty role,
    List<Site> sites,
    int noOfPeople,
    List<Skill> skills,
  }) =>
      ShiftPeopleRequirements(
        role: role ?? this.role,
        sites: sites ?? this.sites,
        noOfPeople: noOfPeople ?? this.noOfPeople,
        skills: skills ?? this.skills,
      );

  ShiftPeopleRequirements addSites(List<Site> sites) {
    return copyWith(
      sites: sites,
    );
  }

  ShiftPeopleRequirements removeSite(Site site) => copyWith(
        sites: sites.where((s) => s.id != site.id).toList(),
      );

  ShiftPeopleRequirements addSkills(List<Skill> skills) {
    return copyWith(
      skills: skills,
    );
  }

  ShiftPeopleRequirements removeSkill(Skill skill) => copyWith(
        skills: skills.where((s) => s.id != skill.id).toList(),
      );

  @override
  // TODO: implement props
  List<Object> get props => [
        role,
        sites,
        noOfPeople,
        skills,
      ];
}

class ShiftApprovalRequirements extends Equatable {
  final ShiftApprovalMode mode;
  final List<Worker> workers;
  final Worker approver;
  final ShiftApprovalPermission permission;

  ShiftApprovalRequirements({
    this.mode = ShiftApprovalMode.automatic,
    this.approver,
    this.workers = const [],
    this.permission,
  });

  ShiftApprovalPrivacy get privacyMode {
    if (permission == null ||
        permission == ShiftApprovalPermission.all_managers) {
      return ShiftApprovalPrivacy.public;
    }

    return ShiftApprovalPrivacy.private;
  }

  ShiftApprovalRequirements copyWith({
    ShiftApprovalMode mode,
    List<Worker> workers,
    Worker approver,
    ShiftApprovalPermission permission,
  }) =>
      ShiftApprovalRequirements(
        mode: mode ?? this.mode,
        workers: workers ?? this.workers,
        approver: approver ?? this.approver,
        permission: permission ?? this.permission,
      );

  ShiftApprovalRequirements addWokers(List<Worker> workers) {
    return copyWith(
      workers: workers,
    );
  }

  ShiftApprovalRequirements removeWorker(Worker worker) => copyWith(
        workers: workers.where((e) => e.id != worker.id).toList(),
      );

  @override
  // TODO: implement props
  List<Object> get props => [mode, approver, workers, permission];
}

class CreateShiftSteps {
  final int step;
  final int maxSteps;
  final int currentMaxStep;
  final List<int> stepsCompleted;
  CreateShiftSteps({
    this.step = 1,
    this.maxSteps = 4,
    this.currentMaxStep = 3,
    this.stepsCompleted = const [],
  });

  int get currentStep =>
      this.step > currentMaxStep ? currentMaxStep : this.step;

  CreateShiftSteps moveForward() {
    final int nextStep = this.step + 1;
    List<int> steps = [];
    if (!this.stepsCompleted.contains(step)) {
      steps = List.from(this.stepsCompleted)..add(step);
    } else {
      steps = List.from(this.stepsCompleted);
    }

    return _copyWith(
      step: nextStep <= this.maxSteps ? nextStep : this.step,
      stepsCompleted: steps,
    );
  }

  CreateShiftSteps moveBackword() {
    final int previsouStep = this.step - 1;
    return _copyWith(
      step: previsouStep > 0 ? previsouStep : this.step,
      stepsCompleted: List.from(this.stepsCompleted),
    );
  }

  bool canMoveBack() {
    final int previsouStep = this.step - 1;
    return previsouStep > 0 && stepsCompleted.contains(previsouStep);
  }

  bool canMoveTo(int step) {
    return this.step != step && stepsCompleted.contains(step);
  }

  CreateShiftSteps _copyWith({int step, List<int> stepsCompleted}) =>
      CreateShiftSteps(
        maxSteps: this.maxSteps,
        currentMaxStep: this.currentMaxStep,
        step: step ?? this.step,
        stepsCompleted: stepsCompleted,
      );

  bool isCurrent(int step) => this.step == step;
}
