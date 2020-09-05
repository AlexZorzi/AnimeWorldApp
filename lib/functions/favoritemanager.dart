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

