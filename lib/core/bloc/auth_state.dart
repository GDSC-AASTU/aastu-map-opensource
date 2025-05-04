import 'package:equatable/equatable.dart';

abstract class AuthState extends Equatable {
  @override
  List<Object> get props => [];
}

// Initial State
class AuthInitial extends AuthState {}

// Loading State
class AuthLoading extends AuthState {}

// Authenticated State
class AuthAuthenticated extends AuthState {
  final String userId;

  AuthAuthenticated({required this.userId});

  @override
  List<Object> get props => [userId];
}

// Authenticated State
class AuthSignupSuccess extends AuthState {}

// Unauthenticated State
class AuthUnauthenticated extends AuthState {}

// Error State
class AuthError extends AuthState {
  final String message;

  AuthError({required this.message});

  @override
  List<Object> get props => [message];
}

class EmailVerificationSent extends AuthState {}

class EmailVerificationSuccess extends AuthState {}

class EmailVerificationFailed extends AuthState {
  final String error;

  EmailVerificationFailed(this.error);
}

class AuthUnverified extends AuthState {}
