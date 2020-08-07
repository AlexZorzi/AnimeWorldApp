import 'package:flutter/material.dart';

class SearchCard extends StatelessWidget {
  SearchCard({Key key, this.dataSearch}) : super(key: key);

  final dataSearch;

  @override
  Widget build(BuildContext context) {
    var Title = dataSearch[0];
    var Link = dataSearch[1];
    var LinkImage = dataSearch[2];
    var Chips = dataSearch[3];

    return Card(
      elevation: 5,
      child: InkWell(
        splashColor: Colors.indigoAccent,
        onTap: () {},
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
                                image: NetworkImage(LinkImage),
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
                          Row(
                            children: Chips,
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