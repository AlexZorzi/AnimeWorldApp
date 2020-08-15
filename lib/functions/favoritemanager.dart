import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:hive/hive.dart';

void FavManager(String link, String imageLink, String title, Box<Map> hivebox){
  if(hivebox.get(link) == null){
    hivebox.put(link, {"link":link, "imageLink":imageLink,"title":title});
    print(title+" Added");
  }else{
    hivebox.delete(link);
    print(title+" Deleted");

  }
}