import 'package:flutter/material.dart';
import 'package:html/parser.dart' show parse;


List Parsehtml(html_search_api){
  final htmldoc = parse(html_search_api);
  var divs = htmldoc.getElementsByClassName("item");
  var returnable = [];
  for(var div in divs){
    var link = div.getElementsByTagName("a")[1];
    var name = link.text;
    var a = link.attributes["href"];
    var img = div.getElementsByTagName("img")[0].attributes["src"];
    var genre_html = div.getElementsByTagName("a");
    List<Widget> genre = [];
    for(var gen in genre_html){
      if(gen.attributes["href"].contains("genre")){
        genre.add(
          Chip(
            avatar: CircleAvatar(
              backgroundColor: Colors.cyan,
              child: Icon(Icons.info_outline),
            ),
            label: Text(gen.text),
          )
        );
      }
    }

    print(a+" "+img+" "+name);
    print(genre);

    returnable.add([name,a,img,genre]);
  }
  return returnable;

}

