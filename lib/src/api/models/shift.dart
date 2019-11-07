import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:latlong/latlong.dart';
import 'package:yodel/src/common/models/date_time_helper.dart';

part 'shift.g.dart';

@JsonSerializable()
class Site extends Equatable {
  final int id;
  final String name;
  final String address;
  final double latitude;
  final double longitude;
  final double distanceKm;
  final List<Manager> managers;
  final String imagePath;
  final String contactEmail;
  final String contactPhone;

  Site({
    this.id,
    this.name,
    this.address,
    this.latitude,
    this.longitude,
    this.distanceKm = 0,
    this.managers = const [],
    this.imagePath,
    this.contactEmail,
    this.contactPhone,
  });

  Site copyWith({
    int id,
    String name,
    String address,
    double latitude,
    double longitude,
    String logoPath,
    double distanceKm = 0,
    List<Manager> managers,
    String imagePath,
  }) =>
      Site(
        id: id ?? this.id,
        name: name ?? this.name,
        address: address ?? this.address,
        latitude: latitude ?? this.latitude,
        longitude: longitude ?? this.longitude,
        distanceKm: distanceKm ?? this.distanceKm,
        managers: managers ?? this.managers,
        imagePath: imagePath ?? this.imagePath,
      );

  static const fromJson = _$SiteFromJson;

  Map<String, dynamic> toJson() => _$SiteToJson(this);

  double distanceFrom(double lat, double long) {
    if (lat == null || long == null || latitude == null || longitude == null)
      return 0;

    final distance = new Distance();
    final double km = distance.as(LengthUnit.Kilometer,
        new LatLng(latitude, longitude), new LatLng(lat, long));

    return km.roundToDouble();
  }

  @override
  // TODO: implement props
  List<Object> get props => [id];
}

@JsonSerializable()
class Skill extends Equatable {
  final int id;
  final String name;

  Skill({
    this.id,
    this.name,
  });

  static const fromJson = _$SkillFromJson;

  Map<String, dynamic> toJson() => _$SkillToJson(this);

  @override
  // TODO: implement props
  List<Object> get props => [id];
}

enum ShiftApprovalMode {
  manual,
  automatic,
}

enum ShiftApprovalPrivacy { private, public }
enum ShiftApprovalPermission {
  all_managers,
  myself,
}

enum ShiftStatus {
  draft,
  unfilled,
  filled,
  cancelled,
}

abstract class Shift extends Equatable {
  final int id;
  final int siteId;
  final Site site;
  final String name;
  final DateTime startOn;
  final DateTime finishOn;
  @JsonKey(name: "status")
  final String statusRaw;
  @JsonKey(name: "approvalType")
  final String approvalRaw;
  final List<int> skillIds;
  final List<Skill> skills;
  final description;

  Shift({
    this.id,
    this.siteId,
    this.site,
    this.name,
    this.startOn,
    this.finishOn,
    this.statusRaw,
    this.approvalRaw,
    this.skillIds,
    this.skills = const [],
    this.description,
    List props,
  });

  ShiftStatus get status {
    return statusRaw != null
        ? ShiftStatus.values.firstWhere(
            (d) => describeEnum(d).toLowerCase() == statusRaw.toLowerCase(),
            orElse: () => ShiftStatus.draft)
        : ShiftStatus.draft;
  }

  ShiftApprovalMode get approval {
    return approvalRaw != null
        ? ShiftApprovalMode.values.firstWhere(
            (d) => describeEnum(d).toLowerCase() == approvalRaw.toLowerCase(),
            orElse: () => ShiftApprovalMode.manual)
        : ShiftApprovalMode.manual;
  }

  bool get isFilled => status == ShiftStatus.filled;
  bool get isUnFilled => status == ShiftStatus.unfilled;
  bool get isNew => status == ShiftStatus.draft;

  bool get isPastShift => DateTimeHelper.isBefore(startOn);

  bool get isActive => !isPastShift && status != ShiftStatus.cancelled;

  bool get isCancelled => status == ShiftStatus.cancelled;
}

@JsonSerializable()
class ManageShift extends Shift {
  final List<Worker> workers;
  @JsonKey(name: "approvalPrivacy")
  final String approvalPrivacyRaw;
  final int dutyId;
  final Duty duty;
  final int headcount;
  final bool canApprove;

  final List<Manager> managers;
  final List<Worker> managerWorkers;
  final Worker createdBy;
  final List<int> otherSiteIds;
  final List<Site> otherSites;

  ManageShift({
    int id,
    int siteId,
    Site site,
    this.workers = const [],
    String name,
    DateTime startOn,
    DateTime finishOn,
    String statusRaw,
    String approvalRaw,
    this.approvalPrivacyRaw,
    this.dutyId,
    this.duty,
    List<int> skillIds,
    List<Skill> skills = const [],
    this.headcount = 0,
    String description,
    this.canApprove = true,
    this.managers,
    this.managerWorkers = const [],
    this.createdBy,
    this.otherSiteIds = const [],
    this.otherSites = const [],
  }) : super(
            id: id,
            siteId: siteId,
            site: site,
            name: name,
            startOn: startOn,
            finishOn: finishOn,
            statusRaw: statusRaw,
            approvalRaw: approvalRaw,
            skillIds: skillIds,
            skills: skills,
            description: description);

  ManageShift copyWith({
    Site site,
    Duty duty,
    List<Skill> skills,
    List<Worker> workers,
    List<Worker> managers,
    Worker createdBy,
    List<Site> otherSites,
  }) =>
      ManageShift(
        id: this.id,
        siteId: this.siteId,
        site: site ?? this.site,
        workers: workers ?? this.workers,
        name: this.name,
        startOn: this.startOn,
        finishOn: this.finishOn,
        statusRaw: this.statusRaw,
        approvalRaw: this.approvalRaw,
        approvalPrivacyRaw: this.approvalPrivacyRaw,
        dutyId: this.dutyId,
        duty: duty ?? this.duty,
        skillIds: this.skillIds,
        skills: skills ?? this.skills,
        headcount: this.headcount,
        description: this.description,
        canApprove: this.canApprove,
        managers: this.managers,
        managerWorkers: managers ?? this.managers,
        createdBy: createdBy ?? this.createdBy,
        otherSiteIds: this.otherSiteIds,
        otherSites: otherSites ?? this.otherSites,
      );

  FilteredResponses get responses => FilteredResponses(workers: this.workers);

  Worker myShift(int id) {
    return workers?.firstWhere((w) => id != null && w.id == id,
        orElse: () => null);
  }

  String get filledBy {
    if (isFilled) {
      final filtered = workers.where((w) => w.isApproved).toList();
      if (filtered.isNotEmpty) {
        if (filtered.length == 1) {
          return "Filled by ${filtered.first.name}";
        } else {
          final others = workers.length - 1;
          return "Filled by ${filtered.first.name} and ${workers.length - 1} ${others > 1 ? "others" : "other"}";
        }
      }
    }

    return "";
  }

  ShiftApprovalPrivacy get approvalPrivacy {
    return approvalPrivacyRaw != null
        ? ShiftApprovalPrivacy.values.firstWhere(
            (d) =>
                describeEnum(d).toLowerCase() ==
                approvalPrivacyRaw.toLowerCase(),
            orElse: () => ShiftApprovalPrivacy.private)
        : ShiftApprovalPrivacy.private;
  }

  int get headCountRemaining {
    if (workers.isEmpty) return headcount;
    final int count =
        workers.where((worker) => worker.status == WorkerStatus.awarded).length;
    return isFilled ? 0 : headcount - count;
  }

  static const fromJson = _$ManageShiftFromJson;

  Map<String, dynamic> toJson() => _$ManageShiftToJson(this);

  @override
  // TODO: implement props
  List<Object> get props => [
        id,
        siteId,
        name,
        startOn,
        finishOn,
        statusRaw,
        approvalRaw,
        skillIds,
        description,
        dutyId,
        approvalPrivacyRaw,
        headcount,
        managers,
        workers,
      ];
}

@JsonSerializable()
class MyShift extends Shift {
  @JsonKey(name: "myStatus")
  final String myStatusRaw;
  final int managerId;
  final Worker manager;
  final Worker worker;

  MyShift({
    int id,
    int siteId,
    Site site,
    String name,
    DateTime startOn,
    DateTime finishOn,
    String statusRaw,
    String approvalRaw,
    List<int> skillIds,
    List<Skill> skills = const [],
    String description,
    this.myStatusRaw,
    this.managerId,
    this.manager,
    this.worker,
  }) : super(
            id: id,
            siteId: siteId,
            site: site,
            name: name,
            startOn: startOn,
            finishOn: finishOn,
            statusRaw: statusRaw,
            approvalRaw: approvalRaw,
            skillIds: skillIds,
            skills: skills,
            description: description);

  MyShift copyWith({
    Site site,
    List<Skill> skills,
    Worker manager,
    Worker worker,
  }) =>
      MyShift(
        id: this.id,
        siteId: this.siteId,
        site: site ?? this.site,
        name: this.name,
        startOn: this.startOn,
        finishOn: this.finishOn,
        statusRaw: this.statusRaw,
        approvalRaw: this.approvalRaw,
        skillIds: this.skillIds,
        skills: skills ?? this.skills,
        description: this.description,
        managerId: this.managerId,
        manager: manager ?? this.manager,
        worker: worker ?? this.worker,
      );

  WorkerStatus get myStatus {
    return myStatusRaw != null
        ? WorkerStatus.values.firstWhere(
            (d) => describeEnum(d).toLowerCase() == myStatusRaw.toLowerCase(),
            orElse: () => WorkerStatus.pending)
        : WorkerStatus.pending;
  }

  static const fromJson = _$MyShiftFromJson;

  Map<String, dynamic> toJson() => _$MyShiftToJson(this);

  @override
  // TODO: implement props
  List<Object> get props => [
        id,
        siteId,
        name,
        startOn,
        finishOn,
        statusRaw,
        approvalRaw,
        skillIds,
        description,
        myStatusRaw,
        managerId,
      ];
}

class FilteredResponses {
  final List<Worker> workers;

  FilteredResponses({
    this.workers = const [],
  });

  List<Worker> get reviews {
    final statuses = reviewStatuses;
    return workers?.where((w) => statuses.contains(w.status))?.toList() ?? [];
  }

  List<Worker> get invited {
    return workers?.toList() ?? [];
  }

  List<Worker> get declined {
    final statuses = declinedStatuses;
    return workers?.where((w) => statuses.contains(w.status))?.toList() ?? [];
  }

  List<Worker> get approved {
    final statuses = approvedStatuses;
    return workers?.where((w) => statuses.contains(w.status))?.toList() ?? [];
  }

  int get reviewItemsCount => reviews.length;
  int get invitedItemCount => invited.length;
  int get declinedItemCount => declined.length;

  int get newItemsCount => workers
      .where((item) => (item.status == WorkerStatus.invited ||
          item.status == WorkerStatus.pending))
      .length;

  int get appliedCount =>
      workers.where((item) => (item.status == WorkerStatus.applied)).length;

  static List<WorkerStatus> reviewStatuses = const [
    WorkerStatus.applied,
  ];
  static List<WorkerStatus> invitesStatus = const [
    WorkerStatus.undecided,
    WorkerStatus.invited,
    WorkerStatus.pending,
    WorkerStatus.applied,
  ];

  static List<WorkerStatus> declinedStatuses = const [WorkerStatus.declined];
  static List<WorkerStatus> approvedStatuses = const [
    WorkerStatus.awarded,
  ];
}

enum WorkerType {
  individual,
  all,
}

enum WorkerStatus {
  none,
  //Manager invites worker to shift
  pending,
  //Invited worker is sent notification (has device)
  invited,
  //Worker declines shift
  declined,
  //Worker opens shifts but takes no action
  undecided,
  //Worker applies for shift
  applied,
  //Manager awards shift to worker, or system awards automatic approval
  awarded,
  // shifts are filled but worker already try to applied
  unawarded,
  //Shift is deleted by manager
  cancelled,
  //Worker removed by manager
  rejected,
}

@JsonSerializable()
class Worker extends Equatable {
  final int id;
  final String name;
  @JsonKey(name: "status")
  final String statusRaw;
  final WorkerType mode;
  @JsonKey(name: "profilePhotoPath")
  final String imagePath;
  final String dateOfBirth;
  final double rate;
  @JsonKey(name: "myShift")
  final String phone;
  final bool isPrimaryManager;
  @JsonKey(name: "isActive")
  final bool isWorkerActive;

  Worker({
    this.id,
    this.name,
    this.statusRaw,
    this.mode = WorkerType.individual,
    this.imagePath,
    this.rate,
    this.dateOfBirth,
    this.phone,
    this.isPrimaryManager = false,
    this.isWorkerActive = true,
  });

  factory Worker.manager(Manager manager, {bool isMyShift = false}) => Worker(
        id: manager.id,
        imagePath: manager.imagePath,
        mode: WorkerType.individual,
        name: manager.name,
        phone: manager.phone,
        isPrimaryManager: manager.isPrimaryManager,
        statusRaw: describeEnum(WorkerStatus.none),
        isWorkerActive: true,
      );

  factory Worker.all({String name}) => Worker(
        id: 0,
        name: name ?? "All managers",
        mode: WorkerType.all,
      );

  WorkerStatus get status {
    return statusRaw != null
        ? WorkerStatus.values.firstWhere(
            (d) => describeEnum(d).toLowerCase() == statusRaw.toLowerCase(),
            orElse: () => WorkerStatus.pending)
        : WorkerStatus.pending;
  }

  int get age {
    if (dateOfBirth != null) {
      final today = DateTimeHelper.getToday();
      final date = DateTime.tryParse(dateOfBirth);
      if (date != null) {
        return today.year - date.year;
      }
    }

    return null;
  }

  String get hourlyRate => rate != null ? rate.toStringAsFixed(2) : "";

  static const fromJson = _$WorkerFromJson;

  String get shiftViewedStatus {
    if (hasSeen) return "Seen";
    if (!isWorkerActive) return "Inactive";
    if (status == WorkerStatus.pending) return "Muted";

    return "";
  }

  Map<String, dynamic> toJson() => _$WorkerToJson(this);

  bool get isApproved => status == WorkerStatus.awarded;

  bool get isRequested => status == WorkerStatus.applied;

  bool isApprovalRequired(Shift shift) =>
      isInvited && shift.approval == ShiftApprovalMode.manual;

  bool get isInvited => (status == WorkerStatus.invited ||
      status == WorkerStatus.pending ||
      status == WorkerStatus.undecided);

  bool get isNew =>
      (status == WorkerStatus.invited || status == WorkerStatus.pending);

  bool get isActive => (status != WorkerStatus.rejected &&
      status != WorkerStatus.declined &&
      status != WorkerStatus.cancelled);

  bool get hasSeen =>
      status == WorkerStatus.undecided || status == WorkerStatus.declined;

  bool get isDeclined => status == WorkerStatus.declined;

  @override
  // TODO: implement props
  List<Object> get props => [id, statusRaw];
}

@JsonSerializable()
class Duty extends Equatable {
  final int id;
  final String name;
  final List<int> skillIds;
  final bool isDefault;

  Duty({
    this.id,
    this.name,
    this.skillIds = const [],
    this.isDefault = false,
  });

  static const fromJson = _$DutyFromJson;

  Map<String, dynamic> toJson() => _$DutyToJson(this);

  @override
  // TODO: implement props
  List<Object> get props => [id];
}

@JsonSerializable()
class CreateShiftRequest {
  final int id;
  final int siteId;
  final List<int> otherSiteIds;
  final List<int> otherManagers;
  final String name;
  final String description;
  final DateTime startOn;
  final DateTime finishOn;
  final int dutyId;
  final List<int> skillIds;
  final int headcount;
  final ShiftApprovalMode mode;
  final ShiftApprovalPrivacy privacyMode;
  @JsonKey(name: "approvalType")
  String approvalType;
  @JsonKey(name: "approvalPrivacy")
  String approvalPrivacy;

  CreateShiftRequest({
    this.id,
    this.siteId,
    this.otherSiteIds = const [],
    this.otherManagers = const [],
    this.name,
    this.description,
    this.startOn,
    this.finishOn,
    this.dutyId,
    this.skillIds = const [],
    this.headcount,
    this.mode,
    this.privacyMode,
  }) {
    approvalType = mode != null
        ? describeEnum(mode)
        : describeEnum(ShiftApprovalMode.automatic);

    approvalPrivacy = privacyMode != null
        ? describeEnum(privacyMode)
        : describeEnum(ShiftApprovalPrivacy.private);
  }

  static const fromJson = _$CreateShiftRequestFromJson;

  Map<String, dynamic> toJson() => _$CreateShiftRequestToJson(this);
}

@JsonSerializable()
class Manager extends Equatable {
  final int id;
  final String name;
  @JsonKey(name: "profilePhotoPath")
  final String imagePath;
  final String phone;
  final bool isPrimaryManager;

  Manager({
    this.id,
    this.name,
    this.imagePath,
    this.phone,
    this.isPrimaryManager = false,
  });

  static const fromJson = _$ManagerFromJson;

  Map<String, dynamic> toJson() => _$ManagerToJson(this);

  @override
  // TODO: implement props
  List<Object> get props => [id];
}

@JsonSerializable()
class ShiftWorkerUpdateRequest {
  @JsonKey(name: "id")
  final int shiftId;
  final int workerId;
  final WorkerStatus workerStaus;
  @JsonKey(name: "status")
  String status;

  ShiftWorkerUpdateRequest({
    this.shiftId,
    this.workerId,
    this.workerStaus = WorkerStatus.pending,
  }) {
    status = describeEnum(workerStaus);
  }

  static const fromJson = _$ShiftWorkerUpdateRequestFromJson;

  Map<String, dynamic> toJson() => _$ShiftWorkerUpdateRequestToJson(this);
}

@JsonSerializable()
class ShiftHeadCountRequest {
  final List<int> skillIds;
  final List<int> siteIds;

  ShiftHeadCountRequest({
    this.skillIds = const [],
    this.siteIds = const [],
  });

  static const fromJson = _$ShiftHeadCountRequestFromJson;

  Map<String, dynamic> toJson() => _$ShiftHeadCountRequestToJson(this);
}

@JsonSerializable()
class PatchShiftRequest {
  final int id;
  final List<int> otherSiteIds;
  final List<int> otherManagerIds;

  PatchShiftRequest({
    this.id,
    this.otherSiteIds,
    this.otherManagerIds,
  });

  static const fromJson = _$PatchShiftRequestFromJson;

  Map<String, dynamic> toJson() => _$PatchShiftRequestToJson(this);
}
