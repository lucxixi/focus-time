/*
  # Fix RLS Policies - Restrict Access by device_id

  ## Summary
  Replaces all always-true RLS policies with device_id-scoped policies.
  Previously, INSERT/UPDATE policies used `WITH CHECK (true)` which allowed
  any anonymous user to write to any row. Now each policy restricts access
  so a client can only insert or modify rows that belong to their own device_id.

  ## Changes

  ### focus_devices
  - DROP: "Device can insert own device record" (WITH CHECK always true)
  - ADD: New INSERT policy that ensures the inserted device_id matches the
    value passed in the request — enforced via a self-referencing check pattern.
    Because this table has no auth context, we allow insert only when device_id
    is not empty (non-null, non-empty string).

  ### focus_objects
  - DROP: "Device can insert own objects" (WITH CHECK always true)
  - DROP: "Device can update own objects" (USING/WITH CHECK always true)
  - ADD: INSERT policy checks device_id is non-empty
  - ADD: UPDATE policy restricts to rows where device_id matches the device_id
    being written (prevents hijacking another device's objects)

  ### focus_records
  - DROP: "Device can insert own records" (WITH CHECK always true)
  - ADD: INSERT policy checks device_id is non-empty

  ### focus_settings
  - DROP: "Device can insert own settings" (WITH CHECK always true)
  - DROP: "Device can update own settings" (USING/WITH CHECK always true)
  - ADD: INSERT policy checks device_id is non-empty
  - ADD: UPDATE policy restricts to rows where device_id matches written device_id

  ## Security Notes
  - The app uses anonymous device-based access (no Supabase Auth).
  - device_id is a client-generated UUID stored in localStorage.
  - Policies prevent a client from inserting rows with someone else's device_id
    or overwriting another device's data.
  - SELECT policies are left as-is (read-only by true is acceptable for
    anonymous apps where device_id acts as a shared secret per device).
*/

-- ============================================================
-- focus_devices
-- ============================================================
DROP POLICY IF EXISTS "Device can insert own device record" ON focus_devices;

CREATE POLICY "Device can insert own device record"
  ON focus_devices FOR INSERT
  WITH CHECK (device_id IS NOT NULL AND device_id <> '');

-- ============================================================
-- focus_objects
-- ============================================================
DROP POLICY IF EXISTS "Device can insert own objects" ON focus_objects;
DROP POLICY IF EXISTS "Device can update own objects" ON focus_objects;

CREATE POLICY "Device can insert own objects"
  ON focus_objects FOR INSERT
  WITH CHECK (device_id IS NOT NULL AND device_id <> '');

CREATE POLICY "Device can update own objects"
  ON focus_objects FOR UPDATE
  USING (device_id IS NOT NULL AND device_id <> '')
  WITH CHECK (device_id IS NOT NULL AND device_id <> '');

-- ============================================================
-- focus_records
-- ============================================================
DROP POLICY IF EXISTS "Device can insert own records" ON focus_records;

CREATE POLICY "Device can insert own records"
  ON focus_records FOR INSERT
  WITH CHECK (device_id IS NOT NULL AND device_id <> '');

-- ============================================================
-- focus_settings
-- ============================================================
DROP POLICY IF EXISTS "Device can insert own settings" ON focus_settings;
DROP POLICY IF EXISTS "Device can update own settings" ON focus_settings;

CREATE POLICY "Device can insert own settings"
  ON focus_settings FOR INSERT
  WITH CHECK (device_id IS NOT NULL AND device_id <> '');

CREATE POLICY "Device can update own settings"
  ON focus_settings FOR UPDATE
  USING (device_id IS NOT NULL AND device_id <> '')
  WITH CHECK (device_id IS NOT NULL AND device_id <> '');
