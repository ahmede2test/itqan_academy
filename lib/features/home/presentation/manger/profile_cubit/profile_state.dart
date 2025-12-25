


import '../../../data/model/profile_model.dart';

abstract class ProfileState {}

class ProfileInitial extends ProfileState {}

class ProfileLoading extends ProfileState {}

class ProfileSuccess extends ProfileState {
  final ProfileModel profileModel;
  ProfileSuccess(this.profileModel);
}
class ProfileDeletedSuccess extends ProfileState {}
class ProfileError extends ProfileState {
  final String errMessage;
  ProfileError(this.errMessage);
}
