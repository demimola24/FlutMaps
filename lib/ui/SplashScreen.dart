import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:sbtmaps/ui/map_home.dart';
import 'package:geolocator/geolocator.dart';
import 'package:android_intent/android_intent.dart';
import 'package:connectivity/connectivity.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with WidgetsBindingObserver{
  String status = "Please wait..";
  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }


  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      //do your stuff
      Timer(Duration(seconds: 2), (){
        getMyLocation();
      });
    }
  }

  Future getMyLocation() async {
    print("First Attempt to Get User Location ");
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.mobile||connectivityResult == ConnectivityResult.wifi) {
      bool check = await Geolocator().isLocationServiceEnabled();
      if(!check){
        onGPS();
        return;
      }else{
        setState(() {
          status="Loading User Location..";
        });
        Position position = await Geolocator().getCurrentPosition(desiredAccuracy: LocationAccuracy.medium);
        print("My request result is  ${position.latitude}  ${position.longitude}");
        if(position==null){
          position = await Geolocator().getLastKnownPosition(desiredAccuracy: LocationAccuracy.low);
          print("My request result for previous is  ${position.latitude}");
        }
        List<Placemark> placemark = await Geolocator().placemarkFromCoordinates(position.latitude, position.longitude);
        print("My Address: 1  "+ placemark.first.name+ " 2 "+placemark.first.administrativeArea+ " 3 "+placemark.first.subAdministrativeArea+ " 4 "+placemark.first.subThoroughfare+ " 5 "+placemark.first.thoroughfare+ " 6 "+placemark.first.subLocality+ " 7 "+placemark.first.locality);

        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => new Map_Home(Long: position.longitude,Lag: position.latitude,LocName: placemark.first.thoroughfare,LocAddress: placemark.first.subThoroughfare+" "+placemark.first.thoroughfare+", "+placemark.first.subAdministrativeArea+", "+placemark.first.administrativeArea+", "+placemark.first.country+" "+placemark.first.postalCode+".",)));

      }

    } else  {
      //Let process proceed till internet arrives
      onNetwork();
      Fluttertoast.showToast(
          msg: "No Internet Connection, Please turn it on",
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIos: 4,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0
      );
    }
  }


  Future openSettingsMenu() async {
    final AndroidIntent intent = new AndroidIntent(
      action: 'android.settings.LOCATION_SOURCE_SETTINGS',
    );
    await intent.launch();
  }


  @override
  void initState() {
    // TODO: implement initState
    WidgetsBinding.instance.addObserver(this);
    super.initState();
    getMyLocation();
  }

  onGPS() {
    var alert  = new AlertDialog(
      title: new Text("Turn On Location"),
      content: new Container(height: 30.0,
          child: new Text("Turn on your GPS in your device's location setting")
      ),
      actions: <Widget>[
        new FlatButton(
          onPressed: (){
            Navigator.pop(context);
            openSettingsMenu();

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
        barrierDismissible: false,
        builder: (_) {
          return alert;
        });
  }

  onNetwork() {
    var alert  = new AlertDialog(
      title: new Text("No Internet"),
      content: new Container(height: 30.0,
          child: new Text("Kindly turn on your Internet Connection in your device's setting")
      ),
      actions: <Widget>[
        new FlatButton(
          onPressed: (){
            Navigator.pop(context);
            getMyLocation();

          },
          child: new Text("Retry"),
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
        barrierDismissible: false,
        builder: (_) {
          return alert;
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.deepOrange,
      body: new Container(
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            CircularProgressIndicator(valueColor: AlwaysStoppedAnimation(Colors.white
            ),),
            Padding(padding: EdgeInsets.all(10),
              child: Text("$status",
                style: TextStyle(color: Colors.white),),
            )
          ],
        )
      )
    );
  }
}

