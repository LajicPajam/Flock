class ChatMessage {
  ChatMessage({
    required this.id,
    required this.tripId,
    required this.senderId,
    required this.receiverId,
    required this.messageText,
    required this.senderName,
    required this.receiverName,
    required this.createdAt,
  });

  final int id;
  final int tripId;
  final int senderId;
  final int receiverId;
  final String messageText;
  final String senderName;
  final String receiverName;
  final DateTime createdAt;

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      id: json['id'] as int,
      tripId: json['trip_id'] as int,
      senderId: json['sender_id'] as int,
      receiverId: json['receiver_id'] as int,
      messageText: json['message_text'] as String,
      senderName: json['sender_name'] as String? ?? 'Unknown',
      receiverName: json['receiver_name'] as String? ?? 'Unknown',
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }
}
