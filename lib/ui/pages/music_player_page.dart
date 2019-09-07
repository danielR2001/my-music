import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_exoplayer/audioplayer.dart';
import 'package:myapp/core/services/audio_player_service.dart';
import 'package:myapp/core/view_models/page_models/music_player_model.dart';
import 'package:myapp/ui/custom_classes/custom_colors.dart';
import 'package:myapp/ui/custom_classes/custom_icons.dart';
import 'package:myapp/ui/pages/base_page.dart';
import 'package:myapp/ui/modal_sheets/queue_modal_buttom_sheet.dart';
import 'package:myapp/ui/modal_sheets/song_options_modal_buttom_sheet.dart';
import 'package:flip_card/flip_card.dart';

class MusicPlayerPage extends StatefulWidget {
  @override
  MusicPageState createState() => MusicPageState();
}

class MusicPageState extends State<MusicPlayerPage> {
  GlobalKey<FlipCardState> flipCardKey = GlobalKey<FlipCardState>();

  @override
  Widget build(BuildContext context) {
    return BasePage<MusicPlayerModel>(
      onModelReady: (model) async => await model.initModel(),
      onModelDisposed: (model) => model.disposeModel(),
      builder: (context, model, child) => Scaffold(
        body: GestureDetector(
          onTap: () {},
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  CustomColors.darkGreyColor,
                  model.backgroundColor,
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
                          drawPlaylistName(model),
                          drawSongOptionsMenu(model),
                        ],
                      ),
                    ),
                    drawSongImageLyricsFlipCard(model),
                    drawSongTitleArtist(model),
                    model.playerState == PlayerState.BUFFERING
                        ? drawLoadingSlider()
                        : drawSongPositionSlider(model),
                    drawSongPositionAndDuration(model),
                    Container(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Row(
                            children: <Widget>[
                              drawPreviousButton(model),
                              drawPlayButton(model),
                              drawNextButton(model),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Row(
                      children: [
                        drawPlaylistModeButton(model),
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
  Widget drawSongOptionsMenu(MusicPlayerModel model) {
    return IconButton(
      iconSize: 30,
      icon: Icon(
        Icons.more_vert,
        color: Colors.white,
      ),
      onPressed: () {
        showMoreOptions(context, model);
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

  Widget drawPlaylistName(MusicPlayerModel model) {
    return Expanded(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Column(
            children: <Widget>[
              Text(
                model.currentPlaylist != null ? "Playing From:" : "",
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
                model.currentPlaylist != null ? model.currentPlaylist.name : "",
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

  Widget drawSongImageLyricsFlipCard(MusicPlayerModel model) {
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
              front: drawSongImageWidget(model),
              back: drawLyricsWidget(model),
            ),
          ),
        ],
      ),
    );
  }

  Widget drawLyricsWidget(MusicPlayerModel model) {
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
                model.currentSong != null
                    ? model.currentSong.lyrics != null
                        ? model.currentSong.lyrics
                        : "We couldn't find lyrics for this song."
                    : "",
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

  Widget drawSongImageWidget(MusicPlayerModel model) {
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
      child: model.imageProvider == null
          ? Icon(
              Icons.music_note,
              color: CustomColors.pinkColor,
              size: 120,
            )
          : Image(
              image: model.imageProvider,
              fit: BoxFit.contain,
            ),
    );
  }

  Widget drawSongTitleArtist(MusicPlayerModel model) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Container(
        width: 300,
        child: Column(
          children: <Widget>[
            AutoSizeText(
              model.currentSong != null ? model.currentSong.title : "",
              style: TextStyle(
                fontSize: 20.0,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              maxLines: 1,
            ),
            AutoSizeText(
              model.currentSong != null ? model.currentSong.artist : "",
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

  Widget drawSongPositionSlider(MusicPlayerModel model) {
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
        value: model.position.inMilliseconds.toDouble(),
        min: 0.0,
        max: model.duration.inMilliseconds.toDouble(),
        onChanged: (double value) {
          model.seekPlayerPosition(value);
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

  Widget drawSongPositionAndDuration(MusicPlayerModel model) {
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
                model.positionText,
                textAlign: TextAlign.left,
                style: TextStyle(color: Colors.white, fontSize: 13),
              ),
            ),
            Expanded(
              child: Text(
                model.durationText,
                textAlign: TextAlign.right,
                style: TextStyle(color: Colors.white, fontSize: 13),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget drawPreviousButton(MusicPlayerModel model) {
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
        model.playPreviousSong();
      },
    );
  }

  Widget drawPlayButton(MusicPlayerModel model) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      child: GestureDetector(
        child: Container(
          width: 80,
          height: 80,
          alignment: Alignment.center,
          child: model.playerState == PlayerState.PLAYING
              ? drawPauseIcon()
              : drawPlayIcon(),
        ),
        onTap: () {
          model.playerState == PlayerState.PLAYING
              ? model.pause()
              : model.resume();
        },
      ),
    );
  }

  Widget drawNextButton(MusicPlayerModel model) {
    return IconButton(
      splashColor: Colors.grey,
      alignment: Alignment.center,
      iconSize: 25,
      icon: Icon(
        MyCustomIcons.next_icon,
        color: Colors.white,
      ),
      onPressed: () {
        model.playNextSong();
      },
    );
  }

  Widget drawPlaylistModeButton(MusicPlayerModel model) {
    return Padding(
      padding: const EdgeInsets.only(left: 20),
      child: IconButton(
        splashColor: Colors.grey,
        icon: model.playlistMode == PlaylistMode.loop
            ? drawLoopIcon()
            : drawShuffleIcon(),
        onPressed: () {
          model.setCurrentPlaylist();
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
  void showMoreOptions(BuildContext context, MusicPlayerModel model) {
    showModalBottomSheet(
      backgroundColor: Colors.transparent,
      context: model.tabNavigatorKey.currentContext,
      builder: (builder) {
        return SongOptionsModalSheet(
          model.currentSong,
          model.currentPlaylist,
          true,
          null,
        );
      },
    );
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
