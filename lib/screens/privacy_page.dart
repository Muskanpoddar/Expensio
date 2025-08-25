import 'package:Budget_App/screens/provider/privacy_provider.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';


class PrivacyPage extends ConsumerWidget {
  const PrivacyPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locationAccess = ref.watch(locationAccessProvider);
    final storageAccess = ref.watch(storageAccessProvider);
    final cameraAccess = ref.watch(cameraAccessProvider);

    final analytics = ref.watch(analyticsProvider);
    final crashReports = ref.watch(crashReportProvider);
    final biometric = ref.watch(biometricProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Privacy & Security"),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            "Permissions",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),

          _settingsTile(
            icon: Icons.location_on,
            title: "Location Access",
            subtitle: "Allow app to use location data",
            trailing: Switch(
              value: locationAccess,
              onChanged:
                  (val) =>
                      ref.read(locationAccessProvider.notifier).state = val,
            ),
          ),
          _settingsTile(
            icon: Icons.storage,
            title: "Storage Access",
            subtitle: "Allow app to access local storage",
            trailing: Switch(
              value: storageAccess,
              onChanged:
                  (val) => ref.read(storageAccessProvider.notifier).state = val,
            ),
          ),
          _settingsTile(
            icon: Icons.camera_alt,
            title: "Camera Access",
            subtitle: "Allow app to access your camera",
            trailing: Switch(
              value: cameraAccess,
              onChanged:
                  (val) => ref.read(cameraAccessProvider.notifier).state = val,
            ),
          ),

          const SizedBox(height: 20),
          const Text(
            "Data & Security",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),

          _settingsTile(
            icon: Icons.analytics,
            title: "Share Analytics",
            subtitle: "Help us improve by sharing usage data",
            trailing: Switch(
              value: analytics,
              onChanged:
                  (val) => ref.read(analyticsProvider.notifier).state = val,
            ),
          ),
          _settingsTile(
            icon: Icons.bug_report,
            title: "Crash Reports",
            subtitle: "Automatically send crash logs",
            trailing: Switch(
              value: crashReports,
              onChanged:
                  (val) => ref.read(crashReportProvider.notifier).state = val,
            ),
          ),
          _settingsTile(
            icon: Icons.fingerprint,
            title: "Biometric Login",
            subtitle: "Use fingerprint or face ID to login",
            trailing: Switch(
              value: biometric,
              onChanged:
                  (val) => ref.read(biometricProvider.notifier).state = val,
            ),
          ),
        ],
      ),
    );
  }

  Widget _settingsTile({
    required IconData icon,
    required String title,
    String? subtitle,
    Widget? trailing,
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
        trailing: trailing,
      ),
    );
  }
}
