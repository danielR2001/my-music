import 'package:firebase_database/firebase_database.dart';
import 'package:myapp/core/database/firebase/database_manager.dart';
import 'package:myapp/locater.dart';
import 'package:myapp/models/playlist.dart';
import 'package:myapp/models/song.dart';
import 'package:myapp/models/user.dart';

class FirebaseDatabaseService {
  final FirebaseDatabaseManager _firebaseDatabaseManager =
      locator<FirebaseDatabaseManager>();

  Future<void> saveUser(User currentUser) async {
    await _firebaseDatabaseManager.saveUser(currentUser);
  }

  Future<User> syncUser(String currentUserId) async {
    return _firebaseDatabaseManager.syncUser(currentUserId);
  }

  Future<String> addPlaylist(Playlist playlist) async {
    return await _firebaseDatabaseManager.addPlaylist(playlist);
  }

  Future<void> removePlaylist(Playlist playlist) async {
    await _firebaseDatabaseManager.removePlaylist(playlist);
  }

  Future<void> renamePlaylist(Playlist playlist, String newName) async {
    await _firebaseDatabaseManager.removePlaylist(playlist);
  }

  Future<void> changePlaylistPrivacy(Playlist playlist) async {
    await _firebaseDatabaseManager.changePlaylistPrivacy(playlist);
  }

  Future<Song> addSongToPlaylist(Playlist playlist, Song song) async {
    return await _firebaseDatabaseManager.addSongToPlaylist(playlist, song);
  }

  Future<void> removeSongFromPlaylist(
      User user, Playlist playlist, Song song) async {
    await _firebaseDatabaseManager.removeSongFromPlaylist(playlist, song);
    if (playlist.isPublic) {
      await removeSongFromPublicPlaylist(user, playlist, song);
    }
  }

  Future<void> removeSongFromPublicPlaylist(
      User user, Playlist playlist, Song song) async {
    await _firebaseDatabaseManager.removeSongFromPublicPlaylist(
        user, playlist, song);
  }

  Future<Playlist> addPublicPlaylist(
      Playlist playlist, bool creatingNewPlaylist) async {
    return await _firebaseDatabaseManager.addPublicPlaylist(
        playlist, creatingNewPlaylist);
  }

  Future<void> removeFromPublicPlaylist(
      Playlist playlist, bool completeDelete) async {
    await _firebaseDatabaseManager.removeFromPublicPlaylist(
        playlist, completeDelete);
  }

  Future<List<Playlist>> buildPublicPlaylists() async {
    return await _firebaseDatabaseManager.buildPublicPlaylists();
  }
}
