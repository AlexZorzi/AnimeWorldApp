import 'package:flutter/material.dart';
import 'package:animeworldapp/functions/favoritemanager.dart';
import '../pages/animeInfo.dart';
import '../main.dart';
class FavoriteCard extends StatefulWidget {
  FavoriteCard({Key key, this.imageLink, this.Link, this.Title, this.callback, this.favorites}) : super(key: key);

  final imageLink;
  final Link;
  final Title;
  final favorites;
  final Function callback;
  @override
  _FavoriteCardState createState() => _FavoriteCardState();

}
class _FavoriteCardState extends State<FavoriteCard>{
  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 5,
      child: InkWell(
        splashColor: Colors.indigoAccent,
        onTap: () {Navigator.push(context,MaterialPageRoute(builder: (context) => AnimeInfo(Title: widget.Title, Link: widget.Link,imageLink: widget.imageLink),),);},
        onLongPress: () {setState(() {
          widget.callback();
          FavManager(widget.Link, widget.imageLink, widget.Title, widget.favorites, );
        });},
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
                              Container(
                                child: Image(
                                  image: NetworkImage(widget.imageLink),
                                  width: 125,),
                              ),
                              SizedBox(
                                height: 10,
                              ),
                              Flexible(
                                child: new Container(
                                  margin: EdgeInsets.only(
                                      left: 15, bottom: 150),
                                  child: new Text(
                                    widget.Title,
                                    overflow: TextOverflow.clip,
                                    style: new TextStyle(
                                      fontSize: 18.0,
                                      fontFamily: 'Roboto',
                                      color: new Color(0xFF212121),
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),

                              SizedBox(
                                width: 10,
                              ),
                              SizedBox(
                                width: 20,
                              )
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

}