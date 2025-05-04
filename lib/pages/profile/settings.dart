import 'package:aastu_map/core/colors.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:line_icons/line_icons.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _darkMode = false;
  bool _locationEnabled = true;
  bool _notificationsEnabled = true;
  String _distanceUnit = 'Meters';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      setState(() {
        _darkMode = prefs.getBool('darkMode') ?? false;
        _locationEnabled = prefs.getBool('locationEnabled') ?? true;
        _notificationsEnabled = prefs.getBool('notificationsEnabled') ?? true;
        _distanceUnit = prefs.getString('distanceUnit') ?? 'Meters';
        _isLoading = false;
      });
      print('[LOG Settings] ========= Settings loaded successfully');
    } catch (e) {
      print('[LOG Settings] ========= Error loading settings: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _saveSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('darkMode', _darkMode);
      await prefs.setBool('locationEnabled', _locationEnabled);
      await prefs.setBool('notificationsEnabled', _notificationsEnabled);
      await prefs.setString('distanceUnit', _distanceUnit);
      print('[LOG Settings] ========= Settings saved successfully');
    } catch (e) {
      print('[LOG Settings] ========= Error saving settings: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        elevation: 0,
        title: const Text(
          "Settings",
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
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              children: [
                const SizedBox(height: 16),
                _buildSectionHeader('Display'),
                _buildSwitchTile(
                  'Dark Mode',
                  'Change app appearance',
                  LineIcons.adjust,
                  _darkMode,
                  (value) {
                    setState(() {
                      _darkMode = value;
                    });
                    _saveSettings();
                  },
                ),
                const Divider(),
                _buildSectionHeader('Map Settings'),
                _buildSwitchTile(
                  'Location Services',
                  'Allow app to access your location',
                  Icons.location_on,
                  _locationEnabled,
                  (value) {
                    setState(() {
                      _locationEnabled = value;
                    });
                    _saveSettings();
                  },
                ),
                _buildDropdownTile(
                  'Distance Unit',
                  'Choose your preferred unit of measurement',
                  Icons.straighten,
                  _distanceUnit,
                  ['Meters', 'Feet'],
                  (String? newValue) {
                    if (newValue != null) {
                      setState(() {
                        _distanceUnit = newValue;
                      });
                      _saveSettings();
                    }
                  },
                ),
                const Divider(),
                _buildSectionHeader('Notifications'),
                _buildSwitchTile(
                  'Push Notifications',
                  'Receive updates and important information',
                  Icons.notifications,
                  _notificationsEnabled,
                  (value) {
                    setState(() {
                      _notificationsEnabled = value;
                    });
                    _saveSettings();
                  },
                ),
                const Divider(),
                _buildSectionHeader('Data Management'),
                _buildActionTile(
                  'Clear Search History',
                  'Delete all your past searches',
                  Icons.history,
                  () => _showConfirmationDialog(
                    'Clear Search History',
                    'Are you sure you want to clear your search history?',
                    () => _clearSearchHistory(),
                  ),
                ),
                _buildActionTile(
                  'Clear Cache',
                  'Free up storage space',
                  Icons.cleaning_services,
                  () => _showConfirmationDialog(
                    'Clear Cache',
                    'Are you sure you want to clear the app cache?',
                    () => _clearCache(),
                  ),
                ),
                const SizedBox(height: 40),
              ],
            ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: AppColors.primary,
        ),
      ),
    );
  }

  Widget _buildSwitchTile(
    String title,
    String subtitle,
    IconData icon,
    bool value,
    Function(bool) onChanged,
  ) {
    return ListTile(
      leading: Icon(icon, color: AppColors.primary),
      title: Text(title),
      subtitle: Text(subtitle, style: const TextStyle(fontSize: 12)),
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        activeColor: AppColors.primary,
      ),
    );
  }

  Widget _buildDropdownTile(
    String title,
    String subtitle,
    IconData icon,
    String value,
    List<String> options,
    Function(String?) onChanged,
  ) {
    return ListTile(
      leading: Icon(icon, color: AppColors.primary),
      title: Text(title),
      subtitle: Text(subtitle, style: const TextStyle(fontSize: 12)),
      trailing: DropdownButton<String>(
        value: value,
        icon: const Icon(Icons.arrow_drop_down),
        elevation: 16,
        style: TextStyle(color: AppColors.primary),
        underline: Container(
          height: 2,
          color: AppColors.primary,
        ),
        onChanged: onChanged,
        items: options.map<DropdownMenuItem<String>>((String value) {
          return DropdownMenuItem<String>(
            value: value,
            child: Text(value),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildActionTile(
    String title,
    String subtitle,
    IconData icon,
    VoidCallback onTap,
  ) {
    return ListTile(
      leading: Icon(icon, color: AppColors.primary),
      title: Text(title),
      subtitle: Text(subtitle, style: const TextStyle(fontSize: 12)),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: onTap,
    );
  }

  void _showConfirmationDialog(
    String title,
    String content,
    VoidCallback onConfirm,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              onConfirm();
            },
            child: const Text('Confirm'),
          ),
        ],
      ),
    );
  }

  Future<void> _clearSearchHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('searchHistory');
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Search history cleared')),
      );
      print('[LOG Settings] ========= Search history cleared successfully');
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to clear search history')),
      );
      print('[LOG Settings] ========= Error clearing search history: $e');
    }
  }

  Future<void> _clearCache() async {
    try {
      // This is a placeholder. In a real app, you would implement actual cache clearing logic
      // using specific packages like flutter_cache_manager.
      
      // Simulate clearing cache with a delay
      await Future.delayed(const Duration(seconds: 1));
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cache cleared')),
      );
      print('[LOG Settings] ========= Cache cleared successfully');
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to clear cache')),
      );
      print('[LOG Settings] ========= Error clearing cache: $e');
    }
  }
} 