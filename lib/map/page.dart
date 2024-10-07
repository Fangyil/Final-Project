import 'dart:async';
import 'package:flutter/material.dart';
import 'package:project/map/location.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  final Completer<GoogleMapController> _mapController = Completer();
  final ValueNotifier<int> _selectedLocation = ValueNotifier(0);
  static const _mapTypeOptions = ['街道圖', '衛星影像'];
  static const _mapTypes = [MapType.normal, MapType.satellite];
  final ValueNotifier<int> _selectedMapType = ValueNotifier(0);
  final List<Marker> _locationMarkers = [];

  @override
  void initState() {
    super.initState();
    requestLocationPermission();
  }

  @override
  Widget build(BuildContext context) {
    final mapOptionPanel = Container(
      margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
      child: Row(
        children: [
          Expanded(
            child: Column(
              children: [
                const Text(
                  '地點選擇',
                  style: TextStyle(fontSize: 18),
                ),
                ValueListenableBuilder<int>(
                  builder: _locationSelectionBuilder,
                  valueListenable: _selectedLocation,
                ),
              ],
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                const Text(
                  "地圖種類選擇",
                  style: TextStyle(fontSize: 18),
                ),
                ValueListenableBuilder<int>(
                  builder: _mapTypeSelectionBuilder,
                  valueListenable: _selectedMapType,
                ),
              ],
            ),
          ),
        ],
      ),
    );

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Column(
            children: <Widget>[
              const SizedBox(height: 20),
              mapOptionPanel,
              Expanded(
                child: GoogleMap(
                  initialCameraPosition: const CameraPosition(
                    target: LatLng(25.1505746, 121.7755482),
                    zoom: 15,
                  ),
                  onMapCreated: (controller) =>
                      _mapController.complete(controller),
                  mapType: _mapTypes[_selectedMapType.value],
                  markers: Set.of(_locationMarkers),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _locationSelectionBuilder(
      BuildContext context, int selected, Widget? child) {
    return DropdownButton<int>(
      isExpanded: true,
      items: List.generate(
        Location.locationNames.length,
        (index) => DropdownMenuItem(
          value: index,
          child: Text(
            Location.locationNames[index],
            style: const TextStyle(fontSize: 12),
          ),
        ),
      ),
      onChanged: (dynamic value) async {
        int index = value as int;
        _selectedLocation.value = index;
        _changeLocation(index);
      },
      value: selected < 0 ? null : selected,
    );
  }

  _changeLocation(int index) async {
    final GoogleMapController controller = await _mapController.future;

    var location = Location.latLng[index].split(',');
    double lat = double.parse(location[0]);
    double lon = double.parse(location[1]);

    controller.moveCamera(CameraUpdate.newLatLng(LatLng(lat, lon)));

    _locationMarkers.clear();
    _locationMarkers.add(Marker(
      markerId: MarkerId(index.toString()),
      position: LatLng(lat, lon),
      infoWindow: InfoWindow(
        title: Location.locationNames[index],
      ),
    ));
    setState(() {});
  }

  Widget _mapTypeSelectionBuilder(
      BuildContext context, int selected, Widget? child) {
    return DropdownButton<int>(
      isExpanded: true,
      items: List.generate(
        _mapTypeOptions.length,
        (index) => DropdownMenuItem(
          value: index,
          child: Text(
            _mapTypeOptions[index],
            style: const TextStyle(fontSize: 20),
          ),
        ),
      ),
      onChanged: (dynamic value) async {
        int index = value as int;
        _selectedMapType.value = index;
        setState(() {});
      },
      value: selected < 0 ? null : selected,
    );
  }
}
