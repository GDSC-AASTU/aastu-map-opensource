import 'package:aastu_map/core/colors.dart';
import 'package:aastu_map/data/models/club_model.dart';
import 'package:aastu_map/pages/admin/components/admin_form_field.dart';
import 'package:aastu_map/pages/admin/components/admin_scaffold.dart';
import 'package:aastu_map/pages/admin/components/image_url_input.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';

class ClubsAdminPage extends StatefulWidget {
  const ClubsAdminPage({Key? key}) : super(key: key);

  @override
  State<ClubsAdminPage> createState() => _ClubsAdminPageState();
}

class _ClubsAdminPageState extends State<ClubsAdminPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _membersCountController = TextEditingController();
  
  String _logoImage = '';
  String _backgroundImage = '';
  List<String> _images = [];
  List<SocialMedia> _socialMedia = [];
  final _socialMediaPlatformController = TextEditingController();
  final _socialMediaUrlController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _membersCountController.dispose();
    _socialMediaPlatformController.dispose();
    _socialMediaUrlController.dispose();
    super.dispose();
  }

  void _addSocialMedia() {
    if (_socialMediaPlatformController.text.isNotEmpty &&
        _socialMediaUrlController.text.isNotEmpty) {
      setState(() {
        _socialMedia.add(SocialMedia(
          platform: _socialMediaPlatformController.text,
          url: _socialMediaUrlController.text,
        ));
        _socialMediaPlatformController.clear();
        _socialMediaUrlController.clear();
      });
    }
  }

  void _removeSocialMedia(int index) {
    setState(() {
      _socialMedia.removeAt(index);
    });
  }

  Future<void> _addClub() async {
    if (!_formKey.currentState!.validate() ||
        _logoImage.isEmpty ||
        _backgroundImage.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Please fill all fields and select both images')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final club = ClubModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: _titleController.text,
        description: _descriptionController.text,
        membersCount: int.parse(_membersCountController.text),
        logoImage: _logoImage,
        backgroundImage: _backgroundImage,
        images: _images,
        socialMedia: _socialMedia,
        createdBy: 'admin', // In a real app, this would be the current user's ID
      );

      await FirebaseFirestore.instance
        .collection('clubs')
        .doc(club.id)
        .set(club.toJson());

      _clearForm();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Club added successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error adding club: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _clearForm() {
    _formKey.currentState?.reset();
    _titleController.clear();
    _descriptionController.clear();
    _membersCountController.clear();
    _socialMediaPlatformController.clear();
    _socialMediaUrlController.clear();
    setState(() {
      _logoImage = '';
      _backgroundImage = '';
      _images = [];
      _socialMedia = [];
    });
  }

  void _handleBackNavigation() {
    context.go('/admin/create_content');
  }

  @override
  Widget build(BuildContext context) {
    return AdminScaffold(
      title: 'Manage Clubs',
      isLoading: _isLoading,
      onBackPressed: _handleBackNavigation,
      body: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Title section
            Text(
              'Add New Club',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
            const Divider(height: 32),
            
            // Form fields
            AdminFormField(
              label: 'Club Name',
              controller: _titleController,
            ),
            const Gap(16),
            
            AdminFormField(
              label: 'Description',
              controller: _descriptionController,
              maxLines: 4,
            ),
            const Gap(16),
            
            AdminFormField(
              label: 'Number of Members',
              controller: _membersCountController,
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Member count is required';
                }
                if (int.tryParse(value) == null) {
                  return 'Please enter a valid number';
                }
                return null;
              },
            ),
            const Gap(24),
            
            // Logo image uploader
            Text(
              'Club Logo',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
            ),
            const Gap(8),
            ImageUrlInput(
              allowMultiple: false,
              initialImages: _logoImage.isEmpty ? [] : [_logoImage],
              onImagesUploaded: (urls) {
                setState(() {
                  _logoImage = urls.isNotEmpty ? urls.first : '';
                });
              },
            ),
            const Gap(24),
            
            // Background image uploader
            Text(
              'Background Image',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
            ),
            const Gap(8),
            ImageUrlInput(
              allowMultiple: false,
              initialImages: _backgroundImage.isEmpty ? [] : [_backgroundImage],
              onImagesUploaded: (urls) {
                setState(() {
                  _backgroundImage = urls.isNotEmpty ? urls.first : '';
                });
              },
            ),
            const Gap(24),
            
            // Additional images uploader
            Text(
              'Additional Images',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
            ),
            const Gap(8),
            ImageUrlInput(
              allowMultiple: true,
              initialImages: _images,
              onImagesUploaded: (urls) {
                setState(() {
                  _images = urls;
                });
              },
            ),
            const Gap(24),
            
            // Social Media section
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Social Media',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
                ),
                const Gap(8),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _socialMediaPlatformController,
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.grey[50],
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: Colors.grey[300]!),
                          ),
                          hintText: 'Platform (e.g., Twitter)',
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextFormField(
                        controller: _socialMediaUrlController,
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.grey[50],
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: Colors.grey[300]!),
                          ),
                          hintText: 'URL',
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: _addSocialMedia,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: const Text('Add'),
                    ),
                  ],
                ),
                if (_socialMedia.isNotEmpty) ...[
                  const Gap(8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _socialMedia.asMap().entries.map((entry) {
                      return Chip(
                        label: Text('${entry.value.platform}: ${entry.value.url}'),
                        backgroundColor: Colors.blue[50],
                        deleteIconColor: Colors.red,
                        onDeleted: () => _removeSocialMedia(entry.key),
                      );
                    }).toList(),
                  ),
                ],
              ],
            ),
            const Gap(32),
            
            // Submit button
            ElevatedButton.icon(
              onPressed: _addClub,
              icon: const Icon(Icons.add_circle),
              label: const Text('Add Club'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            const Gap(32),
            
            // Existing clubs
            Text(
              'Existing Clubs',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
            const Divider(height: 32),
            
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('clubs')
                  .orderBy('createdAt', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final docs = snapshot.data?.docs ?? [];
                if (docs.isEmpty) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Text(
                        'No clubs added yet',
                        style: TextStyle(
                          fontSize: 16,
                          fontStyle: FontStyle.italic,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                  );
                }

                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    final data = docs[index].data() as Map<String, dynamic>;
                    return Card(
                      margin: const EdgeInsets.only(bottom: 16),
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              // Logo image
                              Container(
                                width: 80,
                                height: 80,
                                margin: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8),
                                  image: DecorationImage(
                                    image: NetworkImage(data['logoImage'] ?? ''),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                              // Club details
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        data['title'] ?? 'No Title',
                                        style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const Gap(4),
                                      Text(
                                        'Members: ${data['membersCount'] ?? '0'}',
                                        style: TextStyle(
                                          color: Colors.grey[700],
                                        ),
                                      ),
                                      const Gap(8),
                                      Text(
                                        data['description'] ?? 'No description',
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              // Action buttons
                              Column(
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.edit, color: Colors.blue),
                                    onPressed: () {
                                      // Edit functionality would go here
                                    },
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete, color: Colors.red),
                                    onPressed: () async {
                                      // Show confirmation dialog
                                      final shouldDelete = await showDialog<bool>(
                                        context: context,
                                        builder: (context) => AlertDialog(
                                          title: const Text('Delete Club'),
                                          content: const Text('Are you sure you want to delete this club?'),
                                          actions: [
                                            TextButton(
                                              onPressed: () => Navigator.of(context).pop(false),
                                              child: const Text('Cancel'),
                                            ),
                                            TextButton(
                                              onPressed: () => Navigator.of(context).pop(true),
                                              child: const Text('Delete', style: TextStyle(color: Colors.red)),
                                            ),
                                          ],
                                        ),
                                      );
                                      
                                      if (shouldDelete == true) {
                                        try {
                                          await FirebaseFirestore.instance
                                              .collection('clubs')
                                              .doc(docs[index].id)
                                              .delete();
                                              
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            const SnackBar(content: Text('Club deleted successfully')),
                                          );
                                        } catch (e) {
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(content: Text('Error deleting club: $e')),
                                          );
                                        }
                                      }
                                    },
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
} 