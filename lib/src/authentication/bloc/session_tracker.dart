import 'package:rxdart/rxdart.dart';
import 'package:yodel/src/authentication/index.dart';

enum SessionStatus {
  Uninitialized,
  UnAuthenticated,
  Authenticated,
  Expired,
  LoggedOut
}

class SessionTracker {
  final BehaviorSubject<Session> _sessionController =
      BehaviorSubject<Session>();
  final BehaviorSubject<SessionStatus> _sessionStatusController =
      BehaviorSubject<SessionStatus>();

  ValueObservable<Session> get session => _sessionController.stream;
  ValueObservable<SessionStatus> get sessionStatus =>
      _sessionStatusController.stream;
  void sessionLoaded(Session session) {
    _sessionController.add(session);
    _sessionStatusController.add(SessionStatus.Authenticated);
  }

  void sessionEnded(SessionStatus status) {
    _sessionController.add(null);
    _sessionStatusController.add(status);
  }

  bool get isAuthenticated =>
      this.session.value != null && this.session.value?.userKey != null;

  Session get currentSession => _sessionController.value;

  void dispose() {
    _sessionController?.close();
    _sessionStatusController?.close();
  }
}
