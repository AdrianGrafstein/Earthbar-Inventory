-- ============================================================================
-- EarthBAR Inventory Tracker — Supabase database schema
-- ----------------------------------------------------------------------------
-- Paste this WHOLE file into the Supabase SQL Editor and click "Run".
-- It is safe to run more than once (it uses "if not exists" guards).
-- ============================================================================

-- 1) THE TABLE -------------------------------------------------------------
-- One row = one item count, submitted by one store, for one week.
create table if not exists public.inventory_submissions (
  id            bigint generated always as identity primary key, -- auto-numbered unique id
  store_name    text        not null,        -- e.g. "Berkeley", "West Hollywood"
  item_id       text,                        -- optional item code (e.g. "1042")
  item_name     text        not null,        -- e.g. "Almond Milk"
  quantity      integer     not null default 0,
  notes         text,                        -- optional free-text note
  submitted_at  timestamptz not null default now(), -- when the row was saved (auto)
  week_of       date        not null         -- the Monday of the count's week
);

-- 2) INDEXES ---------------------------------------------------------------
-- These make the dashboard's "give me one week / one store" queries fast.
create index if not exists idx_inv_week  on public.inventory_submissions (week_of);
create index if not exists idx_inv_store on public.inventory_submissions (store_name);

-- 3) ROW LEVEL SECURITY (RLS) ----------------------------------------------
-- RLS controls what the public "anon" key (the one in the HTML file) is
-- allowed to do. We turn it ON, then add only the permissions we want:
--   • anyone can READ   (the dashboard needs this)
--   • anyone can INSERT (employees submitting counts need this)
-- We deliberately do NOT allow UPDATE or DELETE, so a leaked anon key
-- cannot be used to tamper with or wipe past submissions.
alter table public.inventory_submissions enable row level security;

-- Allow reading every row.
drop policy if exists "Allow public read" on public.inventory_submissions;
create policy "Allow public read"
  on public.inventory_submissions
  for select
  using (true);

-- Allow inserting new rows.
drop policy if exists "Allow public insert" on public.inventory_submissions;
create policy "Allow public insert"
  on public.inventory_submissions
  for insert
  with check (true);

-- ============================================================================
-- Done. You can verify it worked under: Table Editor → inventory_submissions
-- ============================================================================
