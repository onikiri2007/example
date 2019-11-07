import 'package:meta/meta.dart';
import 'package:equatable/equatable.dart';
import 'package:yodel/src/api/index.dart';

class Session extends Equatable {
  final String userKey;
  final UserData userData;

  Session({
    @required this.userKey,
    @required this.userData,
  });

  Session copyWith({
    UserData userData,
  }) {
    return Session(
      userKey: userKey,
      userData: userData ?? this.userData,
    );
  }

  List<int> get skillIds => userData.skillIds ?? [];
  List<int> get siteIds => userData.siteIds ?? [];

  static const fromJson = _$SessionFromJson;

  Map<String, dynamic> toJson() => _$SessionToJson(this);

  factory Session.fromUserData(
    UserData userData,
  ) {
    return Session(
      userKey: userData.userKey,
      userData: userData,
    );
  }

  @override
  // TODO: implement props
  List<Object> get props => [userKey];
}

Session _$SessionFromJson(Map<String, dynamic> json) {
  var data = UserData.fromJson(json);
  return Session(userData: data, userKey: data.userKey);
}

Map<String, dynamic> _$SessionToJson(Session instance) {
  return instance.userData.toJson();
}
