import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/auth_provider.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _nameCtrl = TextEditingController();
  bool _isSignUp = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _nameCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    final notifier = ref.read(authProvider.notifier);
    if (_isSignUp) {
      notifier.register(
        _emailCtrl.text.trim(),
        _passwordCtrl.text,
        _nameCtrl.text.trim(),
      );
    } else {
      notifier.login(
        _emailCtrl.text.trim(),
        _passwordCtrl.text,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 40),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Logo
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: isDark ? colorScheme.surfaceContainer : Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(isDark ? 0.3 : 0.05),
                          blurRadius: 20,
                        ),
                      ],
                    ),
                    child: Image.asset(
                      'assets/logo/campus_ai.png',
                      height: 80,
                    ),
                  ),
                  const SizedBox(height: 32),

                  // App Name
                  Text(
                    'Campus AI',
                    style: textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w900,
                      color: colorScheme.onSurface,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Your Smart Academic Assistant',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: colorScheme.onSurfaceVariant,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 48),

                  // Display Name (sign-up only)
                  if (_isSignUp) ...[
                    _buildTextField(
                      controller: _nameCtrl,
                      label: 'Display Name',
                      icon: Icons.person_outline_rounded,
                      textCapitalization: TextCapitalization.words,
                      colorScheme: colorScheme,
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Email
                  _buildTextField(
                    controller: _emailCtrl,
                    label: 'Email',
                    icon: Icons.email_outlined,
                    keyboardType: TextInputType.emailAddress,
                    colorScheme: colorScheme,
                    validator: (v) {
                      if (v == null || v.isEmpty) return 'Enter your email';
                      if (!v.contains('@')) return 'Enter a valid email';
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Password
                  _buildTextField(
                    controller: _passwordCtrl,
                    label: 'Password',
                    icon: Icons.lock_outline_rounded,
                    obscureText: _obscurePassword,
                    colorScheme: colorScheme,
                    suffixIcon: IconButton(
                      icon: Icon(_obscurePassword
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined),
                      onPressed: () {
                        setState(() => _obscurePassword = !_obscurePassword);
                      },
                      color: colorScheme.onSurfaceVariant,
                    ),
                    validator: (v) {
                      if (v == null || v.isEmpty) return 'Enter your password';
                      if (v.length < 6) return 'Minimum 6 characters';
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),

                  // Error Message
                  if (authState.status == AuthStatus.error &&
                      authState.errorMessage != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: Text(
                        authState.errorMessage!,
                        style: const TextStyle(color: Colors.redAccent, fontSize: 13),
                        textAlign: TextAlign.center,
                      ),
                    ),

                  // Submit Button
                  SizedBox(
                    width: double.infinity,
                    height: 60,
                    child: ElevatedButton(
                      onPressed: authState.status == AuthStatus.loading
                          ? null
                          : _submit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFD5D11),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                        elevation: 5,
                        shadowColor: const Color(0xFFFD5D11).withOpacity(0.4),
                      ),
                      child: authState.status == AuthStatus.loading
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : Text(
                              _isSignUp ? 'Create Account' : 'Sign In',
                              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
                            ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Toggle Sign In / Sign Up
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        _isSignUp ? 'Already have an account?' : "Don't have an account?",
                        style: TextStyle(color: colorScheme.onSurfaceVariant),
                      ),
                      TextButton(
                        onPressed: () {
                          setState(() => _isSignUp = !_isSignUp);
                        },
                        child: Text(
                          _isSignUp ? 'Sign In' : 'Sign Up',
                          style: const TextStyle(
                            color: Color(0xFFFD5D11),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required ColorScheme colorScheme,
    bool obscureText = false,
    Widget? suffixIcon,
    TextInputType? keyboardType,
    TextCapitalization textCapitalization = TextCapitalization.none,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      textCapitalization: textCapitalization,
      style: TextStyle(color: colorScheme.onSurface),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: colorScheme.onSurfaceVariant),
        prefixIcon: Icon(icon, color: colorScheme.onSurfaceVariant.withOpacity(0.5)),
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: colorScheme.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide(color: colorScheme.outlineVariant),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide(color: colorScheme.outlineVariant),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: const BorderSide(color: Color(0xFFFD5D11)),
        ),
      ),
      validator: validator,
    );
  }
}
