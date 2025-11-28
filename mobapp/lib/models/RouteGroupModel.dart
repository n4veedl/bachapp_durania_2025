
import 'dart:convert';

class RouteGroupModel {

    late String id;

    // late int cityId;
    late String name;
    late String description;
    late String version;
    List<String>? colors;
    late List<Map<String, dynamic>>? routes;
    String? deletedAt;

    RouteGroupModel({
        required this.id,
        // required this.cityId,
        required this.name,
        required this.description,
        required this.version,
        this.colors,
        this.routes,
        this.deletedAt,
    });

    factory RouteGroupModel.fromJson(Map<String, dynamic> json) {
        return RouteGroupModel(
            id: json['id'],
            // cityId: json['city_id'],
            name: json['name'],
            description: json['description'],
            version: json['version'],
            colors: json['colors'] == null ? [] : List<String>.from(jsonDecode(json['colors'])),
            // check if routes is empty
            routes: json['routes'] == null ? [] : List<Map<String, dynamic>>.from(json['routes']),
            deletedAt: json['deleted_at'],
        );
    }

    Map<String, dynamic> toJson() {
        final Map<String, dynamic> data = <String, dynamic>{};
        data['id'] = id;
        // data['city_id'] = this.cityId;
        data['name'] = name;
        data['description'] = description;
        data['version'] = version;
        data['colors'] = colors;
        data['routes'] = routes;
        data['deleted_at'] = deletedAt;
        return data;
    }

    @override
    String toString() {
        return 'RouteGroupModel{id: $id, name: $name, description: $description, version: $version, colors: $colors, routes: $routes, deletedAt: $deletedAt}';
    }
}
