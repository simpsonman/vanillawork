-- 003_auth_trigger_sync.sql

-- 1. google_sub를 필수 값에서 해제 (구글 외 로그인 확장 시 또는 meta_data 파싱 오류 방지)
ALTER TABLE public.users ALTER COLUMN google_sub DROP NOT NULL;

-- 2. Drop trigger if exists
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
DROP FUNCTION IF EXISTS public.handle_new_user();

-- 3. Create function to handle new auth.users
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS trigger AS $$
BEGIN
  INSERT INTO public.users (id, google_sub, email, name)
  VALUES (
    new.id,
    COALESCE(new.raw_user_meta_data->>'provider_id', new.raw_user_meta_data->>'sub'),
    new.email,
    COALESCE(new.raw_user_meta_data->>'full_name', new.raw_user_meta_data->>'name', split_part(new.email, '@', 1))
  )
  ON CONFLICT (id) DO NOTHING;
  RETURN new;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 4. Create trigger on auth.users
CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE PROCEDURE public.handle_new_user();

-- 5. 이미 가입된 기존 유저들을 public.users에 강제로 동기화 (Backfill)
INSERT INTO public.users (id, google_sub, email, name)
SELECT 
  id,
  COALESCE(raw_user_meta_data->>'provider_id', raw_user_meta_data->>'sub'),
  email,
  COALESCE(raw_user_meta_data->>'full_name', raw_user_meta_data->>'name', split_part(email, '@', 1))
FROM auth.users
WHERE id NOT IN (SELECT id FROM public.users)
ON CONFLICT (id) DO NOTHING;
