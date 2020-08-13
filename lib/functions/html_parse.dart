import 'package:flutter/material.dart';
import 'package:html/parser.dart' show parse;


List Parsehtml_search(html_search_api){
  final htmldoc = parse(html_search_api);
  var divs = htmldoc.getElementsByClassName("item");
  var returnable = [];
  for(var div in divs){
    var link = div.getElementsByTagName("a")[1];
    var name = link.text;
    var a = "/"+link.attributes["href"];
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
    returnable.add([name,a,img,genre]);
  }
  return returnable;
}

List Parsehtml_homepage(html_search_api){
  final htmldoc = parse(html_search_api);
  var divs = htmldoc.getElementsByClassName("film-list")[0].getElementsByClassName("inner");
  var returnable = [];
  for(var div in divs){
    var a = div.getElementsByClassName("poster")[0];
    var name = a.attributes["title"].split("Ep")[0];
    var episodeNumber = a.attributes["title"].split("Ep")[1];
    var link = a.attributes["href"];
    var img = div.getElementsByTagName("img")[0].attributes["src"];
    returnable.add([name,link,img,episodeNumber]);
  }
  return returnable;
}

List Parsehtml_animeinfo(html_search_api) {
  final htmldoc = parse(html_search_api);
  var divs = htmldoc.getElementsByClassName("server active")[0].getElementsByClassName("episodes range");
  var episodes = [];
  var genre = [];
  var desc = htmldoc.getElementsByClassName("desc")[0].text;
  var rating = htmldoc.getElementById("average-vote").text;
  var lenghteps = htmldoc.getElementsByTagName("dl")[1].children[3].text;
  var status = htmldoc.getElementsByTagName("dl")[1].getElementsByTagName("a")[0].text;
  for (var gen in htmldoc.getElementsByTagName("dl")[0].children[11].getElementsByTagName("a")) {
    genre.add(gen.text);
  }
  for (var eprange in divs) {
    for(var ep in eprange.getElementsByClassName("episode")){
      var epid = ep.getElementsByTagName("a")[0].attributes["data-id"];
      var epnumber = ep.getElementsByTagName("a")[0].attributes["data-episode-num"];
      episodes.add([epnumber,epid]);
    }
  }

  print(genre);
  return [rating,lenghteps,status,desc,genre,episodes];
}