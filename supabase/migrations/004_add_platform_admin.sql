-- 004_add_platform_admin.sql
-- Add is_platform_admin column to users table

ALTER TABLE public.users
ADD COLUMN IF NOT EXISTS is_platform_admin BOOLEAN NOT NULL DEFAULT false;

-- (Optional) Make a specific user a platform admin for initial setup.
-- You can uncomment and modify this after knowing the admin's email.
-- UPDATE public.users SET is_platform_admin = true WHERE email = 'admin@example.com';
