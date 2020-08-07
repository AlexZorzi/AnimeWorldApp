import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';

class homepageitem extends StatelessWidget {
  final dataHomepage;
  /*
  dataHomepage[0] Title
  dataHomepage[1] Link
  dataHomepage[2] Image Link
  dataHomepage[3] Episode Number
  */

  homepageitem({this.dataHomepage})
      : super(key: ObjectKey(dataHomepage));

  @override
  Widget build(BuildContext context) {
    String Title = dataHomepage[0];
    String Link = dataHomepage[0];
    String imageLink = dataHomepage[0];
    String episodeNumber = dataHomepage[0];
      return   AnimatedContainer(
        margin: EdgeInsets.fromLTRB(8, 4, 4, 4),
        duration: Duration(milliseconds: 300),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Text(Title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
            Text(
              Title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            Expanded(
              child: Align(
                alignment: Alignment.bottomLeft,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Row(children: <Widget>[
                      Icon(
                        Icons.photo,
                        size: 18,
                      ),
                      Text(' ' + episodeNumber + ' Page',
                          style: TextStyle(
                              fontSize: 12, fontWeight: FontWeight.w500)),
                    ]),
                    Padding(
                        padding: EdgeInsets.fromLTRB(0, 0, 4, 0),
                        child: Text("idk ", style: TextStyle(fontSize: 13))),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
  }
}
