import 'package:firebase_database/firebase_database.dart';
import 'package:myapp/main.dart';

class FirebaseDatabaseManager {
  static final String _usersDirectory = "users/";
  static var _userDirectory;

  static void saveUser() {
    _userDirectory =
        FirebaseDatabase.instance.reference().child(_usersDirectory).push();
    _userDirectory.set({
      'userName': currentUser.getName,
      'user Id': currentUser.getFirebaseUId
    });
  }

  static void addPlaylist() {
    _userDirectory.push().set({
      'userName': currentUser.getName,
      'user Id': currentUser.getFirebaseUId
    });
  }
}
