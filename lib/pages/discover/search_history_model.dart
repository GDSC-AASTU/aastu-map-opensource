import 'package:hive/hive.dart';

part 'search_history_model.g.dart';

@HiveType(typeId: 1)
class SearchHistoryItem {
  @HiveField(0)
  final String query;

  @HiveField(1)
  final DateTime timestamp;

  SearchHistoryItem({
    required this.query,
    required this.timestamp,
  });

  // Factory constructor to create from JSON
  factory SearchHistoryItem.fromJson(Map<String, dynamic> json) {
    return SearchHistoryItem(
      query: json['query'],
      timestamp: DateTime.parse(json['timestamp']),
    );
  }

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'query': query,
      'timestamp': timestamp.toIso8601String(),
    };
  }
} 