import 'dart:async';
import 'dart:developer';

import 'package:aastu_map/data/repositories/auth_repository.dart';
import 'package:bloc/bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository _authRepository;

  AuthBloc(this._authRepository) : super(AuthInitial()) {
    on<LoginEvent>(_onLogin);
    on<SignInAnonymously>(_onSignAnonymously);
    on<SignUpEvent>(_onSignUp);
    on<LogoutEvent>(_onLogout);
    on<CheckAuthStatusEvent>(_onCheckAuthStatus);
    on<StartEmailVerificationCheckEvent>(_onStartEmailVerificationCheck);
    on<ManuallyCheckEmailVerificationEvent>(_onManuallyCheckEmailVerification);
    on<SendEmailVerificationEvent>(_onSendEmailVerification);
    on<SignInWithGoogleEvent>(_onSignInWithGoogle);
  }

  void _onLogin(LoginEvent event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      final userCredential = await _authRepository.signInWithEmailAndPassword(
        event.email, 
        event.password
      );

      if (!userCredential.user!.emailVerified) {
        emit(AuthUnverified());
        return;
      }
      
      emit(AuthAuthenticated(userId: userCredential.user?.uid ?? ""));
    } catch (e) {
      emit(AuthError(message: e.toString()));
    }
  }

  _onSignAnonymously(SignInAnonymously event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      final userCredential = await _authRepository.signInAnonymously();
      emit(AuthAuthenticated(userId: userCredential.user?.uid ?? ""));
    } catch (e) {
      emit(AuthError(message: e.toString()));
    }
  }

  Future<void> _onSignInWithGoogle(
      SignInWithGoogleEvent event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      final User? user = await _authRepository.signInWithGoogle();
      
      if (user != null) {
        emit(AuthAuthenticated(userId: user.uid));
      } else {
        emit(AuthError(message: 'Google Sign-In was canceled.'));
      }
    } catch (e) {
      log('Google sign-in error: $e');
      emit(AuthError(message: e.toString()));
    }
  }

  void _onSignUp(SignUpEvent event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      await _authRepository.registerWithEmailAndPassword(
        email: event.email,
        password: event.password,
        firstname: event.firstname,
        lastname: event.lastname,
        phoneNumber: event.phoneNumber,
      );

      emit(AuthSignupSuccess());
    } catch (e) {
      emit(AuthError(message: e.toString()));
    }
  }

  void _onLogout(LogoutEvent event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    await _authRepository.signOut();
    emit(AuthUnauthenticated());
  }

  void _onCheckAuthStatus(CheckAuthStatusEvent event, Emitter<AuthState> emit) {
    final User? user = _authRepository.currentUser;
    if (user != null) {
      if (user.isAnonymous || user.emailVerified) {
        emit(AuthAuthenticated(userId: user.uid));
      } else {
        emit(AuthUnverified());
      }
    } else {
      emit(AuthUnauthenticated());
    }
  }

  Future<void> _onSendEmailVerification(
      SendEmailVerificationEvent event, Emitter<AuthState> emit) async {
    try {
      await _authRepository.sendEmailVerification();
      emit(EmailVerificationSent());
    } catch (e) {
      emit(EmailVerificationFailed(e.toString()));
    }
  }

  Future<void> _onStartEmailVerificationCheck(
      StartEmailVerificationCheckEvent event, Emitter<AuthState> emit) async {
    try {
      emit(EmailVerificationSent()); // Emit that verification started

      // Run a loop to periodically check the user's email verification status
      for (int i = 0; i < 300; i++) { // Check for 5 minutes max
        await Future.delayed(const Duration(seconds: 1)); // Delay for 1 second
        final isVerified = await _authRepository.checkEmailVerification();
        if (isVerified) {
          emit(EmailVerificationSuccess());
          return; // Exit the handler once verification is successful
        }
      }

      // If the loop finishes without success, emit a failure state
      emit(EmailVerificationFailed("Email verification timeout. Please check manually."));
    } catch (e) {
      emit(EmailVerificationFailed(e.toString())); // Emit failure on error
    }
  }

  Future<void> _onManuallyCheckEmailVerification(
      ManuallyCheckEmailVerificationEvent event,
      Emitter<AuthState> emit) async {
    try {
      final isVerified = await _authRepository.checkEmailVerification();
      if (isVerified) {
        emit(EmailVerificationSuccess());
      } else {
        emit(EmailVerificationFailed("Email not verified yet."));
      }
    } catch (e) {
      emit(EmailVerificationFailed(e.toString()));
    }
  }
}

