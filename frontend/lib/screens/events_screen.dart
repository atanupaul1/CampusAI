/// Campus AI Assistant — Events Screen
///
/// Scrollable list of campus events with category filtering.
/// Pulls data from the FastAPI /events endpoint via the API service.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/event_model.dart';
import '../providers/auth_provider.dart';
import '../widgets/event_card.dart';

// --- Events State & Provider ---

class EventsState {
  final List<EventModel> events;
  final bool isLoading;
  final String? error;
  final String? selectedCategory;

  const EventsState({
    this.events = const [],
    this.isLoading = false,
    this.error,
    this.selectedCategory,
  });

  EventsState copyWith({
    List<EventModel>? events,
    bool? isLoading,
    String? error,
    String? selectedCategory,
  }) {
    return EventsState(
      events: events ?? this.events,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      selectedCategory: selectedCategory,
    );
  }
}

class EventsNotifier extends StateNotifier<EventsState> {
  final Ref _ref;

  EventsNotifier(this._ref) : super(const EventsState());

  Future<void> loadEvents({String? category}) async {
    state = state.copyWith(isLoading: true, error: null, selectedCategory: category);
    try {
      final api = _ref.read(apiServiceProvider);
      final events = await api.getEvents(category: category);
      state = state.copyWith(events: events, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }
}

final eventsProvider = StateNotifierProvider<EventsNotifier, EventsState>((ref) {
  return EventsNotifier(ref);
});

// --- Screen ---

class EventsScreen extends ConsumerStatefulWidget {
  const EventsScreen({super.key});

  @override
  ConsumerState<EventsScreen> createState() => _EventsScreenState();
}

class _EventsScreenState extends ConsumerState<EventsScreen> {
  static const _categories = ['All', 'Academic', 'Social', 'Sports', 'Workshop', 'Seminar'];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(eventsProvider.notifier).loadEvents();
    });
  }

  @override
  Widget build(BuildContext context) {
    final eventsState = ref.watch(eventsProvider);
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Campus Events',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
      body: Column(
        children: [
          // Category filter chips
          SizedBox(
            height: 50,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              itemCount: _categories.length,
              itemBuilder: (context, index) {
                final cat = _categories[index];
                final isSelected = (eventsState.selectedCategory == null && cat == 'All') ||
                    eventsState.selectedCategory == cat;

                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: FilterChip(
                    label: Text(cat),
                    selected: isSelected,
                    onSelected: (_) {
                      ref.read(eventsProvider.notifier).loadEvents(
                            category: cat == 'All' ? null : cat,
                          );
                    },
                    selectedColor: colorScheme.primaryContainer,
                    checkmarkColor: colorScheme.primary,
                  ),
                );
              },
            ),
          ),

          // Events list
          Expanded(
            child: eventsState.isLoading
                ? const Center(child: CircularProgressIndicator())
                : eventsState.error != null
                    ? Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.error_outline_rounded,
                                size: 48, color: colorScheme.error),
                            const SizedBox(height: 12),
                            Text(
                              'Failed to load events',
                              style: TextStyle(color: colorScheme.error),
                            ),
                            const SizedBox(height: 8),
                            FilledButton.tonal(
                              onPressed: () =>
                                  ref.read(eventsProvider.notifier).loadEvents(),
                              child: const Text('Retry'),
                            ),
                          ],
                        ),
                      )
                    : eventsState.events.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.event_busy_rounded,
                                    size: 64,
                                    color: colorScheme.onSurfaceVariant
                                        .withValues(alpha: 0.4)),
                                const SizedBox(height: 12),
                                Text(
                                  'No events found',
                                  style: TextStyle(
                                      color: colorScheme.onSurfaceVariant),
                                ),
                              ],
                            ),
                          )
                        : RefreshIndicator(
                            onRefresh: () => ref
                                .read(eventsProvider.notifier)
                                .loadEvents(
                                    category: eventsState.selectedCategory),
                            child: ListView.builder(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              itemCount: eventsState.events.length,
                              itemBuilder: (context, index) {
                                return EventCard(
                                  event: eventsState.events[index],
                                );
                              },
                            ),
                          ),
          ),
        ],
      ),
    );
  }
}
