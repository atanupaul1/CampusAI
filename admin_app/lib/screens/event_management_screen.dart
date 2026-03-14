import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';
import '../models/event_model.dart';
import 'event_form_screen.dart';

class EventManagementScreen extends StatefulWidget {
  const EventManagementScreen({super.key});

  @override
  State<EventManagementScreen> createState() => _EventManagementScreenState();
}

class _EventManagementScreenState extends State<EventManagementScreen> {
  final _supabase = Supabase.instance.client;
  bool _isLoading = true;
  List<EventModel> _events = [];

  @override
  void initState() {
    super.initState();
    _fetchEvents();
  }

  Future<void> _fetchEvents() async {
    try {
      final data = await _supabase
          .from('campus_events')
          .select()
          .order('start_time', ascending: false);
      
      setState(() {
        _events = (data as List).map((e) => EventModel.fromJson(e)).toList();
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Error fetching events: $e');
      setState(() => _isLoading = false);
    }
  }

  Future<void> _deleteEvent(String id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Theme.of(context).colorScheme.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 36),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Delete Event?',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  color: Theme.of(context).brightness == Brightness.dark 
                      ? Colors.white 
                      : const Color(0xFF1D1D1D),
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'This action cannot be undone.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18,
                  color: Theme.of(context).brightness == Brightness.dark 
                      ? Colors.white70 
                      : const Color(0xFF5A5A5A),
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 32),
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: Text(
                        'Cancel',
                        style: TextStyle(
                          fontSize: 18,
                          color: Theme.of(context).brightness == Brightness.dark 
                              ? Colors.white70 
                              : const Color(0xFF1D1D1D),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context, true),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFF17878),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      child: const Text(
                        'Delete',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );

    if (confirm == true) {
      await _supabase.from('campus_events').delete().eq('id', id);
      _fetchEvents();
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final cardBgColor = Theme.of(context).colorScheme.surface;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // Custom App Bar Header (Tab Mode)
            Padding(
              padding: const EdgeInsets.only(top: 24.0, bottom: 16.0, left: 24.0),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Manage Events',
                  style: textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: Theme.of(context).brightness == Brightness.dark 
                        ? Colors.white 
                        : Colors.black,
                    fontSize: 24,
                  ),
                ),
              ),
            ),
            
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _events.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.event_busy_rounded, size: 64, color: Colors.grey[400]),
                              const SizedBox(height: 16),
                              Text('No events found', style: textTheme.titleMedium),
                            ],
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.all(20),
                          itemCount: _events.length,
                          itemBuilder: (context, index) {
                            final event = _events[index];
                            final isExpired = event.startTime != null && event.startTime!.isBefore(DateTime.now());

                            return Container(
                              margin: const EdgeInsets.only(bottom: 16),
                              decoration: BoxDecoration(
                                color: cardBgColor,
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.04),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  onTap: () async {
                                    final result = await Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => EventFormScreen(event: event),
                                      ),
                                    );
                                    if (result == true) _fetchEvents();
                                  },
                                  borderRadius: BorderRadius.circular(20),
                                  child: Padding(
                                    padding: const EdgeInsets.all(16),
                                    child: Row(
                                      children: [
                                        // Date Box
                                        Container(
                                          width: 60,
                                          height: 70,
                                          decoration: BoxDecoration(
                                            color: isExpired 
                                                ? (Theme.of(context).brightness == Brightness.dark ? Colors.white12 : const Color(0xFFE1DCCF))
                                                : (Theme.of(context).brightness == Brightness.dark ? const Color(0xFF4A3F35) : const Color(0xFFDCC8B6)),
                                            borderRadius: BorderRadius.circular(16),
                                          ),
                                          child: Column(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              Text(
                                                event.startTime != null ? DateFormat('dd').format(event.startTime!) : '?',
                                                style: textTheme.titleLarge?.copyWith(
                                                  color: isExpired 
                                                      ? Colors.grey[500] 
                                                      : (Theme.of(context).brightness == Brightness.dark ? const Color(0xFFDCC8B6) : const Color(0xFF7A685A)),
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              Text(
                                                event.startTime != null ? DateFormat('MMM').format(event.startTime!) : 'N/A',
                                                style: textTheme.labelSmall?.copyWith(
                                                  color: isExpired 
                                                      ? Colors.grey[600] 
                                                      : (Theme.of(context).brightness == Brightness.dark ? const Color(0xFFA28C7B) : const Color(0xFFA28C7B)),
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        const SizedBox(width: 16),
                                        // Event Info
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Container(
                                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                                decoration: BoxDecoration(
                                                  color: Theme.of(context).brightness == Brightness.dark 
                                                      ? Colors.white.withOpacity(0.05) 
                                                      : const Color(0xFFF3EFE6),
                                                  borderRadius: BorderRadius.circular(8),
                                                ),
                                                child: Text(
                                                  event.category ?? 'General',
                                                  style: TextStyle(
                                                    color: Theme.of(context).brightness == Brightness.dark 
                                                        ? const Color(0xFFDCC8B6) 
                                                        : const Color(0xFF9E8A7B),
                                                    fontSize: 10,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(height: 6),
                                              Text(
                                                event.title,
                                                style: textTheme.titleMedium?.copyWith(
                                                  fontWeight: FontWeight.w800,
                                                  color: Theme.of(context).brightness == Brightness.dark 
                                                      ? Colors.white.withOpacity(0.9) 
                                                      : Colors.black87,
                                                ),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                              const SizedBox(height: 4),
                                              Row(
                                                children: [
                                                  Icon(Icons.location_on_outlined, 
                                                    size: 14, 
                                                    color: Theme.of(context).brightness == Brightness.dark 
                                                        ? Colors.white60 
                                                        : Colors.black54),
                                                  const SizedBox(width: 4),
                                                  Expanded(
                                                    child: Text(
                                                      event.location ?? 'Campus',
                                                      style: textTheme.bodySmall?.copyWith(
                                                        color: Theme.of(context).brightness == Brightness.dark 
                                                            ? Colors.white60 
                                                            : Colors.black54,
                                                      ),
                                                      maxLines: 1,
                                                      overflow: TextOverflow.ellipsis,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                        // Actions
                                        IconButton(
                                          icon: const Icon(Icons.delete_outline_rounded, color: Color(0xFF9E8A7B)),
                                          onPressed: () => _deleteEvent(event.id),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const EventFormScreen()),
          );
          if (result == true) _fetchEvents();
        },
        backgroundColor: Theme.of(context).brightness == Brightness.dark 
            ? const Color(0xFF4A3F35) // Darker variant
            : const Color(0xFFEAE5D9),
        elevation: 4,
        highlightElevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        label: Text('Add Event', 
          style: TextStyle(
            color: Theme.of(context).brightness == Brightness.dark 
                ? const Color(0xFFDCC8B6) 
                : Colors.black, 
            fontWeight: FontWeight.bold)),
        icon: Icon(Icons.add, 
          color: Theme.of(context).brightness == Brightness.dark 
                ? const Color(0xFFDCC8B6) 
                : Colors.black),
      ),
    );
  }
}
