import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';
import '../models/event_model.dart';

class EventFormScreen extends StatefulWidget {
  final EventModel? event;
  const EventFormScreen({super.key, this.event});

  @override
  State<EventFormScreen> createState() => _EventFormScreenState();
}

class _EventFormScreenState extends State<EventFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _supabase = Supabase.instance.client;

  late TextEditingController _titleController;
  late TextEditingController _descController;
  late TextEditingController _locController;
  late TextEditingController _sourceController;
  DateTime? _startTime;
  String? _category;

  bool _isSaving = false;

  final List<String> _categories = ['Academic', 'Workshop', 'Cultural', 'Sports', 'Other'];

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.event?.title);
    _descController = TextEditingController(text: widget.event?.description);
    _locController = TextEditingController(text: widget.event?.location);
    _sourceController = TextEditingController(text: widget.event?.sourceUrl);
    _startTime = widget.event?.startTime;
    _category = widget.event?.category;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    _locController.dispose();
    _sourceController.dispose();
    super.dispose();
  }

  Future<void> _selectDateTime() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _startTime ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (date != null) {
      final time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(_startTime ?? DateTime.now()),
      );
      if (time != null) {
        setState(() {
          _startTime = DateTime(date.year, date.month, date.day, time.hour, time.minute);
        });
      }
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);
    try {
      final data = {
        'title': _titleController.text.trim(),
        'description': _descController.text.trim(),
        'location': _locController.text.trim(),
        'source_url': _sourceController.text.trim(),
        'start_time': _startTime?.toIso8601String(),
        'category': _category,
      };

      if (widget.event == null) {
        await _supabase.from('campus_events').insert(data);
      } else {
        await _supabase.from('campus_events').update(data).eq('id', widget.event!.id);
      }

      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.event == null ? 'Add Event' : 'Edit Event')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'Event Title'),
                validator: (v) => v!.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descController,
                decoration: const InputDecoration(labelText: 'Description'),
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _locController,
                decoration: const InputDecoration(labelText: 'Location'),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _category,
                decoration: const InputDecoration(labelText: 'Category'),
                items: _categories.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                onChanged: (v) => setState(() => _category = v),
              ),
              const SizedBox(height: 16),
              ListTile(
                title: const Text('Event Date & Time'),
                subtitle: Text(_startTime == null
                    ? 'Not selected'
                    : DateFormat('MMM dd, yyyy • hh:mm a').format(_startTime!)),
                trailing: const Icon(Icons.calendar_today),
                onTap: _selectDateTime,
                tileColor: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.3),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              const SizedBox(height: 32),
              FilledButton(
                onPressed: _isSaving ? null : _save,
                child: _isSaving ? const CircularProgressIndicator(color: Colors.white) : const Text('Save Event'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
