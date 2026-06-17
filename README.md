# EarthBAR Inventory Tracker

A single-page web app for EarthBAR / Beaming / Equinox store employees to submit
their weekly inventory counts, plus a password-protected manager dashboard that
totals every store's counts by item.

- **Frontend:** one HTML file (`inventory-tracker.html`) + `inventory-data.js`
  (store & item lists) + `eb-logo.svg`. Hosted free on GitHub Pages.
- **Backend:** Supabase (hosted Postgres). The app talks to it directly from the
  browser using the public `anon` key, which is safe — Row Level Security only
  allows reading and inserting rows (no edits or deletes).

## Live site

➡️ **https://USER.github.io/REPO/**  _(fill in after enabling GitHub Pages)_

## How employees use it

1. Open the link, pick your store, add items (autocomplete from the catalog).
2. **Save for Later** keeps a private draft on that device to edit during the week.
3. **Submit This Week's Count** sends it to the shared database for the manager.

## How to update it (single source of truth)

1. Edit the files locally.
2. To change the store/item lists, edit `../data/items_raw.txt` (kept private,
   outside this repo) and run `python3 ../scripts/build_inventory_data.py`, which
   regenerates `inventory-data.js`.
3. Commit and push:
   ```
   git add -A
   git commit -m "Update inventory tracker"
   git push
   ```
4. GitHub Pages redeploys automatically in ~1 minute.

## Setup / connecting Supabase

See `SETUP.md` for full step-by-step instructions (creating the Supabase project,
running `supabase-schema.sql`, and filling in your keys).
