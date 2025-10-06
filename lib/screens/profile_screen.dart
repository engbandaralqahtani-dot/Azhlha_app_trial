import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/app_provider.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('الملف الشخصي'),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildProfileHeader(user),
          const SizedBox(height: 24),
          _buildMenuSection(context),
          const SizedBox(height: 24),
          _buildPreferencesSection(),
          const SizedBox(height: 24),
          _buildDangerZone(context),
        ],
      ),
    );
  }

  Widget _buildProfileHeader(User? user) {
    if (user == null) {
      return const SizedBox.shrink();
    }

    return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance.collection('users').doc(user.uid).snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Card(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: const [
                  Icon(Icons.error_outline, color: Colors.red, size: 32),
                  SizedBox(height: 12),
                  Text('تعذر تحميل بيانات الملف الشخصي'),
                ],
              ),
            ),
          );
        }

        if (!snapshot.hasData) {
          return const Card(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: Center(
                child: CircularProgressIndicator(),
              ),
            ),
          );
        }

        final data = snapshot.data?.data();
        final name = data?['name'] as String? ?? 'مستخدم أزهلها';
        final email = user.email ?? 'غير متوفر';
        final phone = data?['phoneNumber'] as String? ?? 'غير محدد';

        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                CircleAvatar(
                  radius: 50,
                  backgroundColor: const Color(0xFF00543C).withOpacity(0.1),
                  child: const Icon(
                    Icons.person,
                    size: 48,
                    color: Color(0xFF00543C),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  email,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.phone_android, size: 16, color: Color(0xFF00543C)),
                    const SizedBox(width: 6),
                    Text(
                      phone,
                      style: TextStyle(
                        color: Colors.grey[700],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                OutlinedButton(
                  onPressed: () {
                    // TODO: فتح شاشة تعديل البيانات الشخصية
                  },
                  child: const Text('تعديل الملف الشخصي'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildMenuSection(BuildContext context) {
    return Card(
      child: Column(
        children: [
          _buildMenuItem(
            icon: Icons.history,
            title: 'سجل البلاغات',
            onTap: () {
              context.read<AppProvider>().setCurrentIndex(1);
            },
          ),
          const Divider(height: 1),
          _buildMenuItem(
            icon: Icons.notifications,
            title: 'الإشعارات',
            onTap: () {
              // TODO: الانتقال لشاشة الإشعارات
            },
          ),
          const Divider(height: 1),
          _buildMenuItem(
            icon: Icons.payment,
            title: 'طرق الدفع',
            onTap: () {},
          ),
          const Divider(height: 1),
          _buildMenuItem(
            icon: Icons.help_outline,
            title: 'المساعدة والدعم',
            onTap: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildPreferencesSection() {
    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              'الإعدادات',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          _buildSwitchItem(
            icon: Icons.notifications_active,
            title: 'الإشعارات الفورية',
            value: true,
            onChanged: (value) {},
          ),
          const Divider(height: 1),
          _buildSwitchItem(
            icon: Icons.location_on,
            title: 'مشاركة الموقع',
            value: true,
            onChanged: (value) {},
          ),
          const Divider(height: 1),
          _buildSwitchItem(
            icon: Icons.dark_mode,
            title: 'الوضع الليلي',
            value: false,
            onChanged: (value) {},
          ),
        ],
      ),
    );
  }

  Widget _buildDangerZone(BuildContext context) {
    return Card(
      color: Colors.red[50],
      child: ListTile(
        leading: const Icon(Icons.logout, color: Color(0xFFB91C1C)),
        title: const Text(
          'تسجيل الخروج',
          style: TextStyle(
            color: Color(0xFFB91C1C),
            fontWeight: FontWeight.bold,
          ),
        ),
        onTap: () async {
          await FirebaseAuth.instance.signOut();
          if (!context.mounted) return;
          Navigator.of(context)
              .pushNamedAndRemoveUntil('/login', (route) => false);
        },
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: const Color(0xFF00543C)),
      title: Text(title),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: onTap,
    );
  }

  Widget _buildSwitchItem({
    required IconData icon,
    required String title,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return SwitchListTile(
      secondary: Icon(icon, color: const Color(0xFF00543C)),
      title: Text(title),
      value: value,
      onChanged: onChanged,
      activeColor: const Color(0xFF00543C),
    );
  }
}