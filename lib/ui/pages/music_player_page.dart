import 'dart:async';
import 'package:connectivity/connectivity.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:myapp/main.dart';
import 'package:myapp/models/song.dart';
import 'package:myapp/playing_now/playing_now.dart';
import 'package:myapp/ui/widgets/song_options_modal_buttom_sheet.dart';
import 'package:myapp/ui/widgets/text_style.dart';

class MusicPlayerPage extends StatefulWidget {
  @override
  MusicPageState createState() => MusicPageState();
}

class MusicPageState extends State<MusicPlayerPage> {
  Duration _position;
  Duration _duration;
  Icon musicPlayerIcon;
  Icon playlistModeIcon;
  StreamSubscription<AudioPlayerState> stateStream;
  StreamSubscription<Duration> posStream;
  StreamSubscription<Duration> durStream;
  StreamSubscription<void> onSongCompleteStream;
  ImageProvider songImage =
      new AssetImage('assets/images/default_song_pic_big.png');

  @override
  void initState() {
    super.initState();
    initSong();
  }

  @override
  void dispose() {
    super.dispose();
    posStream.cancel();
    durStream.cancel();
    stateStream.cancel();
    onSongCompleteStream.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: new Container(
        decoration: new BoxDecoration(
          gradient: new LinearGradient(
            colors: [
              Color(0xff0f0e0e),
              Colors.pink,
            ],
            begin: FractionalOffset.bottomCenter,
            stops: [0.6, 1.0],
            end: FractionalOffset.topCenter,
          ),
        ),
        child: Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(top: 40, left: 15, right: 15),
              child: Row(
                children: <Widget>[
                  new IconButton(
                    iconSize: 40,
                    icon: Icon(
                      Icons.keyboard_arrow_down,
                      color: Colors.white,
                    ),
                    onPressed: () => {
                          Navigator.pop(context),
                        },
                  ),
                  Expanded(
                    child: new Container(),
                  ),
                  new IconButton(
                      iconSize: 30,
                      icon: Icon(
                        Icons.more_vert,
                        color: Colors.white,
                      ),
                      onPressed: () {
                        showMoreOptions(context);
                      }),
                ],
              ),
            ),
            new Expanded(
              child: new Container(
                child: new Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    new Container(
                      width: 270,
                      height: 270,
                      decoration: new BoxDecoration(
                        color: Colors.black,
                        border: Border.all(
                          color: Colors.black,
                          width: 0.2,
                        ),
                        boxShadow: [
                          new BoxShadow(
                            color: Colors.grey[850],
                            blurRadius: 5.0,
                          ),
                        ],
                        image: new DecorationImage(
                          image: songImage,
                          fit: BoxFit.contain,
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),
            Column(
              children: <Widget>[
                TextDecoration(
                  playingNow.currentSong.getSongName,
                  25,
                  Colors.white,
                  20,
                  35,
                ),
                TextDecoration(
                  playingNow.currentSong.getArtist,
                  14,
                  Colors.grey,
                  30,
                  35,
                ),
              ],
            ),
            new Slider(
                value: _position != null
                    ? _position.inSeconds <= _duration.inSeconds
                        ? _position.inSeconds.toDouble()
                        : 0.0
                    : playingNow.songPosition.inSeconds.toDouble(),
                min: 0.0,
                max: _duration != null
                    ? _duration.inSeconds.toDouble()
                    : playingNow.songDuration.inSeconds.toDouble(),
                inactiveColor: Colors.grey[700],
                activeColor: Colors.white,
                onChanged: (double value) {
                  setState(() {
                    value = value;
                    seekToSecond(value.toInt());
                  });
                }),
            new Container(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                ),
                child: new Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Expanded(
                      child: new Text(
                        _position != null
                            ? _position.inSeconds <= _duration.inSeconds
                                ? _position
                                    .toString()
                                    .substring(checkSongLength(), 7)
                                : "00:00"
                            : playingNow.songPosition
                                .toString()
                                .substring(checkSongLength(), 7),
                        textAlign: TextAlign.left,
                        style: TextStyle(
                          color: Colors.grey[400],
                        ),
                      ),
                    ),
                    Expanded(
                      child: new Text(
                        _duration != null
                            ? _duration
                                .toString()
                                .substring(checkSongLength(), 7)
                            : playingNow.songDuration
                                .toString()
                                .substring(checkSongLength(), 7),
                        textAlign: TextAlign.right,
                        style: TextStyle(
                          color: Colors.grey[400],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            new Container(
              child: new Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  new Row(
                    children: <Widget>[
                      IconButton(
                        splashColor: Colors.grey,
                        alignment: Alignment.center,
                        iconSize: 45,
                        icon: new Icon(
                          Icons.skip_previous,
                          color: Colors.white,
                        ),
                        onPressed: () {
                          playPreviousSong();
                        },
                      ),
                      new IconButton(
                        splashColor: Colors.grey,
                        alignment: Alignment.center,
                        iconSize: 80,
                        icon: musicPlayerIcon,
                        onPressed: () {
                          playingNow.advancedPlayer.state ==
                                  AudioPlayerState.PLAYING
                              ? playingNow.pauseSong()
                              : playingNow.resumeSong();
                        },
                      ),
                      IconButton(
                        splashColor: Colors.grey,
                        alignment: Alignment.center,
                        iconSize: 45,
                        icon: new Icon(
                          Icons.skip_next,
                          color: Colors.white,
                        ),
                        onPressed: () {
                          playNextSong();
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
            new Container(
              child: Padding(
                padding: new EdgeInsets.only(
                  bottom: 50,
                ),
                child: new Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 20),
                      child: IconButton(
                        splashColor: Colors.grey,
                        icon: playlistModeIcon,
                        onPressed: () {
                          playingNow.playlistMode == PlaylistMode.loop
                              ? playingNow.playlistMode = PlaylistMode.shuffle
                              : playingNow.playlistMode = PlaylistMode.loop;
                          changePlaylistModeIconState();
                        },
                      ),
                    ),
                    Expanded(
                      child: new Container(),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(right: 20),
                      child: IconButton(
                        splashColor: Colors.grey,
                        icon: new Icon(
                          Icons.share,
                          size: 25,
                          color: Colors.white,
                        ),
                        onPressed: () {},
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void showMoreOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (builder) {
        return SongOptionsModalSheet(
            playingNow.currentSong, playingNow.currentPlaylist);
      },
    );
  }

  void changePlayingIconState(bool isPlaying) {
    if (isPlaying) {
      setState(
        () {
          musicPlayerIcon = Icon(
            Icons.pause_circle_filled,
            color: Colors.white,
          );
        },
      );
    } else {
      setState(
        () {
          musicPlayerIcon = Icon(
            Icons.play_circle_filled,
            color: Colors.white,
          );
        },
      );
    }
  }

  void changePlaylistModeIconState() {
    if (playingNow.playlistMode == PlaylistMode.loop) {
      setState(
        () {
          playlistModeIcon = Icon(
            Icons.repeat,
            color: Colors.white,
          );
        },
      );
    } else {
      setState(
        () {
          playlistModeIcon = Icon(
            Icons.shuffle,
            color: Colors.white,
          );
        },
      );
    }
  }

  void checkSongStatus(AudioPlayerState state) {
    if (state == AudioPlayerState.PLAYING) {
      changePlayingIconState(true);
    } else if (state == AudioPlayerState.PAUSED) {
      changePlayingIconState(false);
    } else {
      changePlayingIconState(false);
    }
  }

  void initSong() {
    posStream = playingNow.advancedPlayer.onAudioPositionChanged
        .listen((Duration p) => {setState(() => _position = p)});

    durStream = playingNow.advancedPlayer.onDurationChanged.listen(
      (Duration d) {
        setState(() => _duration = d);
      },
    );
    changePlaylistModeIconState();
    setSongImage();
    checkSongStatus(playingNow.advancedPlayer.state);
    stateStream = playingNow.advancedPlayer.onPlayerStateChanged.listen(
      (AudioPlayerState state) {
        checkSongStatus(state);
      },
    );
    onSongCompleteStream =
        playingNow.advancedPlayer.onPlayerCompletion.listen((a) {
      setSongImage();
    });
  }

  void seekToSecond(int second) {
    Duration newDuration = Duration(seconds: second);
    playingNow.seekTime(newDuration);
  }

  int checkSongLength() {
    if (playingNow.songDuration.inMinutes < 59) {
      return 2;
    } else {
      return 0;
    }
  }

  void setSongImage() async {
    if (playingNow.currentSong.getImageUrl.length > 0) {
      ConnectivityResult connectivityResult =
          await Connectivity().checkConnectivity();
      if (connectivityResult == ConnectivityResult.mobile ||
          connectivityResult == ConnectivityResult.wifi) {
        setState(() {
          songImage = new NetworkImage(
            playingNow.currentSong.getImageUrl,
          );
        });
      } else {
        print("no internet connection for loading image");
      }
    }
  }

  void playPreviousSong() {
    if (playingNow.currentPlaylist != null) {
      int i = 0;
      Song correctPreviousSong;
      if (playingNow.currentSong.getSongId ==
          playingNow.currentPlaylist.getSongs[0].getSongId) {
        playingNow.playSong(playingNow.currentPlaylist
            .getSongs[playingNow.currentPlaylist.getSongs.length - 1]);
      } else {
        Song previousSong = playingNow.currentPlaylist.getSongs[0];
        playingNow.currentPlaylist.getSongs.forEach((song) {
          if (i != 0) {
            if (song.getSongId == playingNow.currentSong.getSongId) {
              correctPreviousSong = previousSong;
            } else {
              previousSong = song;
            }
          }
          i++;
        });
        playingNow.playSong(correctPreviousSong);
      }
    }
  }

  void playNextSong() {
    if (playingNow.currentPlaylist != null) {
      bool foundSong = false;
      Song nextSong;
      playingNow.currentPlaylist.getSongs.forEach((song) {
        if (foundSong) {
          nextSong = song;
          foundSong = false;
        }
        if (song.getSongId == playingNow.currentSong.getSongId) {
          foundSong = true;
        }
      });
      if (nextSong == null && foundSong) {
        nextSong = playingNow.currentPlaylist.getSongs[0];
      }
      playingNow.playSong(nextSong);
    }
  }
}
