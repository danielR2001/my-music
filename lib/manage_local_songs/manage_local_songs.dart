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
            '${externalDir.path}/Android/data/com.daniel.mymusic/downloaded/${currentUser.getName}')
        .create(recursive: true);
    File file = File("${fullDir.path}/${song.getSongId}.mp3");

    return file.exists();
  }

  static Future<void> downloadSong(Song song) async {
    currentDownloading.add(song);
    FetchData.getDownloadUrlPage1(song).then((downloadUrl) async {
      if (downloadUrl != null) {
        try {
          await dio.download(startingUrl + downloadUrl,
              "${fullDir.path}/${song.getSongId}.mp3",
              onReceiveProgress: (prog, total) {
            downloading = true;
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

  // static void syncDownloaded() async {
  //   externalDir = await getExternalStorageDirectory();
  //   fullDir = await new Directory(
  //           '${externalDir.path}/Android/data/com.daniel.mymusic/downloaded/${currentUser.getName}')
  //       .create(recursive: true);
  //   List<File> files = List();
  //   try {
  //     var dirList = fullDir.list();
  //     await for (FileSystemEntity f in dirList) {
  //       if (f is File) {
  //         files.add(f);
  //       }
  //     }
  //   } catch (e) {
  //     print(e.toString());
  //   }
  //   List<Song> updatedDownloadedList = List();
  //   files.forEach((file){
  //     currentUser.getDownloadedSongsPlaylist.getSongs.forEach((song){
  //       String songId = file.path.substring(file.path.lastIndexOf("/"),file.path.length-1);
  //       if(song.getSongId == songId){
  //         updatedDownloadedList.add(song);
  //       }
  //     });
  //   });
  // }
}
