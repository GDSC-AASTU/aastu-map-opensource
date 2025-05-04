import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';

class AdminPage extends StatefulWidget {
  @override
  _AdminPageState createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> {
  final TextEditingController _communityNameController =
      TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _membersController = TextEditingController();
  final TextEditingController _logoUrlController = TextEditingController();

  // Function to add community data to Firestore
  Future<void> _addCommunity(BuildContext context) async {
    String name = _communityNameController.text.trim();
    String description = _descriptionController.text.trim();
    String members = _membersController.text.trim();
    String logoUrl = _logoUrlController.text.trim();

    if (name.isNotEmpty && description.isNotEmpty && members.isNotEmpty && logoUrl.isNotEmpty) {
      try {
        // Add the community to Firestore
        await FirebaseFirestore.instance.collection('communities').add({
          'name': name,
          'logo': logoUrl,
          'description': description,
          'members': int.parse(members),
          'approved': false, // Initially set as not approved
        });

        // Clear the fields after successful addition
        _communityNameController.clear();
        _descriptionController.clear();
        _membersController.clear();
        _logoUrlController.clear();

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Community added successfully!')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to add community: $e')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please fill in all fields including the logo URL!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Admin Dashboard')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Admin Dashboard Title
            Text(
              'Admin Dashboard',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            SizedBox(height: 20),

            Text(
              'Here you can manage communities. Start by adding a community!',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            SizedBox(height: 40),

            TextField(
              controller: _communityNameController,
              decoration: InputDecoration(
                labelText: 'Community Name',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),

            // Description Field
            TextField(
              controller: _descriptionController,
              maxLines: 3,
              decoration: InputDecoration(
                labelText: 'Description',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),

            // Number of Members Field
            TextField(
              controller: _membersController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Number of Members',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),

            // Logo URL Field
            TextField(
              controller: _logoUrlController,
              decoration: InputDecoration(
                labelText: 'Logo Image URL',
                hintText: 'Enter the URL of the logo image',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),

            // Add Community Button
            ElevatedButton(
              onPressed: () => _addCommunity(context),
              child: Text('Add Community'),
            ),
          ],
        ),
      ),
    );
  }
}
