// Placeholder model for conversation message
class ConversationMessage {
  final String id;
  final String content;
  final bool isUser;
  final DateTime timestamp;
  final MessageType type;

  ConversationMessage({
    required this.id,
    required this.content,
    required this.isUser,
    required this.timestamp,
    required this.type,
  });

  factory ConversationMessage.fromJson(Map<String, dynamic> json) {
    return ConversationMessage(
      id: json['id'],
      content: json['content'],
      isUser: json['isUser'],
      timestamp: DateTime.parse(json['timestamp']),
      type: MessageType.values.firstWhere(
        (e) => e.toString() == 'MessageType.${json['type']}',
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'content': content,
      'isUser': isUser,
      'timestamp': timestamp.toIso8601String(),
      'type': type.toString().split('.').last,
    };
  }
}

enum MessageType {
  text,
  audio,
}

// Placeholder model for conversation session
class ConversationSession {
  final String id;
  final DateTime startTime;
  final DateTime? endTime;
  final List<ConversationMessage> messages;
  final SessionStatus status;

  ConversationSession({
    required this.id,
    required this.startTime,
    this.endTime,
    required this.messages,
    required this.status,
  });

  factory ConversationSession.fromJson(Map<String, dynamic> json) {
    return ConversationSession(
      id: json['id'],
      startTime: DateTime.parse(json['startTime']),
      endTime: json['endTime'] != null ? DateTime.parse(json['endTime']) : null,
      messages: (json['messages'] as List)
          .map((m) => ConversationMessage.fromJson(m))
          .toList(),
      status: SessionStatus.values.firstWhere(
        (e) => e.toString() == 'SessionStatus.${json['status']}',
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'startTime': startTime.toIso8601String(),
      'endTime': endTime?.toIso8601String(),
      'messages': messages.map((m) => m.toJson()).toList(),
      'status': status.toString().split('.').last,
    };
  }
}

enum SessionStatus {
  active,
  completed,
  cancelled,
}

// Placeholder model for user profile
class UserProfile {
  final String id;
  final String name;
  final String email;
  final String languageLevel;
  final List<String> learningGoals;
  final Map<String, dynamic> preferences;

  UserProfile({
    required this.id,
    required this.name,
    required this.email,
    required this.languageLevel,
    required this.learningGoals,
    required this.preferences,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      languageLevel: json['languageLevel'],
      learningGoals: List<String>.from(json['learningGoals']),
      preferences: Map<String, dynamic>.from(json['preferences']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'languageLevel': languageLevel,
      'learningGoals': learningGoals,
      'preferences': preferences,
    };
  }
}
