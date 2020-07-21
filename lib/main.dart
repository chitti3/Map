import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_map_polyline/google_map_polyline.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:location/location.dart';
import 'package:permission/permission.dart';
import 'dart:math' show cos, sqrt, asin;
import 'map_pin_pill.dart';
import 'pin_pill_info.dart';

const double CAMERA_ZOOM = 16;
const double CAMERA_TILT = 80;
const double CAMERA_BEARING = 30;
const LatLng SOURCE_LOCATION = LatLng(8.4217937, 77.9515563);
const LatLng DEST_LOCATION = LatLng(8.639259030890825, 77.87441566586494);

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  PinInformation currentlySelectedPin = PinInformation(
      pinPath: '',
      avatarPath: '',
      location: LatLng(0, 0),
      locationName: '',
      labelColor: Colors.grey);
  double pinPillPosition = -100;

  Completer<GoogleMapController> _controllers = Completer();
  Set<Polyline> _polylines = Set<Polyline>();
  LocationData currentLocatio;
  LocationData destinationLocation;
  Location location;
  Set<Marker> _markers = Set<Marker>();
  final Set<Polyline> polyline = {};
  String Search;
  var txt = TextEditingController();
  double value = 0.0;
  String loca = "coimbatore";
  double _originLatitude = 8.4217937, _originLongitude = 77.9515563;
  double _destLatitude = 8.639259030890825, _destLongitude = 77.87441566586494;
  TextEditingController nameController = TextEditingController();
  static const LatLng _center = const LatLng(40.6782, -73.9442);
  bool maptoggle = false;
  var currentlocation;
  var current;
  BitmapDescriptor sourceIcon;
  BitmapDescriptor destinationIcon;
  Map<MarkerId, Marker> markers = {};
  Map<PolylineId, Polyline> polylines = {};
  List<LatLng> polylineCoordinates = [];
  PolylinePoints polylinePoints = PolylinePoints();
  GoogleMapController _controller;
  List<LatLng> routeCoords;
  /* GoogleMapPolyline googleMapPolyline = new GoogleMapPolyline(
      apiKey: "AIzaSyCHXS8K1FZBYXS9yqoyUYHBZqIWGS_LF_g");*/
  GoogleMapPolyline googleMapPolyline =
      new GoogleMapPolyline(apiKey: "AIzaSyBJ37Ynqb-EdwHogGpXpEGm4hdx2rZDLhE");

/*
  getsomePoints() async {
    print("hello");

    var permissions =
        await Permission.getPermissionsStatus([PermissionName.Location]);
    if (permissions[0].permissionStatus == PermissionStatus.notAgain) {
      var askpermissions =
          await Permission.requestPermissions([PermissionName.Location]);
    } else {
      routeCoords = await googleMapPolyline.getCoordinatesWithLocation(
          origin: LatLng(40.6782, -73.9442),
          destination: LatLng(40.6944, -73.9212),
          mode: RouteMode.driving);
    }
  }
*/

  @override
  void initState() {
    // TODO: implement initState
//    _getPolyline();
    super.initState();
    /*
    location = new Location();
    location.onLocationChanged().listen((LocationData cLoc) {
      // cLoc contains the lat and long of the
      // current user's position in real time,
      // so we're holding on to it
      currentLocatio = cLoc;
      updatePinOnMap();
    });*/
    // getaddressPoints();
    var p = 0.017453292519943295;
    var c = cos;
    var a = 0.5 -
        c((13.0827 - 11.0168) * p) / 2 +
        c(11.0168 * p) * c(13.0827 * p) * (1 - c((80.2707 - 76.9558) * p)) / 2;
    double value = 12742 * asin(sqrt(a));
    print(value);
    Geolocator().getCurrentPosition().then((currloc) {
      setState(() {
        currentlocation = currloc;
        _addMarker(LatLng(currloc.latitude, currloc.longitude), "origin",
            BitmapDescriptor.defaultMarker);
        maptoggle = true;
        print(currentlocation);
      });
    });
    setSourceAndDestinationIcons();
    // set the initial location
    setInitialLocation();
    //  getDistance();
  }

  void setSourceAndDestinationIcons() async {
    sourceIcon = await BitmapDescriptor.fromAssetImage(
        ImageConfiguration(devicePixelRatio: 2.5), 'assets/driving_pin.png');

    destinationIcon = await BitmapDescriptor.fromAssetImage(
        ImageConfiguration(devicePixelRatio: 2.5),
        'assets/destination_map_marker.png');
  }

  void setInitialLocation() async {
    // set the initial location by pulling the user's
    // current location from the location's getLocation()
    currentLocatio = await location.getLocation();

    // hard-coded destination for this example
    /* destinationLocation = LocationData.fromMap({
      "latitude": DEST_LOCATION.latitude,
      "longitude": DEST_LOCATION.longitude
    });*/
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Stack(
      children: <Widget>[
        Container(
          child: maptoggle
              ? GoogleMap(
                  myLocationEnabled: true,
                  compassEnabled: true,
                  tiltGesturesEnabled: false,
                  onMapCreated: onMapCreated,
                  //markers: _markers,
                  //polylines: _polylines,
                  polylines: Set<Polyline>.of(polylines.values),
                  onTap: _handletap,
                  mapType: MapType.normal,
                  markers: Set<Marker>.of(markers.values),
                  initialCameraPosition: CameraPosition(
                      target: LatLng(
                          currentlocation.latitude, currentlocation.longitude),
                      zoom: 10.0),
                )
              : Center(
                  child: Text(
                    'Loading Please wait',
                    style: TextStyle(fontSize: 20.0),
                  ),
                ),
        ),
        Positioned(
          top: 50.0,
          right: 15.0,
          left: 15.0,
          child: Container(
            color: Colors.white,
            margin: EdgeInsets.fromLTRB(0, 10, 0, 0),
            child: TextField(
                //    onTap: searchandNavigate(),
                controller: nameController,
                cursorColor: Colors.black,
                decoration: InputDecoration(
                  hintText: "Search",
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.only(left: 15.0, top: 16.0),
                )),
          ),
        ),
        Positioned(
          top: 50.0,
          left: 15.0,
          child: Container(
            color: Colors.white,
            margin: EdgeInsets.fromLTRB(270, 10, 0, 0),
            child: IconButton(
              icon: new Icon(Icons.search),
              highlightColor: Colors.pink,
              onPressed: () {
                //getsomePoints();
              },
            ),
          ),
        ),
        Positioned(
          top: 50.0,
          left: 15.0,
          child: Container(
            color: Colors.white,
            margin: EdgeInsets.fromLTRB(0, 80, 0, 0),
            padding: EdgeInsets.fromLTRB(10, 10, 10, 10),
            child: Text(
              value.toString(),
            ),
          ),
        ),
        MapPinPillComponent(
            pinPillPosition: pinPillPosition,
            currentlySelectedPin: currentlySelectedPin)
      ],
    )
        /* GoogleMap(
      onMapCreated: onMapCreated,
      polylines: polyline,
      initialCameraPosition:
          CameraPosition(target: LatLng(40.6782, -73.9442), zoom: 14.0),
      mapType: MapType.normal,
    )*/
        );
  }

  _addMarker(LatLng position, String id, BitmapDescriptor descriptor) {
    MarkerId markerId = MarkerId(id);
    Marker marker =
        Marker(markerId: markerId, icon: descriptor, position: position);
    markers[markerId] = marker;
  }

  _addPolyLine() {
    PolylineId id = PolylineId("poly");
    Polyline polyline = Polyline(
        polylineId: id,
        color: Colors.blue,
        startCap: Cap.roundCap,
        endCap: Cap.buttCap,
        points: polylineCoordinates,
        width: 2);
    polylines[id] = polyline;
    setState(() {});
  }

  void onMapCreated(GoogleMapController controller) {
    _controllers.complete(controller);
    showPinsOnMap();
    setState(() {
      _controller = controller;

      polyline.add(Polyline(
          polylineId: PolylineId('route1'),
          visible: true,
          points: routeCoords,
          width: 4,
          color: Colors.blue,
          startCap: Cap.roundCap,
          endCap: Cap.buttCap));
    });
  }

  void showPinsOnMap() {
    // get a LatLng for the source location
    // from the LocationData currentLocation object
    var pinPosition = LatLng(currentLocatio.latitude, currentLocatio.longitude);
    // get a LatLng out of the LocationData object
    var destPosition =
        LatLng(destinationLocation.latitude, destinationLocation.longitude);
    // add the initial source location pin
    _markers.add(Marker(
        markerId: MarkerId('sourcePin'),
        position: pinPosition,
        icon: sourceIcon));
    // destination pin
    _markers.add(Marker(
        markerId: MarkerId('destPin'),
        position: destPosition,
        icon: destinationIcon));
    // set the route lines on the map from source to destination
    // for more info follow this tutorial
    setPolylines();
  }

  void updatePinOnMap() async {
    // create a new CameraPosition instance
    // every time the location changes, so the camera
    // follows the pin as it moves with an animation
    CameraPosition cPosition = CameraPosition(
      zoom: CAMERA_ZOOM,
      tilt: CAMERA_TILT,
      bearing: CAMERA_BEARING,
      target: LatLng(currentLocatio.latitude, currentLocatio.longitude),
    );
    final GoogleMapController controller = await _controllers.future;
    controller.animateCamera(CameraUpdate.newCameraPosition(cPosition));
    // do this inside the setState() so Flutter gets notified
    // that a widget update is due
    setState(() {
      // updated position
      var pinPosition =
          LatLng(currentLocatio.latitude, currentLocatio.longitude);

      // the trick is to remove the marker (by id)
      // and add it again at the updated location
      _markers.removeWhere((m) => m.markerId.value == "sourcePin");
      _markers.add(Marker(
          markerId: MarkerId("sourcePin"),
          position: pinPosition, // updated position
          icon: sourceIcon));
    });
  }

  void setPolylines() async {
    /*  List<PointLatLng> result = await polylinePoints.getRouteBetweenCoordinates(
        "AIzaSyBJ37Ynqb-EdwHogGpXpEGm4hdx2rZDLhE",
        currentLocatio.latitude,
        currentLocatio.longitude,
        destinationLocation.latitude,
        destinationLocation.longitude);*/
    PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
      "AIzaSyBJ37Ynqb-EdwHogGpXpEGm4hdx2rZDLhE",
      PointLatLng(currentLocatio.latitude, currentLocatio.longitude),
      PointLatLng(destinationLocation.latitude, destinationLocation.longitude),
      travelMode: TravelMode.driving,
      // wayPoints: [PolylineWayPoint(location: "Sabo, Yaba Lagos Nigeria")]
    );
    if (result.points.isNotEmpty) {
      result.points.forEach((PointLatLng point) {
        polylineCoordinates.add(LatLng(point.latitude, point.longitude));
      });
      setState(() {
        _polylines.add(Polyline(
            width: 5, // set the width of the polylines
            polylineId: PolylineId("poly"),
            color: Color.fromARGB(255, 40, 122, 198),
            points: polylineCoordinates));
      });
    }
  }
/*
  distance() {
    var p = 0.017453292519943295;
    var c = cos;
    var a = 0.5 -
        c((current.latitude - currentlocation.latitude) * p) / 2 +
        c(currentlocation.latitude * p) *
            c(current.latitude * p) *
            (1 - c((current.longitude - currentlocation.longitude) * p)) /
            2;
    value = 12742 * asin(sqrt(a));
    print("hello" + value.toString());
  }*/

  searchandNavigate() {
    String value = nameController.text;
    print("hello" + value);
    Geolocator().placemarkFromAddress(value).then((value) {
      _controller.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(
          target:
              LatLng(value[0].position.latitude, value[0].position.longitude),
          zoom: 30.0)));
      print(Search);
    });
  }

  void _handletap(LatLng argument) {
    current = argument;
    destinationLocation = LocationData.fromMap(
        {"latitude": argument.latitude, "longitude": argument.longitude});
    location = new Location();
    location.onLocationChanged().listen((LocationData cLoc) {
      // cLoc contains the lat and long of the
      // current user's position in real time,
      // so we're holding on to it
      currentLocatio = cLoc;
      updatePinOnMap();
    });

    print(argument);
    _getPolyline();

    setState(() {
      _addMarker(LatLng(argument.latitude, argument.longitude), "destination",
          BitmapDescriptor.defaultMarkerWithHue(90));
    });
    var p = 0.017453292519943295;
    var c = cos;
    var a = 0.5 -
        c((current.latitude - currentlocation.latitude) * p) / 2 +
        c(currentlocation.latitude * p) *
            c(current.latitude * p) *
            (1 - c((current.longitude - currentlocation.longitude) * p)) /
            2;
    value = 12742 * asin(sqrt(a));
    print("hello" + value.toString());
  }

  _getPolyline() async {
    PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
      "AIzaSyBJ37Ynqb-EdwHogGpXpEGm4hdx2rZDLhE",
      PointLatLng(currentlocation.latitude, currentlocation.longitude),
      PointLatLng(current.latitude, current.longitude),
      travelMode: TravelMode.driving,
      // wayPoints: [PolylineWayPoint(location: "Sabo, Yaba Lagos Nigeria")]
    );
    polylineCoordinates.clear();
    if (result.points.isNotEmpty) {
      result.points.forEach((PointLatLng point) {
        polylineCoordinates.add(LatLng(point.latitude, point.longitude));
      });
    }
    _addPolyLine();
  }
}
