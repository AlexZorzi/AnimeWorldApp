import 'package:flutter/material.dart';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../functions/html_parse.dart';
import '../widgets/EpisodeCard.dart';

class AnimeInfo extends StatefulWidget {
  final String Link;
  final String Title;
  final String imageLink;
  const AnimeInfo({Key key, this.Title, this.Link, this.imageLink}) : super(key: key);

  @override
  _AnimeInfoState createState() => _AnimeInfoState();
}

class _AnimeInfoState extends State<AnimeInfo> {


  List dataInfo;

  @override
  void initState() {
    super.initState();
    getData_Info();
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
        return EpisodeCard(episodeNumber: dataInfo[5][0][index][0], episodeLink: dataInfo[5][0][index][1],eparray: dataInfo[5],);
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
                          RichText(
                            text: TextSpan(
                              children: List.generate(
                                2,
                                    (i) {
                                  return TextSpan(
                                      text: getData_Genres());
                                },
                              ),
                              style: Theme.of(context).textTheme.caption,
                            ),
                          ),
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
}