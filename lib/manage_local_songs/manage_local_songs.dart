import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:myapp/global_variables/global_variables.dart';
import 'package:myapp/models/song.dart';
import 'package:myapp/page_notifier/page_notifier.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

class ManageLocalSongs {
  Dio dio = Dio();
  List<Song> currentDownloading = List();
  Map<Song, CancelToken> cancelTokensMap = Map();
  Directory externalDir;
  Directory fullSongDownloadDir;

  ManageLocalSongs(){
    initDirs();
  }
  
  Future<void> initDirs() async {
    externalDir = await getExternalStorageDirectory();
    fullSongDownloadDir = await new Directory(
            '${externalDir.path}/Android/data/com.daniel.mymusic/downloaded/')
        .create(recursive: true);
  }

  Future<bool> checkIfStoragePermissionGranted() async {
    Map<PermissionGroup, PermissionStatus> permissions =
        await PermissionHandler().requestPermissions([PermissionGroup.storage]);
    if (permissions[PermissionGroup.storage] == PermissionStatus.granted) {
      return true;
    } else {
      return false;
    }
  }

  Future<bool> checkIfFileExists(Song song) async {
    File file =
        File("${fullSongDownloadDir.path}/${song.songId}/${song.songId}.mp3");
    return file.exists();
  }

  Future<void> downloadSong(Song song) async {
    Directory songDirectory;
    CancelToken cancelToken = CancelToken();
    cancelTokensMap[song] = cancelToken;
    if (GlobalVariables.isNetworkAvailable) {
      songDirectory =
          await new Directory('${fullSongDownloadDir.path}/${song.songId}')
              .create(recursive: true);
      if (song.imageUrl != "") {
        _downloadSongImage(song);
      }
      _downloadSongInfo(song);
      GlobalVariables.apiService.getSongPlayUrl(song).then((downloadUrl) async {
        if (downloadUrl != null) {
          currentDownloading.add(song);
          Provider.of<PageNotifier>(GlobalVariables.homePageContext)
              .addDownloaded(song);
          try {
            await dio.download(
                downloadUrl, "${songDirectory.path}/${song.songId}.mp3",
                cancelToken: cancelToken, onReceiveProgress: (prog, total) {
              if (Provider.of<PageNotifier>(GlobalVariables.homePageContext)
                      .downloadedTotals[song.songId] ==
                  1) {
                Provider.of<PageNotifier>(GlobalVariables.homePageContext)
                    .updateDownloadedTotals(song, total);
              }

              Provider.of<PageNotifier>(GlobalVariables.homePageContext)
                  .updateDownloadedProgsses(song, prog);
              if (prog == total) {
                Provider.of<PageNotifier>(GlobalVariables.homePageContext)
                    .removeDownloaded(song);
                currentDownloading.remove(song);

                GlobalVariables.currentUser.addSongToDownloadedPlaylist(song);
                print("song: ${song.songId}, download completed!");
              }
            });
          } on DioError catch (e) {
            if (e.message == "cancelled") {
              _makeToast(text: "Download cancelled");
            } else {
              print(e);
              _makeToast(text: "Something went wrong");
            }
          } catch (e) {
            print(e);
            currentDownloading.remove(song);
            cancelTokensMap.remove(song);
            _makeToast(text: "Something went wrong");
          }
        } else {
          currentDownloading.remove(song);
          _makeToast(text: "Something went wrong");
        }
      });
    } else {
      _makeToast(text: "No internet connection");
    }
  }

  Future<void> cancelDownLoad(Song song) async {
    cancelTokensMap[song].cancel("cancelled");
    deleteSongDirectory(song);
    currentDownloading.remove(song);
    Provider.of<PageNotifier>(GlobalVariables.homePageContext)
        .removeDownloaded(song);
  }

  Future<void> _downloadSongImage(Song song) async {
    Directory songDirectory =
        await new Directory('${fullSongDownloadDir.path}/${song.songId}')
            .create(recursive: true);
    try {
      await dio
          .download(song.imageUrl, "${songDirectory.path}/${song.songId}.png",
              onReceiveProgress: (prog, total) {})
          .whenComplete(() {
        print("song: ${song.songId}, song image download completed!");
      });
    } catch (e) {
      print(e);
    }
  }

  Future<void> _downloadSongInfo(Song song) async {
    Directory songDirectory =
        await new Directory('${fullSongDownloadDir.path}/${song.songId}')
            .create(recursive: true);
    File file = File('${songDirectory.path}/${song.songId}.txt');
    file.writeAsString(
        "${song.title}*/*${song.artist}*/*${song.songId}*/*${song.searchString}*/*${song.imageUrl}");
    file.create();
  }

  Future<void> deleteSongDirectory(Song song) async {
    bool exists =
        await Directory('${fullSongDownloadDir.path}/${song.songId}').exists();

    if (exists) {
      await new Directory('${fullSongDownloadDir.path}/${song.songId}')
          .delete(recursive: true);
    }
  }

  bool isSongDownloading(Song song) {
    bool exists = false;
    currentDownloading.forEach((downloadingSong) {
      if (downloadingSong.songId == song.songId) {
        exists = true;
      }
    });
    return exists;
  }

  void syncDownloaded() async {
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
          GlobalVariables.currentUser.downloadedSongsPlaylist.addNewSong(song);
        });
      }
    });
    GlobalVariables.currentUser.downloadedSongsPlaylist.setSongs =
        updatedDownloadedList;
  }

  Future<Song> readSongInfoFile(String songId) async {
    File file = File('${fullSongDownloadDir.path}/$songId/$songId.txt');
    String fileString = await file.readAsString();
    List<String> songAttributes = fileString.split("*/*");
    return Song(songAttributes[0], songAttributes[1], songAttributes[2],
        songAttributes[3], songAttributes[4], "");
  }

  Future<void> deleteDownloadedDirectory() async {
    await new Directory('${fullSongDownloadDir.path}').delete(recursive: true);
  }

  void _makeToast({String text}) {
    Fluttertoast.showToast(
      msg: text,
      toastLength: Toast.LENGTH_SHORT,
      timeInSecForIos: 1,
      fontSize: 16.0,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: GlobalVariables.pinkColor,
      textColor: Colors.white,
    );
  }
}
