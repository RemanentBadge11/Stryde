-- Migration: Create completed_quests table for habit, quest, and daily goal persistence

create table if not exists completed_quests (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  quest_id text not null,
  completed_at timestamptz not null default now(),
  quest_type text not null -- 'habit', 'goal', 'quest'
);

-- Index for efficient user queries sorted by completion time
create index if not exists idx_completed_quests_user_time
  on completed_quests(user_id, completed_at desc);

-- Enable Row Level Security (RLS)
alter table completed_quests enable row level security;

-- Policy: Users can read their own completed quests
create policy "Users can read own completed quests"
  on completed_quests
  for select
  using (auth.uid() = user_id);

-- Policy: Users can insert their own completed quests
create policy "Users can insert own completed quests"
  on completed_quests
  for insert
  with check (auth.uid() = user_id);
