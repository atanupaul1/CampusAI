import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../widgets/event_card.dart';
import '../providers/events_provider.dart';


class EventsScreen extends ConsumerStatefulWidget {
  const EventsScreen({super.key});

  @override
  ConsumerState<EventsScreen> createState() => _EventsScreenState();
}

class _EventsScreenState extends ConsumerState<EventsScreen> {
  static const _categories = ['All', 'Academic', 'Workshop', 'Sports', 'Music', 'Tech', 'Exam'];
  bool _isSearching = false;
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

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
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 16),
              child: _isSearching 
                ? Container(
                    height: 48, // Reduced height
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surfaceContainer,
                      borderRadius: BorderRadius.circular(24), // Rounded corners
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.search, size: 20, color: Colors.grey.shade600),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextField(
                            controller: _searchController,
                            autofocus: true,
                            style: const TextStyle(fontSize: 15),
                            decoration: InputDecoration(
                              hintText: 'Search events...',
                              border: InputBorder.none,
                              hintStyle: TextStyle(color: Colors.grey.shade500),
                              isDense: true,
                              contentPadding: EdgeInsets.zero,
                            ),
                            onChanged: (val) {
                              ref.read(eventsProvider.notifier).setSearchQuery(val);
                            },
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close, size: 20),
                          onPressed: () {
                            setState(() {
                              _isSearching = false;
                              _searchController.clear();
                            });
                            ref.read(eventsProvider.notifier).setSearchQuery('');
                          },
                        ),
                      ],
                    ),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Discover',
                            style: textTheme.headlineMedium?.copyWith(
                              fontWeight: FontWeight.w900,
                              fontSize: 32,
                            ),
                          ),
                          Text(
                            'University Campus Events',
                            style: textTheme.bodyMedium?.copyWith(
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.refresh_rounded),
                            onPressed: () {
                              ref.read(eventsProvider.notifier).loadEvents(
                                category: eventsState.selectedCategory,
                              );
                            },
                            tooltip: 'Refresh events',
                          ),
                          const SizedBox(width: 8),
                          InkWell(
                            onTap: () {
                              setState(() => _isSearching = true);
                            },
                            borderRadius: BorderRadius.circular(24),
                            child: Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.surfaceContainer,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.search, size: 24),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
            ),

            // Categories
            SizedBox(
              height: 50,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: _categories.length,
                itemBuilder: (context, index) {
                  final cat = _categories[index];
                  final isSelected = (eventsState.selectedCategory == null && cat == 'All') ||
                      eventsState.selectedCategory == cat;

                  return Padding(
                    padding: const EdgeInsets.only(right: 12),
                    child: ChoiceChip(
                      label: Text(
                        cat,
                        style: TextStyle(
                          color: isSelected 
                              ? Theme.of(context).colorScheme.onPrimary 
                              : Theme.of(context).colorScheme.onSurfaceVariant,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                      selected: isSelected,
                      onSelected: (_) {
                        ref.read(eventsProvider.notifier).loadEvents(
                          category: cat == 'All' ? null : cat,
                        );
                      },
                      selectedColor: Theme.of(context).colorScheme.primary,
                      backgroundColor: Theme.of(context).colorScheme.surface,
                      surfaceTintColor: Colors.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                        side: BorderSide(
                          color: isSelected ? Colors.transparent : Theme.of(context).dividerColor,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 16),

            // Events List
            Expanded(
              child: eventsState.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : eventsState.filteredEvents.isEmpty
                      ? _buildEmptyState()
                      : RefreshIndicator(
                          onRefresh: () => ref
                              .read(eventsProvider.notifier)
                              .loadEvents(category: eventsState.selectedCategory),
                          child: ListView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                            itemCount: eventsState.filteredEvents.length,
                            itemBuilder: (context, index) {
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 24),
                                child: EventCard(event: eventsState.filteredEvents[index]),
                              );
                            },
                          ),
                        ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.event_busy_rounded, size: 64, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          Text(
            'No events found',
            style: TextStyle(color: Colors.grey.shade500, fontSize: 16),
          ),
        ],
      ),
    );
  }
}
