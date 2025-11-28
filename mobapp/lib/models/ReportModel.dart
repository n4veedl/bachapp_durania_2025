
class ReportModel {
  late String id;
  String? location;
  ReportSeverity severity = ReportSeverity.none;
  String? description;
  late Map<String, String>? images;
  String? createdAt;
  String? deletedAt;

  ReportModel({
    required this.id,
    this.location,
    this.severity = ReportSeverity.none,
    this.description,
    this.images,
    this.createdAt,
    this.deletedAt
  });

  ReportModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    location = json['location'];
    // severity = ReportSeverity.values[json['severity']];
    severity = json['severity'] == 0 ? ReportSeverity.none
        : json['severity'] == 1 ? ReportSeverity.low
        : json['severity'] == 2 ? ReportSeverity.medium
        : ReportSeverity.high;
    description = json['description'];
    images = json['images'];
    createdAt = json['created_at'];
    deletedAt = json['deleted_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['location'] = location;
    data['severity'] = severity.index;
    data['description'] = description;
    data['images'] = images;
    data['created_at'] = createdAt;
    return data;
  }

  @override
  String toString() {
    return 'ReportModel{id: $id, location: $location, severity: $severity, description: $description, images: $images, deletedAt: $deletedAt}';
  }
}

enum ReportSeverity {
  none,
  low,
  medium,
  high
}