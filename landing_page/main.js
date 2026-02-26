import './style.css';
import { initHero3D } from './src/hero3d.js';
import { initAnimations } from './src/animations.js';
import { initCounters } from './src/counter.js';

// ─────────────────────────────────────────────────────────────
//  HTML — CraftOS Landing Page  (Artisan Forge 2030)
// ─────────────────────────────────────────────────────────────
document.querySelector('#app').innerHTML = `

  <!-- ── Fond mesh ambiant ──────────────────────────────── -->
  <div class="mesh-bg"></div>

  <!-- ═══════════════════════════════════════════════════════
       NAVBAR
  ════════════════════════════════════════════════════════ -->
  <nav id="navbar">
    <a href="#" class="nav-logo">
      <span class="nav-spark">🔥</span>CraftOS
    </a>
    <div class="nav-links">
      <a href="#features"     class="nav-link">Fonctionnalités</a>
      <a href="#testimonials" class="nav-link">Témoignages</a>
      <a href="#pricing"      class="nav-link">Tarifs</a>
      <a href="#faq"          class="nav-link">FAQ</a>
      <a href="https://app-craftos.vercel.app/signup#/login" class="btn-primary" style="padding:0.6rem 1.5rem;font-size:0.9rem;">
        Connexion →
      </a>
    </div>
    <button id="burger" class="burger" aria-label="Menu">
      <span></span><span></span><span></span>
    </button>
  </nav>

  <!-- Menu mobile overlay -->
  <div id="mobile-menu" class="nav-mobile-overlay">
    <button id="mobile-close" class="mobile-close" aria-label="Fermer">✕</button>
    <a href="#features"     >Fonctionnalités</a>
    <a href="#testimonials" >Témoignages</a>
    <a href="#pricing"      >Tarifs</a>
    <a href="#faq"          >FAQ</a>
    <a href="https://app-craftos.vercel.app/signup#/login" class="btn-primary">Commencer gratuitement</a>
  </div>

  <!-- ═══════════════════════════════════════════════════════
       HERO
  ════════════════════════════════════════════════════════ -->
  <section id="hero">
    <canvas id="hero-canvas"></canvas>

    <div class="hero-content">
      <div class="hero-badge">
        <span class="badge"><span class="dot"></span>500+ artisans actifs</span>
        <span class="badge badge-indigo" style="margin-left:0.75rem;">Gemini 2.0 Flash</span>
      </div>

      <h1 class="hero-title">
        Le SaaS BTP<br>
        <em>Ultime &amp; Gratuit</em>
      </h1>

      <p class="hero-sub">
        Design Apple. Automatisation Tesla.<br>
        Gestion financière parfaite pour les artisans modernes,<br>
        100&nbsp;% cloud et assistée par I.A.
      </p>

      <div class="hero-ctas">
        <a href="https://app-craftos.vercel.app/signup#/login" class="btn-primary" style="font-size:1.1rem;padding:1rem 2.5rem;">
          ⚡ Commencer gratuitement
        </a>
        <a href="#features" class="btn-secondary">
          Découvrir les fonctionnalités
        </a>
      </div>

      <div class="trust-bar">
        <div class="trust-item"><span>🏆</span> 100&nbsp;% Gratuit</div>
        <div class="trust-item"><span>🔒</span> Données sécurisées</div>
        <div class="trust-item"><span>⚡</span> Devis en 30&nbsp;s</div>
        <div class="trust-item"><span>🇫🇷</span> Conforme France</div>
      </div>
    </div>

    <div class="scroll-hint">
      <svg viewBox="0 0 24 24"><path d="M12 5v14m0 0-6-6m6 6 6-6"/></svg>
      Scroll
    </div>
  </section>

  <!-- ═══════════════════════════════════════════════════════
       STATS BAR
  ════════════════════════════════════════════════════════ -->
  <section id="stats">
    <div class="stats-grid">
      <div class="stat-item">
        <div class="stat-number" data-counter data-target="500" data-suffix="+">0+</div>
        <div class="stat-label">Artisans actifs</div>
      </div>
      <div class="stat-item">
        <div class="stat-number" data-counter data-target="30" data-suffix="s">0s</div>
        <div class="stat-label">Pour créer un devis</div>
      </div>
      <div class="stat-item">
        <div class="stat-number" data-counter data-target="4.9" data-decimals="1" data-suffix="★">0★</div>
        <div class="stat-label">Note utilisateurs</div>
      </div>
      <div class="stat-item">
        <div class="stat-number">0€</div>
        <div class="stat-label">Zéro abonnement</div>
      </div>
    </div>
  </section>

  <!-- ═══════════════════════════════════════════════════════
       FEATURES
  ════════════════════════════════════════════════════════ -->
  <section id="features" class="section">
    <div class="section-title">
      <h2>Passez à la vitesse supérieure</h2>
      <p>Chaque fonctionnalité a été pensée pour l'artisan du quotidien.</p>
      <span class="section-divider"></span>
    </div>

    <div class="features-grid">

      <div class="feature-card glass-fire">
        <div class="feature-icon-wrap">🤖</div>
        <h3>CRM Magique &amp; OCR</h3>
        <p>Extraction des factures fournisseurs par I.A. et auto-complétion SIRET via Pappers et la Base Adresse Nationale. Zéro saisie manuelle.</p>
        <span class="feature-tag">→ Gain de temps</span>
      </div>

      <div class="feature-card glass-fire">
        <div class="feature-icon-wrap">🎙️</div>
        <h3>Aitise ton Devis</h3>
        <p>Dictez votre chantier à la voix, Gemini 2.0 génère le devis structuré et chiffre les lignes matériaux / main-d'œuvre avec votre propre catalogue.</p>
        <span class="feature-tag">→ Powered by Gemini 2.0</span>
      </div>

      <div class="feature-card glass-fire">
        <div class="feature-icon-wrap">📊</div>
        <h3>Cockpit Financier</h3>
        <p>Progress Billing ultime. Suivez votre CA, votre marge nette et optimisez vos cotisations URSSAF avec des curseurs intelligents.</p>
        <span class="feature-tag">→ Rentabilité maximale</span>
      </div>

      <div class="feature-card glass-fire">
        <div class="feature-icon-wrap">⚡</div>
        <h3>Encaissement Flash</h3>
        <p>Vos factures PDF premium incluent automatiquement un QR Code SEPA (EPC). Vos clients vous paient en un simple scan bancaire.</p>
        <span class="feature-tag">→ Paiement instantané</span>
      </div>

      <div class="feature-card glass-fire">
        <div class="feature-icon-wrap">🎨</div>
        <h3>PDF Studio</h3>
        <p>Choisissez parmi plusieurs thèmes premium (Classique, Moderne, Épuré) et prévisualisez votre document en temps réel avant envoi.</p>
        <span class="feature-tag">→ Documents professionnels</span>
      </div>

      <div class="feature-card glass-fire">
        <div class="feature-icon-wrap">🔄</div>
        <h3>Factures Récurrentes</h3>
        <p>Automatisez vos abonnements et contrats de maintenance. Générez et envoyez automatiquement chaque mois sans lever le petit doigt.</p>
        <span class="feature-tag">→ Zéro oubli</span>
      </div>

    </div>
  </section>

  <!-- ═══════════════════════════════════════════════════════
       IA SHOWCASE
  ════════════════════════════════════════════════════════ -->
  <section id="ia" class="section">
    <div class="section-title reveal">
      <h2>L'I.A. qui <em class="text-gradient-fire">parle chantier</em></h2>
      <p>Dictez, l'I.A. structure. Validez, c'est envoyé.</p>
      <span class="section-divider"></span>
    </div>

    <div class="ia-inner">
      <div class="phone-mockup-wrap">
        <div class="phone-mockup">
          <div class="phone-notch"></div>
          <div class="phone-screen">
            <img
              src="https://images.unsplash.com/photo-1611532736597-de2d4265fba3?w=560&q=80&auto=format"
              alt="Interface devis vocal CraftOS"
              loading="lazy"
            />
          </div>
          <div class="phone-glow"></div>
          <div class="live-badge"><span style="width:6px;height:6px;border-radius:50%;background:#fff;animation:pulse-dot 1.5s infinite"></span> LIVE</div>
        </div>
      </div>

      <div class="ia-text-col">
        <div class="badge" style="margin-bottom:1.5rem;">🎙️ Devis vocal en 3 étapes</div>
        <h3 style="font-size:clamp(1.5rem,3vw,2.25rem);font-weight:800;margin-bottom:1rem;line-height:1.2;">
          Parlez. L'I.A.<br><span class="text-gradient-fire">fait le reste.</span>
        </h3>
        <p style="color:var(--text-3);margin-bottom:2rem;line-height:1.75;">
          Plus besoin de taper ligne par ligne. Décrivez votre chantier à voix haute,
          CraftOS génère un devis complet et chiffré en moins de 30 secondes.
        </p>

        <div class="ia-steps">
          <div class="ia-step">
            <div class="step-num">1</div>
            <div>
              <h4>Décrivez votre chantier</h4>
              <p>« Pose de 30m² de carrelage salle de bain, fourniture et main d'œuvre »</p>
            </div>
          </div>
          <div class="ia-step">
            <div class="step-num">2</div>
            <div>
              <h4>L'I.A. structure et chiffre</h4>
              <p>Gemini 2.0 génère les lignes matériaux/MO avec vos tarifs et votre catalogue.</p>
            </div>
          </div>
          <div class="ia-step">
            <div class="step-num">3</div>
            <div>
              <h4>Validez et envoyez</h4>
              <p>Ajustez si besoin, signez électroniquement et envoyez le PDF professionnel.</p>
            </div>
          </div>
        </div>
      </div>
    </div>
  </section>

  <!-- ═══════════════════════════════════════════════════════
       SCREENSHOTS
  ════════════════════════════════════════════════════════ -->
  <section id="screenshots" class="section">
    <div class="section-title reveal">
      <h2>Une interface <span class="text-gradient-fire">taillée pour l'artisan</span></h2>
      <p>Pensée pour aller vite, pas pour les comptables.</p>
      <span class="section-divider"></span>
    </div>

    <div class="screenshots-grid">
      <div class="screen-card">
        <div class="screen-header">
          <div class="screen-dot" style="background:#ef4444;"></div>
          <div class="screen-dot" style="background:#f59e0b;"></div>
          <div class="screen-dot" style="background:#10b981;"></div>
        </div>
        <img
          class="screen-img"
          src="https://images.unsplash.com/photo-1554224155-6726b3ff858f?w=800&q=75&auto=format"
          alt="Vue devis CraftOS"
          loading="lazy"
        />
        <div class="screen-label">📋 Devis &amp; Factures</div>
      </div>

      <div class="screen-card">
        <div class="screen-header">
          <div class="screen-dot" style="background:#ef4444;"></div>
          <div class="screen-dot" style="background:#f59e0b;"></div>
          <div class="screen-dot" style="background:#10b981;"></div>
        </div>
        <img
          class="screen-img"
          src="https://images.unsplash.com/photo-1551288049-bebda4e38f71?w=800&q=75&auto=format"
          alt="Cockpit financier CraftOS"
          loading="lazy"
        />
        <div class="screen-label">📊 Cockpit Financier</div>
      </div>

      <div class="screen-card">
        <div class="screen-header">
          <div class="screen-dot" style="background:#ef4444;"></div>
          <div class="screen-dot" style="background:#f59e0b;"></div>
          <div class="screen-dot" style="background:#10b981;"></div>
        </div>
        <img
          class="screen-img"
          src="https://images.unsplash.com/photo-1504307651254-35680f356dfd?w=800&q=75&auto=format"
          alt="Chantier BTP CraftOS"
          loading="lazy"
        />
        <div class="screen-label">🏗️ Suivi Chantiers</div>
      </div>
    </div>
  </section>

  <!-- ═══════════════════════════════════════════════════════
       TÉMOIGNAGES
  ════════════════════════════════════════════════════════ -->
  <section id="testimonials" class="section">
    <div class="section-title reveal">
      <h2>Ils ont adopté CraftOS</h2>
      <p>Des artisans qui gagnent 2h par jour sur leur admin.</p>
      <span class="section-divider"></span>
    </div>

    <div class="testimonials-grid">

      <div class="testi-card glass">
        <div class="testi-stars">★★★★★</div>
        <p class="testi-quote">
          « Avant je perdais des heures sur mes devis. Maintenant je dicte le chantier
          en 2 minutes et le PDF part automatiquement. Mes clients sont bluffés. »
        </p>
        <div class="testi-author">
          <img
            class="testi-avatar"
            src="https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=96&q=80&auto=format&fit=crop&crop=face"
            alt="Julien M."
            loading="lazy"
          />
          <div>
            <div class="testi-name">Julien M.</div>
            <div class="testi-role">Maçon — Grenoble</div>
          </div>
        </div>
      </div>

      <div class="testi-card glass">
        <div class="testi-stars">★★★★★</div>
        <p class="testi-quote">
          « Le QR Code SEPA sur les factures, c'est magique. Mes clients scannent
          et je suis payé le jour même. Mon délai moyen est passé de 45 à 3 jours. »
        </p>
        <div class="testi-author">
          <img
            class="testi-avatar"
            src="https://images.unsplash.com/photo-1560250097-0b93528c311a?w=96&q=80&auto=format&fit=crop&crop=face"
            alt="Karim B."
            loading="lazy"
          />
          <div>
            <div class="testi-name">Karim B.</div>
            <div class="testi-role">Électricien — Lyon</div>
          </div>
        </div>
      </div>

      <div class="testi-card glass">
        <div class="testi-stars">★★★★★</div>
        <p class="testi-quote">
          « Le cockpit URSSAF m'évite les mauvaises surprises. Je vois en temps réel
          ce que je dois provisionner. C'est le seul outil dont j'avais besoin. »
        </p>
        <div class="testi-author">
          <img
            class="testi-avatar"
            src="https://images.unsplash.com/photo-1573497019940-1c28c88b4f3e?w=96&q=80&auto=format&fit=crop&crop=face"
            alt="Sophie L."
            loading="lazy"
          />
          <div>
            <div class="testi-name">Sophie L.</div>
            <div class="testi-role">Plombière — Bordeaux</div>
          </div>
        </div>
      </div>

    </div>
  </section>

  <!-- ═══════════════════════════════════════════════════════
       PRICING
  ════════════════════════════════════════════════════════ -->
  <section id="pricing" class="section" style="text-align:center;">
    <div class="section-title reveal">
      <h2>Zéro coût caché,<br><span class="text-gradient-fire">Zéro abonnement</span></h2>
      <p>Toutes les fonctionnalités pour tous les artisans. Gratuit pour toujours.</p>
      <span class="section-divider"></span>
    </div>

    <div class="pricing-card glass-fire">
      <span class="pricing-label">🔥 Offre unique</span>
      <div>
        <span class="pricing-price">0€</span><span class="pricing-period">/mois</span>
      </div>
      <p class="pricing-tagline">Accès complet sans carte bancaire, sans engagement, pour toujours.</p>

      <ul class="pricing-features">
        <li>Devis et factures illimités</li>
        <li>CRM Magique &amp; OCR Fournisseurs</li>
        <li>Aitise ton Devis (Gemini 2.0 Flash)</li>
        <li>Cockpit Financier &amp; Progress Billing</li>
        <li>QR Code SEPA sur chaque facture</li>
        <li>PDF Studio — 3 thèmes premium</li>
        <li>Factures récurrentes automatiques</li>
        <li>Rappels URSSAF, CFE, TVA</li>
        <li>Signature électronique</li>
        <li>Support 24/7 par I.A.</li>
      </ul>

      <a href="https://app-craftos.vercel.app/signup#/login" class="btn-primary btn-full" style="font-size:1.1rem;padding:1.125rem;">
        ⚡ Créer mon compte gratuitement
      </a>
      <p class="pricing-security">🔒 Données chiffrées · Hébergé en Europe · RGPD conforme</p>
    </div>
  </section>

  <!-- ═══════════════════════════════════════════════════════
       FAQ
  ════════════════════════════════════════════════════════ -->
  <section id="faq" class="section">
    <div class="section-title reveal">
      <h2>Questions fréquentes</h2>
      <span class="section-divider"></span>
    </div>

    <div class="faq-list">

      <div class="faq-item">
        <div class="faq-question" role="button" tabindex="0">
          CraftOS est-il vraiment gratuit ?
          <svg class="faq-chevron" viewBox="0 0 24 24"><path d="M6 9l6 6 6-6" stroke="currentColor" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round"/></svg>
        </div>
        <div class="faq-answer"><div class="faq-answer-inner">
          Oui, 100&nbsp;% gratuit. Pas de plan freemium, pas de limite artificielle.
          CraftOS est financé par des services optionnels futurs. Toutes les fonctionnalités
          actuelles resteront gratuites à vie pour les utilisateurs inscrits avant le lancement payant.
        </div></div>
      </div>

      <div class="faq-item">
        <div class="faq-question" role="button" tabindex="0">
          Mes données sont-elles sécurisées ?
          <svg class="faq-chevron" viewBox="0 0 24 24"><path d="M6 9l6 6 6-6" stroke="currentColor" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round"/></svg>
        </div>
        <div class="faq-answer"><div class="faq-answer-inner">
          Vos données sont chiffrées en transit (TLS) et au repos, hébergées en Europe
          (Supabase / AWS eu-west). Chaque compte est isolé via Row-Level Security PostgreSQL.
          Nous sommes conformes RGPD et ne revendons jamais vos données.
        </div></div>
      </div>

      <div class="faq-item">
        <div class="faq-question" role="button" tabindex="0">
          La numérotation de mes devis et factures est-elle légale ?
          <svg class="faq-chevron" viewBox="0 0 24 24"><path d="M6 9l6 6 6-6" stroke="currentColor" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round"/></svg>
        </div>
        <div class="faq-answer"><div class="faq-answer-inner">
          Absolument. CraftOS génère des numéros séquentiels sans saut via des transactions
          atomiques en base de données, conformément aux obligations françaises (article L441-9 CGI).
          Les documents validés sont immuables et horodatés.
        </div></div>
      </div>

      <div class="faq-item">
        <div class="faq-question" role="button" tabindex="0">
          Fonctionne-t-il pour les micro-entrepreneurs ?
          <svg class="faq-chevron" viewBox="0 0 24 24"><path d="M6 9l6 6 6-6" stroke="currentColor" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round"/></svg>
        </div>
        <div class="faq-answer"><div class="faq-answer-inner">
          Parfaitement. CraftOS gère la franchise en base de TVA (mention légale automatique),
          le calcul des cotisations URSSAF avec les taux 2026, et le suivi du seuil de chiffre
          d'affaires. Conçu spécifiquement pour les artisans en micro-entreprise.
        </div></div>
      </div>

      <div class="faq-item">
        <div class="faq-question" role="button" tabindex="0">
          Puis-je importer mes données existantes ?
          <svg class="faq-chevron" viewBox="0 0 24 24"><path d="M6 9l6 6 6-6" stroke="currentColor" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round"/></svg>
        </div>
        <div class="faq-answer"><div class="faq-answer-inner">
          Oui. CraftOS dispose d'un module d'import CSV pour vos clients et catalogue de produits.
          Notre équipe peut vous accompagner gratuitement pour migrer depuis Excel,
          Henrri, Indy ou tout autre logiciel.
        </div></div>
      </div>

    </div>
  </section>

  <!-- ═══════════════════════════════════════════════════════
       CTA FINALE
  ════════════════════════════════════════════════════════ -->
  <section id="cta-final">
    <div class="cta-bg"></div>
    <div class="cta-final-inner">
      <div class="badge" style="margin-bottom:1.5rem;">⚡ Rejoignez 500+ artisans</div>
      <h2>Prêt à<br><span class="text-gradient-fire">reprendre le contrôle ?</span></h2>
      <p>Créez votre compte en 30 secondes. Aucune carte bancaire requise.</p>
      <a href="https://app-craftos.vercel.app/signup#/login" class="cta-final-btn">
        <span>🔥</span> Commencer gratuitement
      </a>
      <p class="cta-counter">
        <strong id="live-counter">12</strong> artisans se sont inscrits cette semaine
      </p>
    </div>
  </section>

  <!-- ═══════════════════════════════════════════════════════
       FOOTER
  ════════════════════════════════════════════════════════ -->
  <footer id="footer">
    <div class="footer-grid">
      <div class="footer-brand">
        <a href="#" class="nav-logo"><span class="nav-spark">🔥</span>CraftOS</a>
        <p>Le SaaS de gestion BTP pensé pour les artisans français. Devis, factures, cockpit financier — tout en un, gratuit.</p>
        <div class="social-links">
          <a href="#" class="social-link" aria-label="LinkedIn">
            <svg viewBox="0 0 24 24"><path d="M16 8a6 6 0 016 6v7h-4v-7a2 2 0 00-2-2 2 2 0 00-2 2v7h-4v-7a6 6 0 016-6zM2 9h4v12H2zm2-3a2 2 0 100-4 2 2 0 000 4z"/></svg>
          </a>
          <a href="#" class="social-link" aria-label="Twitter / X">
            <svg viewBox="0 0 24 24"><path d="M18.244 2.25h3.308l-7.227 8.26 8.502 11.24H16.17l-5.214-6.817L4.99 21.75H1.68l7.73-8.835L1.254 2.25H8.08l4.713 6.231 5.45-6.231zm-1.161 17.52h1.833L7.084 4.126H5.117z"/></svg>
          </a>
        </div>
      </div>

      <div class="footer-col">
        <h4>Produit</h4>
        <ul class="footer-links">
          <li><a href="#features">Fonctionnalités</a></li>
          <li><a href="#pricing">Tarifs</a></li>
          <li><a href="#testimonials">Témoignages</a></li>
          <li><a href="#faq">FAQ</a></li>
        </ul>
      </div>

      <div class="footer-col">
        <h4>Légal</h4>
        <ul class="footer-links">
          <li><a href="#">Mentions légales</a></li>
          <li><a href="#">CGU</a></li>
          <li><a href="#">Politique de confidentialité</a></li>
          <li><a href="#">Cookies</a></li>
        </ul>
      </div>

      <div class="footer-col">
        <h4>Contact</h4>
        <ul class="footer-links">
          <li><a href="mailto:contact@craftos.fr">contact@craftos.fr</a></li>
          <li><a href="#">Centre d'aide</a></li>
          <li><a href="#">Signaler un bug</a></li>
        </ul>
      </div>
    </div>

    <div class="footer-bottom">
      <p>© 2026 CraftOS. Fait avec <span class="footer-heart">♥</span> en France.</p>
      <p>Conformité RGPD · Données hébergées en Europe</p>
    </div>
  </footer>
`;

// ─────────────────────────────────────────────────────────────
//  Init modules au chargement du DOM
// ─────────────────────────────────────────────────────────────
window.addEventListener('DOMContentLoaded', () => {
  initHero3D();
  initAnimations();
  initCounters();

  // Compteur live "artisans inscrits cette semaine" (cosmétique)
  const liveCounterEl = document.getElementById('live-counter');
  if (liveCounterEl) {
    let base = 12;
    setInterval(() => {
      if (Math.random() < 0.3) {
        base += Math.floor(Math.random() * 2) + 1;
        liveCounterEl.textContent = base;
      }
    }, 8000);
  }
});
