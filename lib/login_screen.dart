import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'models/course.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _busy = false;
  String? _error;

  Future<void> _submit({required bool newAccount}) async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final auth = FirebaseAuth.instance;
      if (newAccount) {
        await auth.createUserWithEmailAndPassword(
          email: _email.text.trim(),
          password: _password.text,
        );
        await addSampleCourses();
      } else {
        await auth.signInWithEmailAndPassword(
          email: _email.text.trim(),
          password: _password.text,
        );
      }
      // No manual navigation here: AuthGate listens to authStateChanges()
      // and swaps in the WeekScreen as soon as the user is signed in.
    } on FirebaseAuthException catch (e) {
      debugPrint('FirebaseAuthException code: ${e.code}');
      if (mounted) setState(() => _error = _message(e.code));
    } catch (e) {
      debugPrint('Unexpected exception on login: $e');
      if (mounted) {
        setState(() => _error =
            'Could not reach Firebase. Check your connection and try again.');
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  String _message(String code) {
    switch (code) {
      case 'email-already-in-use':
        return 'An account with this email already exists. Log in instead.';
      case 'invalid-credential':
      case 'wrong-password':
      case 'user-not-found':
        return 'Wrong email or password.';
      case 'weak-password':
        return 'Choose a stronger password.';
      case 'network-request-failed':
        return 'No internet connection.';
      case 'operation-not-allowed':
        return 'Email/Password sign-in is disabled. Turn it on in the Firebase console.';
      case 'invalid-api-key':
      case 'api-key-not-valid':
        return 'The Firebase apiKey is wrong. Check lib/firebase_options.dart.';
      case 'unauthorized-domain':
        return 'This web domain is not authorized. Add it in Firebase console > Authentication > Settings.';
      default:
        return 'Something went wrong ($code).';
    }
  }

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'My Week',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.indigo,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Manage your courses in the cloud',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 32),
                TextFormField(
                  controller: _email,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.email_outlined),
                  ),
                  validator: (v) {
                    final email = (v ?? '').trim();
                    if (email.isEmpty) return 'Enter your email';
                    if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email)) {
                      return 'Enter a valid email, like aline@gmail.com';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _password,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'Password',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.lock_outline),
                  ),
                  validator: (v) =>
                      (v ?? '').length < 6 ? 'At least 6 characters' : null,
                ),
                const SizedBox(height: 16),
                if (_error != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Text(
                      _error!,
                      style: const TextStyle(color: Colors.red),
                      textAlign: TextAlign.center,
                    ),
                  ),
                FilledButton(
                  onPressed: _busy ? null : () => _submit(newAccount: false),
                  style: FilledButton.styleFrom(backgroundColor: Colors.indigo),
                  child: const Text('Log in'),
                ),
                const SizedBox(height: 8),
                OutlinedButton(
                  onPressed: _busy ? null : () => _submit(newAccount: true),
                  child: const Text('Create account'),
                ),
                if (_busy)
                  const Padding(
                    padding: EdgeInsets.only(top: 16),
                    child: Center(child: CircularProgressIndicator()),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
