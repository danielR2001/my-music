import 'package:dio/dio.dart';
import 'package:myapp/models/song.dart';
import 'package:path_provider/path_provider.dart';

class ManageLocalSongs {
  static String songID;
  static final String downloadUrl =
      'https://free-mp3-download.net/dl.php?i=$songID&c=72272&f=mp3';
  static int downloadProg;
  static int downloadTotal;
  static bool downloading = false;
  static Dio dio = new Dio();

  static Future<void> cacheSong(Song song) async {
    try {
      songID = song.getSongId;
      var dir = await getApplicationDocumentsDirectory();
      print(dir.absolute);
      await dio.download(downloadUrl,
          "${dir.path}/${song.getTitle}-${song.getArtist.getName}.mp3",
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
