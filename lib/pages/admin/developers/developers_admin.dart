import 'package:aastu_map/core/colors.dart';
import 'package:aastu_map/data/models/developer_model.dart';
import 'package:aastu_map/pages/admin/components/admin_form_field.dart';
import 'package:aastu_map/pages/admin/components/admin_scaffold.dart';
import 'package:aastu_map/pages/admin/components/image_url_input.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';

class DevelopersAdmin extends StatefulWidget {
  const DevelopersAdmin({super.key});

  @override
  State<DevelopersAdmin> createState() => _DevelopersAdminState();
}

class _DevelopersAdminState extends State<DevelopersAdmin> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _roleController = TextEditingController();
  final _yearController = TextEditingController();
  final _departmentController = TextEditingController();
  final _githubController = TextEditingController();
  final _linkedinController = TextEditingController();
  final _twitterController = TextEditingController();
  
  String _profilePic = '';
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _roleController.dispose();
    _yearController.dispose();
    _departmentController.dispose();
    _githubController.dispose();
    _linkedinController.dispose();
    _twitterController.dispose();
    super.dispose();
  }

  Future<void> _addDeveloper() async {
    if (!_formKey.currentState!.validate() || _profilePic.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all required fields and select a profile picture')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Create a map of social media links
      Map<String, String> socialMedia = {};
      
      if (_githubController.text.isNotEmpty) {
        socialMedia['github'] = _githubController.text;
      }
      
      if (_linkedinController.text.isNotEmpty) {
        socialMedia['linkedin'] = _linkedinController.text;
      }
      
      if (_twitterController.text.isNotEmpty) {
        socialMedia['twitter'] = _twitterController.text;
      }

      final developer = DeveloperModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: _nameController.text,
        role: _roleController.text,
        profilePic: _profilePic,
        year: int.parse(_yearController.text),
        department: _departmentController.text,
        socialMedia: socialMedia,
        createdBy: 'admin', // In a real app, this would be the current user's ID
      );

      await FirebaseFirestore.instance
          .collection('developers')
          .doc(developer.id)
          .set(developer.toJson());

      _clearForm();
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Developer added successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error adding developer: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _clearForm() {
    _formKey.currentState?.reset();
    _nameController.clear();
    _roleController.clear();
    _yearController.clear();
    _departmentController.clear();
    _githubController.clear();
    _linkedinController.clear();
    _twitterController.clear();
    setState(() {
      _profilePic = '';
    });
  }

  void _handleBackNavigation() {
    context.go('/admin/create_content');
  }

  @override
  Widget build(BuildContext context) {
    return AdminScaffold(
      title: 'Manage Developers',
      isLoading: _isLoading,
      onBackPressed: _handleBackNavigation,
      body: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Title section
            Text(
              'Add New Developer',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
            const Divider(height: 32),
            
            // Profile picture uploader
            Text(
              'Profile Picture',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
            ),
            const Gap(8),
            ImageUrlInput(
              allowMultiple: false,
              initialImages: _profilePic.isEmpty ? [] : [_profilePic],
              onImagesUploaded: (urls) {
                setState(() {
                  _profilePic = urls.isNotEmpty ? urls.first : '';
                });
              },
            ),
            const Gap(24),
            
            // Personal info section
            Text(
              'Personal Information',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.primary,
              ),
            ),
            const Gap(16),
            
            // Form fields
            AdminFormField(
              label: 'Full Name *',
              controller: _nameController,
            ),
            const Gap(16),
            
            AdminFormField(
              label: 'Role *',
              controller: _roleController,
              hintText: 'e.g. Frontend Developer, UI/UX Designer',
            ),
            const Gap(16),
            
            Row(
              children: [
                Expanded(
                  child: AdminFormField(
                    label: 'Year *',
                    controller: _yearController,
                    keyboardType: TextInputType.number,
                    hintText: '4',
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Year is required';
                      }
                      if (int.tryParse(value) == null) {
                        return 'Please enter a valid number';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: AdminFormField(
                    label: 'Department *',
                    controller: _departmentController,
                    hintText: 'e.g. Software Engineering',
                  ),
                ),
              ],
            ),
            const Gap(24),
            
            // Social media section
            Text(
              'Social Media (Optional)',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.primary,
              ),
            ),
            const Gap(16),
            
            AdminFormField(
              label: 'GitHub Profile',
              controller: _githubController,
              hintText: 'https://github.com/username',
              prefixIcon: Icon(Icons.code, color: Colors.grey[600]),
            ),
            const Gap(16),
            
            AdminFormField(
              label: 'LinkedIn Profile',
              controller: _linkedinController,
              hintText: 'https://linkedin.com/in/username',
              prefixIcon: Icon(Icons.work, color: Colors.grey[600]),
            ),
            const Gap(16),
            
            AdminFormField(
              label: 'Twitter/X Profile',
              controller: _twitterController,
              hintText: 'https://twitter.com/username',
              prefixIcon: Icon(Icons.crisis_alert, color: Colors.grey[600]),
            ),
            const Gap(32),
            
            // Submit button
            ElevatedButton.icon(
              onPressed: _addDeveloper,
              icon: const Icon(Icons.person_add),
              label: const Text('Add Developer'),
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
            
            // Existing developers
            Text(
              'Existing Developers',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
            const Divider(height: 32),
            
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('developers')
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
                        'No developers added yet',
                        style: TextStyle(
                          fontSize: 16,
                          fontStyle: FontStyle.italic,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                  );
                }

                return GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 0.75,
                  ),
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    final data = docs[index].data() as Map<String, dynamic>;
                    Map<String, dynamic> socialMedia = {};
                    
                    if (data.containsKey('socialMedia')) {
                      socialMedia = data['socialMedia'] as Map<String, dynamic>;
                    }
                    
                    return Card(
                      elevation: 3,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          // Profile picture
                          Expanded(
                            flex: 3,
                            child: Stack(
                              children: [
                                Container(
                                  width: double.infinity,
                                  decoration: BoxDecoration(
                                    borderRadius: const BorderRadius.vertical(
                                      top: Radius.circular(12),
                                    ),
                                    image: DecorationImage(
                                      image: NetworkImage(data['profilePic'] ?? ''),
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                                Positioned(
                                  top: 8,
                                  right: 8,
                                  child: Row(
                                    children: [
                                      Container(
                                        decoration: BoxDecoration(
                                          color: Colors.white.withOpacity(0.8),
                                          shape: BoxShape.circle,
                                        ),
                                        child: IconButton(
                                          icon: const Icon(Icons.edit, color: Colors.blue, size: 18),
                                          constraints: const BoxConstraints(),
                                          padding: const EdgeInsets.all(4),
                                          onPressed: () {
                                            // Edit functionality would go here
                                          },
                                        ),
                                      ),
                                      const SizedBox(width: 4),
                                      Container(
                                        decoration: BoxDecoration(
                                          color: Colors.white.withOpacity(0.8),
                                          shape: BoxShape.circle,
                                        ),
                                        child: IconButton(
                                          icon: const Icon(Icons.delete, color: Colors.red, size: 18),
                                          constraints: const BoxConstraints(),
                                          padding: const EdgeInsets.all(4),
                                          onPressed: () async {
                                            // Show confirmation dialog
                                            final shouldDelete = await showDialog<bool>(
                                              context: context,
                                              builder: (context) => AlertDialog(
                                                title: const Text('Delete Developer'),
                                                content: const Text('Are you sure you want to delete this developer?'),
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
                                                    .collection('developers')
                                                    .doc(docs[index].id)
                                                    .delete();
                                                    
                                                ScaffoldMessenger.of(context).showSnackBar(
                                                  const SnackBar(content: Text('Developer deleted successfully')),
                                                );
                                              } catch (e) {
                                                ScaffoldMessenger.of(context).showSnackBar(
                                                  SnackBar(content: Text('Error deleting developer: $e')),
                                                );
                                              }
                                            }
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          
                          // Developer details
                          Expanded(
                            flex: 2,
                            child: Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    data['name'] ?? 'No Name',
                                    textAlign: TextAlign.center,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const Gap(4),
                                  Text(
                                    data['role'] ?? 'No Role',
                                    textAlign: TextAlign.center,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                  const Gap(4),
                                  Text(
                                    '${data['department']} • Year ${data['year']}',
                                    textAlign: TextAlign.center,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey[500],
                                    ),
                                  ),
                                  const Gap(8),
                                  // Social media icons
                                  if (socialMedia.isNotEmpty)
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        if (socialMedia.containsKey('github'))
                                          Icon(Icons.code, size: 18, color: Colors.grey[700]),
                                        if (socialMedia.containsKey('github') && 
                                            (socialMedia.containsKey('linkedin') || socialMedia.containsKey('twitter')))
                                          const SizedBox(width: 12),
                                        if (socialMedia.containsKey('linkedin'))
                                          Icon(Icons.work, size: 18, color: Colors.grey[700]),
                                        if (socialMedia.containsKey('linkedin') && socialMedia.containsKey('twitter'))
                                          const SizedBox(width: 12),
                                        if (socialMedia.containsKey('twitter'))
                                          Icon(Icons.crisis_alert, size: 18, color: Colors.grey[700]),
                                      ],
                                    ),
                                ],
                              ),
                            ),
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