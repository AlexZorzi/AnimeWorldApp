import 'package:flick_video_player/flick_video_player.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';
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
  Box<Map> timestamps;
  String cors = "https://cors-anywhere.herokuapp.com/";

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
          Uri.encodeFull(cors+"https://www.animeworld.tv/api/episode/info?alt=0&id="+widget.RawLink),headers: {"x-requested-with": "XMLHttpRequest"});

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

        return Scaffold(
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
      );
    }
    else{
      return Container(
        //stays here a few moments while loading the video
      );
    }
  }


  @override
  Widget build(BuildContext context) {
      return get_video();
   }

}