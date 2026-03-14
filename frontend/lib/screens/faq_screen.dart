import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class FAQScreen extends StatefulWidget {
  const FAQScreen({super.key});

  @override
  State<FAQScreen> createState() => _FAQScreenState();
}

class _FAQScreenState extends State<FAQScreen> {
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
      final data = await _supabase
          .from('campus_faqs')
          .select()
          .order('created_at', ascending: false);
      if (mounted) {
        setState(() {
          _faqs = List<Map<String, dynamic>>.from(data);
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'FAQs',
                        style: textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.w900,
                          fontSize: 32,
                        ),
                      ),
                      Text(
                        'Frequently Asked Questions',
                        style: textTheme.bodyMedium?.copyWith(
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.refresh_rounded),
                    onPressed: _fetchFAQs,
                    tooltip: 'Refresh FAQs',
                  ),
                ],
              ),
            ),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _faqs.isEmpty
                      ? const Center(child: Text('No FAQs found.'))
                      : RefreshIndicator(
                          onRefresh: _fetchFAQs,
                          child: ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          itemCount: _faqs.length,
                          itemBuilder: (context, index) {
                            final faq = _faqs[index];
                            return Theme(
                              data: Theme.of(context).copyWith(
                                dividerColor: Colors.transparent,
                              ),
                              child: Container(
                                margin: const EdgeInsets.only(bottom: 12),
                                decoration: BoxDecoration(
                                  color: Theme.of(context).colorScheme.surface,
                                  borderRadius: BorderRadius.circular(20),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(
                                          Theme.of(context).brightness ==
                                                  Brightness.dark
                                              ? 0.2
                                              : 0.04),
                                      blurRadius: 10,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: ExpansionTile(
                                  tilePadding: const EdgeInsets.symmetric(
                                      horizontal: 20, vertical: 8),
                                  title: Text(
                                    faq['question'] ?? '',
                                    style: textTheme.titleMedium?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.fromLTRB(
                                          20, 0, 20, 20),
                                      child: Text(
                                        faq['answer'] ?? '',
                                        style: textTheme.bodyMedium?.copyWith(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .onSurfaceVariant,
                                          height: 1.5,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
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
}
