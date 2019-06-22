import 'dart:async';
import 'dart:io';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:myapp/communicate_with_native/internet_connection_check.dart';
import 'package:myapp/constants/constants.dart';
import 'package:myapp/main.dart';
import 'package:myapp/audio_player/audio_player_manager.dart';
import 'package:myapp/manage_local_songs/manage_local_songs.dart';
import 'package:myapp/ui/widgets/queue_modal_buttom_sheet.dart';
import 'package:myapp/ui/widgets/song_options_modal_buttom_sheet.dart';
import 'package:myapp/ui/widgets/text_style.dart';
import 'package:flip_card/flip_card.dart';

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
  ImageProvider imageProvider;
  GlobalKey<FlipCardState> flipCardKey = GlobalKey<FlipCardState>();
  @override
  void initState() {
    super.initState();
    checkForIntenetConnetionForNetworkImage();
    initSong();
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
              stops: [0.28, 1.0],
              end: FractionalOffset.topCenter,
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.only(
                  top: 10, bottom: 20, left: 10, right: 10),
              child: Column(
                children: <Widget>[
                  Row(
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
                                      ? audioPlayerManager
                                          .currentPlaylist.getName
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
                            if (audioPlayerManager.currentSong != null) {
                              showMoreOptions(context);
                            }
                          }),
                    ],
                  ),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Container(
                          width: 320,
                          height: 320,
                          child: FlipCard(
                            key: flipCardKey,
                            direction: FlipDirection.VERTICAL,
                            flipOnTouch: true,
                            front: drawSongImageWidget(),
                            back: drawLyricsWidget(),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    children: <Widget>[
                      TextDecoration(
                        audioPlayerManager.currentSong != null
                            ? audioPlayerManager.currentSong.getTitle
                            : "",
                        25,
                        Colors.white,
                        20,
                        30,
                      ),
                      TextDecoration(
                        audioPlayerManager.currentSong != null
                            ? audioPlayerManager.currentSong.getArtist
                            : "",
                        14,
                        Colors.grey,
                        30,
                        30,
                      ),
                    ],
                  ),
                  SliderTheme(
                    data: SliderThemeData(
                      thumbShape: RoundSliderThumbShape(
                          enabledThumbRadius: thumbRadius),
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
                              ? audioPlayerManager.songPosition.inSeconds
                                  .toDouble()
                              : 0.0,
                      min: 0.0,
                      max: _duration != null
                          ? _duration.inSeconds.toDouble()
                          : audioPlayerManager.songDuration != null
                              ? audioPlayerManager.songDuration.inSeconds
                                  .toDouble()
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
                                if (audioPlayerManager.currentPlaylist !=
                                    null) {
                                  if (audioPlayerManager.isLoaded &&
                                      audioPlayerManager.songPosition !=
                                          Duration(milliseconds: 0)) {
                                    setState(() {
                                      _position = Duration(seconds: 0);
                                      _duration = _duration;
                                    });
                                    if (!flipCardKey.currentState.isFront) {
                                      flipCardKey.currentState.toggleCard();
                                    }
                                    imageProvider = null;
                                    audioPlayerManager.playPreviousSong();
                                  }
                                }
                              },
                            ),
                            IconButton(
                              splashColor: Colors.grey,
                              alignment: Alignment.center,
                              iconSize: 80,
                              icon: musicPlayerIcon,
                              onPressed: () {
                                if (audioPlayerManager.isLoaded &&
                                    audioPlayerManager.songPosition !=
                                        Duration(milliseconds: 0)) {
                                  audioPlayerManager.audioPlayer.state ==
                                          AudioPlayerState.PLAYING
                                      ? audioPlayerManager.pauseSong(false)
                                      : audioPlayerManager.audioPlayer.state ==
                                              AudioPlayerState.PAUSED
                                          ? audioPlayerManager.resumeSong(false)
                                          : playSong();
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
                                if (audioPlayerManager.currentPlaylist !=
                                    null) {
                                  if (audioPlayerManager.isLoaded &&
                                      audioPlayerManager.songPosition !=
                                          Duration(milliseconds: 0)) {
                                    setState(() {
                                      _position = Duration(seconds: 0);
                                      _duration = _duration;
                                    });
                                    if (!flipCardKey.currentState.isFront) {
                                      flipCardKey.currentState.toggleCard();
                                    }
                                    imageProvider = null;
                                    audioPlayerManager.playNextSong();
                                  }
                                }
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Row(
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
                            audioPlayerManager.shuffledPlaylist = null;
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
                            Icons.queue_music,
                            size: 25,
                            color: Colors.white,
                          ),
                          onPressed: () {
                            showQueueModalBottomSheet(context);
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
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
          null,
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
            size: 25,
          );
        },
      );
    } else {
      setState(
        () {
          playlistModeIcon = Icon(
            Icons.shuffle,
            color: Colors.white,
            size: 25,
          );
        },
      );
    }
  }

  void checkSongStatus(AudioPlayerState state) {
    if (state == AudioPlayerState.PLAYING) {
      checkForIntenetConnetionForNetworkImage();
      changePlayingIconState(true);
    } else if (state == AudioPlayerState.PAUSED) {
      changePlayingIconState(false);
    } else if (state == AudioPlayerState.STOPPED) {
      setState(() {
        _position = Duration(seconds: 0);
      });
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
      checkForIntenetConnetionForNetworkImage();
      setState(() {
        if (!flipCardKey.currentState.isFront) {
          flipCardKey.currentState.toggleCard();
        }
        imageProvider = null;
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
    if (audioPlayerManager.songDuration != null) {
      if (audioPlayerManager.songDuration.inMinutes < 59) {
        return 2;
      } else {
        return 0;
      }
    } else {
      return 2;
    }
  }

  void checkForIntenetConnetionForNetworkImage() {
    InternetConnectioCheck.check().then((available) {
      ManageLocalSongs.checkIfFileExists(audioPlayerManager.currentSong)
          .then((exists) {
        if (exists) {
          File file = File(
              "${ManageLocalSongs.fullSongDownloadDir.path}/${audioPlayerManager.currentSong.getSongId}/${audioPlayerManager.currentSong.getSongId}.png");
          setState(() {
            imageProvider = FileImage(file);
          });
        } else {
          if (available) {
            setState(() {
              imageProvider = NetworkImage(
                audioPlayerManager.currentSong.getImageUrl,
              );
            });
          }
        }
      });
    });
  }

  void playSong() {
    checkForIntenetConnetionForNetworkImage();
    audioPlayerManager.initSong(
      audioPlayerManager.currentSong,
      audioPlayerManager.currentPlaylist,
      audioPlayerManager.playlistMode,
    );
    audioPlayerManager.playSong();
  }

  void showQueueModalBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (builder) {
        return QueueModalSheet();
      },
    );
  }

  Widget drawLyricsWidget() {
    return Container(
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
      child: Theme(
        data: Theme.of(context).copyWith(accentColor: Colors.grey),
        child: ListView(
          padding: EdgeInsets.only(top: 10),
          children: <Widget>[
            // Padding(
            //   padding: const EdgeInsets.only(bottom: 5),
            //   child: Container(
            //     width: 160,
            //     height: 40,
            //     child: Image(
            //       image: AssetImage("assets/images/genius_logo.png"),
            //       fit: BoxFit.contain,
            //     ),
            //   ),
            // ),
            Padding(
              padding: const EdgeInsets.only(bottom: 15),
              child: Text(
                "Lyrics",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            Container(
              height: 1,
              width: 300,
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
              child: Text(
                audioPlayerManager.currentSong.getLyrics != null
                    ? audioPlayerManager.currentSong.getLyrics
                    : "We didn't find lyrics for this song",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 17,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget drawSongImageWidget() {
    return Container(
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
        child: audioPlayerManager.currentSong.getImageUrl.length == 0 ||
                imageProvider == null
            ? Icon(
                Icons.music_note,
                color: Constants.pinkColor,
                size: 120,
              )
            : Image(
                image: imageProvider,
                fit: BoxFit.contain,
              ));
  }
}
