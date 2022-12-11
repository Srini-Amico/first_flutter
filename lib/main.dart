import 'dart:async';

import 'package:flutter/material.dart';
import 'package:mapbox_gl/mapbox_gl.dart';
import 'package:geolocator/geolocator.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
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
        primarySwatch: Colors.green,
      ),
      home: const MyHomePage(title: 'Anystuff.Rent'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;
  late LatLng _mapPosition = LatLng(13.0827, 80.2707);
  late MapboxMapController mapController;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _mapPosition = LatLng(13.0827, 80.2707);
    _gelocation();
  }

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

  void _gelocation() async {
    try {
      bool servicestatus = await Geolocator.isLocationServiceEnabled();
      if (servicestatus) {
        LocationPermission permission = await Geolocator.checkPermission();

        if (permission == LocationPermission.denied) {
          permission = await Geolocator.requestPermission();
          if (permission == LocationPermission.denied) {
            print("user denied location permission");
          } else if (permission == LocationPermission.deniedForever) {
            print("user denied location permission forever");
          } else {
            print("location permission granted");
          }
        }

        if (permission == LocationPermission.always ||
            permission == LocationPermission.whileInUse) {
          Geolocator.getPositionStream(
                  locationSettings: LocationSettings(
                      accuracy: LocationAccuracy.high, distanceFilter: 100))
              .listen((event) {
            setState(() {
              _mapPosition = LatLng(event.latitude, event.longitude);
              print("setting state");
            });
            print('lat-2: ${event.latitude}');
            print('long-2: ${event.longitude}');
          });
        }
      } else {
        print("GPS service is disabled.");
      }
    } catch (ex) {
      print(ex);
    }
  }

  @override
  Widget build(BuildContext context) {
    print("rendering ${_mapPosition.latitude}");
    var cameraPosition = CameraPosition(
        target: LatLng(_mapPosition.latitude, _mapPosition.longitude),
        zoom: 15.0);

    MapboxMap mapboxMap = MapboxMap(
      initialCameraPosition: cameraPosition,
      trackCameraPosition: true,
      onMapCreated: (controller) =>
          {mapController = controller, print("map created")},
      onMapClick: (point, coordinates) => {
        print("calling mapclick"),
        setState(() => {
              _mapPosition =
                  LatLng(coordinates.latitude, coordinates.longitude),
              print("setting state onmapcick")
            })
      },
    );
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
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
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
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[Expanded(child: mapboxMap)],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
