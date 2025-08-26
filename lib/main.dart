import 'package:Budget_App/navBar/nav_bar_handler.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:url_strategy/url_strategy.dart';

import 'firebase_options.dart';
// 👈 add this import

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (kIsWeb) {
    setPathUrlStrategy();
  }
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Initialise Google-Sign-In once, up-front
  await GoogleSignIn.instance.initialize();
  GoogleFonts.config.allowRuntimeFetching = true;

  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 👈 read from Riverpod

    return MaterialApp(
      debugShowCheckedModeBanner: false,

      home: const BottomNavHandler(),
    );
  }
}
