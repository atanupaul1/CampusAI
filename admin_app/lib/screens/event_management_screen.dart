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
      builder: (context) => AlertDialog(
        title: const Text('Delete Event?'),
        content: const Text('This action cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(context, true), 
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await _supabase.from('campus_events').delete().eq('id', id);
      _fetchEvents();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Manage Events')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _events.isEmpty
              ? const Center(child: Text('No events found.'))
              : ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: _events.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final event = _events[index];
                    return Card(
                      child: ListTile(
                        title: Text(event.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text(
                          event.startTime != null 
                              ? DateFormat('MMM dd, yyyy • hh:mm a').format(event.startTime!)
                              : 'No date',
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete_outline, color: Colors.red),
                          onPressed: () => _deleteEvent(event.id),
                        ),
                        onTap: () async {
                          final result = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => EventFormScreen(event: event),
                            ),
                          );
                          if (result == true) _fetchEvents();
                        },
                      ),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const EventFormScreen()),
          );
          if (result == true) _fetchEvents();
        },
        label: const Text('Add Event'),
        icon: const Icon(Icons.add),
      ),
    );
  }
}
