import 'dart:io';
import 'package:dio/dio.dart';
import 'package:myapp/fetch_data_from_internet/fetch_data_from_internet.dart';
import 'package:myapp/firebase/database_manager.dart';
import 'package:myapp/main.dart';
import 'package:myapp/models/song.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

class ManageLocalSongs {
  static bool downloading = false;
  static Dio dio = Dio();
  static final String startingUrl = "https://muz.xn--41a.wiki";
  static List<Song> currentDownloading = List();
  static Directory externalDir;
  static Directory fullSongDownloadDir;
  static Directory fullSongImageDir;

  static Future<void> initDirs() async {
    externalDir = await getExternalStorageDirectory();
    fullSongDownloadDir = await new Directory(
            '${externalDir.path}/Android/data/com.daniel.mymusic/downloaded/${currentUser.getName}/songs')
        .create(recursive: true);
    fullSongImageDir = await new Directory(
            '${externalDir.path}/Android/data/com.daniel.mymusic/downloaded/${currentUser.getName}/images')
        .create(recursive: true);
  }

  static Future<bool> checkIfStoragePermissionGranted() async {
    Map<PermissionGroup, PermissionStatus> permissions =
        await PermissionHandler().requestPermissions([PermissionGroup.storage]);
    if (permissions[PermissionGroup.storage] == PermissionStatus.granted) {
      return true;
    } else {
      return false;
    }
  }

  static Future<bool> checkIfFileExists(Song song) async {
    File file = File("${fullSongDownloadDir.path}/${song.getSongId}.mp3");
    return file.exists();
  }

  static Future<void> downloadSong(Song song) async {
    currentDownloading.add(song);
    if (song.getImageUrl != "") {
      await _downloadSongImage(song);
    }
    FetchData.getDownloadUrlPage1(song).then((downloadUrl) async {
      if (downloadUrl != null) {
        try {
          await dio.download(startingUrl + downloadUrl,
              "${fullSongDownloadDir.path}/${song.getSongId}.mp3",
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

  static Future<void> _downloadSongImage(Song song) async {
    try {
      await dio
          .download(song.getImageUrl,
              "${fullSongImageDir.path}/${song.getSongId}.png",
              onReceiveProgress: (prog, total) {})
          .whenComplete(() {
        print("song image download completed!");
      });
    } catch (e) {
      print(e);
    }
  }

  static Future<void> unDownloadSong(Song song) async {
    try {
      File file = File("${fullSongDownloadDir.path}/${song.getSongId}.mp3");
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

  static void syncDownloaded() async {
    List<File> files = List();
    try {
      var dirList = fullSongDownloadDir.list();
      await for (FileSystemEntity f in dirList) {
        if (f is File) {
          files.add(f);
        }
      }
    } catch (e) {
      print(e.toString());
    }
    List<Song> updatedDownloadedList = List();
    files.forEach((file) {
      currentUser.getDownloadedSongsPlaylist.getSongs.forEach((song) {
        String songId = file.path
            .substring(file.path.lastIndexOf("/") + 1, file.path.length - 4);
        if (song.getSongId == songId) {
          updatedDownloadedList.add(song);
        }
      });
    });
    currentUser.getDownloadedSongsPlaylist.setSongs = updatedDownloadedList;
  }
}
