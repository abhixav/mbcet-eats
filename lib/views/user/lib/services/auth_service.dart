import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Sign up with college email and password
  Future<UserCredential> signUp(String collegeId, String password) async {
    final email = _collegeEmail(collegeId);
    return await _auth.createUserWithEmailAndPassword(email: email, password: password);
  }

  /// Login with college email and password
  Future<UserCredential> login(String collegeId, String password) async {
    final email = _collegeEmail(collegeId);
    return await _auth.signInWithEmailAndPassword(email: email, password: password);
  }

  String _collegeEmail(String id) {
    final name = id.replaceAll(RegExp(r'\s+'), '').toLowerCase();
    return "$name@mbcet.ac.in";
  }

  User? get currentUser => _auth.currentUser;
}
