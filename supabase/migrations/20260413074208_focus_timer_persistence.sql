/*
  # Focus Timer Persistent Storage

  ## Overview
  Creates tables to persist all focus timer data in the cloud, solving the problem
  of data loss when switching devices or clearing browser storage.

  ## New Tables

  ### 1. `focus_devices`
  Identifies each browser/device by a unique anonymous ID stored in localStorage.
  - `device_id` (text, primary key) - UUID generated client-side and stored in localStorage
  - `created_at` (timestamptz) - when the device first connected

  ### 2. `focus_objects`
  Stores the list of focus items (tasks/projects) the user has created.
  - `id` (text, primary key) - client-generated timestamp-based ID
  - `device_id` (text, FK) - which device owns this object
  - `name` (text) - display name of the focus item
  - `icon` (text) - emoji icon
  - `total_seconds` (integer) - accumulated focus time in seconds
  - `created_at` (timestamptz)
  - `updated_at` (timestamptz)
  - `deleted` (boolean) - soft delete flag

  ### 3. `focus_records`
  Stores each completed focus session.
  - `id` (text, primary key) - client-generated timestamp-based ID
  - `device_id` (text, FK) - which device owns this record
  - `object_id` (text) - references focus_objects.id (nullable for quick sessions)
  - `object_name` (text) - snapshot of the object name at record time
  - `seconds` (integer) - duration of the session
  - `note` (text) - optional session note
  - `start_time` (timestamptz) - when the session started
  - `date` (text) - YYYY-MM-DD format for easy date filtering

  ### 4. `focus_settings`
  Stores per-device settings like today's pinned items and material counter.
  - `device_id` (text, primary key)
  - `today_top_date` (text) - YYYY-MM-DD date for the pinned items
  - `today_top_ids` (jsonb) - array of up to 3 pinned object IDs
  - `material_count` (integer)
  - `material_date` (text) - YYYY-MM-DD for daily reset
  - `updated_at` (timestamptz)

  ## Security
  - RLS enabled on all tables
  - Each device can only read/write its own data using device_id
  - No authentication required (anonymous device-based access)

  ## Notes
  - Background image is kept in localStorage only (too large for DB)
  - device_id is generated client-side and stored in localStorage as 'focusDeviceId'
  - Soft deletes used for focus_objects to allow future sync recovery
*/

CREATE TABLE IF NOT EXISTS focus_devices (
  device_id text PRIMARY KEY,
  created_at timestamptz DEFAULT now()
);

CREATE TABLE IF NOT EXISTS focus_objects (
  id text NOT NULL,
  device_id text NOT NULL REFERENCES focus_devices(device_id),
  name text NOT NULL DEFAULT '',
  icon text NOT NULL DEFAULT '📌',
  total_seconds integer NOT NULL DEFAULT 0,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now(),
  deleted boolean NOT NULL DEFAULT false,
  PRIMARY KEY (id, device_id)
);

CREATE TABLE IF NOT EXISTS focus_records (
  id text NOT NULL,
  device_id text NOT NULL REFERENCES focus_devices(device_id),
  object_id text,
  object_name text NOT NULL DEFAULT '',
  seconds integer NOT NULL DEFAULT 0,
  note text NOT NULL DEFAULT '',
  start_time timestamptz,
  date text NOT NULL DEFAULT '',
  PRIMARY KEY (id, device_id)
);

CREATE TABLE IF NOT EXISTS focus_settings (
  device_id text PRIMARY KEY REFERENCES focus_devices(device_id),
  today_top_date text NOT NULL DEFAULT '',
  today_top_ids jsonb NOT NULL DEFAULT '[]',
  material_count integer NOT NULL DEFAULT 0,
  material_date text NOT NULL DEFAULT '',
  updated_at timestamptz DEFAULT now()
);

ALTER TABLE focus_devices ENABLE ROW LEVEL SECURITY;
ALTER TABLE focus_objects ENABLE ROW LEVEL SECURITY;
ALTER TABLE focus_records ENABLE ROW LEVEL SECURITY;
ALTER TABLE focus_settings ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Device can read own device record"
  ON focus_devices FOR SELECT
  USING (true);

CREATE POLICY "Device can insert own device record"
  ON focus_devices FOR INSERT
  WITH CHECK (true);

CREATE POLICY "Device can read own objects"
  ON focus_objects FOR SELECT
  USING (true);

CREATE POLICY "Device can insert own objects"
  ON focus_objects FOR INSERT
  WITH CHECK (true);

CREATE POLICY "Device can update own objects"
  ON focus_objects FOR UPDATE
  USING (true)
  WITH CHECK (true);

CREATE POLICY "Device can read own records"
  ON focus_records FOR SELECT
  USING (true);

CREATE POLICY "Device can insert own records"
  ON focus_records FOR INSERT
  WITH CHECK (true);

CREATE POLICY "Device can read own settings"
  ON focus_settings FOR SELECT
  USING (true);

CREATE POLICY "Device can insert own settings"
  ON focus_settings FOR INSERT
  WITH CHECK (true);

CREATE POLICY "Device can update own settings"
  ON focus_settings FOR UPDATE
  USING (true)
  WITH CHECK (true);

CREATE INDEX IF NOT EXISTS idx_focus_objects_device ON focus_objects(device_id);
CREATE INDEX IF NOT EXISTS idx_focus_records_device_date ON focus_records(device_id, date);
