import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'auth_gate.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Web has no google-services.json, so it needs the options in
  // firebase_options.dart. If they are still placeholders, stop here and
  // show a clear "set up Firebase" screen instead of a broken login screen.
  if (kIsWeb && !DefaultFirebaseOptions.isConfigured) {
    runApp(const FirebaseNotConfiguredApp());
    return;
  }

  try {
    if (kIsWeb) {
      await Firebase.initializeApp(options: DefaultFirebaseOptions.web);
    } else {
      await Firebase.initializeApp();
    }
  } catch (e) {
    debugPrint('Firebase.initializeApp exception: $e');
    runApp(FirebaseInitErrorApp(error: e.toString()));
    return;
  }

  runApp(const MyWeekApp());
}

class MyWeekApp extends StatelessWidget {
  const MyWeekApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'My Week',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.indigo,
          primary: Colors.indigo,
        ),
        scaffoldBackgroundColor: const Color(0xFFF5F5F7),
        appBarTheme: const AppBarTheme(
          centerTitle: false,
          elevation: 0,
        ),
      ),
      home: const AuthGate(),
    );
  }
}

/// Shown on web until the six `PASTE_...` values in `firebase_options.dart`
/// are replaced with the real values from the Firebase console.
class FirebaseNotConfiguredApp extends StatelessWidget {
  const FirebaseNotConfiguredApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'My Week',
      debugShowCheckedModeBanner: false,
      home: const _FirebaseMessageScreen(
        icon: Icons.settings_suggest_rounded,
        title: "Firebase isn't set up yet",
        message:
            'Open lib/firebase_options.dart and replace the six PASTE_... '
            'values with your real Firebase web config, then hot restart.',
        steps: [
          'Create a project at console.firebase.google.com',
          'Enable Authentication > Email/Password',
          'Create a Firestore database (production mode) and publish the rules in firestore.rules',
          'Register a Web app and copy its firebaseConfig values',
          'Paste those values into lib/firebase_options.dart',
        ],
      ),
    );
  }
}

/// Shown when Firebase is configured but `initializeApp` still failed
/// (for example a wrong apiKey, offline, or a blocked domain).
class FirebaseInitErrorApp extends StatelessWidget {
  final String error;

  const FirebaseInitErrorApp({super.key, required this.error});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'My Week',
      debugShowCheckedModeBanner: false,
      home: _FirebaseMessageScreen(
        icon: Icons.error_outline_rounded,
        title: 'Could not start Firebase',
        message: error,
        steps: const [
          'Check that your internet connection is working',
          'Check that the values in lib/firebase_options.dart match the Firebase console',
          'For web, add your site (for example localhost) under Authentication > Settings > Authorized domains',
        ],
      ),
    );
  }
}

class _FirebaseMessageScreen extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;
  final List<String> steps;

  const _FirebaseMessageScreen({
    required this.icon,
    required this.title,
    required this.message,
    required this.steps,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 560),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(icon, size: 64, color: Colors.indigo),
                  const SizedBox(height: 16),
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.indigo,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(message, style: const TextStyle(fontSize: 15)),
                  const SizedBox(height: 20),
                  const Text(
                    'Checklist',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  ...steps.asMap().entries.map(
                        (e) => Padding(
                          padding: const EdgeInsets.only(bottom: 6),
                          child: Text('${e.key + 1}. ${e.value}'),
                        ),
                      ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
