import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:aastu_map/core/colors.dart';
import 'package:intl/intl.dart';

class ManageSuggestionsPage extends StatefulWidget {
  const ManageSuggestionsPage({Key? key}) : super(key: key);

  @override
  State<ManageSuggestionsPage> createState() => _ManageSuggestionsPageState();
}

class _ManageSuggestionsPageState extends State<ManageSuggestionsPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String _selectedFilter = 'all'; // 'all', 'pending', 'approved', 'rejected'
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        elevation: 0,
        title: const Text(
          "Manage Location Suggestions",
          style: TextStyle(
            color: Colors.white,
            fontSize: 18.0,
            fontWeight: FontWeight.w800,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Column(
        children: [
          _buildFilterChips(),
          Expanded(
            child: _buildSuggestionsList(),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChips() {
    return Container(
      padding: const EdgeInsets.all(8.0),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _buildFilterChip('All', 'all'),
            const SizedBox(width: 8),
            _buildFilterChip('Pending', 'pending'),
            const SizedBox(width: 8),
            _buildFilterChip('Approved', 'approved'),
            const SizedBox(width: 8),
            _buildFilterChip('Rejected', 'rejected'),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label, String value) {
    final bool isSelected = _selectedFilter == value;
    
    return FilterChip(
      label: Text(
        label,
        style: TextStyle(
          color: isSelected ? Colors.white : Colors.black,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      selected: isSelected,
      selectedColor: AppColors.primary,
      backgroundColor: Colors.grey[200],
      onSelected: (bool selected) {
        setState(() {
          _selectedFilter = value;
        });
      },
    );
  }

  Widget _buildSuggestionsList() {
    Query query = _firestore.collection('suggestions').orderBy('createdAt', descending: true);
    
    // Apply filter if not 'all'
    if (_selectedFilter != 'all') {
      query = query.where('status', isEqualTo: _selectedFilter);
    }
    
    return StreamBuilder<QuerySnapshot>(
      stream: query.snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }
        
        final suggestions = snapshot.data?.docs ?? [];
        
        if (suggestions.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.location_off, size: 64, color: Colors.grey),
                const SizedBox(height: 16),
                Text(
                  'No ${_selectedFilter == 'all' ? '' : _selectedFilter} suggestions found',
                  style: const TextStyle(fontSize: 18, color: Colors.grey),
                ),
              ],
            ),
          );
        }
        
        return ListView.builder(
          itemCount: suggestions.length,
          itemBuilder: (context, index) {
            final suggestion = suggestions[index];
            final data = suggestion.data() as Map<String, dynamic>;
            final String id = suggestion.id;
            final String name = data['locationName'] ?? 'Unknown';
            final String type = data['locationType'] ?? 'Unknown';
            final String description = data['description'] ?? 'No description';
            final String status = data['status'] ?? 'pending';
            final Timestamp createdAt = data['createdAt'] as Timestamp? ?? Timestamp.now();
            final String floor = data['floor'] ?? 'Not specified';
            final GeoPoint? coordinates = data['coordinates'] as GeoPoint?;
            
            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: ExpansionTile(
                title: Text(
                  name,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                  '$type • ${_getFormattedDate(createdAt)}',
                  style: const TextStyle(fontSize: 12),
                ),
                trailing: _buildStatusChip(status),
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Description:',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text(description),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Text(
                              'Floor: ',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            Text(floor),
                          ],
                        ),
                        const SizedBox(height: 8),
                        if (coordinates != null)
                          Text(
                            'Coordinates: ${coordinates.latitude.toStringAsFixed(6)}, ${coordinates.longitude.toStringAsFixed(6)}',
                            style: const TextStyle(fontSize: 12),
                          ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _buildActionButton(
                              'Approve',
                              Icons.check_circle,
                              Colors.green,
                              status != 'approved',
                              () => _updateSuggestionStatus(id, 'approved'),
                            ),
                            _buildActionButton(
                              'Reject',
                              Icons.cancel,
                              Colors.red,
                              status != 'rejected',
                              () => _updateSuggestionStatus(id, 'rejected'),
                            ),
                            _buildActionButton(
                              'Delete',
                              Icons.delete,
                              Colors.grey,
                              true,
                              () => _deleteSuggestion(id),
                            ),
                          ],
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
    );
  }

  Widget _buildStatusChip(String status) {
    Color chipColor;
    IconData iconData;
    
    switch (status) {
      case 'approved':
        chipColor = Colors.green;
        iconData = Icons.check_circle;
        break;
      case 'rejected':
        chipColor = Colors.red;
        iconData = Icons.cancel;
        break;
      case 'pending':
      default:
        chipColor = Colors.orange;
        iconData = Icons.pending;
        break;
    }
    
    return Chip(
      label: Text(
        status.capitalize(),
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
        ),
      ),
      backgroundColor: chipColor,
      avatar: Icon(
        iconData,
        color: Colors.white,
        size: 16,
      ),
    );
  }

  Widget _buildActionButton(
      String label, IconData icon, Color color, bool enabled, VoidCallback onPressed) {
    return ElevatedButton.icon(
      onPressed: enabled ? () {
        if (_isLoading) return;
        onPressed();
      } : null,
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        disabledBackgroundColor: Colors.grey.shade300,
      ),
      icon: Icon(icon, size: 16),
      label: Text(label),
    );
  }

  String _getFormattedDate(Timestamp timestamp) {
    final DateTime dateTime = timestamp.toDate();
    return DateFormat('MMM d, yyyy').format(dateTime);
  }

  Future<void> _updateSuggestionStatus(String id, String newStatus) async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      await _firestore.collection('suggestions').doc(id).update({
        'status': newStatus,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Suggestion $newStatus successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
      
      print('[LOG ManageSuggestions] ========= Suggestion status updated: $id -> $newStatus');
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update status: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
      
      print('[LOG ManageSuggestions] ========= Error updating suggestion status: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _deleteSuggestion(String id) async {
    // Show confirmation dialog
    final bool confirm = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Suggestion'),
        content: const Text('Are you sure you want to delete this suggestion? This action cannot be undone.'),
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
    ) ?? false;
    
    if (!confirm) return;
    
    setState(() {
      _isLoading = true;
    });
    
    try {
      await _firestore.collection('suggestions').doc(id).delete();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Suggestion deleted successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
      
      print('[LOG ManageSuggestions] ========= Suggestion deleted: $id');
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to delete suggestion: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
      
      print('[LOG ManageSuggestions] ========= Error deleting suggestion: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}

extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${substring(1)}";
  }
} 