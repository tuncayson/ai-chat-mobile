-- ============================================================================
-- 003_realtime_messages.sql
--
-- Adds public.messages to the supabase_realtime publication so the mobile
-- client can stream live INSERTs as they happen (both the user's message
-- and the assistant's reply are inserted by the `chat` Edge Function).
-- ============================================================================

alter publication supabase_realtime add table public.messages;
