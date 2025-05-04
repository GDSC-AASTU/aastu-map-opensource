import 'package:aastu_map/core/colors.dart';
import 'package:aastu_map/pages/admin/components/admin_form_field.dart';
import 'package:aastu_map/pages/admin/components/admin_scaffold.dart';
import 'package:aastu_map/pages/admin/components/image_url_input.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';

class AboutAdminPage extends StatefulWidget {
  const AboutAdminPage({Key? key}) : super(key: key);

  @override
  State<AboutAdminPage> createState() => _AboutAdminPageState();
}

class _AboutAdminPageState extends State<AboutAdminPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  String _imageUrl = '';
  bool _isLoading = false;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _addContent() async {
    if (!_formKey.currentState!.validate() || _imageUrl.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all fields and select an image')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      await FirebaseFirestore.instance.collection('about').add({
        'title': _titleController.text,
        'description': _descriptionController.text,
        'imageUrl': _imageUrl,
        'createdAt': FieldValue.serverTimestamp(),
      });

      _clearForm();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Content added successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error adding content: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _clearForm() {
    _formKey.currentState?.reset();
    _titleController.clear();
    _descriptionController.clear();
    setState(() {
      _imageUrl = '';
    });
  }

  void _handleBackNavigation() {
    // Use context.go instead of context.pop to ensure we go back to the admin dashboard
    context.go('/admin/create_content');
  }

  @override
  Widget build(BuildContext context) {
    return AdminScaffold(
      title: 'Manage About AASTU',
      isLoading: _isLoading,
      onBackPressed: _handleBackNavigation,
      body: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Title section
            Text(
              'Add New Content',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
            const Divider(height: 32),
            
            // Form fields
            AdminFormField(
              label: 'Title',
              controller: _titleController,
              hintText: 'e.g. About AASTU, Our History',
            ),
            const Gap(16),
            
            AdminFormField(
              label: 'Description',
              controller: _descriptionController,
              maxLines: 5,
              hintText: 'Detailed information about AASTU...',
            ),
            const Gap(24),
            
            // Image uploader
            Text(
              'Image',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
            ),
            const Gap(8),
            ImageUrlInput(
              allowMultiple: false,
              initialImages: _imageUrl.isEmpty ? [] : [_imageUrl],
              onImagesUploaded: (urls) {
                setState(() {
                  _imageUrl = urls.isNotEmpty ? urls.first : '';
                });
              },
            ),
            const Gap(32),
            
            // Submit button
            ElevatedButton.icon(
              onPressed: _addContent,
              icon: const Icon(Icons.add_circle),
              label: const Text('Add Content'),
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
            
            // Existing content
            Text(
              'Existing Content',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
            const Divider(height: 32),
            
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('about')
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
                        'No content added yet',
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
                          // Image
                          if (data['imageUrl'] != null)
                            Container(
                              height: 200,
                              width: double.infinity,
                              decoration: BoxDecoration(
                                borderRadius: const BorderRadius.vertical(
                                  top: Radius.circular(8),
                                ),
                                image: DecorationImage(
                                  image: NetworkImage(data['imageUrl']),
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                          
                          Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        data['title'] ?? 'No Title',
                                        style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
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
                                            title: const Text('Delete Content'),
                                            content: const Text('Are you sure you want to delete this content?'),
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
                                                .collection('about')
                                                .doc(docs[index].id)
                                                .delete();
                                                
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              const SnackBar(content: Text('Content deleted successfully')),
                                            );
                                          } catch (e) {
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              SnackBar(content: Text('Error deleting content: $e')),
                                            );
                                          }
                                        }
                                      },
                                    ),
                                  ],
                                ),
                                const Gap(8),
                                Text(
                                  data['description'] ?? 'No description',
                                  maxLines: 3,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    color: Colors.grey[800],
                                  ),
                                ),
                              ],
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