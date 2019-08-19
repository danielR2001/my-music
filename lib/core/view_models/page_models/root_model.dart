import 'package:firebase_auth/firebase_auth.dart';
import 'package:myapp/core/page_state/page_state.dart';
import 'package:myapp/core/services/connectivity_service.dart';
import 'package:myapp/locater.dart';
import 'package:myapp/core/services/authentication_service.dart';
import 'package:myapp/core/view_models/page_models/base_model.dart';

class RootModel extends BaseModel {
  final AuthenticationService _authenticationService =
      locator<AuthenticationService>();
  final ConnectivityService _connectivityService =
      locator<ConnectivityService>();

  void initNetworkConnectivityStream() {
    _connectivityService.initNetworkConnectivityStream();
  }

  Future<FirebaseUser> checkIfLoggedIn() async {
    setState(PageState.Busy);
    FirebaseUser response;

    response = await _authenticationService.checkIfLoggedIn();

    setState(PageState.Idle);
    return response;
  }

  Future<bool> login(FirebaseUser firebaseUser) async {
    setState(PageState.Busy);
    bool response;

    response = await _authenticationService.login(firebaseUser);

    setState(PageState.Idle);
    return response;
  }
}
