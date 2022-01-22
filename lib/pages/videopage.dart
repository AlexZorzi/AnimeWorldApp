import 'package:better_player/better_player.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:animeworldapp/globals/globals.dart' as globals;
import 'dart:convert';
import 'package:hive/hive.dart';


class LandscapePlayer extends StatefulWidget {
  LandscapePlayer({Key key, this.RawLink, this.epnumber, this.animeid, this.refreshinfo}) : super(key: key);
  final Function refreshinfo;
  final RawLink;
  final epnumber;
  final animeid;

  @override
  _LandscapePlayerState createState() => _LandscapePlayerState();
}

class _LandscapePlayerState extends State<LandscapePlayer> {
  BetterPlayerController videoManager;
  var Link;
  int Seeked;
  Box<Map> timestamps;
  var betterPlayerConfiguration;

  @override
  void initState() {
    super.initState();
    betterPlayerConfiguration = BetterPlayerConfiguration(
      fullScreenByDefault: true,
      controlsConfiguration: BetterPlayerControlsConfiguration(
        enablePip: true,
        enableFullscreen: false,
      ),
    );

    Seeked = 0;
    timestamps = Hive.box<Map>("timestamps");
    print(timestamps.get(widget.animeid+widget.epnumber));
    if(widget.RawLink is String){
      getData_Video_web();
    }else{
      setState(() {
        Link = widget.RawLink;
      });
    }

  }

  Future<String> getData_Video_web() async {
      var response = await http.get(
          Uri.parse("https://www.animeworld.tv/api/episode/info?alt=0&id="+widget.RawLink),headers: {"x-requested-with": "XMLHttpRequest","user-agent":"Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/89.0.4389.90 Safari/537.36"}..addAll(globals.AWCookieTest));

      setState(() {
        Link = json.decode(response.body)['grabber'].replaceAll("http", "https").replaceAll("httpss", "https");
        print(Link);
      });
  }
 
  @override
  void dispose() {
    videoManager.dispose();
    super.dispose();
  }

  Duration seekto(){
    if(videoManager.isPlaying() && Seeked != 1 ){
      Seeked = 1;
      var lasttimestamp = timestamps.get(widget.animeid+widget.epnumber);
      print(lasttimestamp);
      if(lasttimestamp != null){
         return Duration(seconds: lasttimestamp["timestamp"]);
      }else{
        return Duration(seconds: 0);
      }
    }
  }
  void savetemp(){
    if(Seeked != 0){
      Duration position =  videoManager.videoPlayerController.value.position;
      Duration duration =  videoManager.videoPlayerController.value.duration;
      print("Duration "+duration.inSeconds.toString()+" Position "+position.inSeconds.toString());
      timestamps.put(widget.animeid+widget.epnumber,{"duration":duration.inSeconds,"timestamp":position.inSeconds});
      print(timestamps.get(widget.animeid+widget.epnumber));
      widget.refreshinfo();
    }
  }

  void quitplayer(){
    if (!videoManager.isFullScreen){
      //Navigator.pop(context);
    }
  }

  Widget get_video() {
    if(Link != null){
      BetterPlayerDataSource source;
      if(Link is String){
        source = BetterPlayerDataSource(BetterPlayerDataSourceType.network, Link);
        }else{
        source = BetterPlayerDataSource(BetterPlayerDataSourceType.file, Link);
        }
      videoManager = BetterPlayerController(betterPlayerConfiguration, betterPlayerDataSource: source);
      videoManager.enterFullScreen();
      videoManager.addEventsListener((p0) => seekto());
      videoManager.addEventsListener((p0) => quitplayer());
      videoManager.addEventsListener((p0) => savetemp());
      videoManager.play();
        return Scaffold(
        backgroundColor: Colors.black,
        body: WillPopScope(child:
        Container(
          alignment: Alignment.center,
          child: AspectRatio(
            aspectRatio: 16/9,
            child: BetterPlayer(controller: videoManager),
          ),
        ),
            onWillPop: (){
          SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: SystemUiOverlay.values);
          SystemChrome.setPreferredOrientations(
              [DeviceOrientation.portraitUp]);
          Navigator.pop(context);
        })
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