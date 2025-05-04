import 'package:aastu_map/core/colors.dart';
import 'package:flutter/material.dart';
import 'package:aastu_map/pages/admin/manage_suggestions.dart';
import 'package:aastu_map/pages/admin/places/places_admin.dart';
import 'package:aastu_map/pages/admin/clubs/clubs_admin.dart';
import 'package:aastu_map/pages/admin/about/about_admin.dart';
import 'package:aastu_map/pages/admin/developers/developers_admin.dart';
import 'package:aastu_map/pages/admin/events/events_admin.dart';

class CreateContentPage extends StatelessWidget {
  const CreateContentPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Admin content management options
    final List<AdminOption> options = [
      AdminOption(
        title: 'Manage Places',
        icon: Icons.place,
        color: Colors.blueAccent,
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const PlacesAdminPage()),
        ),
      ),
      AdminOption(
        title: 'Manage Clubs',
        icon: Icons.group,
        color: Colors.orangeAccent,
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const ClubsAdminPage()),
        ),
      ),
      AdminOption(
        title: 'Manage About AASTU',
        icon: Icons.info,
        color: Colors.greenAccent,
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const AboutAdminPage()),
        ),
      ),
      AdminOption(
        title: 'Manage Developer List',
        icon: Icons.developer_mode,
        color: Colors.purpleAccent,
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const DevelopersAdmin()),
        ),
      ),
      AdminOption(
        title: 'Manage Events',
        icon: Icons.event,
        color: Colors.redAccent,
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const EventsAdminPage()),
        ),
      ),
      AdminOption(
        title: 'Manage Suggestions',
        icon: Icons.lightbulb,
        color: Colors.amber,
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const ManageSuggestionsPage()),
        ),
      ),
    ];

    return Scaffold(

      appBar: AppBar(
        title: const Text('Create Content', 
            style: TextStyle(
              fontWeight: FontWeight.w800, 
              color: Colors.white, 
              fontSize: 18.0,
            )),
        backgroundColor: AppColors.primary,
        elevation: 4,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(20),
            bottomRight: Radius.circular(20),
          ),
        ),
        //back button
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.arrow_back, color: Colors.white),
        ),
        centerTitle: true,
      ),
      body: Container(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.only(left: 16.0, top: 8.0, bottom: 16.0),
              child: Text(
                'Select Content Type',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16.0,
                  mainAxisSpacing: 16.0,
                  childAspectRatio: 1.1,
                ),
                itemCount: options.length,
                itemBuilder: (context, index) {
                  return _buildAdminOptionCard(context, options[index]);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAdminOptionCard(BuildContext context, AdminOption option) {
    return GestureDetector(
      onTap: option.onTap,
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.0),
        ),
        child: Container(
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16.0),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                option.color.withOpacity(0.7),
                option.color,
              ],
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                option.icon,
                size: 40,
                color: Colors.white,
              ),
              const SizedBox(height: 12),
              Text(
                option.title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class AdminOption {
  final String title;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  AdminOption({
    required this.title,
    required this.icon,
    required this.color,
    required this.onTap,
  });
} 