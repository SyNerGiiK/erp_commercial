import './style.css';

document.querySelector('#app').innerHTML = `
  <div class="aurora-bg"></div>
  
  <nav id="navbar">
    <div class="logo">CraftOS</div>
    <div>
      <a href="#features" style="margin-right: 2.5rem; color: var(--text-secondary); transition: color 0.2s; font-weight: 500;">Fonctionnalités</a>
      <a href="https://app.craftos.fr" class="cta-button" style="padding: 0.6rem 1.5rem;">Connexion</a>
    </div>
  </nav>

  <main>
    <section class="hero">
      <h1>Le SaaS BTP <span style="background: linear-gradient(135deg, var(--secondary-cyan), var(--primary-indigo)); -webkit-background-clip: text; -webkit-text-fill-color: transparent;">Ultime</span></h1>
      <p>Design Apple. Automatisation Tesla. Gestion financière parfaite pour les artisans modernes, 100% cloud et assistée par I.A.</p>
      <a href="https://app.craftos.fr/signup" class="cta-button" style="font-size: 1.125rem; padding: 1rem 2.5rem; margin-top: 1rem;">Commencer gratuitement</a>
      
      <div class="hero-lottie">
        <dotlottie-player
          src="https://lottie.host/81e537ba-4b3f-4e1b-9eb0-e907aadd8a87/9mXQvjF9Yw.json"
          background="transparent"
          speed="1"
          loop
          autoplay>
        </dotlottie-player>
      </div>
    </section>

    <section id="features" class="features">
      <h2>Passez à la vitesse supérieure</h2>
      <div class="grid">
        <div class="feature-card glass-container">
          <div class="feature-icon">🤖</div>
          <h3>CRM Magique & OCR</h3>
          <p style="color: var(--text-secondary);">Oubliez la saisie manuelle. Extraction des factures fournisseurs par I.A. et auto-complétion SIRET via Pappers et la Base Adresse Nationale.</p>
        </div>
        
        <div class="feature-card glass-container" style="border-color: rgba(99, 102, 241, 0.3);">
          <div class="feature-icon">🎙️</div>
          <h3 style="background: linear-gradient(135deg, var(--primary-indigo), var(--primary-violet)); -webkit-background-clip: text; -webkit-text-fill-color: transparent;">Aitise ton Devis</h3>
          <p style="color: var(--text-secondary);">Dictez votre chantier à la voix, l'I.A. génère le devis structuré et chiffre les lignes matériels / main-d'œuvre avec votre propre catalogue.</p>
        </div>
        
        <div class="feature-card glass-container">
          <div class="feature-icon">📊</div>
          <h3>Cockpit Financier</h3>
          <p style="color: var(--text-secondary);">Le "Progress Billing" ultime. Suivez votre chiffre d'affaires, votre marge nette et optimisez vos cotisations avec nos curseurs intelligents.</p>
        </div>

        <div class="feature-card glass-container">
          <div class="feature-icon">⚡</div>
          <h3>Encaissement Flash</h3>
          <p style="color: var(--text-secondary);">Vos factures PDF premium incluent automatiquement un QR Code SEPA (EPC). Vos clients vous paient en un simple scan bancaire.</p>
        </div>
      </div>
    </section>

    <section class="pricing">
      <h2>Zéro coût caché</h2>
      <div class="pricing-card glass-container">
        <div class="pricing-title">Artisan Pro</div>
        <div class="pricing-price">0€<span style="font-size: 1.5rem; color: var(--text-secondary); font-weight: 400;">/mois</span></div>
        <ul class="pricing-features">
          <li>Devis et factures illimités</li>
          <li>CRM Magique & Autocomplétion</li>
          <li>Aitise ton Devis (Gemini 2.0)</li>
          <li>Signature électronique</li>
          <li>Support 24/7 par I.A.</li>
        </ul>
        <a href="https://app.craftos.fr/signup" class="cta-button" style="display: block; width: 100%; text-align: center; padding: 1rem;">Créer mon compte</a>
      </div>
    </section>
  </main>
`;

// Navbar scroll effect
window.addEventListener('scroll', () => {
    const nav = document.getElementById('navbar');
    if (window.scrollY > 50) {
        nav.classList.add('scrolled');
    } else {
        nav.classList.remove('scrolled');
    }
});
