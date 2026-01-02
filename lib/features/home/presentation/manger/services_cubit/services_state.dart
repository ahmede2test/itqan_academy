import 'package:itqan_academy/features/home/data/models/services_models.dart';

abstract class ServicesState {}

class ServicesInitial extends ServicesState {}

class ServicesLoading extends ServicesState {}

class ServicesLoaded extends ServicesState {
  final List<AcademyService> services;
  ServicesLoaded(this.services);
}

class ServicesError extends ServicesState {
  final String message;
  ServicesError(this.message);
}

class ServiceOrderSuccess extends ServicesState {
  final String message;
  ServiceOrderSuccess(this.message);
}
