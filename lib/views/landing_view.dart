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
        gradient: const LinearGradient(
          colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF6366F1).withValues(alpha: 0.2),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Logo
          Text(
            'ARTISAN 3.0',
            style: GoogleFonts.spaceGrotesk(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: Colors.white,
              letterSpacing: 0.5,
            ),
          ),

          // Bouton Se connecter
          ElevatedButton(
            onPressed: () => context.go('/login'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: const Color(0xFF6366F1),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
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
            Color(0xFF6366F1),
            Color(0xFF8B5CF6),
          ],
        ),
      ),
      child: Column(
        children: [
          // Titre principal
          Text(
            'L\'ERP par les artisans,\npour les artisans',
            textAlign: TextAlign.center,
            style: GoogleFonts.spaceGrotesk(
              fontSize: isDesktop ? 52 : 34,
              fontWeight: FontWeight.w700,
              color: Colors.white,
              height: 1.15,
              letterSpacing: -1,
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
              foregroundColor: const Color(0xFF6366F1),
              padding: EdgeInsets.symmetric(
                horizontal: isDesktop ? 48 : 32,
                vertical: isDesktop ? 20 : 16,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 0,
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
      color: const Color(0xFFF8FAFC),
      child: Column(
        children: [
          // Titre de section
          Text(
            'Fonctionnalités clés',
            style: GoogleFonts.spaceGrotesk(
              fontSize: isDesktop ? 36 : 28,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF0F172A),
              letterSpacing: -0.5,
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
        color: Colors.white.withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.7),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF6366F1).withValues(alpha: 0.08),
            blurRadius: 24,
            offset: const Offset(0, 8),
            spreadRadius: -4,
          ),
        ],
      ),
      child: Column(
        children: [
          // Icône
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: const Color(0xFFEEF2FF),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: const Color(0xFF6366F1).withValues(alpha: 0.1),
              ),
            ),
            child: Icon(
              icon,
              size: 36,
              color: const Color(0xFF6366F1),
            ),
          ),

          const SizedBox(height: 24),

          // Titre
          Text(
            title,
            textAlign: TextAlign.center,
            style: GoogleFonts.spaceGrotesk(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF0F172A),
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
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
      ),
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
