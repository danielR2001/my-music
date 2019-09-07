import 'package:get_it/get_it.dart';
import 'package:myapp/core/api/api_manager.dart';
import 'package:myapp/core/database/firebase/authentication_manager.dart';
import 'package:myapp/core/database/firebase/database_manager.dart';
import 'package:myapp/core/database/local/local_database_manager.dart';
import 'package:myapp/core/player/audio_player_manager.dart';
import 'package:myapp/core/services/api_service.dart';
import 'package:myapp/core/services/authentication_service.dart';
import 'package:myapp/core/services/connectivity_service.dart';
import 'package:myapp/core/services/database_service.dart';
import 'package:myapp/core/services/image_loader_service.dart';
import 'package:myapp/core/services/local_database_service.dart';
import 'package:myapp/core/services/audio_player_service.dart';
import 'package:myapp/core/services/native_communication_service.dart';
import 'package:myapp/core/services/tab_navigation_service.dart';
import 'package:myapp/core/services/toast_service.dart';
import 'package:myapp/core/view_models/modal_sheet_models/playlist_options_model.dart';
import 'package:myapp/core/view_models/modal_sheet_models/queue_model.dart';
import 'package:myapp/core/view_models/modal_sheet_models/song_options_model.dart';
import 'package:myapp/core/view_models/modal_sheet_models/sort_model.dart';
import 'package:myapp/core/view_models/page_models/artist_model.dart';
import 'package:myapp/core/view_models/page_models/discover_model.dart';
import 'package:myapp/core/view_models/page_models/home_model.dart';
import 'package:myapp/core/view_models/page_models/library_model.dart';
import 'package:myapp/core/view_models/page_models/login_model.dart';
import 'package:myapp/core/view_models/page_models/music_player_model.dart';
import 'package:myapp/core/view_models/page_models/playlist_model.dart';
import 'package:myapp/core/view_models/page_models/playlist_pick_model.dart';
import 'package:myapp/core/view_models/page_models/root_model.dart';
import 'package:myapp/core/view_models/page_models/search_model.dart';
import 'package:myapp/core/view_models/page_models/sign_up_model.dart';

GetIt locator = GetIt();

void setupLocator() {
  //! view models
  locator.registerFactory(() => LoginModel());
  locator.registerFactory(() => SignUpModel());
  locator.registerFactory(() => RootModel());
  locator.registerFactory(() => ArtistModel());
  locator.registerFactory(() => DiscoverModel());
  locator.registerFactory(() => HomeModel());
  locator.registerFactory(() => LibraryModel());
  locator.registerFactory(() => MusicPlayerModel());
  locator.registerFactory(() => PlaylistModel());
  locator.registerFactory(() => PlaylistPickModel());
  locator.registerFactory(() => SearchModel());

  locator.registerFactory(() => PlaylistOptionsModel());
  locator.registerFactory(() => QueueModel());
  locator.registerFactory(() => SongOptionsModel());
  locator.registerFactory(() => SortModel());

  //! Services
  //Authentication
  locator.registerLazySingleton(() => AuthenticationService());
  locator.registerLazySingleton(() => FirebaseAuthenticationManager());
  //Firebase Database
  locator.registerLazySingleton(() => FirebaseDatabaseService());
  locator.registerLazySingleton(() => FirebaseDatabaseManager());
  //Local Database
  locator.registerLazySingleton(() => LocalDatabaseService());
  locator.registerLazySingleton(() => LocalDatabaseManager());
  //Player
  locator.registerLazySingleton(() => AudioPlayerService());
  locator.registerLazySingleton(() => AudioPlayerManager());
  //Api
  locator.registerLazySingleton(() => ApiManager());
  locator.registerLazySingleton(() => ApiService());
  //Connectivity
  locator.registerLazySingleton(() => ConnectivityService());
  //Native communication
  locator.registerLazySingleton(() => NativeCommunicationService());
  //ImageLoader
  locator.registerLazySingleton(() => ImageLoaderService());
  //Toast
  locator.registerLazySingleton(() => ToastService());
  //Tab navigation
    locator.registerLazySingleton(() => TabNavigationService());
}
