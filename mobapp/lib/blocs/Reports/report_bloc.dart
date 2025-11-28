import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:uuid/uuid.dart';

import '../../models/ReportModel.dart';

part 'report_event.dart';
part 'report_state.dart';

class ReportBloc extends Bloc<ReportEvent, ReportState> {
  ReportBloc() : super(ReportInitial()) {
    on<GetReports>(_onGetReports);
    on<CreateReport>(_onCreateReport);
  }

  FutureOr<void> _onGetReports(
    GetReports event, 
    Emitter<ReportState> emit
  ) async {
    emit(ReportsLoading());
    try {
      // TODO: Replace with actual API call
      await Future.delayed(const Duration(seconds: 1));
      emit(ReportsLoaded(reports: const []));
    } catch (e) {
      emit(ReportsError(message: 'Failed to load reports: $e'));
    }
  }

  FutureOr<void> _onCreateReport(
    CreateReport event,
    Emitter<ReportState> emit,
  ) async {
    emit(ReportCreating());
    try {
      // TODO: Replace with actual API call
      await Future.delayed(const Duration(seconds: 1));
      
      // Convert severity string to enum
      final severity = _mapSeverityStringToEnum(event.severity);
      
      // Create new report
      final newReport = ReportModel(
        id: const Uuid().v4(),
        location: event.location ?? 'Unknown location',
        severity: severity,
        description: event.description,
        images: event.imagePaths?.asMap().map((index, path) => 
          MapEntry('image_$index', path)
        ),
        createdAt: DateTime.now().toIso8601String(),
      );

      emit(ReportsLoaded(reports: [...?event.prevState?.reports, newReport]));
    } catch (e) {
      emit(CreateReportError(message: 'Failed to create report: $e'));
    }
  }

  ReportSeverity _mapSeverityStringToEnum(String severity) {
    switch (severity) {
      case 'media':
        return ReportSeverity.low;
      case 'grave':
        return ReportSeverity.medium;
      case 'muy_grave':
        return ReportSeverity.high;
      default:
        return ReportSeverity.none;
    }
  }
}
