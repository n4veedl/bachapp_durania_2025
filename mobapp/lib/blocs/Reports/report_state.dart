part of 'report_bloc.dart';

@immutable
sealed class ReportState {}

final class ReportInitial extends ReportState {}

// States for getting reports
final class ReportsLoading extends ReportState {}

final class ReportsLoaded extends ReportState {
  final List<ReportModel> reports;

  ReportsLoaded({required this.reports});
}

// States for creating reports
final class ReportCreating extends ReportState {}

final class ReportCreated extends ReportState {
  final ReportModel report;

  ReportCreated({required this.report});
}

// Error states
final class ReportError extends ReportState {
  final String message;

  ReportError({required this.message});
}

final class ReportsError extends ReportError {
  ReportsError({required super.message});
}

final class CreateReportError extends ReportError {
  CreateReportError({required super.message});
}
