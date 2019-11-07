import 'dart:async';
import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:flutter_statusbarcolor/flutter_statusbarcolor.dart';
import 'package:raygun/raygun.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:yodel/src/api/index.dart';
import 'package:yodel/src/config.dart';
import 'package:yodel/src/app.dart';
import 'package:yodel/src/authentication/index.dart';
import 'package:yodel/src/services/services.dart';

import 'common/widgets/index.dart';

final GetIt sl = GetIt.instance;
final FlutterSecureStorage secureStorage = FlutterSecureStorage();

void registerDependencies() {
  registerServices();
}

void registerServices() {
  BlocSupervisor.delegate = FlutterBlocDelegate();

  final options = BaseOptions(
      baseUrl: "${Config.baseUrl}/api/v1",
      connectTimeout: 3000,
      receiveTimeout: 5000,
      headers: {
        "Accept": "*/*",
        "ApiKey": Config.apiKey,
      });

  final dio = Dio(options);

  //**** enable proxy using charles ****/
  // final bool isProxyChecked = true; // a variable for debug
  // final proxy = '192.168.1.9:8888'; // ip:port
  // (dio.httpClientAdapter as DefaultHttpClientAdapter).onHttpClientCreate =
  //     (client) {
  //   client.badCertificateCallback =
  //       (X509Certificate cert, String host, int port) {
  //     return isProxyChecked;
  //   };
  //   client.findProxy = (url) {
  //     return isProxyChecked ? 'PROXY $proxy' : 'DIRECT';
  //   };
  // };

  dio.transformer = FlutterTransformer();
  dio.interceptors.add(
    InterceptorsWrapper(
      onRequest: (options) async {
        final sessionService = sl<SessionService>();
        String token = await sessionService.getToken();
        options.headers.putIfAbsent("UserKey", () => token);
        return options;
      },
      onError: (error) {
        debugPrint("$error");
        if (error.response != null) {
          final response = error.response;
          final tracker = sl<SessionTracker>();
          final token = tracker.currentSession?.userKey ?? "";
          final hasToken = token != null && token.isNotEmpty;
          if (response.statusCode == 401 && hasToken) {
            tracker.sessionEnded(SessionStatus.Expired);
          } else {
            if (hasErrorInfo(error)) {
              try {
                var info = getErrorInfoFromError(error);
                debugPrint(info.errorMessages);
                FlutterRaygun().logException(
                    ServiceException(info.errorMessages), error.stackTrace);
                return DioError(
                  error: info,
                  message: error.message,
                  request: error.request,
                  response: error.response,
                  stackTrace: error.stackTrace,
                  type: error.type,
                );
              } catch (ex, stacktrace) {
                FlutterRaygun().logException(ex, stacktrace);
              }
            }
          }
        } else {
          FlutterRaygun()
              .logException(ServiceException(error.message), error.stackTrace);
        }
        return error;
      },
    ),
  );

  sl.registerFactory<Future<SharedPreferences>>(
      () => SharedPreferences.getInstance());

  sl.registerFactory<FlutterSecureStorage>(() => secureStorage);

  sl.registerLazySingleton<UserApi>(() => UserApiImpl(dio));
  sl.registerLazySingleton<YodelApi>(() => YodelApiImpl(dio));
  sl.registerLazySingleton<AppService>(() => AppServiceImpl());

  sl.registerLazySingleton<UserService>(() => UserServiceImpl());

  sl.registerLazySingleton<SessionService>(() => SessionServiceImpl());

  sl.registerLazySingleton(() => SessionTracker());

  sl.registerLazySingleton<CompanyService>(() => CompanyServiceImpl());

  sl.registerLazySingleton<ManageShiftService>(() => ManageShiftServiceImpl());
  sl.registerLazySingleton<MyShiftService>(() => MyShiftServiceImpl());
  sl.registerLazySingleton<NotificationService>(
      () => NotificationServiceImpl());

  sl.registerFactory<PushNotificationService>(
      () => PushNotificationServiceImpl());
}

Future<void> initializeApp() async {
  await sl.get<AppService>().initialize();
}

void setupStatusBarColour({Color color = Colors.lightBlue}) async {
  await FlutterStatusbarcolor.setStatusBarColor(color);
  await FlutterStatusbarcolor.setStatusBarWhiteForeground(true);
}

Future<void> setupRaygun(
  String apiKey, {
  bool enableLogging = false,
}) async {
  FlutterError.onError = (FlutterErrorDetails details) {
    if (!kReleaseMode) {
      // In development mode simply print to console.
      FlutterError.dumpErrorToConsole(details);
    } else {
      // In production mode report to the application zone to report to
      // Raygun.
      Zone.current.handleUncaughtError(details.exception, details.stack);
    }
  };

  if (enableLogging) {
    await FlutterRaygun().initialize(apiKey);
  }
}

void run() {
  runZoned<Future<void>>(() async {
    await setupRaygun(Config.raygunApiKey, enableLogging: true);
    registerDependencies();
    await initializeApp();
    setupErrorWidget(
      customTitle: "Oops, Something went wrong!",
      customDescription:
          "There was unexpected situation in application. Application could not recover from error. Please try again later.",
    );
    runApp(App());
  }, onError: (error, stackTrace) async {
    // Whenever an error occurs, call the `reportCrash` function. This will send
    // Dart errors to our dev console or Raygun depending on the environment.
    debugPrint(error?.toString());
    debugPrint(stackTrace?.toString());
    await FlutterRaygun().logException(error, stackTrace);
  });
}

void setupErrorWidget(
    {bool showStacktrace = false,
    String customTitle,
    String customDescription}) {
  if (Config.appFlavour == Flavour.Production ||
      Config.appFlavour == Flavour.Staging) {
    addDefaultErrorWidget(
      showStacktrace: showStacktrace,
      customTitle: customTitle,
      customDescription: customDescription,
    );
  }
}

void addDefaultErrorWidget(
    {bool showStacktrace, String customTitle, String customDescription}) {
  ErrorWidget.builder = (FlutterErrorDetails details) {
    return YodelErrorWidget(
      details: details,
      showStacktrace: showStacktrace,
      customTitle: customTitle,
      customDescription: customDescription,
    );
  };
}
