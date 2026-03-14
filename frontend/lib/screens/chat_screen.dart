import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/chat_provider.dart';
import '../services/tts_service.dart';
import '../widgets/message_bubble.dart';
import '../widgets/typing_indicator.dart';

class ChatScreen extends ConsumerStatefulWidget {
  const ChatScreen({super.key});

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final _messageCtrl = TextEditingController();
  final _scrollCtrl = ScrollController();
  final _tts = TtsService();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final chatState = ref.read(chatProvider);
      if (chatState.activeSession == null) {
        ref.read(chatProvider.notifier).createSession(title: 'New Chat');
      }
    });
  }

  @override
  void dispose() {
    _messageCtrl.dispose();
    _scrollCtrl.dispose();
    _tts.dispose();
    super.dispose();
  }

  void _sendMessage() {
    final text = _messageCtrl.text.trim();
    if (text.isEmpty) return;

    ref.read(chatProvider.notifier).sendMessage(text);
    _messageCtrl.clear();

    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollCtrl.hasClients) {
        _scrollCtrl.animateTo(
          _scrollCtrl.position.maxScrollExtent + 80,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final chatState = ref.watch(chatProvider);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.surface,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Theme.of(context).colorScheme.onSurface),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'New Chat',
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurface,
            fontWeight: FontWeight.w900,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.more_vert, color: Theme.of(context).colorScheme.onSurface),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          // Messages List
          Expanded(
            child: ListView.builder(
              controller: _scrollCtrl,
              padding: const EdgeInsets.symmetric(vertical: 20),
              itemCount: chatState.messages.length + (chatState.isSending ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == chatState.messages.length && chatState.isSending) {
                  return const TypingIndicator();
                }
                final msg = chatState.messages[index];
                return MessageBubble(
                  message: msg,
                  onSpeak: msg.role.name == 'assistant' ? () => _tts.speak(msg.content) : null,
                );
              },
            ),
          ),

          // Input Bar
          Container(
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              border: Border(top: BorderSide(color: Theme.of(context).dividerColor)),
            ),
            child: SafeArea(
              child: Row(
                children: [
                  // Capsule Input
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surfaceContainerLow,
                        borderRadius: BorderRadius.circular(30),
                        border: Border.all(color: Theme.of(context).dividerColor),
                      ),
                      child: Row(
                        children: [
                          const SizedBox(width: 8),
                          IconButton(
                            icon: const Icon(Icons.add_circle, color: Color(0xFFFD5D11), size: 28),
                            onPressed: () {},
                          ),
                          Expanded(
                            child: TextField(
                              controller: _messageCtrl,
                              decoration: const InputDecoration(
                                hintText: 'Ask anything...',
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.symmetric(horizontal: 12),
                                fillColor: Colors.transparent,
                              ),
                              onSubmitted: (_) => _sendMessage(),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Orange Send
                  GestureDetector(
                    onTap: _sendMessage,
                    child: Container(
                      width: 50,
                      height: 50,
                      decoration: const BoxDecoration(
                        color: Color(0xFFFD5D11),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.arrow_upward_rounded, color: Colors.white, size: 28),
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
}
