import 'package:flutter/material.dart';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'html_parse.dart';
import 'package:ff_navigation_bar/ff_navigation_bar.dart';
import 'package:expansion_card/expansion_card.dart';


void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
          primarySwatch: Colors.blue,
          brightness: Brightness.dark,
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
      home: MyHomePage(title: 'Flutter Api Call'),
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
  List data;
  String query;
  int selectedIndex;
  final myController = TextEditingController();

  void changeQuery(String text){
    query = myController.text;
    getData();
  }

  Future<String> getData() async {
    var response = await http.get(
        Uri.encodeFull("https://www.animeworld.tv/api/search?sort=year%3Adesc&keyword="+query),
        headers: {"Accept": "application/json"});

    setState(() {
      data = Parsehtml(json.decode(response.body)['html']);
      print(data);
    });
    return "Success";
  }

  @override
  void initState() {
    super.initState();
    getData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Flutter Api Example"),
      ),
      body: Column(
        children: <Widget>[
          Container(
            child:  TextField(controller: myController, onSubmitted: changeQuery,),
          ),
          Expanded(
            child: getList(),
          )
        ],
      ),
      bottomNavigationBar: FFNavigationBar(
        theme: FFNavigationBarTheme(
          barBackgroundColor: Colors.white,
          selectedItemBorderColor: Colors.yellow,
          selectedItemBackgroundColor: Colors.green,
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
            iconData: Icons.calendar_today,
            label: 'Schedule',
          ),
          FFNavigationBarItem(
            iconData: Icons.people,
            label: 'Contacts',
          ),
          FFNavigationBarItem(
            iconData: Icons.attach_money,
            label: 'Bills',
          ),
          FFNavigationBarItem(
            iconData: Icons.note,
            label: 'Notes',
          ),
          FFNavigationBarItem(
            iconData: Icons.settings,
            label: 'Settings',
          ),
        ],
      ),

    );
  }

  Widget getList() {
    if (data == null || data.length < 1) {
      return Container(
        child: Center(
          child: Icon(Icons.search,size: 50, color: Colors.black12,),
        ),
      );
    }
    return ListView.separated(
      itemCount: data?.length,
      itemBuilder: (BuildContext context, int index) {
        return getListItem(index);
      },
      separatorBuilder: (context, index) {
        return Divider();
      },
    );
  }

  Widget getListItem(int i) {
    print(data[i][0]);
    if (data == null || data.length < 1) return null;

    return Center(
        child: ExpansionCard(
          background: Image(image: NetworkImage(data[i][2]),fit: BoxFit.fill,),
          title: Container(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  data[i][0],
                ),
                Text(
                  "Sub",
                ),
              ],
            ),
          ),
          children: <Widget>[
            Container(
              margin: EdgeInsets.symmetric(horizontal: 7),
              child: Text("Content goes over here !",
              ),
            )
          ],
        ));
  }
}