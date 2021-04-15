import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:isolate';
import 'dart:ui';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:animeworldapp/pages/videopage.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:flutter_rounded_progress_bar/flutter_rounded_progress_bar.dart';
import 'package:flutter_rounded_progress_bar/rounded_progress_bar_style.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:animeworldapp/functions/favoritemanager.dart';
import 'package:circular_custom_loader/circular_custom_loader.dart';



class EpisodeCard extends StatefulWidget{
  EpisodeCard({Key key, this.episodeNumber, this.episodeLink, this.eparray, this.animeid, this.Link, this.imageLink, this.Title, this.callback}) : super(key: key);

  final String episodeNumber;
  final String episodeLink;
  final List eparray;
  final String animeid;
  final String Link;
  final String imageLink;
  final String Title;
  final Function callback;
  @override
  _EpisodeCardState createState() => _EpisodeCardState();

}

class _EpisodeCardState extends State<EpisodeCard> {
  var progress;
  Box<Map> timestamps;
  String cors = "https://alexzorzi.it:8080/";


  var videosource;
  @override
  void initState(){
    super.initState();
    timestamps = Hive.box<Map>("timestamps");
    getProgress();
    videosource = widget.episodeLink;
  }

  @override
  void dispose() {
    super.dispose();
  }

  Widget getProgress(){
    var timedata = timestamps.get(widget.animeid+widget.episodeNumber);
    double percentage;
    if(timedata != null){
      percentage = (timedata["timestamp"] / timedata["duration"] * 100);
      setState(() {
        progress = Expanded(
          child:  RoundedProgressBar(
            height: 3.5,
            style: RoundedProgressBarStyle(
                borderWidth: 0,
                widthShadow: 0),
            borderRadius: BorderRadius.circular(24),
            percent: percentage,
          ),
        );
      });

    }else{
      setState(() {
        progress = Container();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 5,
      child: InkWell(
        splashColor: Colors.indigoAccent,
        onTap: () {Navigator.push(context,MaterialPageRoute(builder: (context) => LandscapePlayer(RawLink: videosource, epnumber: widget.episodeNumber, animeid: widget.animeid,refreshinfo: (){setState(() {getProgress();});},),),);},
          child: Padding(
          padding: EdgeInsets.all(7),
          child: Stack(children: <Widget>[
            Align(
              alignment: Alignment.centerRight,
              child: Stack(
                children: <Widget>[
                  Padding(
                      padding: const EdgeInsets.only(left: 10, top: 5),
                      child: Column(
                        children: <Widget>[
                          Row(
                            children: <Widget>[
                              SizedBox(
                                height: 10,
                              ),
                              Flexible(
                                child: new Container(
                                  margin: EdgeInsets.only(
                                      left: 15, bottom: 15),
                                  child: Row(
                                    children: <Widget>[
                                      new Text(
                                        "Episodio "+widget.episodeNumber,
                                        overflow: TextOverflow.clip,
                                        style: new TextStyle(
                                          fontSize: 18.0,
                                          fontFamily: 'Roboto',
                                          color: new Color(0xFF212121),
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      SizedBox(
                                        width: 190,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Row(
                            children: <Widget>[
                              progress,
                            ],
                          ),

                        ],
                      )
                  )
                ],
              ),
            )
          ]),
        ),
      ),
    );
  }


  Future<String> getData_Video(RawLink) async {
    var response = await http.get(

        Uri.parse(cors+Uri.encodeComponent("https://www.animeworld.tv/api/episode/info?alt=0&id="+RawLink)));
    var Link = json.decode(response.body)['grabber'].replaceAll("http", "https").replaceAll("httpss", "https");
    print(Link);
    return Link;
  }
}