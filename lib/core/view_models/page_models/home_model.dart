import 'package:myapp/core/services/audio_player_service.dart';
import 'package:myapp/locater.dart';
import 'package:myapp/core/view_models/page_models/base_model.dart';

class HomeModel extends BaseModel {
  final AudioPlayerService _audioPlayerService = locator<AudioPlayerService>();

  Future<void> restartSong() async {
    //await _audioPlayerService.restartSong()
  }
}
