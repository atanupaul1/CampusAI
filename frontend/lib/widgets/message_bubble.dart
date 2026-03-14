import 'package:flutter/material.dart';
import '../models/message_model.dart';

class MessageBubble extends StatelessWidget {
  final MessageModel message;
  final VoidCallback? onSpeak;

  const MessageBubble({
    super.key,
    required this.message,
    this.onSpeak,
  });

  bool get _isUser => message.role == MessageRole.user;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Column(
        crossAxisAlignment: _isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          // Role Label
          Padding(
            padding: const EdgeInsets.only(bottom: 8, left: 45, right: 45),
            child: Text(
              _isUser ? 'YOU' : 'AI TUTOR',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.0,
                color: Colors.blueGrey.shade400,
              ),
            ),
          ),
          
          Row(
            mainAxisAlignment: _isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (!_isUser) _buildAvatar(false),
              
              const SizedBox(width: 8),
              
              Flexible(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: _isUser 
                        ? Theme.of(context).colorScheme.surfaceContainerLowest 
                        : Theme.of(context).colorScheme.surfaceContainer,
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(20),
                      topRight: const Radius.circular(20),
                      bottomLeft: Radius.circular(_isUser ? 20 : 4),
                      bottomRight: Radius.circular(_isUser ? 4 : 20),
                    ),
                    border: _isUser ? Border.all(color: Theme.of(context).dividerColor) : null,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(Theme.of(context).brightness == Brightness.dark ? 0.2 : 0.04),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        message.content,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurface,
                          fontSize: 15,
                          height: 1.5,
                        ),
                      ),
                      if (!_isUser && onSpeak != null) ...[
                        const SizedBox(height: 8),
                        GestureDetector(
                          onTap: onSpeak,
                           child: Icon(Icons.volume_up_rounded, size: 18, color: Theme.of(context).colorScheme.onSurfaceVariant),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              
              const SizedBox(width: 8),
              
              if (_isUser) _buildAvatar(true),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAvatar(bool isUser) {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: const Color(0xFFFD5D11).withOpacity(0.3), width: 2),
        image: DecorationImage(
          image: NetworkImage(isUser 
            ? 'https://api.dicebear.com/7.x/avataaars/png?seed=Alex' 
            : 'https://api.dicebear.com/7.x/bottts/png?seed=AI'),
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}
