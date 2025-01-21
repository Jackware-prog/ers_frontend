import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:async';

class RealTimeService {
  static final RealTimeService _instance = RealTimeService._internal();
  factory RealTimeService() => _instance;
  RealTimeService._internal();

  final _client = Supabase.instance.client;

  // Streams for real-time data
  final StreamController<Map<String, dynamic>> _caseHandlingController =
      StreamController.broadcast();
  final StreamController<Map<String, dynamic>> _emergencyController =
      StreamController.broadcast();
  final StreamController<Map<String, dynamic>> _caseLogController =
      StreamController.broadcast();

  Stream<Map<String, dynamic>> get caseHandlingStream =>
      _caseHandlingController.stream;
  Stream<Map<String, dynamic>> get emergencyStream =>
      _emergencyController.stream;
  Stream<Map<String, dynamic>> get caseLogStream => _caseLogController.stream;

  void initializeSubscriptions() {
    // Subscribe to case_handling table
    final caseHandlingChannel = _client.channel('case_handling_changes');
    caseHandlingChannel
        .onPostgresChanges(
          event: PostgresChangeEvent.all, // Listen for INSERT, UPDATE, DELETE
          schema: 'public',
          table: 'casehandling',
          callback: (payload) {
            final event = payload.eventType;
            final data = payload.newRecord;
            _caseHandlingController.add({'event': event, ...data});
          },
        )
        .subscribe();

    // Subscribe to emergency table
    final emergencyChannel = _client.channel('emergency_changes');
    emergencyChannel
        .onPostgresChanges(
          event: PostgresChangeEvent.all, // Listen for INSERT, UPDATE, DELETE
          schema: 'public',
          table: 'emergency',
          callback: (payload) {
            final event = payload.eventType;
            final data = payload.newRecord;
            _emergencyController.add({'event': event, ...data});
          },
        )
        .subscribe();

    // Subscribe to case_log table
    final caseLogChannel = _client.channel('caselog_changes');
    caseLogChannel
        .onPostgresChanges(
          event: PostgresChangeEvent.all, // Listen for INSERT, UPDATE, DELETE
          schema: 'public',
          table: 'caselog',
          callback: (payload) {
            final event = payload.eventType;
            final data = payload.newRecord;
            _caseLogController.add({'event': event, ...data});
          },
        )
        .subscribe();
  }

  void dispose() {
    _caseHandlingController.close();
    _emergencyController.close();
    _caseLogController.close();
  }
}
