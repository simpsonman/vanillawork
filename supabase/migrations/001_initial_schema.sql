-- vanillawork initial schema
-- PostgreSQL (Supabase) — UUID primary keys

-- ── Enum types ──────────────────────────────────────

CREATE TYPE member_role       AS ENUM ('OWNER','ADMIN','MANAGER','EMPLOYEE');
CREATE TYPE member_status     AS ENUM ('PENDING','ACTIVE','REJECTED','INVITED','LEFT');
CREATE TYPE leave_unit        AS ENUM ('DAY','HOUR');
CREATE TYPE ledger_reason     AS ENUM ('ACCRUAL','USAGE','ADJUST','EXPIRE');
CREATE TYPE request_status    AS ENUM ('PENDING','APPROVED','REJECTED','CANCELED');
CREATE TYPE attendance_status AS ENUM ('NORMAL','LEAVE','ABSENT','ETC');
CREATE TYPE attendance_source AS ENUM ('AUTO','MANUAL','INTEGRATION');
CREATE TYPE blackout_policy   AS ENUM ('HARD','SOFT');
CREATE TYPE blackout_scope    AS ENUM ('COMPANY','DEPARTMENT','USER');
CREATE TYPE accrual_basis     AS ENUM ('HIRE_DATE','FISCAL_YEAR');
CREATE TYPE apply_mode        AS ENUM ('FORCE_GLOBAL');

-- ── Users ───────────────────────────────────────────

CREATE TABLE IF NOT EXISTS public.users (
  id         UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  google_sub TEXT UNIQUE NOT NULL,
  email      TEXT NOT NULL,
  name       TEXT NOT NULL,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- ── Companies ───────────────────────────────────────

CREATE TABLE IF NOT EXISTS public.companies (
  id         UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name       TEXT NOT NULL,
  timezone   TEXT NOT NULL DEFAULT 'Asia/Seoul',
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- ── Departments ─────────────────────────────────────

CREATE TABLE IF NOT EXISTS public.departments (
  id         UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  company_id UUID NOT NULL REFERENCES public.companies(id) ON DELETE CASCADE,
  name       TEXT NOT NULL,
  parent_id  UUID REFERENCES public.departments(id) ON DELETE SET NULL
);
CREATE INDEX idx_departments_company ON public.departments(company_id);

-- ── Company Memberships ─────────────────────────────

CREATE TABLE IF NOT EXISTS public.company_memberships (
  id            UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  company_id    UUID NOT NULL REFERENCES public.companies(id) ON DELETE CASCADE,
  user_id       UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
  role          member_role    NOT NULL DEFAULT 'EMPLOYEE',
  department_id UUID REFERENCES public.departments(id) ON DELETE SET NULL,
  status        member_status  NOT NULL DEFAULT 'PENDING',
  joined_at     TIMESTAMPTZ,
  UNIQUE(company_id, user_id)
);
CREATE INDEX idx_memberships_company ON public.company_memberships(company_id);
CREATE INDEX idx_memberships_user    ON public.company_memberships(user_id);

-- ── Work Policies ───────────────────────────────────

CREATE TABLE IF NOT EXISTS public.work_policies (
  id                           UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  company_id                   UUID UNIQUE NOT NULL REFERENCES public.companies(id) ON DELETE CASCADE,
  accrual_basis                accrual_basis NOT NULL DEFAULT 'HIRE_DATE',
  fiscal_year_start_mmdd       TEXT,
  allow_hourly_leave           BOOLEAN NOT NULL DEFAULT false,
  overtime_weekly_limit_minutes INT NOT NULL DEFAULT 720,
  created_at                   TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at                   TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- ── Leave Types ─────────────────────────────────────

CREATE TABLE IF NOT EXISTS public.leave_types (
  id           UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  company_id   UUID NOT NULL REFERENCES public.companies(id) ON DELETE CASCADE,
  code         TEXT NOT NULL,
  name         TEXT NOT NULL,
  unit         leave_unit NOT NULL DEFAULT 'DAY',
  paid         BOOLEAN NOT NULL DEFAULT true,
  is_statutory BOOLEAN NOT NULL DEFAULT false,
  is_active    BOOLEAN NOT NULL DEFAULT true,
  UNIQUE(company_id, code)
);
CREATE INDEX idx_leave_types_company ON public.leave_types(company_id);

-- ── Statutory Policy Versions ───────────────────────

CREATE TABLE IF NOT EXISTS public.statutory_policy_versions (
  id                        UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  version_code              TEXT NOT NULL,
  effective_from            DATE NOT NULL,
  effective_to              DATE,
  rules_json                JSONB NOT NULL DEFAULT '{}',
  is_active                 BOOLEAN NOT NULL DEFAULT false,
  created_by_platform_admin UUID REFERENCES public.users(id),
  created_at                TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- ── Company Statutory Policy Link ───────────────────

CREATE TABLE IF NOT EXISTS public.company_statutory_policy_links (
  company_id                   UUID UNIQUE NOT NULL REFERENCES public.companies(id) ON DELETE CASCADE,
  statutory_policy_version_id  UUID NOT NULL REFERENCES public.statutory_policy_versions(id),
  applied_at                   TIMESTAMPTZ NOT NULL DEFAULT now(),
  applied_by                   TEXT NOT NULL DEFAULT 'SYSTEM',
  apply_mode                   apply_mode NOT NULL DEFAULT 'FORCE_GLOBAL',
  PRIMARY KEY (company_id)
);

-- ── Leave Ledger ────────────────────────────────────

CREATE TABLE IF NOT EXISTS public.leave_ledger (
  id            UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  company_id    UUID NOT NULL REFERENCES public.companies(id) ON DELETE CASCADE,
  user_id       UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
  leave_type_id UUID NOT NULL REFERENCES public.leave_types(id),
  occurred_at   TIMESTAMPTZ NOT NULL DEFAULT now(),
  amount        NUMERIC NOT NULL,
  reason_type   ledger_reason NOT NULL,
  ref_type      TEXT,
  ref_id        UUID,
  memo          TEXT,
  created_by    UUID REFERENCES public.users(id),
  created_at    TIMESTAMPTZ NOT NULL DEFAULT now()
);
CREATE INDEX idx_ledger_company ON public.leave_ledger(company_id);
CREATE INDEX idx_ledger_user    ON public.leave_ledger(user_id);
CREATE INDEX idx_ledger_type    ON public.leave_ledger(leave_type_id);

-- ── Leave Requests ──────────────────────────────────

CREATE TABLE IF NOT EXISTS public.leave_requests (
  id            UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  company_id    UUID NOT NULL REFERENCES public.companies(id) ON DELETE CASCADE,
  user_id       UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
  leave_type_id UUID NOT NULL REFERENCES public.leave_types(id),
  start_at      DATE NOT NULL,
  end_at        DATE NOT NULL,
  amount        NUMERIC NOT NULL,
  status        request_status NOT NULL DEFAULT 'PENDING',
  approver_id   UUID REFERENCES public.users(id),
  decided_at    TIMESTAMPTZ,
  comment       TEXT,
  created_at    TIMESTAMPTZ NOT NULL DEFAULT now()
);
CREATE INDEX idx_leave_requests_company ON public.leave_requests(company_id);
CREATE INDEX idx_leave_requests_user    ON public.leave_requests(user_id);

-- ── Attendance Daily ────────────────────────────────

CREATE TABLE IF NOT EXISTS public.attendance_daily (
  id                UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  company_id        UUID NOT NULL REFERENCES public.companies(id) ON DELETE CASCADE,
  user_id           UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
  date              DATE NOT NULL,
  scheduled_minutes INT NOT NULL DEFAULT 480,
  worked_minutes    INT NOT NULL DEFAULT 0,
  break_minutes     INT NOT NULL DEFAULT 0,
  status            attendance_status NOT NULL DEFAULT 'NORMAL',
  source            attendance_source NOT NULL DEFAULT 'AUTO',
  UNIQUE(company_id, user_id, date)
);
CREATE INDEX idx_attendance_company ON public.attendance_daily(company_id);
CREATE INDEX idx_attendance_user    ON public.attendance_daily(user_id);

-- ── Overtime Requests ───────────────────────────────

CREATE TABLE IF NOT EXISTS public.overtime_requests (
  id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  company_id  UUID NOT NULL REFERENCES public.companies(id) ON DELETE CASCADE,
  user_id     UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
  start_at    TIMESTAMPTZ NOT NULL,
  end_at      TIMESTAMPTZ NOT NULL,
  minutes     INT NOT NULL,
  status      request_status NOT NULL DEFAULT 'PENDING',
  approver_id UUID REFERENCES public.users(id),
  decided_at  TIMESTAMPTZ,
  reason      TEXT,
  created_at  TIMESTAMPTZ NOT NULL DEFAULT now()
);
CREATE INDEX idx_overtime_company ON public.overtime_requests(company_id);
CREATE INDEX idx_overtime_user    ON public.overtime_requests(user_id);

-- ── Leave Blackout Rules ────────────────────────────

CREATE TABLE IF NOT EXISTS public.leave_blackout_rules (
  id           UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  company_id   UUID NOT NULL REFERENCES public.companies(id) ON DELETE CASCADE,
  scope_type   blackout_scope NOT NULL DEFAULT 'COMPANY',
  scope_id     UUID,
  start_at     DATE NOT NULL,
  end_at       DATE NOT NULL,
  policy       blackout_policy NOT NULL DEFAULT 'HARD',
  reason       TEXT,
  repeat_rrule TEXT,
  is_active    BOOLEAN NOT NULL DEFAULT true,
  created_by   UUID NOT NULL REFERENCES public.users(id),
  created_at   TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at   TIMESTAMPTZ NOT NULL DEFAULT now()
);
CREATE INDEX idx_blackout_company ON public.leave_blackout_rules(company_id);

-- ── Audit Logs ──────────────────────────────────────

CREATE TABLE IF NOT EXISTS public.audit_logs (
  id             UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  company_id     UUID NOT NULL REFERENCES public.companies(id) ON DELETE CASCADE,
  actor_user_id  UUID REFERENCES public.users(id),
  action         TEXT NOT NULL,
  target_type    TEXT NOT NULL,
  target_id      UUID NOT NULL,
  diff_json      JSONB,
  created_at     TIMESTAMPTZ NOT NULL DEFAULT now(),
  ip             TEXT,
  user_agent     TEXT
);
CREATE INDEX idx_audit_company ON public.audit_logs(company_id);
