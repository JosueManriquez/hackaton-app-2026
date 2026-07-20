import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../domain/models/user_model.dart';

abstract class AuthRepository {
  Stream<User?> get authStateChanges;
  Future<UserModel?> getUserData(String uid);
  Future<UserCredential> signIn(String email, String password);
  Future<UserCredential> signUp(String email, String password, String name);
  Future<void> signOut();
}

class AuthRepositoryImpl implements AuthRepository {
  final FirebaseAuth _firebaseAuth;
  final FirebaseFirestore _firestore;

  AuthRepositoryImpl({
    FirebaseAuth? firebaseAuth,
    FirebaseFirestore? firestore,
  })  : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance,
        _firestore = firestore ?? FirebaseFirestore.instance;

  @override
  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();

  @override
  Future<UserModel?> getUserData(String uid) async {
    try {
      final doc = await _firestore.collection('usuarios').doc(uid).get();
      if (doc.exists && doc.data() != null) {
        return UserModel.fromMap(doc.data()!, doc.id);
      }
    } catch (e) {
      // Ignorar error y devolver null
    }
    return null;
  }

  @override
  Future<UserCredential> signIn(String email, String password) async {
    return await _firebaseAuth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
  }

  @override
  Future<UserCredential> signUp(String email, String password, String name) async {
    // 1. Crear usuario en Firebase Auth
    final userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );

    // 2. Guardar datos adicionales en Firestore
    if (userCredential.user != null) {
      final userModel = UserModel(
        uid: userCredential.user!.uid,
        email: email.trim(),
        displayName: name.trim(),
        rol: 'ciudadano', // Por defecto todos son ciudadanos en la app móvil
        estado: 'activo',
      );
      
      await _firestore
          .collection('usuarios')
          .doc(userCredential.user!.uid)
          .set(userModel.toMap());
    }

    return userCredential;
  }

  @override
  Future<void> signOut() async {
    await _firebaseAuth.signOut();
  }
}
