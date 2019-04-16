class Song {
  String songName;
  String artist;
  String songUrl;

  Song(String songName, String artist) {
    this.songName = songName;
    this.artist = artist;
  }
  String getSongName() {
    return songName;
  }

  String getArtist() {
    return artist;
  }

  String getSongUrl() {
    return songUrl;
  }
}
