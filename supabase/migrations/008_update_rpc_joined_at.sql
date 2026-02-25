-- 008_update_rpc_joined_at.sql
-- Update the create_company_with_owner RPC to set joined_at for the owner

CREATE OR REPLACE FUNCTION public.create_company_with_owner(
  p_name text,
  p_timezone text,
  p_business_registration_number text
)
RETURNS public.companies AS $$
DECLARE
  v_company public.companies;
BEGIN
  -- 1. Insert the company
  INSERT INTO public.companies (name, timezone, business_registration_number)
  VALUES (p_name, p_timezone, p_business_registration_number)
  RETURNING * INTO v_company;

  -- 2. Insert the membership as OWNER with joined_at populated
  INSERT INTO public.company_memberships (company_id, user_id, role, status, joined_at)
  VALUES (v_company.id, auth.uid(), 'OWNER', 'ACTIVE', now());

  RETURN v_company;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
