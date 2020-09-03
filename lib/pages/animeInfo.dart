import 'dart:convert';
import 'dart:io';
import 'package:skeleton_text/skeleton_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/functions/favoritemanager.dart';
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
import 'package:cache_image/cache_image.dart';

class AnimeInfo extends StatefulWidget {
  final String Link;
  final String Title;
  final String imageLink;


  const AnimeInfo({Key key, this.Title, this.Link, this.imageLink}) : super(key: key);

  @override
  _AnimeInfoState createState() => _AnimeInfoState();
}

class _AnimeInfoState extends State<AnimeInfo> {
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
          Uri.encodeFull('https://www.animeworld.tv'+widget.Link));

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

    return ListView.separated(
      itemCount: dataInfo[5][0]?.length,
      itemBuilder: (BuildContext context, int index) {
        return GetEpisodeCard(dataInfo[5][0][index][0], dataInfo[5][0][index][1], dataInfo[5],);
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
                    Image(image: CacheImage(widget.imageLink),),
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
                                  SkeletonAnimation(
                                    child: getData_Rating(),
                                  ),
                                ],
                              ),
                              Column(
                                children: <Widget>[
                                  Text(
                                    "Length",
                                    style: Theme.of(context).textTheme.caption,
                                  ),
                                  SkeletonAnimation(
                                    child: getData_Lenghteps(),
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
                                  child: Container(color: Colors.white,height: 1000,child: getList_EpisodeList()),
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



  GetEpisodeCard(episodeNumber,episodeLink, eparray){

    var timedata = timestamps.get(animeid+episodeNumber);
    double percentage;
    Widget progress;
    if(timedata != null){
      percentage = (timedata["timestamp"] / timedata["duration"] * 100);
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

    }else{
      progress = Container();
    }
    return Card(
      elevation: 5,
      child: InkWell(
        splashColor: Colors.indigoAccent,
        onTap: () {Navigator.push(context,MaterialPageRoute(builder: (context) => LandscapePlayer(RawLink: episodeLink, epnumber: episodeNumber, animeid: animeid,refreshinfo: (){setState(() {});},),),);},
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
                                          onTap: (){pathrequest(episodeLink, widget.Link.split("/")[2].split(".")[0], episodeNumber);},
                                        ),
                                      )
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
    DownloadManager(widget.Link, widget.imageLink, widget.Title, animedownload, epnumber, localPath+"/"+epnumber+".mp4");
    var test = await FlutterDownloader.enqueue(

        url: (await getData_Video(url)),
        fileName: epnumber+".mp4",
        savedDir: localPath,
        showNotification: true,
        openFileFromNotification: true);
    madonna();

  }
  Future<void> madonna()async{
    var tasks = await FlutterDownloader.loadTasks();
    print("MDA");
    print(tasks);
  }

}