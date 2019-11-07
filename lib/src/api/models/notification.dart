import 'package:equatable/equatable.dart';
import 'package:intl/intl.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:yodel/src/api/index.dart';

part 'notification.g.dart';

@JsonSerializable()
class YodelNotification extends Equatable {
  final int id;
  final int siteId;
  final int shiftId;
  final String fromProfilePhotoPath;
  final String title;
  final String message;
  final String ago;
  @JsonKey(fromJson: _fromJson, toJson: _toJson)
  final DateTime createdOn;
  final bool isWorkerNotification;
  final Site site;
  final bool isViewed;
  final int fromUserId;

  YodelNotification({
    this.id,
    this.siteId,
    this.site,
    this.shiftId,
    this.fromProfilePhotoPath,
    this.title,
    this.message,
    this.ago,
    this.createdOn,
    this.isWorkerNotification = false,
    this.isViewed = false,
    this.fromUserId,
  });

  YodelNotification copyWith({
    int id,
    int siteId,
    Site site,
    int shiftId,
    String fromProfilePhotoPath,
    String title,
    String message,
    String ago,
    DateTime createdOn,
    bool isWorkerNotification,
    bool isViewed,
  }) =>
      YodelNotification(
        id: id ?? this.id,
        siteId: siteId ?? this.siteId,
        site: site ?? this.site,
        shiftId: shiftId ?? this.shiftId,
        fromProfilePhotoPath: fromProfilePhotoPath ?? this.fromProfilePhotoPath,
        title: title ?? this.title,
        message: message ?? this.message,
        ago: ago ?? this.ago,
        createdOn: createdOn ?? this.createdOn,
        isWorkerNotification: isWorkerNotification ?? this.isWorkerNotification,
        isViewed: isViewed ?? this.isViewed,
        fromUserId: fromUserId ?? this.fromUserId,
      );

  static const fromJson = _$YodelNotificationFromJson;

  Map<String, dynamic> toJson() => _$YodelNotificationToJson(this);

  @override
  // TODO: implement props
  List<Object> get props => [id];
}

@JsonSerializable()
class NotificationPatchRequest {
  final int id;
  final bool isViewed;

  NotificationPatchRequest(
    this.id, {
    this.isViewed = true,
  });

  static const fromJson = _$NotificationPatchRequestFromJson;

  Map<String, dynamic> toJson() => _$NotificationPatchRequestToJson(this);
}

final _dateFormatter = new DateFormat("yyyy-MM-ddTHH:mm:ss");
DateTime _fromJson(String date) => _dateFormatter.parse(date);

String _toJson(DateTime date) => _dateFormatter.format(date);
