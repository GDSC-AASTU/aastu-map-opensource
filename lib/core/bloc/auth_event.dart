import 'package:equatable/equatable.dart';

abstract class AuthEvent extends Equatable {
  @override
  List<Object> get props => [];
}

// Login Event
class LoginEvent extends AuthEvent {
  final String email;
  final String password;

  LoginEvent({required this.email, required this.password});

  @override
  List<Object> get props => [email, password];
}

// Sign-Up Event
class SignUpEvent extends AuthEvent {
  final String email;
  final String firstname;
  final String lastname;
  final String password;
  final String? phoneNumber;

  SignUpEvent({
    required this.email,
    required this.password,
    required this.lastname,
    required this.firstname,
    this.phoneNumber,
  });

  @override
  List<Object> get props => [email, password, firstname, lastname];
}

// Logout Event
class LogoutEvent extends AuthEvent {}

// Check Authentication Status Event
class CheckAuthStatusEvent extends AuthEvent {}

class VerifyCodeEvent extends AuthEvent {
  final String verificationCode;

  VerifyCodeEvent({required this.verificationCode});
}

class SendEmailVerificationEvent extends AuthEvent {}

class StartEmailVerificationCheckEvent extends AuthEvent {}

class ManuallyCheckEmailVerificationEvent extends AuthEvent {}

class SignInWithGoogleEvent extends AuthEvent {}

class SignInAnonymously extends AuthEvent {}
