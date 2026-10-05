import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/user_model.dart';
import '../core/constants/app_constants.dart';

class AuthService extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  User? _firebaseUser;
  UserModel? _currentUser;
  bool _loading = false;
  String? _error;

  User? get firebaseUser => _firebaseUser;
  UserModel? get currentUser => _currentUser;
  UserModel? get userModel => _currentUser;
  bool get loading => _loading;
  String? get error => _error;
  bool get isLoggedIn => _firebaseUser != null;
  bool get isAdmin => _currentUser?.isAdmin ?? false;

  Future<void> signOut() => logout();

  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email.trim());
    } catch (e) {
      debugPrint('AuthService.sendPasswordResetEmail: $e');
    }
  }

  AuthService() {
    _auth.authStateChanges().listen(_onAuthStateChanged);
  }

  Future<void> _onAuthStateChanged(User? user) async {
    _firebaseUser = user;
    if (user != null) {
      await _loadCurrentUser(user.uid);
    } else {
      _currentUser = null;
    }
    notifyListeners();
  }

  Future<void> _loadCurrentUser(String uid) async {
    try {
      final doc = await _firestore.collection(AppConstants.usersCol).doc(uid).get();
      if (doc.exists && doc.data() != null) {
        _currentUser = UserModel.fromMap(doc.data()!, doc.id);
      }
    } catch (e) {
      debugPrint('AuthService._loadCurrentUser error: $e');
    }
  }

  /// Register a new student
  Future<String?> register({
    required String fullName,
    required String email,
    required String password,
  }) async {
    _setLoading(true);
    _clearError();
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      final uid = credential.user!.uid;
      final now = DateTime.now();
      final user = UserModel(
        userId: uid,
        fullName: fullName.trim(),
        email: email.trim(),
        role: AppConstants.roleStudent,
        createdAt: now,
        updatedAt: now,
      );
      await _firestore.collection(AppConstants.usersCol).doc(uid).set(user.toMap());
      _currentUser = user;
      _setLoading(false);
      return null; // success
    } on FirebaseAuthException catch (e) {
      _setError(_authErrorMessage(e.code));
      _setLoading(false);
      return _error;
    } catch (e) {
      _setError('Registration failed. Please try again.');
      _setLoading(false);
      return _error;
    }
  }

  /// Login with email and password
  Future<String?> login({
    required String email,
    required String password,
  }) async {
    _setLoading(true);
    _clearError();
    try {
      await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      _setLoading(false);
      return null; // success
    } on FirebaseAuthException catch (e) {
      _setError(_authErrorMessage(e.code));
      _setLoading(false);
      return _error;
    } catch (e) {
      _setError('Login failed. Please try again.');
      _setLoading(false);
      return _error;
    }
  }

  /// Logout
  Future<void> logout() async {
    await _auth.signOut();
    _currentUser = null;
    notifyListeners();
  }

  /// Update profile fields
  Future<String?> updateProfile({
    required String fullName,
    String? phone,
    String? bio,
    String? profileImage,
  }) async {
    if (_currentUser == null) return 'Not logged in';
    _setLoading(true);
    try {
      final updated = _currentUser!.copyWith(
        fullName: fullName,
        phone: phone,
        bio: bio,
        profileImage: profileImage,
        updatedAt: DateTime.now(),
      );
      await _firestore
          .collection(AppConstants.usersCol)
          .doc(_currentUser!.userId)
          .update(updated.toMap());
      _currentUser = updated;
      _setLoading(false);
      notifyListeners();
      return null;
    } catch (e) {
      _setLoading(false);
      return 'Profile update failed: $e';
    }
  }

  /// Reload current user from Firestore
  Future<void> reloadUser() async {
    if (_firebaseUser != null) {
      await _loadCurrentUser(_firebaseUser!.uid);
      notifyListeners();
    }
  }

  // ── Helpers ─────────────────────────────────────────────────────────────────
  void _setLoading(bool value) {
    _loading = value;
    notifyListeners();
  }

  void _setError(String msg) {
    _error = msg;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
  }

  String _authErrorMessage(String code) {
    switch (code) {
      case 'user-not-found':
        return 'No account found with this email.';
      case 'wrong-password':
        return 'Incorrect password. Please try again.';
      case 'email-already-in-use':
        return 'An account already exists with this email.';
      case 'weak-password':
        return 'Password is too weak. Use at least 6 characters.';
      case 'invalid-email':
        return 'Invalid email address.';
      case 'user-disabled':
        return 'This account has been disabled.';
      case 'too-many-requests':
        return 'Too many failed attempts. Try again later.';
      case 'network-request-failed':
        return 'Network error. Check your connection.';
      case 'invalid-credential':
        return 'Invalid email or password.';
      default:
        return 'Authentication error. Please try again.';
    }
  }
}
