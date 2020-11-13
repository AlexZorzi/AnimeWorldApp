import 'dart:ui';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:fontisto_flutter/fontisto_flutter.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'functions/favoritemanager.dart';
import 'functions/html_parse.dart';
import 'package:ff_navigation_bar/ff_navigation_bar.dart';
import 'widgets/SearchCard.dart';
import 'widgets/HomeCard.dart';
import 'pages/animeInfo.dart';
import 'package:hive/hive.dart';
import 'package:pwa/client.dart' as pwa;



void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  //Hive.init(document.path); not needed in web
  new pwa.Client();
  await Hive.openBox<Map>("favorites");
  await Hive.openBox<Map>("timestamps");
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

}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String cors = "https://cors-anywhere.herokuapp.com/";
  List dataSearch;
  List dataHomepage;
  String query;
  int selectedIndex;
  Box<Map> favorites;

  final globalKey = GlobalKey<ScaffoldState>();
  final myController = TextEditingController();
  final snackbarQuery = SnackBar(content: Text('Inserisci almeno 1 lettera.'));



  void changeQuery(String text) {
    query = myController.text;
    getData_Search();
  }

  Future<String> getData_Search() async {
    if (query.length >= 1 && query != Null) {
      var response = await http.get(
          Uri.encodeFull(
             cors + "https://www.animeworld.tv/api/search?sort=year%3Adesc&keyword=" +
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
        Uri.encodeFull(cors+"https://www.animeworld.tv/"));

    setState(() {
      dataHomepage = Parsehtml_homepage(response.body);
    });
    return "Success";
  }

  @override
  void initState() {
    super.initState();
    favorites = Hive.box<Map>("favorites");
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
            iconData: Icons.settings,
            label: 'Settings',
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
        return FavoriteCardMethod(anime["title"], anime["link"],anime["imageLink"]);
      },
      separatorBuilder: (context, index) {
        return Divider();
      },
    );
  }


    FavoriteCardMethod(title, Link, imageLink){
    print(Link);
      return Card(
        elevation: 5,
        child: InkWell(
          splashColor: Colors.indigoAccent,
          onTap: () {Navigator.push(context,MaterialPageRoute(builder: (context) => AnimeInfo(Title: title, Link: Link,imageLink: imageLink),),);},
          onLongPress: () {setState(() {
            FavManager(Link, imageLink, title, favorites, );
          });},
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
                                Container(
                                  child: Image(
                                    image: NetworkImage("https://static.wikia.nocookie.net/darling-in-the-franxx/images/b/b3/Zero_Two_appearance.jpg/revision/latest/scale-to-width-down/340?cb=20180807204943"),
                                    width: 125,),
                                ),
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

    Widget getSettings(){
      return  Center(
          child: Column(
            children: <Widget>[
              InkWell(
                child: ListTile(
                  leading: Icon(
                    Istos.trello,
                    color: Colors.deepPurple,
                  ),
                  title: Text("Trello"),
                  trailing: Icon(Icons.open_in_new),
                ),
                onTap: () async {
                  const trello_url = "https://trello.com/b/Tfw7RQsw/animeword-app";
                  if (await canLaunch(trello_url))
                    await launch(trello_url);
                  else
                    // can't launch url, there is some error
                    throw "Could not launch $trello_url";
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

  }



