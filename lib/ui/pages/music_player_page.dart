import 'dart:async';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';

import 'package:myapp/constants/constants.dart';
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
  StreamSubscription<void> completionStream;
  double thumbRadius = 0;
  //bool gifPage = false;

  @override
  void initState() {
    super.initState();
    initSong();
    //gifTimer();
    //tryLoadingImage();
  }

  @override
  void dispose() {
    super.dispose();
    posStream.cancel();
    durStream.cancel();
    stateStream.cancel();
    completionStream.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GestureDetector(
        onTap: () {},
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Constants.darkGreyColor,
                Constants.pinkColor,
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
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Column(
                            children: <Widget>[
                              Text(
                                audioPlayerManager.currentPlaylist != null
                                    ? "Playing From:"
                                    : "",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 13,
                                ),
                              ),
                              SizedBox(
                                height: 5,
                              ),
                              Text(
                                audioPlayerManager.currentPlaylist != null
                                    ? audioPlayerManager.currentPlaylist.getName
                                    : "",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 17,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
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
              audioPlayerManager.currentSong != null
                  ? audioPlayerManager.currentSong.getImageUrl.length > 0
                      ? drawSongImage()
                      : drawDefaultSongImage()
                  : drawDefaultSongImage(),
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
              SliderTheme(
                data: SliderThemeData(
                  thumbShape: RoundSliderThumbShape(enabledThumbRadius: thumbRadius),
                  trackHeight: 3,
                  disabledThumbColor: Colors.black,
                  thumbColor: Constants.pinkColor,
                  inactiveTrackColor: Constants.lightGreyColor,
                  activeTrackColor: Constants.pinkColor,
                  overlayColor: Colors.transparent,
                ),
                child: Slider(
                  value: _position != null && _duration != null
                      ? _position.inSeconds <= _duration.inSeconds
                          ? _position.inSeconds.toDouble()
                          : 0.0
                      : audioPlayerManager.songPosition != null
                          ? audioPlayerManager.songPosition.inSeconds.toDouble()
                          : 0.0,
                  min: 0.0,
                  max: _duration != null
                      ? _duration.inSeconds.toDouble()
                      : audioPlayerManager.songDuration != null
                          ? audioPlayerManager.songDuration.inSeconds.toDouble()
                          : 0.0,
                  onChangeStart: (double value) {
                    setState(() {
                      thumbRadius = 4;
                    });
                  },
                  onChanged: (double value) {
                    setState(() {
                      value = value;
                      _position = Duration(seconds: value.toInt());
                      audioPlayerManager.songPosition =
                          Duration(seconds: value.toInt());
                      seekToSecond(value.toInt());
                    });
                  },
                  onChangeEnd: (double value) {
                    setState(() {
                      thumbRadius = 0;
                    });
                  },
                ),
              ),
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
                          _position != null && _duration != null
                              ? _position.inSeconds <= _duration.inSeconds
                                  ? _position
                                      .toString()
                                      .substring(checkSongLength(), 7)
                                  : "00:00"
                              : audioPlayerManager.songPosition != null
                                  ? audioPlayerManager.songPosition
                                      .toString()
                                      .substring(checkSongLength(), 7)
                                  : "00:00",
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
                              : audioPlayerManager.songDuration != null
                                  ? audioPlayerManager.songDuration
                                      .toString()
                                      .substring(checkSongLength(), 7)
                                  : "00:00",
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
                            if (audioPlayerManager.isLoaded) {
                              setState(() {
                                _position = Duration(seconds: 0);
                                _duration = _duration;
                              });
                              audioPlayerManager.playPreviousSong();
                            }
                          },
                        ),
                        IconButton(
                          splashColor: Colors.grey,
                          alignment: Alignment.center,
                          iconSize: 80,
                          icon: musicPlayerIcon,
                          onPressed: () {
                            if (audioPlayerManager.isLoaded) {
                              audioPlayerManager.audioPlayer.state ==
                                      AudioPlayerState.PLAYING
                                  ? audioPlayerManager.pauseSong(false)
                                  : audioPlayerManager.resumeSong(false);
                            }
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
                            if (audioPlayerManager.isLoaded) {
                              setState(() {
                                _position = Duration(seconds: 0);
                                _duration = _duration;
                              });
                              audioPlayerManager.playNextSong();
                            }
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
      ),
    );
  }

  void showMoreOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (builder) {
        return SongOptionsModalSheet(
          audioPlayerManager.currentSong,
          audioPlayerManager.currentPlaylist,
          true,
        );
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
    posStream = audioPlayerManager.audioPlayer.onAudioPositionChanged
        .listen((Duration p) => setState(() => _position = p));

    durStream = audioPlayerManager.audioPlayer.onDurationChanged.listen(
      (Duration d) {
        setState(() => _duration = d);
      },
    );
    completionStream =
        audioPlayerManager.audioPlayer.onPlayerCompletion.listen((a) {
      setState(() {
        _position = Duration(seconds: 0);
      });
    });
    changePlaylistModeIconState();
    checkSongStatus(audioPlayerManager.audioPlayer.state);
    stateStream = audioPlayerManager.audioPlayer.onPlayerStateChanged.listen(
      (AudioPlayerState state) {
        checkSongStatus(state);
      },
    );
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

  Widget drawDefaultSongImage() {
    return Expanded(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Container(
            width: 260,
            height: 260,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Constants.lightGreyColor,
                  Constants.darkGreyColor,
                ],
                begin: FractionalOffset.bottomLeft,
                stops: [0.3, 0.8],
                end: FractionalOffset.topRight,
              ),
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
            ),
            child: Icon(
              Icons.music_note,
              color: Constants.pinkColor,
              size: 120,
            ),
          ),
        ],
      ),
    );
  }

  Widget drawSongImage() {
    return Expanded(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Container(
            width: 260,
            height: 260,
            decoration: BoxDecoration(
                color: Constants.lightGreyColor,
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
                  image: NetworkImage(
                    audioPlayerManager.currentSong.getImageUrl,
                  ),
                  fit: BoxFit.contain,
                )),
          ),
        ],
      ),
    );
  }
}
