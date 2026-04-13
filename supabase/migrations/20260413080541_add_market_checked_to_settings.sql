/*
  # Add market_checked fields to focus_settings

  ## Summary
  Adds two new columns to the focus_settings table to track whether the user
  has checked today's market.

  ## New Columns
  - `market_checked` (boolean, DEFAULT false): Whether today's market has been checked
  - `market_checked_date` (text, DEFAULT ''): The date the market was last checked, in YYYY-MM-DD format

  ## Notes
  - market_checked_date stores only the date string (YYYY-MM-DD), not a timestamp
  - On page load, if market_checked_date equals today's date AND market_checked is true, show "已查看"
  - Otherwise show "未查看"
*/

DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_name = 'focus_settings' AND column_name = 'market_checked'
  ) THEN
    ALTER TABLE focus_settings ADD COLUMN market_checked boolean DEFAULT false;
  END IF;

  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_name = 'focus_settings' AND column_name = 'market_checked_date'
  ) THEN
    ALTER TABLE focus_settings ADD COLUMN market_checked_date text DEFAULT '';
  END IF;
END $$;
