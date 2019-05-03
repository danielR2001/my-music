import 'package:dio/dio.dart';
import 'package:myapp/models/song.dart';
import 'package:path_provider/path_provider.dart';

class ManageLocalSongs {
  static int downloadProg;
  static int downloadTotal;
  static bool downloading = false;
  static Dio dio = new Dio();

  static Future<void> downloadSong(Song song) async {
    try {
      var dir = await getApplicationDocumentsDirectory();
      print(dir.absolute);
      await dio.download(song.getSongDownloadUrl,
          "${dir.path}/${song.getSongName}-${song.getArtist}.mp3",
          onReceiveProgress: (prog, total) {
        downloading = true;
        downloadProg = prog;
        downloadTotal = total;
      }).then((a) {
        print(a.toString());
      }).whenComplete(() {
        downloading = false;
        print("download completed!");
      });
    } catch (e) {
      print(e);
    }
  }
}
