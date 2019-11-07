import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:yodel/src/theme/themes.dart';

class SliverTabBarDelegate extends SliverPersistentHeaderDelegate {
  SliverTabBarDelegate(
    this._tabBar, {
    this.key,
    Decoration decoration,
  }) : this.decoration =
            decoration ?? BoxDecoration(color: YodelTheme.darkGreyBlue);

  final TabBar _tabBar;
  final Decoration decoration;
  final Key key;

  @override
  double get minExtent => _tabBar.preferredSize.height;
  @override
  double get maxExtent => _tabBar.preferredSize.height;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return new Container(
      padding: EdgeInsets.symmetric(horizontal: 7, vertical: 0),
      decoration: decoration,
      child: _tabBar,
    );
  }

  @override
  bool shouldRebuild(SliverTabBarDelegate oldDelegate) {
    return oldDelegate.key != this.key;
  }
}
