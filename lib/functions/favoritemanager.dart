import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:hive/hive.dart';
void FavManager(String link, String imageLink, String title, Box<Map> hivebox){
  if(hivebox.get("/play/"+link.split("/")[2]) == null){
    hivebox.put("/play/"+link.split("/")[2], {"link":"/play/"+link.split("/")[2], "imageLink":imageLink,"title":title});
    print(title+" Added");
  }else{
    hivebox.delete("/play/"+link.split("/")[2]);
    print(title+" Deleted");

  }
}