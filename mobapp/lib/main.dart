
import 'dart:async';
import 'dart:io';

import 'package:DIAPotholeReporter1/blocs/Reports/report_bloc.dart';
import 'package:DIAPotholeReporter1/pages/AboutPage.dart';
import 'package:DIAPotholeReporter1/pages/ReportsList.dart';
import 'package:DIAPotholeReporter1/utils/sqlite_handler.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:geolocator/geolocator.dart';
import 'package:path_provider/path_provider.dart' as path_provider;

import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:flutter_map/flutter_map.dart';
import 'package:vector_map_tiles_pmtiles/vector_map_tiles_pmtiles.dart';
import 'package:vector_tile_renderer/vector_tile_renderer.dart' as vtr;
import 'package:latlong2/latlong.dart';

import 'package:DIAPotholeReporter1/blocs/map_toggle_cubit.dart';

import 'blocs/map_controller_cubit.dart';

Future main() async {
    await dotenv.load(
        fileName: kDebugMode == true
            ? ".env.development"
            : ".env.production"
    );

    SqliteHandler sqliteHandler = SqliteHandler(null, null);
    await sqliteHandler.initDatabase();

    runApp(const MyApp());
}

class MyApp extends StatelessWidget {
    const MyApp({super.key});

    // This widget is the root of your application.
    @override
    Widget build(BuildContext context) {
        return PopScope(
            canPop: false,
            child: MaterialApp(
                title: 'DIAPotholeReporter1',
                theme: ThemeData(
                    colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
                    useMaterial3: true,
                ),
                home: MultiBlocProvider(
                    providers: [
                        BlocProvider<ReportBloc>(
                            create: (context) => ReportBloc()..add(GetReports()),
                        ),
                        BlocProvider<MapControllerCubit>(
                            create: (context) => MapControllerCubit(),
                        ),
                        BlocProvider<MapToggleCubit>(
                            create: (context) => MapToggleCubit()..reset(),
                        ),
                    ],
                    child: const MyHomePage(title: 'DIAPotholeReporter1'),
                )
            )
        );
    }
}

class MyHomePage extends StatefulWidget {
    const MyHomePage({super.key, required this.title});

    // This widget is the home page of your application. It is stateful, meaning
    // that it has a State object (defined below) that contains fields that affect
    // how it looks.

    // This class is the configuration for the state. It holds the values (in this
    // case the title) provided by the parent (in this case the App widget) and
    // used by the build method of the State. Fields in a Widget subclass are
    // always marked "final".

    final String title;

    @override
    State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

    final mapController = MapController();
    final DraggableScrollableController sheetController = DraggableScrollableController();

    // final Future<MbTiles?> tiles = _initMbTiles();
    // final _theme = vtr.ProvidedThemes.lightTheme();

    final _futureTileProvider = _initTiles();
    final vtr.Theme _theme = ProtomapsThemes.lightV4(
        logger: kDebugMode ? const vtr.Logger.console() : null,
    );

    static Future<PmTilesVectorTileProvider?> _initTiles() async {
        final Directory? directory = await path_provider.getExternalStorageDirectory();
        // final Directory? directory = await path_provider.getApplicationSupportDirectory();
        print("* ${directory?.path}");

        final List<FileSystemEntity>? files = directory?.listSync();
        if (files == null) {
            return null;
        }

        for (var file in files) {
            print("\t\t|__ ${file.path}");
            // check for file
            if (file.path.endsWith("dgocity2.pmtiles")) {
                // MbTiles mbtiles = MbTiles(mbtilesPath: file.path, gzip: false);
                // return MbTiles(mbtilesPath: file.path, gzip: false);
                return await PmTilesVectorTileProvider.fromSource(file.path);
            }
        }

        return null;
    }

    double? gpsLat;
    double? gpsLong;
    late StreamSubscription<Position> _positionStream;
    double? currentLat;
    double? currentLong;

    @override
    void initState() {
        super.initState();

        const LocationSettings locationSettings = LocationSettings(
            accuracy: LocationAccuracy.high,
            distanceFilter: 100,
        );
        _positionStream = Geolocator.getPositionStream(locationSettings: locationSettings)
            .listen((Position? position) {
                    setState(() {
                            print("Position update: ${position!.latitude}, ${position.longitude}");
                            gpsLat = position.latitude;
                            gpsLong = position.longitude;
                            mapController.fitCamera(CameraFit.coordinates(
                                coordinates: [LatLng(gpsLat!-0.005, gpsLong!-0.005), LatLng(gpsLat!+0.005, gpsLong!+0.005)],
                                padding: const EdgeInsets.all(15)
                            ));
                        }
                    );
                }
            );
    }

    @override
    Widget build(BuildContext context) {
        return Scaffold(
            body: Stack(
                children: [
                    FlutterMap(
                        mapController: mapController,
                        options: MapOptions(
                            initialZoom: 14,
                            initialCenter
                                : LatLng(gpsLat ?? 24.0231, gpsLong ?? -104.6502),
                            interactionOptions: const InteractionOptions(
                                flags: InteractiveFlag.all & ~InteractiveFlag.rotate
                            ),
                            onMapReady: () {
                                context.read<MapControllerCubit>().setMapController(mapController);

                                /*mapController.mapEventStream.listen((event) {
                                        if(event is MapEventMoveEnd) {
                                            setState(() {
                                                    currentLat = mapController.camera.center
                                                        .latitude.toString();
                                                    currentLong = mapController.camera
                                                        .center.longitude.toString();
                                                }
                                            );
                                        }
                                    }
                                );*/
                            }
                        ),
                        children: [
                            /*FutureBuilder<PmTilesVectorTileProvider?>(
                                future: _futureTileProvider,
                                builder: (context, snapshot) {
                                    print("1.- ${snapshot.connectionState}");
                                    if (snapshot.hasData) {
                                        print("1.1.- ${snapshot.data}");
                                        return VectorTileLayer(
                                            showTileDebugInfo: true,
                                            layerMode: VectorTileLayerMode.raster,
                                            tileProviders: TileProviders({
                                                // 'openmaptiles': MbTilesVectorTileProvider(mbtiles: snapshot.data!)
                                                'protomaps': snapshot.data!
                                            }
                                            ),
                                            theme: _theme,
                                        );
                                        // return TileLayer(
                                        //     tileProvider: snapshot.data
                                        // );
                                    }
                                    else {
                                        print("1.2.- ${snapshot.data}");
                                        return Container();
                                    }
                                }
                            ),*/
                            TileLayer(
                                // urlTemplate: "http://40.233.29.215/hot/{z}/{x}/{y}.png",
                                urlTemplate: "${dotenv.env['MAP_SERVER_URL']!}hot/{z}/{x}/{y}.png",
                                userAgentPackageName: 'dev.fleaflet.flutter_map.example',
                            ),
                            // PolylineLayer(polylines: <Polyline>[])
                            /*BlocBuilder<RouteBloc, RouteState>(
                                builder: (context, state) {
                                    if (state is RouteLoaded) {
                                        return BlocBuilder<MapToggleCubit, Map<String, bool>>(
                                            builder: (cubitContext, cubitState) {
                                                return Stack(
                                                    children: [
                                                        if (cubitState['inboundRoute']!) PolylineLayer(
                                                            polylines: state.inboundPolylines!
                                                        ),
                                                        if (cubitState['outboundRoute']!) PolylineLayer(
                                                            polylines: state.outboundPolylines!
                                                        ),
                                                        if (cubitState['markers']!) MarkerLayer(
                                                            markers: state.markers!
                                                        ),
                                                        if (cubitState['markers']!) MarkerLayer(
                                                            markers: state.baseMarker!
                                                        )
                                                    ]
                                                );
                                            }
                                        );
                                    }

                                    return Container();
                                }
                            ),*/
                            Builder(
                                builder: (context) {
                                    print("GPS MarkerLayer: $gpsLat, $gpsLong");

                                    if (gpsLat == null && gpsLong == null) {
                                        return Container();
                                    }

                                    MarkerLayer gpsLayer = MarkerLayer(markers: [
                                            Marker(
                                                point: LatLng(gpsLat!, gpsLong!),
                                                child: const Stack(
                                                    children: [
                                                        Icon(
                                                            Icons.circle_outlined,
                                                            color: Colors.white,
                                                            size: 30
                                                        ),
                                                        Center(
                                                            child: Icon(
                                                                Icons.circle,
                                                                color: Colors.blue,
                                                                size: 25
                                                            )
                                                        )
                                                    ])
                                            )
                                        ],

                                    );

                                    return gpsLayer;
                                }
                            )
                        ],
                    ),
                    Builder(
                        builder: (context) {
                            return Positioned(
                                // consider safe area
                                top: MediaQuery.of(context).padding.top + 10,
                                left: 10,
                                child: Row(
                                    children: [
                                        FloatingActionButton(
                                            onPressed: () {
                                                Scaffold.of(context).openDrawer();
                                            },
                                            mini: true,
                                            backgroundColor: Colors.white,
                                            child: const Icon(Icons.menu, size: 20, color: Colors.black),
                                        ),
                                        /*Text(
                                            "Zoom: ${mapController.camera.zoom}, Lat: ${mapController.camera.center.latitude}, Lng: ${mapController.camera.center.longitude}",
                                        )*/
                                    ]
                                )
                            );
                        }
                    ),
                    Positioned(
                        top: MediaQuery.of(context).padding.top + 60,
                        left: 10,
                        child: FloatingActionButton(
                            onPressed: () {
                                if (gpsLat == null || gpsLong == null) {
                                    print("GPS Button: No available values from GPS");
                                }

                                print("GPS Button zoom to: $gpsLat, $gpsLong");
                                mapController.fitCamera(CameraFit.coordinates(
                                        coordinates: [LatLng(gpsLat!-0.005, gpsLong!-0.005), LatLng(gpsLat!+0.005, gpsLong!+0.005)],
                                        padding: const EdgeInsets.all(15)
                                    ));
                            },
                            mini: true,
                            backgroundColor: Colors.white,
                            child: const Icon(Icons.gps_fixed, size: 20, color: Colors.blueAccent),
                        ), 
                    ),
                    /*Positioned(
                        top: MediaQuery.of(context).padding.top + 110,
                        left: 10,
                        child: Text(
                            style: const TextStyle(color: Colors.black, fontSize: 12),
                            "LatLong: ${currentLat}, ${currentLong}"
                        )
                    ),*/
                    const CustomDraggableScroll(),
                ]
            ),
            drawerEnableOpenDragGesture: false,
            drawer: Drawer(
                child: ListView(
                    padding: EdgeInsets.zero,
                    children: [
                        DrawerHeader(
                            decoration: const BoxDecoration(
                                color: Colors.redAccent,
                            ),
                            child: Stack(
                                children: [
                                    const Align(
                                        alignment: Alignment.bottomLeft,
                                        child: Text('DIAPotholeReporter1', style: TextStyle(color: Colors.white, fontSize: 30)),
                                    ),
                                    Align(
                                        alignment: Alignment.topRight,
                                        child: Container(
                                            color: Colors.redAccent,
                                            child: const Icon(Icons.directions_bus, color: Color.fromARGB(128, 255, 82, 82), size: 120, blendMode: BlendMode.plus),
                                        )
                                    ),
                                ])
                        ),
                        ListTile(
                            title: const Text('Acerca de...'),
                            onTap: () {
                                Navigator.of(context).push(
                                    MaterialPageRoute(
                                        builder: (_) => const AboutPage()
                                    )
                                );
                            },
                        ),
                        /*ListTile(
                            title: const Text('Atras'),
                            onTap: () {
                                Navigator.pop(context);
                            },
                        ),*/
                    ],
                ),
            ),
        );
    }

    Future<void> _dialogBuilder(BuildContext context) {
        return showDialog<void>(
            context: context,
            useSafeArea: false,
            barrierDismissible: false,
            useRootNavigator: true,
            builder: (BuildContext context) {
                // return AlertDialog(
                //     title: const Text('Error'),
                //     content: const Text('No se pudo obtener la información de la ruta.'),
                //     actions: <Widget>[
                //         TextButton(
                //             child: const Text('Aceptar'),
                //             onPressed: () {
                //                 Navigator.of(context).pop();
                //             },
                //         ),
                //     ],
                // );
                return Container(
                    width: MediaQuery.of(context).size.width,
                    height: MediaQuery.of(context).size.height,
                    color: Colors.black54,
                    child: const Center(
                        child: CircularProgressIndicator(
                            color: Colors.grey,
                        )
                    )
                );
            },
        );
    }
}

class CustomDraggableScroll extends StatelessWidget {
    const CustomDraggableScroll({
        super.key,
    });

    // final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

    @override
    Widget build(BuildContext context) {
        return DraggableScrollableSheet(
            minChildSize: 0.1,
            initialChildSize: 0.35,
            builder: (BuildContext context, ScrollController scrollController) {
                return Container(
                    clipBehavior: Clip.hardEdge,
                    decoration: const BoxDecoration(
                        // color: Theme.of(context).canvasColor,
                        color: Colors.white,
                        borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(25),
                            topRight: Radius.circular(25),
                        ),
                    ),
                    child: CustomScrollView(
                        controller: scrollController,
                        slivers: [
                            SliverToBoxAdapter(
                                child: Center(
                                    child: Container(
                                        decoration: BoxDecoration(
                                            color: Theme.of(context).hintColor,
                                            // color: Colors.white,
                                            borderRadius: const BorderRadius.all(Radius.circular(10)),
                                        ),
                                        height: 4,
                                        width: 40,
                                        margin: const EdgeInsets.symmetric(vertical: 10),
                                    ),
                                ),
                            ),
                            SliverToBoxAdapter(
                                child: Navigator(
                                    onGenerateRoute: (settings) {
                                        return MaterialPageRoute(
                                            builder: (context) => const ReportsListPage(),
                                        );
                                    },
                                )
                            )
                        ]
                    )
                );
            }
        );
    }
}
