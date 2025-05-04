import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter/foundation.dart';
import 'search_history_model.dart';

class SearchHistoryService {
  static const String _boxName = 'searchHistory';
  
  // Initialize Hive and open box
  static Future<void> init() async {
    await Hive.initFlutter();
    Hive.registerAdapter(SearchHistoryItemAdapter());
    await Hive.openBox<SearchHistoryItem>(_boxName);
  }
  
  // Get box
  static Box<SearchHistoryItem> _getBox() {
    return Hive.box<SearchHistoryItem>(_boxName);
  }
  
  // Add search query to history
  static Future<void> addQuery(String query) async {
    print('[LOG SearchHistory] ========= Adding query to history: $query');
    
    if (query.trim().isEmpty) {
      print('[LOG SearchHistory] ========= Query is empty, not adding to history');
      return;
    }
    
    final box = _getBox();
    print('[LOG SearchHistory] ========= Current history size: ${box.length}');
    
    // Check if query already exists and remove it (to add it again at the top)
    final existingItems = box.values.where((item) => item.query.toLowerCase() == query.toLowerCase()).toList();
    print('[LOG SearchHistory] ========= Found ${existingItems.length} existing items with the same query');
    
    for (var item in existingItems) {
      final key = box.keys.firstWhere((k) => box.get(k) == item, orElse: () => null);
      if (key != null) {
        print('[LOG SearchHistory] ========= Removing existing item with key: $key');
        await box.delete(key);
      }
    }
    
    // Add new search item
    print('[LOG SearchHistory] ========= Adding new search item');
    final newItem = SearchHistoryItem(
      query: query.trim(),
      timestamp: DateTime.now(),
    );
    await box.add(newItem);
    print('[LOG SearchHistory] ========= New item added, new history size: ${box.length}');
    
    // Keep only the most recent 10 searches
    if (box.length > 10) {
      print('[LOG SearchHistory] ========= History size exceeds limit, pruning old items');
      final keys = box.keys.toList();
      keys.sort((a, b) {
        final itemA = box.get(a);
        final itemB = box.get(b);
        if (itemA == null || itemB == null) return 0;
        return itemB.timestamp.compareTo(itemA.timestamp);
      });
      
      for (int i = 10; i < keys.length; i++) {
        print('[LOG SearchHistory] ========= Removing old item with key: ${keys[i]}');
        await box.delete(keys[i]);
      }
      print('[LOG SearchHistory] ========= After pruning, history size: ${box.length}');
    }
    
    // Refresh the history notifier
    refreshHistoryNotifier();
  }
  
  // Remove a specific query from history
  static Future<void> removeQuery(String query) async {
    print('[LOG SearchHistory] ========= Removing query from history: $query');
    
    final box = _getBox();
    final keysToDelete = <dynamic>[];
    
    for (final key in box.keys) {
      final item = box.get(key);
      if (item != null && item.query.toLowerCase() == query.toLowerCase()) {
        print('[LOG SearchHistory] ========= Found matching item with key: $key');
        keysToDelete.add(key);
      }
    }
    
    print('[LOG SearchHistory] ========= Found ${keysToDelete.length} items to delete');
    
    for (final key in keysToDelete) {
      print('[LOG SearchHistory] ========= Deleting item with key: $key');
      await box.delete(key);
    }
    
    print('[LOG SearchHistory] ========= After deletion, history size: ${box.length}');
    
    // Refresh the history notifier
    refreshHistoryNotifier();
  }
  
  // Clear all search history
  static Future<void> clearHistory() async {
    print('[LOG SearchHistory] ========= Clearing all search history');
    
    final box = _getBox();
    print('[LOG SearchHistory] ========= Current history size before clearing: ${box.length}');
    
    await box.clear();
    
    print('[LOG SearchHistory] ========= History cleared, new size: ${box.length}');
    
    // Refresh the history notifier
    refreshHistoryNotifier();
  }
  
  // Get all search history items, sorted by timestamp (newest first)
  static List<SearchHistoryItem> getSearchHistory() {
    final box = _getBox();
    final items = box.values.toList();
    items.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return items;
  }
  
  // Value notifier to listen for changes in search history
  static final ValueNotifier<List<SearchHistoryItem>> historyNotifier = 
      ValueNotifier<List<SearchHistoryItem>>([]);
  
  // Update the notifier with latest data
  static void refreshHistoryNotifier() {
    historyNotifier.value = getSearchHistory();
  }
  
  // Listen for changes in the box and update the notifier
  static void setupListener() {
    final box = _getBox();
    box.listenable().addListener(() {
      refreshHistoryNotifier();
    });
    refreshHistoryNotifier();
  }
} 