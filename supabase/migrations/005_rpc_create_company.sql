-- 005_rpc_create_company.sql
-- Creates a company and an OWNER membership securely in one transaction

CREATE OR REPLACE FUNCTION public.create_company_with_owner(
  p_name text,
  p_timezone text
)
RETURNS public.companies AS $$
DECLARE
  v_company public.companies;
BEGIN
  -- 1. Insert the company
  INSERT INTO public.companies (name, timezone)
  VALUES (p_name, p_timezone)
  RETURNING * INTO v_company;

  -- 2. Insert the membership as OWNER (Bypasses RLS because it's a SECURITY DEFINER function or executed as postgres role)
  INSERT INTO public.company_memberships (company_id, user_id, role, status)
  VALUES (v_company.id, auth.uid(), 'OWNER', 'ACTIVE');

  RETURN v_company;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
