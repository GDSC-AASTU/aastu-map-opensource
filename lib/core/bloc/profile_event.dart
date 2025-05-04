abstract class ProfileEvent {}

class LoadProfileEvent extends ProfileEvent {}

class PickImageEvent extends ProfileEvent {}

class UpdateProfileEvent extends ProfileEvent {
  final String firstname;
  final String? lastname;
  final String email;
  final String? phoneNumber;
  final String? password;

  UpdateProfileEvent({
    required this.firstname,
    this.lastname,
    required this.email,
    this.phoneNumber,
    this.password,
  });
}