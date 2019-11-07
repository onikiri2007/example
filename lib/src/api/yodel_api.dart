import 'package:dio/dio.dart';
import 'package:yodel/src/api/index.dart';

abstract class YodelApi {
  Future<Response<Company>> getCurrentCompany({CancelToken cancelToken});
  Future<Response<List<ManageShift>>> getManagedShifts({
    CancelToken cancelToken,
  });
  Future<Response<ManageShift>> getManagedShift(int id,
      {CancelToken cancelToken});
  Future<Response<ManageShift>> createShift(CreateShiftRequest request,
      {CancelToken cancelToken});
  Future<Response<ManageShift>> sendShiftNotification(int id,
      {CancelToken cancelToken});

  Future<Response<ManageShift>> updateWorkerStatus(ShiftWorkerUpdateRequest req,
      {CancelToken cancelToken});

  Future<Response<int>> getEligibleHeadCount(ShiftHeadCountRequest req,
      {CancelToken cancelToken});

  Future<Response<ManageShift>> deleteShift(int id, {CancelToken cancelToken});

  Future<Response<ManageShift>> updateShift(PatchShiftRequest req,
      {CancelToken cancelToken});

  Future<Response<MyShift>> updateMyShiftStatus(ShiftWorkerUpdateRequest req,
      {CancelToken cancelToken});

  Future<Response<List<MyShift>>> getMyShifts({
    CancelToken cancelToken,
  });
  Future<Response<MyShift>> getMyShift(int id, {CancelToken cancelToken});
  Future<Response<List<YodelNotification>>> getNotifications(
      {CancelToken cancelToken});
  Future<Response<YodelNotification>> patchNotification(
      NotificationPatchRequest req,
      {CancelToken cancelToken});
}

class YodelApiImpl with ResponseMixin implements YodelApi {
  final Dio httpClient;

  YodelApiImpl(this.httpClient) : assert(httpClient != null);

  @override
  Future<Response<Company>> getCurrentCompany({CancelToken cancelToken}) async {
    var res =
        await httpClient.get("/companies/current", cancelToken: cancelToken);
    return createResponse<Company>(Company.fromJson(res.data), res);
  }

  @override
  Future<Response<ManageShift>> createShift(CreateShiftRequest request,
      {CancelToken cancelToken}) async {
    var res = await httpClient.post("/manageshifts",
        data: removeNulls(request.toJson()), cancelToken: cancelToken);
    return createResponse<ManageShift>(ManageShift.fromJson(res.data), res);
  }

  @override
  Future<Response<ManageShift>> getManagedShift(int id,
      {CancelToken cancelToken}) async {
    assert(id != null);
    var res =
        await httpClient.get("/manageshifts/$id", cancelToken: cancelToken);
    return createResponse<ManageShift>(ManageShift.fromJson(res.data), res);
  }

  @override
  Future<Response<List<ManageShift>>> getManagedShifts(
      {CancelToken cancelToken}) async {
    var res = await httpClient.get("/manageshifts", cancelToken: cancelToken);

    List<dynamic> data = res.data ?? [];
    final List<ManageShift> shifts = data.isNotEmpty
        ? data.map((s) => ManageShift.fromJson(s)).toList()
        : [];

    return createResponse<List<ManageShift>>(shifts, res);
  }

  @override
  Future<Response<ManageShift>> sendShiftNotification(int id,
      {CancelToken cancelToken}) async {
    assert(id != null);
    var res = await httpClient.post("/manageshifts/$id/notifications",
        cancelToken: cancelToken);
    return createResponse<ManageShift>(ManageShift.fromJson(res.data), res);
  }

  @override
  Future<Response<ManageShift>> updateWorkerStatus(ShiftWorkerUpdateRequest req,
      {CancelToken cancelToken}) async {
    var res = await httpClient.patch(
        "/manageshifts/${req.shiftId}/workers/${req.workerId}",
        data: req.toJson(),
        cancelToken: cancelToken);
    return createResponse<ManageShift>(ManageShift.fromJson(res.data), res);
  }

  @override
  Future<Response<int>> getEligibleHeadCount(ShiftHeadCountRequest req,
      {CancelToken cancelToken}) {
    return httpClient.post<int>("/manageshifts/headcount",
        data: req.toJson(), cancelToken: cancelToken);
  }

  @override
  Future<Response<ManageShift>> deleteShift(int id,
      {CancelToken cancelToken}) async {
    assert(id != null);
    var res =
        await httpClient.delete("/manageshifts/$id", cancelToken: cancelToken);
    return createResponse<ManageShift>(ManageShift.fromJson(res.data), res);
  }

  @override
  Future<Response<ManageShift>> updateShift(PatchShiftRequest req,
      {CancelToken cancelToken}) async {
    var res = await httpClient.patch("/manageshifts/${req.id}",
        data: req.toJson(), cancelToken: cancelToken);
    return createResponse<ManageShift>(ManageShift.fromJson(res.data), res);
  }

  @override
  Future<Response<MyShift>> getMyShift(int id,
      {CancelToken cancelToken}) async {
    assert(id != null);
    var res = await httpClient.get("/myshifts/$id", cancelToken: cancelToken);
    return createResponse<MyShift>(MyShift.fromJson(res.data), res);
  }

  @override
  Future<Response<List<MyShift>>> getMyShifts({CancelToken cancelToken}) async {
    var res = await httpClient.get("/myshifts", cancelToken: cancelToken);

    List<dynamic> data = res.data ?? [];
    final List<MyShift> shifts =
        data.isNotEmpty ? data.map((s) => MyShift.fromJson(s)).toList() : [];

    return createResponse<List<MyShift>>(shifts, res);
  }

  @override
  Future<Response<MyShift>> updateMyShiftStatus(ShiftWorkerUpdateRequest req,
      {CancelToken cancelToken}) async {
    var res = await httpClient.patch("/myshifts/${req.shiftId}",
        data: req.toJson(), cancelToken: cancelToken);
    return createResponse<MyShift>(MyShift.fromJson(res.data), res);
  }

  @override
  Future<Response<List<YodelNotification>>> getNotifications(
      {CancelToken cancelToken}) async {
    var res = await httpClient.get("/notifications", cancelToken: cancelToken);
    List<dynamic> data = res.data ?? [];
    final List<YodelNotification> notifications = data.isNotEmpty
        ? data.map((s) => YodelNotification.fromJson(s)).toList()
        : [];

    return createResponse<List<YodelNotification>>(notifications, res);
  }

  @override
  Future<Response<YodelNotification>> patchNotification(
      NotificationPatchRequest req,
      {CancelToken cancelToken}) async {
    var res = await httpClient.patch("/notifications/${req.id}",
        data: req.toJson(), cancelToken: cancelToken);
    return createResponse<YodelNotification>(
        YodelNotification.fromJson(res.data), res);
  }
}
