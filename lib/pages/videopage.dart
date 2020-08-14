import 'package:flick_video_player/flick_video_player.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'landscape_player_controls.dart';

class LandscapePlayer extends StatefulWidget {
  LandscapePlayer({Key key, this.RawLink}) : super(key: key);

  final String RawLink;

  @override
  _LandscapePlayerState createState() => _LandscapePlayerState();
}

class _LandscapePlayerState extends State<LandscapePlayer> {
  FlickManager flickManager;
  String Link;

  @override
  void initState() {
    super.initState();
    getData_Video();}

  Future<String> getData_Video() async {
      var response = await http.get(
          Uri.encodeFull("https://www.animeworld.tv/api/episode/info?alt=0&id="+widget.RawLink),headers: {"x-requested-with": "XMLHttpRequest"});

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

  Widget get_video(){
    if(Link != null){
    flickManager = FlickManager(
      videoPlayerController:
      VideoPlayerController.network(Link),
    );
      return Scaffold(
        backgroundColor: Colors.black,
        body: Container(
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
        ),
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