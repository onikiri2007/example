// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notification.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

YodelNotification _$YodelNotificationFromJson(Map<String, dynamic> json) {
  return YodelNotification(
    id: json['id'] as int,
    siteId: json['siteId'] as int,
    site: json['site'] == null
        ? null
        : Site.fromJson(json['site'] as Map<String, dynamic>),
    shiftId: json['shiftId'] as int,
    fromProfilePhotoPath: json['fromProfilePhotoPath'] as String,
    title: json['title'] as String,
    message: json['message'] as String,
    ago: json['ago'] as String,
    createdOn: _fromJson(json['createdOn'] as String),
    isWorkerNotification: json['isWorkerNotification'] as bool,
    isViewed: json['isViewed'] as bool,
    fromUserId: json['fromUserId'] as int,
  );
}

Map<String, dynamic> _$YodelNotificationToJson(YodelNotification instance) =>
    <String, dynamic>{
      'id': instance.id,
      'siteId': instance.siteId,
      'shiftId': instance.shiftId,
      'fromProfilePhotoPath': instance.fromProfilePhotoPath,
      'title': instance.title,
      'message': instance.message,
      'ago': instance.ago,
      'createdOn': _toJson(instance.createdOn),
      'isWorkerNotification': instance.isWorkerNotification,
      'site': instance.site,
      'isViewed': instance.isViewed,
      'fromUserId': instance.fromUserId,
    };

NotificationPatchRequest _$NotificationPatchRequestFromJson(
    Map<String, dynamic> json) {
  return NotificationPatchRequest(
    json['id'] as int,
    isViewed: json['isViewed'] as bool,
  );
}

Map<String, dynamic> _$NotificationPatchRequestToJson(
        NotificationPatchRequest instance) =>
    <String, dynamic>{
      'id': instance.id,
      'isViewed': instance.isViewed,
    };
