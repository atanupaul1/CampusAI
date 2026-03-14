import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:google_fonts/google_fonts.dart';

class FAQFormScreen extends StatefulWidget {
  final Map<String, dynamic>? faq;
  const FAQFormScreen({super.key, this.faq});

  @override
  State<FAQFormScreen> createState() => _FAQFormScreenState();
}

class _FAQFormScreenState extends State<FAQFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _supabase = Supabase.instance.client;

  late TextEditingController _questionController;
  late TextEditingController _answerController;
  String? _category;

  bool _isSaving = false;

  final List<String> _categories = ['Academic', 'Workshop', 'Cultural', 'Sports', 'Facilities', 'Admission', 'Exams', 'Hostel', 'Library', 'General'];

  @override
  void initState() {
    super.initState();
    _questionController = TextEditingController(text: widget.faq?['question']);
    _answerController = TextEditingController(text: widget.faq?['answer']);
    _category = widget.faq?['category'];
    // Ensure the current category exists in the list to prevent crash
    if (_category != null && !_categories.contains(_category)) {
      _categories.add(_category!);
    }
  }

  @override
  void dispose() {
    _questionController.dispose();
    _answerController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);
    try {
      final data = {
        'question': _questionController.text.trim(),
        'answer': _answerController.text.trim(),
        'category': _category,
      };

      if (widget.faq == null) {
        await _supabase.from('campus_faqs').insert(data);
      } else {
        await _supabase.from('campus_faqs').update(data).eq('id', widget.faq!['id']);
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
                widget.faq == null ? 'Add FAQ' : 'Edit FAQ',
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
                        controller: _questionController,
                        decoration: inputDecoration.copyWith(labelText: 'Question'),
                        maxLines: 2,
                        validator: (v) => v!.isEmpty ? 'Required' : null,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _answerController,
                        decoration: inputDecoration.copyWith(labelText: 'Answer'),
                        maxLines: 8,
                        validator: (v) => v!.isEmpty ? 'Required' : null,
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        value: _category,
                        decoration: inputDecoration.copyWith(labelText: 'Category'),
                        items: _categories.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                        onChanged: (v) => setState(() => _category = v),
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
                                  widget.faq == null ? 'Save FAQ' : 'Update FAQ',
                                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Note: The AI Assistant uses these FAQs to answer students instantly.',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 12, color: isDark ? Colors.white70 : Colors.black54),
                      ),
                      const SizedBox(height: 32),
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
