import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:image_picker/image_picker.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../config/theme.dart';
import '../models/client_model.dart';
import '../viewmodels/client_viewmodel.dart';

import '../widgets/base_screen.dart';

class DetailClientView extends StatefulWidget {
  final Client client;
  const DetailClientView({super.key, required this.client});

  @override
  State<DetailClientView> createState() => _DetailClientViewState();
}

class _DetailClientViewState extends State<DetailClientView>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 1, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.client.id != null) {
        Provider.of<ClientViewModel>(context, listen: false)
            .fetchPhotos(widget.client.id!);
      }
    });
  }

  // --- ACTIONS SÉCURISÉES ---

  Future<void> _makeCall() async {
    if (widget.client.telephone.isEmpty) return;
    final Uri launchUri = Uri(scheme: 'tel', path: widget.client.telephone);
    await _launchSecurely(launchUri);
  }

  Future<void> _sendEmail() async {
    if (widget.client.email.isEmpty) return;
    final Uri launchUri = Uri(scheme: 'mailto', path: widget.client.email);
    await _launchSecurely(launchUri);
  }

  Future<void> _openMap() async {
    final query =
        Uri.encodeComponent("${widget.client.adresse}, ${widget.client.ville}");
    final Uri launchUri =
        Uri.parse("https://www.google.com/maps/search/?api=1&query=$query");
    await _launchSecurely(launchUri, mode: LaunchMode.externalApplication);
  }

  Future<void> _launchSecurely(Uri uri,
      {LaunchMode mode = LaunchMode.platformDefault}) async {
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: mode);
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content:
                    Text("Impossible d'ouvrir l'application correspondante")),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Erreur système: $e")),
        );
      }
    }
  }

  Future<void> _takePhoto() async {
    if (widget.client.id == null) return;
    final XFile? photo = await _picker.pickImage(source: ImageSource.camera);
    if (photo != null && mounted) {
      final success = await Provider.of<ClientViewModel>(context, listen: false)
          .uploadPhoto(widget.client.id!, photo);
      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Photo ajoutée au dossier !")));
      }
    }
  }

  void _zoomPhoto(BuildContext context, String url) {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: EdgeInsets.zero,
        child: Stack(
          alignment: Alignment.center,
          children: [
            InteractiveViewer(
              minScale: 0.5,
              maxScale: 4.0,
              child: Image.network(url),
            ),
            Positioned(
              top: 20,
              right: 20,
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.white, size: 30),
                onPressed: () => Navigator.pop(ctx),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final vm = Provider.of<ClientViewModel>(context);

    return BaseScreen(
      title: widget.client.nomComplet,
      subtitle: widget.client.ville,
      headerActions: [
        IconButton(
          icon: const Icon(Icons.edit),
          tooltip: "Modifier",
          onPressed: () => context.push('/ajout_client/${widget.client.id}',
              extra: widget.client),
        )
      ],
      child: Column(
        children: [
          // Carte Contact Rapide
          Card(
            margin: const EdgeInsets.only(bottom: 20),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  _buildContactRow(
                      Icons.phone, widget.client.telephone, _makeCall),
                  const Divider(),
                  _buildContactRow(
                      Icons.email, widget.client.email, _sendEmail),
                  const Divider(),
                  _buildContactRow(
                      Icons.location_on,
                      "${widget.client.adresse}, ${widget.client.ville}",
                      _openMap),
                ],
              ),
            ),
          ),

          // Onglets
          Container(
            color: Colors.white,
            child: TabBar(
              controller: _tabController,
              labelColor: AppTheme.primary,
              unselectedLabelColor: Colors.grey,
              indicatorColor: AppTheme.primary,
              tabs: const [
                Tab(text: "PHOTOS CHANTIER"),
              ],
            ),
          ),

          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // Galerie Photos
                Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: ElevatedButton.icon(
                        onPressed: _takePhoto,
                        icon: const Icon(Icons.camera_alt),
                        label: const Text("AJOUTER UNE PHOTO"),
                      ),
                    ),
                    Expanded(
                      child: vm.isLoading
                          ? const Center(child: CircularProgressIndicator())
                          : vm.photos.isEmpty
                              ? const Center(
                                  child: Text("Aucune photo pour ce client"))
                              : GridView.builder(
                                  padding: const EdgeInsets.all(8),
                                  gridDelegate:
                                      const SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 3,
                                    crossAxisSpacing: 4,
                                    mainAxisSpacing: 4,
                                  ),
                                  itemCount: vm.photos.length,
                                  itemBuilder: (ctx, i) {
                                    final p = vm.photos[i];
                                    return GestureDetector(
                                      onTap: () => _zoomPhoto(context, p.url),
                                      child: Hero(
                                        tag: p.url,
                                        child: Image.network(
                                          p.url,
                                          fit: BoxFit.cover,
                                          loadingBuilder: (c, child, progress) {
                                            if (progress == null) return child;
                                            return Container(
                                                color: Colors.grey.shade200,
                                                child: const Center(
                                                    child: Icon(Icons.image)));
                                          },
                                        ),
                                      ),
                                    );
                                  },
                                ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactRow(IconData icon, String text, VoidCallback? onTap) {
    return InkWell(
      onTap: (text.isNotEmpty && onTap != null) ? onTap : null,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12.0),
        child: Row(
          children: [
            Icon(icon, color: AppTheme.primary, size: 20),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                text.isEmpty ? "Non renseigné" : text,
                style: TextStyle(
                  fontSize: 15,
                  color: (text.isNotEmpty && onTap != null)
                      ? AppTheme.textDark
                      : Colors.grey,
                  decoration: (text.isNotEmpty && onTap != null)
                      ? TextDecoration.underline
                      : null,
                ),
              ),
            ),
            if (text.isNotEmpty && onTap != null)
              const Icon(Icons.chevron_right, color: Colors.grey, size: 16)
          ],
        ),
      ),
    );
  }
}
