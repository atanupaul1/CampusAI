import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

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

  final List<String> _categories = ['Admission', 'Exams', 'Hostel', 'Library', 'General'];

  @override
  void initState() {
    super.initState();
    _questionController = TextEditingController(text: widget.faq?['question']);
    _answerController = TextEditingController(text: widget.faq?['answer']);
    _category = widget.faq?['category'];
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
    return Scaffold(
      appBar: AppBar(title: Text(widget.faq == null ? 'Add FAQ' : 'Edit FAQ')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _questionController,
                decoration: const InputDecoration(labelText: 'Question'),
                maxLines: 2,
                validator: (v) => v!.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _answerController,
                decoration: const InputDecoration(labelText: 'Answer'),
                maxLines: 8,
                validator: (v) => v!.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _category,
                decoration: const InputDecoration(labelText: 'Category'),
                items: _categories.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                onChanged: (v) => setState(() => _category = v),
              ),
              const SizedBox(height: 32),
              FilledButton(
                onPressed: _isSaving ? null : _save,
                child: _isSaving ? const CircularProgressIndicator(color: Colors.white) : const Text('Save FAQ'),
              ),
              const SizedBox(height: 16),
              const Text(
                'Note: The AI Assistant uses these FAQs to answer students instantly.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
