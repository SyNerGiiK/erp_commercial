/**
 * animations.js — GSAP ScrollTrigger + interactions UI
 * Reveal au scroll, navbar, FAQ accordion, burger menu
 */

import { gsap } from 'gsap';
import { ScrollTrigger } from 'gsap/ScrollTrigger';

gsap.registerPlugin(ScrollTrigger);

// ─── Navbar scroll effect ────────────────────────────────
function initNavbar() {
  const nav = document.getElementById('navbar');
  if (!nav) return;

  ScrollTrigger.create({
    start: 'top -80px',
    onEnter: () => nav.classList.add('scrolled'),
    onLeaveBack: () => nav.classList.remove('scrolled'),
  });

  // Burger menu
  const burger = document.getElementById('burger');
  const mobileMenu = document.getElementById('mobile-menu');
  const mobileClose = document.getElementById('mobile-close');

  if (burger && mobileMenu) {
    burger.addEventListener('click', () => mobileMenu.classList.add('open'));
    mobileClose?.addEventListener('click', () => mobileMenu.classList.remove('open'));
    mobileMenu.querySelectorAll('a').forEach((a) =>
      a.addEventListener('click', () => mobileMenu.classList.remove('open'))
    );
  }
}

// ─── Hero reveal ─────────────────────────────────────────
function initHeroReveal() {
  const tl = gsap.timeline({ delay: 0.3 });
  tl.from('.hero-badge',  { opacity: 0, y: 20, duration: 0.6, ease: 'power2.out' })
    .from('.hero-title',  { opacity: 0, y: 35, duration: 0.7, ease: 'power2.out' }, '-=0.3')
    .from('.hero-sub',    { opacity: 0, y: 25, duration: 0.6, ease: 'power2.out' }, '-=0.4')
    .from('.hero-ctas',   { opacity: 0, y: 20, duration: 0.5, ease: 'power2.out' }, '-=0.3')
    .from('.trust-bar',   { opacity: 0, y: 15, duration: 0.5, ease: 'power2.out' }, '-=0.2')
    .from('.scroll-hint', { opacity: 0, duration: 0.5 }, '-=0.1');
}

// ─── Scroll reveal générique ─────────────────────────────
function revealOn(selector, options = {}) {
  const defaults = {
    opacity: 0, y: 35, duration: 0.7, ease: 'power2.out', stagger: 0.1,
  };
  const merged = { ...defaults, ...options };

  gsap.from(selector, {
    ...merged,
    scrollTrigger: {
      trigger: selector,
      start: 'top 85%',
      toggleActions: 'play none none none',
    },
  });
}

// ─── Stats bar ───────────────────────────────────────────
function initStats() {
  gsap.from('.stat-item', {
    opacity: 0, y: 30, duration: 0.6, stagger: 0.12, ease: 'power2.out',
    scrollTrigger: { trigger: '#stats', start: 'top 80%' },
  });
}

// ─── Features cards ──────────────────────────────────────
function initFeatures() {
  gsap.from('.feature-card', {
    opacity: 0, y: 40, duration: 0.65, stagger: 0.08, ease: 'power2.out',
    scrollTrigger: { trigger: '.features-grid', start: 'top 80%' },
  });
}

// ─── IA Showcase ─────────────────────────────────────────
function initIASection() {
  // Titre
  gsap.from('#ia .section-title', {
    opacity: 0, y: 30, duration: 0.7, ease: 'power2.out',
    scrollTrigger: { trigger: '#ia', start: 'top 80%' },
  });

  // Téléphone depuis la gauche
  gsap.from('.phone-mockup-wrap', {
    opacity: 0, x: -60, duration: 0.9, ease: 'power2.out',
    scrollTrigger: { trigger: '.ia-inner', start: 'top 75%' },
  });

  // Texte depuis la droite
  gsap.from('.ia-text-col', {
    opacity: 0, x: 60, duration: 0.9, ease: 'power2.out',
    scrollTrigger: { trigger: '.ia-inner', start: 'top 75%' },
  });

  // Steps en stagger
  gsap.from('.ia-step', {
    opacity: 0, y: 25, duration: 0.6, stagger: 0.15, ease: 'power2.out',
    scrollTrigger: { trigger: '.ia-steps', start: 'top 80%' },
  });
}

// ─── Screenshots ─────────────────────────────────────────
function initScreenshots() {
  const cards = document.querySelectorAll('.screen-card');
  cards.forEach((card, i) => {
    const dir = i === 0 ? -50 : i === 2 ? 50 : 0;
    gsap.from(card, {
      opacity: 0, x: dir, y: dir === 0 ? 40 : 20, duration: 0.8, ease: 'power2.out',
      scrollTrigger: { trigger: '.screenshots-grid', start: 'top 78%' },
      delay: i * 0.12,
    });
  });
}

// ─── Testimonials ────────────────────────────────────────
function initTestimonials() {
  gsap.from('.testi-card', {
    opacity: 0, y: 35, scale: 0.97, duration: 0.65, stagger: 0.12, ease: 'power2.out',
    scrollTrigger: { trigger: '.testimonials-grid', start: 'top 80%' },
  });
}

// ─── Pricing card ────────────────────────────────────────
function initPricing() {
  gsap.from('.pricing-card', {
    opacity: 0, y: 40, scale: 0.97, duration: 0.8, ease: 'back.out(1.2)',
    scrollTrigger: { trigger: '#pricing', start: 'top 78%' },
  });
}

// ─── FAQ accordion ───────────────────────────────────────
function initFaq() {
  gsap.from('.faq-item', {
    opacity: 0, y: 20, stagger: 0.08, duration: 0.5, ease: 'power2.out',
    scrollTrigger: { trigger: '.faq-list', start: 'top 82%' },
  });

  document.querySelectorAll('.faq-question').forEach((btn) => {
    btn.addEventListener('click', () => {
      const item = btn.closest('.faq-item');
      const answer = item.querySelector('.faq-answer');
      const isOpen = item.classList.contains('open');

      // Fermer tous les autres
      document.querySelectorAll('.faq-item.open').forEach((openItem) => {
        if (openItem !== item) {
          const a = openItem.querySelector('.faq-answer');
          gsap.to(a, { height: 0, duration: 0.35, ease: 'power2.inOut' });
          openItem.classList.remove('open');
        }
      });

      if (isOpen) {
        gsap.to(answer, { height: 0, duration: 0.35, ease: 'power2.inOut' });
        item.classList.remove('open');
      } else {
        item.classList.add('open');
        const inner = answer.querySelector('.faq-answer-inner');
        const targetH = inner.offsetHeight;
        gsap.fromTo(answer, { height: 0 }, { height: targetH, duration: 0.4, ease: 'power2.out' });
      }
    });
  });
}

// ─── CTA finale ──────────────────────────────────────────
function initCtaFinal() {
  gsap.from('#cta-final h2', {
    opacity: 0, y: 40, duration: 0.8, ease: 'power2.out',
    scrollTrigger: { trigger: '#cta-final', start: 'top 80%' },
  });
  gsap.from('#cta-final p', {
    opacity: 0, y: 25, duration: 0.7, ease: 'power2.out', delay: 0.15,
    scrollTrigger: { trigger: '#cta-final', start: 'top 80%' },
  });
  gsap.from('.cta-final-btn', {
    opacity: 0, y: 20, scale: 0.95, duration: 0.6, ease: 'back.out(1.5)', delay: 0.3,
    scrollTrigger: { trigger: '#cta-final', start: 'top 80%' },
  });
}

// ─── Section titles ──────────────────────────────────────
function initSectionTitles() {
  document.querySelectorAll('.section-title').forEach((el) => {
    gsap.from(el, {
      opacity: 0, y: 30, duration: 0.7, ease: 'power2.out',
      scrollTrigger: { trigger: el, start: 'top 85%' },
    });
  });
}

// ─── Init général ────────────────────────────────────────
export function initAnimations() {
  initNavbar();
  initHeroReveal();
  initStats();
  initFeatures();
  initIASection();
  initScreenshots();
  initTestimonials();
  initPricing();
  initFaq();
  initCtaFinal();
  initSectionTitles();
}
