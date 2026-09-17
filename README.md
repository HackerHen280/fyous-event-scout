# Fyous Event Scout

Dental and advanced-manufacturing trade shows for 2026 and 2027, with a shared plan for each show: status, checklist with deadlines, budget and notes.

**Open it:** https://hackerhen280.github.io/fyous-event-scout/

## How it works

- `index.html` is the whole website. The event list (dates, cities, attendance, audiences) is in the `fyous-events` block near the top of the script.
- The plan everyone edits is stored in a Supabase database, not in this repository. Changes save automatically and appear on everyone's open page within seconds.
- Anyone with the link can view and edit the plan, so share it only with the team and keep private details (booking references, card numbers) out of the notes.
- `supabase-setup.sql` creates the database tables and access rules. It is safe to run again.
- Event dates and figures are re-checked against organiser websites every Monday by a scheduled Claude Code task, which updates `index.html` here.

## If something goes wrong

- **"Couldn't load the shared plan"**: the Supabase project may be paused after a quiet week. Open supabase.com/dashboard, pick the project and click **Restore**.
- **Two people changed the same show at the same moment**: the later save wins for that show. Different shows never overwrite each other.
