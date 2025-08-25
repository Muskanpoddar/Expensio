import 'package:hooks_riverpod/hooks_riverpod.dart';

/// Example providers for privacy & security settings
final locationAccessProvider = StateProvider<bool>((ref) => false);
final storageAccessProvider = StateProvider<bool>((ref) => true);
final cameraAccessProvider = StateProvider<bool>((ref) => false);

final analyticsProvider = StateProvider<bool>((ref) => true);
final crashReportProvider = StateProvider<bool>((ref) => true);
final biometricProvider = StateProvider<bool>((ref) => false);
