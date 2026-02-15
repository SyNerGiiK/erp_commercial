import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

/// Page d'accueil publique (Landing Page) de l'ERP Artisan 3.0
/// Design SaaS B2B professionnel et responsive (Mobile/Desktop)
class LandingView extends StatelessWidget {
  const LandingView({super.key});

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width > 800;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // NavBar
            _buildNavBar(context),

            // Hero Section
            _buildHeroSection(context, isDesktop),

            // Features Section
            _buildFeaturesSection(context, isDesktop),

            // Footer
            _buildFooter(context),
          ],
        ),
      ),
    );
  }

  // ========== NAVBAR ==========
  Widget _buildNavBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E5572),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Logo
          Text(
            'ARTISAN 3.0',
            style: GoogleFonts.poppins(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              letterSpacing: 1.2,
            ),
          ),

          // Bouton Se connecter
          ElevatedButton(
            onPressed: () => context.go('/login'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: const Color(0xFF1E5572),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              elevation: 0,
            ),
            child: Text(
              'Se connecter',
              style: GoogleFonts.inter(
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ========== HERO SECTION ==========
  Widget _buildHeroSection(BuildContext context, bool isDesktop) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isDesktop ? 80 : 24,
        vertical: isDesktop ? 120 : 60,
      ),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF1E5572),
            Color(0xFF2A6A8C),
          ],
        ),
      ),
      child: Column(
        children: [
          // Titre principal
          Text(
            'L\'ERP par les artisans,\npour les artisans',
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: isDesktop ? 48 : 32,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              height: 1.2,
            ),
          ),

          const SizedBox(height: 24),

          // Sous-titre
          Text(
            'Gérez vos devis, factures, URSSAF et planning\nen toute simplicité',
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: isDesktop ? 20 : 16,
              color: Colors.white.withValues(alpha: 0.9),
              height: 1.5,
            ),
          ),

          const SizedBox(height: 40),

          // Bouton CTA
          ElevatedButton(
            onPressed: () => context.go('/login'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: const Color(0xFF1E5572),
              padding: EdgeInsets.symmetric(
                horizontal: isDesktop ? 48 : 32,
                vertical: isDesktop ? 20 : 16,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 8,
            ),
            child: Text(
              'Commencer',
              style: GoogleFonts.inter(
                fontSize: isDesktop ? 18 : 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ========== FEATURES SECTION ==========
  Widget _buildFeaturesSection(BuildContext context, bool isDesktop) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isDesktop ? 80 : 24,
        vertical: isDesktop ? 100 : 60,
      ),
      color: const Color(0xFFF8FAFB),
      child: Column(
        children: [
          // Titre de section
          Text(
            'Fonctionnalités clés',
            style: GoogleFonts.poppins(
              fontSize: isDesktop ? 36 : 28,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF1E5572),
            ),
          ),

          const SizedBox(height: 60),

          // Cartes features (Responsive)
          isDesktop
              ? Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: _buildFeatureCard(
                        icon: Icons.receipt_long,
                        title: 'Devis & Factures',
                        description:
                            'Créez et suivez vos documents commerciaux professionnels',
                      ),
                    ),
                    const SizedBox(width: 32),
                    Expanded(
                      child: _buildFeatureCard(
                        icon: Icons.account_balance,
                        title: 'Gestion URSSAF',
                        description:
                            'Calculez vos cotisations automatiquement et en temps réel',
                      ),
                    ),
                    const SizedBox(width: 32),
                    Expanded(
                      child: _buildFeatureCard(
                        icon: Icons.calendar_today,
                        title: 'Planning',
                        description:
                            'Organisez vos chantiers et rendez-vous efficacement',
                      ),
                    ),
                  ],
                )
              : Column(
                  children: [
                    _buildFeatureCard(
                      icon: Icons.receipt_long,
                      title: 'Devis & Factures',
                      description:
                          'Créez et suivez vos documents commerciaux professionnels',
                    ),
                    const SizedBox(height: 24),
                    _buildFeatureCard(
                      icon: Icons.account_balance,
                      title: 'Gestion URSSAF',
                      description:
                          'Calculez vos cotisations automatiquement et en temps réel',
                    ),
                    const SizedBox(height: 24),
                    _buildFeatureCard(
                      icon: Icons.calendar_today,
                      title: 'Planning',
                      description:
                          'Organisez vos chantiers et rendez-vous efficacement',
                    ),
                  ],
                ),
        ],
      ),
    );
  }

  // Carte Feature individuelle
  Widget _buildFeatureCard({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Icône
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFF1E5572).withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              size: 40,
              color: const Color(0xFF1E5572),
            ),
          ),

          const SizedBox(height: 24),

          // Titre
          Text(
            title,
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF1E5572),
            ),
          ),

          const SizedBox(height: 12),

          // Description
          Text(
            description,
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 14,
              color: Colors.grey[600],
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  // ========== FOOTER ==========
  Widget _buildFooter(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
      color: const Color(0xFF1E5572),
      child: Center(
        child: Text(
          '© 2026 Artisan 3.0 - Tous droits réservés',
          textAlign: TextAlign.center,
          style: GoogleFonts.inter(
            fontSize: 14,
            color: Colors.white.withValues(alpha: 0.8),
          ),
        ),
      ),
    );
  }
}
