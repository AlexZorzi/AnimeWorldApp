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
  var downloadprogress;
  Box<Map> timestamps;
  Box<Map> animedownload;
  Box<String> downloadworks;

  var localPathtry;
  var downloadstatus;
  var doiexistWid;
  var videosource;
  var workid;
  var existsbool;
  var mytimer;
  @override
  void initState(){
    super.initState();
    downloadprogress = 0;
    timestamps = Hive.box<Map>("timestamps");
    animedownload = Hive.box<Map>("animedownload");
    downloadworks = Hive.box<String>("downloadworks");
    workid = downloadworks.get(widget.animeid+widget.episodeNumber);
    print(workid);
    doiexist();
    getProgress();
    const oneSecond = const Duration(seconds: 2);
    mytimer = Timer.periodic(oneSecond, (Timer t) => setState((){
      if(workid != null){
        FlutterDownloader.loadTasksWithRawQuery(query: "SELECT * FROM task WHERE task_id = '${workid}'").then((value) => {
          downloadprogress = value[0].progress
        });
        FlutterDownloader.loadTasksWithRawQuery(query: "SELECT * FROM task WHERE task_id = '${workid}'").then((value) => {
          downloadstatus = value[0].status
        });
      }
    }));
  }


  Widget getDownloadprogress(){
    print(downloadstatus);
    if(downloadstatus != null && downloadstatus == DownloadTaskStatus.running){
      return  Row(
        children: <Widget>[
        Divider(),
      Expanded(
      child:  RoundedProgressBar(
        height: 3.5,
        style: RoundedProgressBarStyle(
            colorProgress: Colors.orangeAccent,
            backgroundProgress: Colors.yellow[100],
            borderWidth: 0,
            widthShadow: 0
        ),
        borderRadius: BorderRadius.circular(24),
        percent: downloadprogress.toDouble(),
      ),
    ),
        ],
      );
    }
    else{
      return Container();
    }
  }


  @override
  void dispose() {
    mytimer.cancel();
    super.dispose();
  }

  Future<void> doiexist() async{
    localPathtry = (await _findLocalPath()) + Platform.pathSeparator + 'Download' + Platform.pathSeparator + widget.animeid;
    print(widget.episodeNumber);
    print(localPathtry+"/"+widget.episodeNumber+widget.animeid+".mp4");
    if(!File(localPathtry+"/"+widget.episodeNumber+widget.animeid+".mp4").existsSync()){
      setState(() {
        videosource = widget.episodeLink;
        doiexistWid = InkWell(
          child: Icon(Icons.file_download),
          onTap: (){pathrequest(widget.episodeLink, widget.Link.split("/")[2].split(".")[0], widget.episodeNumber);},
        );
      });
    }
    else{
      setState(() {
        videosource = File(localPathtry+"/"+widget.episodeNumber+widget.animeid+".mp4");
        doiexistWid = InkWell(
          child: Icon(Icons.delete_forever),
          onTap: (){deleterequest(widget.animeid,widget.episodeNumber);},
        );
      });
    }

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
                                      Container(
                                        height: 30,
                                        width: 30,
                                        child: doiexistWid,
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

                          getDownloadprogress(),

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
        Uri.parse("https://www.animeworld.tv/api/episode/info_new?alt=0&id="+RawLink),headers: {"x-requested-with": "XMLHttpRequest","user-agent":"Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/89.0.4389.90 Safari/537.36"});
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
        fileName: epnumber+widget.animeid+".mp4",
        savedDir: localPath,
        showNotification: true,
        openFileFromNotification: false).then((workidd) => {
          downloadworks.put(widget.animeid+widget.episodeNumber, workidd)
    });
    setState(() {
      workid = downloadworks.get(widget.animeid+widget.episodeNumber);
      videosource = File(localPathtry+"/"+widget.episodeNumber+widget.animeid+".mp4");
      doiexistWid = InkWell(
        child: Icon(Icons.delete_forever),
        onTap: (){deleterequest(widget.animeid,widget.episodeNumber);},
      );
    });
  }

  void deleterequest(animelink,epnumber) async {
    String localPath = (await _findLocalPath()) + Platform.pathSeparator + 'Download' + Platform.pathSeparator + animelink;
    new Directory(localPath).create(recursive: true)
    // The created directory is returned as a Future.
        .then((Directory directory) {
    });
    print(workid);
    setState(() {
      FlutterDownloader.cancel(taskId: workid);
      File(localPath+"/"+epnumber+".mp4").delete();
      setState(() {
        workid = null;
        downloadstatus = DownloadTaskStatus.canceled;
        doiexistWid = InkWell(
          child: Icon(Icons.file_download),
          onTap: (){pathrequest(widget.episodeLink, widget.Link.split("/")[2].split(".")[0], widget.episodeNumber);},
        );
      });
      DownloadManager(widget.Link, widget.imageLink, widget.Title, animedownload, epnumber, localPath+"/"+epnumber+".mp4");
      try{
        widget.callback();
      }
      catch(e){}
    });
  }
  void DownloadManager(String link, String imageLink, String title, Box<Map> hivebox, String epnumber, String eplink){
    var animeid = link.split("/")[2].split(".")[0];
    var animelink = "/play/"+link.split("/")[2];

    if(hivebox.get(animeid) == null){
      hivebox.put(animeid,
          {
            'link' : animelink,
            'title': title,
            'imageLink': imageLink,
            'episodes' : {epnumber: eplink}
          }
      );
      print(title+" Added (downloadmanager)");
    }
    else if(!hivebox.get(animeid)["episodes"].containsKey(epnumber)){
      var episodes = hivebox.get(animeid)["episodes"];
      episodes[epnumber] = eplink;
      hivebox.put(animeid,
          {
            'link' : animelink,
            'title': title,
            'imageLink': imageLink,
            'episodes' : episodes
          }
      );

      print(title+" Added (downloadmanager)");

    }
    else if(hivebox.get(animeid)["episodes"].containsKey(epnumber)){
      var episodes = hivebox.get(animeid)["episodes"];
      episodes.remove(epnumber);
      hivebox.put(animeid,
          {
            'link' : animelink,
            'title': title,
            'imageLink': imageLink,
            'episodes' : episodes
          }
      );
      print(hivebox.get(animeid)["episodes"].values.length == 0);
      if(hivebox.get(animeid)["episodes"].values.length == 0){hivebox.delete(animeid);}
      print(title+" Deleted (downloadmanager)");

    }
    else{
      print(title+" IDK ERROR(?)");

    }
    print(hivebox.values);
  }


}