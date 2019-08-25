import 'dart:async';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:myapp/models/song.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

enum DownloadError {
  Cancceled,
  Unknown,
}

class LocalDatabaseManager {
  final StreamController<Map<String, int>> _downloadProgressesController =
      StreamController<Map<String, int>>.broadcast();
  final StreamController<Map<String, int>> _downloadTotalsController =
      StreamController<Map<String, int>>.broadcast();
  final StreamController<Map<String, bool>> _downloadStopsController =
      StreamController<Map<String, bool>>.broadcast();
  final StreamController<Map<String, DownloadError>> _downloadErorsController =
      StreamController<Map<String, DownloadError>>.broadcast();

  Dio _dio = Dio();
  List<Song> _currentDownloading = List();
  Map<Song, CancelToken> _cancelTokensMap = Map();
  Directory _externalDir;
  Directory _fullSongDownloadDir;

  StreamController<Map<String, int>> get downloadProgressesController =>
      _downloadProgressesController;

  StreamController<Map<String, int>> get downloadTotalsController =>
      _downloadTotalsController;

  StreamController<Map<String, bool>> get downloadStopsController =>
      _downloadStopsController;

  StreamController<Map<String, DownloadError>> get downloadErorController =>
      _downloadErorsController;

  List<Song> get currentDownloading => _currentDownloading;

  Directory get fullSongDownloadDir => _fullSongDownloadDir;

  Future<void> initDirs() async {
    _externalDir = await getExternalStorageDirectory();
    _fullSongDownloadDir = await new Directory(
            '${_externalDir.path}/Android/data/com.daniel.mymusic/downloaded/')
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

  Future<bool> checkIfSongFileExists(Song song) async {
    File file =
        File("${_fullSongDownloadDir.path}/${song.songId}/${song.songId}.mp3");
    return file.exists();
  }

  Future<bool> checkIfImageFileExists(Song song) async {
    File file =
        File("${_fullSongDownloadDir.path}/${song.songId}/${song.songId}.png");
    return file.exists();
  }

  Future<void> downloadSong(Song song) async {
    Directory songDirectory;
    CancelToken cancelToken = CancelToken();
    _cancelTokensMap[song] = cancelToken;
    songDirectory =
        await new Directory('${_fullSongDownloadDir.path}/${song.songId}')
            .create(recursive: true);
    if (song.imageUrl != "") {
      _downloadSongImage(song);
    }
    _downloadSongInfo(song);
    _currentDownloading.add(song);
    try {
      await _dio.download(
          song.playUrl, "${songDirectory.path}/${song.songId}.mp3",
          cancelToken: cancelToken, onReceiveProgress: (prog, total) {
        _downloadProgressesController.add(generateResultMap(song.songId, prog));
        _downloadTotalsController.add(generateResultMap(song.songId, total));
        if (prog == total) {
          _downloadStopsController.add(generateResultMap(song.songId, true));
          print(
              "song: ${song.songId}, download completed!"); //! TODO add to current user! or not
        }
      });
    } on DioError catch (e) {
      if (e.message == "cancelled") {
        _downloadErorsController
            .add(generateResultMap(song.songId, DownloadError.Cancceled));
      } else {
        print(e);
        _currentDownloading.remove(song);
        _cancelTokensMap.remove(song);
        _downloadErorsController
            .add(generateResultMap(song.songId, DownloadError.Unknown));
      }
    } catch (e) {
      print(e);
      _currentDownloading.remove(song);
      _cancelTokensMap.remove(song);
      _downloadErorsController
          .add(generateResultMap(song.songId, DownloadError.Unknown));
    }
  }

  Future<void> cancelDownLoad(Song song) async {
    _cancelTokensMap[song].cancel("cancelled");
    deleteSongDirectory(song);
    _currentDownloading.remove(song);
    Map<String, bool> resultMap = Map();
    resultMap[song.songId] = false;
    _downloadStopsController.add(resultMap);
  }

  Future<void> _downloadSongImage(Song song) async {
    Directory songDirectory =
        await new Directory('${_fullSongDownloadDir.path}/${song.songId}')
            .create(recursive: true);
    try {
      await _dio
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
        await new Directory('${_fullSongDownloadDir.path}/${song.songId}')
            .create(recursive: true);
    File file = File('${songDirectory.path}/${song.songId}.txt');
    file.writeAsString(
        "${song.title}*/*${song.artist}*/*${song.songId}*/*${song.searchString}*/*${song.imageUrl}*/*${DateTime.now().millisecondsSinceEpoch}");
    file.create();
  }

  Future<void> deleteSongDirectory(Song song) async {
    bool exists =
        await Directory('${_fullSongDownloadDir.path}/${song.songId}').exists();

    if (exists) {
      await new Directory('${_fullSongDownloadDir.path}/${song.songId}')
          .delete(recursive: true);
    }
  }

  bool isSongDownloading(Song song) {
    bool exists = false;
    _currentDownloading.forEach((downloadingSong) {
      if (downloadingSong.songId == song.songId) {
        exists = true;
      }
    });
    return exists;
  }

  Future<List<Song>> syncDownloaded() async {
    List<File> files = List();
    List<Song> songs = List();
    try {
      var songsDirList = _fullSongDownloadDir.list();
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
    for (var file in files) {
      if (file.path.contains(".txt")) {
        await _readSongInfoFile(file.path.substring(
                file.path.lastIndexOf("/"), file.path.lastIndexOf(".txt")))
            .then((song) {
          songs.add(song);
        });
      }
    }
    return songs;
  }

  Future<Song> _readSongInfoFile(String songId) async {
    File file = File('${_fullSongDownloadDir.path}/$songId/$songId.txt');
    String fileString = await file.readAsString();
    List<String> songAttributes = fileString.split("*/*");
    return Song(
      songAttributes[0],
      songAttributes[1],
      songAttributes[2],
      songAttributes[3],
      songAttributes[4],
      "",
      dateAdded: int.parse(songAttributes[5]),
    );
  }

  Future<void> deleteDownloadedDirectory() async {
    await new Directory('${_fullSongDownloadDir.path}').delete(recursive: true);
  }

  Map generateResultMap(String songId, dynamic result) {
    if (result.runtimeType == int) {
      Map<String, int> resultMap = Map();
      resultMap[songId] = result;
      return resultMap;
    } else {
      Map<String, DownloadError> resultMap = Map();
      resultMap[songId] = result;
      return resultMap;
    }
  }
}
