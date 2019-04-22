import 'package:firebase_auth/firebase_auth.dart';
import 'package:myapp/models/user.dart';

class FirebaseAuthentication {
  static Future<FirebaseUser> signInWithEmail(
      String email, String password) async {
    try {
      FirebaseUser user =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      print("firebase User ID: " + user.uid);
      return user;
    } catch (e) {
      print(e);
      return null;
    }
  }

  static Future<FirebaseUser> logInWithEmail(
      String email, String password) async {
    try {
      FirebaseUser user =
          await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      print("firebase User ID: " + user.uid);
      return user;
    } catch (e) {
      print(e);
      return null;
    }
  }

  static Future<FirebaseUser> currentUser() async {
    FirebaseUser user = await FirebaseAuth.instance.currentUser();
    if (user != null) {
      print("firebase User ID: " + user.uid);
    }
    return user;
  }

  static Future<void> signOut() async {
    await FirebaseAuth.instance.signOut();
  }

  void createUser() {
    //User
  }
}
