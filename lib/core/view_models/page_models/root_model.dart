import 'package:firebase_auth/firebase_auth.dart';
import 'package:myapp/core/enums/page_state.dart';
import 'package:myapp/core/services/audio_player_service.dart';
import 'package:myapp/core/services/connectivity_service.dart';
import 'package:myapp/core/services/local_database_service.dart';
import 'package:myapp/locater.dart';
import 'package:myapp/core/services/authentication_service.dart';
import 'package:myapp/core/view_models/page_models/base_model.dart';

class RootModel extends BaseModel {
  final AuthenticationService _authenticationService =
      locator<AuthenticationService>();
  final ConnectivityService _connectivityService =
      locator<ConnectivityService>();
  final AudioPlayerService _audioPlayerService = locator<AudioPlayerService>();
  final LocalDatabaseService _localDatabaseService =
      locator<LocalDatabaseService>();

  Future<void> initApp() async {
    await _connectivityService.initService();
    _audioPlayerService.initAudioPlayerService();
    _localDatabaseService.initDirs();
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
