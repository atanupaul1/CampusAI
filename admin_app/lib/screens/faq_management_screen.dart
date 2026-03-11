import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'faq_form_screen.dart';

class FAQManagementScreen extends StatefulWidget {
  const FAQManagementScreen({super.key});

  @override
  State<FAQManagementScreen> createState() => _FAQManagementScreenState();
}

class _FAQManagementScreenState extends State<FAQManagementScreen> {
  final _supabase = Supabase.instance.client;
  bool _isLoading = true;
  List<Map<String, dynamic>> _faqs = [];

  @override
  void initState() {
    super.initState();
    _fetchFAQs();
  }

  Future<void> _fetchFAQs() async {
    try {
      final data = await _supabase.from('campus_faqs').select().order('created_at', ascending: false);
      setState(() {
        _faqs = List<Map<String, dynamic>>.from(data);
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Error fetching FAQs: $e');
      setState(() => _isLoading = false);
    }
  }

  Future<void> _deleteFAQ(String id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete FAQ?'),
        content: const Text('This will remove this question from the AI knowledge base.'),
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
      await _supabase.from('campus_faqs').delete().eq('id', id);
      _fetchFAQs();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Manage FAQs')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _faqs.isEmpty
              ? const Center(child: Text('No FAQs found.'))
              : ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: _faqs.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final faq = _faqs[index];
                    return Card(
                      child: ListTile(
                        title: Text(faq['question'] ?? 'No Question',
                            maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text(faq['answer'] ?? 'No Answer', maxLines: 2, overflow: TextOverflow.ellipsis),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete_outline, color: Colors.red),
                          onPressed: () => _deleteFAQ(faq['id']),
                        ),
                        onTap: () async {
                          final result = await Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => FAQFormScreen(faq: faq)),
                          );
                          if (result == true) _fetchFAQs();
                        },
                      ),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const FAQFormScreen()),
          );
          if (result == true) _fetchFAQs();
        },
        label: const Text('Add FAQ'),
        icon: const Icon(Icons.add),
      ),
    );
  }
}
