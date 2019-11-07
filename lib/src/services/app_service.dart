import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:raygun/raygun.dart';
import 'package:uuid/uuid.dart';
import 'package:yodel/src/bootstrapper.dart';

const String kDeviceId = "DeviceId";
const String kYodelNavigationChannel = "co.yodel.app/navigation";

abstract class AppService {
  Future<void> initialize();
  Future<String> getDeviceId();
  Future<void> minimise();
}

class AppServiceImpl implements AppService {
  final FlutterSecureStorage storage;
  static const channel = const MethodChannel(kYodelNavigationChannel);

  AppServiceImpl({
    FlutterSecureStorage storage,
  }) : this.storage = storage ?? sl<FlutterSecureStorage>();
  @override
  Future<String> getDeviceId() async {
    return storage.read(key: kDeviceId);
  }

  @override
  Future<void> initialize() async {
    final String deviceId = await getDeviceId();

    if (deviceId == null) {
      final id = Uuid().v4();
      await storage.write(key: kDeviceId, value: id);
    }
  }

  @override
  Future<void> minimise() async {
    try {
      await channel.invokeMethod("minimise");
    } on PlatformException catch (e, s) {
      FlutterRaygun().logException(e, s);
    }
  }
}
