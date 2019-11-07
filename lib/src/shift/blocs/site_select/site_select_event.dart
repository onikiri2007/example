import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';
import 'package:yodel/src/api/index.dart';

@immutable
abstract class SiteSelectEvent {}

class SelectSite extends SiteSelectEvent {
  final Site site;
  final bool isSelected;
  SelectSite({
    this.site,
    this.isSelected,
  });

  @override
  String toString() => 'SelectSite';
}
