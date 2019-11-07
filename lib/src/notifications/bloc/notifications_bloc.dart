import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:rxdart/rxdart.dart';
import 'package:yodel/src/api/index.dart';
import 'package:yodel/src/bootstrapper.dart';
import 'package:yodel/src/common/models/models.dart';
import 'package:yodel/src/services/services.dart';
import './bloc.dart';

enum NotificationType {
  Manage,
  MyShift,
}

class NotificationsBloc extends Bloc<NotificationsEvent, NotificationsState> {
  NotificationsBloc({
    NotificationService notificationService,
    NotificationType defaultFilter = NotificationType.Manage,
    CompanyService companyService,
  })  : this._notificationService =
            notificationService ?? sl<NotificationService>(),
        this._companyService = companyService ?? sl<CompanyService>(),
        this._notificationFilterSubject =
            BehaviorSubject.seeded(defaultFilter) {
    _subscription = listen((state) {
      if (state is NotificationsLoaded) {
        _notificationsSubject.add(state.notifications);
      }
    });
  }

  final BehaviorSubject<List<YodelNotification>> _notificationsSubject =
      BehaviorSubject.seeded([]);

  final BehaviorSubject<NotificationType> _notificationFilterSubject;

  final NotificationService _notificationService;
  final CompanyService _companyService;

  StreamSubscription _subscription;

  @override
  NotificationsState get initialState => InitialNotificationsState();

  @override
  Stream<NotificationsState> mapEventToState(
    NotificationsEvent event,
  ) async* {
    if (event is FetchNotifications) {
      yield NotificationsLoading();
      final r = await _notificationService.getNotifications();
      if (r.isSuccessful) {
        final notifications = await _populateSites(r.result);
        yield NotificationsLoaded(
          notifications ?? [],
        );
      } else {
        yield NotificationsError(
          r.error,
          exception: r.getException(),
        );
      }
    }

    if (event is NotificationViewed) {
      final r = await _notificationService.markAsViewed(event.id);
      if (r.isSuccessful) {
        List<YodelNotification> notifications =
            List.from(_notificationsSubject.value);
        final changed =
            notifications.firstWhere((n) => n == r.result, orElse: () => null);
        final index = notifications.indexOf(changed);
        final newNotification = r.result.copyWith(
          site: changed?.site,
        );
        notifications[index] = newNotification;
        yield NotificationsLoaded(
          notifications ?? [],
        );
      } else {
        yield NotificationsError(
          r.error,
          exception: r.getException(),
        );
      }
    }
  }

  Stream<Map<DateTime, List<YodelNotification>>> get notifications =>
      Observable.combineLatest2(
          _notificationsSubject.stream, _notificationFilterSubject.stream,
          (List<YodelNotification> notifications, NotificationType type) {
        Map<DateTime, List<YodelNotification>> map = {};

        List<YodelNotification> filtered;

        if (type == NotificationType.Manage) {
          filtered =
              notifications.where((n) => !n.isWorkerNotification).toList();
        } else {
          filtered =
              notifications.where((n) => n.isWorkerNotification).toList();
        }

        filtered.forEach((n) {
          final date = DateTimeHelper.toDateOnly(n.createdOn);
          map.update(
              date,
              (notifications) => notifications
                ..add(n)
                ..sort((d1, d2) => d1.createdOn.compareTo(d2.createdOn)),
              ifAbsent: () => [n]);
        });

        return map;
      });

  @override
  void close() {
    _notificationsSubject.close();
    _notificationFilterSubject?.close();
    _subscription?.cancel();
    super.close();
  }

  Stream<NotificationType> get filter => _notificationFilterSubject.stream;
  void Function(NotificationType) get changeFilter =>
      _notificationFilterSubject.add;

  NotificationType get currentFilter => _notificationFilterSubject.value;

  _populateSites(List<YodelNotification> notifications) async {
    if (_companyService.company == null) {
      await _companyService.loadCompanyData();
    }

    final company = _companyService.company;
    final sites = company.sites;

    return notifications.map((n) {
      var site = Site(
        imagePath: company.logoPath,
      );

      if (n.siteId != null) {
        var newSite =
            sites.firstWhere((s) => s.id == n.siteId, orElse: () => site);

        if (newSite.imagePath == null) {
          newSite = newSite.copyWith(
            imagePath: company.logoPath,
          );
        }

        return n.copyWith(
          site: newSite,
        );
      }

      return n.copyWith(
        site: site,
      );
    }).toList();
  }
}
