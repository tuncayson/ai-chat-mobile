-- ============================================================================
-- 002_default_user_id_and_realtime.sql
--
-- * Let clients insert conversations without supplying user_id — the DB fills
--   it from the JWT's `auth.uid()`. The existing RLS policy still enforces
--   `auth.uid() = user_id`, so this is a convenience, not a relaxation.
-- * Add the conversations table to the supabase_realtime publication so the
--   mobile client can stream live updates with `client.from(...).stream(...)`.
-- ============================================================================

alter table public.conversations
  alter column user_id set default auth.uid();

alter publication supabase_realtime add table public.conversations;
