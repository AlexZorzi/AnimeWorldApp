import 'package:flutter/material.dart';
import 'package:html/parser.dart' show parse;

String ParseAWCookieTest(body_homepage){
  var re = RegExp(r'AWCookieVerify=[^;]+;');
  var match = re.firstMatch(body_homepage);
  if (match != null){
    return match.group(0).replaceAll(" ", ""); // last " " breaks cookie
  }else{
    print("E: Cookie not found!");
    return null;
  }

}

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
/*
AnimeWorld Server Number 9
Beta Number 10
Alpha Number 5

*/
List Parsehtml_animeinfo(html_search_api) {
  final htmldoc = parse(html_search_api);
  var episodes = [];
  for(var server in htmldoc.getElementsByClassName("tab server-tab")){
    int servername = int.parse(server.attributes["data-name"]);
      if(servername == 9 || servername == 10 || servername == 5) {
        var serverdiv = htmldoc.querySelector('div[data-name="${servername.toString()}"]')
            .getElementsByClassName("episodes range");
        List<List<String>> serverep = [];
        for (var eprange in serverdiv) {
          for (var ep in eprange.getElementsByClassName("episode")) {
            var epid = ep.getElementsByTagName("a")[0].attributes["data-id"];
            var epnumber = ep.getElementsByTagName("a")[0]
                .attributes["data-episode-num"];
            serverep.add([epnumber, epid]);
          }
          episodes.add(serverep);
        }
      }
  }
  
  var genre = [];
  var desc = htmldoc.getElementsByClassName("desc")[0].text;
  var rating = htmldoc.getElementById("average-vote").text;
  var lenghteps = htmldoc.getElementsByTagName("dl")[1].children[3].text;
  var status = htmldoc.getElementsByTagName("dl")[1].getElementsByTagName("a")[0].text;
  var dl = htmldoc.getElementsByTagName("dl")[0].children[2];
  for (var gen in dl.getElementsByTagName("a")) {
    genre.add(gen.text);
  }
  print(episodes[0]);
  return [rating,lenghteps,status,desc,genre,episodes];
}