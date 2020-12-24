import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:wikipedia_search/wikidata.dart';
import 'package:html/parser.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'wikipedia Search',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
        // This makes the visual density adapt to the platform that you run
        // the app on. For desktop platforms, the controls will be smaller and
        // closer together (more dense) than on mobile platforms.
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(title: 'Wikipedia Search'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;
  wikiData WikiData;
  String SearchText;
  final FormKey = GlobalKey<FormState>();

  void _incrementCounter() {
    setState(() {
      // This call to setState tells the Flutter framework that something has
      // changed in this State, which causes it to rerun the build method below
      // so that the display can reflect the updated values. If we changed
      // _counter without calling setState(), then the build method would not be
      // called again, and so nothing would appear to happen.
      _counter++;
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    GetSearchData(search: "google");
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: Container(
        height: MediaQuery.of(context).size.height,
        child: Center(
          // Center is a layout widget. It takes a single child and positions it
          // in the middle of the parent.
          child: SingleChildScrollView(
            child: Form(
              key: FormKey,
              child: Column(
                // Column is also a layout widget. It takes a list of children and
                // arranges them vertically. By default, it sizes itself to fit its
                // children horizontally, and tries to be as tall as its parent.
                //
                // Invoke "debug painting" (press "p" in the console, choose the
                // "Toggle Debug Paint" action from the Flutter Inspector in Android
                // Studio, or the "Toggle Debug Paint" command in Visual Studio Code)
                // to see the wireframe for each widget.
                //
                // Column has various properties to control how it sizes itself and
                // how it positions its children. Here we use mainAxisAlignment to
                // center the children vertically; the main axis here is the vertical
                // axis because Columns are vertical (the cross axis would be
                // horizontal).
                // mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Container(
                    padding: EdgeInsets.all(8.0),
                    width: MediaQuery.of(context).size.width,
                    child: Row(
                      children: [
                        Flexible(
                          child: TextFormField(
                            decoration:
                                InputDecoration(hintText: "Search Here..."),
                            onChanged: (text) {
                              setState(() {
                                SearchText = text;
                              });
                            },
                            validator: (val) {
                              if (val.isEmpty) {
                                return "! Enter Search Text";
                              }
                              return null;
                            },
                            onFieldSubmitted: (val) {
                              if (FormKey.currentState.validate()) {
                                GetSearchData(search: SearchText);
                              }
                            },
                          ),
                        ),
                        IconButton(
                          onPressed: () {
                            if (FormKey.currentState.validate()) {
                              GetSearchData(search: SearchText);
                            }
                          },
                          icon: Icon(Icons.search),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(8.0),
                    child: SingleChildScrollView(
                      child: Container(
                        height: MediaQuery.of(context).size.height * 0.75,
                        child: WikiData != null
                            ? ListView.builder(
                                itemCount: WikiData.query.search.length,
                                itemBuilder: (context, index) {
                                  return Container(
                                    margin: EdgeInsets.only(bottom: 8.0),
                                    decoration: BoxDecoration(
                                      color: Color(0XFFe6e6e7),
                                      borderRadius: BorderRadius.circular(5.0),
                                    ),
                                    child: ListTile(
                                      title: Text(
                                          WikiData.query.search[index].title,style: TextStyle(fontSize: 20,fontWeight: FontWeight.w600),),
                                      subtitle: Text(parseToHtml(WikiData
                                          .query.search[index].snippet),style: TextStyle(fontSize: 18,fontWeight: FontWeight.w600),),
                                    ),
                                  );
                                })
                            : Center(
                                child: CircularProgressIndicator(),
                              ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      // This trailing comma makes auto-formatting nicer for build methods.
    );
  }

  GetSearchData({String search}) async {
    /*if(WikiData!=null){
      setState(() {

      });
    }*/
    http.Response response = await http.get(
        "https://en.wikipedia.org/w/api.php?action=query&format=json&list=search&srsearch=$search");
    if (response.statusCode == 200) {
      setState(() {
        WikiData = wikiData.fromJson(jsonDecode(response.body));
      });
    } else {
      print(response.body);
    }
  }

  String parseToHtml(String HtmlString) {
    var doc = parse(HtmlString);
    String parsedString = parse(doc.body.text).documentElement.text;
    return parsedString;
  }
}
