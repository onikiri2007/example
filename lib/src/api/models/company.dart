import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:yodel/src/api/models/models.dart';

part 'company.g.dart';

@JsonSerializable()
class Company extends Equatable {
  final String name;
  final String logoPath;
  final List<Site> sites;
  final List<Skill> skills;
  final List<Duty> duties;

  Company({
    this.name,
    this.logoPath,
    this.sites,
    this.skills,
    this.duties,
  });

  factory Company.empty() => Company(
        name: "",
        sites: const [],
        skills: const [],
        duties: const [],
      );

  static const fromJson = _$CompanyFromJson;

  Map<String, dynamic> toJson() => _$CompanyToJson(this);

  List<Manager> allManagers() {
    List<Manager> managers = [];

    sites.forEach((site) {
      final ids = managers.map((m) => m.id);
      managers.addAll(site.managers.where((m) => !ids.contains(m.id)));
    });

    return managers;
  }

  List<Duty> get sortedDuties {
    List<Duty> sortedDuties = [];
    sortedDuties.addAll(this.duties ?? []);
    sortedDuties.sort((d, d1) => d.name.compareTo(d1.name));
    return sortedDuties;
  }

  @override
  // TODO: implement props
  List<Object> get props => [
        name,
        sites,
        skills,
        duties,
      ];
}
