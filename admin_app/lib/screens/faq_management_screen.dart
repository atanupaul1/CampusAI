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
      builder: (context) => Dialog(
        backgroundColor: const Color(0xFFFBF9F4),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 36),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Delete FAQ?',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF1D1D1D),
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'This action cannot be undone.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18,
                  color: Color(0xFF5A5A5A),
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 32),
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text(
                        'Cancel',
                        style: TextStyle(
                          fontSize: 18,
                          color: Color(0xFF1D1D1D),
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
      await _supabase.from('campus_faqs').delete().eq('id', id);
      _fetchFAQs();
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    const scaffoldBgColor = Color(0xFFF8F7F2); // Soft warm cream
    const cardBgColor = Color(0xFFEFECE3); // Slightly darker rounded card

    return Scaffold(
      backgroundColor: scaffoldBgColor,
      body: SafeArea(
        child: Column(
          children: [
            // Custom App Bar Header (Centered)
            Padding(
              padding: const EdgeInsets.only(top: 20.0, bottom: 12.0),
              child: Center(
                child: Text(
                  'Manage FAQs',
                  style: textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: Colors.black,
                    fontSize: 22,
                  ),
                ),
              ),
            ),
            
            // List of FAQs
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _faqs.isEmpty
                      ? const Center(child: Text('No FAQs found.'))
                      : ListView.separated(
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                          itemCount: _faqs.length,
                          separatorBuilder: (context, index) => const SizedBox(height: 16),
                          itemBuilder: (context, index) {
                            final faq = _faqs[index];
                            return Container(
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
                                      MaterialPageRoute(builder: (context) => FAQFormScreen(faq: faq)),
                                    );
                                    if (result == true) _fetchFAQs();
                                  },
                                  borderRadius: BorderRadius.circular(20),
                                  child: Padding(
                                    padding: const EdgeInsets.all(20),
                                    child: Row(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                faq['question'] ?? 'No Question',
                                                maxLines: 2,
                                                overflow: TextOverflow.ellipsis,
                                                style: textTheme.titleMedium?.copyWith(
                                                  fontWeight: FontWeight.w800,
                                                  color: Colors.black87,
                                                ),
                                              ),
                                              const SizedBox(height: 8),
                                              Text(
                                                faq['answer'] ?? 'No Answer',
                                                maxLines: 2,
                                                overflow: TextOverflow.ellipsis,
                                                style: textTheme.bodyMedium?.copyWith(
                                                  color: Colors.black54,
                                                  height: 1.4,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        const SizedBox(width: 16),
                                        IconButton(
                                          icon: const Icon(Icons.delete_outline_rounded, color: Color(0xFF9E8A7B)),
                                          onPressed: () => _deleteFAQ(faq['id']),
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
            MaterialPageRoute(builder: (context) => const FAQFormScreen()),
          );
          if (result == true) _fetchFAQs();
        },
        backgroundColor: const Color(0xFFEAE5D9),
        elevation: 4,
        highlightElevation: 8,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        label: const Text('Add FAQ', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        icon: const Icon(Icons.add, color: Colors.black),
      ),
    );
  }
}
