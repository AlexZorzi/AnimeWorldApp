import 'dart:io';

import 'package:better_player/better_player.dart';
import 'package:dart_vlc/dart_vlc.dart';
import 'package:wakelock/wakelock.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:hive/hive.dart';
import 'package:window_manager/window_manager.dart';

class LandscapePlayer extends StatefulWidget {
  bool isNetwork;
  final Function refreshinfo;
  final String RawDataSource;
  final epnumber;
  final animeid;

  LandscapePlayer(
      {Key key,
      this.RawDataSource,
      this.isNetwork,
      this.epnumber,
      this.animeid,
      this.refreshinfo})
      : super(key: key);

  @override
  _LandscapePlayerState createState() => _LandscapePlayerState();
}

class _LandscapePlayerState extends State<LandscapePlayer> {
  BetterPlayerController videoManager;
  var Link;
  Box<Map> timestamps;
  var betterPlayerConfiguration;
  BetterPlayerDataSource sourceMobile;
  Media sourceDesktop;
  GlobalKey betterPlayerKey;
  Player player;

  @override
  void initState() {
    super.initState();
    timestamps = Hive.box<Map>("timestamps");
    print(timestamps.get(widget.animeid + widget.epnumber));

    Wakelock.enable();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: []);
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);

    if (Platform.isAndroid || Platform.isIOS) {
      mobileSetup();
    } else {
      desktopSetup();
    }
    print("TEst");
  }

  void desktopSetup() {
    player = Player(id: 42069);
    setSourceDesktop();
  }

  void mobileSetup() {
    betterPlayerConfiguration = BetterPlayerConfiguration(
      //fullScreenByDefault: true,
      startAt: seekto(),
      fit: BoxFit.contain,
      deviceOrientationsAfterFullScreen: [
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight
      ],
      deviceOrientationsOnFullScreen: [
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight
      ],
      controlsConfiguration: BetterPlayerControlsConfiguration(
        enablePip: true,
        enableFullscreen: false,
        enablePlaybackSpeed: false,
        enableSubtitles: false,
        enableQualities: false,
        enableAudioTracks: false,
        controlsHideTime: Duration(seconds: 5),
        overflowMenuCustomItems: [
          BetterPlayerOverflowMenuItem(
              Icons.picture_in_picture,
              "Picture In Picture",
              () => videoManager.enablePictureInPicture(betterPlayerKey)),
          BetterPlayerOverflowMenuItem(
              Icons.cancel, "Quit", () => quitplayer()),
        ],
      ),
    );
    setSourceMobile();
  }

  void setSourceDesktop() async {
    if (widget.isNetwork) {
      String link = await getData_Video_web();
      setState(() {
        sourceDesktop = Media.network(link);
      });
    } else {
      setState(() {
        sourceDesktop =
            Media.file(File(widget.RawDataSource), startTime: seekto());
      });
    }
  }

  void setSourceMobile() async {
    if (widget.isNetwork) {
      String link = await getData_Video_web();
      setState(() {
        sourceMobile =
            BetterPlayerDataSource(BetterPlayerDataSourceType.network, link);
      });
    } else {
      setState(() {
        sourceMobile = BetterPlayerDataSource(
            BetterPlayerDataSourceType.file, widget.RawDataSource);
      });
    }
  }

  Future<String> getData_Video_web() async {
    Uri uri = Uri.parse("https://www.animeworld.tv/api/episode/info?alt=0&id=" +
        widget.RawDataSource);
    var response = await http.get(uri);
    String link;
    if (Platform.isWindows){
      link = json
          .decode(response.body)['grabber']
          .replaceAll("https", "http"); //TODO http for now cuz VLC on windows dosent like TLS

    }else{
      link = json
          .decode(response.body)['grabber']
          .replaceAll("http", "https")
          .replaceAll("httpss", "https");
    }
     return link;
  }

  @override
  void dispose() {
    Wakelock.disable();
    videoManager.dispose();
    super.dispose();
  }

  Duration seekto() {
    var lasttimestamp = timestamps.get(widget.animeid + widget.epnumber);
    print(lasttimestamp);
    if (lasttimestamp != null) {
      return Duration(seconds: lasttimestamp["timestamp"]);
    } else {
      return Duration(seconds: 0);
    }
  }

  void savetemp() {
    Duration position;
    Duration duration;
    if (Platform.isIOS || Platform.isAndroid) {
      position = videoManager.videoPlayerController.value.position;
      duration = videoManager.videoPlayerController.value.duration;
    } else {
      position = player.position.position;
      duration = player.position.duration;
    }
    timestamps.put(widget.animeid + widget.epnumber,
        {"duration": duration.inSeconds, "timestamp": position.inSeconds});
    print(timestamps.get(widget.animeid + widget.epnumber));
    widget.refreshinfo();
  }

  void quitplayer() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
        overlays: SystemUiOverlay.values);
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    Wakelock.disable();
    if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      WindowManager.instance.setFullScreen(false);
      player.dispose();
    }
    Navigator.pop(context);
  }

  Widget play_video() {
    if (sourceDesktop != null || sourceMobile != null) {
      GlobalKey _betterPlayerKey;
      if (Platform.isIOS || Platform.isAndroid) {
        videoManager = BetterPlayerController(betterPlayerConfiguration,
            betterPlayerDataSource: sourceMobile);
        videoManager.play();
        _betterPlayerKey = GlobalKey();
        videoManager.addEventsListener((p0) => savetemp());
        videoManager.addEventsListener((p0) =>
            SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
                overlays: []));
      } else {
        player.open(sourceDesktop, autoStart: true);
        player.play();
        player.positionStream.listen((PositionState state) {
          savetemp();
          SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
              overlays: []);
        });
      }

      return Scaffold(
          backgroundColor: Colors.black,
          body: WillPopScope(
              child: getVideoPlayerPlatform(_betterPlayerKey),
              onWillPop: () {
                quitplayer();
              }));
    } else {
      return Container();
    }
  }

  Widget getVideoPlayerPlatform(
      GlobalKey<State<StatefulWidget>> _betterPlayerKey) {
    if (Platform.isIOS || Platform.isAndroid) {
      return RotatedBox(
        quarterTurns: 0,
        child: Container(
          alignment: Alignment.center,
          child: AspectRatio(
            aspectRatio: 16 / 9,
            child:
                BetterPlayer(controller: videoManager, key: _betterPlayerKey),
          ),
        ),
      );
    } else {
      return Stack(children: [
        Container(
          alignment: Alignment.center,
          child: AspectRatio(
            aspectRatio: 16 / 9,
            child: Video(player: player),
          ),
        ),
        Positioned(
          right: 20,
          top: 10,
          child: GestureDetector(
            onTap: () {
              quitplayer();
            },
            child: Icon(
              Icons.cancel,
              size: 30,
              color: Colors.white38,
            ),
          ),
        ),
        Positioned(
          right: 65,
          top: 10,
          child: GestureDetector(
            onTap: () async {
              bool isfullscreen = await WindowManager.instance.isFullScreen();
              WindowManager.instance.setFullScreen(!isfullscreen);
            },
            child: Icon(
              Icons.fullscreen,
              size: 30,
              color: Colors.white38,
            ),
          ),
        ),
      ]);
    }
  }

  @override
  Widget build(BuildContext context) {
    return play_video();
  }
}
