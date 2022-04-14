import 'dart:developer';
import 'dart:math';
import 'dart:math';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:package_buddy/Screens/navBar.dart';
import '../main.dart';
import 'directions_reposotory.dart';
import 'directions_model.dart';

LatLng getRandomLocation(LatLng point, int radius, int i) {
  //This is to generate 10 random points
  double x0 = point.latitude;
  double y0 = point.longitude;

  Random random = new Random();

  // Convert radius from meters to degrees
  double radiusInDegrees = radius / 111000;

  double u = random.nextDouble();
  double v = random.nextDouble();
  double w = radiusInDegrees * sqrt(u);
  double t = 2 * pi * v;
  double x = w * cos(t);
  double y = w * sin(t) * 1.75;

  // Adjust the x-coordinate for the shrinking of the east-west distances
  double new_x = x / sin(y0);

  double foundLatitude = new_x + x0;
  double foundLongitude = y + y0;
  LatLng randomLatLng = new LatLng(foundLatitude, foundLongitude);

  return randomLatLng;
}

class MapScreen extends StatefulWidget {
  const MapScreen({Key? key}) : super(key: key);

  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  var rng = Random();
  late BitmapDescriptor customMarker;
  getcustomMarker() async {
    var customMarker = await BitmapDescriptor.fromAssetImage(
        ImageConfiguration(devicePixelRatio: 3.0), 'assets/package.png');
    setState(() {
      this.customMarker = customMarker;
    });
  }

  custom() async {
    BitmapDescriptor customIcon;

    BitmapDescriptor.fromAssetImage(
            ImageConfiguration(devicePixelRatio: 3.0), 'assets/package.png')
        .then((d) {
      customIcon = d;
    });
  }

  @override
  void initState() {
    super.initState();
    getcustomMarker();
    custom();
  }

  static const _initialCameraPosition = CameraPosition(
    target: LatLng(43.517472668097945, 16.445993140206063),
    zoom: 11.5,
  );

  GoogleMapController? _googleMapController;
  Marker? _origin;
  Marker? _destination;
  Marker? _package;
  Marker? _package1;
  Directions? _info;

  @override
  void dispose() {
    _googleMapController!.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: NavBar(),
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.black),
        backgroundColor: Color(0xFFFFF9C4),
        centerTitle: false,
        title: const Text(
          'Map',
          style: TextStyle(
            color: Color(0xf0000000),
          ),
        ),
        actions: [
          if (_origin != null)
            TextButton(
              onPressed: () => _googleMapController!.animateCamera(
                CameraUpdate.newCameraPosition(
                  CameraPosition(
                    target: _origin!.position,
                    zoom: 14.5,
                    tilt: 50.0,
                  ),
                ),
              ),
              style: TextButton.styleFrom(
                primary: Colors.red,
                textStyle: const TextStyle(fontWeight: FontWeight.w600),
              ),
              child: const Text('ORIGIN'),
            ),
          if (_destination != null)
            TextButton(
              onPressed: () => _googleMapController!.animateCamera(
                CameraUpdate.newCameraPosition(
                  CameraPosition(
                    target: _destination!.position,
                    zoom: 14.5,
                    tilt: 50.0,
                  ),
                ),
              ),
              style: TextButton.styleFrom(
                primary: Colors.green,
                textStyle: const TextStyle(fontWeight: FontWeight.w600),
              ),
              child: const Text('DEST'),
            ),
          if (_package != null)
            TextButton(
              onPressed: () => _googleMapController!.animateCamera(
                CameraUpdate.newCameraPosition(
                  CameraPosition(
                    target: _package!.position,
                    zoom: 14.5,
                    tilt: 50.0,
                  ),
                ),
              ),
              style: TextButton.styleFrom(
                primary: Colors.amber,
                textStyle: const TextStyle(fontWeight: FontWeight.w600),
              ),
              child: const Text('PACKAGE'),
            ),
          if (_package1 != null)
            TextButton(
              onPressed: () => _googleMapController!.animateCamera(
                CameraUpdate.newCameraPosition(
                  CameraPosition(
                    target: _package1!.position,
                    zoom: 14.5,
                    tilt: 50.0,
                  ),
                ),
              ),
              style: TextButton.styleFrom(
                primary: Colors.amber,
                textStyle: const TextStyle(fontWeight: FontWeight.w600),
              ),
              child: const Text('PACKAGE'),
            ),
        ],
      ),
      body: Stack(
        alignment: Alignment.center,
        children: [
          GoogleMap(
            myLocationButtonEnabled: false,
            zoomControlsEnabled: false,
            initialCameraPosition: _initialCameraPosition,
            onMapCreated: (controller) => _googleMapController = controller,
            markers: {
              if (_origin != null) _origin!,
              if (_destination != null) _destination!,
              if (_package != null) _package!,
              if (_package1 != null) _package1!,
            },
            polylines: {
              if (_info != null)
                Polyline(
                  polylineId: const PolylineId('overview_polyline'),
                  color: Colors.red,
                  width: 5,
                  points: _info!.polylinePoints!
                      .map((e) => LatLng(e.latitude, e.longitude))
                      .toList(),
                ),
            },
            onLongPress: _addMarker,
          ),
          if (_info != null)
            Positioned(
              top: 20.0,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  vertical: 6.0,
                  horizontal: 12.0,
                ),
                decoration: BoxDecoration(
                  color: Colors.yellowAccent,
                  borderRadius: BorderRadius.circular(20.0),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black26,
                      offset: Offset(0, 2),
                      blurRadius: 6.0,
                    )
                  ],
                ),
                child: Text(
                  '${_info!.totalDistance}, ${_info!.totalDuration}',
                  style: const TextStyle(
                    fontSize: 18.0,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.black,
        onPressed: () => _googleMapController!.animateCamera(
          _info != null
              ? CameraUpdate.newLatLngBounds(_info!.bounds!, 100.0)
              : CameraUpdate.newCameraPosition(_initialCameraPosition),
        ),
        child: const Icon(Icons.center_focus_strong),
      ),
    );
  }

  void addPackages(LatLng pos) async {
    setState(() {
      _package = Marker(
        markerId: const MarkerId("Package"),
        infoWindow: const InfoWindow(title: 'package'),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange),
        position: getRandomLocation(pos, 250, 20),
      );
    });
  }

  void addPackages1(LatLng pos) async {
    setState(() {
      _package1 = Marker(
        markerId: const MarkerId("Package1"),
        infoWindow: const InfoWindow(title: 'package'),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange),
        position: getRandomLocation(pos, 100, 20),
      );
    });
  }

  void addPackages2(LatLng pos) async {
    setState(() {
      _package = Marker(
        markerId: const MarkerId("Package2"),
        infoWindow: const InfoWindow(title: 'package'),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange),
        position: getRandomLocation(pos, 100, 20),
      );
    });
  }

  void _addMarker(LatLng pos) async {
    if (_origin == null || (_origin != null && _destination != null)) {
      // Origin is not set OR Origin/Destination are both set
      // Set origin
      setState(() {
        _origin = Marker(
          markerId: const MarkerId('origin'),
          infoWindow: const InfoWindow(title: 'Origin'),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
          position: pos,
        );
        // Reset destination
        _destination = null;
        _package = null;
        _package1 = null;
        // Reset info
        _info = null;
      });
    } else {
      // Origin is already set
      // Set destination
      setState(() {
        _destination = Marker(
          markerId: const MarkerId('destination'),
          infoWindow: const InfoWindow(title: 'Destination'),
          icon:
              BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
          position: pos,
        );
      });

      // Get directions
      final directions = await DirectionsRepository()
          .getDirections(origin: _origin!.position, destination: pos);
      setState(() => _info = directions);

      addPackages(pos);
      int a = 1;
      if (rng.nextInt(1) == 1) {
        addPackages1(pos);
      }
    }
  }
}
