
class DraftReportModel {
  String? location;
  double? lat;
  double? lon;
  String? severity;
  String? description;
  List<dynamic>? images;
  bool isInLocation = false;
  double? currentLat;
  double? currentLon;
  bool anonymous = true;
  String? userId;

  DraftReportModel({
    this.location,
    this.lat,
    this.lon,
    this.severity,
    this.description,
    this.images,
    this.isInLocation = false,
    this.currentLat,
    this.currentLon,
    this.anonymous = true,
    this.userId
  });

  DraftReportModel.fromJson(Map<String, dynamic> json) {
    location = json['location'];
    lat = json['lat'];
    lon = json['lon'];
    severity = json['severity'];
    description = json['description'];
    images = json['images'];
    isInLocation = json['isInLocation'] ?? false;
    currentLat = json['currentLat'];
    currentLon = json['currentLon'];
    anonymous = json['anonymous'] ?? true;
    userId = json['userId'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['location'] = location;
    data['lat'] = lat;
    data['lon'] = lon;
    data['severity'] = severity;
    data['description'] = description;
    data['images'] = images;
    data['isInLocation'] = isInLocation;
    data['currentLat'] = currentLat;
    data['currentLon'] = currentLon;
    data['anonymous'] = anonymous;
    data['userId'] = userId;
    return data;
  }

  @override
  String toString() {
    return 'DraftReportModel{location: $location, lat: $lat, lon: $lon, severity: $severity, description: $description, images: $images, isInLocation: $isInLocation, currentLat: $currentLat, currentLon: $currentLon, anonymous: $anonymous, userId: $userId}';
  }
}