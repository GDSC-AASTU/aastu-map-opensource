import 'package:aastu_map/data/models/user_model.dart';

abstract class ProfileState {}

class ProfileInitial extends ProfileState {}

class ProfileLoading extends ProfileState {}

class ProfileLoaded extends ProfileState {
  final UserModel user;

  ProfileLoaded({required this.user});
}

class ProfileImageUpdated extends ProfileState {
  final UserModel updatedUser;

  ProfileImageUpdated({required this.updatedUser});
}

class ProfileUpdated extends ProfileState {
  final UserModel updatedUser;

  ProfileUpdated({required this.updatedUser});
}

class ProfileError extends ProfileState {
  final String error;

  ProfileError({required this.error, required String message});
}