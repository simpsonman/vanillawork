-- vanillawork RLS policies
-- deny-by-default: enable RLS on all tables, then add specific policies

-- ── Helper function: get current user's membership for a company ──

CREATE OR REPLACE FUNCTION public.get_my_membership(p_company_id UUID)
RETURNS TABLE(role member_role, status member_status, department_id UUID) AS $$
  SELECT cm.role, cm.status, cm.department_id
  FROM public.company_memberships cm
  WHERE cm.company_id = p_company_id
    AND cm.user_id = auth.uid()
  LIMIT 1;
$$ LANGUAGE sql SECURITY DEFINER STABLE;

-- ── Enable RLS on all tables ────────────────────────

ALTER TABLE public.users                          ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.companies                      ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.departments                    ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.company_memberships            ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.work_policies                  ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.leave_types                    ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.statutory_policy_versions      ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.company_statutory_policy_links ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.leave_ledger                   ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.leave_requests                 ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.attendance_daily               ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.overtime_requests              ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.leave_blackout_rules           ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.audit_logs                     ENABLE ROW LEVEL SECURITY;


-- ══════════════════════════════════════════════════════
--  Users
-- ══════════════════════════════════════════════════════

-- 본인 프로필 조회
CREATE POLICY "users_select_own" ON public.users
  FOR SELECT USING (id = auth.uid());

-- 같은 회사 멤버 조회 (이름/이메일 표시에 필요)
CREATE POLICY "users_select_same_company" ON public.users
  FOR SELECT USING (
    EXISTS (
      SELECT 1 FROM public.company_memberships cm1
      JOIN public.company_memberships cm2 ON cm1.company_id = cm2.company_id
      WHERE cm1.user_id = auth.uid()
        AND cm2.user_id = public.users.id
        AND cm1.status = 'ACTIVE'
        AND cm2.status = 'ACTIVE'
    )
  );


-- ══════════════════════════════════════════════════════
--  Companies
-- ══════════════════════════════════════════════════════

-- 인증된 사용자는 회사 목록(검색) 가능
CREATE POLICY "companies_select_authenticated" ON public.companies
  FOR SELECT USING (auth.uid() IS NOT NULL);

-- 인증된 사용자는 회사 생성 가능
CREATE POLICY "companies_insert_authenticated" ON public.companies
  FOR INSERT WITH CHECK (auth.uid() IS NOT NULL);


-- ══════════════════════════════════════════════════════
--  Departments
-- ══════════════════════════════════════════════════════

-- 회사 ACTIVE 멤버만 조회
CREATE POLICY "departments_select_member" ON public.departments
  FOR SELECT USING (
    EXISTS (
      SELECT 1 FROM public.company_memberships cm
      WHERE cm.company_id = departments.company_id
        AND cm.user_id = auth.uid()
        AND cm.status = 'ACTIVE'
    )
  );

-- ADMIN/OWNER만 부서 생성/수정
CREATE POLICY "departments_insert_admin" ON public.departments
  FOR INSERT WITH CHECK (
    EXISTS (
      SELECT 1 FROM public.company_memberships cm
      WHERE cm.company_id = departments.company_id
        AND cm.user_id = auth.uid()
        AND cm.status = 'ACTIVE'
        AND cm.role IN ('ADMIN','OWNER')
    )
  );

CREATE POLICY "departments_update_admin" ON public.departments
  FOR UPDATE USING (
    EXISTS (
      SELECT 1 FROM public.company_memberships cm
      WHERE cm.company_id = departments.company_id
        AND cm.user_id = auth.uid()
        AND cm.status = 'ACTIVE'
        AND cm.role IN ('ADMIN','OWNER')
    )
  );


-- ══════════════════════════════════════════════════════
--  Company Memberships
-- ══════════════════════════════════════════════════════

-- 본인 멤버십 조회
CREATE POLICY "memberships_select_own" ON public.company_memberships
  FOR SELECT USING (user_id = auth.uid());

-- ADMIN/OWNER: 회사 전체 멤버 조회
CREATE POLICY "memberships_select_admin" ON public.company_memberships
  FOR SELECT USING (
    EXISTS (
      SELECT 1 FROM public.company_memberships cm
      WHERE cm.company_id = company_memberships.company_id
        AND cm.user_id = auth.uid()
        AND cm.status = 'ACTIVE'
        AND cm.role IN ('ADMIN','OWNER')
    )
  );

-- 본인 가입 신청
CREATE POLICY "memberships_insert_self" ON public.company_memberships
  FOR INSERT WITH CHECK (user_id = auth.uid());

-- ADMIN/OWNER: 멤버십 상태/역할 변경
CREATE POLICY "memberships_update_admin" ON public.company_memberships
  FOR UPDATE USING (
    EXISTS (
      SELECT 1 FROM public.company_memberships cm
      WHERE cm.company_id = company_memberships.company_id
        AND cm.user_id = auth.uid()
        AND cm.status = 'ACTIVE'
        AND cm.role IN ('ADMIN','OWNER')
    )
  );


-- ══════════════════════════════════════════════════════
--  Work Policies
-- ══════════════════════════════════════════════════════

CREATE POLICY "work_policies_select_member" ON public.work_policies
  FOR SELECT USING (
    EXISTS (
      SELECT 1 FROM public.company_memberships cm
      WHERE cm.company_id = work_policies.company_id
        AND cm.user_id = auth.uid()
        AND cm.status = 'ACTIVE'
    )
  );

CREATE POLICY "work_policies_update_admin" ON public.work_policies
  FOR UPDATE USING (
    EXISTS (
      SELECT 1 FROM public.company_memberships cm
      WHERE cm.company_id = work_policies.company_id
        AND cm.user_id = auth.uid()
        AND cm.status = 'ACTIVE'
        AND cm.role IN ('ADMIN','OWNER')
    )
  );


-- ══════════════════════════════════════════════════════
--  Leave Types
-- ══════════════════════════════════════════════════════

CREATE POLICY "leave_types_select_member" ON public.leave_types
  FOR SELECT USING (
    EXISTS (
      SELECT 1 FROM public.company_memberships cm
      WHERE cm.company_id = leave_types.company_id
        AND cm.user_id = auth.uid()
        AND cm.status = 'ACTIVE'
    )
  );

CREATE POLICY "leave_types_insert_admin" ON public.leave_types
  FOR INSERT WITH CHECK (
    EXISTS (
      SELECT 1 FROM public.company_memberships cm
      WHERE cm.company_id = leave_types.company_id
        AND cm.user_id = auth.uid()
        AND cm.status = 'ACTIVE'
        AND cm.role IN ('ADMIN','OWNER')
    )
  );

CREATE POLICY "leave_types_update_admin" ON public.leave_types
  FOR UPDATE USING (
    EXISTS (
      SELECT 1 FROM public.company_memberships cm
      WHERE cm.company_id = leave_types.company_id
        AND cm.user_id = auth.uid()
        AND cm.status = 'ACTIVE'
        AND cm.role IN ('ADMIN','OWNER')
    )
  );


-- ══════════════════════════════════════════════════════
--  Statutory Policy Versions (플랫폼 — 공개 읽기 전용)
-- ══════════════════════════════════════════════════════

CREATE POLICY "statutory_versions_select" ON public.statutory_policy_versions
  FOR SELECT USING (auth.uid() IS NOT NULL);


-- ══════════════════════════════════════════════════════
--  Company Statutory Policy Link
-- ══════════════════════════════════════════════════════

CREATE POLICY "statutory_link_select_member" ON public.company_statutory_policy_links
  FOR SELECT USING (
    EXISTS (
      SELECT 1 FROM public.company_memberships cm
      WHERE cm.company_id = company_statutory_policy_links.company_id
        AND cm.user_id = auth.uid()
        AND cm.status = 'ACTIVE'
    )
  );


-- ══════════════════════════════════════════════════════
--  Leave Ledger
-- ══════════════════════════════════════════════════════

-- 본인 원장만 조회
CREATE POLICY "ledger_select_own" ON public.leave_ledger
  FOR SELECT USING (user_id = auth.uid());

-- ADMIN/OWNER: 회사 전체 원장 조회
CREATE POLICY "ledger_select_admin" ON public.leave_ledger
  FOR SELECT USING (
    EXISTS (
      SELECT 1 FROM public.company_memberships cm
      WHERE cm.company_id = leave_ledger.company_id
        AND cm.user_id = auth.uid()
        AND cm.status = 'ACTIVE'
        AND cm.role IN ('ADMIN','OWNER')
    )
  );


-- ══════════════════════════════════════════════════════
--  Leave Requests
-- ══════════════════════════════════════════════════════

-- 본인 신청 조회
CREATE POLICY "leave_requests_select_own" ON public.leave_requests
  FOR SELECT USING (user_id = auth.uid());

-- ADMIN/OWNER: 회사 전체 신청 조회
CREATE POLICY "leave_requests_select_admin" ON public.leave_requests
  FOR SELECT USING (
    EXISTS (
      SELECT 1 FROM public.company_memberships cm
      WHERE cm.company_id = leave_requests.company_id
        AND cm.user_id = auth.uid()
        AND cm.status = 'ACTIVE'
        AND cm.role IN ('ADMIN','OWNER')
    )
  );

-- ACTIVE 멤버: 신청 생성
CREATE POLICY "leave_requests_insert_member" ON public.leave_requests
  FOR INSERT WITH CHECK (
    user_id = auth.uid()
    AND EXISTS (
      SELECT 1 FROM public.company_memberships cm
      WHERE cm.company_id = leave_requests.company_id
        AND cm.user_id = auth.uid()
        AND cm.status = 'ACTIVE'
    )
  );

-- ADMIN/OWNER: 상태 변경 (승인/거부)
CREATE POLICY "leave_requests_update_admin" ON public.leave_requests
  FOR UPDATE USING (
    EXISTS (
      SELECT 1 FROM public.company_memberships cm
      WHERE cm.company_id = leave_requests.company_id
        AND cm.user_id = auth.uid()
        AND cm.status = 'ACTIVE'
        AND cm.role IN ('ADMIN','OWNER')
    )
  );

-- 본인 취소
CREATE POLICY "leave_requests_update_own_cancel" ON public.leave_requests
  FOR UPDATE USING (user_id = auth.uid() AND status = 'PENDING');


-- ══════════════════════════════════════════════════════
--  Attendance Daily
-- ══════════════════════════════════════════════════════

-- 본인 근태 조회
CREATE POLICY "attendance_select_own" ON public.attendance_daily
  FOR SELECT USING (user_id = auth.uid());

-- ADMIN/OWNER: 전체 조회
CREATE POLICY "attendance_select_admin" ON public.attendance_daily
  FOR SELECT USING (
    EXISTS (
      SELECT 1 FROM public.company_memberships cm
      WHERE cm.company_id = attendance_daily.company_id
        AND cm.user_id = auth.uid()
        AND cm.status = 'ACTIVE'
        AND cm.role IN ('ADMIN','OWNER')
    )
  );


-- ══════════════════════════════════════════════════════
--  Overtime Requests
-- ══════════════════════════════════════════════════════

CREATE POLICY "overtime_select_own" ON public.overtime_requests
  FOR SELECT USING (user_id = auth.uid());

CREATE POLICY "overtime_select_admin" ON public.overtime_requests
  FOR SELECT USING (
    EXISTS (
      SELECT 1 FROM public.company_memberships cm
      WHERE cm.company_id = overtime_requests.company_id
        AND cm.user_id = auth.uid()
        AND cm.status = 'ACTIVE'
        AND cm.role IN ('ADMIN','OWNER')
    )
  );

CREATE POLICY "overtime_insert_member" ON public.overtime_requests
  FOR INSERT WITH CHECK (
    user_id = auth.uid()
    AND EXISTS (
      SELECT 1 FROM public.company_memberships cm
      WHERE cm.company_id = overtime_requests.company_id
        AND cm.user_id = auth.uid()
        AND cm.status = 'ACTIVE'
    )
  );

CREATE POLICY "overtime_update_admin" ON public.overtime_requests
  FOR UPDATE USING (
    EXISTS (
      SELECT 1 FROM public.company_memberships cm
      WHERE cm.company_id = overtime_requests.company_id
        AND cm.user_id = auth.uid()
        AND cm.status = 'ACTIVE'
        AND cm.role IN ('ADMIN','OWNER')
    )
  );


-- ══════════════════════════════════════════════════════
--  Leave Blackout Rules
-- ══════════════════════════════════════════════════════

CREATE POLICY "blackout_select_member" ON public.leave_blackout_rules
  FOR SELECT USING (
    EXISTS (
      SELECT 1 FROM public.company_memberships cm
      WHERE cm.company_id = leave_blackout_rules.company_id
        AND cm.user_id = auth.uid()
        AND cm.status = 'ACTIVE'
    )
  );

CREATE POLICY "blackout_insert_admin" ON public.leave_blackout_rules
  FOR INSERT WITH CHECK (
    EXISTS (
      SELECT 1 FROM public.company_memberships cm
      WHERE cm.company_id = leave_blackout_rules.company_id
        AND cm.user_id = auth.uid()
        AND cm.status = 'ACTIVE'
        AND cm.role IN ('ADMIN','OWNER')
    )
  );

CREATE POLICY "blackout_update_admin" ON public.leave_blackout_rules
  FOR UPDATE USING (
    EXISTS (
      SELECT 1 FROM public.company_memberships cm
      WHERE cm.company_id = leave_blackout_rules.company_id
        AND cm.user_id = auth.uid()
        AND cm.status = 'ACTIVE'
        AND cm.role IN ('ADMIN','OWNER')
    )
  );


-- ══════════════════════════════════════════════════════
--  Audit Logs (ADMIN/OWNER 읽기 전용)
-- ══════════════════════════════════════════════════════

CREATE POLICY "audit_select_admin" ON public.audit_logs
  FOR SELECT USING (
    EXISTS (
      SELECT 1 FROM public.company_memberships cm
      WHERE cm.company_id = audit_logs.company_id
        AND cm.user_id = auth.uid()
        AND cm.status = 'ACTIVE'
        AND cm.role IN ('ADMIN','OWNER')
    )
  );
