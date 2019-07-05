import 'dart:async';
import 'dart:io';
import 'package:audioplayers/audioplayers.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:myapp/communicate_with_native/get_image_dominant_color.dart';
import 'package:myapp/communicate_with_native/internet_connection_check.dart';
import 'package:myapp/global_variables/global_variables.dart';
import 'package:myapp/main.dart';
import 'package:myapp/audio_player/audio_player_manager.dart';
import 'package:myapp/manage_local_songs/manage_local_songs.dart';
import 'package:myapp/ui/widgets/queue_modal_buttom_sheet.dart';
import 'package:myapp/ui/widgets/song_options_modal_buttom_sheet.dart';
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
  ImageProvider imageProvider;
  GlobalKey<FlipCardState> flipCardKey = GlobalKey<FlipCardState>();
  Color backgroundColor = GlobalVariables.darkGreyColor;
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
                GlobalVariables.darkGreyColor,
                backgroundColor,
              ],
              begin: FractionalOffset.bottomCenter,
              stops: [0.28, 1.0],
              end: FractionalOffset.topCenter,
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.only(top: 10, bottom: 20),
              child: Column(
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
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
                                    textAlign: TextAlign.center,
                                  ),
                                  SizedBox(
                                    height: 5,
                                  ),
                                  AutoSizeText(
                                    audioPlayerManager.currentPlaylist != null
                                        ? audioPlayerManager
                                            .currentPlaylist.getName
                                        : "",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15,
                                    ),
                                    textAlign: TextAlign.center,
                                    maxLines: 1,
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
                  ),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Container(
                          width: 300,
                          height: 300,
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
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Column(
                      children: <Widget>[
                        AutoSizeText(
                          audioPlayerManager.currentSong != null
                              ? audioPlayerManager.currentSong.getTitle
                              : "",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20.0,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                          maxLines: 1,
                        ),
                        SizedBox(
                          height: 5,
                        ),
                        AutoSizeText(
                          audioPlayerManager.currentSong != null
                              ? audioPlayerManager.currentSong.getArtist
                              : "",
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 14.0,
                          ),
                          textAlign: TextAlign.center,
                          maxLines: 1,
                        ),
                      ],
                    ),
                  ),
                  SliderTheme(
                    data: SliderThemeData(
                      thumbShape: RoundSliderThumbShape(enabledThumbRadius: 5),
                      trackHeight: 3,
                      thumbColor: Colors.white,
                      inactiveTrackColor: GlobalVariables.lightGreyColor,
                      activeTrackColor: Colors.white,
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
                      onChanged: (double value) {
                        setState(() {
                          value = value;
                          _position = Duration(seconds: value.toInt());
                          audioPlayerManager.songPosition =
                              Duration(seconds: value.toInt());
                          seekToSecond(value.toInt());
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
                              style:
                                  TextStyle(color: Colors.white, fontSize: 13),
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
                              style:
                                  TextStyle(color: Colors.white, fontSize: 13),
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
                                        null &&
                                    audioPlayerManager
                                            .currentPlaylist.getSongs.length >
                                        0) {
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
                                    if (audioPlayerManager.previousMode ==
                                        PreviousMode.previous) {
                                      imageProvider = null;
                                    }

                                    audioPlayerManager.playPreviousSong(false);
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
                                      ? audioPlayerManager.pauseSong(
                                          calledFromNative: false)
                                      : audioPlayerManager.audioPlayer.state ==
                                              AudioPlayerState.PAUSED
                                          ? audioPlayerManager.resumeSong(
                                              calledFromNative: false)
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
                                        null &&
                                    audioPlayerManager
                                            .currentPlaylist.getSongs.length >
                                        0) {
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
            CupertinoIcons.shuffle_medium,
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
    } else if (state == AudioPlayerState.COMPLETED) {
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
    audioPlayerManager.seekTime(duration: duration);
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
    InternetConnectionCheck.check().then((available) {
      ManageLocalSongs.checkIfFileExists(audioPlayerManager.currentSong)
          .then((exists) {
        if (exists) {
          File file = File(
              "${ManageLocalSongs.fullSongDownloadDir.path}/${audioPlayerManager.currentSong.getSongId}/${audioPlayerManager.currentSong.getSongId}.png");
          setState(() {
            imageProvider = FileImage(file);
          });
          generateBackgroundColors();
        } else {
          if (available) {
            setState(() {
              imageProvider = NetworkImage(
                audioPlayerManager.currentSong.getImageUrl,
              );
            });
            generateBackgroundColors();
          }
        }
      });
    });
  }

  void playSong() {
    checkForIntenetConnetionForNetworkImage();
    audioPlayerManager.initSong(
      song: audioPlayerManager.currentSong,
      playlist: audioPlayerManager.currentPlaylist,
      playlistMode: audioPlayerManager.playlistMode,
    );
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
            GlobalVariables.lightGreyColor,
            GlobalVariables.darkGreyColor,
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
                    : "We couldn't find lyrics for this song.",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
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
              GlobalVariables.lightGreyColor,
              GlobalVariables.darkGreyColor,
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
              blurRadius: 1.0,
              spreadRadius: 0.5,
            ),
          ],
        ),
        child: audioPlayerManager.currentSong.getImageUrl.length == 0 ||
                imageProvider == null
            ? Icon(
                Icons.music_note,
                color: GlobalVariables.pinkColor,
                size: 120,
              )
            : Image(
                image: imageProvider,
                fit: BoxFit.contain,
              ));
  }

  Future generateBackgroundColors() async {
    if (audioPlayerManager.currentSong.getImageUrl != "") {
      String dominantColor = await GetImageDominantColor.getDominantColor(
          audioPlayerManager.currentSong.getImageUrl);
      if (dominantColor != null) {
        dominantColor = dominantColor.replaceAll("#", "");
        dominantColor = "0xff" + dominantColor;
        setState(() {
          backgroundColor = Color(int.parse(dominantColor));
        });
      }
    } else {
      setState(() {
        backgroundColor = GlobalVariables.pinkColor;
      });
    }
  }
}
