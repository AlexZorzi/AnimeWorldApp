import 'package:flutter/material.dart';
import '../pages/animeInfo.dart';
import '../functions/favoritemanager.dart';
import '../main.dart';
class FavoriteCard extends StatelessWidget {
  FavoriteCard({Key key, this.imageLink, this.Link, this.Title, this.favorites}) : super(key: key);

  final imageLink;
  final Link;
  final Title;
  final favorites;


  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 5,
      child: InkWell(
        splashColor: Colors.indigoAccent,
        onTap: () {Navigator.push(context,MaterialPageRoute(builder: (context) => AnimeInfo(Title: Title, Link: Link,imageLink: imageLink),),);},
        onLongPress: () {FavManager(Link, imageLink, Title, favorites); change();},
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
                              Image(
                                image: NetworkImage(imageLink),
                                width: 150,),
                              SizedBox(
                                height: 10,
                              ),
                              Flexible(
                                child: new Container(
                                  margin: EdgeInsets.only(
                                      left: 15, bottom: 150),
                                  child: new Text(
                                    Title,
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