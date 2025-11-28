import 'package:DIAPotholeReporter1/models/RouteGroupModel.dart';
import 'package:flutter/material.dart';

import '../pages/RouteGroupDetailsPage.dart';

class RouteGroupListWidget extends StatelessWidget {
    final RouteGroupModel routeGroupModel;

    const RouteGroupListWidget({
        super.key,
        required this.routeGroupModel
    });

    @override
    Widget build(BuildContext context) {
        // return ListTile(
        //     title: Text(routeGroupModel.name),
        //     subtitle: Text(routeGroupModel.description),
        // );
        return ListTile(
            onTap: () {
                print(routeGroupModel);
                Navigator.of(context).push(
                    MaterialPageRoute(
                        builder: (_) => RouteGroupDetailPage(routeGroupModel: routeGroupModel)
                    )
                );
            },
            title: Text(routeGroupModel.name),
            subtitle: Text(routeGroupModel.description),
            leading: FittedBox(
                child: Container(
                    width: 30,
                    height: 30,
                    constraints: const BoxConstraints(minWidth: 30, minHeight: 30, maxWidth: 30, maxHeight: 30),
                    decoration: const BoxDecoration(
                        color: Colors.white,
                        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2))],
                    ),
                    child: Row(
                        children: (routeGroupModel.colors == null && routeGroupModel.colors!.isEmpty)
                            ? []
                            : _colorWidgets(routeGroupModel.colors!),
                    ),
                ),
            ),
            trailing: const Icon(
                Icons.arrow_forward_ios,
                size: 15,
            ),
            visualDensity: VisualDensity.compact,
            contentPadding: EdgeInsets.zero,
        );
            /* child: Row(
                children: [
                    Container(
                        width: 30,
                        height: 30,
                        decoration: const BoxDecoration(
                            color: Colors.white,
                            boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2))],
                        ),
                    ),
                    const SizedBox(width: 15),
                    Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                            Text(
                                routeGroupModel.name,
                                style: const TextStyle(
                                    fontSize: 14
                                )
                            ),
                            ConstrainedBox(
                                constraints: BoxConstraints(
                                    maxWidth: MediaQuery.of(context).size.width - 100
                                ),
                                child: Text(
                                    routeGroupModel.description,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                        fontSize: 12
                                    )
                                )
                            )
                        ]
                    )
                ]
            )*/
    }

    List<Widget> _colorWidgets(List<String> colors) {
        return colors.map((color) {
                late int colorValue;
                try {
                    colorValue = int.parse("0xFF$color");
                }
                catch(e) {
                    colorValue = 0xFF000000;
                }
                return Container(
                    width: 30/colors.length,
                    height: 30,
                    color: Color(colorValue),
                );
            }
        ).toList();
    }
}

