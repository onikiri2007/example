import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:yodel/src/api/index.dart';
import 'package:yodel/src/theme/themes.dart';

enum BottomTabItemType {
  Manage,
  MyShifts,
  Notifications,
  Profile,
}

class BottomTabItem {
  final BottomTabItemType type;
  final IconData icon;
  final IconData activeIcon;
  final String tabName;

  BottomTabItem({
    @required this.type,
    @required this.icon,
    IconData activeIcon,
    this.tabName,
  }) : this.activeIcon = activeIcon ?? icon;

  String get name => tabName ?? describeEnum(type);
}

class BottomTabItems {
  static List<BottomTabItem> getTabsByUser(UserData user) => [
        if (user.isManagementRole)
          BottomTabItem(
            icon: YodelIcons.manage,
            type: BottomTabItemType.Manage,
          ),
        BottomTabItem(
            icon: YodelIcons.myshifts,
            type: BottomTabItemType.MyShifts,
            tabName: "My Shifts"),
        BottomTabItem(
          icon: YodelIcons.notifications,
          type: BottomTabItemType.Notifications,
        ),
        BottomTabItem(
          icon: YodelIcons.profile,
          type: BottomTabItemType.Profile,
        ),
      ];
}
