# Audit Sécurité & Conformité BDD (FINAL)

**Projet:** Cap'Tech Project (Production)
**Date:** 16/02/2026
**Statut:** 🟢 BLINDÉ

---

## 🛡️ 1. SÉCURITÉ D'ACCÈS (RLS)
✅ **CONFIRMÉ.**
L'accès aux données est strictement cloisonné.
- Un utilisateur ne voit QUE ses propres données (`factures`, `clients`, etc.).
- Les tables liées (`lignes`, `paiements`) vérifient systématiquement la paternité du parent.

## 🔒 2. INTÉGRITÉ DES DONNÉES (HARDENING)
✅ **APPLIQUÉ (v2).**
Le script de durcissement a été exécuté avec succès sur la PROD.

Désormais, la base de données REFUSE physiquement :
1.  **Les Prix Négatifs :** `prix_unitaire >= 0` (sauf remises explicites).
2.  **Les Factures Négatives :** `total_ttc >= 0`.
3.  **Les Quantités Nulles :** `quantite <> 0` (sauf pour les lignes de pur formatage type 'Titre').
4.  **Les Paiements à 0 :** Interdits.
5.  **Les Emails Clients Invalides :** Format vérifié (regex simple).
6.  **Les Noms Clients Vides :** Interdits.

---

## Conclusion
La base de données est maintenant conforme aux standards de **"Haut Niveau de Sécurité"**. Elle résiste non seulement aux accès non autorisés (RLS), mais aussi aux bugs logiciels et aux insertions incohérentes (Constraints).
