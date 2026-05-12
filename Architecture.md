# Architecture

This file documents the architecture, conventions, and constraints for this project.

## Project Overview

A cross-platform mobile AI chat app for Android and iOS. Users sign in, chat with an AI assistant that has memory of the conversation, and review past conversations. The focus is a clean, modern mobile UI with dark mode.

The backend is **entirely Supabase**:
- Supabase Auth (email + password) for sign-up and sign-in.
- Supabase Postgres for users, conversations, and messages, secured with Row Level Security.
- A single Supabase Edge Function (Deno) that proxies requests to the Anthropic Claude API. The Anthropic API key lives only inside the Edge Function's secrets — never in the mobile app.

There is no separate Node.js/Express service. The Edge Function replaces what would otherwise be a custom backend.

## Tech Stack

**Mobile (Flutter)**
- Flutter 3.24+ (stable channel), Dart 3.5+
- State management: **Riverpod** (`flutter_riverpod`) — type-safe, testable, current community standard
- Routing: **go_router**
- Supabase client: **`supabase_flutter`** (v2.x)
- Local storage: handled by `supabase_flutter` (uses `shared_preferences` under the hood)
- HTTP for Edge Function calls: use Supabase client's `functions.invoke()` — handles auth headers automatically
- UI: Material 3 with custom theming, dark mode by default
- Markdown rendering for AI responses: `flutter_markdown`
- Lints: `flutter_lints` + `very_good_analysis`

**Backend (Supabase only)**
- Supabase Auth — email/password
- Supabase Postgres — tables for `conversations` and `messages`
- Supabase Edge Functions (Deno + TypeScript) — one function: `chat`
- Anthropic Claude API (called from the Edge Function only)

## Commands

All Flutter `run`/`build` commands need `--dart-define=SUPABASE_URL=...` and `--dart-define=SUPABASE_ANON_KEY=...` — see [Mobile App Configuration](#mobile-app-configuration). Omitted below for brevity.

**Flutter**

```sh
flutter pub get
flutter analyze
dart format .
flutter test                                            # all tests
flutter test test/path/foo_test.dart                    # single file
flutter test test/path/foo_test.dart --name 'pattern'   # single test by name
flutter run                                             # dev (add --dart-define flags)
flutter build apk --release                             # add --dart-define flags
flutter build ios --release                             # add --dart-define flags
```

**Codegen** — regenerate after editing any `@riverpod` (and later `@freezed`, `@JsonSerializable`) annotated file. `*.g.dart` outputs are committed as source.

```sh
dart run build_runner build
dart run build_runner watch     # rebuild on save during dev
```

Do not pass `--delete-conflicting-outputs`; it was removed from current `build_runner` and now prints a warning.

**Supabase** — requires the CLI (`brew install supabase/tap/supabase`).

```sh
supabase start                                  # local Postgres + Auth + Edge runtime
supabase stop
supabase db reset                               # re-apply migrations locally
supabase functions serve chat \
  --env-file ./supabase/functions/.env          # run edge fn locally
supabase functions deploy chat                  # ship to your project
supabase secrets set ANTHROPIC_API_KEY=sk-...   # production secret

# Edge function Deno tests (run inside supabase/functions/chat/):
deno test --allow-env --allow-net
```

## Folder Structure

```
ai-chat-mobile/
├── Architecture.md
├── README.md
├── pubspec.yaml
├── analysis_options.yaml
├── .env.example
├── .gitignore
├── lib/
│   ├── main.dart
│   ├── app.dart                          # MaterialApp.router setup
│   ├── core/
│   │   ├── theme/
│   │   │   ├── app_theme.dart            # light + dark themes
│   │   │   └── app_colors.dart
│   │   ├── router/
│   │   │   └── app_router.dart           # go_router config + auth guard
│   │   ├── config/
│   │   │   └── env.dart                  # reads --dart-define values
│   │   └── widgets/
│   │       ├── loading_indicator.dart
│   │       └── error_view.dart
│   ├── features/
│   │   ├── auth/
│   │   │   ├── data/
│   │   │   │   └── auth_repository.dart
│   │   │   ├── domain/
│   │   │   │   └── auth_state.dart       # Riverpod providers
│   │   │   └── presentation/
│   │   │       ├── login_screen.dart
│   │   │       ├── signup_screen.dart
│   │   │       └── widgets/
│   │   ├── conversations/
│   │   │   ├── data/
│   │   │   │   └── conversations_repository.dart
│   │   │   ├── domain/
│   │   │   │   ├── conversation.dart     # model
│   │   │   │   └── conversations_providers.dart
│   │   │   └── presentation/
│   │   │       ├── conversations_list_screen.dart
│   │   │       └── widgets/
│   │   │           └── conversation_tile.dart
│   │   ├── chat/
│   │   │   ├── data/
│   │   │   │   ├── chat_repository.dart  # talks to Edge Function + DB
│   │   │   │   └── messages_repository.dart
│   │   │   ├── domain/
│   │   │   │   ├── message.dart          # model
│   │   │   │   └── chat_providers.dart
│   │   │   └── presentation/
│   │   │       ├── chat_screen.dart
│   │   │       └── widgets/
│   │   │           ├── message_bubble.dart
│   │   │           ├── chat_input.dart
│   │   │           └── typing_indicator.dart
│   │   └── settings/
│   │       └── presentation/
│   │           └── settings_screen.dart  # sign out, theme toggle, about
│   └── shared/
│       └── extensions/                   # date formatting, etc.
├── test/
│   ├── features/
│   │   ├── auth/
│   │   └── chat/
│   └── widget_test.dart
└── supabase/
    ├── config.toml
    ├── migrations/
    │   └── 001_initial_schema.sql
    └── functions/
        └── chat/
            ├── index.ts                   # Edge Function entrypoint
            └── deno.json
```

## Data Model

```sql
-- Users come from auth.users (Supabase Auth). No custom users table.

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

create index messages_conversation_id_idx on public.messages(conversation_id, created_at);
create index conversations_user_id_idx on public.conversations(user_id, updated_at desc);
```

**Row Level Security (required, not optional):**
- `conversations`: SELECT/INSERT/UPDATE/DELETE only where `user_id = auth.uid()`.
- `messages`: SELECT/INSERT only where the parent conversation belongs to `auth.uid()`.

## Schema changes

Every DB change is a new numbered migration in `supabase/migrations/` (`NNN_<slug>.sql`). Apply via `supabase db push` once the project is linked, or paste into the dashboard SQL Editor. Don't mutate existing migration files after they've been applied — add a new one instead.

Two recurring patterns to follow when adding tables:

- **Realtime publication.** If the mobile client needs live updates for a new table, add `alter publication supabase_realtime add table public.<table>;` in the same migration. Without it, `client.from(...).stream(...)` returns the initial snapshot and never receives further events. We've hit this twice (conversations in 002, messages in 003).
- **Implicit `user_id` via `default auth.uid()`.** For any user-owned table, prefer `user_id uuid not null default auth.uid() references auth.users(id) on delete cascade`. Clients can then insert without sending `user_id` and never leak the caller's id into client code; RLS still enforces `auth.uid() = user_id`.

## Edge Function: `chat`

Single endpoint that the mobile app calls. It:

1. Verifies the Supabase JWT (default `verify_jwt = true` in `config.toml`).
2. Reads `{ conversation_id, user_message }` from the request body.
3. Inserts the user message into `public.messages`.
4. Loads the last N messages (default 20) from this conversation as Anthropic-format history.
5. Calls Anthropic's `messages` endpoint with that history + a system prompt.
6. Inserts the assistant response into `public.messages`.
7. If this is the first message in the conversation, generates a short title (a second tiny Claude call) and updates `conversations.title`.
8. Returns `{ assistant_message: { id, content, created_at } }`.

For v1, the function is **non-streaming**. Streaming is a Prompt 9 enhancement.

Secrets (set with `supabase secrets set`):
- `ANTHROPIC_API_KEY` — required.
- `CLAUDE_MODEL` — optional, fallback `claude-opus-4-7`.
- `CLAUDE_SYSTEM_PROMPT` — optional, fallback is the built-in prompt in `index.ts`.
- `CLAUDE_MAX_TOKENS` — optional integer, fallback `1024`. Invalid values fall back silently.
- `CLAUDE_TEMPERATURE` — optional float, fallback `0.7`, clamped to `[0, 1]`.

All four are re-read on every request, so changes via `supabase secrets set …` take effect with no redeploy. They only apply to the main chat call — the title-generation call uses its own fixed parameters.

Environment provided automatically by Supabase:
- `SUPABASE_URL`
- `SUPABASE_ANON_KEY`
- `SUPABASE_SERVICE_ROLE_KEY` (avoid using this; prefer the user's JWT so RLS applies)

## Mobile App Configuration

Configuration is passed at build time via `--dart-define`, not committed to the repo:

```
SUPABASE_URL=https://<project>.supabase.co
SUPABASE_ANON_KEY=eyJ...                   # publishable, safe to ship in the app
```

`.env.example` documents these. Read them through `String.fromEnvironment` in `lib/core/config/env.dart`. The mobile app **never** has the Anthropic API key or the Supabase service-role key.

Run command for dev:
```
flutter run \
  --dart-define=SUPABASE_URL=https://xyz.supabase.co \
  --dart-define=SUPABASE_ANON_KEY=eyJ...
```

## UX Requirements (non-negotiable)

1. **Dark mode by default.** Light mode toggleable in Settings. Persist the choice.
2. **Auth gate.** Unauthenticated users see Login/Signup. Authenticated users land on the conversations list. Use `go_router` redirects with the auth state.
3. **Conversations list.** Newest first. Each row shows the title + a snippet of the last message + relative time ("2m ago"). Tap to open. Long-press to delete (with confirmation).
4. **Chat screen.**
   - Message bubbles: user right-aligned (accent color), assistant left-aligned (surface variant).
   - AI messages render markdown (bold, code blocks, lists).
   - "Thinking…" indicator while waiting for a response.
   - Input is a text field with a send button. Send on tap or Cmd/Ctrl+Enter on physical keyboards.
   - Scroll to bottom on new message and on screen open.
   - Disable the send button while a request is in flight.
5. **Empty states.** Conversations list when empty shows "Start your first chat". Chat screen when empty shows a friendly prompt suggestion.
6. **Errors.** Network errors show a non-blocking SnackBar with a "Retry" action. Never silently swallow errors.
7. **Performance.** No jank when scrolling 100+ messages. Use `ListView.builder`.

## Coding Conventions

- **Strict null safety** everywhere.
- Prefer **immutable models** (`@immutable`, `freezed` is OK to introduce in Prompt 3 if you want).
- **One feature per folder**, three layers per feature: `data`, `domain`, `presentation`. Don't import `presentation` from `data`.
- Riverpod (3.x with `riverpod_generator` 4.x): use `@riverpod` / `@Riverpod(keepAlive: true)` code-gen-style providers.
  - Regenerate after editing annotated files: `dart run build_runner build`. The legacy `--delete-conflicting-outputs` flag has been removed in current `build_runner` — it's the default now and passing it prints a warning.
  - `AsyncValue<T>` no longer exposes `.valueOrNull` in 3.x. Read async values with a Dart 3 pattern match (`switch (async) { AsyncData(:final value) => value, _ => null }`) or `whenOrNull(data: ...)`.
- Repositories return plain Dart types or throw typed exceptions. Providers handle async state.
- When a repository's typed exception name would collide with a Supabase SDK type (e.g. our `AuthException` vs `supabase_flutter`'s `AuthException`), keep our own name and import the Supabase package with a prefix (`as supabase`) inside the repository file. Downstream code then only sees our exception type — no `show`/`hide` gymnastics elsewhere.
- No business logic in widgets. Widgets read providers and call repository methods.
- Run `dart format .` and `flutter analyze` clean before declaring a prompt complete.

## Security Requirements

- The Anthropic API key lives ONLY in the Edge Function's `ANTHROPIC_API_KEY` secret. It is never bundled into the mobile app, never logged, never returned in responses.
- Row Level Security is enabled on every table. Every `select`/`insert`/`update`/`delete` policy is tested manually before shipping (use the SQL editor "Run as authenticated user" feature).
- The mobile app uses only the Supabase publishable (anon) key. Anon key in a mobile binary is expected — RLS is what protects the data.
- Edge Function logs do not include message content beyond the truncated first 50 chars for debugging. No JWTs, no API keys.

## What NOT to Do

- Do NOT add a Node.js backend. The whole point is to demonstrate a Supabase-only architecture.
- Do NOT put the Anthropic API key in the Flutter app — not in `.env`, not in `pubspec.yaml`, not in Dart code.
- Do NOT skip RLS. Test that User A cannot read User B's conversations.
- Do NOT log message content in the Edge Function beyond a 50-char prefix.
- Do NOT use the service role key from the Edge Function unless absolutely necessary; rely on the caller's JWT so RLS applies.
- Do NOT introduce `setState`-only state management in feature code. Use Riverpod.
- Do NOT hardcode colors. Always pull from the theme.
- Do NOT commit `.env` or any Supabase/Anthropic keys.
- DO commit `*.g.dart` files produced by `build_runner`. They're treated as source so CI/clones don't need a codegen step.

## Testing Standards

- Unit tests for repositories (mock the Supabase client).
- Widget tests for `LoginScreen`, `ChatScreen` message rendering, and `ConversationsListScreen`.
- One integration test (using `integration_test` package) that logs in a seeded test user and sends a message, against a local Supabase instance.
- Edge Function test: a Deno test that mocks the Anthropic API and verifies the function inserts both messages and returns the expected shape.
- Run `flutter test` clean before declaring done.

## Future Work (out of scope for v1, document in README)

- Streaming responses (SSE from Edge Function → Flutter)
- Voice input
- Image attachments (Claude vision)
- Per-conversation system prompts ("Adapt to different tones and styles")
- Push notifications for long-running responses
- Export conversation as markdown
- Multi-device sync indicator
