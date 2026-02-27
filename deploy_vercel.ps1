<#
.SYNOPSIS
    Script de déploiement automatisé pour CraftOS sur Vercel.
.DESCRIPTION
    Ce script compile et déploie la Landing Page et le SaaS Flutter sur Vercel.
    Prérequis : Avoir installé Vercel CLI (npm i -g vercel) et s'être connecté (vercel login).
#>

$ErrorActionPreference = "Stop"
$scriptRoot = Split-Path -Parent $MyInvocation.MyCommand.Path

# --- Fix PATH npm (vercel CLI) ---
$npmGlobal = "$env:APPDATA\npm"
if ($env:PATH -notlike "*$npmGlobal*") { $env:PATH += ";$npmGlobal" }

if (-not (Get-Command vercel -ErrorAction SilentlyContinue)) {
    Write-Host "❌ Vercel CLI introuvable. Installez-le via : npm i -g vercel" -ForegroundColor Red
    exit 1
}

Write-Host "🚀 DÉPLOIEMENT DE CRAFTOS SUR VERCEL" -ForegroundColor Cyan
Write-Host "--------------------------------------" -ForegroundColor Cyan

# 1. Déploiement de la Landing Page
Write-Host "`n[1/2] 🌐 Déploiement de la Landing Page (ViteJS)..." -ForegroundColor Yellow
Set-Location "$scriptRoot\landing_page"
npm install
npm run build
Write-Host "📡 Envoi sur Vercel..." -ForegroundColor DarkGray
vercel deploy --prod --yes
Set-Location $scriptRoot

# 2. Déploiement du SaaS Flutter
Write-Host "`n[2/2] 🛠️ Déploiement de l'Application SaaS (Flutter Web)..." -ForegroundColor Yellow
Write-Host "⏳ Compilation Flutter en cours (cela peut prendre 1 à 2 minutes)..." -ForegroundColor DarkGray
flutter build web --release

# Restaurer le lien Vercel si flutter clean l'a effacé
$vercelBuildDir = "$scriptRoot\build\web\.vercel"
$vercelBackup   = "$scriptRoot\web\.vercel\project.json"
if (-not (Test-Path "$vercelBuildDir\project.json")) {
    Write-Host "⚠️  Lien Vercel manquant dans build/web → restauration depuis web/.vercel/" -ForegroundColor Yellow
    New-Item -ItemType Directory -Path $vercelBuildDir -Force | Out-Null
    Copy-Item $vercelBackup "$vercelBuildDir\project.json" -Force
    Write-Host "✅ Lien restauré." -ForegroundColor Green
}

Write-Host "📡 Envoi du build sur Vercel..." -ForegroundColor DarkGray
Set-Location "$scriptRoot\build\web"
vercel deploy --prod --yes
Set-Location $scriptRoot

Write-Host "`n✅ DÉPLOIEMENT TERMINÉ AVEC SUCCÈS !" -ForegroundColor Green
Write-Host "Vos liens de production sont disponibles ci-dessus." -ForegroundColor Green
