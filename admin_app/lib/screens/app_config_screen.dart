import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AppConfigScreen extends StatefulWidget {
  const AppConfigScreen({super.key});

  @override
  State<AppConfigScreen> createState() => _AppConfigScreenState();
}

class _AppConfigScreenState extends State<AppConfigScreen> {
  final _supabase = Supabase.instance.client;
  
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  
  bool _isLoading = false;
  bool _isLoadingAdmins = true;
  bool _obscurePassword = true;
  List<Map<String, dynamic>> _admins = [];

  @override
  void initState() {
    super.initState();
    _fetchAdmins();
  }

  Future<void> _fetchAdmins() async {
    try {
      final data = await _supabase
          .from('users')
          .select()
          .eq('role', 'admin')
          .order('created_at', ascending: false);
          
      if (mounted) {
        setState(() {
          _admins = List<Map<String, dynamic>>.from(data);
          _isLoadingAdmins = false;
        });
      }
    } catch (e) {
      debugPrint('Error fetching admins: $e');
      if (mounted) setState(() => _isLoadingAdmins = false);
    }
  }

  Future<void> _removeAdmin(String id, String name) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remove Admin?'),
        content: Text('Are you sure you want to revoke admin privileges for $name?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Remove', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        // Demote to standard user using the secure database function
        await _supabase.rpc('remove_admin', params: {
          'target_user_id': id
        });
        
        _fetchAdmins();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Admin removed successfully')));
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
        }
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _addAdmin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    
    // Save current session so we can restore it because auth.signUp will sign out the active user
    // if email confirmations are disabled on Supabase.
    final currentSession = _supabase.auth.currentSession;

    try {
      // Create auth user
      final authResponse = await _supabase.auth.signUp(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      final user = authResponse.user;
      
      if (user != null) {
        // Insert admin profile records into 'users' table
        await _supabase.from('users').upsert({
          'id': user.id,
          'email': user.email,
          'display_name': _nameController.text.trim(),
          'role': 'admin', // This grants admin access
          'created_at': DateTime.now().toIso8601String(),
        });
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('New Admin successfully added!'), backgroundColor: Colors.green),
          );
          Navigator.pop(context); // Go back after success
        }
      } else {
        throw Exception('Failed to create admin user.');
      }
      
    } on AuthException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Authentication Error: ${e.message}')));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      // Restore previous admin session gently (only needed if Supabase logs us into the newly created account)
      if (currentSession != null && _supabase.auth.currentUser?.id != currentSession.user.id) {
         await _supabase.auth.setSession(currentSession.refreshToken!); // Refresh to old session
      }
      
      if (mounted) {
        setState(() {
          _isLoading = false;
          _nameController.clear();
          _emailController.clear();
          _passwordController.clear();
        });
        _fetchAdmins();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    const scaffoldBgColor = Color(0xFFF8F7F2); // Soft warm cream
    const cardBgColor = Color(0xFFEFECE3); // Slightly darker rounded card
    const primaryColor = Color(0xFFAFA098);
    final isKeyboardOpen = MediaQuery.of(context).viewInsets.bottom > 0;

    return Scaffold(
      backgroundColor: scaffoldBgColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black, size: 28),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'App Config',
          style: textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w800,
            color: Colors.black,
            fontSize: 22,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Add New Admin',
                style: textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Create a new administrator account with full access to Campus AI management tools.',
                style: textTheme.bodyMedium?.copyWith(
                  color: Colors.black54,
                  height: 1.5,
                ),
              ),
              
              const SizedBox(height: 32),
              
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: cardBgColor,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Name field
                      TextFormField(
                        controller: _nameController,
                        decoration: InputDecoration(
                          labelText: 'Display Name',
                          prefixIcon: const Icon(Icons.person_outline),
                          filled: true,
                          fillColor: scaffoldBgColor,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        validator: (value) =>
                            value == null || value.isEmpty ? 'Please enter a name' : null,
                      ),
                      const SizedBox(height: 16),
                      
                      // Email field
                      TextFormField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: InputDecoration(
                          labelText: 'Admin Email',
                          prefixIcon: const Icon(Icons.email_outlined),
                          filled: true,
                          fillColor: scaffoldBgColor,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) return 'Please enter an email';
                          if (!value.contains('@')) return 'Please enter a valid email';
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      
                      // Password field
                      TextFormField(
                        controller: _passwordController,
                        obscureText: _obscurePassword,
                        decoration: InputDecoration(
                          labelText: 'Temporary Password',
                          prefixIcon: const Icon(Icons.lock_outline),
                          suffixIcon: IconButton(
                            icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility),
                            onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                          ),
                          filled: true,
                          fillColor: scaffoldBgColor,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        validator: (value) => value != null && value.length < 6
                            ? 'Password must be at least 6 characters'
                            : null,
                      ),
                      
                      const SizedBox(height: 32),
                      
                      // Submit Button
                      SizedBox(
                        height: 56,
                        child: FilledButton(
                          onPressed: _isLoading ? null : _addAdmin,
                          style: FilledButton.styleFrom(
                            backgroundColor: primaryColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: _isLoading
                              ? const SizedBox(
                                  height: 24,
                                  width: 24,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Text(
                                  'Create Admin Account',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 48),
              
              Text(
                'Existing Administrators',
                style: textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 16),
              
              if (_isLoadingAdmins)
                const Center(child: Padding(
                  padding: EdgeInsets.all(32.0),
                  child: CircularProgressIndicator(),
                ))
              else if (_admins.isEmpty)
                Container(
                  padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: Colors.grey.withOpacity(0.2)),
                  ),
                  child: const Center(child: Text('No admins found.')),
                )
              else
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _admins.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 16),
                  itemBuilder: (context, index) {
                    final admin = _admins[index];
                    final isCurrentUser = _supabase.auth.currentUser?.id == admin['id'];
                    
                    return Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.02),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 24,
                            backgroundColor: const Color(0xFFDCC8B6),
                            child: Text(
                              (admin['display_name'] ?? '?')[0].toUpperCase(),
                              style: const TextStyle(
                                color: Color(0xFF7A685A),
                                fontWeight: FontWeight.bold,
                                fontSize: 20,
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        admin['display_name'] ?? 'Unknown',
                                        style: textTheme.titleMedium?.copyWith(
                                          fontWeight: FontWeight.bold,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    if (isCurrentUser)
                                      Container(
                                        margin: const EdgeInsets.only(left: 8),
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFE2EDD9),
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: const Text('You', style: TextStyle(color: Color(0xFF5A7C46), fontSize: 10, fontWeight: FontWeight.bold)),
                                      ),
                                  ],
                                ),
                                Text(
                                  admin['email'] ?? '',
                                  style: textTheme.bodySmall?.copyWith(color: Colors.black54),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                          if (!isCurrentUser)
                            IconButton(
                              icon: const Icon(Icons.person_remove_rounded, color: Colors.redAccent),
                              tooltip: 'Remove Admin',
                              onPressed: () => _removeAdmin(admin['id'], admin['display_name'] ?? 'Unknown'),
                            ),
                        ],
                      ),
                    );
                  },
                ),
                
              if (isKeyboardOpen) const SizedBox(height: 100), // padding for scrolling
            ],
          ),
        ),
      ),
    );
  }
}
