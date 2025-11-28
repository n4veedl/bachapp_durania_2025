import 'dart:convert';

import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_geojson/flutter_map_geojson.dart';

import '../../utils/http.dart' as http;
import '../../models/RouteModel.dart';

part 'route_event.dart';
part 'route_state.dart';

class RouteBloc extends Bloc<RouteEvent, RouteState> {
    RouteBloc() : super(RouteInitial()) {
        on<LoadRouteById>((event, emit) async {
                try {
                    emit(RouteLoading());
                    // TODO: try to load routes from a SQLite database before fetching from the API

                    // Get the route from the API
                    String url = dotenv.env['API_URL']!;
                    url = "${url}api/v1/routes/${event.routeGroupId}/${event.routeId}";

                    dynamic response = await http.get(url);
                    if(response.statusCode != 200) {
                        throw Exception('Failed to load route');
                    }
                    Map<String, dynamic> body = json.decode(response.body);
                    RouteModel route = RouteModel.fromJson(body);

                    if(event.mapController == null) {
                        throw Exception('MapController is not set');
                    }

                    route.route == null ? throw Exception('Route is null') : null;

                    GeoJsonParser inboundParser = GeoJsonParser(
                        defaultPolylineColor: const Color(0xFF330099),
                        defaultPolylineStroke: 3
                    );
                    Map<String, dynamic> inboundLineStrings = {
                        "type": "FeatureCollection",
                        "features": route.route!["features"].where(
                            (feature) => feature["properties"]["name"] == "inbound"
                        ).toList()
                    };
                    inboundParser.parseGeoJson(inboundLineStrings);

                    GeoJsonParser outboundParser = GeoJsonParser(
                        defaultPolylineColor: const Color(0xFF339999),
                        defaultPolylineStroke: 3
                    );
                    Map<String, dynamic> outboundLineStrings = {
                        "type": "FeatureCollection",
                        "features": route.route!["features"].where((feature) => feature["properties"]["name"] == "outbound").toList()
                    };
                    outboundParser.parseGeoJson(outboundLineStrings);

                    GeoJsonParser markers = GeoJsonParser(
                        defaultMarkerColor: Colors.redAccent,
                        defaultMarkerIcon: Icons.arrow_drop_down
                    );
                    Map<String, dynamic> mapMarkers = {
                        "type": "FeatureCollection",
                        "features": route.route!["features"].where(
                            (feature) => (
                            feature["geometry"]["type"] == "Point"
                                && (
                                feature["properties"]["name"] == "start"
                                    || feature["properties"]["name"] == "end"
                                )
                            )
                        ).toList()
                    };
                    markers.parseGeoJson(mapMarkers);

                    GeoJsonParser routeBaseParser = GeoJsonParser(
                        defaultMarkerColor: Colors.redAccent,
                        defaultMarkerIcon: Icons.warehouse_rounded
                    );
                    Map<String, dynamic> routeBase = {
                        "type": "FeatureCollection",
                        "features": route.route!["features"].where((feature) => feature["properties"]["name"] == "base").toList()
                    };
                    routeBaseParser.parseGeoJson(routeBase);

                    event.mapController!.fitCamera(CameraFit.coordinates(coordinates: inboundParser.polylines[0].points, padding: const EdgeInsets.all(15)));

                    emit(
                        RouteLoaded(
                            selectedRoute: route,
                            inboundPolylines: inboundParser.polylines,
                            outboundPolylines: outboundParser.polylines,
                            markers: markers.markers,
                            baseMarker: routeBaseParser.markers
                        )
                    );
                }
                catch (e) {
                    print(e);
                    emit(RouteError(e.toString()));
                }
            }
        );

        on<UnloadRoute>((event, emit) async {
                emit(RouteInitial());
            }
        );
    }
}
