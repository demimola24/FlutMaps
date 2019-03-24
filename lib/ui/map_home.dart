import 'dart:async';
import 'dart:io';

import 'package:android_intent/android_intent.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';




class Map_Home extends StatefulWidget {

   double Long;
   double Lag;
   String LocName;
   String LocAddress;

  Map_Home({Key key, this.Long,this.Lag,this.LocName,this.LocAddress}) : super (key:key);


  @override
  _Map_HomeState createState() => _Map_HomeState();
}

class _Map_HomeState extends State<Map_Home> {
  GoogleMapController _controller;


  @override
  void initState() {
    //Cross - Check Location Shift after awhile
    Timer(Duration(seconds: 10), (){
      print("Second Attempt to Get User Location");
      getMyLocation();
    });
  }

  @override
  Widget build(BuildContext context) {
    final _width = MediaQuery.of(context).size.width;
    final _height = MediaQuery.of(context).size.height;

    return new Scaffold(
      appBar: new AppBar(
        title: new Text("SBT Maps"),
        centerTitle: true,
        backgroundColor: Colors.deepOrange,
      ),
      body: Stack(
        children: <Widget>[
          GoogleMap(
            onMapCreated: (GoogleMapController controller) {
              _controller = controller;
            },
            myLocationEnabled: true,
            initialCameraPosition: CameraPosition(
              target: new LatLng(widget.Lag, widget.Long),
              zoom: 13.0,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Align(
              alignment: Alignment.topLeft,
              child: FloatingActionButton(
                onPressed: () => getMyLocation(),
                materialTapTargetSize: MaterialTapTargetSize.padded,
                backgroundColor: Colors.green,
                child: const Icon(Icons.my_location),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(5.0),
            child: Align(
              alignment: Alignment.bottomCenter,
              child: new Container(
                height: 100,
                margin: EdgeInsets.all(10.0),
                decoration: new BoxDecoration(
                  borderRadius: new BorderRadius.circular(10.0),
                  color: Colors.white70,
                  boxShadow: [
                    new BoxShadow(
                        color: Colors.black.withAlpha(95),
                        offset: const Offset(3.0, 10.0),
                        blurRadius: 10.0)
                  ],
                ),
                width: _width-40.0,
                child: Padding(
                    padding: EdgeInsets.all(10.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[
                        Text(widget.LocName,textAlign: TextAlign.left,
                            style: new TextStyle(
                                fontSize: 22.0,
                                fontWeight: FontWeight.w500
                            ),),
                        Divider(),
                        Text(widget.LocAddress,textAlign: TextAlign.left,
                            softWrap: true,
                            style: new TextStyle(
                                fontSize: 15.0,
                                color: Colors.black54
                            ),),
                      ],
                    ),

                )
              ),
            ),
          ),
        ],
      ),
    );
  }



  void gotoLocation(double Lat, double Long) {
    _controller.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: new LatLng(Lat, Long),
          zoom: 17.0,
        ),
      ),
    );
  }

  Future getMyLocation() async {
    print("Called ");
    bool check = await Geolocator().isLocationServiceEnabled();
    if(!check){
      onGPS();
    }else{
      Position position = await Geolocator().getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
      print("My request result is  ${position.latitude}");
      if(position==null){
        position = await Geolocator().getLastKnownPosition(desiredAccuracy: LocationAccuracy.low);
      }
      List<Placemark> placemark = await Geolocator().placemarkFromCoordinates(position.latitude, position.longitude);
      print("My Address: 1  "+ placemark.first.name+ " 2 "+placemark.first.administrativeArea+ " 3 "+placemark.first.subAdministrativeArea+ " 4 "+placemark.first.subThoroughfare+ " 5 "+placemark.first.thoroughfare+ " 6 "+placemark.first.subLocality+ " 7 "+placemark.first.locality);
      setState(() {
        widget.LocName = placemark.first.thoroughfare;
        widget.LocAddress = placemark.first.subThoroughfare+" "+placemark.first.thoroughfare+", "+placemark.first.subAdministrativeArea+", "+placemark.first.administrativeArea+", "+placemark.first.country+" "+placemark.first.postalCode+".";
        gotoLocation(position.latitude,position.longitude);
      });
    }
  }
//Turn on GPS Dialog
  onGPS() {
    var alert  = new AlertDialog(
      title: new Text("Turn On Location"),
      content: new Container(height: 30.0,
          child: new Text("Turn on your GPS in your device's location setting")
      ),
      actions: <Widget>[
        new FlatButton(
          onPressed: (){
            openSettingsMenu();
            Navigator.pop(context);
          },
          child: new Text("Yes"),
        ),
        new FlatButton(
            onPressed: (){
              exit(0);
            },
            child: new Text("Exit"))
      ],
    );

    showDialog(
        context: context,
        builder: (_) {
          return alert;
        });
  }

  //Turn on GPS
  Future openSettingsMenu() async {
    final AndroidIntent intent = new AndroidIntent(
      action: 'android.settings.LOCATION_SOURCE_SETTINGS',
    );
    await intent.launch();
  }
}
