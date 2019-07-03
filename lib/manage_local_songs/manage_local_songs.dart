import 'dart:io';
import 'package:dio/dio.dart';
import 'package:myapp/fetch_data_from_internet/fetch_data_from_internet.dart';
import 'package:myapp/global_variables/global_variables.dart';
import 'package:myapp/main.dart';
import 'package:myapp/models/song.dart';
import 'package:myapp/page_notifier/page_notifier.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

class ManageLocalSongs {
  static Dio dio = Dio();
  static List<Song> currentDownloading = List();
  static Directory externalDir;
  static Directory fullSongDownloadDir;

  static Future<void> initDirs() async {
    externalDir = await getExternalStorageDirectory();
    fullSongDownloadDir = await new Directory(
            '${externalDir.path}/Android/data/com.daniel.mymusic/downloaded/')
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
    File file = File(
        "${fullSongDownloadDir.path}/${song.getSongId}/${song.getSongId}.mp3");
    return file.exists();
  }

  static Future<void> downloadSong(Song song) async {
    Directory songDirectory =
        await new Directory('${fullSongDownloadDir.path}/${song.getSongId}')
            .create(recursive: true);
    if (song.getImageUrl != "") {
      _downloadSongImage(song);
    }
    _downloadSongInfo(song);
    FetchData.getSongPlayUrl(song).then((downloadUrl) async {
      if (downloadUrl != null) {
        currentDownloading.add(song);
        Provider.of<PageNotifier>(GlobalVariables.homePageContext).addDownloaded(song);
        try {
          await dio.download(downloadUrl,
              "${songDirectory.path}/${song.getSongId}.mp3",
              onReceiveProgress: (prog, total) {
            if (Provider.of<PageNotifier>(GlobalVariables.homePageContext)
                    .downloadedTotals[song.getSongId] ==
                1) {
              Provider.of<PageNotifier>(GlobalVariables.homePageContext)
                  .updateDownloadedTotals(song, total);
            }

            Provider.of<PageNotifier>(GlobalVariables.homePageContext)
                .updateDownloadedProgsses(song, prog);
          }).whenComplete(() {
            Provider.of<PageNotifier>(GlobalVariables.homePageContext).removeDownloaded(song);
            currentDownloading.remove(song);

            currentUser.addSongToDownloadedPlaylist(song);
            print("song: ${song.getSongId}, download completed!");
          });
        } catch (e) {
          print(e);

          currentDownloading.remove(song);
        }
      } else {
        currentDownloading.remove(song);
      }
    });
  }

  static Future<void> _downloadSongImage(Song song) async {
    Directory songDirectory =
        await new Directory('${fullSongDownloadDir.path}/${song.getSongId}')
            .create(recursive: true);
    try {
      await dio
          .download(
              song.getImageUrl, "${songDirectory.path}/${song.getSongId}.png",
              onReceiveProgress: (prog, total) {})
          .whenComplete(() {
        print("song: ${song.getSongId}, song image download completed!");
      });
    } catch (e) {
      print(e);
    }
  }

  static Future<void> _downloadSongInfo(Song song) async {
    Directory songDirectory =
        await new Directory('${fullSongDownloadDir.path}/${song.getSongId}')
            .create(recursive: true);
    File file = File('${songDirectory.path}/${song.getSongId}.txt');
    file.writeAsString(
        "${song.getTitle}*/*${song.getArtist}*/*${song.getSongId}*/*${song.getSearchString}*/*${song.getImageUrl}");
    file.create();
  }

  static Future<void> deleteSongDirectory(Song song) async {
    await new Directory('${fullSongDownloadDir.path}/${song.getSongId}')
        .delete(recursive: true);
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
      var songsDirList = fullSongDownloadDir.list();
      await for (FileSystemEntity d in songsDirList) {
        if (d is Directory) {
          var songDirList = d.list();
          await for (FileSystemEntity f in songDirList) {
            if (f is File) {
              files.add(f);
            }
          }
        }
      }
    } catch (e) {
      print(e.toString());
    }
    List<Song> updatedDownloadedList = List();
    files.forEach((file) {
      if (file.path.contains(".txt")) {
        readSongInfoFile(file.path.substring(
                file.path.lastIndexOf("/"), file.path.lastIndexOf(".txt")))
            .then((song) {
          currentUser.getDownloadedSongsPlaylist.addNewSong(song);
        });
      }
    });
    currentUser.getDownloadedSongsPlaylist.setSongs = updatedDownloadedList;
  }

  static Future<Song> readSongInfoFile(String songId) async {
    File file = File('${fullSongDownloadDir.path}/$songId/$songId.txt');
    String fileString = await file.readAsString();
    List<String> songAttributes = fileString.split("*/*");
    return Song(songAttributes[0], songAttributes[1], songAttributes[2],
        songAttributes[3], songAttributes[4], "");
  }

  static Future<void> deleteDownloadedDirectory() async {
    await new Directory('${fullSongDownloadDir.path}').delete(recursive: true);
  }

}
