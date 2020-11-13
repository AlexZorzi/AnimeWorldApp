import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import '../pages/animeInfo.dart';
import '../functions/favoritemanager.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:cache_image/cache_image.dart';
class homepageitem extends StatelessWidget {
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
  Widget build(BuildContext context) {
    String Title = dataHomepage[0];
    String Link = dataHomepage[1];
    String imageLink = dataHomepage[2];
    String episodeNumber = dataHomepage[3];
    return GestureDetector(
      onTap: () {Navigator.push(context,MaterialPageRoute(builder: (context) => AnimeInfo(Title: Title,Link: Link,imageLink: imageLink,)));},
      onLongPress: () {FavManager(Link, imageLink, Title, favorites); print(imageLink);},
      child: Container(
        width: MediaQuery.of(context).size.width / 2.5,
        margin: EdgeInsets.only(right: 15,left: 15),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15.0),
          boxShadow: [
            BoxShadow(
                blurRadius: 5.0, color: Colors.grey[400], offset: Offset(0, 3))
          ],
        ),
        child: Stack(
          children: <Widget>[
            Positioned.fill(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(15.0),
                child: Image(image: CacheImage(imageLink),fit: BoxFit.cover,)
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
                child: Text(
                  Title,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 23,
                  ),
                  softWrap: true,
                  maxLines: 2,
                  overflow: TextOverflow.clip,
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
