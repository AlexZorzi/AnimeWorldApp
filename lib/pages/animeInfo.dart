import 'dart:convert';
import 'dart:io';
import 'dart:isolate';
import 'dart:ui';
import 'package:skeleton_text/skeleton_text.dart';
import 'package:flutter/material.dart';
import 'package:animeworldapp/functions/favoritemanager.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:flutter_rounded_progress_bar/rounded_progress_bar_style.dart';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import '../functions/html_parse.dart';
import '../widgets/EpisodeCard.dart';
import '../pages/videopage.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:hive/hive.dart';
import 'package:flutter_rounded_progress_bar/flutter_rounded_progress_bar.dart';

class AnimeInfo extends StatefulWidget {
  final String Link;
  final String Title;
  final String imageLink;


  const AnimeInfo({Key key, this.Title, this.Link, this.imageLink}) : super(key: key);

  @override
  _AnimeInfoState createState() => _AnimeInfoState();
}

class _AnimeInfoState extends State<AnimeInfo> {
  Box<Map> timestamps;
  String animeid;
  List dataInfo;
  String cors = "https://alexzorzi.it:8080/";

  @override
  void initState() {
    super.initState();
    getData_Info();

    timestamps = Hive.box<Map>("timestamps");
    animeid = widget.Link.split("/")[2].split(".")[0];
    const oneSecond = const Duration(seconds: 2);


  }

  Future<String> getData_Info() async {
      var response = await http.get(
          Uri.parse(cors+'https://www.animeworld.tv'+widget.Link));

      setState(() {
        dataInfo = Parsehtml_animeinfo(response.body);
      });
      return "Success";
  }

  Widget getData_Genres(){
    if(dataInfo == null){
      return SkeletonAnimation(
          child: Text("Loading...",style: Theme.of(context).textTheme.caption)
      );
    }
    else{
      String returnable = "";
      for(var gen in dataInfo[4]){
        returnable += gen;
        returnable += " ";
      }
      return Text(returnable,style: Theme.of(context).textTheme.caption);
    }
  }
  Widget getData_Desc(){
    if(dataInfo == null){
      return SkeletonAnimation(
          child: Text("Loading...",style: Theme.of(context).textTheme.caption)
      );
    }
    else{
      return Text(dataInfo[3],style: Theme.of(context).textTheme.caption);

    }
  }
  Widget getData_Status(){
    if(dataInfo == null){
      return SkeletonAnimation(
          child: Text("Loading...",style: Theme.of(context).textTheme.caption)
      );
    }
    else{
      return Text(dataInfo[2],style: Theme.of(context).textTheme.caption);
    }
  }
  Widget getData_Lenghteps(){
    if(dataInfo == null){
      return SkeletonAnimation(
          child: Text("Loading...",style: Theme.of(context).textTheme.caption)
      );
    }
    else{
      return Text(dataInfo[1],style: Theme.of(context).textTheme.caption);
    }
  }
  Widget getData_Rating(){
    if(dataInfo == null){
      return SkeletonAnimation(
          child: Text("Loading...",style: Theme.of(context).textTheme.caption)
      );
    }
    else{
      return Text(dataInfo[0],style: Theme.of(context).textTheme.caption);

    }
  }

  Widget getList_EpisodeList() {
    if (dataInfo == null) {
      return Container(
        child: Center(
          child: Icon(Icons.search, size: 50, color: Colors.black12,),
        ),
      );
    }

    List<EpisodeCard> cards = [];
    for(int index = 0; index < dataInfo[5][0].length; ++index){
      cards.add(EpisodeCard(episodeNumber: dataInfo[5][0][index][0], episodeLink: dataInfo[5][0][index][1], eparray: dataInfo[5], animeid: animeid,Link: widget.Link, Title: widget.Title, imageLink: widget.imageLink,));
    }
    return Column(
      children: cards,
    );
  }

  @override
  Widget build(BuildContext context) {

    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SingleChildScrollView(
                child: Column(
                  children: <Widget>[
                    Image(image: NetworkImage(cors+widget.imageLink),),
                    // using image cache here produces a flickering of the main image
                    // web branch *toast*
                    // idk why further research is needed.
                    SizedBox(
                      height: 11,
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 15.0),
                      child: Column(
                        children: <Widget>[
                          Text(
                            widget.Title,
                            style: Theme.of(context).textTheme.headline,
                          ),
                          SizedBox(
                            height: 7.0,
                          ),
                              Container(child: getData_Genres()),
                          SizedBox(height: 9.0),
                          SizedBox(height: 13.0),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Column(
                                children: <Widget>[
                                  Text(
                                    "Status",
                                    style: Theme.of(context).textTheme.caption,
                                  ),
                                  Container(
                                    child: getData_Status(),
                                  ),
                                ],
                              ),
                              Column(
                                children: <Widget>[
                                  Text(
                                    "Rating",
                                    style: Theme.of(context).textTheme.caption,
                                  ),
                                  getData_Rating(),
                                ],
                              ),
                              Column(
                                children: <Widget>[
                                  Text(
                                    "Length",
                                    style: Theme.of(context).textTheme.caption,
                                  ),
                                  getData_Lenghteps(),
                                ],
                              ),
                            ],
                          ),
                          SizedBox(height: 13.0),
                          SizedBox(height: 13.0),
                           getList_EpisodeList(),
                        ],
                      ),
                    ),
                    // MyScreenshots(),
                    SizedBox(height: 13.0),

                  ],
                ),
              )
        ,)
      ,);
  }






}