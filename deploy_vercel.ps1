<#
.SYNOPSIS
    Script de déploiement automatisé pour CraftOS sur Vercel.
.DESCRIPTION
    Ce script compile et déploie la Landing Page et le SaaS Flutter sur Vercel.
    Prérequis : Avoir installé Vercel CLI (npm i -g vercel) et s'être connecté (vercel login).
#>

Write-Host "🚀 DÉPLOIEMENT DE CRAFTOS SUR VERCEL" -ForegroundColor Cyan
Write-Host "--------------------------------------" -ForegroundColor Cyan

# 1. Déploiement de la Landing Page
Write-Host "`n[1/2] 🌐 Déploiement de la Landing Page (ViteJS)..." -ForegroundColor Yellow
cd landing_page
npm install
npm run build
Write-Host "📡 Envoi sur Vercel..." -ForegroundColor DarkGray
vercel deploy --prod --yes
cd ..

# 2. Déploiement du SaaS Flutter
Write-Host "`n[2/2] 🛠️ Déploiement de l'Application SaaS (Flutter Web)..." -ForegroundColor Yellow
Write-Host "⏳ Compilation Flutter en cours (cela peut prendre 1 à 2 minutes)..." -ForegroundColor DarkGray
flutter build web --release

Write-Host "📡 Envoi du build sur Vercel..." -ForegroundColor DarkGray
cd build\web
vercel deploy --prod --yes
cd ..\..

Write-Host "`n✅ DÉPLOIEMENT TERMINÉ AVEC SUCCÈS !" -ForegroundColor Green
Write-Host "Vos liens de production sont disponibles ci-dessus." -ForegroundColor Green
