import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/gestures.dart';
import 'package:aastu_map/core/colors.dart';
import 'package:aastu_map/pages/chat/chat_message_model.dart';
import 'package:aastu_map/pages/chat/openai_service.dart';
import 'package:aastu_map/pages/full_map/full_map_page.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:line_icons/line_icons.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart' as google_maps;
import 'package:cached_network_image/cached_network_image.dart';
import 'package:any_link_preview/any_link_preview.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

class ChatScreen extends StatefulWidget {
  final String apiKey;

  const ChatScreen({
    Key? key,
    required this.apiKey,
  }) : super(key: key);

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> with SingleTickerProviderStateMixin {
  final List<ChatMessage> _messages = [];
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isTyping = false;
  late OpenAIService _openAIService;
  late AnimationController _animationController;
  
  // Map to track if a message was copied
  final Map<int, bool> _copiedMessages = {};
  
  // Set to track completed animations for bot messages
  final Set<int> _completedAnimations = {};

  @override
  void initState() {
    super.initState();
    _openAIService = OpenAIService(apiKey: widget.apiKey);
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();
    
    // Add initial bot message
    _addMessage(ChatMessage.bot(
      "Hello! I'm AASTU Assistant. How can I help you with information about Addis Ababa Science and Technology University today?"));
    
    // Don't mark the initial message animation as complete to allow animation
    // We'll let it play out to enhance the user experience
  }
  
  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _addMessage(ChatMessage message) {
    setState(() {
      _messages.add(message);
    });
    _scrollToBottom();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }
  
  // Method to scroll as message grows
  void _followScrollWithAnimation(int messageIndex) {
    // Only auto-scroll if we're near the bottom already
    if (_scrollController.hasClients &&
        _scrollController.position.pixels > 
        _scrollController.position.maxScrollExtent - 250) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 100),
        curve: Curves.easeOut,
      );
    }
  }
  
  // Copy message text to clipboard with proper formatting
  void _copyToClipboard(String text, int messageIndex) {
    // Remove any markdown syntax for cleaner copy
    String cleanText = text;
    
    // Replace bold: **text** → text
    cleanText = cleanText.replaceAllMapped(
      RegExp(r'\*\*(.*?)\*\*'),
      (match) => match.group(1) ?? '',
    );
    
    // Replace italic: *text* → text
    cleanText = cleanText.replaceAllMapped(
      RegExp(r'\*(.*?)\*'),
      (match) => match.group(1) ?? '',
    );
    
    // Replace code: `text` → text
    cleanText = cleanText.replaceAllMapped(
      RegExp(r'`(.*?)`'),
      (match) => match.group(1) ?? '',
    );
    
    // Replace links: [text](url) → text (url)
    cleanText = cleanText.replaceAllMapped(
      RegExp(r'\[(.*?)\]\((.*?)\)'),
      (match) => '${match.group(1) ?? ''} (${match.group(2) ?? ''})',
    );
    
    Clipboard.setData(ClipboardData(text: cleanText)).then((_) {
      // Update state to show "Copied" indicator
      setState(() {
        _copiedMessages[messageIndex] = true;
      });
      
      // Reset the "Copied" indicator after 2 seconds
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) {
          setState(() {
            _copiedMessages[messageIndex] = false;
          });
        }
      });
      
      print('[LOG ChatScreen] ========= Copied message to clipboard: ${cleanText.substring(0, cleanText.length > 20 ? 20 : cleanText.length)}...');
    });
  }
  
  // Open URL in browser
  Future<void> _openUrl(String url) async {
    // Ensure URL has proper scheme
    String formattedUrl = url;
    if (!url.startsWith('http://') && !url.startsWith('https://')) {
      formattedUrl = 'https://$url';
    }
    
    final Uri uri = Uri.parse(formattedUrl);
    print('[LOG ChatScreen] ========= Opening URL: $formattedUrl');
    
    try {
      // First try external app mode
      bool launched = await launchUrl(
        uri, 
        mode: LaunchMode.externalApplication,
      );
      
      if (!launched) {
        // If that fails, try internal browser
        launched = await launchUrl(
          uri, 
          mode: LaunchMode.inAppWebView,
        );
        
        if (!launched) {
          // If that also fails, try platform default
          launched = await launchUrl(uri);
          
          if (!launched) {
            throw Exception('Could not launch URL');
          }
        }
      }
    } catch (e) {
      print('[LOG ChatScreen] ========= Error launching URL: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Could not open link: $url'),
            action: SnackBarAction(
              label: 'COPY',
              onPressed: () {
                Clipboard.setData(ClipboardData(text: url));
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('URL copied to clipboard')),
                );
              },
            ),
          ),
        );
      }
    }
  }
  
  // Extract domain from URL
  String _extractDomain(String url) {
    try {
      final Uri uri = Uri.parse(url);
      return uri.host;
    } catch (e) {
      print('[LOG URL_PARSE_ERROR] ========= Error parsing URL: $e');
      return url;
    }
  }
  
  // Navigate to full map page with location details
  void _navigateToMap(MapLocation location) {
    print('[LOG ChatScreen] ========= Navigating to map for: ${location.title}');
    
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FullMapPage(
          initialLocation: LatLng(location.latitude, location.longitude),
          initialPlace: {
            'id': 'location_${location.title.toLowerCase().replaceAll(' ', '_')}',
            'title': location.title,
            'latitude': location.latitude,
            'longitude': location.longitude,
            'type': 'office', // Default type
            'source': 'special',
          },
        ),
      ),
    );
  }
  
  // Check if message is a welcome or simple message that shouldn't have previews
  bool _isSimpleMessage(String text) {
    final lowerText = text.toLowerCase();
    
    // Check for welcome or greeting messages
    if (lowerText.contains("hello") || 
        lowerText.contains("hi") || 
        lowerText.contains("welcome") || 
        lowerText.contains("aastu assistant")) {
      return true;
    }
    
    // Check for simple responses
    if (lowerText.length < 100 && !lowerText.contains("http") && 
        !lowerText.contains("located") && !lowerText.contains("map")) {
      return true;
    }
    
    return false;
  }

  // Extract URLs from text - simple approach that only catches explicit URLs
  List<String> _extractUrls(String text) {
    // Simple regex to find URLs in text
    RegExp exp = RegExp(
      r'https?:\/\/(www\.)?[-a-zA-Z0-9@:%._\+~#=]{1,256}\.[a-zA-Z0-9()]{1,6}\b([-a-zA-Z0-9()@:%_\+.~#?&//=]*)',
      caseSensitive: false,
    );
    
    // Extract all URLs
    final matches = exp.allMatches(text).map((match) => match.group(0) ?? '').toList();
    
    // Only return the first URL to avoid duplicate previews
    final List<String> results = matches.isNotEmpty ? [matches.first] : [];
    
    return results;
  }

  // Process message text to handle emojis correctly
  String _processMessageText(String text) {
    // Convert common emoji shortcodes to actual emojis
    final emojiMap = {
      ':smile:': '😊',
      ':grin:': '😁',
      ':laughing:': '😆',
      ':joy:': '😂',
      ':rofl:': '🤣',
      ':smiley:': '😃',
      ':wink:': '😉',
      ':blush:': '😊',
      ':heart:': '❤️',
      ':thumbsup:': '👍',
      ':ok:': '👌',
      ':pray:': '🙏',
      ':clap:': '👏',
      ':thinking:': '🤔',
      ':check:': '✅',
      ':warning:': '⚠️',
      ':info:': 'ℹ️',
      ':star:': '⭐',
      ':sparkles:': '✨',
      ':rocket:': '🚀',
      ':campus:': '🏫',
      ':school:': '🏫',
      ':books:': '📚',
      ':book:': '📖',
      ':laptop:': '💻',
      ':computer:': '🖥️',
      ':phone:': '📱',
      ':email:': '📧',
      ':document:': '📄',
      ':calendar:': '📅',
      ':clock:': '🕒',
      ':world:': '🌍',
      ':location:': '📍',
      ':map:': '🗺️',
      ':pin:': '📌',
      ':link:': '🔗',
    };
    
    String processedText = text;
    emojiMap.forEach((shortcode, emoji) {
      processedText = processedText.replaceAll(shortcode, emoji);
    });
    
    return processedText;
  }

  Future<void> _handleSubmitted(String text) async {
    if (text.trim().isEmpty) return;
    
    _textController.clear();
    _addMessage(ChatMessage.user(text));
    
    setState(() {
      _isTyping = true;
    });
    
    try {
      final botResponse = await _openAIService.getCompletionWithEnhancements(text);
      
      if (mounted) {
        setState(() {
          _isTyping = false;
        });
        _addMessage(botResponse);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isTyping = false;
        });
        _addMessage(ChatMessage.bot(
          "I'm having trouble connecting. Please try again later."));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'AASTU Assistant',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.primary),
      ),
      body: Column(
        children: [
          Expanded(
            child: Container(
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/images/signup_bg.jpg'),
                  fit: BoxFit.cover,
                  opacity: 0.05,
                ),
              ),
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.all(16.0),
                itemCount: _messages.length + (_isTyping ? 1 : 0),
                itemBuilder: (context, index) {
                  if (index == _messages.length) {
                    // Show typing indicator
                    return _buildTypingIndicator();
                  }
                  
                  final message = _messages[index];
                  return _buildMessage(message, index);
                },
              ),
            ),
          ),
          _buildMessageComposer(),
        ],
      ),
    );
  }

  Widget _buildMessage(ChatMessage message, int index) {
    final isUser = message.type == MessageType.user;
    final bool copied = _copiedMessages[index] ?? false;
    final bool isAnimationCompleted = _completedAnimations.contains(index);
    
    // Check if this is the initial welcome message (index 0)
    final bool isInitialMessage = index == 0;
    
    // Check if the message is a simple text message (no links, no location references)
    final bool isSimple = _isSimpleMessage(message.text);
    
    // Extract URLs from message text ONLY if there are no predefined enhancements
    final List<String> extractedUrls = isUser ? <String>[] : _extractUrls(message.text);
    
    // Improved preview logic:
    // 1. Show location preview if message has location
    // 2. Show link preview if message has links or contains URL
    // 3. Don't show any preview for simple messages
    final bool hasLocation = message.location != null;
    final bool hasLinks = message.links != null && message.links!.isNotEmpty;
    final bool hasExtractedUrls = extractedUrls.isNotEmpty;
    
    // Only show link previews for non-simple messages
    final bool shouldShowExtractedLinks = !isSimple && hasExtractedUrls;
    
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isUser) _buildAvatar(),
          const SizedBox(width: 8),
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: isUser ? AppColors.primary : Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 5,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                children: [
                  isUser
                    ? Container(
                        constraints: BoxConstraints(
                          maxWidth: MediaQuery.of(context).size.width * 0.7,
                        ),
                        child: Text(
                          message.text,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            height: 1.5,
                          ),
                        ),
                      )
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Bot message with typewriter effect or markdown text if animation completed
                          isAnimationCompleted
                            ? Container(
                                constraints: BoxConstraints(
                                  maxWidth: MediaQuery.of(context).size.width * 0.7,
                                ),
                                child: _buildFormattedMessage(message.text),
                              )
                            : AnimatedTextKit(
                                animatedTexts: [
                                  TypewriterAnimatedText(
                                    _processMessageText(message.text),
                                    speed: const Duration(milliseconds: 15),
                                    textStyle: const TextStyle(color: Colors.black87),
                                  ),
                                ],
                                totalRepeatCount: 1,
                                displayFullTextOnTap: true,
                                stopPauseOnTap: true,
                                onFinished: () {
                                  // Mark this animation as complete
                                  setState(() {
                                    _completedAnimations.add(index);
                                  });
                                },
                                onNextBeforePause: (_, __) {
                                  // Auto-scroll during animation for long messages
                                  _followScrollWithAnimation(index);
                                },
                              ),
                          
                          // Only show previews when animation is complete and message is not simple
                          if (!isUser && isAnimationCompleted) ...[
                            // First priority: Show location preview if available
                            if (hasLocation)
                              _buildGoogleMapPreview(message.location!)
                            // Second priority: Show link previews from model
                            else if (hasLinks)
                              _buildLinkPreviewCards(message.links!)
                            // Third priority: Show extracted URLs if found and not a simple message
                            else if (shouldShowExtractedLinks)
                              _buildExtractedLinkPreviews(extractedUrls)
                          ],
                          
                          // Copy button for bot messages (except the initial welcome message)
                          if (!isUser && isAnimationCompleted && !isInitialMessage)
                            Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  // Show copied text or copy icon
                                  copied
                                      ? Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: Colors.green.withOpacity(0.1),
                                            borderRadius: BorderRadius.circular(4),
                                          ),
                                          child: const Text(
                                            'Copied',
                                            style: TextStyle(
                                              color: Colors.green,
                                              fontSize: 10,
                                            ),
                                          ),
                                        )
                                      : InkWell(
                                          onTap: () => _copyToClipboard(message.text, index),
                                          child: Icon(
                                            Icons.copy,
                                            size: 16,
                                            color: Colors.grey[600],
                                          ),
                                        ),
                                ],
                              ),
                            ),
                        ],
                      ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 8),
          if (isUser) const SizedBox(width: 30), // Space for avatar symmetry
        ],
      ),
    );
  }

  Widget _buildGoogleMapPreview(MapLocation location) {
    return Container(
      margin: const EdgeInsets.only(top: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          // Map preview header with location name
          Container(
            color: Colors.green.shade50,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              children: [
                Icon(Icons.location_on, color: Colors.red.shade800, size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    location.title,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: Colors.green.shade900,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          
          // Map preview
          SizedBox(
            height: 170,
            child: Stack(
              children: [
                // Use Flutter Map 
                FlutterMap(
                  options: MapOptions(
                    initialCenter: LatLng(location.latitude, location.longitude),
                    initialZoom: 16.5,
                    interactionOptions: const InteractionOptions(
                      flags: InteractiveFlag.none,
                    ),
                  ),
                  children: [
                    TileLayer(
                      urlTemplate: 'https://mt1.google.com/vt/lyrs=m&x={x}&y={y}&z={z}',
                      userAgentPackageName: 'com.gdsc.aastu_map',
                    ),
                    MarkerLayer(
                      markers: [
                        Marker(
                          width: 30,
                          height: 30,
                          point: LatLng(location.latitude, location.longitude),
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.red.withOpacity(0.7),
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.white,
                                width: 2,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.2),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: const Center(
                              child: Icon(
                                Icons.location_on,
                                color: Colors.white,
                                size: 18,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                
                // Overlay with slight gradient for better readability
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  height: 40,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(0.2),
                        ],
                      ),
                    ),
                  ),
                ),
                
                // Coordinates display
                Positioned(
                  bottom: 8,
                  right: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.8),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      '${location.latitude.toStringAsFixed(5)}, ${location.longitude.toStringAsFixed(5)}',
                      style: const TextStyle(
                        color: Colors.black87,
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
                
                // Transparent overlay to handle taps
                Positioned.fill(
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () => _navigateToMap(location),
                      splashColor: Colors.black12,
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // Open in map button
          InkWell(
            onTap: () => _navigateToMap(location),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                border: Border(top: BorderSide(color: Colors.grey.shade300)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.map, size: 16, color: Colors.green.shade700),
                  const SizedBox(width: 8),
                  Text(
                    "OPEN IN CAMPUS MAP",
                    style: TextStyle(
                      color: Colors.green.shade700,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Utility method to ensure link previews are returned as widgets, not a list
  Widget _buildLinkPreviewCards(List<LinkPreview> links) {
    if (links.isEmpty) return const SizedBox.shrink();
    
    final link = links.first;
    
    return Container(
      margin: const EdgeInsets.only(top: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          // Link preview header
          Container(
            color: Colors.blue.shade50,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            width: double.infinity,
            child: Row(
              children: [
                Icon(Icons.link, color: Colors.blue.shade800, size: 16),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _extractDomain(link.url),
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.blue.shade800,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          
          // Link content - use AnyLinkPreview
          AnyLinkPreview(
            link: link.url,
            displayDirection: UIDirection.uiDirectionHorizontal,
            cache: const Duration(hours: 24),
            backgroundColor: Colors.white,
            borderRadius: 0,
            removeElevation: true,
            bodyMaxLines: 3,
            titleStyle: const TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
              fontSize: 15,
            ),
            bodyStyle: const TextStyle(color: Colors.grey, fontSize: 12),
            errorBody: 'Could not load a preview for this link',
            errorTitle: 'Preview Unavailable',
            errorWidget: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Text(
                link.title,
                style: TextStyle(
                  color: Colors.blue.shade700,
                  fontSize: 12,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
          
          // Open link button
          InkWell(
            onTap: () => _openUrl(link.url),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                border: Border(top: BorderSide(color: Colors.grey.shade300)),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.open_in_new, size: 14, color: AppColors.primary),
                  SizedBox(width: 8),
                  Text(
                    "OPEN WEBSITE",
                    style: TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExtractedLinkPreviews(List<String> urls) {
    if (urls.isEmpty) return const SizedBox.shrink();
    
    // Convert string URLs to LinkPreview objects and use the existing method
    final linkPreviews = urls.map((url) => 
      LinkPreview(
        title: _extractDomain(url),
        url: url,
      )
    ).toList();
    
    return _buildLinkPreviewCards(linkPreviews);
  }

  Widget _buildTypingIndicator() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildAvatar(),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 5,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildDot(),
                const SizedBox(width: 4),
                _buildDot(delay: 300),
                const SizedBox(width: 4),
                _buildDot(delay: 600),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDot({int delay = 0}) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        final animation = (((_animationController.value * 1500) + delay) % 1500) / 1500;
        final size = 4 + 4 * (animation < 0.5 ? animation * 2 : (1 - animation) * 2);
        
        return Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.7),
            shape: BoxShape.circle,
          ),
        );
      },
    );
  }

  Widget _buildAvatar() {
    return const CircleAvatar(
      backgroundColor: AppColors.primary,
      radius: 15,
      child: Icon(
        LineIcons.robot,
        size: 18,
        color: Colors.white,
      ),
    );
  }

  Widget _buildMessageComposer() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(30),
                  color: Colors.grey[100],
                ),
                child: Row(
                  children: [
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextField(
                        controller: _textController,
                        minLines: 1,
                        maxLines: 4,
                        textCapitalization: TextCapitalization.sentences,
                        decoration: InputDecoration(
                          hintText: 'Ask about AASTU...',
                          hintStyle: TextStyle(color: Colors.grey[400]),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 10,
                          ),
                        ),
                        onSubmitted: _isTyping ? null : _handleSubmitted,
                        textInputAction: TextInputAction.send,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 8),
            Container(
              decoration: const BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: Icon(
                  _isTyping ? Icons.hourglass_top : Icons.send_rounded,
                  color: Colors.white,
                ),
                onPressed: _isTyping
                    ? null
                    : () => _handleSubmitted(_textController.text),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Process and format message text with clickable coordinates
  Widget _buildFormattedMessage(String text) {
    // Process emojis and other text formatting
    final processedText = _processMessageText(text);
    
    // Check for coordinate patterns in the text
    final coordRegex = RegExp(r'(\d+\.\d+)\s*,\s*(\d+\.\d+)|latitude\s+(\d+\.\d+)\s*,?\s*longitude\s+(\d+\.\d+)', caseSensitive: false);
    final matches = coordRegex.allMatches(processedText);
    
    if (matches.isEmpty) {
      // If no coordinates found, use regular markdown rendering
      return MarkdownBody(
        data: processedText,
        styleSheet: MarkdownStyleSheet(
          p: TextStyle(
            color: Colors.black87,
            fontSize: 14,
            height: 1.5,
          ),
          strong: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
          em: TextStyle(
            fontStyle: FontStyle.italic,
            color: Colors.black87,
          ),
          blockquote: TextStyle(
            color: Colors.black54,
            fontSize: 14,
            height: 1.5,
            fontStyle: FontStyle.italic,
          ),
          code: TextStyle(
            color: Colors.deepPurple,
            backgroundColor: Colors.grey.shade100,
            fontFamily: 'monospace',
            fontSize: 13,
          ),
          codeblockDecoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(4),
          ),
          blockSpacing: 8,
          listBullet: TextStyle(
            color: Colors.black87,
          ),
        ),
        onTapLink: (text, href, title) {
          if (href != null) _openUrl(href);
        },
      );
    }
    
    // When coordinates are found, build rich text with clickable spans
    final textSpans = <InlineSpan>[];
    int lastEnd = 0;
    
    for (final match in matches) {
      // Add text before the coordinate
      if (match.start > lastEnd) {
        final beforeText = processedText.substring(lastEnd, match.start);
        textSpans.add(_buildMarkdownSpan(beforeText));
      }
      
      // Extract coordinates from the match
      double? lat, lng;
      String coordText = match.group(0) ?? '';
      
      if (match.group(1) != null && match.group(2) != null) {
        // Direct format: 8.885, 38.811
        lat = double.tryParse(match.group(1) ?? '');
        lng = double.tryParse(match.group(2) ?? '');
      } else if (match.group(3) != null && match.group(4) != null) {
        // Latitude/longitude format: latitude 8.885, longitude 38.811
        lat = double.tryParse(match.group(3) ?? '');
        lng = double.tryParse(match.group(4) ?? '');
      }
      
      // Add the coordinate as a clickable span
      if (lat != null && lng != null) {
        textSpans.add(
          WidgetSpan(
            child: GestureDetector(
              onTap: () => _navigateToCoordinates(lat!, lng!, coordText),
              child: Text(
                coordText,
                style: TextStyle(
                  color: Colors.blue,
                  fontWeight: FontWeight.bold,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
          ),
        );
      } else {
        // If coordinate parsing failed, add as plain text
        textSpans.add(TextSpan(text: coordText));
      }
      
      lastEnd = match.end;
    }
    
    // Add any remaining text after the last coordinate
    if (lastEnd < processedText.length) {
      final afterText = processedText.substring(lastEnd);
      textSpans.add(_buildMarkdownSpan(afterText));
    }
    
    return RichText(
      text: TextSpan(
        style: const TextStyle(
          color: Colors.black87,
          fontSize: 14,
          height: 1.5,
        ),
        children: textSpans,
      ),
    );
  }
  
  // Helper to create text spans with basic markdown styling
  TextSpan _buildMarkdownSpan(String text) {
    // Process basic formatting
    // Bold: **text**
    final boldRegex = RegExp(r'\*\*(.*?)\*\*');
    // Italic: *text*
    final italicRegex = RegExp(r'\*(.*?)\*');
    // Links: [text](url)
    final linkRegex = RegExp(r'\[(.*?)\]\((.*?)\)');
    
    final textSpans = <InlineSpan>[];
    int lastEnd = 0;
    
    // First check for links
    final linkMatches = linkRegex.allMatches(text);
    for (final match in linkMatches) {
      // Add text before the link
      if (match.start > lastEnd) {
        textSpans.add(TextSpan(text: text.substring(lastEnd, match.start)));
      }
      
      // Add the link
      final linkText = match.group(1) ?? '';
      final linkUrl = match.group(2) ?? '';
      
      textSpans.add(
        TextSpan(
          text: linkText,
          style: TextStyle(
            color: Colors.blue,
            decoration: TextDecoration.underline,
          ),
          recognizer: TapGestureRecognizer()
            ..onTap = () => _openUrl(linkUrl),
        ),
      );
      
      lastEnd = match.end;
    }
    
    // If no links were found or there's remaining text
    if (textSpans.isEmpty) {
      return TextSpan(text: text);
    } else if (lastEnd < text.length) {
      textSpans.add(TextSpan(text: text.substring(lastEnd)));
    }
    
    return TextSpan(children: textSpans);
  }
  
  // Navigate to full map page with coordinates
  void _navigateToCoordinates(double lat, double lng, String coordText) {
    print('[LOG ChatScreen] ========= Navigating to coordinates: $lat, $lng');
    
    // Extract a title from the coordinates for better display
    String title = "Location";
    
    // Try to extract a more descriptive title
    final beforeTextRegex = RegExp(r'(?:the|aastu)\s+([^.,:;]+)(?=\s+(?:is|are|at)\s+located|.*?(?:latitude|coordinates))', caseSensitive: false);
    final beforeMatch = beforeTextRegex.firstMatch(coordText);
    
    if (beforeMatch != null && beforeMatch.group(1) != null) {
      title = beforeMatch.group(1)!.trim();
      // Capitalize title
      title = title.split(' ')
          .map((word) => word.isNotEmpty 
              ? word[0].toUpperCase() + word.substring(1) 
              : '')
          .join(' ');
    }
    
    // Create a custom place for the full map page
    final customPlace = {
      'id': 'chat_location_${lat}_${lng}',
      'title': title,
      'latitude': lat,
      'longitude': lng,
      'type': 'location',
      'source': 'special',
    };
    
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FullMapPage(
          initialLocation: LatLng(lat, lng),
          initialPlace: customPlace,
        ),
      ),
    );
  }
} 