-- ============================================================
-- 1. Add role column to users table
-- ============================================================
ALTER TABLE public.users ADD COLUMN IF NOT EXISTS role TEXT DEFAULT 'user';

-- ============================================================
-- 2. Update RLS Policies for campus_events
-- ============================================================
DROP POLICY IF EXISTS "Service role can manage events" ON public.campus_events;
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

-- ============================================================
-- 3. Update RLS Policies for campus_faqs
-- ============================================================
DROP POLICY IF EXISTS "Service role can manage FAQs" ON public.campus_faqs;
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
-- 4. Set yourself as Admin (Run this with your User ID)
-- ============================================================
-- UPDATE public.users SET role = 'admin' WHERE email = 'your-email@example.com';
