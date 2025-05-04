import 'package:aastu_map/widgets/common.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:aastu_map/core/colors.dart';
import 'package:aastu_map/core/bloc/profile_bloc.dart';
import 'package:aastu_map/core/bloc/profile_event.dart';
import 'package:aastu_map/core/bloc/profile_state.dart';

class EditProfile extends StatefulWidget {
  @override
  _EditProfilePageState createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfile> {
  File? _image;
  late TextEditingController firstNameController;
  late TextEditingController lastNameController;
  late TextEditingController emailController;
  late TextEditingController phoneNumberController;
  late TextEditingController passwordController;

  @override
  void initState() {
    super.initState();
    final profileState = context.read<ProfileBloc>().state;
    if (profileState is ProfileLoaded) {
      firstNameController = TextEditingController(text: profileState.user.firstname ?? '');
      lastNameController = TextEditingController(text: profileState.user.lastname ?? '');
      emailController = TextEditingController(text: profileState.user.email ?? '');
      phoneNumberController = TextEditingController(text: profileState.user.phoneNumber ?? '');
      passwordController = TextEditingController(); // Leave password empty for security
    } else {
      firstNameController = TextEditingController();
      lastNameController = TextEditingController();
      emailController = TextEditingController();
      phoneNumberController = TextEditingController();
      passwordController = TextEditingController();
    }
  }

  @override
  void dispose() {
    firstNameController.dispose();
    lastNameController.dispose();
    emailController.dispose();
    phoneNumberController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  String _getDisplayName() {
    final first = firstNameController.text.trim();
    final last = lastNameController.text.trim();
    
    if (first.isEmpty && last.isEmpty) return "No Name";
    if (first.isEmpty) return last;
    if (last.isEmpty) return first;
    
    return "$first $last";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            pinned: true,
            floating: false,
            title: Text(
              "Edit Profile",
              style: TextStyle(color: Colors.black),
            ),
            centerTitle: true,
          ),
          SliverToBoxAdapter(
            child: Column(
              children: [
                SizedBox(height: 20),
                // Edit Profile Picture
                GestureDetector(
                  onTap: _pickImage,
                  child: CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.grey.shade200,
                    backgroundImage: _image != null ? FileImage(_image!) : null,
                    child: _image == null
                        ? Icon(Icons.person, size: 50, color: Colors.grey)
                        : null,
                  ),
                ),
                SizedBox(height: 10),
                // Name and Email
                Text(
                  _getDisplayName(),
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Text(
                  emailController.text.isNotEmpty ? emailController.text : "No Email",
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                ),
                SizedBox(height: 10),

                SizedBox(height: 20),
                // Options List
                Divider(thickness: 1),
                Container(
                  padding: EdgeInsets.all(10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      CustomTextField(
                          hintText: "First Name", textcont: firstNameController),
                      SizedBox(height: 15),
                      CustomTextField(
                          hintText: "Last Name", textcont: lastNameController),
                      SizedBox(height: 15),
                      CustomTextField(
                          hintText: "Email", textcont: emailController),
                      SizedBox(height: 15),
                      CustomTextField(
                          hintText: "Phone Number",
                          textcont: phoneNumberController),
                      SizedBox(height: 15),
                      CustomTextField(
                          hintText: "Update Password",
                          textcont: passwordController),
                      SizedBox(height: 15),
                      BlocConsumer<ProfileBloc, ProfileState>(
                        listener: (context, state) {
                          if (state is ProfileUpdated) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text("Profile updated successfully!"),backgroundColor:Colors.green,),
                            );
                          } else if (state is ProfileError) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(state.error),backgroundColor:Colors.red,),
                            );
                          }
                        },
                        builder: (context, state) {
                          return CustomButton(
                            text: "Update Profile",
                            isLoading: state is ProfileLoading,
                            onPressed: () {
                              context.read<ProfileBloc>().add(UpdateProfileEvent(
                                firstname: firstNameController.text,
                                lastname: lastNameController.text,
                                email: emailController.text,
                                phoneNumber: phoneNumberController.text.isEmpty ? null : phoneNumberController.text,
                                password: passwordController.text.isEmpty ? null : passwordController.text,
                              ));
                            },
                            color: AppColors.primary,
                            textColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),

                // App Version
                SizedBox(height: 40),
                Text(
                  "App Version 0.0",
                  style: TextStyle(color: Colors.grey, fontSize: 14),
                ),
                SizedBox(height: 20),
              ],
            ),
          ),
        ],
      ),
    );
  }
}