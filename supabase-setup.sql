-- Fyous Event Scout: shared plan storage.
-- Paste this whole file into Supabase > SQL Editor > New query, then press Run.
-- It is safe to run more than once.

-- One row per show: its status, checklist, budget and notes.
create table if not exists public.event_plans (
  event_id   text primary key check (char_length(event_id) between 1 and 80),
  data       jsonb not null default '{}'::jsonb,
  updated_by text,
  updated_at timestamptz not null default now()
);

-- Page-wide settings (currently just the budget currency). One row, key = 'plan'.
create table if not exists public.app_settings (
  key        text primary key check (char_length(key) between 1 and 40),
  value      jsonb not null default '{}'::jsonb,
  updated_by text,
  updated_at timestamptz not null default now()
);

-- Anyone with the website link can read and edit the plan, but nobody can delete rows through
-- the website, and a single row can't be made absurdly large.
alter table public.event_plans  enable row level security;
alter table public.app_settings enable row level security;

drop policy if exists "plan readable by site"   on public.event_plans;
drop policy if exists "plan insertable by site" on public.event_plans;
drop policy if exists "plan updatable by site"  on public.event_plans;
create policy "plan readable by site"   on public.event_plans for select to anon, authenticated using (true);
create policy "plan insertable by site" on public.event_plans for insert to anon, authenticated
  with check (pg_column_size(data) < 200000);
create policy "plan updatable by site"  on public.event_plans for update to anon, authenticated
  using (true) with check (pg_column_size(data) < 200000);

drop policy if exists "settings readable by site"   on public.app_settings;
drop policy if exists "settings insertable by site" on public.app_settings;
drop policy if exists "settings updatable by site"  on public.app_settings;
create policy "settings readable by site"   on public.app_settings for select to anon, authenticated using (true);
create policy "settings insertable by site" on public.app_settings for insert to anon, authenticated
  with check (key = 'plan' and pg_column_size(value) < 20000);
create policy "settings updatable by site"  on public.app_settings for update to anon, authenticated
  using (true) with check (key = 'plan' and pg_column_size(value) < 20000);

grant select, insert, update on public.event_plans  to anon, authenticated;
grant select, insert, update on public.app_settings to anon, authenticated;

-- Send changes to everyone's open page straight away (Realtime).
do $$
begin
  if not exists (select 1 from pg_publication_tables
                 where pubname = 'supabase_realtime' and schemaname = 'public' and tablename = 'event_plans') then
    alter publication supabase_realtime add table public.event_plans;
  end if;
  if not exists (select 1 from pg_publication_tables
                 where pubname = 'supabase_realtime' and schemaname = 'public' and tablename = 'app_settings') then
    alter publication supabase_realtime add table public.app_settings;
  end if;
end $$;
