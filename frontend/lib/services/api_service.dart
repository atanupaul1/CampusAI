/// Campus AI Assistant — API Service
///
/// HTTP client for all FastAPI backend endpoints.
/// Uses Dio for networking. The base URL and auth token are
/// configured at construction time.

import 'package:dio/dio.dart';
import '../models/event_model.dart';
import '../models/message_model.dart';

class ApiService {
  final Dio _dio;

  ApiService({required String baseUrl, String? accessToken})
      : _dio = Dio(BaseOptions(
          baseUrl: baseUrl,
          connectTimeout: const Duration(seconds: 15),
          receiveTimeout: const Duration(seconds: 60), // Increased for AI response
          headers: {
            'Content-Type': 'application/json',
            if (accessToken != null) 'Authorization': 'Bearer $accessToken',
          },
        ));

  /// Send a request with manual retry logic for resilience.
  Future<Response> _requestWithRetry(
    Future<Response> Function() request, {
    int maxRetries = 2,
  }) async {
    int attempts = 0;
    while (true) {
      try {
        return await request();
      } on DioException catch (e) {
        attempts++;
        final isRetryable = e.type != DioExceptionType.cancel &&
            e.type != DioExceptionType.badResponse;
        
        if (attempts > maxRetries || !isRetryable) {
          rethrow;
        }
        
        final delay = Duration(seconds: attempts * 2);
        print('API Error: ${e.message}. Retrying in ${delay.inSeconds}s (Attempt $attempts)...');
        await Future.delayed(delay);
      }
    }
  }

  /// Update the auth token (e.g. after login).
  void setAccessToken(String token) {
    _dio.options.headers['Authorization'] = 'Bearer $token';
  }

  // ----------------------------------------------------------------
  // Auth
  // ----------------------------------------------------------------

  /// Register a new user. Returns the auth response map.
  Future<Map<String, dynamic>> register({
    required String email,
    required String password,
    String? displayName,
  }) async {
    final response = await _dio.post('/auth/register', data: {
      'email': email,
      'password': password,
      if (displayName != null) 'display_name': displayName,
    });
    return response.data as Map<String, dynamic>;
  }

  /// Login with email and password. Returns the auth response map.
  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    final response = await _dio.post('/auth/login', data: {
      'email': email,
      'password': password,
    });
    return response.data as Map<String, dynamic>;
  }

  // ----------------------------------------------------------------
  // Events
  // ----------------------------------------------------------------

  /// Fetch a list of campus events with optional filters.
  Future<List<EventModel>> getEvents({
    String? category,
    DateTime? fromDate,
    DateTime? toDate,
  }) async {
    final params = <String, dynamic>{};
    if (category != null) params['category'] = category;
    if (fromDate != null) params['from_date'] = fromDate.toIso8601String().split('T')[0];
    if (toDate != null) params['to_date'] = toDate.toIso8601String().split('T')[0];

    final response = await _requestWithRetry(
      () => _dio.get('/events', queryParameters: params),
    );
    final list = response.data as List;
    return list.map((e) => EventModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  /// Get a single event by ID.
  Future<EventModel> getEvent(String id) async {
    final response = await _dio.get('/events/$id');
    return EventModel.fromJson(response.data as Map<String, dynamic>);
  }

  // ----------------------------------------------------------------
  // Chat
  // ----------------------------------------------------------------

  /// List all chat sessions for the current user.
  Future<List<ChatSession>> getSessions() async {
    final response = await _requestWithRetry(
      () => _dio.get('/chat/sessions'),
    );
    final list = response.data as List;
    return list.map((e) => ChatSession.fromJson(e as Map<String, dynamic>)).toList();
  }

  /// Create a new chat session.
  Future<ChatSession> createSession({String? title}) async {
    final response = await _dio.post('/chat/sessions', data: {
      if (title != null) 'title': title,
    });
    return ChatSession.fromJson(response.data as Map<String, dynamic>);
  }

  /// Get the message history for a session.
  Future<List<MessageModel>> getChatHistory(String sessionId) async {
    final response = await _requestWithRetry(
      () => _dio.get('/chat/history/$sessionId'),
    );
    final list = response.data as List;
    return list.map((e) => MessageModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  /// Send a message and get the AI reply.
  Future<Map<String, dynamic>> sendMessage({
    required String sessionId,
    required String message,
  }) async {
    final response = await _requestWithRetry(
      () => _dio.post('/chat', data: {
        'session_id': sessionId,
        'message': message,
      }),
    );
    return response.data as Map<String, dynamic>;
  }
}
