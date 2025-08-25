import 'package:Budget_App/Theme/theme_provider.dart';
import 'package:Budget_App/screens/edit_profile_page.dart';
import 'package:Budget_App/screens/login_page.dart';

import 'package:Budget_App/screens/privacy_page.dart';

import 'package:Budget_App/view_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:url_launcher/url_launcher.dart' show launchUrl;

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = ref.watch(themeProvider);

    /// For Notifications

    final notificationsEnabled = ref.watch(viewModel);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Settings",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Profile Section
          Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            elevation: 3,
            child: ListTile(
              leading: const CircleAvatar(
                radius: 25,
                backgroundImage: AssetImage("assets/profile.png"),
              ),
              title: Text(
                FirebaseAuth.instance.currentUser?.displayName ?? "User",
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              subtitle: Text(
                FirebaseAuth.instance.currentUser?.email ??
                    "No email available",
              ),
              trailing: IconButton(
                icon: const Icon(Icons.edit, color: Colors.deepPurple),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const EditProfilePage()),
                  );
                },
              ),
            ),
          ),

          const SizedBox(height: 20),

          // General Settings
          const Text(
            "General",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),

          _settingsTile(
            icon: Icons.dark_mode,
            title: "Dark Mode",
            subtitle: "Switch between light and dark theme",
            trailing: Switch(
              value: isDark,
              onChanged: (val) {
                ref.read(themeProvider.notifier).state = val;
              },
            ),
          ),
          _settingsTile(
            icon: Icons.notifications,
            title: "Notifications",
            subtitle: "Enable or disable app notifications",
            trailing: Switch(
              value: notificationsEnabled.notificationsEnabled,
              onChanged: (val) {
                ref.read(viewModel).toggleNotifications(val);

                // 🔔 Optionally integrate with flutter_local_notifications or FCM here
              },
            ),
          ),
          _settingsTile(
            icon: Icons.lock,
            title: "Privacy",
            subtitle: "Manage security & privacy settings",
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const PrivacyPage()),
              );
            },
          ),
          _settingsTile(
            icon: Icons.backup,
            title: "Backup & Restore",
            subtitle: "Backup data to cloud or restore",
            onTap: () {
              showDialog(
                context: context,
                builder:
                    (context) => AlertDialog(
                      title: const Text("Backup & Restore"),
                      content: const Text(
                        "This feature will be available soon.",
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text("OK"),
                        ),
                      ],
                    ),
              );
            },
          ),

          const SizedBox(height: 20),

          // Support Section
          const Text(
            "Support",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          _settingsTile(
            icon: Icons.help_outline,
            title: "Help & Support",
            subtitle: "Get assistance or FAQs",
            onTap: () {
              launchUrl(Uri.parse("mailto:support@budgetapp.com"));
            },
          ),
          _settingsTile(
            icon: Icons.info_outline,
            title: "About App",
            subtitle: "Learn more about this app",
            onTap: () {
              showAboutDialog(
                context: context,
                applicationName: "Budget App",
                applicationVersion: "1.0.0",
                applicationIcon: const Icon(Icons.account_balance_wallet),
                children: [
                  const Text(
                    "This app helps you manage your expenses & income.",
                  ),
                ],
              );
            },
          ),

          const SizedBox(height: 30),

          // Logout Button
          ElevatedButton.icon(
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => LoginPage()),
              );
            },
            icon: const Icon(Icons.logout),
            label: const Text("Logout"),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Reusable Settings Tile
  Widget _settingsTile({
    required IconData icon,
    required String title,
    String? subtitle,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.deepPurple.withOpacity(0.1),
          child: Icon(icon, color: Colors.deepPurple),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: subtitle != null ? Text(subtitle) : null,
        trailing: trailing ?? const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap,
      ),
    );
  }
}
