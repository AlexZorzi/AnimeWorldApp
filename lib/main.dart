import 'package:cached_network_image/cached_network_image.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:fontisto_flutter/fontisto_flutter.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'globals/globals.dart' as globals;
import 'functions/html_parse.dart';
import 'widgets/FavoriteCard.dart';
import 'widgets/SearchCard.dart';
import 'package:salomon_bottom_bar/salomon_bottom_bar.dart';
import 'widgets/HomeCard.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'pages/animedownloaded.dart';
import 'package:permission_handler/permission_handler.dart';



void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  var document = await getApplicationDocumentsDirectory();
  Hive.init(document.path);
  await Hive.openBox<Map>("favorites");
  await Hive.openBox<Map>("timestamps");
  await Hive.openBox<Map>("animedownload");
  await Hive.openBox<String>("downloadworks");
  //await Permission.storage.request();
  await FlutterDownloader.initialize(
      debug: true // optional: set false to disable printing logs to console
  );
  await FlutterDownloader.registerCallback(callback);
  runApp(MyApp());
}

void callback(String id, DownloadTaskStatus status, int progress) {}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AnimeWorld App',
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


  Future<Map<String, String>> getCookie() async{
    var response = await http.get(Uri.parse("https://www.animeworld.tv/"),);
    String cookie = ParseAWCookieTest(response.body);
    return {"cookie": cookie};
  }

  Future<String> getData_Homepage() async {
    globals.AWCookieTest = await getCookie();
    var response = await http.get(
        Uri.parse("https://www.animeworld.tv/"),headers: globals.AWCookieTest);

    setState(() {
      dataHomepage = Parsehtml_homepage(response.body);
    });
    return "Success";
  }

  void changeQuery(String text) {
    query = myController.text;
    getData_Search();
  }

  Future<String> getData_Search() async {
    if (query.length >= 1 && query != Null) {
      var response = await http.get(
          Uri.parse("https://www.animeworld.tv/api/search?sort=year%3Adesc&keyword=" +query),
          headers: {"Accept": "application/json"}..addAll(globals.AWCookieTest));

      setState(() {
        dataSearch = Parsehtml_search(json.decode(response.body)['html']);
      });
      return "Success";
    } else {
      globalKey.currentState.showSnackBar(snackbarQuery);
    }
  }


  @override
  void initState() {
    super.initState();
    favorites = Hive.box<Map>("favorites");
    animedownload = Hive.box<Map>("animedownload");
    getData_Homepage();
    selectedIndex = 0;
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
            Card(
              elevation: 5,
              child: Container(
                width: 400,
                child: TextField(
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.all(20.0),
                      hintText: 'Cerca Anime',
                    focusedBorder: InputBorder.none,
                  ),
                  controller: myController, onSubmitted: changeQuery,),
              ),
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
      case 4:
        return Column(
          children: <Widget>[getSettings()],
        );
        break;
    }

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: globalKey,
      appBar: AppBar(
        title: Text(
          "AnimeWorld very legit",
          style: Theme.of(context).textTheme.headline5,

        ),
      ),
      body: _indexManager(),
      bottomNavigationBar: SalomonBottomBar(
        currentIndex: selectedIndex,
        onTap: (i) => setState(() => selectedIndex = i),
        items: [
          SalomonBottomBarItem(
            icon: Icon(Icons.home),
            title: Text('Home'),
          ),
          SalomonBottomBarItem(
            icon: Icon(Icons.search),
            title: Text('Cerca'),
          ),
          SalomonBottomBarItem(
            icon: Icon(Icons.favorite),
            title: Text('Preferiti'),
          ),
          SalomonBottomBarItem(
            icon: Icon(Icons.file_download),
            title: Text('Download'),
          ),
          SalomonBottomBarItem(
            icon: Icon(Icons.settings),
            title: Text('Settings'),
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
          child: Icon(Icons.home, size: 50, color: Colors.black12,),
        ),
      );
    }
      return GridView.count(
          crossAxisCount: 2,
          mainAxisSpacing: 10.0,
          shrinkWrap: true,
          children: List.generate(dataHomepage.length, (index) {
                    print(dataHomepage[index]);
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
        print(favorites.keys);
        return FavoriteCard(Title: anime["title"], Link: anime["link"], imageLink: anime["imageLink"], favorites: favorites, callback: (){setState(() {
          print("refresh");
        });});
      },
      separatorBuilder: (context, index) {
        return Divider();
      },
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

    Widget getSettings(){
      return  Center(
          child: Column(
            children: <Widget>[
              InkWell(
                child: ListTile(
                  leading: Icon(
                    Istos.github,
                    color: Colors.black,
                  ),
                  title: Text("Github"),
                  trailing: Icon(Icons.open_in_new),
                ),
                onTap: () async {
                  const github_url = "https://github.com/AlexZorzi/AnimeWorldApp";
                  if (await canLaunch(github_url))
                    await launch(github_url);
                  else
                    // can't launch url, there is some error
                    throw "Could not launch $github_url";
                },
              ),
              InkWell(
                child: ListTile(
                  leading: Icon(
                    Istos.telegram,
                    color: Colors.blueAccent,
                  ),
                  title: Text("Telegram Updates"),
                  trailing: Icon(Icons.open_in_new),
                ),
                onTap: () async {
                  const telegram_url = "https://t.me/animeworldapp";
                  if (await canLaunch(telegram_url))
                    await launch(telegram_url);
                  else
                    // can't launch url, there is some error
                    throw "Could not launch $telegram_url";
                },
              ),
            ],
          ),
      );
    }
  DownloadCardMethod(title, Link, imageLink){
    return Card(
      elevation: 5,
      child: InkWell(
        splashColor: Colors.indigoAccent,
        onTap: () {Navigator.push(context,MaterialPageRoute(builder: (context) => AnimeDownloadDisplay(Title: title, Link: Link,imageLink: imageLink, refreshmain: (){setState(() {print("dontask");});},),),);},
        onLongPress: () {},
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
                              CachedNetworkImage(imageUrl: imageLink, width: 100,),
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



