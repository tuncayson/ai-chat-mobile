// Edge Function: chat
//
// Proxies user messages to Anthropic's Claude API, persists the user and
// assistant messages, and (on the first turn) generates a short title for
// the conversation. Every Supabase call runs under the caller's JWT so
// Row Level Security applies — the ANTHROPIC_API_KEY never leaves this
// function and is never returned in the response.

import '@supabase/functions-js/edge-runtime.d.ts';
import { createClient } from 'jsr:@supabase/supabase-js@2';

// ---------------------------------------------------------------------------
// Constants
// ---------------------------------------------------------------------------

const MAX_USER_MESSAGE_LENGTH = 8000;
const HISTORY_LIMIT = 20;
const DEFAULT_MODEL = 'claude-opus-4-7';
const DEFAULT_MAX_TOKENS = 1024;
const DEFAULT_TEMPERATURE = 0.7;
const DEFAULT_SYSTEM_PROMPT =
  "You are a helpful, friendly AI assistant in a personal chat app. " +
  "Be concise but warm. Adapt your tone to match the user's. " +
  'Use markdown for formatting when helpful.';

const CORS_HEADERS: Record<string, string> = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers':
    'authorization, x-client-info, apikey, content-type',
  'Access-Control-Allow-Methods': 'POST, OPTIONS',
};

// ---------------------------------------------------------------------------
// Types
// ---------------------------------------------------------------------------

interface ChatRequestBody {
  conversation_id?: unknown;
  user_message?: unknown;
}

interface AnthropicTextBlock {
  type: 'text';
  text: string;
}

interface AnthropicResponse {
  content?: Array<AnthropicTextBlock | { type: string }>;
}

interface AnthropicMessage {
  role: 'user' | 'assistant';
  content: string;
}

// ---------------------------------------------------------------------------
// Handler
// ---------------------------------------------------------------------------

Deno.serve(async (req) => {
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: CORS_HEADERS });
  }
  if (req.method !== 'POST') {
    return json({ error: 'method_not_allowed' }, 405);
  }

  // --- Validate body --------------------------------------------------------
  let body: ChatRequestBody;
  try {
    body = await req.json();
  } catch {
    return json({ error: 'invalid_json' }, 400);
  }

  const conversationId =
    typeof body.conversation_id === 'string' ? body.conversation_id : null;
  const userMessage =
    typeof body.user_message === 'string' ? body.user_message : null;

  if (!conversationId) {
    return json({ error: 'missing_conversation_id' }, 400);
  }
  if (!userMessage || userMessage.trim().length === 0) {
    return json({ error: 'empty_user_message' }, 400);
  }
  if (userMessage.length > MAX_USER_MESSAGE_LENGTH) {
    return json(
      { error: 'user_message_too_long', limit: MAX_USER_MESSAGE_LENGTH },
      400,
    );
  }

  // --- Build a caller-scoped Supabase client -------------------------------
  const authHeader = req.headers.get('Authorization');
  if (!authHeader) {
    return json({ error: 'missing_authorization' }, 401);
  }

  const supabase = createClient(
    Deno.env.get('SUPABASE_URL')!,
    Deno.env.get('SUPABASE_ANON_KEY')!,
    { global: { headers: { Authorization: authHeader } } },
  );

  const { data: userData, error: userErr } = await supabase.auth.getUser();
  if (userErr || !userData.user) {
    return json({ error: 'unauthenticated' }, 401);
  }

  // --- Confirm conversation ownership (via RLS) ----------------------------
  const { data: conversation, error: convErr } = await supabase
    .from('conversations')
    .select('id, title')
    .eq('id', conversationId)
    .maybeSingle();
  if (convErr) {
    console.error('conversation lookup failed:', convErr.message);
    return json({ error: 'lookup_failed' }, 500);
  }
  if (!conversation) {
    return json({ error: 'conversation_not_found' }, 404);
  }

  // --- Persist the user message -------------------------------------------
  const { error: insertUserErr } = await supabase.from('messages').insert({
    conversation_id: conversationId,
    role: 'user',
    content: userMessage,
  });
  if (insertUserErr) {
    console.error('insert user message failed:', insertUserErr.message);
    return json({ error: 'persist_failed' }, 500);
  }

  // --- Load recent history (oldest → newest, includes just-inserted) ------
  const { data: history, error: historyErr } = await supabase
    .from('messages')
    .select('role, content, created_at')
    .eq('conversation_id', conversationId)
    .order('created_at', { ascending: true })
    .limit(HISTORY_LIMIT);
  if (historyErr || !history) {
    console.error('load history failed:', historyErr?.message);
    return json({ error: 'history_failed' }, 500);
  }

  const anthropicMessages: AnthropicMessage[] = history.map((m) => ({
    role: m.role as 'user' | 'assistant',
    content: m.content as string,
  }));

  // --- Call Anthropic ------------------------------------------------------
  const model = currentModel();
  let assistantText: string;
  try {
    assistantText = await callAnthropic({
      model,
      max_tokens: currentMaxTokens(),
      temperature: currentTemperature(),
      system: currentSystemPrompt(),
      messages: anthropicMessages,
    });
  } catch (err) {
    console.error('anthropic call failed:', (err as Error).message);
    return json({ error: 'upstream_failed' }, 502);
  }

  // --- Persist the assistant message --------------------------------------
  const { data: assistantRow, error: insertAssistantErr } = await supabase
    .from('messages')
    .insert({
      conversation_id: conversationId,
      role: 'assistant',
      content: assistantText,
    })
    .select('id, content, created_at')
    .single();
  if (insertAssistantErr || !assistantRow) {
    console.error(
      'insert assistant message failed:',
      insertAssistantErr?.message,
    );
    return json({ error: 'persist_failed' }, 500);
  }

  // --- First-turn title generation (best-effort) --------------------------
  // history was loaded after the user message insert but before the
  // assistant insert, so length === 1 means total messages will be 2 once
  // this response returns.
  if (history.length === 1) {
    try {
      const raw = await callAnthropic({
        model,
        max_tokens: 32,
        system: 'You generate concise conversation titles.',
        messages: [
          {
            role: 'user',
            content:
              'Summarize this conversation in 3-6 words as a title. ' +
              'No quotes, no punctuation at the end. ' +
              `Conversation: ${userMessage}`,
          },
        ],
      });
      const cleaned = raw.replace(/^["'\s]+|["'\s.!?]+$/g, '').trim();
      if (cleaned.length > 0) {
        const { error: titleErr } = await supabase
          .from('conversations')
          .update({ title: cleaned })
          .eq('id', conversationId);
        if (titleErr) {
          console.error('title update failed:', titleErr.message);
        }
      }
    } catch (err) {
      console.error('title generation failed:', (err as Error).message);
    }
  }

  return json(
    {
      assistant_message: {
        id: assistantRow.id,
        content: assistantRow.content,
        created_at: assistantRow.created_at,
      },
    },
    200,
  );
});

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Returns the model to call. Reads `CLAUDE_MODEL` from the function's
/// environment on every request so the value can be swapped at runtime
/// via `supabase secrets set CLAUDE_MODEL=...` — no redeploy required.
function currentModel(): string {
  const fromEnv = Deno.env.get('CLAUDE_MODEL');
  return fromEnv && fromEnv.length > 0 ? fromEnv : DEFAULT_MODEL;
}

/// System prompt for the main chat call. Override via
/// `supabase secrets set CLAUDE_SYSTEM_PROMPT="..."`.
function currentSystemPrompt(): string {
  const fromEnv = Deno.env.get('CLAUDE_SYSTEM_PROMPT');
  return fromEnv && fromEnv.length > 0 ? fromEnv : DEFAULT_SYSTEM_PROMPT;
}

/// Anthropic `max_tokens` for the main chat call. Falls back to the
/// default on missing / non-numeric / non-positive values.
function currentMaxTokens(): number {
  const raw = Deno.env.get('CLAUDE_MAX_TOKENS');
  if (!raw) return DEFAULT_MAX_TOKENS;
  const parsed = Number.parseInt(raw, 10);
  if (!Number.isFinite(parsed) || parsed <= 0) return DEFAULT_MAX_TOKENS;
  return parsed;
}

/// Anthropic `temperature` for the main chat call. Clamped to [0, 1];
/// falls back to the default on missing / non-numeric values.
function currentTemperature(): number {
  const raw = Deno.env.get('CLAUDE_TEMPERATURE');
  if (!raw) return DEFAULT_TEMPERATURE;
  const parsed = Number.parseFloat(raw);
  if (!Number.isFinite(parsed)) return DEFAULT_TEMPERATURE;
  return Math.min(1, Math.max(0, parsed));
}

function json(payload: unknown, status: number): Response {
  return new Response(JSON.stringify(payload), {
    status,
    headers: {
      ...CORS_HEADERS,
      'Content-Type': 'application/json',
    },
  });
}

async function callAnthropic(
  payload: {
    model: string;
    max_tokens: number;
    system: string;
    messages: AnthropicMessage[];
    temperature?: number;
  },
): Promise<string> {
  const apiKey = Deno.env.get('ANTHROPIC_API_KEY');
  if (!apiKey) {
    throw new Error('ANTHROPIC_API_KEY not set');
  }

  const res = await fetch('https://api.anthropic.com/v1/messages', {
    method: 'POST',
    headers: {
      'x-api-key': apiKey,
      'anthropic-version': '2023-06-01',
      'content-type': 'application/json',
    },
    body: JSON.stringify(payload),
  });

  if (!res.ok) {
    // Log the upstream body for debugging but never return it to the client.
    const text = await res.text();
    throw new Error(`anthropic ${res.status}: ${text.slice(0, 200)}`);
  }

  const data = (await res.json()) as AnthropicResponse;
  const firstBlock = data.content?.[0];
  if (!firstBlock || firstBlock.type !== 'text') {
    throw new Error('anthropic returned no text content');
  }
  return (firstBlock as AnthropicTextBlock).text;
}
