import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:myapp/core/database/local/local_database_manager.dart';
import 'package:myapp/core/database/firebase/authentication_manager.dart';
import 'package:myapp/core/database/firebase/database_manager.dart';
import 'package:myapp/core/services/audio_player_service.dart';
import 'package:myapp/core/services/connectivity_service.dart';
import 'package:myapp/locater.dart';
import 'package:myapp/models/user.dart';

class AuthenticationService {
  final FirebaseDatabaseManager _firebaseDatabaseManager =
      locator<FirebaseDatabaseManager>();
  final FirebaseAuthenticationManager _firebaseAuthenticationManager =
      locator<FirebaseAuthenticationManager>();
  final LocalDatabaseManager _localDatabaseManager =
      locator<LocalDatabaseManager>();
  final ConnectivityService _connectivityService =
      locator<ConnectivityService>();
  final AudioPlayerService _audioPlayerService = locator<AudioPlayerService>();

  StreamController<User> userController = StreamController<User>();

  Future<bool> login(FirebaseUser firebaseUser) async {
    if (_connectivityService.isNetworkAvailable) {
      User user = await _firebaseDatabaseManager.syncUser(firebaseUser.uid);
      if (user != null) {
        userController.add(user);
        bool permissionGranted =
            await _localDatabaseManager.checkIfStoragePermissionGranted();
        if (permissionGranted) {
          await _localDatabaseManager.initDirs();
          _localDatabaseManager.syncDownloaded();
        }
        return true;
      } else {
        return false;
      }
    } else {
      //! TODO handle the offline toast
      userController.add(User(firebaseUser.email, firebaseUser.uid));
      bool permissionGranted =
          await _localDatabaseManager.checkIfStoragePermissionGranted();
      if (permissionGranted) {
        await _localDatabaseManager.initDirs();
        _localDatabaseManager.syncDownloaded();
      }
      return true;
    }
  }

  Future<void> signUp(String userName) async {
    FirebaseUser firebaseUser =
        await _firebaseAuthenticationManager.currentUser();
    User currentUser = User(userName, firebaseUser.uid);
    userController.add(currentUser);
    _firebaseDatabaseManager.saveUser(currentUser);
    _firebaseDatabaseManager.syncUser(firebaseUser.uid);
  }

  Future<void> logout() async {
    await _localDatabaseManager.deleteDownloadedDirectory();
    await _firebaseAuthenticationManager.signOut();
    await _audioPlayerService.releasePlaylist();
    userController.add(null);
  }

  Future<bool> createUserWithEmailAndPassword(
      String email, String password) async {
    FirebaseUser firebaseUser = await _firebaseAuthenticationManager
        .createUserWithEmailAndPassword(email, password);
    if (firebaseUser != null) {
      return true;
    } else {
      return false;
    }
  }

  Future<FirebaseUser> signInWithEmailAndPassword(
      String email, String password) async {
    return await _firebaseAuthenticationManager.signInWithEmailAndPassword(
        email, password);
  }

  Future<bool> checkIfVerified() async {
    bool isEmailVerified = await _firebaseAuthenticationManager.userReload();
    if (isEmailVerified) {
      return true;
    } else {
      return false;
    }
  }

  Future<FirebaseUser> checkIfLoggedIn() async {
    return await _firebaseAuthenticationManager.currentUser();
  }
}
