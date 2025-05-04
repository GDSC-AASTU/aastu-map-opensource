enum MessageType { user, bot }

class MapLocation {
  final String title;
  final double latitude;
  final double longitude;

  MapLocation({
    required this.title,
    required this.latitude,
    required this.longitude,
  });
}

class LinkPreview {
  final String title;
  final String url;

  LinkPreview({
    required this.title,
    required this.url,
  });
}

class ChatMessage {
  final String text;
  final MessageType type;
  final DateTime timestamp;
  final MapLocation? location;
  final List<LinkPreview>? links;

  ChatMessage({
    required this.text,
    required this.type,
    DateTime? timestamp,
    this.location,
    this.links,
  }) : timestamp = timestamp ?? DateTime.now();

  factory ChatMessage.user(String text) {
    return ChatMessage(
      text: text,
      type: MessageType.user,
    );
  }

  factory ChatMessage.bot(
    String text, {
    MapLocation? location,
    List<LinkPreview>? links,
  }) {
    return ChatMessage(
      text: text,
      type: MessageType.bot,
      location: location,
      links: links,
    );
  }
} 