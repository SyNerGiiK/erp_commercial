import '../models/support_ticket_model.dart';
import '../core/base_repository.dart';

abstract class ISupportRepository {
  Future<List<SupportTicket>> getTickets();
  Future<SupportTicket> createTicket(SupportTicket ticket);
}

class SupportRepository extends BaseRepository implements ISupportRepository {
  @override
  Future<List<SupportTicket>> getTickets() async {
    try {
      final response = await client
          .from('support_tickets')
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      return (response as List).map((e) => SupportTicket.fromMap(e)).toList();
    } catch (e) {
      throw handleError(e, 'getTickets');
    }
  }

  @override
  Future<SupportTicket> createTicket(SupportTicket ticket) async {
    try {
      final data = prepareForInsert(ticket.toMap());
      final response =
          await client.from('support_tickets').insert(data).select().single();

      final createdTicket = SupportTicket.fromMap(response);

      // Invoke the Edge Function directly from the client to avoid pg_net issues
      try {
        await client.functions.invoke('ai_support_triage', body: {
          'record': {
            'id': createdTicket.id,
            'subject': createdTicket.subject,
            'description': createdTicket.description
          }
        });
      } catch (funcErr) {
        // We log the function error but still return the created ticket so the UI doesn't crash
        // The ticket just won't have an AI resolution yet.
        print('Edge Function invoke error: $funcErr');
      }

      return createdTicket;
    } catch (e) {
      throw handleError(e, 'createTicket');
    }
  }
}
