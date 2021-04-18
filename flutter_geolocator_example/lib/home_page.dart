import 'dart:core';
import 'dart:io';
import 'dart:math' show cos, sqrt, asin;
import 'dart:typed_data';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';
import 'package:flutter/services.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:audioplayers/audio_cache.dart';
// import 'package:flutter_beep/flutter_beep.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final Future<FirebaseApp> _future = Firebase.initializeApp();
  String sound = 'audio/alarm.mp3';
  double lat_parent = 0;
  double long_parent = 0;
  double lat_child = 0;
  double long_child = 0;
  // final long = TextEditingController();
  Position _currentPosition;
  String _currentAddress;

  final databaseRef =
      FirebaseDatabase.instance.reference(); //database reference object

  void addData(double lat, double long) {
    databaseRef.push().set({'latitude': lat, 'longitude': long});
  }

  double calculateDistance(lat1, lon1, lat2, lon2) {
    var x = lat2 - lat1;
    var y = (lon2 - lon1) * cos((lat2 + lat1) * 0.00872664626);
    return 111.319 * sqrt(x * x + y * y);
  }

  final player = AudioCache();
  AudioPlayer advancedPlayer = new AudioPlayer();

  @override
  void initState() {
    _getCurrentLocation();
    super.initState();
  }

  void printFirebase() {
    databaseRef.once().then((DataSnapshot snapshot) async {
      final values = snapshot.value;
      //print('${Map<String, Map>.from(values) is Map<String, Map>}');

      final v = Map<String, Map>.from(values);

      double lat_present = values[v.keys.first]["latitude"];
      double long_present = values[v.keys.first]["longitude"];
      lat_child = lat_present;
      long_child = long_present;
      double lat = _currentPosition.latitude;
      double long = _currentPosition.longitude;
      double distance =
          calculateDistance(lat_child, long_child, lat_parent, long_parent);
      // print('Distance : $distance');
      if (distance > 0.02) {
        print("YOUR CHILD IS OUT OF RANGE");
        int i = 0;
        player.play(sound);
      } else {
        print(" YOUR CHILD IS  WITHIN RANGE");
      }
    });
  }

  // @override
  // void initState() {
  //   _getCurrentLocation();
  //   super.initState();
  // }

  // @override
  Widget build(BuildContext context) {
    // printFirebase();
    // _getCurrentLocation();
    print('Add : $_currentAddress');
    print('Latitude : $_currentPosition.latitude');
    return Scaffold(
      appBar: AppBar(
        title: Text("FollowME"),
        backgroundColor: Colors.purple[500],
        centerTitle: true,
      ),
      body: FutureBuilder(
          future: _future,
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Text(snapshot.error.toString());
            } else {
              // body: Center(
              return Center(
                child: Column(
                  // key: formkey,
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    if (_currentAddress != null)
                      Expanded(
                        //color: Colors.purple,
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.purple[300],
                            borderRadius: BorderRadius.only(
                              bottomLeft: Radius.circular(30.0),
                              bottomRight: Radius.circular(30.0),
                            ),
                          ),
                          width: double.infinity,
                          child: Center(
                            child: Text(
                              _currentAddress,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  color: Colors.white, fontSize: 25.0),
                            ),
                          ),
                        ),
                      ),
                    // FlatButton(
                    //   child: Text("Get location"),
                    //   onPressed: () {
                    //     _getCurrentLocation();
                    //   },
                    // ),
                    Expanded(
                      flex: 2,
                      child: TextButton(
                        onPressed: () {
                          _getCurrentLocation();
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20.0),
                            color: Colors.purple[200],
                          ),
                          padding: EdgeInsets.all(10.0),
                          width: 225.0,
                          child: Row(
                            children: [
                              Icon(
                                Icons.location_city_rounded,
                                color: Colors.white,
                              ),
                              SizedBox(
                                height: 10.0,
                              ),
                              Text(
                                ' Activate Location',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 19.0,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    // FlatButton(
                    //   child: Text("STOP"),
                    //   onPressed: () {
                    //     advancedPlayer.stop();
                    //   },
                    // ),
                  ],
                ),
              );
            }
            // ),
          }),
    );
  }

  _getCurrentLocation() {
    Geolocator.getCurrentPosition(
            desiredAccuracy: LocationAccuracy.best,
            forceAndroidLocationManager: false)
        .then((Position position) {
      setState(() {
        _currentPosition = position;
        double lat = _currentPosition.latitude;
        double long = _currentPosition.longitude;
        print('Lat : $lat');
        addData(lat, long);
        _getAddressFromLatLng();
        // itemRef.push().set(item.toJson());
      });
    }).catchError((e) {
      print(e);
    });
  }

  _getAddressFromLatLng() async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
          _currentPosition.latitude, _currentPosition.longitude);

      Placemark place = placemarks[0];

      setState(() {
        _currentAddress =
            "${place.street}, ${place.locality}, ${place.administrativeArea}";
      });
      print('Add : $_currentAddress');
    } catch (e) {
      print(e);
    }
  }
}
