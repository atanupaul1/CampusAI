/// Campus AI Assistant — Chat Provider (Riverpod)
///
/// Manages chat sessions and messages. Handles sending messages,
/// loading history, and tracking the "AI is typing" state.

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/message_model.dart';
import '../services/api_service.dart';
import '../providers/auth_provider.dart';

// --------------- Chat State ---------------

class ChatState {
  final List<ChatSession> sessions;
  final ChatSession? activeSession;
  final List<MessageModel> messages;
  final bool isLoading;
  final bool isSending;
  final String? error;

  const ChatState({
    this.sessions = const [],
    this.activeSession,
    this.messages = const [],
    this.isLoading = false,
    this.isSending = false,
    this.error,
  });

  ChatState copyWith({
    List<ChatSession>? sessions,
    ChatSession? activeSession,
    List<MessageModel>? messages,
    bool? isLoading,
    bool? isSending,
    String? error,
  }) {
    return ChatState(
      sessions: sessions ?? this.sessions,
      activeSession: activeSession ?? this.activeSession,
      messages: messages ?? this.messages,
      isLoading: isLoading ?? this.isLoading,
      isSending: isSending ?? this.isSending,
      error: error,
    );
  }
}

// --------------- Chat Notifier ---------------

class ChatNotifier extends StateNotifier<ChatState> {
  final ApiService _api;

  ChatNotifier(this._api) : super(const ChatState());

  /// Load all chat sessions for the current user.
  Future<void> loadSessions() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final sessions = await _api.getSessions();
      state = state.copyWith(sessions: sessions, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  /// Create a new chat session and set it as active.
  Future<void> createSession({String? title}) async {
    try {
      final session = await _api.createSession(title: title);
      state = state.copyWith(
        sessions: [session, ...state.sessions],
        activeSession: session,
        messages: [],
      );
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  /// Set the active session and load its history.
  Future<void> selectSession(ChatSession session) async {
    state = state.copyWith(activeSession: session, isLoading: true);
    try {
      final messages = await _api.getChatHistory(session.id);
      state = state.copyWith(messages: messages, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  /// Send a message and get the AI reply.
  Future<void> sendMessage(String message) async {
    if (state.activeSession == null) return;

    // Add the user message to the list immediately (optimistic)
    final userMsg = MessageModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      sessionId: state.activeSession!.id,
      role: MessageRole.user,
      content: message,
      createdAt: DateTime.now(),
    );

    state = state.copyWith(
      messages: [...state.messages, userMsg],
      isSending: true,
      error: null,
    );

    try {
      final response = await _api.sendMessage(
        sessionId: state.activeSession!.id,
        message: message,
      );

      final aiMsg = MessageModel(
        id: DateTime.now().millisecondsSinceEpoch.toString() + '_ai',
        sessionId: state.activeSession!.id,
        role: MessageRole.assistant,
        content: response['reply'] as String,
        createdAt: DateTime.now(),
      );

      state = state.copyWith(
        messages: [...state.messages, aiMsg],
        isSending: false,
      );
    } catch (e) {
      state = state.copyWith(
        isSending: false,
        error: 'Failed to get response: ${e.toString()}',
      );
    }
  }
}

// --------------- Provider ---------------

final chatProvider = StateNotifierProvider<ChatNotifier, ChatState>((ref) {
  final api = ref.watch(apiServiceProvider);
  return ChatNotifier(api);
});
