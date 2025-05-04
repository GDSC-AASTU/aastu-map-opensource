import 'package:aastu_map/core/colors.dart';
import 'package:aastu_map/data/models/place_model.dart';
import 'package:aastu_map/pages/admin/components/admin_form_field.dart';
import 'package:aastu_map/pages/admin/components/admin_scaffold.dart';
import 'package:aastu_map/pages/admin/components/image_url_input.dart';
import 'package:aastu_map/pages/admin/components/location_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';

class PlacesAdminPage extends StatefulWidget {
  const PlacesAdminPage({Key? key}) : super(key: key);

  @override
  State<PlacesAdminPage> createState() => _PlacesAdminPageState();
}

class _PlacesAdminPageState extends State<PlacesAdminPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _blockNoController = TextEditingController();
  final _servicesController = TextEditingController();
  
  List<String> _selectedImages = [];
  List<String> _services = [];
  late GeoLocation _location = GeoLocation(lat: 8.9806, lng: 38.7578); // Default AASTU location
  bool _isLoading = false;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _blockNoController.dispose();
    _servicesController.dispose();
    super.dispose();
  }

  void _addService() {
    if (_servicesController.text.isNotEmpty) {
      setState(() {
        _services.add(_servicesController.text);
        _servicesController.clear();
      });
    }
  }

  void _removeService(int index) {
    setState(() {
      _services.removeAt(index);
    });
  }

  Future<void> _addPlace() async {
    if (!_formKey.currentState!.validate() || _selectedImages.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all fields and select at least one image')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final place = PlaceModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: _titleController.text,
        description: _descriptionController.text,
        blockNo: _blockNoController.text,
        images: _selectedImages,
        services: _services,
        location: _location,
        reviews: [],
        createdBy: 'admin', // In a real app, this would be the current user's ID
      );

      await FirebaseFirestore.instance
          .collection('places')
          .doc(place.id)
          .set(place.toJson());

      _clearForm();
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Place added successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error adding place: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _clearForm() {
    _formKey.currentState?.reset();
    _titleController.clear();
    _descriptionController.clear();
    _blockNoController.clear();
    _servicesController.clear();
    setState(() {
      _selectedImages = [];
      _services = [];
      _location = GeoLocation(lat: 8.9806, lng: 38.7578);
    });
  }

  void _handleBackNavigation() {
    context.go('/admin/create_content');
  }

  @override
  Widget build(BuildContext context) {
    return AdminScaffold(
      title: 'Manage Places',
      isLoading: _isLoading,
      onBackPressed: _handleBackNavigation,
      body: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Title section
            Text(
              'Add New Place',
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
            ),
            const Gap(16),
            
            AdminFormField(
              label: 'Block Number',
              controller: _blockNoController,
            ),
            const Gap(16),
            
            AdminFormField(
              label: 'Description',
              controller: _descriptionController,
              maxLines: 4,
            ),
            const Gap(16),
            
            // Services section
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Services',
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
                        controller: _servicesController,
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
                          hintText: 'Enter a service',
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: _addService,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: const Text('Add'),
                    ),
                  ],
                ),
                if (_services.isNotEmpty) ...[
                  const Gap(8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _services.asMap().entries.map((entry) {
                      return Chip(
                        label: Text(entry.value),
                        backgroundColor: Colors.blue[50],
                        deleteIconColor: Colors.red,
                        onDeleted: () => _removeService(entry.key),
                      );
                    }).toList(),
                  ),
                ],
              ],
            ),
            const Gap(24),
            
            // Image uploader
            Text(
              'Place Images',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
            ),
            const Gap(8),
            ImageUrlInput(
              allowMultiple: true,
              initialImages: _selectedImages,
              onImagesUploaded: (urls) {
                setState(() {
                  _selectedImages = urls;
                });
              },
            ),
            const Gap(24),
            
            // Location picker
            Text(
              'Location',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
            ),
            const Gap(8),
            LocationPicker(
              initialLocation: _location,
              onLocationSelected: (location) {
                setState(() {
                  _location = location;
                });
              },
            ),
            const Gap(32),
            
            // Submit button
            ElevatedButton.icon(
              onPressed: _addPlace,
              icon: const Icon(Icons.add_location_alt),
              label: const Text('Add Place'),
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
            
            // Existing places
            Text(
              'Existing Places',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
            const Divider(height: 32),
            
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('places')
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
                        'No places added yet',
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
                          if (data['images'] != null && (data['images'] as List).isNotEmpty)
                            Container(
                              height: 150,
                              width: double.infinity,
                              decoration: BoxDecoration(
                                borderRadius: const BorderRadius.vertical(
                                  top: Radius.circular(8),
                                ),
                                image: DecorationImage(
                                  image: NetworkImage((data['images'] as List).first.toString()),
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
                                            title: const Text('Delete Place'),
                                            content: const Text('Are you sure you want to delete this place?'),
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
                                                .collection('places')
                                                .doc(docs[index].id)
                                                .delete();
                                                
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              const SnackBar(content: Text('Place deleted successfully')),
                                            );
                                          } catch (e) {
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              SnackBar(content: Text('Error deleting place: $e')),
                                            );
                                          }
                                        }
                                      },
                                    ),
                                  ],
                                ),
                                Text(
                                  'Block: ${data['blockNo'] ?? 'N/A'}',
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
                                if (data['services'] != null && (data['services'] as List).isNotEmpty) ...[
                                  const Gap(8),
                                  Wrap(
                                    spacing: 4,
                                    runSpacing: 4,
                                    children: (data['services'] as List).map((service) {
                                      return Chip(
                                        label: Text(
                                          service.toString(),
                                          style: const TextStyle(fontSize: 12),
                                        ),
                                        backgroundColor: Colors.grey[200],
                                        padding: EdgeInsets.zero,
                                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                      );
                                    }).toList(),
                                  ),
                                ],
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