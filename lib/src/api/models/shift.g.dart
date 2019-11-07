// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'shift.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Site _$SiteFromJson(Map<String, dynamic> json) {
  return Site(
    id: json['id'] as int,
    name: json['name'] as String,
    address: json['address'] as String,
    latitude: (json['latitude'] as num)?.toDouble(),
    longitude: (json['longitude'] as num)?.toDouble(),
    distanceKm: (json['distanceKm'] as num)?.toDouble(),
    managers: (json['managers'] as List)
        ?.map((e) =>
            e == null ? null : Manager.fromJson(e as Map<String, dynamic>))
        ?.toList(),
    imagePath: json['imagePath'] as String,
    contactEmail: json['contactEmail'] as String,
    contactPhone: json['contactPhone'] as String,
  );
}

Map<String, dynamic> _$SiteToJson(Site instance) => <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'address': instance.address,
      'latitude': instance.latitude,
      'longitude': instance.longitude,
      'distanceKm': instance.distanceKm,
      'managers': instance.managers,
      'imagePath': instance.imagePath,
      'contactEmail': instance.contactEmail,
      'contactPhone': instance.contactPhone,
    };

Skill _$SkillFromJson(Map<String, dynamic> json) {
  return Skill(
    id: json['id'] as int,
    name: json['name'] as String,
  );
}

Map<String, dynamic> _$SkillToJson(Skill instance) => <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
    };

ManageShift _$ManageShiftFromJson(Map<String, dynamic> json) {
  return ManageShift(
    id: json['id'] as int,
    siteId: json['siteId'] as int,
    site: json['site'] == null
        ? null
        : Site.fromJson(json['site'] as Map<String, dynamic>),
    workers: (json['workers'] as List)
        ?.map((e) =>
            e == null ? null : Worker.fromJson(e as Map<String, dynamic>))
        ?.toList(),
    name: json['name'] as String,
    startOn: json['startOn'] == null
        ? null
        : DateTime.parse(json['startOn'] as String),
    finishOn: json['finishOn'] == null
        ? null
        : DateTime.parse(json['finishOn'] as String),
    statusRaw: json['status'] as String,
    approvalRaw: json['approvalType'] as String,
    approvalPrivacyRaw: json['approvalPrivacy'] as String,
    dutyId: json['dutyId'] as int,
    duty: json['duty'] == null
        ? null
        : Duty.fromJson(json['duty'] as Map<String, dynamic>),
    skillIds: (json['skillIds'] as List)?.map((e) => e as int)?.toList(),
    skills: (json['skills'] as List)
        ?.map(
            (e) => e == null ? null : Skill.fromJson(e as Map<String, dynamic>))
        ?.toList(),
    headcount: json['headcount'] as int,
    description: json['description'] as String,
    canApprove: json['canApprove'] as bool,
    managers: (json['managers'] as List)
        ?.map((e) =>
            e == null ? null : Manager.fromJson(e as Map<String, dynamic>))
        ?.toList(),
    managerWorkers: (json['managerWorkers'] as List)
        ?.map((e) =>
            e == null ? null : Worker.fromJson(e as Map<String, dynamic>))
        ?.toList(),
    createdBy: json['createdBy'] == null
        ? null
        : Worker.fromJson(json['createdBy'] as Map<String, dynamic>),
    otherSiteIds:
        (json['otherSiteIds'] as List)?.map((e) => e as int)?.toList(),
    otherSites: (json['otherSites'] as List)
        ?.map(
            (e) => e == null ? null : Site.fromJson(e as Map<String, dynamic>))
        ?.toList(),
  );
}

Map<String, dynamic> _$ManageShiftToJson(ManageShift instance) =>
    <String, dynamic>{
      'id': instance.id,
      'siteId': instance.siteId,
      'site': instance.site,
      'name': instance.name,
      'startOn': instance.startOn?.toIso8601String(),
      'finishOn': instance.finishOn?.toIso8601String(),
      'status': instance.statusRaw,
      'approvalType': instance.approvalRaw,
      'skillIds': instance.skillIds,
      'skills': instance.skills,
      'description': instance.description,
      'workers': instance.workers,
      'approvalPrivacy': instance.approvalPrivacyRaw,
      'dutyId': instance.dutyId,
      'duty': instance.duty,
      'headcount': instance.headcount,
      'canApprove': instance.canApprove,
      'managers': instance.managers,
      'managerWorkers': instance.managerWorkers,
      'createdBy': instance.createdBy,
      'otherSiteIds': instance.otherSiteIds,
      'otherSites': instance.otherSites,
    };

MyShift _$MyShiftFromJson(Map<String, dynamic> json) {
  return MyShift(
    id: json['id'] as int,
    siteId: json['siteId'] as int,
    site: json['site'] == null
        ? null
        : Site.fromJson(json['site'] as Map<String, dynamic>),
    name: json['name'] as String,
    startOn: json['startOn'] == null
        ? null
        : DateTime.parse(json['startOn'] as String),
    finishOn: json['finishOn'] == null
        ? null
        : DateTime.parse(json['finishOn'] as String),
    statusRaw: json['status'] as String,
    approvalRaw: json['approvalType'] as String,
    skillIds: (json['skillIds'] as List)?.map((e) => e as int)?.toList(),
    skills: (json['skills'] as List)
        ?.map(
            (e) => e == null ? null : Skill.fromJson(e as Map<String, dynamic>))
        ?.toList(),
    description: json['description'] as String,
    myStatusRaw: json['myStatus'] as String,
    managerId: json['managerId'] as int,
    manager: json['manager'] == null
        ? null
        : Worker.fromJson(json['manager'] as Map<String, dynamic>),
    worker: json['worker'] == null
        ? null
        : Worker.fromJson(json['worker'] as Map<String, dynamic>),
  );
}

Map<String, dynamic> _$MyShiftToJson(MyShift instance) => <String, dynamic>{
      'id': instance.id,
      'siteId': instance.siteId,
      'site': instance.site,
      'name': instance.name,
      'startOn': instance.startOn?.toIso8601String(),
      'finishOn': instance.finishOn?.toIso8601String(),
      'status': instance.statusRaw,
      'approvalType': instance.approvalRaw,
      'skillIds': instance.skillIds,
      'skills': instance.skills,
      'description': instance.description,
      'myStatus': instance.myStatusRaw,
      'managerId': instance.managerId,
      'manager': instance.manager,
      'worker': instance.worker,
    };

Worker _$WorkerFromJson(Map<String, dynamic> json) {
  return Worker(
    id: json['id'] as int,
    name: json['name'] as String,
    statusRaw: json['status'] as String,
    mode: _$enumDecodeNullable(_$WorkerTypeEnumMap, json['mode']),
    imagePath: json['profilePhotoPath'] as String,
    rate: (json['rate'] as num)?.toDouble(),
    dateOfBirth: json['dateOfBirth'] as String,
    phone: json['myShift'] as String,
    isPrimaryManager: json['isPrimaryManager'] as bool,
    isWorkerActive: json['isActive'] as bool,
  );
}

Map<String, dynamic> _$WorkerToJson(Worker instance) => <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'status': instance.statusRaw,
      'mode': _$WorkerTypeEnumMap[instance.mode],
      'profilePhotoPath': instance.imagePath,
      'dateOfBirth': instance.dateOfBirth,
      'rate': instance.rate,
      'myShift': instance.phone,
      'isPrimaryManager': instance.isPrimaryManager,
      'isActive': instance.isWorkerActive,
    };

T _$enumDecode<T>(Map<T, dynamic> enumValues, dynamic source) {
  if (source == null) {
    throw ArgumentError('A value must be provided. Supported values: '
        '${enumValues.values.join(', ')}');
  }
  return enumValues.entries
      .singleWhere((e) => e.value == source,
          orElse: () => throw ArgumentError(
              '`$source` is not one of the supported values: '
              '${enumValues.values.join(', ')}'))
      .key;
}

T _$enumDecodeNullable<T>(Map<T, dynamic> enumValues, dynamic source) {
  if (source == null) {
    return null;
  }
  return _$enumDecode<T>(enumValues, source);
}

const _$WorkerTypeEnumMap = <WorkerType, dynamic>{
  WorkerType.individual: 'individual',
  WorkerType.all: 'all'
};

Duty _$DutyFromJson(Map<String, dynamic> json) {
  return Duty(
    id: json['id'] as int,
    name: json['name'] as String,
    skillIds: (json['skillIds'] as List)?.map((e) => e as int)?.toList(),
    isDefault: json['isDefault'] as bool,
  );
}

Map<String, dynamic> _$DutyToJson(Duty instance) => <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'skillIds': instance.skillIds,
      'isDefault': instance.isDefault,
    };

CreateShiftRequest _$CreateShiftRequestFromJson(Map<String, dynamic> json) {
  return CreateShiftRequest(
    id: json['id'] as int,
    siteId: json['siteId'] as int,
    otherSiteIds:
        (json['otherSiteIds'] as List)?.map((e) => e as int)?.toList(),
    otherManagers:
        (json['otherManagers'] as List)?.map((e) => e as int)?.toList(),
    name: json['name'] as String,
    description: json['description'] as String,
    startOn: json['startOn'] == null
        ? null
        : DateTime.parse(json['startOn'] as String),
    finishOn: json['finishOn'] == null
        ? null
        : DateTime.parse(json['finishOn'] as String),
    dutyId: json['dutyId'] as int,
    skillIds: (json['skillIds'] as List)?.map((e) => e as int)?.toList(),
    headcount: json['headcount'] as int,
    mode: _$enumDecodeNullable(_$ShiftApprovalModeEnumMap, json['mode']),
    privacyMode: _$enumDecodeNullable(
        _$ShiftApprovalPrivacyEnumMap, json['privacyMode']),
  )
    ..approvalType = json['approvalType'] as String
    ..approvalPrivacy = json['approvalPrivacy'] as String;
}

Map<String, dynamic> _$CreateShiftRequestToJson(CreateShiftRequest instance) =>
    <String, dynamic>{
      'id': instance.id,
      'siteId': instance.siteId,
      'otherSiteIds': instance.otherSiteIds,
      'otherManagers': instance.otherManagers,
      'name': instance.name,
      'description': instance.description,
      'startOn': instance.startOn?.toIso8601String(),
      'finishOn': instance.finishOn?.toIso8601String(),
      'dutyId': instance.dutyId,
      'skillIds': instance.skillIds,
      'headcount': instance.headcount,
      'mode': _$ShiftApprovalModeEnumMap[instance.mode],
      'privacyMode': _$ShiftApprovalPrivacyEnumMap[instance.privacyMode],
      'approvalType': instance.approvalType,
      'approvalPrivacy': instance.approvalPrivacy,
    };

const _$ShiftApprovalModeEnumMap = <ShiftApprovalMode, dynamic>{
  ShiftApprovalMode.manual: 'manual',
  ShiftApprovalMode.automatic: 'automatic'
};

const _$ShiftApprovalPrivacyEnumMap = <ShiftApprovalPrivacy, dynamic>{
  ShiftApprovalPrivacy.private: 'private',
  ShiftApprovalPrivacy.public: 'public'
};

Manager _$ManagerFromJson(Map<String, dynamic> json) {
  return Manager(
    id: json['id'] as int,
    name: json['name'] as String,
    imagePath: json['profilePhotoPath'] as String,
    phone: json['phone'] as String,
    isPrimaryManager: json['isPrimaryManager'] as bool,
  );
}

Map<String, dynamic> _$ManagerToJson(Manager instance) => <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'profilePhotoPath': instance.imagePath,
      'phone': instance.phone,
      'isPrimaryManager': instance.isPrimaryManager,
    };

ShiftWorkerUpdateRequest _$ShiftWorkerUpdateRequestFromJson(
    Map<String, dynamic> json) {
  return ShiftWorkerUpdateRequest(
    shiftId: json['id'] as int,
    workerId: json['workerId'] as int,
    workerStaus:
        _$enumDecodeNullable(_$WorkerStatusEnumMap, json['workerStaus']),
  )..status = json['status'] as String;
}

Map<String, dynamic> _$ShiftWorkerUpdateRequestToJson(
        ShiftWorkerUpdateRequest instance) =>
    <String, dynamic>{
      'id': instance.shiftId,
      'workerId': instance.workerId,
      'workerStaus': _$WorkerStatusEnumMap[instance.workerStaus],
      'status': instance.status,
    };

const _$WorkerStatusEnumMap = <WorkerStatus, dynamic>{
  WorkerStatus.none: 'none',
  WorkerStatus.pending: 'pending',
  WorkerStatus.invited: 'invited',
  WorkerStatus.declined: 'declined',
  WorkerStatus.undecided: 'undecided',
  WorkerStatus.applied: 'applied',
  WorkerStatus.awarded: 'awarded',
  WorkerStatus.unawarded: 'unawarded',
  WorkerStatus.cancelled: 'cancelled',
  WorkerStatus.rejected: 'rejected'
};

ShiftHeadCountRequest _$ShiftHeadCountRequestFromJson(
    Map<String, dynamic> json) {
  return ShiftHeadCountRequest(
    skillIds: (json['skillIds'] as List)?.map((e) => e as int)?.toList(),
    siteIds: (json['siteIds'] as List)?.map((e) => e as int)?.toList(),
  );
}

Map<String, dynamic> _$ShiftHeadCountRequestToJson(
        ShiftHeadCountRequest instance) =>
    <String, dynamic>{
      'skillIds': instance.skillIds,
      'siteIds': instance.siteIds,
    };

PatchShiftRequest _$PatchShiftRequestFromJson(Map<String, dynamic> json) {
  return PatchShiftRequest(
    id: json['id'] as int,
    otherSiteIds:
        (json['otherSiteIds'] as List)?.map((e) => e as int)?.toList(),
    otherManagerIds:
        (json['otherManagerIds'] as List)?.map((e) => e as int)?.toList(),
  );
}

Map<String, dynamic> _$PatchShiftRequestToJson(PatchShiftRequest instance) =>
    <String, dynamic>{
      'id': instance.id,
      'otherSiteIds': instance.otherSiteIds,
      'otherManagerIds': instance.otherManagerIds,
    };
