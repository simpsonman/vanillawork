-- 007_fix_infinite_recursion.sql
-- Fix infinite recursion in company_memberships RLS policies

-- Drop the existing policies that cause the recursion
DROP POLICY IF EXISTS "memberships_select_own" ON public.company_memberships;
DROP POLICY IF EXISTS "memberships_select_admin" ON public.company_memberships;

-- 1. Create a simplified, single SELECT policy for memberships.
-- A user can see a membership if:
-- a) It's their own membership.
-- OR
-- b) They are an ADMIN or OWNER in the same company.
-- To prevent recursion, we use a subquery that bypasses RLS (by checking the base table directly if we were to use a security definer function, or by being careful).
-- Actually, the best way to prevent recursion on `company_memberships` is to allow anyone to read memberships of companies they belong to.
-- Since this is an internal HR app, it's generally safe for any active member to see other members of the SAME company. 
-- Let's change the policy to: "A user can see memberships of companies they are an ACTIVE member of".
-- But even that might recurse if we query `company_memberships` to check `company_memberships`.
-- To completely avoid recursion on the same table, we can use the `get_my_membership` helper function we already have, OR just allow a user to see their own, and for admins, use a subquery without triggering policies again (not possible directly in SQL unless we use a SECURITY DEFINER function).

-- Fortunately, `get_my_membership(company_id)` is a SECURITY DEFINER function!
-- So we can use it to check the current user's role without triggering RLS on `company_memberships`.

CREATE POLICY "memberships_select" ON public.company_memberships
  FOR SELECT USING (
    -- 1. 본인의 멤버십 정보인 경우
    user_id = auth.uid()
    OR 
    -- 2. 해당 회사의 ADMIN 또는 OWNER인 경우 (보안 함수 get_my_membership 사용)
    (SELECT role FROM public.get_my_membership(company_id)) IN ('ADMIN', 'OWNER')
  );
