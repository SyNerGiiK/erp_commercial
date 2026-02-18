-- Migration Sprint 8 : Extension audit_logs pour actions email et relance
-- ========================================

-- Étendre la contrainte CHECK pour accepter les nouvelles actions
ALTER TABLE audit_logs DROP CONSTRAINT IF EXISTS audit_logs_action_check;
ALTER TABLE audit_logs ADD CONSTRAINT audit_logs_action_check
  CHECK (action IN ('INSERT', 'UPDATE', 'DELETE', 'VALIDATE', 'PAYMENT', 'EMAIL_SENT', 'RELANCE_SENT'));
