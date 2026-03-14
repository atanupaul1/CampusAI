import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';
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

  final List<String> _categories = ['Academic', 'Workshop', 'Sports', 'Music', 'Tech', 'Exam', 'Other'];

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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final inputDecoration = InputDecoration(
      filled: true,
      fillColor: isDark ? Colors.white.withOpacity(0.05) : const Color(0xFFEBE6DC),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
      contentPadding: const EdgeInsets.all(20),
      labelStyle: TextStyle(color: isDark ? Colors.white60 : Colors.black54),
      floatingLabelBehavior: FloatingLabelBehavior.never,
    );

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
              child: Row(
                children: [
                  IconButton(
                    icon: Icon(Icons.arrow_back, 
                      color: isDark ? Colors.white : Colors.black87, 
                      size: 28),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 24.0),
              child: Text(
                widget.event == null ? 'Add Event' : 'Edit Event',
                style: GoogleFonts.playfairDisplay(
                  fontSize: 36,
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white : Colors.black,
                ),
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _titleController,
                        decoration: inputDecoration.copyWith(labelText: 'Event Title'),
                        validator: (v) => v!.isEmpty ? 'Required' : null,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _descController,
                        decoration: inputDecoration.copyWith(labelText: 'Description'),
                        maxLines: 4,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _locController,
                        decoration: inputDecoration.copyWith(labelText: 'Location'),
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        value: _category,
                        decoration: inputDecoration.copyWith(labelText: 'Category'),
                        items: _categories.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                        onChanged: (v) => setState(() => _category = v),
                      ),
                      const SizedBox(height: 16),
                      Container(
                        decoration: BoxDecoration(
                          color: isDark ? Colors.white.withOpacity(0.05) : const Color(0xFFEBE6DC),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                          title: Text('Event Date & Time', 
                            style: TextStyle(color: isDark ? Colors.white60 : Colors.black54, fontSize: 13)),
                          subtitle: Text(
                            _startTime == null
                                ? 'Not selected'
                                : DateFormat('MMM dd, yyyy • hh:mm a').format(_startTime!),
                            style: TextStyle(
                              color: isDark ? Colors.white : Colors.black87, 
                              fontSize: 16, 
                              fontWeight: FontWeight.w500),
                          ),
                          trailing: Icon(Icons.calendar_today_rounded, 
                            color: isDark ? Colors.white60 : Colors.black54),
                          onTap: _selectDateTime,
                        ),
                      ),
                      const SizedBox(height: 32),
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: FilledButton(
                          style: FilledButton.styleFrom(
                            backgroundColor: isDark ? const Color(0xFFEBE6DC) : const Color(0xFF2E2E2E),
                            foregroundColor: isDark ? Colors.black : Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          onPressed: _isSaving ? null : _save,
                          child: _isSaving
                              ? const SizedBox(
                                  height: 24,
                                  width: 24,
                                  child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                                )
                              : Text(
                                  widget.event == null ? 'Save Event' : 'Update Event',
                                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
