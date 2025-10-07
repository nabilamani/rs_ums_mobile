import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:rs_ums_test/services/auth_service.dart';
import 'package:rs_ums_test/utils/constants.dart';
import 'login_screen.dart';

class AkunPage extends StatefulWidget {
  const AkunPage({super.key});

  @override
  State<AkunPage> createState() => _AkunPageState();
}

class _AkunPageState extends State<AkunPage> {
  User? currentUser;

  @override
  void initState() {
    super.initState();
    currentUser = FirebaseAuth.instance.currentUser;
  }

  String _getUserName() {
    if (currentUser?.displayName != null &&
        currentUser!.displayName!.isNotEmpty) {
      return currentUser!.displayName!;
    }
    if (currentUser?.email != null) {
      return currentUser!.email!.split('@')[0];
    }
    return "Pengguna";
  }

  String _getUserEmail() {
    return currentUser?.email ?? "email@example.com";
  }

  void _logout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text("Keluar dari Akun"),
        content: const Text("Apakah Anda yakin ingin keluar?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Batal"),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text("Keluar"),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final auth = AuthService();
      await auth.logout();

      if (!mounted) return;

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
        (route) => false,
      );
    }
  }

  void _showResetPasswordDialog() {
    final emailController = TextEditingController(
      text: currentUser?.email ?? '',
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text("Reset Password"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              "Link reset password akan dikirim ke email Anda",
              style: TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: emailController,
              decoration: const InputDecoration(
                labelText: "Email",
                prefixIcon: Icon(Icons.email_outlined),
              ),
              enabled: false,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Batal"),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                await FirebaseAuth.instance.sendPasswordResetEmail(
                  email: emailController.text,
                );
                if (!context.mounted) return;
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      'Link reset password telah dikirim ke email Anda',
                    ),
                    backgroundColor: Colors.green,
                  ),
                );
              } catch (e) {
                if (!context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Gagal mengirim email: $e'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            child: const Text("Kirim"),
          ),
        ],
      ),
    );
  }

  void _showFAQ() {
    Navigator.push(context, MaterialPageRoute(builder: (_) => const FAQPage()));
  }

  void _showAbout() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.local_hospital, color: AppColors.primary),
            ),
            const SizedBox(width: 12),
            const Text("Tentang Aplikasi"),
          ],
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "RS UMS Mobile",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 4),
            Text("Versi 1.0.0", style: TextStyle(color: Colors.grey)),
            SizedBox(height: 16),
            Text(
              "Aplikasi manajemen rumah sakit untuk kemudahan akses jadwal, presensi, dan informasi kesehatan.",
              style: TextStyle(height: 1.5),
            ),
            SizedBox(height: 16),
            Text(
              "© 2025 Rumah Sakit UMS",
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Tutup"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(0), // atur tinggi di sini
        child: AppBar(
          backgroundColor: const Color(0xFF009688),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              _buildHeader(),
              const SizedBox(height: 20),
              _buildMenuSection(),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [const Color(0xFF009688), const Color(0xFF00796B)],
        ),
      ),
      child: Column(
        children: [
          const SizedBox(height: 40),
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 20,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: CircleAvatar(
              radius: 50,
              backgroundColor: Colors.grey[200],
              backgroundImage: currentUser?.photoURL != null
                  ? NetworkImage(currentUser!.photoURL!)
                  : null,
              child: currentUser?.photoURL == null
                  ? Icon(Icons.person, size: 50, color: Colors.grey[400])
                  : null,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            _getUserName(),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            _getUserEmail(),
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.9),
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 24),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 20),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem(Icons.calendar_today, "12", "Jadwal"),
                Container(
                  height: 40,
                  width: 1,
                  color: Colors.white.withValues(alpha: 0.3),
                ),
                _buildStatItem(Icons.check_circle, "28", "Presensi"),
                Container(
                  height: 40,
                  width: 1,
                  color: Colors.white.withValues(alpha: 0.3),
                ),
                _buildStatItem(Icons.star, "4.8", "Rating"),
              ],
            ),
          ),
          const SizedBox(height: 30),
        ],
      ),
    );
  }

  Widget _buildStatItem(IconData icon, String value, String label) {
    return Column(
      children: [
        Icon(icon, color: Colors.white, size: 24),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.8),
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildMenuSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Pengaturan Akun",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          _buildMenuItem(
            icon: Icons.person_outline,
            title: "Edit Profil",
            subtitle: "Ubah informasi profil Anda",
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Fitur edit profil akan segera hadir'),
                ),
              );
            },
          ),
          _buildMenuItem(
            icon: Icons.lock_outline,
            title: "Reset Password",
            subtitle: "Ubah password akun Anda",
            onTap: _showResetPasswordDialog,
          ),
          _buildMenuItem(
            icon: Icons.notifications_none_outlined,
            title: "Notifikasi",
            subtitle: "Atur preferensi notifikasi",
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Fitur notifikasi akan segera hadir'),
                ),
              );
            },
          ),
          const SizedBox(height: 24),
          const Text(
            "Lainnya",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          _buildMenuItem(
            icon: Icons.help_outline,
            title: "FAQ",
            subtitle: "Pertanyaan yang sering ditanyakan",
            onTap: _showFAQ,
          ),
          _buildMenuItem(
            icon: Icons.privacy_tip_outlined,
            title: "Kebijakan Privasi",
            subtitle: "Lihat kebijakan privasi kami",
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Membuka kebijakan privasi...')),
              );
            },
          ),
          _buildMenuItem(
            icon: Icons.info_outline,
            title: "Tentang Aplikasi",
            subtitle: "Informasi aplikasi RS UMS Mobile",
            onTap: _showAbout,
          ),
          _buildMenuItem(
            icon: Icons.logout,
            title: "Keluar",
            subtitle: "Keluar dari akun Anda",
            color: AppColors.error,
            onTap: _logout,
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    Color? color,
  }) {
    final itemColor = color ?? AppColors.primary;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: itemColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: itemColor, size: 24),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: itemColor == AppColors.error
                ? itemColor
                : AppColors.textPrimary,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
        ),
        trailing: Icon(
          Icons.arrow_forward_ios,
          size: 16,
          color: Colors.grey[400],
        ),
        onTap: onTap,
      ),
    );
  }
}

// FAQ Page
class FAQPage extends StatelessWidget {
  const FAQPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text("FAQ"),
        backgroundColor: const Color(0xFF009688),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _buildFAQItem(
            question: "Bagaimana cara melakukan presensi?",
            answer:
                "Buka menu Presensi, lalu gunakan fitur fingerprint atau scan QR code yang tersedia di lokasi kerja Anda.",
          ),
          _buildFAQItem(
            question: "Bagaimana melihat jadwal kerja saya?",
            answer:
                "Anda dapat melihat jadwal kerja di menu Jadwal. Jadwal akan ditampilkan berdasarkan bulan dan dapat difilter sesuai kebutuhan.",
          ),
          _buildFAQItem(
            question: "Apa yang harus dilakukan jika lupa password?",
            answer:
                "Gunakan fitur Reset Password di halaman Akun atau klik 'Lupa Password' di halaman login untuk mendapatkan link reset via email.",
          ),
          _buildFAQItem(
            question: "Bagaimana cara mengubah informasi profil?",
            answer:
                "Buka menu Akun, pilih Edit Profil, lalu update informasi yang ingin diubah dan simpan perubahan.",
          ),
          _buildFAQItem(
            question: "Siapa yang bisa saya hubungi untuk bantuan teknis?",
            answer:
                "Anda dapat menghubungi IT Support RS UMS di nomor (0271) 717500 ext. 123 atau email support@rs-ums.ac.id",
          ),
        ],
      ),
    );
  }

  Widget _buildFAQItem({required String question, required String answer}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Theme(
        data: ThemeData(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          title: Text(
            question,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Text(
                answer,
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                  height: 1.5,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
