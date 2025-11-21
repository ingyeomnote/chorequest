/// Firebase Authentication Service
library;

import 'package:firebase_auth/firebase_auth.dart' as fb_auth;
import 'package:google_sign_in/google_sign_in.dart';
import '../utils/logger.dart';

/// Firebase Authentication Service
///
/// Handles user authentication including:
/// - Email/Password authentication
/// - Google Sign-In
/// - Password reset
/// - Auth state changes
class FirebaseAuthService {
  final fb_auth.FirebaseAuth _auth = fb_auth.FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final _log = Log.get('FirebaseAuthService');

  /// Get current user
  fb_auth.User? get currentUser => _auth.currentUser;

  /// Check if user is signed in
  bool get isSignedIn => currentUser != null;

  /// Auth state changes stream
  Stream<fb_auth.User?> get authStateChanges => _auth.authStateChanges();

  /// Sign in with email and password
  Future<fb_auth.User> signInWithEmail(String email, String password) async {
    try {
      _log.info('Signing in with email: $email');

      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (credential.user == null) {
        throw Exception('Sign in failed: no user returned');
      }

      _log.info('Sign in successful: ${credential.user!.uid}');
      return credential.user!;
    } on fb_auth.FirebaseAuthException catch (e) {
      _log.error('Sign in failed', e);
      throw _handleAuthException(e);
    } catch (e) {
      _log.error('Unexpected error during sign in', e);
      rethrow;
    }
  }

  /// Sign up with email and password
  Future<fb_auth.User> signUpWithEmail(String email, String password) async {
    try {
      _log.info('Creating account with email: $email');

      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (credential.user == null) {
        throw Exception('Sign up failed: no user returned');
      }

      _log.info('Account created: ${credential.user!.uid}');
      return credential.user!;
    } on fb_auth.FirebaseAuthException catch (e) {
      _log.error('Sign up failed', e);
      throw _handleAuthException(e);
    } catch (e) {
      _log.error('Unexpected error during sign up', e);
      rethrow;
    }
  }

  /// Sign in with Google
  Future<fb_auth.User> signInWithGoogle() async {
    try {
      _log.info('Starting Google Sign-In');

      // Trigger the authentication flow
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        throw Exception('Google sign in aborted by user');
      }

      // Obtain the auth details from the request
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      // Create a new credential
      final credential = fb_auth.GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in with the credential
      final userCredential = await _auth.signInWithCredential(credential);

      if (userCredential.user == null) {
        throw Exception('Google sign in failed: no user returned');
      }

      _log.info('Google sign in successful: ${userCredential.user!.uid}');
      return userCredential.user!;
    } on fb_auth.FirebaseAuthException catch (e) {
      _log.error('Google sign in failed', e);
      throw _handleAuthException(e);
    } catch (e) {
      _log.error('Unexpected error during Google sign in', e);
      rethrow;
    }
  }

  /// Send password reset email
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      _log.info('Sending password reset email to: $email');

      await _auth.sendPasswordResetEmail(email: email);

      _log.info('Password reset email sent');
    } on fb_auth.FirebaseAuthException catch (e) {
      _log.error('Failed to send password reset email', e);
      throw _handleAuthException(e);
    } catch (e) {
      _log.error('Unexpected error during password reset', e);
      rethrow;
    }
  }

  /// Update user display name
  Future<void> updateDisplayName(String displayName) async {
    try {
      final user = currentUser;
      if (user == null) {
        throw Exception('No user signed in');
      }

      _log.info('Updating display name: $displayName');

      await user.updateDisplayName(displayName);
      await user.reload();

      _log.info('Display name updated');
    } on fb_auth.FirebaseAuthException catch (e) {
      _log.error('Failed to update display name', e);
      throw _handleAuthException(e);
    } catch (e) {
      _log.error('Unexpected error during display name update', e);
      rethrow;
    }
  }

  /// Sign out
  Future<void> signOut() async {
    try {
      _log.info('Signing out');

      // Sign out from Google if signed in
      if (await _googleSignIn.isSignedIn()) {
        await _googleSignIn.signOut();
      }

      await _auth.signOut();

      _log.info('Sign out successful');
    } catch (e) {
      _log.error('Sign out failed', e);
      rethrow;
    }
  }

  /// Sign in anonymously (for guest access)
  Future<fb_auth.User> signInAnonymously() async {
    try {
      _log.info('Signing in anonymously');

      final credential = await _auth.signInAnonymously();

      if (credential.user == null) {
        throw Exception('Anonymous sign in failed: no user returned');
      }

      _log.info('Anonymous sign in successful: ${credential.user!.uid}');
      return credential.user!;
    } on fb_auth.FirebaseAuthException catch (e) {
      _log.error('Anonymous sign in failed', e);
      throw _handleAuthException(e);
    } catch (e) {
      _log.error('Unexpected error during anonymous sign in', e);
      rethrow;
    }
  }

  /// Check if current user is anonymous
  bool get isAnonymous => currentUser?.isAnonymous ?? false;

  /// Link anonymous account with email/password
  Future<fb_auth.User> linkWithEmail(String email, String password) async {
    try {
      final user = currentUser;
      if (user == null) {
        throw Exception('No user signed in');
      }

      if (!user.isAnonymous) {
        throw Exception('User is not anonymous');
      }

      _log.info('Linking anonymous account with email: $email');

      final credential = fb_auth.EmailAuthProvider.credential(
        email: email,
        password: password,
      );

      final userCredential = await user.linkWithCredential(credential);

      if (userCredential.user == null) {
        throw Exception('Account linking failed: no user returned');
      }

      _log.info('Account linked successfully');
      return userCredential.user!;
    } on fb_auth.FirebaseAuthException catch (e) {
      _log.error('Account linking failed', e);
      throw _handleAuthException(e);
    } catch (e) {
      _log.error('Unexpected error during account linking', e);
      rethrow;
    }
  }

  /// Delete user account
  Future<void> deleteAccount() async {
    try {
      final user = currentUser;
      if (user == null) {
        throw Exception('No user signed in');
      }

      _log.warning('Deleting user account: ${user.uid}');

      await user.delete();

      _log.info('Account deleted');
    } on fb_auth.FirebaseAuthException catch (e) {
      _log.error('Failed to delete account', e);
      throw _handleAuthException(e);
    } catch (e) {
      _log.error('Unexpected error during account deletion', e);
      rethrow;
    }
  }

  /// Handle Firebase Auth exceptions
  Exception _handleAuthException(fb_auth.FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return Exception('이메일이 등록되지 않았습니다.');
      case 'wrong-password':
        return Exception('비밀번호가 올바르지 않습니다.');
      case 'invalid-email':
        return Exception('이메일 형식이 올바르지 않습니다.');
      case 'user-disabled':
        return Exception('비활성화된 계정입니다.');
      case 'email-already-in-use':
        return Exception('이미 사용 중인 이메일입니다.');
      case 'weak-password':
        return Exception('비밀번호가 너무 약합니다. 6자 이상 입력하세요.');
      case 'operation-not-allowed':
        return Exception('이 로그인 방식은 현재 사용할 수 없습니다.');
      case 'requires-recent-login':
        return Exception('보안을 위해 다시 로그인해주세요.');
      default:
        return Exception('인증 오류: ${e.message}');
    }
  }
}
