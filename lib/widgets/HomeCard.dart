import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import '../pages/animeInfo.dart';
import '../functions/favoritemanager.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
class homepageitem extends StatefulWidget {
  final dataHomepage;
  final Box<Map> favorites;

  /*
  dataHomepage[0] Title
  dataHomepage[1] Link
  dataHomepage[2] Image Link
  dataHomepage[3] Episode Number
  */

  homepageitem({this.dataHomepage,this.favorites})
      : super(key: ObjectKey(dataHomepage));

  @override
  _homepageitemState createState() => _homepageitemState();
}

class _homepageitemState extends State<homepageitem> {
  String Title;
  String Link;
  String animeid;
  String imageLink;
  var favorites;
  var hearticon;

  @override
  void initState(){
    super.initState();
    favorites = Hive.box<Map>("favorites");
     Title = widget.dataHomepage[0];
     Link = widget.dataHomepage[1];
     animeid = Link.split("/")[2].split(".")[0];
     imageLink = widget.dataHomepage[2];
    animeid = Link.split("/")[2].split(".")[0];
    isfavorite();
  }

  Widget isfavorite(){
    if(favorites.get(animeid) == null){
      setState(() {
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

    return GestureDetector(
      onTap: () {Navigator.push(context,MaterialPageRoute(builder: (context) => AnimeInfo(Title: Title,Link: Link,imageLink: imageLink,)));},
      onLongPress: () {FavManager(Link, imageLink, Title, widget.favorites); print(imageLink); isfavorite();},
      child: Container(
        width: MediaQuery.of(context).size.width / 2.5,
        margin: EdgeInsets.only(right: 15,left: 15),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15.0),
        ),
        child: Stack(
          children: <Widget>[
            Positioned.fill(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(15.0),
                child: CachedNetworkImage(imageUrl: imageLink, fit: BoxFit.cover),

               ),
            ),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: EdgeInsets.all(15.0),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(15),
                    bottomRight: Radius.circular(15),
                  ),
                  color: Colors.black45,
                ),
                child:Column(
                  children: [
                    Text(
                          Title,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                          ),
                          softWrap: true,
                          maxLines: 2,
                          overflow: TextOverflow.clip,
                        ),
                    hearticon,
                  ],
                ),

              ),
            ),
            //Text("test"),
          ],
        ),
      ),
    );
  }
}
