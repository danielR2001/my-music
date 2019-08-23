import 'dart:async';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_exoplayer/audioplayer.dart';
import 'package:myapp/core/services/audio_player_service.dart';
import 'package:myapp/core/view_models/page_models/music_player_model.dart';
import 'package:myapp/ui/custom_classes/custom_colors.dart';
import 'package:myapp/ui/custom_classes/custom_icons.dart';
import 'package:myapp/ui/pages/base_page.dart';
import 'package:myapp/ui/widgets/queue_modal_buttom_sheet.dart';
import 'package:myapp/ui/widgets/song_options_modal_buttom_sheet.dart';
import 'package:flip_card/flip_card.dart';

class MusicPlayerPage extends StatefulWidget {
  @override
  MusicPageState createState() => MusicPageState();
}

class MusicPageState extends State<MusicPlayerPage> {
  MusicPlayerModel _model;
  GlobalKey<FlipCardState> flipCardKey = GlobalKey<FlipCardState>();
  Color backgroundColor = CustomColors.darkGreyColor;

  @override
  Widget build(BuildContext context) {
    return BasePage<MusicPlayerModel>(
      onModelReady: (model) async {
        _model = model;
        await _model.setCurrentSong();
        _model.initPlayerStreamSubsciptions();
      },
      builder: (context, model, child) => Scaffold(
        body: GestureDetector(
          onTap: () {},
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  CustomColors.darkGreyColor,
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
                          drawSongOptionsMenu(),
                        ],
                      ),
                    ),
                    drawSongImageLyricsFlipCard(),
                    drawSongTitleArtist(),
                    _model.playerState == PlayerState.BUFFERING
                        ? drawLoadingSlider()
                        : drawSongPositionSlider(),
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
      ),
    );
  }

  // Widgets
  Widget drawSongOptionsMenu() {
    return IconButton(
      iconSize: 30,
      icon: Icon(
        Icons.more_vert,
        color: Colors.white,
      ),
      onPressed: () {
        showMoreOptions(context);
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
                _model.currentPlaylist != null ? "Playing From:" : "",
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
                _model.currentPlaylist != null
                    ? _model.currentPlaylist.name
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
            CustomColors.lightGreyColor,
            CustomColors.darkGreyColor,
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
                _model.currentSong.lyrics != null
                    ? _model.currentSong.lyrics
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
            CustomColors.lightGreyColor,
            CustomColors.darkGreyColor,
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
      child: _model.imageProvider == null
          ? Icon(
              Icons.music_note,
              color: CustomColors.pinkColor,
              size: 120,
            )
          : Image(
              image: _model.imageProvider,
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
              _model.currentSong.title,
              style: TextStyle(
                fontSize: 20.0,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              maxLines: 1,
            ),
            AutoSizeText(
              _model.currentSong.artist,
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
        inactiveTrackColor: CustomColors.lightGreyColor,
        activeTrackColor: Colors.white,
        overlayColor: Colors.transparent,
      ),
      child: Slider(
        value: _model.position.inMilliseconds.toDouble(),
        min: 0.0,
        max: _model.duration.inMilliseconds.toDouble(),
        onChanged: (double value) {
          _model.seekPlayerPosition(value);
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
          valueColor: AlwaysStoppedAnimation<Color>(CustomColors.pinkColor),
          backgroundColor: CustomColors.lightGreyColor,
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
                _model.positionText,
                textAlign: TextAlign.left,
                style: TextStyle(color: Colors.white, fontSize: 13),
              ),
            ),
            Expanded(
              child: Text(
                _model.durationText,
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
        if (!flipCardKey.currentState.isFront) {
          flipCardKey.currentState.toggleCard();
        }
        _model.playPreviousSong();
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
          child: _model.playerState == PlayerState.PLAYING
              ? drawPauseIcon()
              : drawPlayIcon(),
        ),
        onTap: () {
          _model.resume();
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
        _model.playNextSong();
      },
    );
  }

  Widget drawPlaylistModeButton() {
    return Padding(
      padding: const EdgeInsets.only(left: 20),
      child: IconButton(
        splashColor: Colors.grey,
        icon: _model.playlistMode == PlaylistMode.loop
            ? drawLoopIcon()
            : drawShuffleIcon(),
        onPressed: () {
          _model.setCurrentPlaylist();
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

  Widget drawLoopIcon() {
    return Icon(
      MyCustomIcons.repeat_icon,
      color: Colors.white,
      size: 22,
    );
  }

  Widget drawShuffleIcon() {
    return Icon(
      MyCustomIcons.shuffle_icon,
      color: Colors.white,
      size: 22,
    );
  }

  //methods
  void showMoreOptions(BuildContext context) {
    showModalBottomSheet(
      backgroundColor: Colors.transparent,
      context: context,
      builder: (builder) {
        return SongOptionsModalSheet(
          _model.currentSong,
          _model.currentPlaylist,
          true,
          null,
        );
      },
    );
  }

  Future<void> generateBackgroundColors() async {
    Color color = await _model.generateBackgroundColor();
    if (color == null) {
      color = CustomColors.pinkColor;
    }
    if (mounted) {
      setState(() {
        backgroundColor = color;
      });
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
