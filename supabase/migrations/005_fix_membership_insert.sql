-- Fix RLS policy for company_memberships to allow the first OWNER user to be inserted.
-- The current policy is: CREATE POLICY "memberships_insert_self" ON public.company_memberships FOR INSERT WITH CHECK (user_id = auth.uid());
-- But we also want to allow setting role='OWNER' during workspace creation if we are that user.

DROP POLICY IF EXISTS "memberships_insert_self" ON public.company_memberships;

CREATE POLICY "memberships_insert_self" ON public.company_memberships
  FOR INSERT WITH CHECK (user_id = auth.uid());
