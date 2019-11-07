import 'package:yodel/src/api/index.dart';
import 'package:yodel/src/authentication/index.dart';
import 'package:yodel/src/bootstrapper.dart';
import 'package:yodel/src/services/services.dart';
import 'package:dio/dio.dart';

abstract class MyShiftService {
  Future<ServiceResult<List<MyShift>>> getShifts();

  Future<ServiceResult<MyShift>> getShift(int shiftId);
  Future<ServiceResult<MyShift>> updateStatus(ShiftWorkerUpdateRequest req);
}

class MyShiftServiceImpl with ServiceMixin implements MyShiftService {
  final YodelApi api;
  final CompanyService companyService;
  final SessionTracker sessionTracker;

  MyShiftServiceImpl(
      {YodelApi api,
      CompanyService companyService,
      SessionTracker sessionTracker})
      : this.api = api ?? sl<YodelApi>(),
        this.companyService = companyService ?? sl<CompanyService>(),
        this.sessionTracker = sessionTracker ?? sl<SessionTracker>();

  @override
  Future<ServiceResult<MyShift>> getShift(int shiftId) async {
    try {
      var response = await api.getMyShift(shiftId);
      return ServiceResult.success(_populateShift(response.data));
    } on DioError catch (error) {
      return onApiError<MyShift>(error);
    } catch (error, stacktrace) {
      return onApiException<MyShift>(error, stacktrace);
    }
  }

  @override
  Future<ServiceResult<List<MyShift>>> getShifts() async {
    try {
      var response = await api.getMyShifts();
      return ServiceResult.success(
          response.data.map((shift) => _populateShift(shift)).toList());
    } on DioError catch (error) {
      return onApiError<List<MyShift>>(error);
    } catch (error, stacktrace) {
      return onApiException<List<MyShift>>(error, stacktrace);
    }
  }

  @override
  Future<ServiceResult<MyShift>> updateStatus(
      ShiftWorkerUpdateRequest req) async {
    try {
      var response = await api.updateMyShiftStatus(req);
      return ServiceResult.success(_populateShift(response.data));
    } on DioError catch (error) {
      return onApiError<MyShift>(error);
    } catch (error, stacktrace) {
      return onApiException<MyShift>(error, stacktrace);
    }
  }

  MyShift _populateShift(MyShift shift) {
    final managers = companyService.company.allManagers();

    Worker manager;

    if (managers.isNotEmpty) {
      final mg = managers.firstWhere((mg) => mg.id == shift.managerId,
          orElse: () => null);

      if (mg != null) {
        manager = Worker.manager(
          mg,
          isMyShift: sessionTracker?.session?.value?.userData?.userId == mg.id,
        );
      }
    }

    return shift.copyWith(
      site: companyService.company?.sites?.firstWhere(
        (site) => site.id == shift.siteId,
        orElse: () => Site(name: "Unkonwn", id: 0),
      ),
      manager: manager,
      worker: Worker(
        id: sessionTracker?.session?.value?.userData?.userId,
        imagePath: sessionTracker?.session?.value?.userData?.profilePhoto,
        name: sessionTracker?.session?.value?.userData?.fullName,
        statusRaw: shift.myStatusRaw,
      ),
      skills: companyService.company?.skills
              ?.where((skill) => shift.skillIds?.contains(skill.id) ?? false)
              ?.toList() ??
          [],
    );
  }
}
