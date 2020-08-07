import 'package:flutter/material.dart';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'html_parse.dart';
import 'package:ff_navigation_bar/ff_navigation_bar.dart';
import 'widgets/SearchCard.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'widgets/homepage.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
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
  int selectedIndex;
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
              "https://www.animeworld.tv/api/search?sort=year%3Adesc&keyword=" +
                  query),
          headers: {"Accept": "application/json"});

      setState(() {
        dataSearch = Parsehtml_search(json.decode(response.body)['html']);
        print(dataSearch);
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
          children: <Widget>[Icon(Icons.settings)],
        );
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: globalKey,
      appBar: AppBar(
        title: Text("Flutter Api Example"),
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
            iconData: Icons.settings,
            label: 'Impostazioni',
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
          mainAxisSpacing: 10.0,
          shrinkWrap: true,
          children: List.generate(dataHomepage.length, (index) {
                   return homepageitem(dataHomepage: dataHomepage[index],);
              },
          ),
      );
  }
}