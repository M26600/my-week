import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

/// Firebase configuration for the **My Week** app (web platform).
///
/// HOW TO FILL THIS IN (about 5 minutes, do it once):
///
///  1. Open https://console.firebase.google.com and sign in with Google.
///  2. Click **Create a project**, name it `my-week-app`, turn Google
///     Analytics **off**, then click **Create project**.
///  3. Left menu: **Build → Authentication → Get started**.
///     Choose **Email/Password**, switch it **on**, click **Save**.
///  4. Left menu: **Build → Firestore Database → Create database**.
///     Pick the suggested location, choose **Start in production mode**.
///     Then open the **Rules** tab, paste the rules below, click **Publish**:
///
///         rules_version = '2';
///         service cloud.firestore {
///           match /databases/{database}/documents {
///             match /users/{userId}/{document=**} {
///               allow read, write: if request.auth != null
///                                  && request.auth.uid == userId;
///             }
///           }
///         }
///
///  5. Project settings (the gear icon) → scroll to **Your apps** →
///     click the **Web** icon (`</>`) → nickname it `my-week-web` →
///     **Register app**. Firebase shows a `firebaseConfig` object.
///  6. Copy each value from that object into the matching `PASTE_...`
///     constant below, then **hot restart** the app. Done.
///
/// Until every `PASTE_...` value is replaced, the app shows a
/// "Firebase isn't set up yet" screen instead of a broken login screen.
class DefaultFirebaseOptions {
  DefaultFirebaseOptions._();

  // ---- Replace these six lines with the values from the Firebase console ----
  static const String _apiKey = 'PASTE_API_KEY_HERE';
  static const String _appId = 'PASTE_APP_ID_HERE';
  static const String _messagingSenderId = 'PASTE_SENDER_ID_HERE';
  static const String _projectId = 'PASTE_PROJECT_ID_HERE';
  static const String _authDomain = 'PASTE_AUTH_DOMAIN_HERE';
  static const String _storageBucket = 'PASTE_STORAGE_BUCKET_HERE';
  // --------------------------------------------------------------------------

  /// `true` once the placeholders above have been replaced with real values.
  static bool get isConfigured => !_apiKey.startsWith('PASTE_');

  /// Firebase options for the web build (`flutter run -d chrome`).
  static FirebaseOptions get web => FirebaseOptions(
        apiKey: _apiKey,
        appId: _appId,
        messagingSenderId: _messagingSenderId,
        projectId: _projectId,
        authDomain: _authDomain,
        storageBucket: _storageBucket,
      );

  /// Options for whichever platform the app is running on.
  ///
  /// Android reads `android/app/google-services.json` instead, so it does
  /// not need this object. Only web (and desktop) need explicit options.
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) return web;
    throw UnsupportedError(
      'DefaultFirebaseOptions is only configured for web in this project. '
      'On Android the app uses android/app/google-services.json.',
    );
  }
}
