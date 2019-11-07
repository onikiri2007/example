import 'package:yodel/src/api/index.dart';
import 'package:yodel/src/bootstrapper.dart';
import 'package:yodel/src/services/services.dart';
import 'package:dio/dio.dart';

abstract class NotificationService {
  Future<ServiceResult<List<YodelNotification>>> getNotifications();
  Future<ServiceResult<YodelNotification>> markAsViewed(int id);
}

class NotificationServiceImpl with ServiceMixin implements NotificationService {
  final YodelApi api;

  NotificationServiceImpl({YodelApi api}) : this.api = api ?? sl<YodelApi>();

  @override
  Future<ServiceResult<List<YodelNotification>>> getNotifications() async {
    try {
      var response = await api.getNotifications();
      return ServiceResult.success(response.data);
    } on DioError catch (error) {
      return onApiError<List<YodelNotification>>(error);
    } catch (error, stacktrace) {
      return onApiException<List<YodelNotification>>(error, stacktrace);
    }
  }

  @override
  Future<ServiceResult<YodelNotification>> markAsViewed(int id) async {
    try {
      var response = await api
          .patchNotification(NotificationPatchRequest(id, isViewed: true));
      return ServiceResult.success(response.data);
    } on DioError catch (error) {
      return onApiError<YodelNotification>(error);
    } catch (error, stacktrace) {
      return onApiException<YodelNotification>(error, stacktrace);
    }
  }
}
