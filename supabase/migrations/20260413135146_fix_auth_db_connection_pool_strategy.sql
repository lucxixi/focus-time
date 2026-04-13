/*
  # Fix Auth DB Connection Pool Strategy

  ## Summary
  This migration documents the required Auth connection pool change.
  The actual fix must be applied via the Supabase Dashboard under
  Project Settings > Database > Connection Pooling.

  Switch Auth server connection allocation from fixed (10 connections)
  to percentage-based so it scales automatically with instance size.

  ## Manual Step Required
  In Supabase Dashboard:
    Settings > Auth > Connection pool size
    Change from fixed number to percentage (recommended: 10%)

  ## No SQL changes needed
  This setting is managed by Supabase infrastructure, not SQL.
*/

SELECT 1;
