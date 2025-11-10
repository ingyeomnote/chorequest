import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:flutter_app/models/user_model.dart';
import 'package:flutter_app/services/firebase_auth_service.dart';
import 'package:flutter_app/repositories/user_repository.dart';
import 'package:flutter_app/utils/logger.dart';

/// Authentication Provider
///
/// Manages user authentication state using:
/// - FirebaseAuthService for authentication
/// - UserRepository for user data (Firestore + Hive cache)
/// - Auth state listener for automatic session management
class AuthProvider extends ChangeNotifier {
  final FirebaseAuthService _authService;
  final UserRepository _userRepository;
  final _log = Log.get('AuthProvider');

  StreamSubscription<firebase_auth.User?>? _authStateSubscription;

  UserModel? _currentUser;
  UserModel? get currentUser => _currentUser;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool get isAuthenticated => _currentUser != null;

  AuthProvider({
    required FirebaseAuthService authService,
    required UserRepository userRepository,
  })  : _authService = authService,
        _userRepository = userRepository {
    _initAuthStateListener();
  }

  // ==================== Initialization ====================

  /// Initialize auth state listener
  void _initAuthStateListener() {
    _log.info('Initializing auth state listener');
    _authStateSubscription = _authService.authStateChanges.listen(
      _onAuthStateChanged,
      onError: (error) {
        _log.error('Auth state listener error', error);
      },
    );
  }

  /// Handle auth state changes
  Future<void> _onAuthStateChanged(firebase_auth.User? firebaseUser) async {
    _log.info('Auth state changed: ${firebaseUser?.uid}');

    if (firebaseUser == null) {
      // User signed out
      _currentUser = null;
      notifyListeners();
      return;
    }

    // User signed in - load user data from Firestore
    try {
      _isLoading = true;
      notifyListeners();

      final user = await _userRepository.getUser(firebaseUser.uid);

      if (user == null) {
        // First time sign in - create user in Firestore
        _log.info('First time sign in, creating user document');
        final newUser = UserModel(
          id: firebaseUser.uid,
          name: firebaseUser.displayName ?? '',
          email: firebaseUser.email ?? '',
          avatarUrl: firebaseUser.photoURL,
        );
        await _userRepository.createUser(newUser);
        _currentUser = newUser;
      } else {
        _currentUser = user;
      }

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _log.error('Failed to load user data', e);
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  // ==================== Authentication ====================

  /// Sign up with email and password
  Future<UserModel> signUpWithEmail({
    required String email,
    required String password,
    required String name,
  }) async {
    try {
      _isLoading = true;
      notifyListeners();

      _log.info('Signing up with email: $email');

      // 1. Create Firebase Auth account
      final firebaseUser = await _authService.signUpWithEmail(email, password);

      // 2. Update display name
      await _authService.updateDisplayName(name);

      // 3. Create user in Firestore (auth state listener will handle this)
      // But we'll do it explicitly here for better control
      final user = UserModel(
        id: firebaseUser.uid,
        name: name,
        email: email,
      );
      await _userRepository.createUser(user);

      _currentUser = user;
      _isLoading = false;
      notifyListeners();

      _log.info('Sign up successful');
      return user;
    } catch (e) {
      _log.error('Sign up failed', e);
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  /// Sign in with email and password
  Future<void> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      _isLoading = true;
      notifyListeners();

      _log.info('Signing in with email: $email');

      // Firebase Auth will trigger auth state listener
      await _authService.signInWithEmail(email, password);

      _log.info('Sign in successful');
      // _isLoading will be set to false in _onAuthStateChanged
    } catch (e) {
      _log.error('Sign in failed', e);
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  /// Sign in with Google
  Future<void> signInWithGoogle() async {
    try {
      _isLoading = true;
      notifyListeners();

      _log.info('Signing in with Google');

      // Firebase Auth will trigger auth state listener
      await _authService.signInWithGoogle();

      _log.info('Google sign in successful');
      // _isLoading will be set to false in _onAuthStateChanged
    } catch (e) {
      _log.error('Google sign in failed', e);
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  /// Sign out
  Future<void> signOut() async {
    try {
      _log.info('Signing out');

      await _authService.signOut();
      await _userRepository.clearCache();

      _currentUser = null;
      notifyListeners();

      _log.info('Sign out successful');
    } catch (e) {
      _log.error('Sign out failed', e);
      rethrow;
    }
  }

  /// Send password reset email
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      _log.info('Sending password reset email to: $email');
      await _authService.sendPasswordResetEmail(email);
      _log.info('Password reset email sent');
    } catch (e) {
      _log.error('Failed to send password reset email', e);
      rethrow;
    }
  }

  // ==================== Profile Management ====================

  /// Update user profile
  Future<void> updateProfile({
    String? name,
    String? avatarUrl,
  }) async {
    if (_currentUser == null) {
      _log.warning('Cannot update profile: user not authenticated');
      return;
    }

    try {
      _log.info('Updating profile');

      // Update Firebase Auth display name if provided
      if (name != null) {
        await _authService.updateDisplayName(name);
      }

      // Update user model
      final updatedUser = _currentUser!.copyWith(
        name: name,
        avatarUrl: avatarUrl,
      );

      // Update in Firestore (and cache)
      await _userRepository.updateUser(updatedUser);

      _currentUser = updatedUser;
      notifyListeners();

      _log.info('Profile updated successfully');
    } catch (e) {
      _log.error('Failed to update profile', e);
      rethrow;
    }
  }

  // ==================== Household Management ====================

  /// Join a household
  Future<void> joinHousehold(String householdId) async {
    if (_currentUser == null) {
      _log.warning('Cannot join household: user not authenticated');
      return;
    }

    try {
      _log.info('Joining household: $householdId');

      final updatedUser = _currentUser!.copyWith(householdId: householdId);
      await _userRepository.updateUser(updatedUser);

      _currentUser = updatedUser;
      notifyListeners();

      _log.info('Joined household successfully');
    } catch (e) {
      _log.error('Failed to join household', e);
      rethrow;
    }
  }

  /// Leave current household
  Future<void> leaveHousehold() async {
    if (_currentUser == null) {
      _log.warning('Cannot leave household: user not authenticated');
      return;
    }

    try {
      _log.info('Leaving household');

      final updatedUser = _currentUser!.copyWith(householdId: '');
      await _userRepository.updateUser(updatedUser);

      _currentUser = updatedUser;
      notifyListeners();

      _log.info('Left household successfully');
    } catch (e) {
      _log.error('Failed to leave household', e);
      rethrow;
    }
  }

  // ==================== XP & Progression ====================

  /// Gain XP (called by ChoreProvider when chore is completed)
  Future<void> gainXp(int amount) async {
    if (_currentUser == null) {
      _log.warning('Cannot gain XP: user not authenticated');
      return;
    }

    try {
      _log.info('Gaining $amount XP');

      // Use repository's atomic transaction
      await _userRepository.incrementXp(_currentUser!.id, amount);

      // Refresh current user to get updated XP and level
      await refreshCurrentUser();

      _log.info('XP gained successfully');
    } catch (e) {
      _log.error('Failed to gain XP', e);
      rethrow;
    }
  }

  // ==================== Utility ====================

  /// Refresh current user data from Firestore
  Future<void> refreshCurrentUser() async {
    if (_currentUser == null) {
      _log.warning('Cannot refresh: user not authenticated');
      return;
    }

    try {
      _log.info('Refreshing current user');

      // Refresh cache from Firestore
      await _userRepository.refreshCache(_currentUser!.id);

      // Get updated user from cache
      final refreshedUser = await _userRepository.getUser(_currentUser!.id);
      if (refreshedUser != null) {
        _currentUser = refreshedUser;
        notifyListeners();
      }

      _log.info('User refreshed successfully');
    } catch (e) {
      _log.error('Failed to refresh user', e);
      rethrow;
    }
  }

  // ==================== Lifecycle ====================

  @override
  void dispose() {
    _log.info('Disposing AuthProvider');
    _authStateSubscription?.cancel();
    super.dispose();
  }
}
