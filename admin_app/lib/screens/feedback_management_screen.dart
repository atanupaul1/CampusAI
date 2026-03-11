import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';

class FeedbackManagementScreen extends StatefulWidget {
  const FeedbackManagementScreen({super.key});

  @override
  State<FeedbackManagementScreen> createState() => _FeedbackManagementScreenState();
}

class _FeedbackManagementScreenState extends State<FeedbackManagementScreen> {
  final _supabase = Supabase.instance.client;
  bool _isLoading = true;
  String? _errorMessage;
  List<Map<String, dynamic>> _feedbacks = [];

  @override
  void initState() {
    super.initState();
    _fetchFeedback();
  }

  Future<void> _fetchFeedback() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final data = await _supabase
          .from('user_feedback')
          .select('*, users(display_name, email)') 
          .order('created_at', ascending: false);
      
      setState(() {
        _feedbacks = List<Map<String, dynamic>>.from(data);
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Error fetching feedback: $e');
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _toggleResolve(String id, bool currentStatus) async {
    await _supabase.from('user_feedback').update({'is_resolved': !currentStatus}).eq('id', id);
    _fetchFeedback();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('User Feedback'),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _fetchFeedback),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error_outline_rounded, color: Colors.red, size: 48),
                        const SizedBox(height: 16),
                        Text('Error: $_errorMessage', textAlign: TextAlign.center, style: const TextStyle(color: Colors.red)),
                        const SizedBox(height: 16),
                        ElevatedButton(onPressed: _fetchFeedback, child: const Text('Try Again')),
                      ],
                    ),
                  ),
                )
              : _feedbacks.isEmpty
                  ? const Center(child: Text('No feedback received yet.'))
                  : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _feedbacks.length,
                  itemBuilder: (context, index) {
                    final fb = _feedbacks[index];
                    final user = fb['users'];
                    final isResolved = fb['is_resolved'] ?? false;
                    final category = fb['category'] ?? 'General';
                    final rating = fb['rating'] ?? 0;

                    return Card(
                      margin: const EdgeInsets.only(bottom: 16),
                      clipBehavior: Clip.antiAlias,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                        side: BorderSide(
                          color: isResolved ? Colors.green.withOpacity(0.3) : colorScheme.outlineVariant,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ListTile(
                            leading: CircleAvatar(
                              backgroundColor: _getCategoryColor(category).withOpacity(0.1),
                              child: Icon(_getCategoryIcon(category), color: _getCategoryColor(category), size: 20),
                            ),
                            title: Text(user is Map ? (user['display_name'] ?? 'Anonymous') : 'Anonymous'),
                            subtitle: Text(fb['created_at'] != null 
                                ? DateFormat('MMM dd, yyyy • hh:mm a').format(DateTime.parse(fb['created_at']))
                                : 'Unknown date'),
                            trailing: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: isResolved ? Colors.green.withOpacity(0.1) : Colors.orange.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                isResolved ? 'Resolved' : 'Pending',
                                style: TextStyle(
                                  color: isResolved ? Colors.green : Colors.orange,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: List.generate(5, (i) => Icon(
                                    i < rating ? Icons.star_rounded : Icons.star_outline_rounded,
                                    color: Colors.amber,
                                    size: 18,
                                  )),
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  fb['content'] ?? '',
                                  style: const TextStyle(fontSize: 15, height: 1.4),
                                ),
                                const SizedBox(height: 16),
                              ],
                            ),
                          ),
                          Divider(height: 1, color: colorScheme.outlineVariant),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                if (user is Map && user['email'] != null)
                                  TextButton.icon(
                                    onPressed: () {}, // Future: Link to email app
                                    icon: const Icon(Icons.email_outlined, size: 18),
                                    label: const Text('Contact'),
                                  ),
                                const SizedBox(width: 8),
                                FilledButton.tonalIcon(
                                  onPressed: () => _toggleResolve(fb['id'], isResolved),
                                  icon: Icon(isResolved ? Icons.undo : Icons.check_circle_outline, size: 18),
                                  label: Text(isResolved ? 'Mark Pending' : 'Mark Resolved'),
                                  style: FilledButton.styleFrom(
                                    foregroundColor: isResolved ? Colors.orange : Colors.green,
                                    backgroundColor: (isResolved ? Colors.orange : Colors.green).withOpacity(0.1),
                                    minimumSize: const Size(0, 40), // Fix: Override global infinite width
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
    );
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'Bug': return Colors.red;
      case 'Feature Request': return Colors.blue;
      case 'General': return Colors.green;
      default: return Colors.grey;
    }
  }

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'Bug': return Icons.bug_report_outlined;
      case 'Feature Request': return Icons.add_chart_outlined;
      case 'General': return Icons.chat_outlined;
      default: return Icons.help_outline;
    }
  }
}
