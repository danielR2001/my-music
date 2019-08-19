import 'package:firebase_auth/firebase_auth.dart';

class FirebaseAuthenticationManager {
  Future<FirebaseUser> createUserWithEmailAndPassword(String email, String password) async {
    FirebaseUser user;
    try {
      user = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      await user.sendEmailVerification();
      return user;
    } catch (e) {
      print("An error occured while trying to send email verification");
      print(e.message);
      return user;
    }
  }

  Future<FirebaseUser> signInWithEmailAndPassword(String email, String password) async {
    FirebaseUser user;
    try {
      user = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } catch (e) {
      print(e);
      user = null;
    }
    return user;
  }

  Future<FirebaseUser> currentUser() async {
    FirebaseUser user = await FirebaseAuth.instance.currentUser();
    if (user != null) {
      print("firebase User ID: " + user.uid);
    }
    return user;
  }

  Future<void> signOut() async {
    await FirebaseAuth.instance.signOut();
  }

  Future<bool> userReload() async {
    FirebaseUser user = await FirebaseAuth.instance.currentUser();
    await user.reload();
    user = await FirebaseAuth.instance.currentUser();
    bool flag = user.isEmailVerified;
    return flag;
  }
}
