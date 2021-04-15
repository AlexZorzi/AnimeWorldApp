import 'package:flick_video_player/flick_video_player.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';
import 'dart:io' show Platform;
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'landscape_player_controls.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:hive/hive.dart';
import 'package:flutter/services.dart';


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
  FlickManager flickManager;
  var Link;
  int Seeked;
  int videoRotation;
  Box<Map> timestamps;
  String cors = "https://alexzorzi.it/pwa_api/mirror.php?url=";

  @override
  void initState() {
    super.initState();
    Seeked = 0;
    timestamps = Hive.box<Map>("timestamps");
    print(timestamps.get(widget.animeid+widget.epnumber));
    getData_Video_web();

  }

  Future<String> getData_Video_web() async {
      var response = await http.get(
          Uri.parse(cors+Uri.encodeComponent("https://www.animeworld.tv/api/episode/info?alt=0&id="+widget.RawLink)));

      setState(() {
        Link = json.decode(response.body)['grabber'].replaceAll("http", "https").replaceAll("httpss", "https");
        print(Link);
      });
  }
 
  @override
  void dispose() {
    flickManager.dispose();
    super.dispose();
  }

  Future<void> seekto(){
    if(flickManager.flickVideoManager.isPlaying && Seeked != 1){
      Seeked = 1;
      var lasttimestamp = timestamps.get(widget.animeid+widget.epnumber);
      print(lasttimestamp);
      if(lasttimestamp != null){
         flickManager.flickControlManager.seekTo(Duration(seconds: lasttimestamp["timestamp"]));
      }
    }
  }
  void savetemp(Duration timestamp,Duration durationvideo){
    if(Seeked != 0){
      timestamps.put(widget.animeid+widget.epnumber,{"duration":durationvideo.inSeconds,"timestamp":timestamp.inSeconds});
      print(timestamps.get(widget.animeid+widget.epnumber));
      widget.refreshinfo();
    }
  }

  Widget get_video(){
    if(Link != null){
          flickManager = FlickManager(
            videoPlayerController:
            VideoPlayerController.network(Link),
          );
        flickManager.flickControlManager.addListener(() {seekto();});
        flickManager.flickVideoManager.addListener(() {savetemp(flickManager.flickVideoManager.videoPlayerValue.position,flickManager.flickVideoManager.videoPlayerValue.duration);});

        return RotatedBox(
          quarterTurns: videoRotation,
          child: Scaffold(
          backgroundColor: Colors.black,
          body: WillPopScope(child:
          Container(
            alignment: Alignment.center,
            child: AspectRatio(
              aspectRatio: 16/9,
              child: FlickVideoPlayer(
                flickManager: flickManager,
                preferredDeviceOrientation: [
                  DeviceOrientation.landscapeRight,
                  DeviceOrientation.landscapeLeft
                ],
                systemUIOverlay: [],
                flickVideoWithControls: FlickVideoWithControls(
                  controls: LandscapePlayerControls(),

                ),
              ),
            ),
          ), onWillPop: (){
            SystemChrome.setEnabledSystemUIOverlays(SystemUiOverlay.values);
            SystemChrome.setPreferredOrientations(
                [DeviceOrientation.portraitUp]);
            Navigator.pop(context);
          })
      ),
        );
    }
    else{
      return Container(
        //stays here a few moments while loading the video
      );
    }
  }

  void checkRotation(context){
    // Function Used to set the player rotation, 1  for phones and 0 for web
    // value expressed in quarters
    if(MediaQuery.of(context).size.width < MediaQuery.of(context).size.height){
        videoRotation = 1;
      }else{
        videoRotation = 0;
      }
  }

  @override
  Widget build(BuildContext context) {
    setState(() {
      checkRotation(context);
    });
    return get_video();
   }

}