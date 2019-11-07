import 'dart:async';
import 'dart:io';
import 'package:bloc/bloc.dart';
import 'package:yodel/src/api/index.dart';
import 'package:yodel/src/authentication/index.dart';
import 'package:yodel/src/bootstrapper.dart';
import 'package:yodel/src/services/services.dart';
import './bloc.dart';

class PushNotificationBloc
    extends Bloc<PushNotificationEvent, PushNotificationState> {
  PushNotificationBloc({
    this.authBloc,
    PushNotificationService pushNotificationService,
    UserService userService,
    AppService appService,
    ManageShiftService manageShiftService,
    MyShiftService myShiftService,
    NotificationService notificationService,
  })  : assert(authBloc != null),
        this._pushNotificationService =
            pushNotificationService ?? sl<PushNotificationService>(),
        this._userService = userService ?? sl<UserService>(),
        this._appService = appService ?? sl<AppService>(),
        this._manageShiftService =
            manageShiftService ?? sl<ManageShiftService>(),
        this._myShiftService = myShiftService ?? sl<MyShiftService>(),
        this._notificationService =
            notificationService ?? sl<NotificationService>() {
    _tokenSubscription =
        _pushNotificationService.onTokenRefresh.listen((token) async {
      final oldToken = await _userService.getPushToken();
      final hasPushtokenRegistered =
          authBloc?.sessionTracker?.currentSession?.userData?.hasPushToken ??
              false;
      var hasPushToken =
          oldToken != null && oldToken.isNotEmpty && oldToken == token;

      if (!hasPushtokenRegistered) {
        await _userService.removePushToken();
        hasPushToken = false;
      }
      if (!hasPushToken) {
        add(RegisterPushToken(token));
      }
    });

    _notificationSubscription =
        _pushNotificationService.onMessageReceived.listen((message) async {
      print("message recieved : ${message.id}");

      if (message.notificationId != null) {
        await _notificationService.markAsViewed(message.notificationId);
      }

      if (message.id != null) {
        if (message.isMyShift) {
          final r = await _myShiftService.getShift(message.id);

          if (r.isSuccessful) {
            add(
              ShiftMessageRecieved(
                r.result,
              ),
            );
          }
        } else {
          final r = await _manageShiftService.getShift(message.id);

          if (r.isSuccessful) {
            add(
              ShiftMessageRecieved(
                r.result,
              ),
            );
          }
        }
      }
    });
  }

  final PushNotificationService _pushNotificationService;
  final UserService _userService;
  final AppService _appService;
  final ManageShiftService _manageShiftService;
  final MyShiftService _myShiftService;
  final NotificationService _notificationService;
  final AuthenticationBloc authBloc;

  StreamSubscription _tokenSubscription;
  StreamSubscription _notificationSubscription;

  @override
  PushNotificationState get initialState => InitialPushNotificationState();

  @override
  Stream<PushNotificationState> mapEventToState(
    PushNotificationEvent event,
  ) async* {
    if (event is InitializeNotification) {
      await _pushNotificationService.requestNotificationPermission();
      yield InitialPushNotificationState();
    }

    if (event is RegisterPushToken) {
      yield PushNotificationLoading();
      final deviceId = await _appService.getDeviceId();

      print("DeviceId $deviceId");

      final result = await _userService.registerPushToken(PushTokenInfo(
        deviceId: deviceId,
        token: event.token,
        provider:
            Platform.isIOS ? PushTokenProvider.Apple : PushTokenProvider.Google,
      ));

      if (result.isSuccessful) {
        authBloc.add(SyncSession());
      }

      yield PushNotificationInitialized();
    }

    if (event is ShiftMessageRecieved) {
      yield PushNotificationShiftMessageRecieved(event.shift,
          myShift: event.shift is MyShift);
    }
  }

  @override
  void close() {
    _tokenSubscription?.cancel();
    _notificationSubscription?.cancel();
    _pushNotificationService?.dispose();
    super.close();
  }
}
