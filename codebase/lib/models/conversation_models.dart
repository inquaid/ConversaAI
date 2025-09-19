enum MessageType { user, assistant, system }

enum MessageStatus { sending, sent, error }

class ChatMessage {
  final String id;
  final String content;
  final MessageType type;
  final DateTime timestamp;
  final MessageStatus status;
  final double? confidence;
  final Map<String, dynamic>? metadata;

  ChatMessage({
    required this.id,
    required this.content,
    required this.type,
    required this.timestamp,
    this.status = MessageStatus.sent,
    this.confidence,
    this.metadata,
  });

  ChatMessage copyWith({
    String? id,
    String? content,
    MessageType? type,
    DateTime? timestamp,
    MessageStatus? status,
    double? confidence,
    Map<String, dynamic>? metadata,
  }) {
    return ChatMessage(
      id: id ?? this.id,
      content: content ?? this.content,
      type: type ?? this.type,
      timestamp: timestamp ?? this.timestamp,
      status: status ?? this.status,
      confidence: confidence ?? this.confidence,
      metadata: metadata ?? this.metadata,
    );
  }
}

class ConversationSession {
  final String id;
  final DateTime startTime;
  final List<ChatMessage> messages;
  final String title;
  final Map<String, dynamic>? metadata;

  ConversationSession({
    required this.id,
    required this.startTime,
    required this.messages,
    required this.title,
    this.metadata,
  });

  ConversationSession copyWith({
    String? id,
    DateTime? startTime,
    List<ChatMessage>? messages,
    String? title,
    Map<String, dynamic>? metadata,
  }) {
    return ConversationSession(
      id: id ?? this.id,
      startTime: startTime ?? this.startTime,
      messages: messages ?? List.from(this.messages),
      title: title ?? this.title,
      metadata: metadata ?? this.metadata,
    );
  }

  void addMessage(ChatMessage message) {
    messages.add(message);
  }

  ChatMessage? get lastMessage => messages.isNotEmpty ? messages.last : null;

  int get messageCount => messages.length;

  Duration get duration => DateTime.now().difference(startTime);
}
