import 'dart:developer' as developer;
import 'package:flutter/foundation.dart';
import '../models/devis_model.dart';
import '../repositories/devis_repository.dart';

class DevisViewModel extends ChangeNotifier {
  final IDevisRepository _repository = DevisRepository();

  List<Devis> _devis = [];
  List<Devis> _archives = [];

  List<Devis> get devis => _devis;
  List<Devis> get archives => _archives;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  Future<void> fetchDevis() async {
    await _executeOperation(() async {
      _devis = await _repository.getDevis(archives: false);
    });
  }

  Future<void> fetchArchives() async {
    await _executeOperation(() async {
      _archives = await _repository.getDevis(archives: true);
    });
  }

  Future<bool> addDevis(Devis devis) async {
    return await _executeOperation(() async {
      await _repository.createDevis(devis);
      await fetchDevis();
    });
  }

  Future<bool> updateDevis(Devis devis) async {
    return await _executeOperation(() async {
      await _repository.updateDevis(devis);
      await fetchDevis();
    });
  }

  Future<bool> finaliserDevis(Devis devis) async {
    if (devis.id == null) return false;
    return await _executeOperation(() async {
      final annee = DateTime.now().year;
      final newNumero = await _repository.generateNextNumero(annee);
      await _repository.finalizeDevis(devis.id!, newNumero);
      await fetchDevis();
    });
  }

  Future<void> deleteDevis(String id) async {
    await _executeOperation(() async {
      await _repository.deleteDevis(id);
      await fetchDevis();
    });
  }

  Future<void> toggleArchive(Devis devis, bool archiver) async {
    if (devis.id == null) return;
    await _executeOperation(() async {
      await _repository.toggleArchive(devis.id!, archiver);
      await fetchDevis();
      await fetchArchives();
    });
  }

  Future<bool> markAsSigned(Devis devis, String? signatureUrl) async {
    if (devis.id == null) return false;
    return await _executeOperation(() async {
      await _repository.markAsSigned(devis.id!, signatureUrl);
      await fetchDevis();
    });
  }

  Future<bool> _executeOperation(Future<void> Function() operation) async {
    _isLoading = true;
    notifyListeners();
    try {
      await operation();
      return true;
    } catch (e) {
      developer.log("🔴 DevisVM Error", error: e);
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
