import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;


void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Software Factory',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Software Factory'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  Map<String, dynamic> realFactory = {
    "Username": "a",
    "Password": "b",
    "Toolchain": {},
    "Apps": {}
  };

  Future<void> readJson() async {
    final String response = await rootBundle.loadString('assets/config.json');
    final data = await json.decode(response);

    realFactory = Map.castFrom(data);

    for (var tool in realFactory["Toolchain"]!.keys) {
      switch (realFactory["Toolchain"]![tool]["Color"]) {
        case "red":
          realFactory["Toolchain"]![tool]["Color"] = Colors.red;
          break;
        case "blue":
          realFactory["Toolchain"]![tool]["Color"] = Colors.blue;
          break;
        case "green":
          realFactory["Toolchain"]![tool]["Color"] = Colors.green;
          break;
        case "black":
          realFactory["Toolchain"]![tool]["Color"] = Colors.black;
          break;
        case "black26":
          realFactory["Toolchain"]![tool]["Color"] = Colors.black26;
          break;
        default:
          realFactory["Toolchain"]![tool]["Color"] = Colors.red;
      }
    }

    for (var app in realFactory["Apps"]!.keys) {
      for (var pipe in realFactory["Apps"]![app].keys) {
        for (var stage in realFactory["Apps"]![app][pipe].keys) {
          switch (realFactory["Apps"]![app][pipe][stage]["Color"]) {
            case "red":
              realFactory["Apps"]![app][pipe][stage]["Color"] = Colors.red;
              break;
            case "blue":
              realFactory["Apps"]![app][pipe][stage]["Color"] = Colors.blue;
              break;
            case "green":
              realFactory["Apps"]![app][pipe][stage]["Color"] = Colors.green;
              break;
            case "black":
              realFactory["Apps"]![app][pipe][stage]["Color"] = Colors.black;
              break;
            case "black26":
              realFactory["Apps"]![app][pipe][stage]["Color"] = Colors.black26;
              break;
            default:
              realFactory["Apps"]![app][pipe][stage]["Color"] = Colors.red;
          }
        }
      }
    }
  }

  @override
  void initState() {
    super.initState();

    readJson();

    const refreshTime = Duration(seconds: 5);

    Timer.periodic(refreshTime, (Timer timer) {
      _refreshAll(realFactory);
    });
  }

  void _refresh(Map thing) async {
    Map<String, String> baseHeader = {"Accept": "application/json", "Access-Control-Allow-Origin": "*"};

    String username = realFactory["Username"].toString();
    String password = realFactory["Password"].toString();
    String basicAuth = 'Basic ' + base64Encode(utf8.encode('$username:$password'));

    baseHeader[HttpHeaders.authorizationHeader] = realFactory["Token"].toString();
    baseHeader["authorization"] = basicAuth;

    var response = await http.get(Uri.parse(thing["Link"]), headers: baseHeader);

    setState(() {
      if (response.statusCode == 200) {
        thing["Color"] = Colors.green;
        /*var decodedResponse = jsonDecode(utf8.decode(response.bodyBytes)) as Map;
        if (decodedResponse["title"] == "quidem molestiae enim") {
          thing["Color"] = Colors.green;
        } else if (decodedResponse["title"] == "sunt qui excepturi placeat culpa") {
          thing["Color"] = Colors.red;
        } else if (decodedResponse["title"] == "omnis laborum odio") {
          thing["Color"] = Colors.black26;
        } else if (decodedResponse["title"] == "non esse culpa molestiae omnis sed optio") {
          thing["Color"] = Colors.blue;
        } else {
          thing["Color"] = Colors.green;
        }*/
      } else {
        thing["Color"] = Colors.red;
      }
    });
  }

  void _refreshAll(Map factory) {
      for (var tool in factory["Toolchain"].keys) {
        _refresh(factory["Toolchain"][tool]);
      }
      for (var app in factory["Apps"].keys) {
        for (var pipe in factory["Apps"][app].keys) {
          for (var stage in factory["Apps"][app][pipe].keys) {
            _refresh(factory["Apps"][app][pipe][stage]);
          }
        }
      }
  }

  List<Widget> _generatePipeline(String title, Map stageStatus) {
    var pipeline = [
      const Padding(padding: EdgeInsets.all(18.0),),
      Text(title),
      const Padding(padding: EdgeInsets.all(5.0),),
      ] +
    [ for (var stage in stageStatus.keys) OutlinedButton(onPressed: () {_refresh(stageStatus[stage]);}, child: Text(stage), style: TextButton.styleFrom(primary: stageStatus[stage]!["Color"],)) ] +
    [
      const Padding(padding: EdgeInsets.all(5.0),),
      ElevatedButton(onPressed: () {}, child: const Text("Run"))
    ];

    return pipeline;
  }

  List<Widget> _generateToolchain(Map toolStatus) {
    var toolchain = [ const Padding(padding: EdgeInsets.all(10.0),), const Text(""),] +
      [ for (var tool in toolStatus.keys) OutlinedButton(onPressed: () {_refresh(toolStatus[tool]);}, child: Text(tool), style: TextButton.styleFrom(primary: toolStatus[tool]!["Color"],)), ];

    return toolchain;
  }

  List<Widget> _generateApp(String app, Map appBuilds) {
    List<Widget> appData = [ const Padding(padding: EdgeInsets.all(10.0),),  Align(alignment: Alignment.centerLeft, child: Text(app),)];
    List<Widget> builds =  [ for (var build in appBuilds.keys) Row(children: _generatePipeline(build, appBuilds[build])),];

    appData += builds;

    return appData;
  }

  List<Widget> _generateApps(Map appBuilds) {
    List<Widget> toolchain = [];
    
    for (var app in appBuilds.keys) {
      List<Widget>appWidgets = _generateApp(app, appBuilds[app]);
      toolchain += appWidgets;
    }

      return toolchain;
    }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Column(
        children: [
          const Padding(padding: EdgeInsets.all(10.0),),
          Row(
            children: _generateToolchain(realFactory["Toolchain"]!)
          ),
          const Divider(
            height: 20,
            thickness: 2,
            indent: 5,
            endIndent: 5,
            color: Colors.black,
          ),
          const Text("Pipelines", style: TextStyle(fontSize: 25),),
        ] + _generateApps(realFactory["Apps"]!)
      )
    );
  }
}
