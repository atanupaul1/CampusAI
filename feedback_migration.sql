-- --------------------------------------------------------
-- 6. user_feedback
-- --------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.user_feedback (
    id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id     UUID REFERENCES public.users(id) ON DELETE SET NULL,
    category    TEXT NOT NULL, -- 'Bug', 'Feature', 'General'
    content     TEXT NOT NULL,
    rating      INT CHECK (rating >= 1 AND rating <= 5),
    is_resolved BOOLEAN DEFAULT false,
    created_at  TIMESTAMPTZ DEFAULT now()
);

ALTER TABLE public.user_feedback ENABLE ROW LEVEL SECURITY;

-- Users can insert their own feedback
CREATE POLICY "Users can insert own feedback"
    ON public.user_feedback FOR INSERT
    WITH CHECK (auth.uid() = user_id OR user_id IS NULL);

-- Users can read their own feedback
CREATE POLICY "Users can read own feedback"
    ON public.user_feedback FOR SELECT
    USING (auth.uid() = user_id);

-- Admins can manage all feedback
CREATE POLICY "Admins can manage all feedback"
    ON public.user_feedback FOR ALL
    USING (
        EXISTS (
            SELECT 1 FROM public.users 
            WHERE users.id = auth.uid() 
            AND users.role = 'admin'
        )
    );

CREATE INDEX idx_user_feedback_created ON public.user_feedback(created_at DESC);
