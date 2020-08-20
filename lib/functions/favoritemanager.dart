import 'dart:io';

import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_downloader/flutter_downloader.dart';

void FavManager(String link, String imageLink, String title, Box<Map> hivebox){
  var animeid = link.split("/")[2].split(".")[0];
  var animelink = "/play/"+link.split("/")[2];
  if(hivebox.get(animeid) == null){
    hivebox.put(animeid, {"link":animelink, "imageLink":imageLink,"title":title});
    print(title+" Added");
  }else{
    hivebox.delete(animeid);
    print(title+" Deleted");

  }
}
void DownloadManager(String link, String imageLink, String title, Box<Map> hivebox, String epnumber, String eplink){
  var animeid = link.split("/")[2].split(".")[0];
  var animelink = "/play/"+link.split("/")[2];

  if(hivebox.get(animeid) == null){
    hivebox.put(animeid,
    {
      'link' : animelink,
      'title': title,
      'imageLink': imageLink,
      'episodes' : {epnumber: eplink}
    }
    );
    print(title+" Added (downloadmanager)");
  }
  else if(!hivebox.get(animeid)["episodes"].containsKey(epnumber)){
    var episodes = hivebox.get(animeid)["episodes"];
    episodes[epnumber] = eplink;
          hivebox.put(animeid,
              {
                'link' : animelink,
                'title': title,
                'imageLink': imageLink,
                'episodes' : episodes
              }
          );

          print(title+" Added (downloadmanager)");

  }
  else if(hivebox.get(animeid)["episodes"].containsKey(epnumber)){
    var episodes = hivebox.get(animeid)["episodes"];
    episodes.remove(epnumber);
    hivebox.put(animeid,
        {
          'link' : animelink,
          'title': title,
          'imageLink': imageLink,
          'episodes' : episodes
        }
    );

    if(hivebox.get(animeid)["episodes"].values.length == 0){hivebox.delete(animeid);}
    print(title+" Deleted (downloadmanager)");

  }
  else{
    print(title+" IDK ERROR(?)");

  }
  print(hivebox.values);
}

