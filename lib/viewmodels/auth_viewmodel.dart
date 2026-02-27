import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:google_sign_in/google_sign_in.dart';
import '../models/models.dart';

class AuthViewModel extends ChangeNotifier {
  final firebase_auth.FirebaseAuth _auth = firebase_auth.FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn.instance;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  firebase_auth.User? _firebaseUser;
  bool get isAuthenticated => _firebaseUser != null;

  User? _userProfile;
  User? get userProfile => _userProfile;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  AuthViewModel() {
    _initializeGoogleSignIn();
    _listenToAuthState();
  }

  void _listenToAuthState() {
    _auth.authStateChanges().listen((firebase_auth.User? user) {
      _firebaseUser = user;
      if (user != null) {
        _createUserProfile();
      } else {
        _userProfile = null;
      }
      notifyListeners();
    });
  }

  Future<void> _initializeGoogleSignIn() async {
    try {
      await _googleSignIn.initialize();
    } catch (e) {
      debugPrint('GoogleSignIn initialization failed: $e');
    }
  }

  // ================= LOGIN =================
  Future<bool> login(String email, String password) async {
    // Clear errors and show loading
    _errorMessage = null;
    _isLoading = true;
    notifyListeners();

    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      // Auth state listener will handle the user update
      _isLoading = false;
      notifyListeners();
      return true;
    } on firebase_auth.FirebaseAuthException catch (e) {
      debugPrint('FirebaseAuth Error [${e.code}]: ${e.message}');
      _handleAuthError(e);
    } catch (e) {
      debugPrint('Unexpected login error: $e');
      _errorMessage = 'An unexpected error occurred: $e';
    }

    _isLoading = false;
    notifyListeners();
    return false;
  }

  // ================= SIGNUP =================
  Future<bool> signup(String email, String password) async {
    // Clear errors and show loading
    _errorMessage = null;
    _isLoading = true;
    notifyListeners();

    try {
      await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      // Auth state listener will handle the user update
      _isLoading = false;
      notifyListeners();
      return true;
    } on firebase_auth.FirebaseAuthException catch (e) {
      debugPrint('FirebaseAuth Error [${e.code}]: ${e.message}');
      _handleAuthError(e);
    } catch (e) {
      debugPrint('Unexpected signup error: $e');
      _errorMessage = 'An unexpected error occurred: $e';
    }

    _isLoading = false;
    notifyListeners();
    return false;
  }

  // ================= GOOGLE SIGN IN =================
  Future<bool> signInWithGoogle() async {
    _errorMessage = null;
    _isLoading = true;
    notifyListeners();

    try {
      final account = await _googleSignIn.authenticate();

      final auth = await account.authorizationClient.authorizationForScopes([
        'email',
        'profile',
      ]);

      if (auth == null) {
        _errorMessage = 'Google authorization failed.';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      final credential = firebase_auth.GoogleAuthProvider.credential(
        accessToken: auth.accessToken,
        idToken: null,
      );

      await _auth.signInWithCredential(credential);
      _isLoading = false;
      notifyListeners();
      return true;
    } on firebase_auth.FirebaseAuthException catch (e) {
      debugPrint('FirebaseAuth Error [${e.code}]: ${e.message}');
      _handleAuthError(e);
    } catch (e) {
      debugPrint('Unexpected Google sign-in error: $e');
      _errorMessage = e.toString();
    }

    _isLoading = false;
    notifyListeners();
    return false;
  }

  // ================= LOGOUT =================
  Future<void> logout() async {
    try {
      await _auth.signOut();
      await _googleSignIn.signOut();
    } catch (e) {
      debugPrint('Logout error: $e');
    }
    // authStateChanges listener will clear _firebaseUser and _userProfile
  }

  // ================= HELPER METHODS =================

  void _createUserProfile() {
    final email = _firebaseUser!.email ?? '';
    final displayName = _firebaseUser!.displayName;
    final emailPrefix = email.contains('@') ? email.split('@')[0] : 'User';
    final name = displayName?.isNotEmpty == true ? displayName! : emailPrefix;

    _userProfile = User(
      id: 1,
      username: name,
      email: email,
      name: {
        'firstname': name.split(' ').first,
        'lastname': name.contains(' ') ? name.split(' ').last : '',
      },
      address: {
        'city': '',
        'street': '',
        'number': 0,
        'zipcode': '',
        'geolocation': {'lat': '', 'long': ''},
      },
      phone: '',
    );
  }

  void _handleAuthError(firebase_auth.FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        _errorMessage = 'No user found for that email.';
        break;
      case 'wrong-password':
        _errorMessage = 'Wrong password provided.';
        break;
      case 'invalid-credential':
        _errorMessage = 'Invalid email or password. Please try again.';
        break;
      case 'weak-password':
        _errorMessage = 'Password must be at least 6 characters.';
        break;
      case 'email-already-in-use':
        _errorMessage = 'An account already exists with this email.';
        break;
      case 'invalid-email':
        _errorMessage = 'The email address is not valid.';
        break;
      case 'too-many-requests':
        _errorMessage = 'Too many attempts. Please try again later.';
        break;
      case 'network-request-failed':
        _errorMessage = 'No internet connection. Please try again.';
        break;
      default:
        _errorMessage = e.message ?? 'Authentication failed (${e.code})';
    }
  }
}
