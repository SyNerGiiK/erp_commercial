import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import '../models/client_model.dart';
import '../viewmodels/client_viewmodel.dart';
import '../widgets/base_screen.dart';
import '../widgets/custom_text_field.dart';
import '../config/theme.dart';
import 'detail_client_view.dart'; // Pour l'intégration des détails si besoin, ou navigation

class AjoutClientView extends StatefulWidget {
  final String? id;
  final Client? clientAModifier;
  const AjoutClientView({super.key, this.id, this.clientAModifier});

  @override
  State<AjoutClientView> createState() => _AjoutClientViewState();
}

class _AjoutClientViewState extends State<AjoutClientView> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = true;

  String _typeClient = 'particulier';

  late TextEditingController _nomController;
  late TextEditingController _contactController;
  late TextEditingController _siretController;
  late TextEditingController _tvaController;

  late TextEditingController _adresseController;
  late TextEditingController _cpController;
  late TextEditingController _villeController;
  late TextEditingController _telController;
  late TextEditingController _emailController;
  late TextEditingController _notesController;

  @override
  void initState() {
    super.initState();
    _nomController = TextEditingController();
    _contactController = TextEditingController();
    _siretController = TextEditingController();
    _tvaController = TextEditingController();
    _adresseController = TextEditingController();
    _cpController = TextEditingController();
    _villeController = TextEditingController();
    _telController = TextEditingController();
    _emailController = TextEditingController();
    _notesController = TextEditingController();

    _loadData();
  }

  Future<void> _loadData() async {
    Client? c = widget.clientAModifier;

    // F5 Refresh Logic
    if (c == null && widget.id != null) {
      final vm = Provider.of<ClientViewModel>(context, listen: false);
      if (vm.clients.isEmpty) await vm.fetchClients();
      try {
        c = vm.clients.firstWhere((element) => element.id == widget.id);
      } catch (_) {}
    }

    if (c != null) {
      _typeClient = c.typeClient;
      _nomController.text = c.nomComplet;
      _contactController.text = c.nomContact ?? "";
      _siretController.text = c.siret ?? "";
      _tvaController.text = c.tvaIntra ?? "";
      _adresseController.text = c.adresse;
      _cpController.text = c.codePostal;
      _villeController.text = c.ville;
      _telController.text = c.telephone;
      _emailController.text = c.email;
      _notesController.text = c.notesPrivees ?? "";
    }

    if (mounted) setState(() => _isLoading = false);
  }

  @override
  void dispose() {
    _nomController.dispose();
    _contactController.dispose();
    _siretController.dispose();
    _tvaController.dispose();
    _adresseController.dispose();
    _cpController.dispose();
    _villeController.dispose();
    _telController.dispose();
    _emailController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _sauvegarder() async {
    if (_formKey.currentState!.validate()) {
      final newClient = Client(
        id: widget.id ?? widget.clientAModifier?.id,
        userId: widget.clientAModifier?.userId,
        nomComplet: _nomController.text,
        typeClient: _typeClient,
        nomContact:
            _contactController.text.isEmpty ? null : _contactController.text,
        siret: _siretController.text.isEmpty ? null : _siretController.text,
        tvaIntra: _tvaController.text.isEmpty ? null : _tvaController.text,
        adresse: _adresseController.text,
        codePostal: _cpController.text,
        ville: _villeController.text,
        telephone: _telController.text,
        email: _emailController.text,
        notesPrivees: _notesController.text,
      );

      final vm = Provider.of<ClientViewModel>(context, listen: false);
      bool success;
      if (newClient.id == null) {
        success = await vm.addClient(newClient);
      } else {
        success = await vm.updateClient(newClient);
      }

      if (mounted && success) {
        context.pop();
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Client enregistré avec succès")));
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Erreur lors de l'enregistrement")));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    // Si on est en mode édition, on peut vouloir afficher le détail complet
    // Mais pour simplifier l'édition, on reste sur ce formulaire.
    // Pour voir les détails (photos, historique), on pourrait ajouter un bouton.

    // Si l'utilisateur veut voir le détail complet (Dashboard client), on peut l'intégrer
    // ici via un TabBar ou rediriger. Pour l'instant, on garde le mode Formulaire pur.
    // Si c'est une modification existante, on affiche l'onglet détail en dessous ou on
    // redirige vers DetailClientView.

    // Pour cette version V3, si un ID existe, on affiche le formulaire d'édition.
    // Mais on peut inclure DetailClientView comme un "Viewer" si on veut.
    // Restons simple : Formulaire d'édition.
    // Pour voir le détail, on peut imaginer une autre route '/client/:id' qui affiche DetailClientView
    // et qui a un bouton "Modifier" qui mène ici.
    // Mais dans notre router actuel, la liste mène ici.
    // Donc on va ajouter un bouton "VOIR DOSSIER COMPLET" si l'ID existe.

    final isPro = _typeClient == 'professionnel';

    return BaseScreen(
      title: widget.id == null ? "Nouveau Client" : "Modifier Client",
      child: Column(
        children: [
          if (widget.id != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  icon: const Icon(Icons.folder_shared),
                  label: const Text(
                      "VOIR DOSSIER COMPLET (Historique, Photos...)"),
                  onPressed: () {
                    // Astuce: On utilise le widget DetailClientView directement ici dans une modale ou nouvelle page
                    // Mais comme on est déjà dans une page, le mieux est de push une nouvelle route si on l'avait définie.
                    // Ici on va afficher DetailClientView en full screen modal pour l'exemple
                    Navigator.push(context, MaterialPageRoute(builder: (c) {
                      // On doit reconstruire l'objet client à jour
                      final c = Client(
                          id: widget.id,
                          userId: widget.clientAModifier?.userId,
                          nomComplet: _nomController.text,
                          adresse: _adresseController.text,
                          codePostal: _cpController.text,
                          ville: _villeController.text,
                          telephone: _telController.text,
                          email: _emailController.text,
                          typeClient: _typeClient,
                          nomContact: _contactController.text,
                          siret: _siretController.text,
                          tvaIntra: _tvaController.text,
                          notesPrivees: _notesController.text);
                      return DetailClientView(client: c);
                    }));
                  },
                ),
              ),
            ),
          Expanded(
            child: Form(
              key: _formKey,
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                            child: _buildTypeButton(
                                "Particulier", "particulier", Icons.person)),
                        const SizedBox(width: 16),
                        Expanded(
                            child: _buildTypeButton("Professionnel",
                                "professionnel", Icons.business)),
                      ],
                    ),
                    const SizedBox(height: 20),
                    CustomTextField(
                      label: isPro ? "Raison Sociale" : "Nom & Prénom",
                      controller: _nomController,
                      icon: isPro ? Icons.store : Icons.person,
                      validator: (v) => v!.isEmpty ? "Requis" : null,
                    ),
                    const SizedBox(height: 16),
                    if (isPro) ...[
                      CustomTextField(
                        label: "Nom du contact (Interlocuteur)",
                        controller: _contactController,
                        icon: Icons.badge,
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                              child: CustomTextField(
                                  label: "SIRET",
                                  controller: _siretController)),
                          const SizedBox(width: 16),
                          Expanded(
                              child: CustomTextField(
                                  label: "TVA Intra",
                                  controller: _tvaController)),
                        ],
                      ),
                      const SizedBox(height: 16),
                    ],
                    const Text("Coordonnées",
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: AppTheme.primary)),
                    const SizedBox(height: 10),
                    CustomTextField(
                      label: "Adresse",
                      controller: _adresseController,
                      icon: Icons.location_on,
                      validator: (v) => v!.isEmpty ? "Requis" : null,
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        SizedBox(
                          width: 100,
                          child: CustomTextField(
                            label: "Code Postal",
                            controller: _cpController,
                            keyboardType: TextInputType.number,
                            validator: (v) => v!.isEmpty ? "Requis" : null,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: CustomTextField(
                            label: "Ville",
                            controller: _villeController,
                            validator: (v) => v!.isEmpty ? "Requis" : null,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    CustomTextField(
                      label: "Téléphone",
                      controller: _telController,
                      keyboardType: TextInputType.phone,
                      icon: Icons.phone,
                      validator: (v) => v!.isEmpty ? "Requis" : null,
                    ),
                    const SizedBox(height: 10),
                    CustomTextField(
                      label: "Email",
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      icon: Icons.email,
                      validator: (v) => v!.isEmpty ? "Requis" : null,
                    ),
                    const SizedBox(height: 20),
                    CustomTextField(
                      label: "Notes privées",
                      controller: _notesController,
                      maxLines: 3,
                      icon: Icons.note,
                    ),
                    const SizedBox(height: 30),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _sauvegarder,
                        child: const Text("ENREGISTRER"),
                      ),
                    ),
                    const SizedBox(height: 50),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTypeButton(String label, String value, IconData icon) {
    bool isSelected = _typeClient == value;
    return GestureDetector(
      onTap: () => setState(() => _typeClient = value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primary : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
              color: isSelected ? AppTheme.primary : Colors.grey.shade300,
              width: 2),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                      color: AppTheme.primary.withValues(alpha: 0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 4))
                ]
              : [],
        ),
        child: Column(
          children: [
            Icon(icon,
                color: isSelected ? Colors.white : Colors.grey, size: 28),
            const SizedBox(height: 8),
            Text(label,
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: isSelected ? Colors.white : Colors.grey)),
          ],
        ),
      ),
    );
  }
}
