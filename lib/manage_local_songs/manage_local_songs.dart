import 'dart:io';
import 'package:dio/dio.dart';
import 'package:myapp/fetch_data_from_internet/fetch_data_from_internet.dart';
import 'package:myapp/firebase/database_manager.dart';
import 'package:myapp/main.dart';
import 'package:myapp/models/song.dart';
import 'package:path_provider/path_provider.dart';

class ManageLocalSongs {
  static bool downloading = false;
  static Dio dio = Dio();
  static final String startingUrl = "https://muz.xn--41a.wiki";
  static List<Song> currentDownloading = List();
  static Directory externalDir;
  static Directory fullDir;

  static Future<bool> checkIfFileExists(Song song) async {
    externalDir = await getExternalStorageDirectory();
    fullDir = await new Directory(
            '${externalDir.path}/Android/data/com.daniel.mymusic/downloaded')
        .create(recursive: true);
    File file = File("${fullDir.path}/${song.getSongId}.mp3");
    
    return file.exists();
  }

  static Future<void> downloadSong(Song song) async {
    //final stateRefresher = Provider.of<StateRefresher>(context);
    currentDownloading.add(song);
    FetchData.getDownloadUrlPage1(song).then((downloadUrl) async {
      if (downloadUrl != null) {
        try {
          await dio.download(startingUrl + downloadUrl,
              "${fullDir.path}/${song.getSongId}.mp3",
              onReceiveProgress: (prog, total) {
            downloading = true;
            //stateRefresher.setDownloadedProg = prog;
            //stateRefresher.setDownloadedTotal = total;
            print("prog: $prog , total: $total");
          }).whenComplete(() {
            currentDownloading.remove(song);
            downloading = false;
            song = FirebaseDatabaseManager.addSongToDownloadedPlaylist(song);
            currentUser.addSongToDownloadedPlaylist(song);
            print("download completed!");
          });
        } catch (e) {
          print(e);
          downloading = false;
          currentDownloading.remove(song);
        }
      } else {
        downloading = false;
        currentDownloading.remove(song);
      }
    });
  }

  static Future<void> unDownloadSong(Song song) async {
    //final stateRefresher = Provider.of<StateRefresher>(context);
    try {
      File file = File("${fullDir.path}/${song.getSongId}.mp3");
      file.delete().whenComplete(() {
        FirebaseDatabaseManager.removeSongFromDownloadedPlaylist(song);
        currentUser.removeSongToDownloadedPlaylist(song);
        print("unDownload completed!");
      });
    } catch (e) {
      print(e);
    }
  }

  static bool isSongDownloading(Song song) {
    bool exists = false;
    currentDownloading.forEach((downloadingSong) {
      if (downloadingSong.getSongId == song.getSongId) {
        exists = true;
      }
    });
    return exists;
  }
}
