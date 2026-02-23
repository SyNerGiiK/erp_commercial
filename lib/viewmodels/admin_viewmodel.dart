import 'package:supabase_flutter/supabase_flutter.dart';
import '../config/supabase_config.dart';
import '../core/base_viewmodel.dart';
import 'dart:developer' as developer;

class AdminViewModel extends BaseViewModel {
  Map<String, dynamic>? _dbMetrics;
  List<Map<String, dynamic>> _tickets = [];
  List<Map<String, dynamic>> _crashLogs = [];

  Map<String, dynamic>? get dbMetrics => _dbMetrics;
  List<Map<String, dynamic>> get tickets => _tickets;
  List<Map<String, dynamic>> get crashLogs => _crashLogs;

  AdminViewModel() {
    refreshAll();
  }

  Future<void> refreshAll() async {
    await executeOperation(() async {
      await Future.wait([
        _fetchMetrics(),
        _fetchTickets(),
        _fetchCrashLogs(),
      ]);
    });
  }

  Future<void> _fetchMetrics() async {
    try {
      final response = await SupabaseConfig.client.rpc('get_db_metrics');
      _dbMetrics = response as Map<String, dynamic>;
    } catch (e) {
      developer.log('Erreur fetch metrics : $e');
    }
  }

  Future<void> _fetchTickets() async {
    try {
      final response = await SupabaseConfig.client
          .from('support_tickets')
          .select('*, auth.users(email)')
          .order('created_at', ascending: false);
      _tickets = List<Map<String, dynamic>>.from(response);
    } catch (e) {
      developer.log('Erreur fetch tickets : $e');
    }
  }

  Future<void> _fetchCrashLogs() async {
    try {
      final response = await SupabaseConfig.client
          .from('crash_logs')
          .select('*')
          .order('created_at', ascending: false)
          .limit(50);
      _crashLogs = List<Map<String, dynamic>>.from(response);
    } catch (e) {
      developer.log('Erreur fetch crash logs : $e');
    }
  }

  Future<void> updateTicketStatus(String id, String status) async {
    try {
      await SupabaseConfig.client
          .from('support_tickets')
          .update({'statut': status}).eq('id', id);
      await _fetchTickets();
      notifyListeners();
    } catch (e) {
      developer.log('Erreur update ticket statut : $e');
    }
  }

  Future<void> resolveCrashLog(String id) async {
    try {
      await SupabaseConfig.client
          .from('crash_logs')
          .update({'resolved': true}).eq('id', id);
      await _fetchCrashLogs();
      notifyListeners();
    } catch (e) {
      developer.log('Erreur resolve crash log: $e');
    }
  }
}
