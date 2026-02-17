-- ================================================================================
-- SCRIPT DE VERIFICATION POST-MIGRATION
-- Date: 2026-02-17
-- Description: Vérifier que toutes les corrections ont été appliquées
-- ================================================================================

-- ============================================================================
-- 1. Vérifier que les numéros sont tous à 4 chiffres
-- ============================================================================

SELECT 
    'Vérification numérotation devis' as test,
    COUNT(*) FILTER (WHERE numero_devis ~ '-\d{3}$') as nb_3_chiffres,
    COUNT(*) FILTER (WHERE numero_devis ~ '-\d{4}$') as nb_4_chiffres,
    CASE 
        WHEN COUNT(*) FILTER (WHERE numero_devis ~ '-\d{3}$') = 0 
        THEN '✅ OK' 
        ELSE '❌ ERREUR' 
    END as statut
FROM devis
WHERE numero_devis IS NOT NULL AND numero_devis != '';

SELECT 
    'Vérification numérotation factures' as test,
    COUNT(*) FILTER (WHERE numero_facture ~ '-\d{3}$') as nb_3_chiffres,
    COUNT(*) FILTER (WHERE numero_facture ~ '-\d{4}$') as nb_4_chiffres,
    CASE 
        WHEN COUNT(*) FILTER (WHERE numero_facture ~ '-\d{3}$') = 0 
        THEN '✅ OK' 
        ELSE '❌ ERREUR' 
    END as statut
FROM factures
WHERE numero_facture IS NOT NULL AND numero_facture != '';


-- ============================================================================
-- 2. Vérifier les triggers de protection
-- ============================================================================

SELECT 
    'Vérification triggers' as test,
    COUNT(*) FILTER (WHERE trigger_name = 'trig_prevent_devis_mod') as trigger_devis,
    COUNT(*) FILTER (WHERE trigger_name = 'trig_prevent_facture_mod') as trigger_facture,
    CASE 
        WHEN COUNT(*) FILTER (WHERE trigger_name IN ('trig_prevent_devis_mod', 'trig_prevent_facture_mod')) = 2 
        THEN '✅ OK' 
        ELSE '❌ ERREUR' 
    END as statut
FROM information_schema.triggers
WHERE event_object_schema = 'public' 
  AND event_object_table IN ('devis', 'factures')
  AND trigger_name LIKE 'trig_prevent_%';


-- ============================================================================
-- 3. Vérifier les contraintes UNIQUE
-- ============================================================================

SELECT 
    'Vérification index unique' as test,
    COUNT(*) FILTER (WHERE indexname = 'idx_devis_numero_unique') as idx_devis,
    COUNT(*) FILTER (WHERE indexname = 'idx_factures_numero_unique') as idx_factures,
    CASE 
        WHEN COUNT(*) FILTER (WHERE indexname IN ('idx_devis_numero_unique', 'idx_factures_numero_unique')) = 2 
        THEN '✅ OK' 
        ELSE '❌ ERREUR' 
    END as statut
FROM pg_indexes
WHERE schemaname = 'public' 
  AND tablename IN ('devis', 'factures')
  AND indexname LIKE 'idx_%_numero_unique';


-- ============================================================================
-- 4. Vérifier les contraintes CHECK sur montants
-- ============================================================================

SELECT 
    'Vérification contraintes CHECK' as test,
    COUNT(*) FILTER (WHERE conname = 'chk_paiement_montant_positif') as chk_paiement,
    COUNT(*) FILTER (WHERE conname = 'chk_facture_total_ht_positif') as chk_facture,
    COUNT(*) FILTER (WHERE conname = 'chk_devis_total_ht_positif') as chk_devis,
    CASE 
        WHEN COUNT(*) >= 3 
        THEN '✅ OK' 
        ELSE '❌ ERREUR' 
    END as statut
FROM pg_constraint
WHERE conname LIKE 'chk_%';


-- ============================================================================
-- 5. Détecter les paiements excédentaires (BUG #1)
-- ============================================================================

WITH facture_paiements AS (
    SELECT 
        f.id,
        f.numero_facture,
        f.total_ht::numeric as total_ht,
        f.remise_taux::numeric as remise_taux,
        f.acompte_deja_regle::numeric as acompte_deja_regle,
        COALESCE(SUM(p.montant::numeric), 0) as total_paye,
        -- Net commercial = HT - Remise
        (f.total_ht::numeric - (f.total_ht::numeric * f.remise_taux::numeric / 100)) as net_commercial
    FROM factures f
    LEFT JOIN paiements p ON p.facture_id = f.id
    WHERE f.statut_juridique != 'brouillon'
    GROUP BY f.id, f.numero_facture, f.total_ht, f.remise_taux, f.acompte_deja_regle
)
SELECT 
    'Détection paiements excédentaires' as test,
    numero_facture,
    total_ht,
    total_paye,
    acompte_deja_regle,
    (net_commercial - acompte_deja_regle - total_paye) as reste_a_payer,
    CASE 
        WHEN (total_paye + acompte_deja_regle) > net_commercial 
        THEN '❌ PAIEMENT EXCÉDENTAIRE' 
        ELSE '✅ OK' 
    END as statut
FROM facture_paiements
WHERE (total_paye + acompte_deja_regle) > net_commercial + 0.01; -- Tolérance 1 centime

-- Si aucune ligne retournée = OK


-- ============================================================================
-- 6. Vérifier les doublons de numéros
-- ============================================================================

SELECT 
    'Détection doublons devis' as test,
    numero_devis,
    user_id,
    COUNT(*) as nb_doublons
FROM devis
WHERE numero_devis IS NOT NULL AND numero_devis != '' AND numero_devis != 'brouillon'
GROUP BY numero_devis, user_id
HAVING COUNT(*) > 1;

SELECT 
    'Détection doublons factures' as test,
    numero_facture,
    user_id,
    COUNT(*) as nb_doublons
FROM factures
WHERE numero_facture IS NOT NULL AND numero_facture != '' AND numero_facture != 'brouillon'
GROUP BY numero_facture, user_id
HAVING COUNT(*) > 1;


-- ============================================================================
-- RÉSUMÉ FINAL
-- ============================================================================

SELECT 
    'MIGRATION TERMINÉE' as message,
    NOW() as date_verification;
