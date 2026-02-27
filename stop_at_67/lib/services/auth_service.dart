import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  Stream<User?> get authStateChanges => _auth.authStateChanges();
  User? get currentUser => _auth.currentUser;
  bool get isSignedIn => _auth.currentUser != null;

  /// Sign in with Google. Returns the signed-in User or null on failure.
  Future<User?> signInWithGoogle() async {
    try {
      final googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return null;
      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      final result = await _auth.signInWithCredential(credential);
      final user = result.user;
      if (user != null) {
        await _upsertUserDoc(
          uid: user.uid,
          displayName: user.displayName ?? googleUser.displayName ?? 'Player',
          isAnonymous: false,
        );
      }
      return user;
    } catch (_) {
      return null;
    }
  }

  /// Sign in anonymously with a chosen display name.
  Future<User?> signInAnonymous(String displayName) async {
    try {
      final result = await _auth.signInAnonymously();
      final user = result.user;
      if (user != null) {
        await _upsertUserDoc(
          uid: user.uid,
          displayName: displayName.trim(),
          isAnonymous: true,
        );
      }
      return user;
    } catch (_) {
      return null;
    }
  }

  /// Fetch display name from Firestore (falls back to Google name or uid).
  Future<String?> getDisplayName(User user) async {
    try {
      final doc = await _db.collection('users').doc(user.uid).get();
      if (doc.exists) {
        return doc.data()?['displayName'] as String?;
      }
      return user.displayName;
    } catch (_) {
      return user.displayName;
    }
  }

  Future<void> signOut() async {
    await Future.wait([
      _auth.signOut(),
      _googleSignIn.signOut(),
    ]);
  }

  Future<void> _upsertUserDoc({
    required String uid,
    required String displayName,
    required bool isAnonymous,
  }) async {
    final ref = _db.collection('users').doc(uid);
    await ref.set({
      'displayName': displayName,
      'isAnonymous': isAnonymous,
      'createdAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }
}
