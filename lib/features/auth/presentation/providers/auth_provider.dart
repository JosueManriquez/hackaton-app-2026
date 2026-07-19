import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../data/auth_repository.dart';
import '../../domain/models/user_model.dart';

class AuthProvider extends ChangeNotifier {
  final AuthRepository _authRepository;

  User? _currentUser;
  UserModel? _userData;
  bool _isLoading = true;
  String? _errorMessage;

  AuthProvider({AuthRepository? authRepository})
      : _authRepository = authRepository ?? AuthRepositoryImpl() {
    _init();
  }

  User? get currentUser => _currentUser;
  UserModel? get userData => _userData;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  void _init() {
    _authRepository.authStateChanges.listen((User? user) async {
      _isLoading = true;
      notifyListeners();

      _currentUser = user;
      if (user != null) {
        _userData = await _authRepository.getUserData(user.uid);
      } else {
        _userData = null;
      }

      _isLoading = false;
      notifyListeners();
    });
  }

  Future<bool> signIn(String email, String password) async {
    _setLoading(true);
    try {
      await _authRepository.signIn(email, password);
      _setLoading(false);
      return true;
    } on FirebaseAuthException catch (e) {
      _errorMessage = _getFirebaseErrorMessage(e);
      _setLoading(false);
      return false;
    } catch (e) {
      _errorMessage = "Ocurrió un error inesperado.";
      _setLoading(false);
      return false;
    }
  }

  Future<bool> signUp(String email, String password, String name) async {
    _setLoading(true);
    try {
      await _authRepository.signUp(email, password, name);
      _setLoading(false);
      return true;
    } on FirebaseAuthException catch (e) {
      _errorMessage = _getFirebaseErrorMessage(e);
      _setLoading(false);
      return false;
    } catch (e) {
      _errorMessage = "Ocurrió un error inesperado.";
      _setLoading(false);
      return false;
    }
  }

  Future<void> signOut() async {
    await _authRepository.signOut();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    _errorMessage = null; // Clear error on new action
    notifyListeners();
  }

  String _getFirebaseErrorMessage(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'No existe un usuario con este correo.';
      case 'wrong-password':
        return 'Contraseña incorrecta.';
      case 'email-already-in-use':
        return 'El correo ya está registrado.';
      case 'invalid-email':
        return 'El correo no es válido.';
      case 'weak-password':
        return 'La contraseña es muy débil (mínimo 6 caracteres).';
      default:
        return 'Error de autenticación: ${e.message}';
    }
  }
}
