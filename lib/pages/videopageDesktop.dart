import 'dart:io';

import 'package:better_player/better_player.dart';
import 'package:dart_vlc/dart_vlc.dart';
import 'package:wakelock/wakelock.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:animeworldapp/globals/globals.dart' as globals;
import 'dart:convert';
import 'package:hive/hive.dart';


class LandscapePlayerDesktop extends StatefulWidget {
  bool isNetwork;
  final Function refreshinfo;
  final String RawDataSource;
  final epnumber;
  final animeid;

  LandscapePlayerDesktop({Key key, this.RawDataSource, this.isNetwork, this.epnumber, this.animeid, this.refreshinfo}) : super(key: key);


  @override
  _LandscapePlayerDesktopState createState() => _LandscapePlayerDesktopState();
}

class _LandscapePlayerDesktopState extends State<LandscapePlayerDesktop> {
  Player player;
  var Link;
  Box<Map> timestamps;
  var betterPlayerConfiguration;
  Media source;
  

  @override
  void initState() {
    super.initState();
    timestamps = Hive.box<Map>("timestamps");
    print(timestamps.get(widget.animeid+widget.epnumber));

    setSource();
    //Wakelock.enable();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: []);
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    player = Player(id: 42069);


  }

  void setSource() {
    if(widget.isNetwork){
      getData_Video_web();
    }else{
      setState(() {
        source = Media.file(
            File(widget.RawDataSource),
            startTime: seekto()
        );
      });
    }
  }

  Future<String> getData_Video_web() async {
      var response = await http.get(
          Uri.parse("https://www.animeworld.tv/api/episode/info?alt=0&id="+widget.RawDataSource),headers: {"x-requested-with": "XMLHttpRequest","user-agent":"Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/89.0.4389.90 Safari/537.36"}..addAll(globals.AWCookieTest));
          String link = json.decode(response.body)['grabber'].replaceAll("http", "https").replaceAll("httpss", "https");
      setState(() {
        source = Media.network(
          widget.RawDataSource,
          startTime: seekto()
        );
      });
  }
 
  @override
  void dispose() {
    Wakelock.disable();
    player.dispose();
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
      Duration position =  player.position.position;
      Duration duration =  player.position.duration;
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

  Widget play_video() {
    if(source != null){
      player.open(source, autoStart: true);
      player.play();
      player.positionStream.listen((PositionState state) {
        savetemp();
        SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: []);
      });

        return Scaffold(
        backgroundColor: Colors.black,
        body: WillPopScope(child:
            RotatedBox(
              quarterTurns: 0,
              child:  Container(
                alignment: Alignment.center,
                child: AspectRatio(
                  aspectRatio: 16/9,
                  child: Video(player: player),
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
      return play_video();
   }

}