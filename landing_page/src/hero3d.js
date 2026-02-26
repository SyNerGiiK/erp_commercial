/**
 * hero3d.js — Scène Three.js : particules forge orange/ambre
 * ~800 particules sphériques flottantes avec mouseMove parallax
 * Désactivé automatiquement sur mobile (< 768px) et prefers-reduced-motion
 */

import * as THREE from 'three';

export function initHero3D() {
  // Désactivé sur petits écrans ou si animation réduite préférée
  const prefersReduced = window.matchMedia('(prefers-reduced-motion: reduce)').matches;
  if (window.innerWidth < 768 || prefersReduced) return;

  const canvas = document.getElementById('hero-canvas');
  if (!canvas) return;

  // ─── Renderer ───────────────────────────────────────────
  const renderer = new THREE.WebGLRenderer({
    canvas,
    alpha: true,
    antialias: false,
  });
  renderer.setPixelRatio(Math.min(window.devicePixelRatio, 2));
  renderer.setSize(window.innerWidth, window.innerHeight);

  // ─── Scene & Camera ──────────────────────────────────────
  const scene = new THREE.Scene();
  const camera = new THREE.PerspectiveCamera(60, window.innerWidth / window.innerHeight, 0.1, 1000);
  camera.position.z = 300;

  // ─── Particules ──────────────────────────────────────────
  const COUNT = 900;
  const geometry = new THREE.BufferGeometry();
  const positions = new Float32Array(COUNT * 3);
  const colors = new Float32Array(COUNT * 3);
  const scales = new Float32Array(COUNT);

  // Couleurs forge : orange, ambre, or, braise
  const palette = [
    new THREE.Color('#F97316'), // fire
    new THREE.Color('#F97316'),
    new THREE.Color('#FB923C'), // fire-light
    new THREE.Color('#F59E0B'), // gold
    new THREE.Color('#FCD34D'), // gold-light
    new THREE.Color('#EA580C'), // fire-dark
    new THREE.Color('#6366F1'), // indigo (accent tech)
  ];

  const spread = 380;

  for (let i = 0; i < COUNT; i++) {
    // Distribution sphérique
    const theta = Math.random() * Math.PI * 2;
    const phi = Math.acos(2 * Math.random() - 1);
    const r = 80 + Math.random() * spread;

    positions[i * 3]     = r * Math.sin(phi) * Math.cos(theta);
    positions[i * 3 + 1] = r * Math.sin(phi) * Math.sin(theta);
    positions[i * 3 + 2] = r * Math.cos(phi) - 100;

    const color = palette[Math.floor(Math.random() * palette.length)];
    colors[i * 3]     = color.r;
    colors[i * 3 + 1] = color.g;
    colors[i * 3 + 2] = color.b;

    scales[i] = 0.4 + Math.random() * 2.2;
  }

  geometry.setAttribute('position', new THREE.BufferAttribute(positions, 3));
  geometry.setAttribute('color', new THREE.BufferAttribute(colors, 3));
  geometry.setAttribute('size', new THREE.BufferAttribute(scales, 1));

  // Shader material pour particules rondes avec glow
  const material = new THREE.PointsMaterial({
    size: 2.5,
    vertexColors: true,
    transparent: true,
    opacity: 0.75,
    sizeAttenuation: true,
    blending: THREE.AdditiveBlending,
    depthWrite: false,
  });

  const particles = new THREE.Points(geometry, material);
  scene.add(particles);

  // ─── Connexions légères (lignes entre proches) ───────────
  const lineGeometry = new THREE.BufferGeometry();
  const linePositions = [];
  const lineColors = [];
  const CONNECT_DIST = 60;
  const MAX_LINES = 200;
  let lineCount = 0;

  const posArr = Array.from({ length: COUNT }, (_, i) => ({
    x: positions[i * 3],
    y: positions[i * 3 + 1],
    z: positions[i * 3 + 2],
  }));

  for (let i = 0; i < COUNT && lineCount < MAX_LINES; i++) {
    for (let j = i + 1; j < COUNT && lineCount < MAX_LINES; j++) {
      const dx = posArr[i].x - posArr[j].x;
      const dy = posArr[i].y - posArr[j].y;
      const dz = posArr[i].z - posArr[j].z;
      const dist = Math.sqrt(dx * dx + dy * dy + dz * dz);
      if (dist < CONNECT_DIST) {
        linePositions.push(posArr[i].x, posArr[i].y, posArr[i].z);
        linePositions.push(posArr[j].x, posArr[j].y, posArr[j].z);
        const alpha = 1 - dist / CONNECT_DIST;
        lineColors.push(0.98, 0.45, 0.09, 0.98, 0.45, 0.09); // orange
        lineCount++;
      }
    }
  }

  if (linePositions.length > 0) {
    lineGeometry.setAttribute('position', new THREE.BufferAttribute(new Float32Array(linePositions), 3));
    const lineMat = new THREE.LineBasicMaterial({
      vertexColors: false,
      color: new THREE.Color('#F97316'),
      transparent: true,
      opacity: 0.08,
      blending: THREE.AdditiveBlending,
      depthWrite: false,
    });
    const lines = new THREE.LineSegments(lineGeometry, lineMat);
    scene.add(lines);
  }

  // ─── MouseMove parallax ──────────────────────────────────
  let mouseX = 0;
  let mouseY = 0;
  let targetX = 0;
  let targetY = 0;

  document.addEventListener('mousemove', (e) => {
    mouseX = (e.clientX / window.innerWidth - 0.5) * 2;
    mouseY = (e.clientY / window.innerHeight - 0.5) * 2;
  });

  // ─── Resize ──────────────────────────────────────────────
  window.addEventListener('resize', () => {
    if (window.innerWidth < 768) {
      renderer.domElement.style.display = 'none';
      return;
    }
    camera.aspect = window.innerWidth / window.innerHeight;
    camera.updateProjectionMatrix();
    renderer.setSize(window.innerWidth, window.innerHeight);
  });

  // ─── Animation loop ──────────────────────────────────────
  let animId;
  const clock = new THREE.Clock();

  function animate() {
    animId = requestAnimationFrame(animate);
    const elapsed = clock.getElapsedTime();

    // Rotation lente
    particles.rotation.y = elapsed * 0.04;
    particles.rotation.x = elapsed * 0.015;

    // Légère oscillation z
    particles.position.z = Math.sin(elapsed * 0.3) * 5;

    // Parallax camera (lerp vers souris)
    targetX += (mouseX * 25 - targetX) * 0.04;
    targetY += (-mouseY * 20 - targetY) * 0.04;
    camera.position.x = targetX;
    camera.position.y = targetY;
    camera.lookAt(0, 0, 0);

    renderer.render(scene, camera);
  }

  animate();

  // Stopper quand hero hors viewport (perf)
  const heroEl = document.getElementById('hero');
  if (heroEl) {
    const obs = new IntersectionObserver(
      ([entry]) => {
        if (!entry.isIntersecting) {
          cancelAnimationFrame(animId);
        } else {
          animate();
        }
      },
      { threshold: 0 }
    );
    obs.observe(heroEl);
  }
}
