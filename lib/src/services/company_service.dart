import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:yodel/src/api/index.dart';
import 'package:dio/dio.dart';
import 'package:yodel/src/bootstrapper.dart';
import 'package:yodel/src/services/services.dart';

const String kCompany = "Company";
const String kCompanyLastUpdated = "CompanyLastUpdated";

abstract class CompanyService {
  Future<ServiceResult<Company>> loadCompanyData();
  Future<ServiceResult<List<Worker>>> searchManagers(String query,
      {int siteId});
  Future<ServiceResult<List<Site>>> searchSites(String query);
  Future<ServiceResult<List<Skill>>> searchSkills(String query, {int dutyId});
  Future<ServiceResult<List<Duty>>> getDuties();
  Future<ServiceResult<void>> clearCompanyData();
  Company get company;
}

class CompanyServiceImpl with ServiceMixin implements CompanyService {
  final YodelApi api;
  final Future<SharedPreferences> sharedPreferences;
  Company _company;

  CompanyServiceImpl({
    YodelApi api,
    Future<SharedPreferences> sharedPreferences,
  })  : this.api = api ?? sl<YodelApi>(),
        this.sharedPreferences =
            sharedPreferences ?? sl<Future<SharedPreferences>>();

  @override
  Future<ServiceResult<Company>> loadCompanyData() async {
    try {
      final pref = await sharedPreferences;
      final companyString = pref.getString(kCompany);
      final companyLastUpdated = await _getLastCompanyDataUpdated();
      final today = DateTime.now();
      if (companyLastUpdated != null &&
          today.difference(companyLastUpdated).inHours < 2) {
        if (companyString != null && companyString.isNotEmpty) {
          _company = Company.fromJson(json.decode(companyString));
          return ServiceResult.success(_company);
        }
      }

      var response = await api.getCurrentCompany();
      _company = response.data;

      if (_company.sites != null &&
          _company.skills != null &&
          _company.duties != null) {
        await pref.setString(kCompany, json.encode(response.data.toJson()));
        await setLastCompanyDataUpDate(DateTime.now());
      }

      return ServiceResult.success(_company);
    } on DioError catch (error) {
      onApiError<Company>(error);
      return ServiceResult.success(_company);
    } catch (error, stacktrace) {
      onApiException<Company>(error, stacktrace);
      return ServiceResult.success(_company);
    }
  }

  Future<DateTime> _getLastCompanyDataUpdated() async {
    final pref = await sharedPreferences;
    final companyLastUpdatedString = pref.getString(kCompanyLastUpdated);
    if (companyLastUpdatedString != null &&
        companyLastUpdatedString.isNotEmpty) {
      return DateTime.tryParse(companyLastUpdatedString);
    }
    return null;
  }

  Future<void> setLastCompanyDataUpDate(DateTime date) async {
    final pref = await sharedPreferences;
    await pref.setString(kCompanyLastUpdated, date.toIso8601String());
  }

  @override
  Future<ServiceResult<List<Site>>> searchSites(String query) async {
    if (_company == null) {
      var r = await loadCompanyData();
      if (r.isSuccessful) {
        _company = r.result;
      }
    }

    final list = query != null && query.isNotEmpty
        ? _company.sites
            .where((c) => c.name.toLowerCase().contains(query.toLowerCase()))
            .toList()
        : _company.sites.toList();

    return ServiceResult.success(list);
  }

  @override
  Future<ServiceResult<List<Worker>>> searchManagers(String query,
      {int siteId}) async {
    if (_company == null) {
      var r = await loadCompanyData();
      if (r.isSuccessful) {
        _company = r.result;
      }
    }

    List<Manager> managers = [];

    if (siteId == null) {
      _company.sites.forEach((m) => managers.addAll(m.managers));
    } else {
      final site =
          _company.sites.firstWhere((s) => s.id == siteId, orElse: () => null);
      if (site != null) {
        managers.addAll(site.managers);
      }
    }

    final list = query != null && query.isNotEmpty
        ? managers
            .where((c) => c.name.toLowerCase().contains(query.toLowerCase()))
            .toList()
        : managers;

    return ServiceResult.success(list
        .map((m) => Worker(
              id: m.id,
              mode: WorkerType.individual,
              name: m.name,
              imagePath: m.imagePath,
            ))
        .toList());
  }

  @override
  Future<ServiceResult<List<Skill>>> searchSkills(String query,
      {int dutyId}) async {
    if (_company == null) {
      var r = await loadCompanyData();
      if (r.isSuccessful) {
        _company = r.result;
      }
    }

    List<Skill> skills = [];

    if (dutyId == null) {
      skills = _company.skills;
    } else {
      final duty = _company.sortedDuties
          .firstWhere((s) => s.id == dutyId, orElse: () => null);
      if (duty != null) {
        skills
            .addAll(_company.skills.where((s) => duty.skillIds.contains(s.id)));
      }
    }

    final list = query != null && query.isNotEmpty
        ? skills
            .where((c) => c.name.toLowerCase().contains(query.toLowerCase()))
            .toList()
        : skills;

    return ServiceResult.success(list);
  }

  @override
  Future<ServiceResult<List<Duty>>> getDuties() async {
    if (_company == null) {
      var r = await loadCompanyData();
      if (r.isSuccessful) {
        _company = r.result;
      }
    }

    return ServiceResult.success(_company.duties);
  }

  @override
  Company get company => _company;

  @override
  Future<ServiceResult<void>> clearCompanyData() async {
    try {
      final pref = await sharedPreferences;
      await pref.remove(kCompanyLastUpdated);
      await pref.remove(kCompanyLastUpdated);
      return ServiceResult.successWithNoData();
    } catch (error) {
      return ServiceResult.failure(errorMessage: error.toString());
    }
  }
}
