import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import "package:google_maps_webservice/places.dart";
import 'package:transparent_image/transparent_image.dart';

const kGoogleApiKey = "AIzaSyDu3ov0UuButM8WgABpmOz8GXzXRjMfdqg";

final places = GoogleMapsPlaces(apiKey: kGoogleApiKey);

// GoogleMapsPlaces _places = GoogleMapsPlaces(apiKey: kGoogleApiKey);
// const List<Widget> _views = <Widget>[
//   Text('Filter'),
//   Text('Map'),
//   Text('List')
// ];

class UNTMap extends StatelessWidget {
  const UNTMap({super.key});

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
        statusBarIconBrightness: Brightness.dark, // dark text for status bar
        statusBarColor: Colors.transparent));
    return const MaterialApp(
      title: 'Campus Map',
      home: Map(),
    );
  }
}

class Map extends StatefulWidget {
  const Map({super.key});

  @override
  State<Map> createState() => MapState();
}

class MapState extends State<Map> {
  late GoogleMapController _mapController;
  CameraPosition? _cameraPosition;
  int _selectedIndex = 1;
  Set<Marker> _markers = {};
  String placeType = "restaurant";

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: _mapView(),
        bottomNavigationBar: BottomNavigationBar(
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(Icons.filter_list_rounded),
              label: "Filter"
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.map_rounded),
              label: "Map"
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.view_list_rounded),
              label: "List"
            ),
          ],
          currentIndex: _selectedIndex,
          selectedItemColor: const Color(0xFF00853e),
          onTap: _onNavBarTapped,
        ),
      ),
    );
  }

  void _onNavBarTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    switch (index) {
      case 0:
        _filterBottomSheet(context);
        break;
      case 1: break;
      case 2:
        _listBottomSheet(context);
        break;
      default: break;
    }
  }

  void _onCameraMove(CameraPosition cameraPosition) {
    _cameraPosition = cameraPosition;
  }

  GoogleMap _mapView() {
    if (_markers.isEmpty) {
      _retrieveNearbyPlaces(_posDiscoveryPark.target);
    }

    return GoogleMap(
      padding: const EdgeInsets.only(
          top: 32),
      initialCameraPosition: _cameraPosition ?? _posDiscoveryPark,
      onCameraMove: _onCameraMove,
      onMapCreated: (GoogleMapController controller) {
        //_mapController.complete(controller);
        _mapController = controller;
        setState(() {});
      },
      buildingsEnabled: true,
      indoorViewEnabled: true,
      myLocationEnabled: true,
      trafficEnabled: true,
      markers: _markers
        ..add(Marker(
            markerId: MarkerId("User Location"),
            infoWindow: InfoWindow(title: "User Location"),
            position: _posDiscoveryPark.target)),
    );
  }

  Future<void> _retrieveNearbyPlaces(LatLng _userLocation) async {
    PlacesSearchResponse _response = await places.searchNearbyWithRadius(
        Location(lat: 33.25369983707906, lng: -97.15252309168712), 10000,
        type: placeType);

    print(_response.status);

    Set<Marker> _placeMarkers = _response.results
        .map((result) => Marker(
        markerId: MarkerId(result.name),
        // Use an icon with different colors to differentiate between current location
        // and the restaurants
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
        infoWindow: InfoWindow(
            title: result.name,
            snippet: "Ratings: " + (result.rating?.toString() ?? "Not Rated")),
        position: LatLng(
            result.geometry!.location.lat, result.geometry!.location.lng)))
        .toSet();

    setState(() {
      _markers.addAll(_placeMarkers);
    });
  }

  final CameraPosition _posDiscoveryPark = const CameraPosition(
    bearing: 302,
    target: LatLng(33.25369983707906, -97.15252309168712),
    zoom: 17,
  );

  void _update(String? pType) {
    setState(() => placeType = pType!);
  }

  Future<void> _goToDP() async {
    //final GoogleMapController controller = await _mapController.future;
    _mapController.animateCamera(CameraUpdate.newCameraPosition(_posDiscoveryPark));
  }
  Future<void> _listBottomSheet(context) async {
    var results = await getLocData();

    final resultsChildren = <Widget>[];
    for (var i = 0; i < results.length; i++) {
      resultsChildren.add(LocationData(results[i].name, results[i].photos));
    }

    _mapController.animateCamera(CameraUpdate.newCameraPosition(const CameraPosition(
      bearing: 302,
      target: LatLng(33.25369983707906, -97.15252309168712),
      zoom: 13,
    )));

    showModalBottomSheet(
      context: context,
      builder: (BuildContext bc){
        return Wrap(
          children: <Widget>[
            const SizedBox(
              height: 32,
              child: Center(child: Icon(Icons.drag_handle_rounded)),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: resultsChildren
              ),
            )
          ],
        );
      },
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(15.0), topRight: Radius.circular(15.0)),
      ),
      isScrollControlled: true,
      isDismissible: true
    ).whenComplete(() => setState(() {_selectedIndex = 1;}));
  }

  void _filterBottomSheet(context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext bc){
        return Wrap(
          alignment: WrapAlignment.center,
          children: <Widget>[
            const SizedBox(
              height: 32,
              child: Center(child: Icon(Icons.drag_handle_rounded)),
            ),
            FilterPage(update: _update),
          ],
        );
      },
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
            topLeft: Radius.circular(15.0), topRight: Radius.circular(15.0)),
      ),
      isScrollControlled: true,
      isDismissible: true
    ).whenComplete(() => setState(() {_selectedIndex = 1;}));
  }
}

class FilterPage extends StatelessWidget {
  final ValueChanged<String?> update;
  FilterPage({required this.update});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const Text("Filter", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),),
        DropdownButton<String>(
          hint: const Text("Place Type"),
          items: <String>['cafe', 'doctor', 'restaurant', 'store'].map((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value),
            );
          }).toList(),
          onChanged: (value) {update(value.toString());},
        ),
        // DropdownButton<String>(
        //   hint: const Text("Shops"),
        //   items: <String>['Shop Type A', 'Shop Type B', 'Shop Type C', 'Shop Type D'].map((String value) {
        //     return DropdownMenuItem<String>(
        //       value: value,
        //       child: Text(value),
        //     );
        //   }).toList(),
        //   onChanged: (_) {},
        // ),
        // DropdownButton<String>(
        //   hint: const Text("Zones"),
        //   items: <String>['Zone A', 'Zone B', 'Zone C', 'Zone D'].map((String value) {
        //     return DropdownMenuItem<String>(
        //       value: value,
        //       child: Text(value),
        //     );
        //   }).toList(),
        //   onChanged: (_) {},
        // ),
        // DropdownButton<String>(
        //   hint: const Text("Activities"),
        //   items: <String>['Activity A', 'Activity B', 'Activity C', 'Activity D'].map((String value) {
        //     return DropdownMenuItem<String>(
        //       value: value,
        //       child: Text(value),
        //     );
        //   }).toList(),
        //   onChanged: (_) {},
        // ),
        // DropdownButton<String>(
        //   hint: const Text("Services"),
        //   items: <String>['Service A', 'Service B', 'Service C', 'Service D'].map((String value) {
        //     return DropdownMenuItem<String>(
        //       value: value,
        //       child: Text(value),
        //     );
        //   }).toList(),
        //   onChanged: (_) {},
        // ),
      ],
    );
  }
}

List<DropdownMenuItem<String>> get dropdownItems{
  List<DropdownMenuItem<String>> menuItems = [
    const DropdownMenuItem(value: "One", child: Text("One")),
    const DropdownMenuItem(value: "Two", child: Text("Two")),
    const DropdownMenuItem(value: "Three", child: Text("Three")),
    const DropdownMenuItem(value: "Four", child: Text("Four")),
  ];
  return menuItems;
}


class LocationData extends StatelessWidget {
  String businessName;
  List<Photo> photos;

  LocationData(this.businessName, this.photos, {super.key});

  String buildPhotoURL(String photoReference) {
    return "https://maps.googleapis.com/maps/api/place/photo?maxwidth=400&photoreference=${photoReference}&key=${kGoogleApiKey}";
  }

  @override
  Widget build(BuildContext context) {
    final photosChildren = <Widget>[];
    for (var i = 0; i < photos.length; i++) {
      photosChildren.add(FadeInImage.memoryNetwork(
        placeholder: kTransparentImage,
        image: buildPhotoURL(photos[i].photoReference),
        width: 300,
      ),);
      photosChildren.add(const SizedBox(width: 4));
    }

    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(bottom: 16),
          child: Text(businessName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),)
        ),
        Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: photosChildren
            )
          ),
        )
      ],
    );
  }
}

class LocationImage extends StatelessWidget {
  const LocationImage({super.key});

  @override
  Widget build(BuildContext context) {
    return Container( // Change to Image when using actual data
      height: 100,
      width: 100,
      decoration: BoxDecoration(
        color: Colors.grey[500],
        borderRadius: BorderRadius.circular(8),
      ),
    );
  }
}

Future<List<PlacesSearchResult>> getLocData() async {
  PlacesSearchResponse response = await places.searchNearbyWithRadius(Location(lat: 33.25369983707906, lng: -97.15252309168712), 10000, type: "restaurant");
  List<PlacesSearchResult> results = response.results;

  return results;
}