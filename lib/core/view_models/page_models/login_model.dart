import 'package:firebase_auth/firebase_auth.dart';
import 'package:myapp/core/enums/page_state.dart';
import 'package:myapp/locater.dart';
import 'package:myapp/core/services/authentication_service.dart';
import 'package:myapp/core/view_models/page_models/base_model.dart';

class LoginModel extends BaseModel {
  final AuthenticationService _authenticationService =
      locator<AuthenticationService>();
  String _email = "";
  String _password = "";

  Future<bool> login(FirebaseUser firebaseUser) async {
    setState(PageState.Busy);
    bool response;

    response = await _authenticationService.login(firebaseUser);

    setState(PageState.Idle);
    return response;
  }

  Future<FirebaseUser> signInWithEmailAndPassword() async {
    setState(PageState.Busy);
    FirebaseUser response;

    response = await _authenticationService.signInWithEmailAndPassword(_email, _password);

    setState(PageState.Idle);
    return response;
  }

  bool checkForValidEmail(String email) {
    return RegExp(r"^[a-zA-Z0-9.]+@[a-zA-Z0-9]+\.[a-zA-Z]+").hasMatch(email);
  }

  String get email => _email;

  String get password => _password;

  set setEmail(String email) => _email = email;

  set setPassword(String password) => _password = password;
}
