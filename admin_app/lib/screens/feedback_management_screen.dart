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

  Future<void> _deleteFeedback(String id) async {
    try {
      await _supabase.from('user_feedback').delete().eq('id', id);
      _fetchFeedback();
    } catch (e) {
      debugPrint('Error deleting feedback: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error deleting feedback: $e')),
        );
      }
      _fetchFeedback();
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
            // Custom App Bar (Tab Mode)
            Padding(
              padding: const EdgeInsets.only(top: 12.0, bottom: 12.0, left: 16.0, right: 8.0),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Padding(
                      padding: const EdgeInsets.only(left: 8.0, top: 12.0),
                      child: Text(
                        'User Feedback',
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
                  Align(
                    alignment: Alignment.centerRight,
                    child: IconButton(
                      icon: Icon(Icons.refresh, 
                        color: Theme.of(context).brightness == Brightness.dark 
                            ? Colors.white 
                            : Colors.black, 
                        size: 28),
                      onPressed: _fetchFeedback,
                    ),
                  ),
                ],
              ),
            ),
            
            // Content
            Expanded(
              child: _isLoading
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
                              padding: const EdgeInsets.all(20),
                              itemCount: _feedbacks.length,
                              itemBuilder: (context, index) {
                                final fb = _feedbacks[index];
                                final user = fb['users'];
                                final isResolved = fb['is_resolved'] ?? false;
                                final rating = fb['rating'] ?? 0;

                                final userName = user is Map ? (user['display_name'] ?? 'Anonymous') : 'Anonymous';
                                final dateStr = fb['created_at'] != null 
                                    ? DateFormat('MMM dd, yyyy • hh:mm a').format(DateTime.parse(fb['created_at']))
                                    : 'Unknown date';

                                return Dismissible(
                                  key: Key(fb['id'].toString()),
                                  direction: DismissDirection.endToStart,
                                  background: Container(
                                    margin: const EdgeInsets.only(bottom: 20),
                                    decoration: BoxDecoration(
                                      color: Colors.red.shade400,
                                      borderRadius: BorderRadius.circular(24),
                                    ),
                                    alignment: Alignment.centerRight,
                                    padding: const EdgeInsets.symmetric(horizontal: 24),
                                    child: const Icon(Icons.delete_outline_rounded, color: Colors.white, size: 32),
                                  ),
                                  confirmDismiss: (direction) async {
                                    return await showDialog<bool>(
                                      context: context,
                                      builder: (context) => AlertDialog(
                                        title: const Text('Delete Feedback?'),
                                        content: const Text('This action cannot be undone.'),
                                        actions: [
                                          TextButton(
                                            onPressed: () => Navigator.pop(context, false),
                                            child: const Text('Cancel'),
                                          ),
                                          TextButton(
                                            onPressed: () => Navigator.pop(context, true),
                                            child: const Text(
                                              'Delete',
                                              style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                  onDismissed: (direction) {
                                    _deleteFeedback(fb['id']);
                                  },
                                  child: Container(
                                    margin: const EdgeInsets.only(bottom: 20),
                                    padding: const EdgeInsets.all(20),
                                    decoration: BoxDecoration(
                                      color: cardBgColor,
                                      borderRadius: BorderRadius.circular(24),
                                      border: Border.all(
                                        color: Theme.of(context).brightness == Brightness.dark 
                                            ? Colors.white.withOpacity(0.05) 
                                            : Colors.transparent,
                                      ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.04),
                                        blurRadius: 10,
                                        offset: const Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      // Header profile
                                      Row(
                                        children: [
                                          CircleAvatar(
                                            radius: 24,
                                            backgroundColor: const Color(0xFFDCC8B6),
                                            child: const Icon(Icons.person, color: Color(0xFFA28C7B), size: 32),
                                          ),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  userName,
                                                  style: textTheme.titleMedium?.copyWith(
                                                    fontWeight: FontWeight.w800,
                                                    color: Theme.of(context).brightness == Brightness.dark 
                                                        ? Colors.white 
                                                        : Colors.black,
                                                  ),
                                                ),
                                                Text(
                                                  dateStr,
                                                  style: textTheme.bodyMedium?.copyWith(
                                                    color: Theme.of(context).brightness == Brightness.dark 
                                                        ? Colors.white70 
                                                        : Colors.black87,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                            decoration: BoxDecoration(
                                              color: isResolved 
                                                  ? (Theme.of(context).brightness == Brightness.dark ? const Color(0xFF2D3B24) : const Color(0xFFE2EDD9))
                                                  : (Theme.of(context).brightness == Brightness.dark ? const Color(0xFF3B2A1F) : const Color(0xFFEDDBCE)),
                                              borderRadius: BorderRadius.circular(12),
                                            ),
                                            child: Text(
                                              isResolved ? 'Resolved' : 'Pending',
                                              style: TextStyle(
                                              color: isResolved 
                                                  ? (Theme.of(context).brightness == Brightness.dark ? const Color(0xFFA8C895) : const Color(0xFF5A7C46))
                                                  : (Theme.of(context).brightness == Brightness.dark ? const Color(0xFFDCC8B6) : const Color(0xFF9E6B4A)),
                                                fontSize: 12,
                                                fontWeight: FontWeight.w700,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 16),
                                      
                                      // Stars
                                      Row(
                                        children: List.generate(5, (i) => Icon(
                                          i < rating ? Icons.star_rounded : Icons.star_outline_rounded,
                                          color: Theme.of(context).brightness == Brightness.dark 
                                              ? Colors.white.withOpacity(0.9) 
                                              : Colors.black87,
                                          size: 24,
                                        )),
                                      ),
                                      const SizedBox(height: 8),
                                      
                                      // Feedback Text
                                      Text(
                                        fb['content'] ?? '',
                                        style: textTheme.bodyLarge?.copyWith(
                                          color: Theme.of(context).brightness == Brightness.dark 
                                              ? Colors.white.withOpacity(0.9) 
                                              : Colors.black87,
                                        ),
                                      ),
                                      
                                      const SizedBox(height: 20),
                                      
                                      // Action Buttons
                                      Row(
                                        children: [
                                          Expanded(
                                            child: OutlinedButton(
                                              onPressed: () {}, // Future: contact logic
                                              style: OutlinedButton.styleFrom(
                                                foregroundColor: Theme.of(context).brightness == Brightness.dark 
                                                    ? Colors.white.withOpacity(0.9) 
                                                    : Colors.black,
                                                side: BorderSide(
                                                  color: Theme.of(context).brightness == Brightness.dark 
                                                      ? Colors.white24 
                                                      : Colors.black12, 
                                                  width: 1.5),
                                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                                padding: const EdgeInsets.symmetric(vertical: 12),
                                              ),
                                              child: const Text('Contact', style: TextStyle(fontWeight: FontWeight.bold)),
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: FilledButton.icon(
                                              onPressed: () => _toggleResolve(fb['id'], isResolved),
                                              icon: Icon(
                                                isResolved ? Icons.undo : Icons.check, 
                                                size: 20,
                                                color: Theme.of(context).brightness == Brightness.dark 
                                                    ? Colors.black 
                                                    : Colors.black,
                                              ),
                                              label: Text(
                                                isResolved ? 'Mark Pending' : 'Mark Resolved',
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold, 
                                                  color: Theme.of(context).brightness == Brightness.dark 
                                                      ? Colors.black 
                                                      : Colors.black),
                                              ),
                                              style: FilledButton.styleFrom(
                                                backgroundColor: Theme.of(context).brightness == Brightness.dark 
                                                    ? const Color(0xFFDCC8B6) 
                                                    : const Color(0xFFE1DCCF),
                                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                                padding: const EdgeInsets.symmetric(vertical: 12),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                    ),
                                  ),
                                );
                              },
                            ),
            ),
          ],
        ),
      ),
    );
  }
}
