import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:developer' as developer;

import '../models/planning_model.dart';
import '../config/supabase_config.dart';

abstract class IPlanningRepository {
  Future<List<PlanningEvent>> getManualEvents();
  Future<void> addEvent(PlanningEvent event);
  Future<void> updateEvent(PlanningEvent event);
  Future<void> deleteEvent(String id);
}

class PlanningRepository implements IPlanningRepository {
  final SupabaseClient _client = SupabaseConfig.client;

  @override
  Future<List<PlanningEvent>> getManualEvents() async {
    try {
      final userId = SupabaseConfig.userId;
      final response =
          await _client.from('plannings').select().eq('user_id', userId);

      return (response as List).map((e) => PlanningEvent.fromMap(e)).toList();
    } catch (e) {
      throw _handleError(e, 'getManualEvents');
    }
  }

  @override
  Future<void> addEvent(PlanningEvent event) async {
    try {
      final userId = SupabaseConfig.userId;
      final data = event.toMap();
      data['user_id'] = userId;
      data.remove('id');

      await _client.from('plannings').insert(data);
    } catch (e) {
      throw _handleError(e, 'addEvent');
    }
  }

  @override
  Future<void> updateEvent(PlanningEvent event) async {
    if (event.id == null) return;
    try {
      final data = event.toMap();
      data.remove('user_id'); // Sécurité RLS

      await _client.from('plannings').update(data).eq('id', event.id!);
    } catch (e) {
      throw _handleError(e, 'updateEvent');
    }
  }

  @override
  Future<void> deleteEvent(String id) async {
    try {
      await _client.from('plannings').delete().eq('id', id);
    } catch (e) {
      throw _handleError(e, 'deleteEvent');
    }
  }

  Exception _handleError(Object error, String method) {
    developer.log("🔴 PlanningRepo Error ($method)", error: error);
    return Exception("Erreur Planning ($method): $error");
  }
}
