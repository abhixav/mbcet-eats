import 'package:flutter/material.dart';
import 'admin/admin_home_screen.dart';
import 'user/home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _idController = TextEditingController();
  final TextEditingController _adminUserController = TextEditingController();
  final TextEditingController _adminPassController = TextEditingController();
  String? _errorText;

  void _login() {
    final input = _idController.text.trim();

    if (RegExp(r'^b\d{2}[a-z]{2}\d{4}$', caseSensitive: false).hasMatch(input)) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => HomeScreen(userId: input)),
      );
    } else {
      setState(() => _errorText = 'Enter valid College ID (e.g., b22cs1234)');
    }
  }

  void _adminLoginDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Admin Login'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _adminUserController,
              decoration: const InputDecoration(
                labelText: 'Username',
                prefixIcon: Icon(Icons.person),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _adminPassController,
              decoration: const InputDecoration(
                labelText: 'Password',
                prefixIcon: Icon(Icons.lock),
              ),
              obscureText: true,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: _adminLogin,
            child: const Text('Login'),
          ),
        ],
      ),
    );
  }

  void _adminLogin() {
    final username = _adminUserController.text.trim();
    final password = _adminPassController.text;

    if (username == 'admin' && password == 'admin123') {
      Navigator.pop(context);
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const AdminHomeScreen()),
      );
    } else {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('❌ Invalid admin username or password'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.teal.shade50,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.restaurant_menu, size: 90, color: Colors.teal),
              const SizedBox(height: 16),
              const Text(
                'MBCET Eats',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.teal),
              ),
              const SizedBox(height: 24),
              TextField(
                controller: _idController,
                decoration: InputDecoration(
                  labelText: 'Enter College ID',
                  hintText: 'e.g., b22cs1234',
                  prefixIcon: const Icon(Icons.person),
                  errorText: _errorText,
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _login,
                icon: const Icon(Icons.login),
                label: const Text('Login'),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(50),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 12),
              ElevatedButton.icon(
                onPressed: _adminLoginDialog,
                icon: const Icon(Icons.admin_panel_settings),
                label: const Text('Admin Login'),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(50),
                  backgroundColor: Colors.teal,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
