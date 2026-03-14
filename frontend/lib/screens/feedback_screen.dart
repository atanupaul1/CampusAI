import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class FeedbackScreen extends StatefulWidget {
  const FeedbackScreen({super.key});

  @override
  State<FeedbackScreen> createState() => _FeedbackScreenState();
}

class _FeedbackScreenState extends State<FeedbackScreen> {
  final _formKey = GlobalKey<FormState>();
  final _contentController = TextEditingController();
  final _supabase = Supabase.instance.client;
  
  String _category = 'General';
  double _rating = 5.0;
  bool _isSending = false;

  final List<String> _categories = ['Bug', 'Feature Request', 'General', 'Question'];

  Future<void> _submitFeedback() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSending = true);

    try {
      final user = _supabase.auth.currentUser;
      await _supabase.from('user_feedback').insert({
        'user_id': user?.id,
        'category': _category,
        'content': _contentController.text.trim(),
        'rating': _rating.toInt(),
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Feedback submitted! Thank you.', style: TextStyle(fontWeight: FontWeight.bold)),
            backgroundColor: const Color(0xFFFD5D11),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to submit: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: colorScheme.surface,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.close, color: colorScheme.onSurface),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Feedback',
          style: TextStyle(
            color: colorScheme.onSurface, 
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'How are we doing?',
                style: textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w900, 
                  fontSize: 26,
                  color: colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Your feedback helps us make Campus AI better for everyone.',
                style: TextStyle(
                  color: colorScheme.onSurfaceVariant, 
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 40),

              _buildSectionLabel('RATE YOUR EXPERIENCE'),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
                decoration: BoxDecoration(
                  color: colorScheme.surface,
                  borderRadius: BorderRadius.circular(24),
                  border: isDark ? Border.all(color: Theme.of(context).dividerColor.withOpacity(0.1)) : null,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(isDark ? 0.2 : 0.04), 
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Slider(
                      value: _rating,
                      min: 1,
                      max: 5,
                      divisions: 4,
                      activeColor: const Color(0xFFFD5D11),
                      inactiveColor: const Color(0xFFFD5D11).withOpacity(0.1),
                      onChanged: (v) => setState(() => _rating = v),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _buildRatingLabel('POOR'),
                          _buildRatingLabel('EXCELLENT'),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 32),

              _buildSectionLabel('CATEGORY'),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: _category,
                dropdownColor: colorScheme.surface,
                style: TextStyle(color: colorScheme.onSurface, fontSize: 16),
                decoration: InputDecoration(
                  fillColor: colorScheme.surface,
                  filled: true,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20), 
                    borderSide: isDark ? BorderSide(color: Theme.of(context).dividerColor.withOpacity(0.1)) : BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: isDark ? BorderSide(color: Theme.of(context).dividerColor.withOpacity(0.1)) : BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                ),
                items: _categories.map((c) => DropdownMenuItem(
                  value: c, 
                  child: Text(c, style: TextStyle(color: colorScheme.onSurface)),
                )).toList(),
                onChanged: (v) => setState(() => _category = v!),
              ),
              
              const SizedBox(height: 32),

              _buildSectionLabel('YOUR MESSAGE'),
              const SizedBox(height: 12),
              TextFormField(
                controller: _contentController,
                maxLines: 6,
                style: TextStyle(color: colorScheme.onSurface),
                decoration: InputDecoration(
                  hintText: 'Tell us what you think...',
                  hintStyle: TextStyle(color: colorScheme.onSurfaceVariant.withOpacity(0.5)),
                  fillColor: colorScheme.surface,
                  filled: true,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24), 
                    borderSide: isDark ? BorderSide(color: Theme.of(context).dividerColor.withOpacity(0.1)) : BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: isDark ? BorderSide(color: Theme.of(context).dividerColor.withOpacity(0.1)) : BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.all(20),
                ),
                validator: (v) => v == null || v.isEmpty ? 'Please enter some text' : null,
              ),
              
              const SizedBox(height: 40),

              SizedBox(
                width: double.infinity,
                height: 60,
                child: ElevatedButton(
                  onPressed: _isSending ? null : _submitFeedback,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFD5D11),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    elevation: 5,
                    shadowColor: const Color(0xFFFD5D11).withOpacity(0.4),
                  ),
                  child: _isSending 
                    ? const SizedBox(height: 24, width: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : const Text('Submit Feedback', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionLabel(String label) {
    return Text(
      label,
      style: TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.bold,
        color: Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.7),
        letterSpacing: 1.0,
      ),
    );
  }

  Widget _buildRatingLabel(String text) {
    return Text(
      text, 
      style: TextStyle(
        fontSize: 10, 
        fontWeight: FontWeight.bold, 
        color: Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.5),
      ),
    );
  }
}
