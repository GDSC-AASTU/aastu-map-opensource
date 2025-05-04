import 'package:aastu_map/core/bloc/profile_bloc.dart';
import 'package:aastu_map/core/bloc/profile_event.dart';
import 'package:aastu_map/core/bloc/profile_state.dart';
import 'package:aastu_map/core/colors.dart';
import 'package:aastu_map/core/bloc/auth_bloc.dart';
import 'package:aastu_map/core/bloc/auth_event.dart';
import 'package:aastu_map/core/bloc/auth_state.dart';
import 'package:aastu_map/pages/about/about_aastu.dart';
import 'package:aastu_map/pages/about/aastu_info_page.dart';
import 'package:aastu_map/pages/profile/settings.dart';
import 'package:aastu_map/pages/profile/suggest_location.dart';
import 'package:aastu_map/pages/profile/edit_profile.dart';
import 'package:aastu_map/pages/admin/create_content.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:line_icons/line_icons.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:share_plus/share_plus.dart';

class Profile extends StatefulWidget {
  const Profile({Key? key}) : super(key: key);

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  PackageInfo _packageInfo = PackageInfo(
    appName: 'AASTU Map',
    packageName: '',
    version: '0.0',
    buildNumber: '0',
    buildSignature: '',
    installerStore: '',
  );

  @override
  void initState() {
    super.initState();
    _initPackageInfo();
    
    // Trigger LoadProfileEvent when the Profile page is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProfileBloc>().add(LoadProfileEvent());
    });
  }

  Future<void> _initPackageInfo() async {
    final info = await PackageInfo.fromPlatform();
    if (mounted) {
      setState(() {
        _packageInfo = info;
      });
    }
    print('[LOG Profile] ========= Package info loaded: ${_packageInfo.version}+${_packageInfo.buildNumber}');
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthUnauthenticated) {
          // Navigate to the login screen when signed out
          GoRouter.of(context).go("/login");
        } else if (state is AuthError) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Logout Failed!")),
          );
        }
      },
      child: BlocBuilder<ProfileBloc, ProfileState>(builder: (context, state) {
        return Scaffold(
          backgroundColor: Colors.white,
          body: Stack(
            children: [
              // Background container
              Container(
                color: Colors.white,
              ),
              CustomScrollView(
                slivers: [
                  // Curved app bar with primary color
                  SliverAppBar(
                    backgroundColor: AppColors.primary,
                    elevation: 0,
                    pinned: true,
                    floating: false,
                    expandedHeight: 65,
                    
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(20),
                        bottomRight: Radius.circular(20),
                      ),
                    ),
                    title: const Text(
                      "My Profile",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18.0,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    centerTitle: true,
                    // Add some bottom padding to make the curved shape more visible
                    bottom: PreferredSize(
                      preferredSize: const Size.fromHeight(10),
                      child: Container(),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: Container(
                      color: Colors.white,
                      padding: const EdgeInsets.only(top: 16),
                      child: BlocBuilder<ProfileBloc, ProfileState>(
                        builder: (context, state) {
                          final String? profilePic = (state is ProfileLoaded) 
                              ? (state.user.profilePic.isEmpty ? null : state.user.profilePic)
                              : null;

                          // Handle name with null safety
                          final String name = state is ProfileLoaded
                              ? _getDisplayName(state.user.firstname, state.user.lastname)
                              : "Loading Name...";
                              
                          // Handle email with null safety
                          final String email = state is ProfileLoaded
                              ? state.user.isAnonymous 
                                  ? "Guest User"
                                  : state.user.email
                              : "Loading Email...";

                          // Check if user is admin
                          final bool isAdmin = state is ProfileLoaded ? state.user.isAdmin : false;

                          return Column(
                            children: [
                              const SizedBox(height: 20),
                              GestureDetector(
                                onTap: () {
                                  context.read<ProfileBloc>().add(PickImageEvent());
                                },
                                child: CircleAvatar(
                                  radius: 50,
                                  backgroundColor: Colors.grey.shade200,
                                  backgroundImage: profilePic != null ? NetworkImage(profilePic) : null,
                                  child: profilePic == null
                                      ? const Icon(Icons.person, size: 50, color: Colors.grey)
                                      : null,
                                ),
                              ),
                              const SizedBox(height: 10),
                              Text(
                                name,
                                style: const TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                              Text(
                                email,
                                style: const TextStyle(fontSize: 14, color: Colors.grey),
                              ),
                              const SizedBox(height: 30),
                              _buildListItem(
                                  Icons.edit, 
                                  "Edit Profile",
                                  "", 
                                  context,
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(builder: (context) => EditProfile()),
                                    );
                                  }
                              ),
                              // Admin only: Manage option
                              if (isAdmin)
                                _buildListItem(
                                  LineIcons.cog, 
                                  "Manage", 
                                  "", 
                                  context,
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(builder: (context) => const CreateContentPage()),
                                    );
                                  }
                                ),
                              _buildListItem(
                                  Icons.add_location_alt, "Suggest a Location", "", context,
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(builder: (context) => const SuggestLocationPage()),
                                    );
                                  }),
                              _buildListItem(
                                  Icons.share, "Share this App", "", context,
                                  onTap: () => _shareApp(context)),
                              _buildListItem(
                                  Icons.settings, "Settings", "", context,
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(builder: (context) => const SettingsPage()),
                                    );
                                  }),
                              _buildListItem(
                                  LineIcons.infoCircle, "About Us", "", context, 
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(builder: (context) => const AboutUs()),
                                    );
                                  }),
                              _buildListItem(
                                  LineIcons.university, "Learn about AASTU", "", context, 
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(builder: (context) => const AASTUInfoPage()),
                                    );
                                  }),
                              _buildSignOutItem(context),
                              const SizedBox(height: 140),
                              // Version information with app version and build number
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade100,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(
                                      LineIcons.infoCircle, 
                                      size: 14,
                                      color: Colors.grey,
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      "${_packageInfo.appName} v${_packageInfo.version}+${_packageInfo.buildNumber}",
                                      style: const TextStyle(
                                        color: Colors.grey,
                                        fontSize: 13,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 20),
                            ],
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      }),
    );
  }

  // Helper method to safely get display name even if firstname or lastname is null
  String _getDisplayName(String? firstname, String? lastname) {
    if ((firstname == null || firstname.trim().isEmpty) && 
        (lastname == null || lastname.trim().isEmpty)) {
      return "Anonymous User";
    }
    
    final first = firstname?.trim() ?? "";
    final last = lastname?.trim() ?? "";
    
    if (first.isEmpty) return last;
    if (last.isEmpty) return first;
    
    return "$first $last";
  }

  Widget _buildSignOutItem(BuildContext context) {
    return ListTile(
      leading: const Icon(Icons.logout, color: Colors.red),
      title: const Text("Sign Out", 
        style: TextStyle(
          fontSize: 16, 
          color: Colors.red,
          fontWeight: FontWeight.w500
        )
      ),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
      onTap: () {
        // Show confirmation dialog
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text("Sign Out"),
              content: const Text("Are you sure you want to sign out?"),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Cancel"),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    context.read<AuthBloc>().add(LogoutEvent());
                  },
                  child: const Text("Sign Out", style: TextStyle(color: Colors.red)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildListItem(
      IconData icon, String title, String goTo, BuildContext context, {VoidCallback? onTap}) {
    return InkWell(
      onTap: onTap ?? () {
        if (goTo.isNotEmpty) {
          print('[LOG Profile] ========= Navigating to: $goTo');
          Navigator.pushNamed(context, goTo);
        } else {
          print('[LOG Profile] ========= Navigation path is empty for: $title');
        }
      },
      child: ListTile(
        leading: Icon(icon, color: AppColors.primary),
        title: Text(title, style: const TextStyle(fontSize: 16)),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
      ),
    );
  }

  // Share app function
  void _shareApp(BuildContext context) {
    final String appName = _packageInfo.appName;
    final String message = 'Check out $appName! The best way to navigate AASTU campus. '
        'Download it now: https://play.google.com/store/apps/details?id=${_packageInfo.packageName}';
    
    Share.share(message)
        .then((_) => print('[LOG Profile] ========= App shared successfully'))
        .catchError((error) {
          print('[LOG Profile] ========= Error sharing app: $error');
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Failed to share app")),
          );
        });
  }
}