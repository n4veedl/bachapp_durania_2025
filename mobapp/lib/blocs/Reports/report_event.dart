part of 'report_bloc.dart';

@immutable
sealed class ReportEvent {}

class GetReports extends ReportEvent {}

class CreateReport extends ReportEvent {
  final String? location;
  final String severity;
  final String? description;
  final List<String>? imagePaths;

  // delete me later
  final ReportsLoaded? prevState;

  CreateReport({
    this.location,
    required this.severity,
    this.description,
    this.imagePaths,
    this.prevState,
  });
}