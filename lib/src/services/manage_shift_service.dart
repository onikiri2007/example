import 'package:yodel/src/api/index.dart';
import 'package:yodel/src/authentication/bloc/session_tracker.dart';
import 'package:yodel/src/bootstrapper.dart';
import 'package:yodel/src/services/services.dart';
import 'package:yodel/src/shift/index.dart';
import 'package:dio/dio.dart';

abstract class ManageShiftService {
  Future<ServiceResult<List<ManageShift>>> getShifts();

  Future<ServiceResult<ManageShift>> getShift(int shiftId);
  Future<ServiceResult<ManageShift>> createShift(
    ShiftDetails details,
    ShiftPeopleRequirements staffRequirements,
    ShiftApprovalRequirements approvalRequirements,
  );
  Future<ServiceResult<ManageShift>> sendNotification(int shiftId);
  Future<ServiceResult<int>> getEligibleHeadCount({
    List<int> skillIds = const [],
    List<int> siteIds = const [],
  });

  Future<ServiceResult<ManageShift>> updateWorkerStatus(
      ShiftWorkerUpdateRequest req);
  Future<ServiceResult<ManageShift>> deleteShift(int shiftId);
  Future<ServiceResult<ManageShift>> updateShift(PatchShiftRequest req);
}

class ManageShiftServiceImpl with ServiceMixin implements ManageShiftService {
  final YodelApi api;
  final CompanyService companyService;
  final SessionTracker sessionTracker;

  ManageShiftServiceImpl(
      {YodelApi api,
      CompanyService companyService,
      SessionTracker sessionTracker})
      : this.api = api ?? sl<YodelApi>(),
        this.companyService = companyService ?? sl<CompanyService>(),
        this.sessionTracker = sessionTracker ?? sl<SessionTracker>();

  @override
  Future<ServiceResult<ManageShift>> createShift(
    ShiftDetails details,
    ShiftPeopleRequirements staffRequirements,
    ShiftApprovalRequirements approvalRequirements,
  ) async {
    try {
      var response = await api.createShift(
        CreateShiftRequest(
          description: details.description,
          finishOn: details.endDate,
          startOn: details.startDate,
          headcount: staffRequirements.noOfPeople,
          mode: approvalRequirements.mode,
          name: details.name,
          otherManagers: approvalRequirements.workers
              .where((m) => m.id > 0)
              .map((m) => m.id)
              .toList(),
          siteId: details.location.id,
          otherSiteIds: staffRequirements.sites.map((s) => s.id).toList(),
          skillIds: staffRequirements.skills.map((skill) => skill.id).toList(),
          dutyId: staffRequirements.role.id,
          privacyMode: approvalRequirements.privacyMode,
        ),
      );

      return ServiceResult.success(response.data);
    } on DioError catch (error) {
      return onApiError<ManageShift>(error);
    } catch (error, stacktrace) {
      return onApiException<ManageShift>(error, stacktrace);
    }
  }

  @override
  Future<ServiceResult<ManageShift>> getShift(int shiftId) async {
    try {
      var response = await api.getManagedShift(shiftId);
      return ServiceResult.success(_populateShift(response.data));
    } on DioError catch (error) {
      return onApiError<ManageShift>(error);
    } catch (error, stacktrace) {
      return onApiException<ManageShift>(error, stacktrace);
    }
  }

  @override
  Future<ServiceResult<List<ManageShift>>> getShifts() async {
    try {
      var response = await api.getManagedShifts();
      return ServiceResult.success(
          response.data.map((shift) => _populateShift(shift)).toList());
    } on DioError catch (error) {
      return onApiError<List<ManageShift>>(error);
    } catch (error, stacktrace) {
      return onApiException<List<ManageShift>>(error, stacktrace);
    }
  }

  @override
  Future<ServiceResult<ManageShift>> sendNotification(int shiftId) async {
    try {
      var response = await api.sendShiftNotification(shiftId);
      return ServiceResult.success(_populateShift(response.data));
    } on DioError catch (error) {
      return onApiError<ManageShift>(error);
    } catch (error, stacktrace) {
      return onApiException<ManageShift>(error, stacktrace);
    }
  }

  ManageShift _populateShift(ManageShift shift) {
    final managers = companyService.company.allManagers();

    final managerIds =
        shift.managers.where((m) => !m.isPrimaryManager).map((m) => m.id);
    final shiftManagers = managers
        .where((m) => managerIds.contains(m.id))
        .map((m) => Worker.manager(m))
        .toList();

    final primaryManager = shift.managers
        .firstWhere((m) => m.isPrimaryManager, orElse: () => null);

    Worker primaryWorker;

    if (primaryManager != null && managers.isNotEmpty) {
      final mg = managers.firstWhere((m) => m.id == primaryManager.id,
          orElse: () => null);

      if (mg != null) {
        primaryWorker = Worker.manager(
          mg,
          isMyShift: sessionTracker?.session?.value?.userData?.userId == mg.id,
        );
      }
    }

    return shift.copyWith(
      duty: companyService.company?.sortedDuties
          ?.firstWhere((duty) => duty.id == shift.dutyId, orElse: () => null),
      site: companyService.company?.sites?.firstWhere(
        (site) => site.id == shift.siteId,
        orElse: () => Site(name: "Unkonwn", id: 0),
      ),
      otherSites: companyService.company?.sites
              ?.where((s) => shift.otherSiteIds.contains(s.id))
              ?.toList() ??
          [],
      createdBy: primaryWorker,
      managers: shiftManagers,
      skills: companyService.company?.skills
              ?.where((skill) => shift.skillIds.contains(skill.id))
              ?.toList() ??
          [],
    );
  }

  @override
  Future<ServiceResult<int>> getEligibleHeadCount({
    List<int> skillIds = const [],
    List<int> siteIds = const [],
  }) async {
    try {
      var response = await api.getEligibleHeadCount(ShiftHeadCountRequest(
        siteIds: siteIds,
        skillIds: skillIds,
      ));
      return ServiceResult.success(response.data);
    } on DioError catch (error) {
      return onApiError<int>(error);
    } catch (error, stacktrace) {
      return onApiException<int>(error, stacktrace);
    }
  }

  @override
  Future<ServiceResult<ManageShift>> updateWorkerStatus(
      ShiftWorkerUpdateRequest req) async {
    try {
      var response = await api.updateWorkerStatus(req);
      return ServiceResult.success(_populateShift(response.data));
    } on DioError catch (error) {
      return onApiError<ManageShift>(error);
    } catch (error, stacktrace) {
      return onApiException<ManageShift>(error, stacktrace);
    }
  }

  @override
  Future<ServiceResult<ManageShift>> deleteShift(int shiftId) async {
    try {
      var response = await api.deleteShift(shiftId);
      return ServiceResult.success(_populateShift(response.data));
    } on DioError catch (error) {
      return onApiError<ManageShift>(error);
    } catch (error, stacktrace) {
      return onApiException<ManageShift>(error, stacktrace);
    }
  }

  @override
  Future<ServiceResult<ManageShift>> updateShift(PatchShiftRequest req) async {
    try {
      var response = await api.updateShift(req);
      return ServiceResult.success(_populateShift(response.data));
    } on DioError catch (error) {
      return onApiError<ManageShift>(error);
    } catch (error, stacktrace) {
      return onApiException<ManageShift>(error, stacktrace);
    }
  }
}
