-- ----------------------------------------------------------------------------
-- MIGRATION: 20260223_001_god_mode_rpc.sql
-- DESCRIPTION: Creates RPC functions for Super-Cockpit God Mode and tables.
-- ----------------------------------------------------------------------------

-- 1. RPC for Database Size Metrics
CREATE OR REPLACE FUNCTION get_db_metrics()
RETURNS json
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  db_size bigint;
  stats json;
BEGIN
  SELECT pg_database_size(current_database()) INTO db_size;
  
  stats := json_build_object(
    'total_size_bytes', db_size,
    'total_size_mb', round(db_size / 1048576.0, 2),
    'current_database', current_database()
  );
  
  RETURN stats;
END;
$$;

-- 2. Create crash_logs table if not exists (for Custom Crashlytics)
CREATE TABLE IF NOT EXISTS public.crash_logs (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES auth.users(id) ON DELETE SET NULL,
    error_message TEXT NOT NULL,
    stack_trace TEXT,
    app_version VARCHAR(50),
    device_info JSONB,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    resolved BOOLEAN DEFAULT FALSE
);

-- Protect crash_logs with RLS
ALTER TABLE public.crash_logs ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can insert their own crash logs"
    ON public.crash_logs
    FOR INSERT
    TO authenticated
    WITH CHECK (auth.uid() = user_id OR user_id IS NULL);

-- Admin policy (Assume admin is verified by a custom claim or just role)
CREATE POLICY "Admins can view all crash logs"
    ON public.crash_logs
    FOR SELECT
    TO authenticated
    USING (auth.uid() IN (SELECT id FROM public.entreprises WHERE is_admin = true)); -- Or comparable admin check
