import 'package:flutter/material.dart';

class AboutPage extends StatelessWidget {
    const AboutPage({super.key});

    @override
    Widget build(BuildContext context) {
        return  Scaffold(
            backgroundColor: Colors.black,
            appBar: AppBar(
                title: const Text('Acerca de...', style: TextStyle(color: Colors.white)),
                backgroundColor: Colors.black,
                iconTheme: const IconThemeData(color: Colors.white),
            ),
            body: const Center(
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                        Text('DIAPotholeReporter1', style: TextStyle(color: Colors.white, fontSize: 30)),
                        Icon(Icons.directions_bus, color: Colors.white, size: 100),
                        SizedBox(height: 40,),
                        Text(
                            'App hecha con <3',
                            style: TextStyle(color: Colors.white, fontSize: 20)
                        ),
                        SizedBox(height: 20,),
                        Text(
                            'Eznihcitos',
                            style: TextStyle(color: Colors.white, fontSize: 16)
                        ),
                    ],
                )
            )
        );
    }
}
