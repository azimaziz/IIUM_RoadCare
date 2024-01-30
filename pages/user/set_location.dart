import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geocoder2/geocoder2.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:location/location.dart' as loc;

class setLocation extends StatefulWidget {
  const setLocation({super.key});

  @override
  State<setLocation> createState() => _setLocation();
}

class _setLocation extends State<setLocation> {
  LatLng? destLocation = LatLng(3.252161672150421, 101.73425857314945);
  Location location = Location();
  loc.LocationData? _currentPosition;
  final Completer<GoogleMapController?> _controller = Completer();
  String? _address;

  @override
  void initState() {
    super.initState();
    getCurrentLocation();
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Set Location'),
        centerTitle: true,
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.blue, 
        child: Container(
          decoration: BoxDecoration(
            color: Colors.blue, 
          ),
          padding: EdgeInsets.all(8), 
          child: const Icon(
            Icons.save,
            color: Colors.white, 
          ),
        ),
        onPressed: () {
          // Pass back the latitude and longitude to the previous screen
          Navigator.pop(context, {'latitude': destLocation!.latitude, 'longitude': destLocation!.longitude});
        },
      ),
      body: Stack(
        children: [
          GoogleMap(
            myLocationEnabled: true,
            myLocationButtonEnabled: true,
            zoomControlsEnabled: false,
            initialCameraPosition: CameraPosition(
              target: destLocation!,
              zoom: 16,
            ),
            onCameraMove: (CameraPosition? position){
              if(destLocation!= position!.target){
                setState(() {
                  destLocation = position.target;
                });
              }
            },
            onCameraIdle: (){
              print('camera idle');
              getAddressFromLatLng();
            },
            onTap: (LatLng){
              print(LatLng);
            },
            onMapCreated: (GoogleMapController controller){
              _controller.complete(controller);
            },
          ),
          Align(
            alignment: Alignment.center,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 35.0),
              child: Image.asset(
                'lib/images/pinLocation.png',
                height: 45,
                width: 45,
              ),
            ),
          ),
          Positioned(
            top: 10,
            right: 60,
            left: 20,
            child: Material(
              elevation: 5.0, // Set the elevation value here
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                ),
                padding: EdgeInsets.all(20),
                child: Text(
                  _address ?? 'Set your location',
                  overflow: TextOverflow.visible, 
                  softWrap: true,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  getAddressFromLatLng() async {
    try {
      GeoData data = await Geocoder2.getDataFromCoordinates(
        latitude: destLocation!.latitude,
        longitude: destLocation!.longitude,
        googleMapApiKey: 'SECRET'
      );
      setState(() {
        _address = data.address;
      });
    } catch (e) {
      print(e);
    }
  }

  getCurrentLocation() async {
    bool _serviceEnabled;
    PermissionStatus _permissionGranted;

    _serviceEnabled = await location.serviceEnabled();
    final GoogleMapController? controller = await _controller.future;

    if (!_serviceEnabled) {
      _serviceEnabled = await location.requestService();
      if (!_serviceEnabled) {
        return;
      }
    }

    _permissionGranted = await location.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await location.requestPermission();
      if (_permissionGranted != PermissionStatus.granted) {
        return;
      }
    }

    if(_permissionGranted == loc.PermissionStatus.granted) {
      location.changeSettings(accuracy: loc.LocationAccuracy.high);

      _currentPosition = await location.getLocation();
      controller?.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(
        target:LatLng(_currentPosition!.latitude!, _currentPosition!.longitude!),
        zoom: 16,
      )));
      setState(() {
        destLocation = LatLng(_currentPosition!.latitude!, _currentPosition!.longitude!);
      });
    }
  }

}
