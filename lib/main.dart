import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert' as convert;

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(accentColor: Colors.white),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<Widget> tvShows = [];
  String showName;
  Widget favorateShow = Container();

  Future<void> loadShowData() async {
    var url = 'http://api.tvmaze.com/search/shows?q=$showName';
    String category;
    String imageUrl;
    String language;
    String rating;
    String status;

    // Await the http get response, then decode the json-formatted response.
    var response = await http.get(url);

    if (response.statusCode == 200) {
      var jsonResponse = convert.jsonDecode(response.body);
      var show = jsonResponse[0]['show'];
      category = show['genres'][0] ?? "";
      imageUrl = show['image']['original'].toString() ?? "";
      language = show['language'] ?? "";
      rating = show['rating']['average'].toString() ?? 0;
      status = show['status'] ?? "";
    } else {
      print('Request failed with status: ${response.statusCode}.');
    }

    tvShows.add(
      ListTile(
        leading: Image.network(imageUrl),
        subtitle: Text(
          "$category | $language | $status",
          style: TextStyle(color: Colors.grey[500]),
        ),
        title: Text(showName),
        trailing: Text(rating),
        onLongPress: () {
          setFavorateTvShow(imageUrl: imageUrl);
        },
      ),
    );

    setState(() {});
  }

  void setFavorateTvShow({String imageUrl}) {
    favorateShow = CircleAvatar(
      key: UniqueKey(),
      backgroundImage: NetworkImage(imageUrl),
      radius: 75,
    );
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    var _controller = TextEditingController();

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text("My TV Shows"),
        centerTitle: true,
        backgroundColor: Colors.transparent,
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.white,
        onPressed: () {
          loadShowData();
          _controller.clear();
        },
        child: Icon(Icons.add),
      ),
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              AnimatedSwitcher(
                duration: Duration(milliseconds: 500),
                child: favorateShow,
              ),
              Padding(
                padding: EdgeInsets.all(20.0),
                child: TextField(
                  controller: _controller,
                  decoration: InputDecoration(
                    labelText: 'TV Show',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(9),
                    ),
                  ),
                  onChanged: (value) {
                    showName = value;
                  },
                ),
              ),
              Expanded(
                child: Container(
                  margin: EdgeInsets.all(8.0),
                  padding: EdgeInsets.all(8.0),
                  decoration: BoxDecoration(
                    color: tvShows.isNotEmpty
                        ? Color(0xFF1c1c1e)
                        : Colors.transparent,
                    borderRadius: BorderRadius.all(
                      Radius.circular(20),
                    ),
                  ),
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: tvShows.reversed.toList(), //TV Shows
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
