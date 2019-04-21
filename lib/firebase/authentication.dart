import 'package:firebase_auth/firebase_auth.dart';

class FirebaseAuthentication {
  final GoogleAuthProvider _googleSignIn = GoogleAuthProvider();
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static FirebaseUser user;

  static Future<void> SignInWithEmail(String email, String password) async {
    try {
      user = await _auth
          .createUserWithEmailAndPassword(
        email: email,
        password: password,
      )
          .whenComplete(() {
        print("Register Completed");
      });
    } catch (e) {
      print("Register Failed!!! " + e);
    }
  }
}
