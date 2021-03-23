import 'package:flutter/material.dart';
import 'package:animeworldapp/functions/favoritemanager.dart';
import '../pages/animeInfo.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:hive/hive.dart';
import '../functions/favoritemanager.dart';

class SearchCard extends StatefulWidget {
  SearchCard({Key key, this.dataSearch}) : super(key: key);
  final dataSearch;

  @override
  State<StatefulWidget> createState() => _SearchCardState();


}
class _SearchCardState extends State<SearchCard>{
  var Title;
  var Link;
  var imageLink;
  var Chips;
  var animeid;
  var hearticon;
  Box<Map> favorites;
  @override
  void initState(){
    super.initState();
    favorites = Hive.box<Map>("favorites");
    Title = widget.dataSearch[0];
    Link = widget.dataSearch[1];
    imageLink = widget.dataSearch[2];
    Chips = widget.dataSearch[3];
    animeid = Link.split("/")[2].split(".")[0];
    isfavorite();
  }

 Widget isfavorite(){
    if(favorites.get(animeid) == null){
      setState(() {
        //hearticon = Container();
        hearticon = Icon(Icons.favorite_border, color: Colors.red,);
      });
    }else{
      setState(() {
        hearticon = Icon(Icons.favorite, color: Colors.red,);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 5,
      child: InkWell(
          splashColor: Colors.indigoAccent,
          onTap: () {Navigator.push(context,MaterialPageRoute(builder: (context) => AnimeInfo(Title: Title,Link: Link,imageLink: imageLink),),);},
        onLongPress: () {FavManager(Link, imageLink, Title, favorites); isfavorite();},
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
                              child: Row(
                                children: <Widget>[
                                   Expanded(
                                     child: Container(
                                      margin: EdgeInsets.only(
                                          left: 15, bottom: 150),
                                      child: Text(
                                        Title,
                                        overflow: TextOverflow.clip,
                                        style: TextStyle(
                                          fontSize: 18.0,
                                          fontFamily: 'Roboto',
                                          color: Color(0xFF212121),
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),

                                  ),
                                   ),
                                ],
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
                        Row(
                          children: Chips,
                        ),
                        Row(
                          children: <Widget>[
                            hearticon,
                          ],
                        )
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