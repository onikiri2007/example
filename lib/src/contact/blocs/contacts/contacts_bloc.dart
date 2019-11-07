import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:rxdart/rxdart.dart';
import 'package:yodel/src/api/index.dart';
import 'package:yodel/src/authentication/index.dart';
import 'package:yodel/src/bootstrapper.dart';
import 'package:yodel/src/services/services.dart';
import './bloc.dart';

class ContactsBloc extends Bloc<ContactsEvent, ContactsState> {
  ContactsBloc({
    UserService userService,
    SessionTracker sessionTracker,
  }) : this._userService = userService ?? sl<UserService>() {
    _stateSubscription = this.listen((state) {
      if (state is ContactsSuccess) {
        _contactsSubject.add(state.contacts);
      }
    });
  }

  @override
  ContactsState get initialState => InitialContactsState();

  final BehaviorSubject<List<Contact>> _contactsSubject =
      BehaviorSubject.seeded([]);
  final BehaviorSubject<int> _siteFilterSubject = BehaviorSubject.seeded(0);
  final BehaviorSubject<String> _querySubject = BehaviorSubject.seeded("");
  final UserService _userService;

  StreamSubscription _stateSubscription;

  @override
  void close() {
    _contactsSubject?.close();
    _siteFilterSubject?.close();
    _stateSubscription?.cancel();
    _querySubject?.close();
    super.close();
  }

  @override
  Stream<ContactsState> mapEventToState(
    ContactsEvent event,
  ) async* {
    if (event is FetchContacts) {
      yield ContactsLoading();
      final r = await _userService.getContacts();
      if (r.isSuccessful) {
        yield ContactsSuccess(
          contacts: r.result.toList() ?? [],
        );
      } else {
        yield ContactsError(
          r.error,
          exception: r.getException(),
        );
      }
    }
  }

  Stream<int> get siteFilter => _siteFilterSubject.stream;
  void Function(int) get onFilterChanged => _siteFilterSubject.add;
  int get currentFilter => _siteFilterSubject.value;

  void Function(String) get onQueryChanaged => _querySubject.add;

  Stream<List<Contact>> get contacts => Observable.combineLatest3(
          _contactsSubject.stream,
          _siteFilterSubject.stream,
          _querySubject.stream.distinct().debounceTime(
                const Duration(milliseconds: 250),
              ), (
        List<Contact> users,
        int filter,
        String query,
      ) {
        List<Contact> filteredUsers = List.from(users);

        if (query != null && query.isNotEmpty) {
          filteredUsers = filteredUsers
              .where(
                  (s) => s.fullName.toLowerCase().contains(query.toLowerCase()))
              .toList();
        }

        if (filter == 0) return filteredUsers;
        return filteredUsers.where((u) => u.siteIds.contains(filter)).toList();
      }).asBroadcastStream();
}
