import 'package:flutter/material.dart';
import '../../services/auth_service.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final AuthService _authService = AuthService();

  String? _errorText;

  void _signup() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (!email.endsWith('@mbcet.ac.in')) {
      setState(() => _errorText = '❌ Use your college email (e.g., name.id@mbcet.ac.in)');
      return;
    }

    if (password.length < 6) {
      setState(() => _errorText = '❌ Password must be at least 6 characters long');
      return;
    }

    try {
      await _authService.registerWithEmail(email, password);
      if (context.mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Account created successfully'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      setState(() {
        if (e.toString().contains('email-already-in-use')) {
          _errorText = '❌ Email already registered';
        } else if (e.toString().contains('weak-password')) {
          _errorText = '❌ Weak password. Use a stronger one';
        } else {
          _errorText = '❌ Signup failed: ${e.toString()}';
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create Account')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Icon(Icons.person_add_alt, size: 80, color: Colors.teal),
            const SizedBox(height: 16),
            TextField(
              controller: _emailController,
              decoration: InputDecoration(
                labelText: 'College Email',
                hintText: 'fullname.b22cs1234@mbcet.ac.in',
                errorText: _errorText,
                prefixIcon: const Icon(Icons.email),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(
                labelText: 'Password',
                prefixIcon: const Icon(Icons.lock),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              obscureText: true,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _signup,
              icon: const Icon(Icons.app_registration),
              label: const Text('Create Account'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
