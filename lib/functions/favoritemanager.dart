import 'dart:io';

import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_downloader/flutter_downloader.dart';

void FavManager(String link, String imageLink, String title, Box<Map> hivebox){
  if(hivebox.get("/play/"+link.split("/")[2]) == null){
    hivebox.put("/play/"+link.split("/")[2], {"link":"/play/"+link.split("/")[2], "imageLink":imageLink,"title":title});
    print(title+" Added");
  }else{
    hivebox.delete("/play/"+link.split("/")[2]);
    print(title+" Deleted");

  }
}
void DownloadManager(String link, String imageLink, String title, Box<Map> hivebox, String epnumber, String eplink){
  if(hivebox.get("/play/"+link.split("/")[2]) == null){
    hivebox.put("/play/"+link.split("/")[2],
    {
      'link' : link,
      'title': title,
      'imageLink': imageLink,
      'episodes' : {epnumber: eplink}
    }
    );
    print(title+" Added (downloadmanager)");
  }
  else if(!hivebox.get("/play/"+link.split("/")[2])["episodes"].containsKey(epnumber)){
    var episodes = hivebox.get("/play/"+link.split("/")[2])["episodes"];
    episodes[epnumber] = eplink;
          hivebox.put("/play/"+link.split("/")[2],
              {
                'link' : link,
                'title': title,
                'imageLink': imageLink,
                'episodes' : episodes
              }
          );

          print(title+" Added (downloadmanager)");

  }
  else if(hivebox.get("/play/"+link.split("/")[2])["episodes"].containsKey(epnumber)){
    var episodes = hivebox.get("/play/"+link.split("/")[2])["episodes"];
    episodes.remove(epnumber);
    hivebox.put(link.split("/")[2],
        {
          'link' : link,
          'title': title,
          'imageLink': imageLink,
          'episodes' : episodes
        }
    );
    if(hivebox.get("/play/"+link.split("/")[2])["episodes"].values.length == 0){hivebox.delete("/play/"+link.split("/")[2]);}
    print(title+" Deleted (downloadmanager)");

  }
  else{
    print(title+" IDK ERROR(?)");

  }
  print(hivebox.values);
}

