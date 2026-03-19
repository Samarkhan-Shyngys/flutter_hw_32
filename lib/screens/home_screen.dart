import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'edit_profile_screen.dart';

class HomeScreen extends StatelessWidget {
  final User user;
  const HomeScreen({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    final authService = AuthService();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Главная'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            tooltip: 'Редактировать профиль',
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => EditProfileScreen(user: user),
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Выйти',
            onPressed: () async {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text('Выход'),
                  content: const Text('Вы уверены, что хотите выйти?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(ctx, false),
                      child: const Text('Отмена'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(ctx, true),
                      child: const Text(
                        'Выйти',
                        style: TextStyle(color: Colors.red),
                      ),
                    ),
                  ],
                ),
              );
              if (confirm == true) {
                await authService.signOut();
              }
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const SizedBox(height: 24),
            _buildAvatar(user),
            const SizedBox(height: 20),
            Text(
              user.displayName?.isNotEmpty == true
                  ? user.displayName!
                  : 'Без имени',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              user.email ?? '',
              style: const TextStyle(color: Colors.grey, fontSize: 16),
            ),
            const SizedBox(height: 32),
            _buildInfoCard(user),
            const SizedBox(height: 24),
            _buildProviderChips(user),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatar(User user) {
    return Stack(
      children: [
        CircleAvatar(
          radius: 60,
          backgroundColor: Colors.deepPurple.shade100,
          backgroundImage: user.photoURL != null
              ? NetworkImage(user.photoURL!)
              : null,
          child: user.photoURL == null
              ? Text(
                  _getInitials(user),
                  style: const TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    color: Colors.deepPurple,
                  ),
                )
              : null,
        ),
        if (user.emailVerified)
          Positioned(
            bottom: 4,
            right: 4,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: const BoxDecoration(
                color: Colors.green,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check, color: Colors.white, size: 16),
            ),
          ),
      ],
    );
  }

  Widget _buildInfoCard(User user) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildInfoRow(
              icon: Icons.person,
              label: 'Имя',
              value: user.displayName?.isNotEmpty == true
                  ? user.displayName!
                  : 'Не указано',
            ),
            const Divider(),
            _buildInfoRow(
              icon: Icons.email,
              label: 'Email',
              value: user.email ?? 'Не указан',
            ),
            const Divider(),
            _buildInfoRow(
              icon: Icons.verified_user,
              label: 'Email подтверждён',
              value: user.emailVerified ? 'Да' : 'Нет',
              valueColor: user.emailVerified ? Colors.green : Colors.orange,
            ),
            const Divider(),
            _buildInfoRow(
              icon: Icons.fingerprint,
              label: 'UID',
              value: '${user.uid.substring(0, 12)}...',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
    Color? valueColor,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: Colors.deepPurple, size: 20),
          const SizedBox(width: 12),
          Text(label, style: const TextStyle(color: Colors.grey)),
          const Spacer(),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: valueColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProviderChips(User user) {
    final providers = user.providerData.map((p) => p.providerId).toList();
    if (providers.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Способ входа',
          style: TextStyle(color: Colors.grey, fontSize: 14),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: providers.map((provider) {
            IconData icon;
            String label;
            if (provider == 'google.com') {
              icon = Icons.g_mobiledata;
              label = 'Google';
            } else if (provider == 'password') {
              icon = Icons.email;
              label = 'Email/Password';
            } else {
              icon = Icons.login;
              label = provider;
            }
            return Chip(
              avatar: Icon(icon, size: 18, color: Colors.deepPurple),
              label: Text(label),
              backgroundColor: Colors.deepPurple.shade50,
            );
          }).toList(),
        ),
      ],
    );
  }

  String _getInitials(User user) {
    if (user.displayName != null && user.displayName!.isNotEmpty) {
      final parts = user.displayName!.trim().split(' ');
      if (parts.length >= 2) return parts[0][0] + parts[1][0];
      return parts[0][0];
    }
    if (user.email != null && user.email!.isNotEmpty) {
      return user.email![0].toUpperCase();
    }
    return '?';
  }
}
