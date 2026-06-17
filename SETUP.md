# EarthBAR Inventory Tracker — Supabase Setup

This guide turns `inventory-tracker.html` from a browser-only app into a real
multi-user web app. After setup, all 6 street stores submit their weekly counts
to **one shared database (Supabase)**, and the Manager Dashboard reads them back.

**You only have to do this once.** Total time: about 10 minutes. No coding required —
just copy/paste.

Files involved:

| File | What it is |
|---|---|
| `inventory-tracker.html` | The app (employee view + manager dashboard) |
| `inventory-data.js` | The store + item lists that power the dropdowns |
| `eb-logo.svg` | The EarthBAR logo shown in the top-left |
| `supabase-schema.sql` | The database setup script you'll paste into Supabase |
| `scripts/build_inventory_data.py` | Regenerates `inventory-data.js` from a text list |
| `SETUP.md` | This guide |

> **Keep these files together.** `inventory-tracker.html` loads `inventory-data.js`
> and `eb-logo.svg` from the same folder, so don't separate them.

---

## What is Supabase? (30-second version)

Supabase is a free hosted database. Think of it as a shared spreadsheet in the
cloud that our app can write to and read from. Every store writes its counts to
the same place, so the manager can see everything in one view. localStorage (the
old way) only lived inside one person's browser — Supabase is shared by everyone.

---

## Step 1 — Create a Supabase project

1. Go to **https://supabase.com** and click **Start your project** / **Sign in**
   (you can sign in with GitHub or email — it's free).
2. Click **New project**.
3. Fill in:
   - **Name:** `earthbar-inventory` (anything is fine)
   - **Database Password:** click *Generate a password* and **save it somewhere
     safe** (a password manager). You won't need it for this app, but Supabase
     requires one.
   - **Region:** pick the one closest to you (e.g. *West US*).
4. Click **Create new project** and wait ~1–2 minutes while it sets up.

---

## Step 2 — Create the database table (paste the SQL)

1. In your project, click the **SQL Editor** icon in the left sidebar
   (it looks like `</>`).
2. Click **+ New query**.
3. Open the file **`supabase-schema.sql`** (next to this guide), select **all**
   of it, and copy it.
4. Paste it into the SQL editor and click **Run** (or press ⌘+Enter).
5. You should see **"Success. No rows returned."** That's correct — it just
   built the table.

To confirm: click **Table Editor** in the sidebar → you should see a table named
**`inventory_submissions`**.

---

## Step 3 — Find your API keys

1. Click the **gear icon (Project Settings)** at the bottom of the left sidebar.
2. Click **API** (under "Configuration").
3. You'll see two things you need:
   - **Project URL** — looks like `https://abcdefgh1234.supabase.co`
   - **Project API keys → `anon` `public`** — a long string starting with `eyJ...`

> **Is it safe to put these in the HTML file?** Yes. The `anon` key is meant to be
> public. It can only do what we allowed in the SQL: **read** and **insert**. It
> **cannot** edit or delete past data. (Never paste the *service_role* key into the
> HTML — that one is a master key. We don't use it.)

---

## Step 4 — Paste the keys into the HTML file

1. Open **`inventory-tracker.html`** in any text editor (TextEdit, VS Code, etc.).
2. Near the top of the `<script>` section, find the **CONFIG** block:

   ```js
   const SUPABASE_URL      = "YOUR_SUPABASE_URL_HERE";
   const SUPABASE_ANON_KEY = "YOUR_SUPABASE_ANON_KEY_HERE";
   ```

3. Replace the placeholder text (keep the quotes!) with your real values:

   ```js
   const SUPABASE_URL      = "https://abcdefgh1234.supabase.co";
   const SUPABASE_ANON_KEY = "eyJhbGciOiJIUzI1NiIsInR5cCI6...your-long-key...";
   ```

4. **Save the file.**

That's it — the app is now connected. If you ever see a yellow "Not connected to
Supabase yet" banner at the top, it means these two values still need to be filled in.

---

## Step 5 — Try it out

**As an employee:**
1. Open `inventory-tracker.html` in a browser (double-click it).
2. On the **Employee** tab, pick your store, add a few items, and click
   **Submit This Week's Count**.
3. You should see a green ✓ success message, and the list clears.
4. (Optional) In Supabase → **Table Editor → inventory_submissions**, you'll see
   your rows appear.

**As a manager:**
1. Click the **Manager** tab at the top.
2. Enter the password — default is **`earthbar2026`** — and click **Unlock**.
3. You'll see a table with every item, each store's quantity side by side, and a
   **Total** column on the right.
4. Use the **Week of** dropdown to look back at previous weeks.

---

## How it works (so you can learn from it)

- **`week_of`** — every submission is stamped with the **Monday** of its week, so
  all 6 stores' counts for the same week group together automatically. The code
  calculates this with the `mondayOf()` helper.
- **`submitted_at`** — the exact timestamp is filled in by the database itself
  (the column's default is `now()`), so we don't have to send it.
- **Manager pivot** — the dashboard pulls all of one week's rows, then groups them
  by item and sums each store's quantity into a column. If the same store submits
  the same item twice in a week, the numbers **add together**.

---

## Sharing the app with the stores

Right now the app is a single file. To let employees use it from their own devices,
you have a few options (easiest first):

1. **Email/Teams the file** — each store opens `inventory-tracker.html` in a browser.
   It works as long as the keys are filled in (the file already "knows" the database).
2. **Host it for free** — drag the file into **Netlify Drop** (https://app.netlify.com/drop)
   or put it in a **GitHub Pages** repo to get a shareable link. Ask me and I'll
   walk you through it.

---

## Updating the store & item lists

The "Select Your Store" dropdown and the item-name autocomplete read their
options from **`inventory-data.js`**. That file has two lists:

- `EB_STORES` — the full company store list (99 stores).
- `EB_ITEMS` — the full item catalog (2,173 items), generated from
  `data/items_raw.txt`. Items whose name starts with `zzz` (discontinued) are
  automatically excluded.

### Refreshing the lists (when items/stores change)

1. Edit the source list — **one name per line** — in:
   `data/items_raw.txt`   (and optionally `data/stores_raw.txt` for stores)
   (Paste straight from the spreadsheet; blank lines, duplicates, and `zzz`
   items are cleaned up automatically.)
2. From the project root, run:
   ```
   cd ~/Desktop/EarthBAR-Intern && source .venv/bin/activate
   python3 scripts/build_inventory_data.py
   ```
3. It rewrites `output/inventory-data.js`. Refresh the app — the dropdowns update.

> **Want to change stores too?** Same idea: save store names (one per line) to
> `data/stores_raw.txt` and re-run the script. If that file doesn't exist, the
> script keeps the built-in store list.

### How the dropdowns behave

- **Store box** — click it to scroll the whole list, or type to filter. Matching
  is "contains," not "starts with," so typing `Culver` finds `EQ Culver City`.
- **Item box** — nothing appears until you start typing; then it suggests items
  whose name contains your text (e.g. `Liposomal` finds
  `Akasha Superfoods - Liposomal Sea Moss Gel 30ct`).
- **Both boxes require a real match.** You can't submit a store or item that
  isn't in the lists — if you type something that doesn't match and click away,
  the box snaps back, and "Add" is rejected with a message. To add a brand-new
  item, add it to `data/items_raw.txt` and re-run the build script (above).
- Use ↑/↓ arrow keys to move through suggestions and Enter to pick one.

---

## Changing the manager password

In `inventory-tracker.html`, find:

```js
const MANAGER_PASSWORD = "earthbar2026";
```

Change the text in quotes and save.

> ⚠️ **Heads-up on security:** this password lives in the HTML, so anyone who opens
> the file and views its source could read it. It's a light gate to keep the
> dashboard tidy, **not** real security. For the internal weekly report that's
> usually fine — but don't treat it like a bank vault. If we ever need true
> per-user logins, Supabase has a proper Auth system we can add later.

---

## Troubleshooting

| Problem | Fix |
|---|---|
| Yellow "Not connected" banner | The two keys in Step 4 aren't filled in (or have a typo). Re-check them. |
| Submit says "Submit failed: ..." | Usually the SQL in Step 2 didn't run, or RLS policies are missing. Re-run `supabase-schema.sql`. |
| Dashboard shows "No submissions for this week yet" | No one has submitted for the selected week. Submit a test count, then click **Refresh**. |
| Manager tab won't unlock | Check the password matches `MANAGER_PASSWORD` in the HTML. |

Stuck on any step? Send me the screenshot and I'll help. — Claude
