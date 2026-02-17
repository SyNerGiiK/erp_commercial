import 'dart:developer' as developer;
import '../models/planning_model.dart';
import '../core/base_repository.dart';

abstract class IPlanningRepository {
  Future<List<PlanningEvent>> getManualEvents();
  Future<void> addEvent(PlanningEvent event);
  Future<void> updateEvent(PlanningEvent event);
  Future<void> deleteEvent(String id);
}

class PlanningRepository extends BaseRepository implements IPlanningRepository {
  @override
  Future<List<PlanningEvent>> getManualEvents() async {
    try {
      final response =
          await client.from('plannings').select().eq('user_id', userId);

      return (response as List).map((e) => PlanningEvent.fromMap(e)).toList();
    } catch (e) {
      throw handleError(e, 'getManualEvents');
    }
  }

  @override
  Future<void> addEvent(PlanningEvent event) async {
    try {
      final data = prepareForInsert(event.toMap());
      await client.from('plannings').insert(data);
    } catch (e) {
      throw handleError(e, 'addEvent');
    }
  }

  @override
  Future<void> updateEvent(PlanningEvent event) async {
    if (event.id == null) return;
    try {
      final data = prepareForUpdate(event.toMap());
      await client.from('plannings').update(data).eq('id', event.id!);
    } catch (e) {
      throw handleError(e, 'updateEvent');
    }
  }

  @override
  Future<void> deleteEvent(String id) async {
    try {
      await client.from('plannings').delete().eq('id', id);
    } catch (e) {
      throw handleError(e, 'deleteEvent');
    }
  }
}
