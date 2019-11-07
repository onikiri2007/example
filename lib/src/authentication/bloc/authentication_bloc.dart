import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:rxdart/rxdart.dart';
import 'package:uni_links/uni_links.dart';
import 'package:yodel/src/bootstrapper.dart';
import 'package:yodel/src/common/models/bloc_base.dart';
import 'package:yodel/src/home/index.dart';
import 'package:yodel/src/authentication/index.dart';
import 'package:yodel/src/services/services.dart';

enum AuthenticationAppLinkType {
  None,
  ResetPassword,
  CreatePassword,
}

const Map<String, AuthenticationAppLinkType> _applinkToType = const {
  "ConfirmInvite": AuthenticationAppLinkType.CreatePassword,
  "ResetPassword": AuthenticationAppLinkType.ResetPassword
};

class _AppLinkOutput {
  final Map<String, dynamic> parameters;
  final AuthenticationAppLinkType appLinkType;

  _AppLinkOutput({
    this.parameters,
    this.appLinkType,
  });
}

class AuthenticationBloc extends Bloc<AuthenticationEvent, AuthenticationState>
    implements BlocBase {
  final SessionService sessionService;
  final UserService userService;
  final CompanyService companyService;
  final SessionTracker sessionTracker;
  @required
  final CompanyBloc companyBloc;
  @required
  final ThemeBloc themeBloc;
  StreamSubscription _sessionSubscription;
  StreamSubscription _applinkSubscription;

  AuthenticationBloc({
    SessionService sessionService,
    UserService userService,
    SessionTracker sessionTracker,
    CompanyService companyService,
    this.companyBloc,
    this.themeBloc,
  })  : assert(companyBloc != null),
        assert(themeBloc != null),
        this.sessionService = sessionService ?? sl<SessionService>(),
        this.userService = userService ?? sl<UserService>(),
        this.companyService = companyService ?? sl<CompanyService>(),
        this.sessionTracker = sessionTracker ?? sl<SessionTracker>() {
    _sessionSubscription = this.sessionTracker.sessionStatus.listen((status) {
      switch (status) {
        case SessionStatus.Expired:
          this.add(Expired());
          break;
        default:
          break;
      }
    });

    _applinkSubscription = getUriLinksStream().listen((Uri uri) async {
      final data = _getSetPasswordAppLinkFromUri(uri);
      if (data.isSuccessful) {
        this.add(
          AppLinkOpen(
            linkType: data.result.appLinkType,
            parameters: data.result.parameters,
          ),
        );
      }
    }, onError: (err) {
      print("app link open => $err");
    });
  }

  @override
  void close() {
    _sessionSubscription?.cancel();
    _applinkSubscription?.cancel();
    super.close();
  }

  @override
  AuthenticationState get initialState => AuthenticationUninitialized();

  @override
  Stream<AuthenticationState> mapEventToState(
    AuthenticationEvent event,
  ) async* {
    if (event is AppStarted) {
      yield* _handleAppStart();
    }

    if (event is LoggedIn) {
      yield* _handleLogin(event);
    }

    if (event is Loggedout || event is Expired) {
      yield* _handleLogout();
    }

    if (event is AppLinkOpen) {
      yield AuthenticationAppLinkOpened(
        linkType: event.linkType,
        parameters: event.parameters,
      );
    }

    if (event is WelcomeUser) {
      yield AuthenticationAuthenticated();
    }

    if (event is SyncSession) {
      yield* _handleSessionSync();
    }
  }

  Stream<AuthenticationState> _handleLogout() async* {
    yield AuthenticationLoading();
    await sessionService.removeSession();
    await companyService.clearCompanyData();
    await userService.logout();
    yield AuthenticationUnauthenticated();
  }

  Stream<AuthenticationState> _handleAppStart() async* {
    final appLinkResult = await _getSetPassworApplink();

    if (appLinkResult.isSuccessful) {
      yield AuthenticationAppLinkOpened(
        linkType: appLinkResult.result.appLinkType,
        parameters: appLinkResult.result.parameters,
      );
    } else {
      yield AuthenticationLoading();
      final hasToken = await sessionService.hasToken();

      if (!hasToken) {
        yield AuthenticationUnauthenticated();
      }

      if (hasToken) {
        final result = await sessionService.loadSession();
        if (result.isSuccessful && result.result != null) {
          final session = await _loadSession(result.result);
          yield* _authenticated(session);
        } else {
          yield AuthenticationUnauthenticated();
        }
      }
    }
  }

  Stream<AuthenticationState> _handleLogin(LoggedIn event) async* {
    yield AuthenticationLoading();
    final session = await _loadSession(event.session);

    if (event.type == AuthenticationAppLinkType.CreatePassword) {
      yield AuthenticationAuthenticatedFromAppLink();
    } else {
      yield* _authenticated(session);
    }
  }

  Stream<AuthenticationState> _authenticated(Session session) async* {
    final isConfirmed = session.userData.isProfileConfirmed ?? false;
    if (isConfirmed) {
      yield AuthenticationAuthenticated();
    } else {
      yield AuthenticationAuthenticatedFromAppLink();
    }
  }

  Stream<AuthenticationState> _handleSessionSync() async* {
    final currentState = state;
    if (currentState is AuthenticationAuthenticated) {
      final session = sessionTracker.currentSession;
      await syncSession(session);
      yield currentState;
    }

    yield currentState;
  }

  ServiceResult<_AppLinkOutput> _getSetPasswordAppLinkFromUri(Uri uri) {
    if (uri != null && uri.pathSegments.length > 0) {
      final segment = uri.pathSegments.last;

      if (segment == "EmailRedirect") {
        return _parseAppLinkFromRedirect(uri);
      } else {
        return _parseAppLinkOutput(uri);
      }
    }

    return ServiceResult<_AppLinkOutput>.failure();
  }

  ServiceResult<_AppLinkOutput> _parseAppLinkFromRedirect(Uri uri) {
    final queries = uri.queryParameters;
    final url = queries["Url"];
    if (url != null && url.isNotEmpty) {
      final uri1 = Uri.tryParse(url);
      if (uri1 != null) {
        return _parseAppLinkOutput(uri1);
      }
    }

    return ServiceResult<_AppLinkOutput>.failure();
  }

  ServiceResult<_AppLinkOutput> _parseAppLinkOutput(Uri uri) {
    AuthenticationAppLinkType actionLinkType;

    actionLinkType = _applinkToType[uri.pathSegments.last];
    if (actionLinkType != null) {
      return ServiceResult<_AppLinkOutput>.success(_AppLinkOutput(
          parameters: uri.queryParameters, appLinkType: actionLinkType));
    }

    return ServiceResult<_AppLinkOutput>.failure();
  }

  Future<ServiceResult<_AppLinkOutput>> _getSetPassworApplink() async {
    try {
      Uri initialUri = await getInitialUri();
      return _getSetPasswordAppLinkFromUri(initialUri);
    } catch (ex) {
      return ServiceResult<_AppLinkOutput>.failure(ex: ex);
    }
  }

  Future<Session> _refreshSession(Session session) async {
    final result = await userService.getCurrentUserProfile();

    if (result.isSuccessful) {
      return session.copyWith(
        userData: result.result.copyWith(
          userId: session.userData.userId,
          userKey: session.userKey,
        ),
      );
    }

    return session;
  }

  Future<Session> syncSession(Session currentSession) async {
    final session = await _refreshSession(currentSession);
    final newSession = await _fillSitesAndSkills(session);

    if (newSession != null) {
      await sessionService.saveSession(newSession);
      sessionTracker.sessionLoaded(newSession);
    }

    return newSession;
  }

  Future<Session> _loadSession(Session currentSession) async {
    sessionTracker.sessionLoaded(currentSession);
    final session = await _refreshSession(currentSession);
    final newSession = await _fillSitesAndSkills(session);

    if (newSession != null) {
      await sessionService.saveSession(newSession);
      sessionTracker.sessionLoaded(newSession);
    }

    themeBloc.add(ChangeTheme(user: newSession.userData));
    companyBloc.add(Fetch());

    return newSession;
  }

  @override
  Stream<AuthenticationState> transformEvents(
    Stream<AuthenticationEvent> events,
    Stream<AuthenticationState> Function(AuthenticationEvent event) next,
  ) {
    final eventsObservable = events as Observable<AuthenticationEvent>;
    final filteredEvents = eventsObservable
        .where((e) => e is Expired)
        .distinct()
        .debounceTime(Duration(milliseconds: 250));
    final nonFiltered = eventsObservable.where((e) => e is! Expired);
    final finalEvents = filteredEvents.mergeWith([nonFiltered]);
    return super.transformEvents(
      finalEvents,
      next,
    );
  }

  Future<Session> _fillSitesAndSkills(Session session) async {
    if (session != null && session.userData != null) {
      final r = await companyBloc.companyService.loadCompanyData();
      if (r.isSuccessful) {
        final sites = r.result.sites
            .where((s) => session.userData.siteIds.contains(s.id))
            .toList();
        final skills = r.result.skills
            .where((s) => session.userData.skillIds.contains(s.id))
            .toList();

        return session.copyWith(
          userData: session.userData.copyWith(
            skills: skills,
            sites: sites,
          ),
        );
      }
    }
    return session;
  }

  @override
  void dispose() {
    this.close();
  }
}
