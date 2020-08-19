import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_app/functions/favoritemanager.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
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

  const AnimeDownloadDisplay({Key key, this.Title, this.Link, this.imageLink}) : super(key: key);

  @override
  _AnimeDownloadDisplayState createState() => _AnimeDownloadDisplayState();
}

class _AnimeDownloadDisplayState extends State<AnimeDownloadDisplay> {
  Box<Map> animedownload;
  List dataInfo;

  @override
  void initState() {
    super.initState();
    getData_Info();
    animedownload = Hive.box<Map>("animedownload");
    print(animedownload.values);

  }

  Future<String> getData_Info() async {
    var response = await http.get(
        Uri.encodeFull('https://www.animeworld.tv'+widget.Link));

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
    var animedata = animedownload.get("/play/"+widget.Link.split("/")[2]);
    if (animedata["episodes"] == null) {
      return Container(
        child: Center(
          child: Icon(Icons.cloud_download, size: 50, color: Colors.black12,),
        ),
      );
    }

    return ListView.separated(
      itemCount: animedata["episodes"].length,
      itemBuilder: (BuildContext context, int index) {
        var file = File(animedata["episodes"][(1+index).toString()]);
        print(file);
        return GetEpisodeCard((1+index).toString(), file);
      },
      separatorBuilder: (context, index) {
        return Divider();
      },
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
              Image(image: NetworkImage(widget.imageLink),),
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
                            height: 200,
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

  GetEpisodeCard(episodeNumber,episodeFile){
    return Card(
      elevation: 5,
      child: InkWell(
        splashColor: Colors.indigoAccent,
        onTap: () {Navigator.push(context,MaterialPageRoute(builder: (context) => LandscapePlayer(RawLink: episodeFile,),),);},
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
                                        "Episodio "+episodeNumber,
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
                                      Container(
                                        height: 30,
                                        width: 30,
                                        child: InkWell(
                                          child: Icon(Icons.file_download),
                                          onTap: (){},
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ))
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
        Uri.encodeFull("https://www.animeworld.tv/api/episode/info?alt=0&id="+RawLink),headers: {"x-requested-with": "XMLHttpRequest"});
    var Link = json.decode(response.body)['grabber'].replaceAll("http", "https").replaceAll("httpss", "https");
    print(Link);
    return Link;
  }
  Future<String> _findLocalPath() async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }
  void pathrequest(url,animelink,epnumber) async {
    String localPath = (await _findLocalPath()) + Platform.pathSeparator + 'Download' + Platform.pathSeparator + animelink;
    new Directory(localPath).create(recursive: true)
    // The created directory is returned as a Future.
        .then((Directory directory) {
    });
    await FlutterDownloader.enqueue(

        url: (await getData_Video(url)),
        savedDir: localPath,
        showNotification: true,
        openFileFromNotification: true);
  }

}