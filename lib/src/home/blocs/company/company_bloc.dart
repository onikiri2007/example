import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:rxdart/rxdart.dart';
import 'package:yodel/src/api/index.dart';
import 'package:yodel/src/bootstrapper.dart';
import 'package:yodel/src/services/services.dart';
import './bloc.dart';

class CompanyBloc extends Bloc<CompanyEvent, CompanyState> {
  final CompanyService companyService;
  final BehaviorSubject<Site> _siteSubject = BehaviorSubject();

  CompanyBloc({
    CompanyService companyService,
  }) : this.companyService = companyService ?? sl<CompanyService>();

  @override
  CompanyState get initialState => InitialCompanyState();

  @override
  void close() {
    _siteSubject.close();
    super.close();
  }

  @override
  Stream<CompanyState> mapEventToState(
    CompanyEvent event,
  ) async* {
    if (event is Fetch) {
      yield CompanyLoading();
      var r = await companyService.loadCompanyData();
      if (r.isSuccessful) {
        yield CompanyLoaded(data: r.result);
      } else {
        yield CompanyError(r.error, exception: r.getException());
      }
    }

    if (event is SyncCompany) {
      var r = await companyService.loadCompanyData();
      if (r.isSuccessful) {
        yield CompanyLoaded(data: r.result);
      }
    }
  }

  Company get company {
    final currentState = state;
    return currentState is CompanyLoaded ? currentState.data : Company.empty();
  }
}
