import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';
import 'package:yodel/src/api/index.dart';

@immutable
abstract class CompanyState extends Equatable {}

class InitialCompanyState extends CompanyState {
  @override
  // TODO: implement props
  List<Object> get props => [];
}

class CompanyLoading extends CompanyState {
  @override
  String toString() => 'CompanyLoading';

  @override
  // TODO: implement props
  List<Object> get props => [];
}

class CompanyError extends CompanyState {
  final Exception exception;
  final String error;

  CompanyError(
    this.error, {
    this.exception,
  });

  @override
  String toString() =>
      'Company => error: error, exception: ${exception.toString()}';

  @override
  // TODO: implement props
  List<Object> get props => [error];
}

class CompanyLoaded extends CompanyState {
  final Company data;

  CompanyLoaded({
    this.data,
  });

  @override
  String toString() => 'CompanyLoaded';

  @override
  // TODO: implement props
  List<Object> get props => [data];
}
