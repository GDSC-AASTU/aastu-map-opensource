import 'dart:developer';

import 'package:aastu_map/data/models/user_model.dart';
import 'package:aastu_map/data/repository/repository.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'profile_event.dart';
import 'profile_state.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final ProfileRepository profileRepository;
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  UserModel _user = UserModel.empty();

  ProfileBloc({required this.profileRepository}) : super(ProfileInitial()) {
    on<LoadProfileEvent>(_onFetchProfile);
    on<PickImageEvent>(_onPickImage);
    on<UpdateProfileEvent>(_onUpdateProfile);
  }
Future<void> _onFetchProfile(
    LoadProfileEvent event, Emitter<ProfileState> emit) async {
  emit(ProfileLoading());
  try {
    final uid = await _firebaseAuth.currentUser!.uid;
    final user = await profileRepository.getUserProfile(uid);

    // Log the fetched user data for debugging
    print("Fetched User Data: ${user.toJson()}");

    _user = user;
    emit(ProfileLoaded(user: user));
  } catch (e) {
    print("Error fetching profile: $e");
    emit(ProfileError(message: e.toString(), error: 'Failed to load profile'));
  }
}

  Future<void> _onPickImage(
      PickImageEvent event, Emitter<ProfileState> emit) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      emit(ProfileImageUpdated(updatedUser: _user));
    }
  }
Future<void> _onUpdateProfile(
    UpdateProfileEvent event, Emitter<ProfileState> emit) async {
  emit(ProfileLoading());
  try {
    final updatedUser = _user.copyWith(
      firstname: event.firstname,
      lastname: event.lastname,
      email: event.email,
      phoneNumber: event.phoneNumber,
    );

    await profileRepository.updateUserProfile(updatedUser);
    
    // If password is provided, update the password separately
    if (event.password != null && event.password!.isNotEmpty) {
      await profileRepository.updatePassword(event.password!);
    }
    
    _user = updatedUser;

    emit(ProfileUpdated(updatedUser: updatedUser));
  } catch (e) {
    emit(ProfileError(message: e.toString(), error: 'Failed to update profile'));
  }
}
}