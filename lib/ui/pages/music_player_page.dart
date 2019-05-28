import 'dart:async';
import 'package:connectivity/connectivity.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:myapp/main.dart';
import 'package:myapp/audio_player/audio_player_manager.dart';
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
      AssetImage('assets/images/default_song_pic_big.png');

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
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
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
                  IconButton(
                    iconSize: 40,
                    icon: Icon(
                      Icons.keyboard_arrow_down,
                      color: Colors.white,
                    ),
                    onPressed: () => Navigator.pop(context),
                  ),
                  Expanded(
                    child: Container(),
                  ),
                  IconButton(
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
            Expanded(
              child: Container(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Container(
                      width: 270,
                      height: 270,
                      decoration: BoxDecoration(
                        color: Colors.black,
                        border: Border.all(
                          color: Colors.black,
                          width: 0.2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey[850],
                            blurRadius: 5.0,
                          ),
                        ],
                        image: DecorationImage(
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
                  audioPlayerManager.currentSong.getTitle,
                  25,
                  Colors.white,
                  20,
                  30,
                ),
                TextDecoration(
                  audioPlayerManager.currentSong.getArtist,
                  14,
                  Colors.grey,
                  30,
                  30,
                ),
              ],
            ),
            Slider(
                value: _position != null
                    ? _position.inSeconds <= _duration.inSeconds
                        ? _position.inSeconds.toDouble()
                        : 0.0
                    : audioPlayerManager.songPosition.inSeconds.toDouble(),
                min: 0.0,
                max: _duration != null
                    ? _duration.inSeconds.toDouble()
                    : audioPlayerManager.songDuration.inSeconds.toDouble(),
                inactiveColor: Colors.grey[700],
                activeColor: Colors.white,
                onChanged: (double value) {
                  setState(() {
                    value = value;
                    _position = Duration(seconds: value.toInt());
                    seekToSecond(value.toInt());
                  });
                }),
            Container(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Expanded(
                      child: Text(
                        _position != null
                            ? _position.inSeconds <= _duration.inSeconds
                                ? _position
                                    .toString()
                                    .substring(checkSongLength(), 7)
                                : "00:00"
                            : audioPlayerManager.songPosition
                                .toString()
                                .substring(checkSongLength(), 7),
                        textAlign: TextAlign.left,
                        style: TextStyle(
                          color: Colors.grey[400],
                        ),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        _duration != null
                            ? _duration
                                .toString()
                                .substring(checkSongLength(), 7)
                            : audioPlayerManager.songDuration
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
            Container(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    children: <Widget>[
                      IconButton(
                        splashColor: Colors.grey,
                        alignment: Alignment.center,
                        iconSize: 45,
                        icon: Icon(
                          Icons.skip_previous,
                          color: Colors.white,
                        ),
                        onPressed: () {
                          audioPlayerManager.playPreviousSong();
                          setSongImage();
                        },
                      ),
                      IconButton(
                        splashColor: Colors.grey,
                        alignment: Alignment.center,
                        iconSize: 80,
                        icon: musicPlayerIcon,
                        onPressed: () {
                          audioPlayerManager.advancedPlayer.state ==
                                  AudioPlayerState.PLAYING
                              ? audioPlayerManager.pauseSong()
                              : audioPlayerManager.resumeSong();
                        },
                      ),
                      IconButton(
                        splashColor: Colors.grey,
                        alignment: Alignment.center,
                        iconSize: 45,
                        icon: Icon(
                          Icons.skip_next,
                          color: Colors.white,
                        ),
                        onPressed: () {
                          audioPlayerManager.playNextSong();
                          setSongImage();
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Container(
              child: Padding(
                padding: EdgeInsets.only(
                  bottom: 50,
                ),
                child: Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 20),
                      child: IconButton(
                        splashColor: Colors.grey,
                        icon: playlistModeIcon,
                        onPressed: () {
                          audioPlayerManager.playlistMode == PlaylistMode.loop
                              ? audioPlayerManager.playlistMode =
                                  PlaylistMode.shuffle
                              : audioPlayerManager.playlistMode =
                                  PlaylistMode.loop;
                          changePlaylistModeIconState();
                          audioPlayerManager.setCurrentPlaylist();
                        },
                      ),
                    ),
                    Expanded(
                      child: Container(),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(right: 20),
                      child: IconButton(
                        splashColor: Colors.grey,
                        icon: Icon(
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
            audioPlayerManager.currentSong, audioPlayerManager.currentPlaylist);
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
    if (audioPlayerManager.playlistMode == PlaylistMode.loop) {
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
    posStream = audioPlayerManager.advancedPlayer.onAudioPositionChanged
        .listen((Duration p) => setState(() => _position = p));

    durStream = audioPlayerManager.advancedPlayer.onDurationChanged.listen(
      (Duration d) {
        setState(() => _duration = d);
      },
    );
    changePlaylistModeIconState();
    setSongImage();
    checkSongStatus(audioPlayerManager.advancedPlayer.state);
    stateStream = audioPlayerManager.advancedPlayer.onPlayerStateChanged.listen(
      (AudioPlayerState state) {
        checkSongStatus(state);
      },
    );
    onSongCompleteStream =
        audioPlayerManager.advancedPlayer.onPlayerCompletion.listen((a) {
      setSongImage();
    });
  }

  void seekToSecond(int second) {
    Duration duration = new Duration(seconds: second);
    audioPlayerManager.seekTime(duration);
  }

  int checkSongLength() {
    if (audioPlayerManager.songDuration.inMinutes < 59) {
      return 2;
    } else {
      return 0;
    }
  }

  void setSongImage() async {
    if (audioPlayerManager.currentSong.getImageUrl.length > 0) {
      ConnectivityResult connectivityResult =
          await Connectivity().checkConnectivity();
      if (connectivityResult == ConnectivityResult.mobile ||
          connectivityResult == ConnectivityResult.wifi) {
        setState(() {
          songImage = NetworkImage(
            audioPlayerManager.currentSong.getImageUrl,
          );
        });
      } else {
        setState(() {
          songImage = AssetImage('assets/images/default_song_pic.png');
        });
      }
    } else {
      setState(() {
        songImage = AssetImage('assets/images/default_song_pic.png');
      });
    }
  }
}
