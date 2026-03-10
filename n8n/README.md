# n8n IUT Campus Scraper — Telegram Bot Setup Guide

This workflow scrapes events from the **ICFAI University Tripura** website (`iutripura.edu.in`) and populates the `campus_events` table in Supabase — triggered on-demand via a **Telegram bot**.

## How It Works

```
You send /fetch to your Telegram bot
  → Bot replies "🔄 Fetching..."
  → Scrapes iutripura.edu.in/eventspage
  → Parses forthcoming + concluded events
  → Upserts to Supabase campus_events table
  → Bot replies "✅ Done! Fetched X events"
```

## Prerequisites

- **Docker** installed (or n8n installed via npm globally)
- **Supabase project** with the migration SQL already applied
- **Telegram Bot** created via [@BotFather](https://t.me/BotFather)

## 1. Create a Telegram Bot

1. Open Telegram and search for **@BotFather**.
2. Send `/newbot` and follow the prompts to create your bot.
3. Copy the **bot token** (e.g., `8718405272:AAET1kV...`).
4. Send a message to your new bot so it can receive messages from you.

## 2. Start n8n Locally

```bash
# Option A: Docker (recommended)
docker run -it --rm --name n8n -p 5678:5678 -v n8n_data:/home/node/.n8n n8nio/n8n

# Option B: npm
npm install -g n8n
n8n start
```

Open http://localhost:5678 in your browser.

## 3. Add Telegram Credentials in n8n

1. Go to **Settings** → **Credentials** → **Add Credential**.
2. Search for **"Telegram API"**.
3. Name it **"IUT Campus Bot"** (must match exactly).
4. Paste your bot token.
5. Click **Save**.

## 4. Import the Workflow

1. In n8n, click **"Add workflow"** (+).
2. Click the three-dot menu → **"Import from file"**.
3. Select `campus_scraper_workflow.json` from this folder.
4. All nodes should automatically connect to the "IUT Campus Bot" credential.

## 5. Configure Supabase (Step 8)

In the **"Upsert to Supabase"** node, replace:
- **URL**: `https://<your-project>.supabase.co/rest/v1/campus_events`
- **apikey**: Your Supabase anon key
- **Authorization**: `Bearer <your-supabase-service-role-key>`

## 6. Activate & Test

1. Toggle the **Active** switch in the top-right corner.
2. Open Telegram and send `/fetch` to your bot.
3. You should receive:
   - 🔄 "Fetching latest events..."
   - ✅ "Done! Fetched X events" with a summary

## Workflow Nodes Explained

| # | Node | Purpose |
|---|------|---------|
| 1 | **Telegram Trigger** | Listens for incoming Telegram messages |
| 2 | **Is /fetch from Admin?** | Checks if the message is `/fetch` AND from your Telegram ID (`1685715420`) |
| 3 | **Reply: Fetching...** | Sends acknowledgment message |
| 4 | **Reply: Unauthorized** | Sends rejection if someone else tries to use the bot |
| 5 | **Fetch Events Page** | HTTP GET `https://iutripura.edu.in/eventspage` |
| 6 | **Parse IUT Events** | Extracts events from IUT's HTML (title, description, date, URL) |
| 7 | **Has Events?** | Checks if any events were extracted |
| 8 | **Upsert to Supabase** | POSTs extracted events to Supabase REST API |
| 9 | **Reply: Success** | Sends summary of fetched events back to Telegram |
| 10 | **Reply: No Events** | Sends error message if scraping failed |

## Security

- Only your Telegram ID (`1685715420`) can trigger the scraping.
- Anyone else who messages the bot gets an "Unauthorized" reply.
- To add more admins, edit the IF node conditions.

## Troubleshooting

- **Bot not responding?** — Make sure the workflow is **Active** (toggle on).
- **"Unauthorized" reply?** — Check that your Telegram ID matches in the IF node.
- **No events extracted?** — The IUT website HTML structure may have changed. Check the Parse node's JS code.
- **Supabase error?** — Verify your API keys and URL in the Upsert node.
