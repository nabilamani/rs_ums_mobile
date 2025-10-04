import 'package:flutter/material.dart';
import 'package:rs_ums_test/services/auth_service.dart';
import 'login_screen.dart';

class AkunPage extends StatelessWidget {
  const AkunPage({super.key});

  void _logout(BuildContext context) async {
    final auth = AuthService();
    await auth.logout();

    // ✅ Pastikan widget masih mounted sebelum pakai context
    if (!context.mounted) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Home")),
      body: Center(
        child: ElevatedButton(
          onPressed: () => _logout(context),
          child: const Text("Logout"),
        ),
      ),
    );
  }
}
