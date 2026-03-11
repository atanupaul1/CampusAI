-- ============================================================
-- Campus AI Assistant — Supabase Database Migration
-- Run this entire script in the Supabase SQL Editor (one shot).
-- It creates all tables, enums, indexes, and RLS policies.
-- ============================================================

-- Enable the pgvector extension for FAQ embeddings (semantic search)
CREATE EXTENSION IF NOT EXISTS vector;

-- --------------------------------------------------------
-- 1. users
-- --------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.users (
    id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    email       TEXT UNIQUE NOT NULL,
    display_name TEXT,
    avatar_url  TEXT,
    role        TEXT DEFAULT 'user',
    created_at  TIMESTAMPTZ DEFAULT now()
);

ALTER TABLE public.users ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can read own profile"
    ON public.users FOR SELECT
    USING (auth.uid() = id);

CREATE POLICY "Users can update own profile"
    ON public.users FOR UPDATE
    USING (auth.uid() = id);

CREATE POLICY "Allow insert for authenticated users"
    ON public.users FOR INSERT
    WITH CHECK (auth.uid() = id);

-- --------------------------------------------------------
-- 2. chat_sessions
-- --------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.chat_sessions (
    id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id     UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
    title       TEXT DEFAULT 'New Chat',
    created_at  TIMESTAMPTZ DEFAULT now(),
    updated_at  TIMESTAMPTZ DEFAULT now()
);

ALTER TABLE public.chat_sessions ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can CRUD own sessions"
    ON public.chat_sessions FOR ALL
    USING (auth.uid() = user_id);

CREATE INDEX idx_chat_sessions_user ON public.chat_sessions(user_id);

-- --------------------------------------------------------
-- 3. chat_messages
-- --------------------------------------------------------
CREATE TYPE public.message_role AS ENUM ('user', 'assistant');

CREATE TABLE IF NOT EXISTS public.chat_messages (
    id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    session_id  UUID NOT NULL REFERENCES public.chat_sessions(id) ON DELETE CASCADE,
    role        public.message_role NOT NULL,
    content     TEXT NOT NULL,
    created_at  TIMESTAMPTZ DEFAULT now()
);

ALTER TABLE public.chat_messages ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can CRUD own messages"
    ON public.chat_messages FOR ALL
    USING (
        EXISTS (
            SELECT 1 FROM public.chat_sessions cs
            WHERE cs.id = chat_messages.session_id
              AND cs.user_id = auth.uid()
        )
    );

CREATE INDEX idx_chat_messages_session ON public.chat_messages(session_id, created_at);

-- --------------------------------------------------------
-- 4. campus_events
-- --------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.campus_events (
    id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    title       TEXT NOT NULL,
    description TEXT,
    location    TEXT,
    start_time  TIMESTAMPTZ,
    end_time    TIMESTAMPTZ,
    category    TEXT,
    source_url  TEXT,
    created_at  TIMESTAMPTZ DEFAULT now()
);

ALTER TABLE public.campus_events ENABLE ROW LEVEL SECURITY;

-- Events are public-read
CREATE POLICY "Anyone can read events"
    ON public.campus_events FOR SELECT
    USING (true);

-- Only service_role or Admins can insert/update
CREATE POLICY "Admins and Service role can manage events"
    ON public.campus_events FOR ALL
    USING (
        auth.role() = 'service_role' 
        OR EXISTS (
            SELECT 1 FROM public.users 
            WHERE users.id = auth.uid() 
            AND users.role = 'admin'
        )
    );

CREATE INDEX idx_campus_events_category ON public.campus_events(category);
CREATE INDEX idx_campus_events_start ON public.campus_events(start_time);

-- --------------------------------------------------------
-- 5. campus_faqs
-- --------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.campus_faqs (
    id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    question    TEXT NOT NULL,
    answer      TEXT NOT NULL,
    category    TEXT,
    embedding   vector(768),  -- for semantic search (matches common embedding sizes)
    created_at  TIMESTAMPTZ DEFAULT now()
);

ALTER TABLE public.campus_faqs ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Anyone can read FAQs"
    ON public.campus_faqs FOR SELECT
    USING (true);

CREATE POLICY "Admins and Service role can manage FAQs"
    ON public.campus_faqs FOR ALL
    USING (
        auth.role() = 'service_role'
        OR EXISTS (
            SELECT 1 FROM public.users 
            WHERE users.id = auth.uid() 
            AND users.role = 'admin'
        )
    );

-- ============================================================
-- Done! Verify by checking the Table Editor in Supabase.
-- ============================================================
