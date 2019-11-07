import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:yodel/src/api/index.dart';
import 'package:yodel/src/bootstrapper.dart';
import 'package:yodel/src/services/services.dart';
import './bloc.dart';

class ContactBloc extends Bloc<ContactEvent, ContactState> {
  final UserService _userService;
  final CompanyService _companyService;

  ContactBloc({
    UserService userService,
    CompanyService companyService,
  })  : this._userService = userService ?? sl<UserService>(),
        this._companyService = companyService ?? sl<CompanyService>();

  @override
  ContactState get initialState => InitialContactState();

  @override
  Stream<ContactState> mapEventToState(
    ContactEvent event,
  ) async* {
    if (event is FetchContactDetails) {
      yield ContactLoading();
      final r = await _userService.getContact(event.id);

      if (r.isSuccessful) {
        final user = _fillSitesAndSkills(r.result);
        yield ContactLoaded(
          user,
        );
      } else {
        yield ContactError(
          r.error,
          exception: r.getException(),
        );
      }
    }
  }

  UserData _fillSitesAndSkills(UserData user) {
    final company = _companyService.company;
    final sites =
        company.sites.where((s) => user.siteIds.contains(s.id)).toList();
    final skills =
        company.skills.where((s) => user.skillIds.contains(s.id)).toList();

    return user.copyWith(
      skills: skills,
      sites: sites,
    );
  }
}
