-- ============================================================================
-- 001_initial_schema.sql
-- Tables, indexes, RLS policies, and triggers for the AI chat app.
-- ============================================================================

-- ---------------------------------------------------------------------------
-- Tables
-- ---------------------------------------------------------------------------

create table public.conversations (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  title text not null default 'New conversation',
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table public.messages (
  id uuid primary key default gen_random_uuid(),
  conversation_id uuid not null references public.conversations(id) on delete cascade,
  role text not null check (role in ('user', 'assistant')),
  content text not null,
  created_at timestamptz not null default now()
);

-- ---------------------------------------------------------------------------
-- Indexes
-- ---------------------------------------------------------------------------

create index messages_conversation_id_idx
  on public.messages(conversation_id, created_at);

create index conversations_user_id_idx
  on public.conversations(user_id, updated_at desc);

-- ---------------------------------------------------------------------------
-- Row Level Security
-- ---------------------------------------------------------------------------

alter table public.conversations enable row level security;
alter table public.messages      enable row level security;

-- Conversations: one policy per operation, scoped to the row owner.
create policy "conversations_select_own"
  on public.conversations for select
  to authenticated
  using (auth.uid() = user_id);

create policy "conversations_insert_own"
  on public.conversations for insert
  to authenticated
  with check (auth.uid() = user_id);

create policy "conversations_update_own"
  on public.conversations for update
  to authenticated
  using      (auth.uid() = user_id)
  with check (auth.uid() = user_id);

create policy "conversations_delete_own"
  on public.conversations for delete
  to authenticated
  using (auth.uid() = user_id);

-- Messages: caller can read/insert messages only inside their own conversations.
create policy "messages_select_own"
  on public.messages for select
  to authenticated
  using (
    exists (
      select 1
      from public.conversations c
      where c.id = conversation_id
        and c.user_id = auth.uid()
    )
  );

create policy "messages_insert_own"
  on public.messages for insert
  to authenticated
  with check (
    exists (
      select 1
      from public.conversations c
      where c.id = conversation_id
        and c.user_id = auth.uid()
    )
  );

-- ---------------------------------------------------------------------------
-- Triggers
-- ---------------------------------------------------------------------------

-- 1. Auto-bump conversations.updated_at on every UPDATE.
create function public.set_updated_at()
returns trigger
language plpgsql
security invoker
set search_path = ''
as $$
begin
  new.updated_at = now();
  return new;
end;
$$;

create trigger conversations_set_updated_at
  before update on public.conversations
  for each row
  execute function public.set_updated_at();

-- 2. Bump the parent conversation's updated_at whenever a new message is
--    inserted, so the conversations list naturally re-sorts most-recent-first.
create function public.bump_conversation_updated_at()
returns trigger
language plpgsql
security invoker
set search_path = ''
as $$
begin
  update public.conversations
     set updated_at = now()
   where id = new.conversation_id;
  return new;
end;
$$;

create trigger messages_bump_parent_updated_at
  after insert on public.messages
  for each row
  execute function public.bump_conversation_updated_at();
