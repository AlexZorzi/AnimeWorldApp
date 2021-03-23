import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:animeworldapp/functions/favoritemanager.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:flutter_rounded_progress_bar/flutter_rounded_progress_bar.dart';
import 'package:flutter_rounded_progress_bar/rounded_progress_bar_style.dart';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import '../functions/html_parse.dart';
import '../widgets/EpisodeCard.dart';
import '../pages/videopage.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:hive/hive.dart';

class AnimeDownloadDisplay extends StatefulWidget {
  final String Link;
  final String Title;
  final String imageLink;
  final Function refreshmain;

  const AnimeDownloadDisplay({Key key, this.Title, this.Link, this.imageLink, this.refreshmain}) : super(key: key);

  @override
  _AnimeDownloadDisplayState createState() => _AnimeDownloadDisplayState();
}

class _AnimeDownloadDisplayState extends State<AnimeDownloadDisplay> {
  Box<Map> animedownload;
  Box<Map> timestamps;
  String animeid;
  List dataInfo;

  @override
  void initState() {
    super.initState();
    getData_Info();
    animedownload = Hive.box<Map>("animedownload");
    timestamps = Hive.box<Map>("timestamps");
    animeid = widget.Link.split("/")[2].split(".")[0];


  }

  Future<String> getData_Info() async {
    var response = await http.get(
        Uri.parse('https://www.animeworld.tv'+widget.Link));

    setState(() {
      dataInfo = Parsehtml_animeinfo(response.body);
    });
    return "Success";
  }

  String getData_Genres(){
    if(dataInfo == null){
      return "Loading";
    }
    else{
      String returnable = "";
      for(var gen in dataInfo[4]){
        returnable += gen;
        returnable += " ";
      }
      return returnable;
    }
  }
  String getData_Desc(){
    if(dataInfo == null){
      return "Loading";
    }
    else{
      return dataInfo[3];
    }
  }
  String getData_Status(){
    if(dataInfo == null){
      return "Loading";
    }
    else{
      return dataInfo[2];
    }
  }
  String getData_Lenghteps(){
    if(dataInfo == null){
      return "Loading";
    }
    else{
      return dataInfo[1];
    }
  }
  String getData_Rating(){
    if(dataInfo == null){
      return "Loading";
    }
    else{
      return dataInfo[0];
    }
  }

  Widget getList_EpisodeList() {
    var animedata = animedownload.get(animeid);
    if (animedata == null) {
      return Container(
        child: Center(
          child: Icon(Icons.cloud_download, size: 50, color: Colors.black12,),
        ),
      );
    }

    var keys = animedata["episodes"].keys.toList();
    List<int> sortedkeys = [];
    for(var key in keys){
      sortedkeys.add(int.parse(key));
    }
    sortedkeys.sort();

    return ListView.separated(
      itemCount: animedata["episodes"].length,
      itemBuilder: (BuildContext context, int index) {

        return EpisodeCard(episodeNumber: sortedkeys[index].toString(),episodeLink: "",eparray: [],animeid: animeid,Link: widget.Link,imageLink: widget.imageLink,Title: widget.Title,callback: update,);
      },
      separatorBuilder: (context, index) {
        return Divider();
      },
    );
  }

  void update(){
    setState(() {
      widget.refreshmain();
      print("update");
    });
  }
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              Image(image: NetworkImage(widget.imageLink),),
              // using image cache here produces a flickering of the main image
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
                    Text(getData_Genres(),style: Theme.of(context).textTheme.caption,),
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
                            Text(
                              getData_Status(),
                              style: Theme.of(context).textTheme.subhead,
                            ),
                          ],
                        ),
                        Column(
                          children: <Widget>[
                            Text(
                              "Rating",
                              style: Theme.of(context).textTheme.caption,
                            ),
                            Text(
                              getData_Rating(),
                              style: Theme.of(context).textTheme.subhead,
                            ),
                          ],
                        ),
                        Column(
                          children: <Widget>[
                            Text(
                              "Length",
                              style: Theme.of(context).textTheme.caption,
                            ),
                            Text(
                              getData_Lenghteps(),
                              style: Theme.of(context).textTheme.subhead,
                            ),
                          ],
                        ),
                      ],
                    ),
                    SizedBox(height: 13.0),
                    SizedBox(height: 13.0),
                    Row(
                      children: <Widget>[
                        Expanded(
                          child: SizedBox(
                            height: 300,
                            child: getList_EpisodeList(),
                          ),
                        ),
                      ],
                    ),
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