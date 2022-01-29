import 'package:better_player/better_player.dart';
import 'package:wakelock/wakelock.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:animeworldapp/globals/globals.dart' as globals;
import 'dart:convert';
import 'package:hive/hive.dart';


class LandscapePlayer extends StatefulWidget {
  bool isNetwork;
  final Function refreshinfo;
  final String RawDataSource;
  final epnumber;
  final animeid;

  LandscapePlayer({Key key, this.RawDataSource, this.isNetwork, this.epnumber, this.animeid, this.refreshinfo}) : super(key: key);


  @override
  _LandscapePlayerState createState() => _LandscapePlayerState();
}

class _LandscapePlayerState extends State<LandscapePlayer> {
  BetterPlayerController videoManager;
  var Link;
  Box<Map> timestamps;
  var betterPlayerConfiguration;
  BetterPlayerDataSource source;
  GlobalKey betterPlayerKey;

  @override
  void initState() {
    super.initState();
    timestamps = Hive.box<Map>("timestamps");
    print(timestamps.get(widget.animeid+widget.epnumber));

    setSource();
    Wakelock.enable();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: []);
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);

    betterPlayerConfiguration = BetterPlayerConfiguration(
      //fullScreenByDefault: true,
      startAt: seekto(),
      fit: BoxFit.contain,
      deviceOrientationsAfterFullScreen: [DeviceOrientation.landscapeLeft, DeviceOrientation.landscapeRight],
      deviceOrientationsOnFullScreen: [DeviceOrientation.landscapeLeft, DeviceOrientation.landscapeRight],
      controlsConfiguration: BetterPlayerControlsConfiguration(
        enablePip: true,
        enableFullscreen: false,
        enablePlaybackSpeed: false,
        enableSubtitles: false,
        enableQualities: false,
        enableAudioTracks:false,
        controlsHideTime: Duration(seconds: 5),
        overflowMenuCustomItems: [
            BetterPlayerOverflowMenuItem(
            Icons.picture_in_picture,
            "Picture In Picture",
                () => videoManager.enablePictureInPicture(betterPlayerKey)),
          BetterPlayerOverflowMenuItem(
              Icons.cancel,
              "Quit",
                  () => quitplayer()),
          ],
      ),
    );


  }

  void setSource() {
    if(widget.isNetwork){
      getData_Video_web();
    }else{
      setState(() {
        source = BetterPlayerDataSource(BetterPlayerDataSourceType.file, widget.RawDataSource );
      });
    }
  }

  Future<String> getData_Video_web() async {
      var response = await http.get(
          Uri.parse("https://www.animeworld.tv/api/episode/info?alt=0&id="+widget.RawDataSource),headers: {"x-requested-with": "XMLHttpRequest","user-agent":"Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/89.0.4389.90 Safari/537.36"}..addAll(globals.AWCookieTest));
          String link = json.decode(response.body)['grabber'].replaceAll("http", "https").replaceAll("httpss", "https");
      setState(() {
        source = BetterPlayerDataSource(BetterPlayerDataSourceType.network, link);
        print(Link);
      });
  }
 
  @override
  void dispose() {
    Wakelock.disable();
    videoManager.dispose();
    super.dispose();
  }

  Duration seekto(){
      var lasttimestamp = timestamps.get(widget.animeid+widget.epnumber);
      print(lasttimestamp);
      if(lasttimestamp != null){
         return Duration(seconds: lasttimestamp["timestamp"]);
      }else{
        return Duration(seconds: 0);
      }
  }
  void savetemp(){
      Duration position =  videoManager.videoPlayerController.value.position;
      Duration duration =  videoManager.videoPlayerController.value.duration;
      print("Duration "+duration.inSeconds.toString()+" Position "+position.inSeconds.toString());
      timestamps.put(widget.animeid+widget.epnumber,{"duration":duration.inSeconds,"timestamp":position.inSeconds});
      print(timestamps.get(widget.animeid+widget.epnumber));
      widget.refreshinfo();
  }

  void quitplayer(){
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: SystemUiOverlay.values);
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    Wakelock.disable();
    Navigator.pop(context);
  }

  Widget get_video() {
    if(source != null){
      videoManager = BetterPlayerController(betterPlayerConfiguration, betterPlayerDataSource: source);
      videoManager.play();
      GlobalKey _betterPlayerKey = GlobalKey();
      videoManager.addEventsListener((p0) => savetemp());
      videoManager.addEventsListener((p0) => SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: []));

        return Scaffold(
        backgroundColor: Colors.black,
        body: WillPopScope(child:
            RotatedBox(
              quarterTurns: 0,
              child:  Container(
                alignment: Alignment.center,
                child: AspectRatio(
                  aspectRatio: 16/9,
                  child: BetterPlayer(controller: videoManager, key: _betterPlayerKey),
                ),
              ),
            ),
            onWillPop: (){quitplayer();})
      );
    }
    else{
      return Container();
    }
  }


  @override
  Widget build(BuildContext context) {
      return get_video();
   }

}