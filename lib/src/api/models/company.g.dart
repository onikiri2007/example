// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'company.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Company _$CompanyFromJson(Map<String, dynamic> json) {
  return Company(
    name: json['name'] as String,
    logoPath: json['logoPath'] as String,
    sites: (json['sites'] as List)
        ?.map(
            (e) => e == null ? null : Site.fromJson(e as Map<String, dynamic>))
        ?.toList(),
    skills: (json['skills'] as List)
        ?.map(
            (e) => e == null ? null : Skill.fromJson(e as Map<String, dynamic>))
        ?.toList(),
    duties: (json['duties'] as List)
        ?.map(
            (e) => e == null ? null : Duty.fromJson(e as Map<String, dynamic>))
        ?.toList(),
  );
}

Map<String, dynamic> _$CompanyToJson(Company instance) => <String, dynamic>{
      'name': instance.name,
      'logoPath': instance.logoPath,
      'sites': instance.sites,
      'skills': instance.skills,
      'duties': instance.duties,
    };
