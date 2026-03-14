import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/event_model.dart';
import '../providers/auth_provider.dart';

const Object _sentinel = Object();

class EventsState {
  final List<EventModel> events;
  final bool isLoading;
  final String? error;
  final String? selectedCategory;
  final String searchQuery;

  const EventsState({
    this.events = const [],
    this.isLoading = false,
    this.error,
    this.selectedCategory,
    this.searchQuery = '',
  });

  List<EventModel> get filteredEvents {
    if (searchQuery.isEmpty) return events;
    final query = searchQuery.toLowerCase();
    return events.where((event) {
      final title = event.title.toLowerCase();
      final location = (event.location ?? '').toLowerCase();
      final category = (event.category ?? '').toLowerCase();
      return title.contains(query) || 
             location.contains(query) || 
             category.contains(query);
    }).toList();
  }

  EventsState copyWith({
    List<EventModel>? events,
    bool? isLoading,
    String? error,
    Object? selectedCategory = _sentinel,
    String? searchQuery,
  }) {
    return EventsState(
      events: events ?? this.events,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      selectedCategory: selectedCategory == _sentinel 
          ? this.selectedCategory 
          : selectedCategory as String?,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }
}

class EventsNotifier extends StateNotifier<EventsState> {
  final Ref _ref;
  
  EventsNotifier(this._ref) : super(const EventsState());

  void setSearchQuery(String query) {
    state = state.copyWith(searchQuery: query);
  }

  Future<void> loadEvents({String? category}) async {
    state = state.copyWith(
      isLoading: true, 
      error: null, 
      selectedCategory: category,
    );

    try {
      final api = _ref.read(apiServiceProvider);
      final events = await api.getEvents(category: category);
      
      if (!mounted) return;
      
      state = state.copyWith(
        events: events, 
        isLoading: false,
      );
    } catch (e) {
      if (!mounted) return;
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }
}

final eventsProvider = StateNotifierProvider<EventsNotifier, EventsState>((ref) {
  return EventsNotifier(ref);
});
