import 'package:myapp/core/page_state/page_state.dart';
import 'package:myapp/locater.dart';
import 'package:myapp/core/services/authentication_service.dart';
import 'package:myapp/core/view_models/page_models/base_model.dart';

class SignUpModel extends BaseModel {
  final AuthenticationService _authenticationService =
      locator<AuthenticationService>();
  String _email = "";
  String _password = "";
  String _userName = "";

  Future<bool> signInWithEmail() async {
    setState(PageState.Busy);
    bool response;

    response = await _authenticationService.createUserWithEmailAndPassword(_email, _password);

    setState(PageState.Idle);
    return response;
  }

  Future<bool> checkIfVerified() async {
    setState(PageState.Busy);
    bool response;

    response = await _authenticationService.checkIfVerified();

    setState(PageState.Idle);
    return response;
  }

  Future<void> signUp() async {
    setState(PageState.Busy);

    await _authenticationService.signUp(_userName);

    setState(PageState.Idle);
  }

  bool checkForValidEmail(String email) {
    return RegExp(r"^[a-zA-Z0-9.]+@[a-zA-Z0-9]+\.[a-zA-Z]+").hasMatch(email);
  }

  String get email => _email;

  String get password => _password;

  String get userName => _userName;

  set setEmail(String email) => _email = email;

  set setPassword(String password) => _password = password;

  set setUserName(String userName) => _userName = userName;
}
