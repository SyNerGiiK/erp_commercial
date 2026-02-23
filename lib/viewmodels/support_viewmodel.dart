import '../models/support_ticket_model.dart';
import '../repositories/support_repository.dart';
import '../core/base_viewmodel.dart';
import 'dart:developer' as developer;

class SupportViewModel extends BaseViewModel {
  final ISupportRepository _repository;
  List<SupportTicket> _tickets = [];

  SupportViewModel({ISupportRepository? repository})
      : _repository = repository ?? SupportRepository();

  List<SupportTicket> get tickets => _tickets;

  Future<void> fetchTickets() async {
    await execute(() async {
      _tickets = await _repository.getTickets();
    });
  }

  Future<bool> createTicket(SupportTicket ticket) async {
    return await executeOperation(() async {
      await _repository.createTicket(ticket);
      await fetchTickets(); // Refresh list to get the AI resolution eventually if real-time, but here it's immediate
    });
  }
}
