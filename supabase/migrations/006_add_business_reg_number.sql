-- 006_add_business_reg_number.sql
-- Add business_registration_number to companies table and update RPC

-- 1. Add column to companies
ALTER TABLE public.companies
ADD COLUMN IF NOT EXISTS business_registration_number TEXT UNIQUE;

-- 2. Update the RPC to accept business_registration_number
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

  -- 2. Insert the membership as OWNER 
  INSERT INTO public.company_memberships (company_id, user_id, role, status)
  VALUES (v_company.id, auth.uid(), 'OWNER', 'ACTIVE');

  RETURN v_company;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
