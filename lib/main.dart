import 'dart:io';

import 'package:flutter/material.dart';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'functions/html_parse.dart';
import 'package:ff_navigation_bar/ff_navigation_bar.dart';
import 'widgets/SearchCard.dart';
import 'widgets/homepage.dart';
import 'pages/animeInfo.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'pages/animedownloaded.dart';



void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  var document = await getApplicationDocumentsDirectory();
  Hive.init(document.path);
  await Hive.openBox<Map>("favorites");
  await Hive.openBox<Map>("timestamps");
  await Hive.openBox<Map>("animedownload");

  FlutterDownloader.initialize(
      debug: true // optional: set false to disable printing logs to console
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        brightness: Brightness.light,
        primaryColor: Colors.lightBlue[800],
        accentColor: Colors.cyan[600],

        // Define the default font family.
        fontFamily: 'Georgia',

        // Define the default TextTheme. Use this to specify the default
        // text styling for headlines, titles, bodies of text, and more.
        textTheme: TextTheme(
        headline1: TextStyle(fontSize: 72.0, fontWeight: FontWeight.bold),
        headline6: TextStyle(fontSize: 36.0, fontStyle: FontStyle.italic),
        bodyText2: TextStyle(fontSize: 14.0, fontFamily: 'Hind'),
      )),
      home: MyHomePage(title: 'AnimeWorld App'),
    );
  }

  void test(){
    print("ciao");
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List dataSearch;
  List dataHomepage;
  String query;
  var downloadfiles;
  int selectedIndex;
  Box<Map> favorites;
  Box<Map> animedownload;
  final globalKey = GlobalKey<ScaffoldState>();
  final myController = TextEditingController();
  final snackbarQuery = SnackBar(content: Text('Inserisci almeno 1 lettera.'));
  String _localPath;

  Future<String> _findLocalPath() async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }
  void _requestDownload(url,pathanime,epnumber) async {
    String _localPath = (await _findLocalPath()) + Platform.pathSeparator + 'Download' + Platform.pathSeparator + pathanime;

    final savedDir = Directory(_localPath);
    bool hasExisted = await savedDir.exists();
    print(savedDir.listSync());
    if (!hasExisted) {
      savedDir.create();
    }
    await FlutterDownloader.enqueue(
        url: url,
        fileName: epnumber,
        savedDir: _localPath,
        showNotification: true,
        openFileFromNotification: true);
  }

  void FavManager(String link, String imageLink, String title){
    if(favorites.get("/play/"+link.split("/")[2]) == null){
      setState(() {
        favorites.put("/play/"+link.split("/")[2], {"link":"/play/"+link.split("/")[2], "imageLink":imageLink,"title":title});
      });
      print(title+" Added");
    }else{
      setState(() {
        favorites.delete("/play/"+link.split("/")[2]);
      });
      print(title+" Deleted");

    }
  }

  void changeQuery(String text) {
    query = myController.text;
    getData_Search();
  }

  Future<String> getData_Search() async {
    if (query.length >= 1 && query != Null) {
      var response = await http.get(
          Uri.encodeFull(
              "https://www.animeworld.tv/api/search?sort=year%3Adesc&keyword=" +
                  query),
          headers: {"Accept": "application/json"});

      setState(() {
        dataSearch = Parsehtml_search(json.decode(response.body)['html']);
      });
      return "Success";
    } else {
      globalKey.currentState.showSnackBar(snackbarQuery);
    }
  }

  Future<String> getData_Homepage() async {
    var response = await http.get(
        Uri.encodeFull("https://www.animeworld.tv/"));

    setState(() {
      dataHomepage = Parsehtml_homepage(response.body);
    });
    return "Success";
  }

  @override
  void initState() {
    super.initState();
    favorites = Hive.box<Map>("favorites");
    animedownload = Hive.box<Map>("animedownload");
    print(animedownload.values);
    refreshDownloads();
    getData_Homepage();
    selectedIndex = 0;
  }

  void refreshDownloads() async{
    var downloadpath =  (await _findLocalPath()) + Platform.pathSeparator + 'Download';
    setState(() {
      downloadfiles = Directory(downloadpath).listSync();
      });
  }
  Column _indexManager() {
    switch (selectedIndex) {
      case 0:
        return Column(
          children: <Widget>[Expanded(child: getList_Home())],
        );
        break;

      case 1:
        return Column(
          children: <Widget>[
            Container(
              child: TextField(
                controller: myController, onSubmitted: changeQuery,),
            ),
            Expanded(
              child: getList_Search(),
            )
          ],
        );
        break;
      case 2:
        return Column(
          children: <Widget>[Expanded(child: getFavorites(),)],
        );
        break;
      case 3:
        return Column(
          children: <Widget>[Expanded(child: getDownloads(),)],
        );
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: globalKey,
      appBar: AppBar(
        title: Text("AnimeWorld very legit"),
      ),
      body: _indexManager(),
      bottomNavigationBar: FFNavigationBar(
        theme: FFNavigationBarTheme(
          barBackgroundColor: Colors.white,
          selectedItemBorderColor: Colors.indigo,
          selectedItemBackgroundColor: Colors.indigo,
          selectedItemIconColor: Colors.white,
          selectedItemLabelColor: Colors.black,
        ),
        selectedIndex: selectedIndex,
        onSelectTab: (index) {
          setState(() {
            selectedIndex = index;
          });
        },
        items: [
          FFNavigationBarItem(
            iconData: Icons.home,
            label: 'Home',
          ),
          FFNavigationBarItem(
            iconData: Icons.search,
            label: 'Cerca',
          ),
          FFNavigationBarItem(
            iconData: Icons.favorite,
            label: 'Preferiti',
          ),
          FFNavigationBarItem(
            iconData: Icons.file_download,
            label: 'Download',
          ),
        ],
      ),

    );
  }

  Widget getList_Search() {
    if (dataSearch == null || dataSearch.length < 1) {
      return Container(
        child: Center(
          child: Icon(Icons.search, size: 50, color: Colors.black12,),
        ),
      );
    }
    return ListView.separated(
      itemCount: dataSearch?.length,
      itemBuilder: (BuildContext context, int index) {
        return SearchCard(dataSearch: dataSearch[index]);
      },
      separatorBuilder: (context, index) {
        return Divider();
      },
    );
  }


  Widget getList_Home() {
    if (dataHomepage == null || dataHomepage.length < 1) {
      return Container(
        child: Center(
          child: Icon(Icons.search, size: 50, color: Colors.black12,),
        ),
      );
    }
      return GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 20.0,
          mainAxisSpacing: 20.0,
          shrinkWrap: true,
          children: List.generate(dataHomepage.length, (index) {
                   return homepageitem(dataHomepage: dataHomepage[index],favorites: favorites,);
              },
          ),
      );
  }

  Widget getFavorites(){
    if (favorites.values.length < 1) {
      return Container(
        child: Center(
          child: Icon(Icons.favorite, size: 50, color: Colors.black12,),
        ),
      );
    }
    return ListView.separated(
      itemCount: favorites.values.length,
      itemBuilder: (BuildContext context, int index) {
        var anime = favorites.getAt(index);
        print(favorites.values);
        print(anime);
        return FavoriteCardMethod(anime["title"], anime["link"],anime["imageLink"]);
      },
      separatorBuilder: (context, index) {
        return Divider();
      },
    );
  }


    FavoriteCardMethod(title, Link, imageLink){
      return Card(
        elevation: 5,
        child: InkWell(
          splashColor: Colors.indigoAccent,
          onTap: () {Navigator.push(context,MaterialPageRoute(builder: (context) => AnimeInfo(Title: title, Link: Link,imageLink: imageLink),),);},
          onLongPress: () {FavManager(Link, imageLink, title);},
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
                                  image: NetworkImage(imageLink),
                                  width: 50,),
                                SizedBox(
                                  height: 10,
                                ),
                                Flexible(
                                  child: new Container(
                                    margin: EdgeInsets.only(
                                        left: 15, bottom: 150),
                                    child: new Text(
                                      title,
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

    Widget getDownloads(){
      if (animedownload.values.length < 1) {
        return Container(
          child: Center(
            child: Icon(Icons.file_download, size: 50, color: Colors.black12,),
          ),
        );
      }
      return ListView.separated(
        itemCount: animedownload.values.length,
        itemBuilder: (BuildContext context, int index) {
          var anime = animedownload.getAt(index);
          return DownloadCardMethod(anime["title"], anime["link"],anime["imageLink"]);
        },
        separatorBuilder: (context, index) {
          return Divider();
        },
      );
    }
  DownloadCardMethod(title, Link, imageLink){
    return Card(
      elevation: 5,
      child: InkWell(
        splashColor: Colors.indigoAccent,
        onTap: () {Navigator.push(context,MaterialPageRoute(builder: (context) => AnimeDownloadDisplay(Title: title, Link: Link,imageLink: imageLink),),);},
        onLongPress: () {FavManager(Link, imageLink, title);},
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
                                image: NetworkImage(imageLink),
                                width: 50,),
                              SizedBox(
                                height: 10,
                              ),
                              Flexible(
                                child: new Container(
                                  margin: EdgeInsets.only(
                                      left: 15, bottom: 150),
                                  child: new Text(
                                    title,
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

