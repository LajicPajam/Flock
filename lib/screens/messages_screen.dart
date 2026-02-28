import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/chat_message.dart';
import '../state/app_state.dart';
import '../theme/app_colors.dart';
import 'ui_shell.dart';

class MessagesScreen extends StatefulWidget {
  const MessagesScreen({
    super.key,
    required this.tripId,
    required this.tripDriverId,
  });

  final int tripId;
  final int tripDriverId;

  @override
  State<MessagesScreen> createState() => _MessagesScreenState();
}

class _MessagesScreenState extends State<MessagesScreen> {
  final _messageController = TextEditingController();
  late Future<_MessageViewData> _messagesFuture;
  int? _selectedParticipantId;
  bool _sending = false;

  @override
  void initState() {
    super.initState();
    _messagesFuture = _load();
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  Future<_MessageViewData> _load() async {
    final result = await context.read<AppState>().loadMessages(
          tripId: widget.tripId,
          participantId: _selectedParticipantId,
        );

    if (_selectedParticipantId == null && result.participantId != null) {
      _selectedParticipantId = result.participantId;
    }

    return _MessageViewData(
      messages: result.messages,
      acceptedRiders: result.acceptedRiders,
      participantId: result.participantId,
    );
  }

  Future<void> _refresh() async {
    setState(() {
      _messagesFuture = _load();
    });
  }

  Future<void> _send() async {
    if (_messageController.text.trim().isEmpty) {
      return;
    }

    setState(() {
      _sending = true;
    });

    try {
      await context.read<AppState>().sendMessage(
            tripId: widget.tripId,
            messageText: _messageController.text.trim(),
            receiverId: _selectedParticipantId,
          );
      _messageController.clear();
      await _refresh();
    } catch (error) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.toString().replaceFirst('Exception: ', ''))),
      );
    } finally {
      if (mounted) {
        setState(() {
          _sending = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentUserId = context.watch<AppState>().currentUser?.id;

    return UiShell(
      title: 'Messages',
      child: FutureBuilder<_MessageViewData>(
        future: _messagesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return ListView(
              children: [
                Text(snapshot.error.toString().replaceFirst('Exception: ', '')),
                const SizedBox(height: 12),
                OutlinedButton(
                  onPressed: _refresh,
                  child: const Text('Retry'),
                ),
              ],
            );
          }

          final data = snapshot.data!;
          final acceptedRiders = data.acceptedRiders;
          final isDriver = currentUserId == widget.tripDriverId;

          return Column(
            children: [
              if (isDriver && acceptedRiders.isNotEmpty)
                DropdownButtonFormField<int>(
                  initialValue: _selectedParticipantId,
                  decoration: const InputDecoration(
                    labelText: 'Accepted rider',
                    border: OutlineInputBorder(),
                  ),
                  items: acceptedRiders
                      .map(
                        (rider) => DropdownMenuItem<int>(
                          value: rider['rider_id'] as int,
                          child: Text(rider['rider_name'] as String),
                        ),
                      )
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedParticipantId = value;
                      _messagesFuture = _load();
                    });
                  },
                ),
              if (isDriver && acceptedRiders.isEmpty)
                const Text('Accept a rider request before messaging.'),
              const SizedBox(height: 12),
              Expanded(
                child: data.messages.isEmpty
                    ? const Center(child: Text('No messages yet.'))
                    : ListView.separated(
                        itemCount: data.messages.length,
                        separatorBuilder: (_, _) => const SizedBox(height: 8),
                        itemBuilder: (context, index) {
                          final message = data.messages[index];
                          final mine = message.senderId == currentUserId;
                          return _MessageBubble(
                            message: message,
                            mine: mine,
                          );
                        },
                      ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      decoration: const InputDecoration(
                        labelText: 'Message',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  FilledButton(
                    onPressed: _sending || (isDriver && _selectedParticipantId == null)
                        ? null
                        : _send,
                    child: Text(_sending ? '...' : 'Send'),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  const _MessageBubble({
    required this.message,
    required this.mine,
  });

  final ChatMessage message;
  final bool mine;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: mine ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 520),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: mine ? AppColors.secondaryGreen : AppColors.cardBackground,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.subtleBorder),
        ),
        child: Column(
          crossAxisAlignment:
              mine ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Text(
              message.senderName,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(message.messageText),
          ],
        ),
      ),
    );
  }
}

class _MessageViewData {
  _MessageViewData({
    required this.messages,
    required this.acceptedRiders,
    required this.participantId,
  });

  final List<ChatMessage> messages;
  final List<Map<String, dynamic>> acceptedRiders;
  final int? participantId;
}
