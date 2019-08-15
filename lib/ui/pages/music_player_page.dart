import 'dart:async';
import 'dart:io';
import 'package:audioplayers/audioplayers.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:connectivity/connectivity.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:myapp/communicate_with_native/native_communication_service.dart';
import 'package:myapp/custom_classes/custom_colors.dart';
import 'package:myapp/managers/audio_player_manager.dart';
import 'package:myapp/custom_classes/custom_icons.dart';
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
  Icon playlistModeIcon;
  Icon musicPlayerIcon;
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
              stops: [0.22, 1.0],
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
                        drawBackButton(),
                        drawPlaylistName(),
                        drawPlaylistMoreMenu(),
                      ],
                    ),
                  ),
                  drawSongImageLyricsFlipCard(),
                  drawSongTitleArtist(),
                  GlobalVariables.audioPlayerManager.isSongActuallyPlaying
                      ? drawSongPositionSlider()
                      : drawLoadingSlider(),
                  drawSongPositionAndDuration(),
                  Container(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Row(
                          children: <Widget>[
                            drawPreviousButton(),
                            drawPlayButton(),
                            drawNextButton(),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Row(
                    children: [
                      drawPlaylistModeButton(),
                      Expanded(
                        child: Container(),
                      ),
                      drawPlaylistQueue(),
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

  // Widgets
  Widget drawPlaylistMoreMenu() {
    return IconButton(
      iconSize: 30,
      icon: Icon(
        Icons.more_vert,
        color: Colors.white,
      ),
      onPressed: () {
        if (GlobalVariables.audioPlayerManager.currentSong != null) {
          showMoreOptions(context);
        }
      },
    );
  }

  Widget drawBackButton() {
    return IconButton(
      iconSize: 40,
      icon: Icon(
        Icons.keyboard_arrow_down,
        color: Colors.white,
      ),
      onPressed: () => Navigator.pop(context),
    );
  }

  Widget drawPlaylistName() {
    return Expanded(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Column(
            children: <Widget>[
              Text(
                GlobalVariables.audioPlayerManager.currentPlaylist != null
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
                GlobalVariables.audioPlayerManager.currentPlaylist != null
                    ? GlobalVariables.audioPlayerManager.currentPlaylist.name
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
    );
  }

  Widget drawSongImageLyricsFlipCard() {
    return Expanded(
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
                GlobalVariables.audioPlayerManager.currentSong.lyrics != null
                    ? GlobalVariables.audioPlayerManager.currentSong.lyrics
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
      child:
          GlobalVariables.audioPlayerManager.currentSong.imageUrl.length == 0 ||
                  imageProvider == null
              ? Icon(
                  Icons.music_note,
                  color: GlobalVariables.pinkColor,
                  size: 120,
                )
              : Image(
                  image: imageProvider,
                  fit: BoxFit.contain,
                ),
    );
  }

  Widget drawSongTitleArtist() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Container(
        width: 300,
        child: Column(
          children: <Widget>[
            AutoSizeText(
              GlobalVariables.audioPlayerManager.currentSong.title,
              style: TextStyle(
                fontSize: 20.0,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              maxLines: 1,
            ),
            AutoSizeText(
              GlobalVariables.audioPlayerManager.currentSong.artist,
              style: TextStyle(
                fontSize: 14.0,
                color: Colors.grey,
              ),
              maxLines: 1,
            ),
          ],
        ),
      ),
    );
  }

  Widget drawSongPositionSlider() {
    return SliderTheme(
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
            : GlobalVariables.audioPlayerManager.songPosition != null
                ? GlobalVariables.audioPlayerManager.songPosition.inSeconds
                    .toDouble()
                : 0.0,
        min: 0.0,
        max: _duration != null
            ? _duration.inSeconds.toDouble()
            : GlobalVariables.audioPlayerManager.songDuration != null
                ? GlobalVariables.audioPlayerManager.songDuration.inSeconds
                    .toDouble()
                : 0.0,
        onChanged: (double value) {
          setState(() {
            value = value;
            _position = Duration(seconds: value.toInt());
            GlobalVariables.audioPlayerManager.songPosition =
                Duration(seconds: value.toInt());
            seekToSecond(value.toInt());
          });
        },
      ),
    );
  }

  Widget drawLoadingSlider() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 22.5, horizontal: 22),
      child: SizedBox(
        height: 3,
        width: 576,
        child: LinearProgressIndicator(
          value: null,
          valueColor: AlwaysStoppedAnimation<Color>(GlobalVariables.pinkColor),
          backgroundColor: GlobalVariables.lightGreyColor,
        ),
      ),
    );
  }

  Widget drawSongPositionAndDuration() {
    return Container(
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
                        ? _position.toString().substring(checkSongLength(), 7)
                        : "00:00"
                    : GlobalVariables.audioPlayerManager.songPosition != null
                        ? GlobalVariables.audioPlayerManager.songPosition
                            .toString()
                            .substring(checkSongLength(), 7)
                        : "00:00",
                textAlign: TextAlign.left,
                style: TextStyle(color: Colors.white, fontSize: 13),
              ),
            ),
            Expanded(
              child: Text(
                _duration != null
                    ? _duration.toString().substring(checkSongLength(), 7)
                    : GlobalVariables.audioPlayerManager.songDuration != null
                        ? GlobalVariables.audioPlayerManager.songDuration
                            .toString()
                            .substring(checkSongLength(), 7)
                        : "00:00",
                textAlign: TextAlign.right,
                style: TextStyle(color: Colors.white, fontSize: 13),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget drawPreviousButton() {
    return IconButton(
      splashColor: Colors.grey,
      alignment: Alignment.center,
      iconSize: 25,
      icon: Icon(
        MyCustomIcons.previous_icon,
        color: Colors.white,
      ),
      onPressed: () {
        if (GlobalVariables.audioPlayerManager.currentPlaylist != null &&
            GlobalVariables.audioPlayerManager.currentPlaylist.songs.length >
                0 &&
            GlobalVariables.audioPlayerManager.isSongLoaded) {
          setState(() {
            _position = Duration(seconds: 0);
            _duration = _duration;
            if (GlobalVariables.audioPlayerManager.previousMode ==
                PreviousMode.previous) {
              imageProvider = null;
            }
          });
          if (!flipCardKey.currentState.isFront) {
            flipCardKey.currentState.toggleCard();
          }
          GlobalVariables.audioPlayerManager.playPreviousSong();
          checkForIntenetConnetionForNetworkImage();
        }
      },
    );
  }

  Widget drawPlayButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      child: GestureDetector(
        child: Container(
          width: 80,
          height: 80,
          alignment: Alignment.center,
          child: musicPlayerIcon,
        ),
        onTap: () {
          if (GlobalVariables.audioPlayerManager.isSongLoaded &&
              GlobalVariables.audioPlayerManager.isSongActuallyPlaying) {
            GlobalVariables.audioPlayerManager.audioPlayer.state ==
                    AudioPlayerState.PLAYING
                ? GlobalVariables.audioPlayerManager
                    .pauseSong(calledFromNative: false)
                : GlobalVariables.audioPlayerManager.audioPlayer.state ==
                        AudioPlayerState.PAUSED
                    ? GlobalVariables.audioPlayerManager
                        .resumeSong(calledFromNative: false)
                    : playSong();
          }
        },
      ),
    );
  }

  Widget drawNextButton() {
    return IconButton(
      splashColor: Colors.grey,
      alignment: Alignment.center,
      iconSize: 25,
      icon: Icon(
        MyCustomIcons.next_icon,
        color: Colors.white,
      ),
      onPressed: () {
        if (GlobalVariables.audioPlayerManager.currentPlaylist != null &&
            GlobalVariables.audioPlayerManager.currentPlaylist.songs.length >
                0 &&
            GlobalVariables.audioPlayerManager.isSongLoaded) {
          setState(() {
            _position = Duration(seconds: 0);
            _duration = _duration;
            imageProvider = null;
          });
          if (!flipCardKey.currentState.isFront) {
            flipCardKey.currentState.toggleCard();
          }
          GlobalVariables.audioPlayerManager.playNextSong();
          checkForIntenetConnetionForNetworkImage();
        }
      },
    );
  }

  Widget drawPlaylistModeButton() {
    return Padding(
      padding: const EdgeInsets.only(left: 20),
      child: IconButton(
        splashColor: Colors.grey,
        icon: playlistModeIcon,
        onPressed: () {
          GlobalVariables.audioPlayerManager.playlistMode == PlaylistMode.loop
              ? GlobalVariables.audioPlayerManager.playlistMode =
                  PlaylistMode.shuffle
              : GlobalVariables.audioPlayerManager.playlistMode =
                  PlaylistMode.loop;
          GlobalVariables.audioPlayerManager.shuffledPlaylist = null;
          changePlaylistModeIconState();
          GlobalVariables.audioPlayerManager.setCurrentPlaylist();
        },
      ),
    );
  }

  Widget drawPlaylistQueue() {
    return Padding(
      padding: const EdgeInsets.only(right: 20),
      child: IconButton(
        splashColor: Colors.grey,
        icon: Icon(
          Icons.playlist_play,
          size: 30,
          color: Colors.white,
        ),
        onPressed: () {
          showQueueModalBottomSheet(context);
        },
      ),
    );
  }

  Widget drawPauseIcon() {
    return Icon(
      Icons.pause_circle_filled,
      color: Colors.white,
      size: 77,
    );
  }

  Widget drawPlayIcon() {
    return Icon(
      MyCustomIcons.play_rounded_icon,
      color: Colors.white,
      size: 80,
    );
  }

  //methods
  void showMoreOptions(BuildContext context) {
    showModalBottomSheet(
      backgroundColor: Colors.transparent,
      context: context,
      builder: (builder) {
        return SongOptionsModalSheet(
          GlobalVariables.audioPlayerManager.currentSong,
          GlobalVariables.audioPlayerManager.currentPlaylist,
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
          musicPlayerIcon = drawPauseIcon();
        },
      );
    } else {
      setState(
        () {
          musicPlayerIcon = drawPlayIcon();
        },
      );
    }
  }

  void changePlaylistModeIconState() {
    if (GlobalVariables.audioPlayerManager.playlistMode == PlaylistMode.loop) {
      setState(
        () {
          playlistModeIcon = Icon(
            MyCustomIcons.repeat_icon,
            color: Colors.white,
            size: 22,
          );
        },
      );
    } else {
      setState(
        () {
          playlistModeIcon = Icon(
            MyCustomIcons.shuffle_icon,
            color: Colors.white,
            size: 22,
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
      if (mounted) {
        setState(() {
          _position = Duration(seconds: 0);
        });
      }
      changePlayingIconState(false);
    } else if (state == AudioPlayerState.COMPLETED) {
      if (mounted) {
        setState(() {
          _position = Duration(seconds: 0);
        });
      }
      changePlayingIconState(false);
    }
  }

  void initSong() {
    posStream = GlobalVariables
        .audioPlayerManager.audioPlayer.onAudioPositionChanged
        .listen((Duration p) {
      if (mounted) {
        setState(() => _position = p);
      }
    });

    durStream =
        GlobalVariables.audioPlayerManager.audioPlayer.onDurationChanged.listen(
      (Duration d) {
        if (mounted) {
          setState(() => _duration = d);
        }
      },
    );
    completionStream = GlobalVariables
        .audioPlayerManager.audioPlayer.onPlayerCompletion
        .listen((a) {
      checkForIntenetConnetionForNetworkImage();
      if (mounted) {
        if (!flipCardKey.currentState.isFront) {
          flipCardKey.currentState.toggleCard();
        }
        setState(() {
          imageProvider = null;
          _position = Duration(seconds: 0);
        });
      }
    });
    changePlaylistModeIconState();
    checkSongStatus(GlobalVariables.audioPlayerManager.audioPlayer.state);
    stateStream = GlobalVariables
        .audioPlayerManager.audioPlayer.onPlayerStateChanged
        .listen(
      (AudioPlayerState state) {
        checkSongStatus(state);
      },
    );
  }

  void seekToSecond(int second) {
    GlobalVariables.audioPlayerManager
        .seekTime(duration: Duration(seconds: second));
  }

  int checkSongLength() {
    if (GlobalVariables.audioPlayerManager.songDuration != null) {
      if (GlobalVariables.audioPlayerManager.songDuration.inMinutes < 59) {
        return 2;
      } else {
        return 0;
      }
    } else {
      return 2;
    }
  }

  void checkForIntenetConnetionForNetworkImage() {
    generateBackgroundColors();
    if (GlobalVariables.audioPlayerManager.currentSong.imageUrl != "") {
      GlobalVariables.manageLocalSongs
          .checkIfImageFileExists(
              GlobalVariables.audioPlayerManager.currentSong)
          .then((exists) {
        if (exists) {
          File file = File(
              "${GlobalVariables.manageLocalSongs.fullSongDownloadDir.path}/${GlobalVariables.audioPlayerManager.currentSong.songId}/${GlobalVariables.audioPlayerManager.currentSong.songId}.png");
          if (mounted) {
            setState(() {
              imageProvider = FileImage(file);
            });
          }
        } else {
          if (GlobalVariables.isNetworkAvailable) {
            if (mounted) {
              setState(() {
                imageProvider = NetworkImage(
                  GlobalVariables.audioPlayerManager.currentSong.imageUrl,
                );
              });
            }
          }
        }
      });
    }
  }

  void playSong() {
    checkForIntenetConnetionForNetworkImage();
    GlobalVariables.audioPlayerManager.initSong(
      song: GlobalVariables.audioPlayerManager.currentSong,
      playlist: GlobalVariables.audioPlayerManager.currentPlaylist,
      mode: GlobalVariables.audioPlayerManager.playlistMode,
    );
  }

  Future generateBackgroundColors() async {
    if (GlobalVariables.audioPlayerManager.currentSong.imageUrl != "") {
      String dominantColor;
      ConnectivityResult connectivityResult =
          await Connectivity().checkConnectivity();
      bool exists = await GlobalVariables.manageLocalSongs
          .checkIfSongFileExists(
              GlobalVariables.audioPlayerManager.currentSong);
      if (exists) {
        dominantColor = await NativeCommunicationService.getDominantColor(
            imagePath:
                "${GlobalVariables.manageLocalSongs.fullSongDownloadDir.path}/${GlobalVariables.audioPlayerManager.currentSong.songId}/${GlobalVariables.audioPlayerManager.currentSong.songId}.png",
            isLocal: true);
      } else {
        if (connectivityResult == ConnectivityResult.mobile ||
            connectivityResult == ConnectivityResult.wifi) {
          dominantColor = await NativeCommunicationService.getDominantColor(
              imagePath:
                  GlobalVariables.audioPlayerManager.currentSong.imageUrl,
              isLocal: false);
        }
      }

      if (dominantColor != null) {
        dominantColor = dominantColor.replaceAll("#", "");
        dominantColor = "0xff" + dominantColor;
        if (mounted) {
          setState(() {
            backgroundColor = Color(int.parse(dominantColor));
          });
        }
      } else {
        if (mounted) {
          setState(() {
            backgroundColor = GlobalVariables.pinkColor;
          });
        }
      }
    } else {
      if (mounted) {
        setState(() {
          backgroundColor = GlobalVariables.pinkColor;
        });
      }
    }
  }

  void showQueueModalBottomSheet(BuildContext context) {
    showModalBottomSheet(
      backgroundColor: Colors.transparent,
      context: context,
      builder: (builder) {
        return QueueModalSheet();
      },
    );
  }
}
