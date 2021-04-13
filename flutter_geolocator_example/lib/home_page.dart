import 'dart:core';
import 'dart:core';
import 'dart:core';

import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:firebase_core/firebase_core.dart';

// final FirebaseApp app = FirebaseApp(
//     options: FirebaseOptions(
//   googleAppID: '1:583397431848:android:b94ae9c439de890522f31d',
//   apiKey: 'AIzaSyDsRLoXtFsKYqeeaLJUXkyXx0x3GEvtxCc',
//   // databaseURL: '',
// ));
//

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final Future<FirebaseApp> _future = Firebase.initializeApp();
  final textcontroller = TextEditingController();
  double lat = 0;
  double long = 0;
  // final long = TextEditingController();
  Position _currentPosition;
  String _currentAddress;

  final databaseRef =
      FirebaseDatabase.instance.reference(); //database reference object

  void addData(double lat, double long) {
    databaseRef.push().set({'latitude': lat, 'longitude': long});
  }

  void printFirebase() {
    databaseRef.once().then((DataSnapshot snapshot) {
      Map<dynamic, dynamic> values = snapshot.value;
      values.forEach((key, values) {
        print('Lat : $values["latitude"]');
        print('Long : $values["longitude"]');
      });
    });
  }

  // @override
  Widget build(BuildContext context) {
    printFirebase();
    return Scaffold(
      appBar: AppBar(
        title: Text("Location"),
      ),
      body: FutureBuilder(
          future: _future,
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Text(snapshot.error.toString());
            } else {
              // body: Center(
              return Container(
                child: Column(
                  // key: formkey,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    if (_currentAddress != null) Text(_currentAddress),
                    FlatButton(
                      child: Text("Get location"),
                      onPressed: () {
                        _getCurrentLocation();
                      },
                    ),
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
            forceAndroidLocationManager: true)
        .then((Position position) {
      setState(() {
        _currentPosition = position;
        double lat = _currentPosition.latitude;
        double long = _currentPosition.longitude;
        addData(lat, long);
        // itemRef.push().set(item.toJson());
        _getAddressFromLatLng();
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
            "${place.locality}, ${place.postalCode}, ${place.country}";
      });
    } catch (e) {
      print(e);
    }
  }
}
