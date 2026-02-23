# vanillawork 개발 문서 (MVP+확장)

> 프론트엔드: **Nuxt 3** (Pinia, VueUse) + **shadcn-vue**  
> 백엔드: **Supabase** (Postgres + Auth + RLS + Edge Functions/CRON)

---

## 0. 문서 목적
이 문서는 **vanillawork**(근태/연차/추가근무 관리 서비스)를 **Codex/Claude Code로 바로 구현**할 수 있도록, **요구사항, 도메인 규칙, 데이터 모델, API 명세, 배치(Job), 권한(RBAC), Supabase 정책(RLS)**까지 개발 친화적으로 정리한다.

---

## 1. 서비스 개요

### 1.1 핵심 기능
- Google OAuth로 회원가입/로그인
- 회사(그룹) 생성 및 멤버십(입사 신청/관리자 초대)
- 근태(일 단위) 자동 생성/기록 및 열람
- 연차/휴가 정책(법정 기본 + 회사 커스텀)
- 연차 신청/승인(워크플로우) 및 캘린더 대시보드
- 관리자 연차 조정/부여(개인/부서/회사)
- 자동 부여/초기화(근속/월 개근/연초 등 회사 설정)
- 추가근무 신청/승인
- **연차 사용 불가 일정(블랙아웃) 등록 → 신청 차단/경고**
- 감사 로그(누가/언제/무엇을)

### 1.2 용어
- **회사(Company)**: 그룹(테넌트)
- **멤버십(Membership)**: 회사-사용자 소속/역할/상태
- **근태(AttendanceDaily)**: 일별 근무 기록
- **휴가 타입(LeaveType)**: 연차/병가/경조 등
- **원장(LeaveLedger)**: 부여/사용/조정/소멸 내역(잔여는 합산으로 계산)
- **블랙아웃(LeaveBlackoutRule)**: 연차 신청 금지/제한 기간
- **공용 캘린더(Event Summary)**: 회사 전체가 보는 “요약 일정” 피드

---

## 2. 사용자/권한(RBAC)

### 2.1 역할

#### 2.1.1 플랫폼(서비스 전체) 역할
- **PLATFORM_ADMIN**: vanillawork 전체 관리자  
  - 법정 최소 기준(기본 연차 규칙/템플릿) 업데이트 (**강제 일괄 적용**)  
  - 전사(전체 테넌트) 설정, 모니터링, 위험 정책(차단 룰) 관리  
  - 회사 데이터에 직접 개입은 원칙적으로 감사 로그/권한 통제 하에 제한(옵션)

#### 2.1.2 회사(테넌트) 역할
- **OWNER**: 회사 생성자(대표). 회사 내 최상위 권한
- **ADMIN**: HR/관리자. 회사 전체 조회 및 승인, 정책 일부 변경
- **MANAGER**: 팀장. 팀 단위 승인/조회(옵션)
- **EMPLOYEE**: 본인 신청/열람

> 회사 생성자 명칭은 `OWNER`를 기본으로 사용(권한 모델에 자연스럽게 매칭).

### 2.2 접근 규칙

#### 2.2.1 기본 원칙
- EMPLOYEE는 **원장(LeaveLedger) / 신청서 상세(LeaveRequest) / 근태 상세(AttendanceDaily)**에서 **타인의 상세 데이터**를 볼 수 없다.
- MANAGER는 **자기 범위(팀/지정 조직)**에 대해서만 상세 열람/승인 가능.
- ADMIN/OWNER는 회사 전체 상세 열람/승인 가능.

#### 2.2.2 예외: 회사 공용 캘린더(전체 일정) 가시성
회사 구성원은 **회사 공용 캘린더**에서 다음을 **모두 볼 수 있어야 한다**:
- 모든 구성원의 **연차/휴가 등록 현황(일정 형태)**
- 회사 공용 일정(행사/회의/교육/마감 등)

다만, 공용 캘린더에서 노출되는 정보는 **“일정 단위 요약”**로 제한한다.
- **노출 허용(기본)**: `이름(표시명)`, `부서`, `일정 종류(연차/병가/출장/회사행사 등)`, `기간(날짜/시간)`, `상태(APPROVED 여부)`
- **노출 제한(기본)**: `잔여 연차`, `원장 내역(부여/차감/조정)`, `신청 사유/첨부`, `정정 히스토리`, `근무시간 상세`

즉,
- EMPLOYEE는 **공용 캘린더에서 타인의 “휴가 일정”은 보되**, 타인의 **사용 내역/잔여/사유**는 볼 수 없다.
- MANAGER는 공용 캘린더는 전체를 보되, **상세 페이지(신청서/원장)**는 자기 범위만 가능.

#### 2.2.3 캘린더 공개 레벨(권장)
Event는 공개 레벨을 가진다.
- `PUBLIC_COMPANY`: 회사 전체 구성원에게 보임(기본)
- `SCOPE_DEPARTMENT`: 특정 부서 구성원에게만 보임(옵션)
- `PRIVATE_SELF`: 본인만 보임(민감 일정, 옵션)

휴가 일정은 기본 `PUBLIC_COMPANY`로 두되, 회사 정책으로 다른 레벨을 허용할지 설정할 수 있다.

### 2.3 테넌트 격리
모든 데이터는 `company_id` 기준으로 격리한다.
- **Supabase RLS**로 기본 차단(deny-by-default)
- 클라이언트는 `company_id`를 전달하되, DB는 반드시 **요청자의 멤버십(회사/역할/상태)**을 기준으로 허용한다.

#### 2.3.1 Supabase Auth/Claims 권장
- Supabase Auth 사용자: `auth.users.id`
- 멤버십/역할은 DB에서 조회하며, 필요 시 Edge Function에서 Custom Claims(옵션)로 캐싱

---

## 3. 주요 유저 플로우

### 3.1 가입/로그인
1) Google OAuth → `google_sub`로 사용자 식별  
2) 신규면 `User` 생성  
3) 토큰 발급(Supabase session)

### 3.2 회사 만들기
1) `POST /companies`  
2) `Company` 생성  
3) 생성자 멤버십 `role=OWNER, status=ACTIVE`  
4) 기본 정책/기본 휴가 타입(법정 연차) 생성  
5) **법정 기준 템플릿 버전(`StatutoryPolicyVersion`)을 회사에 연결**

### 3.3 입사(멤버십)

#### A. 직원이 신청
1) 회사 검색  
2) `POST /companies/{companyId}/memberships/apply`  
3) 관리자 승인 → ACTIVE

#### B. 관리자가 초대
1) `POST /companies/{companyId}/invites`  
2) 이메일로 초대 토큰 발급  
3) 수락 시 멤버십 ACTIVE

### 3.4 연차 신청/승인
1) 직원 `POST /leave-requests`  
2) 서버 검증(잔여/중복/블랙아웃/정책)  
3) 상태 `PENDING`  
4) 승인자 `POST /leave-requests/{id}/approve`  
5) 승인 시 원장에 사용(-) 기록 + 캘린더 반영

### 3.5 블랙아웃(연차 사용 불가 일정)
1) 관리자 `POST /leave-blackouts`  
2) 범위(회사/부서/개인), 기간, 정책(HARD/SOFT)  
3) 직원이 해당 기간 신청 시:
- HARD: 신청 차단
- SOFT: 신청 가능(사유 필수/상위 결재 강제 옵션)

---

## 4. 도메인 규칙(법정 기본 + 회사 커스텀)

### 4.1 법정 연차(기본 타입) + 정책 버전 관리
- 서비스는 **법정 연차 타입(Statutory Annual Leave)**를 기본 생성한다.
- 회사 설정은 **법정 최소 기준을 하회하지 못하도록** 서버/DB에서 차단한다.

#### 4.1.1 정부 정책 변화 대응(플랫폼 관리자 업데이트) — **강제 일괄 적용(의무)**
법정 최소 기준이 바뀌면 이는 **법적 의무사항**이므로, vanillawork는 다음 원칙으로 동작한다.
- **PLATFORM_ADMIN이 법정 기준 템플릿을 업데이트하면 모든 회사에 일괄 강제 적용**
- 회사(OWNER/ADMIN)는 옵트인/거부 선택권이 없음

**적용 방식(권장 구현)**
1) `StatutoryPolicyVersion`는 계속 버전으로 남긴다(감사/추적 목적).
2) 플랫폼에 **현재 활성 버전 1개**를 유지(`is_active=true`).
3) 플랫폼 관리자가 활성 버전을 변경하면:
   - 모든 회사의 `CompanyStatutoryPolicyLink.statutory_policy_version_id`를 최신으로 업데이트
   - 기존 회사의 휴가 정책/최소 부여 검증 로직은 즉시 최신 기준으로 평가

**데이터 마이그레이션(강제)**
- (A) 회사의 설정값이 법정 최소보다 낮으면 **자동 상향 보정**
- (B) 필요한 경우 사용자별 `LeaveLedger`에 **추가 부여(+)**를 생성(부족분만)
- (C) 모든 보정/부여는 `AuditLog`에 `actor=PLATFORM_ADMIN` 또는 `SYSTEM`으로 기록

> 구현 포인트: 강제 적용은 Edge Function(트랜잭션)으로 수행하고, 회사별 적용 결과(성공/실패/보정 내역)를 별도 로그 테이블로 남긴다.

### 4.2 회사 커스텀 휴가
- 휴가 타입 추가/삭제(권장: 삭제 대신 비활성)
- 단위: DAY/HOUR (MVP는 DAY만, 확장 시 HOUR)
- 유급/무급

### 4.3 잔여 연차 계산
- 잔여 = `SUM(LeaveLedger.amount)`
- 원장 이벤트:
  - ACCRUAL(+)
  - USAGE(-)
  - ADJUST(+/-)
  - EXPIRE(-)

### 4.4 회사 커스텀 휴가의 부여 범위(개인/부서/회사)
관리자는 회사 커스텀 휴가(특별휴가/포상휴가 등)를 다음 범위로 부여할 수 있다.
- **개인(USER)**: 특정 직원에게만 부여
- **부서(DEPARTMENT)**: 특정 부서 구성원에게만 부여
- **회사(COMPANY)**: 전 직원 일괄 부여

부여 방식:
- 실제 부여는 `LeaveLedger(ACCRUAL 또는 ADJUST)`로 기록
- 범위 부여 시, 대상자 목록을 확정한 뒤 각 사용자별로 원장 레코드를 생성

### 4.5 근태 자동 생성
- 매일 `AttendanceDaily`를 생성(또는 요청 시 Lazy 생성)
- 휴가 승인 시 해당 날짜의 상태를 휴가로 반영

---

## 5. 데이터 모델(ERD 초안)
PostgreSQL(Supabase) 기준 권장 스키마(키는 UUID 권장)

### 5.1 핵심 테이블

#### User
- id (uuid)
- google_sub (unique)
- email
- name
- created_at

#### Company
- id
- name
- timezone (default Asia/Seoul)
- created_at

#### Department
- id
- company_id (idx)
- name
- parent_id (nullable)

#### CompanyMembership
- id
- company_id (idx)
- user_id (idx)
- role (OWNER/ADMIN/MANAGER/EMPLOYEE)
- department_id (nullable)
- status (PENDING/ACTIVE/REJECTED/INVITED/LEFT)
- joined_at
- unique(company_id, user_id)

#### WorkPolicy (회사 근무/휴가 정책)
- id
- company_id (unique)
- accrual_basis (HIRE_DATE/FISCAL_YEAR)
- fiscal_year_start_mmdd (nullable)
- allow_hourly_leave (bool)
- overtime_weekly_limit_minutes (default 720=12h)
- created_at, updated_at

#### LeaveType
- id
- company_id (idx)
- code (unique per company)
- name
- unit (DAY/HOUR)
- paid (bool)
- is_statutory (bool)  // 법정 연차
- is_active (bool)

#### StatutoryPolicyVersion (플랫폼: 법정 기준 템플릿 버전)
- id
- version_code (e.g., 2026-01)
- effective_from (date)
- effective_to (nullable)
- rules_json (jsonb) // 최소 기준/가산/한도/산정 방식 등
- is_active (bool)
- created_by_platform_admin
- created_at

#### CompanyStatutoryPolicyLink (회사별 적용 버전)
- company_id (unique)
- statutory_policy_version_id
- applied_at
- applied_by (PLATFORM_ADMIN 또는 SYSTEM)
- apply_mode (FORCE_GLOBAL)

#### LeaveLedger
- id
- company_id (idx)
- user_id (idx)
- leave_type_id (idx)
- occurred_at (timestamp)
- amount (numeric) // DAY 기준: 1.0, 0.5 등
- reason_type (ACCRUAL/USAGE/ADJUST/EXPIRE)
- ref_type (LEAVE_REQUEST/ADMIN_ADJUST/JOB/PLATFORM_MIGRATION/...)
- ref_id (nullable)
- memo (text)
- created_by (user_id or null for system)
- created_at

#### LeaveRequest
- id
- company_id (idx)
- user_id (idx)
- leave_type_id
- start_at (date or timestamp)
- end_at
- amount (numeric)
- status (PENDING/APPROVED/REJECTED/CANCELED)
- approver_id (nullable)
- decided_at (nullable)
- comment (nullable)
- created_at

#### AttendanceDaily
- id
- company_id (idx)
- user_id (idx)
- date (date)
- scheduled_minutes
- worked_minutes
- break_minutes
- status (NORMAL/LEAVE/ABSENT/ETC)
- source (AUTO/MANUAL/INTEGRATION)
- unique(company_id, user_id, date)

#### OvertimeRequest
- id
- company_id (idx)
- user_id (idx)
- start_at
- end_at
- minutes
- status (PENDING/APPROVED/REJECTED/CANCELED)
- approver_id
- decided_at
- reason
- created_at

#### LeaveBlackoutRule (연차 사용 불가 일정)
- id
- company_id (idx)
- scope_type (COMPANY/DEPARTMENT/USER)
- scope_id (nullable)
- start_at (date)
- end_at (date)
- policy (HARD/SOFT)
- reason (text)
- repeat_rrule (nullable) // iCal RRULE 문자열
- is_active (bool)
- created_by
- created_at
- updated_at

#### AuditLog
- id
- company_id (idx)
- actor_user_id
- action (string)
- target_type
- target_id
- diff_json (jsonb)
- created_at
- ip
- user_agent

---

## 6. API 명세(REST, MVP)

공통:
- Authorization: Supabase session (Bearer)
- 모든 요청은 멤버십 검증 필요

### 6.1 Auth
- (Supabase Auth 사용) Google OAuth 로그인/콜백은 Supabase 가이드에 따름

### 6.2 Company
#### POST /companies
요청: `name`  
응답: `company`

#### GET /companies
내가 속한 회사 목록

#### GET /companies/search?query=
회사 검색(공개 정책에 따라 결과 제한 가능)

### 6.3 Membership/Invite
#### POST /companies/{companyId}/memberships/apply
회사 가입 신청

#### POST /companies/{companyId}/memberships/{membershipId}/approve
관리자 승인

#### POST /companies/{companyId}/invites
요청:
- email
- role (optional)
- department_id (optional)

#### POST /invites/{token}/accept
초대 수락

### 6.4 Leave Types & Policy
#### GET /companies/{companyId}/leave-types
#### POST /companies/{companyId}/leave-types
관리자: 휴가 타입 추가

#### PATCH /companies/{companyId}/leave-types/{leaveTypeId}
- 활성/비활성, 이름, 유급 여부 등
- `is_statutory=true` 인 타입은 삭제 금지(비활성만 허용 권장)

#### GET /companies/{companyId}/work-policy
#### PATCH /companies/{companyId}/work-policy

#### (플랫폼) GET /platform/statutory-policies
PLATFORM_ADMIN 전용

#### (플랫폼) POST /platform/statutory-policies
PLATFORM_ADMIN 전용: 법정 기준 템플릿 버전 생성

#### (플랫폼) PATCH /platform/statutory-policies/{id}
PLATFORM_ADMIN 전용: 활성화/종료(effective_to) 등

#### (회사) POST /companies/{companyId}/statutory-policy/apply
- **사용하지 않음(비활성)**: 법정 기준은 PLATFORM_ADMIN 업데이트 시 전체 회사에 강제 일괄 적용

### 6.5 Leave Requests
#### POST /companies/{companyId}/leave-requests
요청:
- leave_type_id
- start_at
- end_at
- amount
- reason (SOFT 블랙아웃 시 필수)

서버 검증(필수):
1) 요청자 ACTIVE 멤버십
2) 잔여 >= amount (LeaveLedger 합산)
3) 기간 중복(승인된 휴가/근태 상태)
4) 블랙아웃 룰 체크(섹션 7)

#### GET /companies/{companyId}/leave-requests?from=&to=&status=&user_id=&department_id=
- 직원: 본인만
- 관리자: 필터 기반 조회

#### GET /companies/{companyId}/leave-requests/{id}
- EMPLOYEE: 본인만
- MANAGER: 범위 내만
- ADMIN/OWNER: 전체

#### POST /companies/{companyId}/leave-requests/{id}/approve
#### POST /companies/{companyId}/leave-requests/{id}/reject
#### POST /companies/{companyId}/leave-requests/{id}/cancel

승인 트랜잭션:
- LeaveRequest → APPROVED
- LeaveLedger USAGE(-amount) 생성
- AttendanceDaily 해당 날짜 status=LEAVE 반영
- AuditLog 기록

### 6.6 Leave Ledger (원장)
#### GET /companies/{companyId}/leave-ledger?user_id=&leave_type_id=&from=&to=
- 직원: 본인 user_id만 가능

#### POST /companies/{companyId}/leave-adjustments
관리자 부여/조정(개인/부서/회사) — **회사 커스텀 휴가 포함**  
요청:
- scope_type (USER/DEPARTMENT/COMPANY)
- scope_id (nullable)
- leave_type_id
- amount(+/-)
- memo (required)

처리:
- 대상 유저 목록 확정 → 사용자별 LeaveLedger ADJUST/ACCRUAL 생성
- AuditLog

### 6.7 Attendance
#### GET /companies/{companyId}/attendance?user_id=&from=&to=
- 직원: 본인만
- 관리자: 전체

### 6.8 Overtime
#### POST /companies/{companyId}/overtime-requests
#### POST /companies/{companyId}/overtime-requests/{id}/approve
#### POST /companies/{companyId}/overtime-requests/{id}/reject

검증(기본):
- 주 누계 연장근로 제한(WorkPolicy 기준) 초과 시 경고/차단 정책 선택

### 6.9 Calendar (공용/개인)
#### GET /companies/{companyId}/calendar/events?from=&to=&department_id=&user_id=
목적:
- **공용 캘린더**: 회사 전체 구성원의 일정 요약을 반환(EMPLOYEE 포함)
- 필터: 부서/개인 필터 가능(단, 상세 권한은 별도)

응답 모델(요약 Event):
- id
- event_type (LEAVE/COMPANY_EVENT/OT_APPROVED/...)
- title (예: “홍길동 연차”, “전사 워크숍”)
- start_at, end_at
- visibility (PUBLIC_COMPANY/SCOPE_DEPARTMENT/PRIVATE_SELF)
- owner_user_id
- owner_display_name
- owner_department_id
- status (APPROVED/PENDING 등)

권한:
- EMPLOYEE: 모든 `PUBLIC_COMPANY` 이벤트 조회 가능
- 상세(사유/원장/첨부 등)는 **절대 포함하지 않음**

### 6.10 Blackout
#### POST /companies/{companyId}/leave-blackouts
요청:
- scope_type (COMPANY/DEPARTMENT/USER)
- scope_id (nullable)
- start_at (date)
- end_at (date)
- policy (HARD/SOFT)
- reason
- repeat_rrule (optional)

#### GET /companies/{companyId}/leave-blackouts?active=true
#### PATCH /companies/{companyId}/leave-blackouts/{id}
기간 수정/비활성

---

## 7. 블랙아웃(연차 사용 불가 일정) 검증 상세

### 7.1 적용 룰 집합
신청자 기준 룰을 모두 적용:
- 회사 전체(scope=COMPANY)
- 신청자 부서(scope=DEPARTMENT, scope_id=department_id)
- 신청자 개인(scope=USER, scope_id=user_id)

### 7.2 기간 겹침(일 단위)
overlap if: `req_start <= rule_end AND req_end >= rule_start`

### 7.3 HARD/SOFT 처리
- HARD: 신청 API에서 즉시 실패(예: HTTP 409)
- SOFT(옵션):
  - 신청은 저장하되 `reason` 필수
  - 승인 라인을 상위로 강제(예: ADMIN 이상)
  - UI에 경고 배지 표시

### 7.4 반복 룰(RRULE) 처리(확장)
- `repeat_rrule`이 있으면 요청 범위(from~to)에서 발생 인스턴스를 전개해 overlap 검사
- MVP는 단발만 지원하고 이후 확장 가능

### 7.5 기존 승인 연차와의 충돌
- 블랙아웃 생성 시 기존 APPROVED 휴가와 충돌하면:
  - 기본: 경고만 표시(기존 승인 유지)
  - 옵션: 충돌 목록 리턴(관리자 확인)

---

## 8. 배치(Job) 설계 (Supabase Cron + Edge Function)

### 8.1 Daily Job (00:10 KST)
- AttendanceDaily 자동 생성(전일/금일)
- 주/월 누계 계산용 집계(옵션)

### 8.2 Monthly Job (매월 1일 00:20 KST)
- 월 개근 조건 충족자에 대해 부여 원장 기록(회사 정책/법정 템플릿 기준)

### 8.3 Anniversary/Accrual Job (매일 00:30 KST)
- 근속 이벤트 체크 → 부여 원장 기록

### 8.4 Expire Job (회사 정책 기준)
- 만료되는 휴가(EXPIRE) 처리 → 원장 기록

### 8.5 Statutory Migration Job (플랫폼 관리자 트리거)
- PLATFORM_ADMIN이 법정 템플릿 활성 버전을 변경하면:
  - 회사 링크 일괄 업데이트
  - 회사 정책 자동 상향 보정
  - 사용자별 부족분 추가 부여(LeaveLedger +)
  - 감사/결과 로그 기록

---

## 9. 에러 코드(권장)
- AUTH_REQUIRED
- FORBIDDEN_ROLE
- MEMBERSHIP_INACTIVE
- LEAVE_BALANCE_INSUFFICIENT
- LEAVE_OVERLAP
- LEAVE_BLACKOUT_HARD
- LEAVE_BLACKOUT_SOFT_REASON_REQUIRED
- OVERTIME_LIMIT_EXCEEDED
- CALENDAR_EVENT_FORBIDDEN_DETAIL

---

## 10. 화면/페이지 구성(IA) + 네비게이션

### 10.1 공통 레이아웃
- TopBar: 회사 선택(조건부), 알림, 프로필
- SideNav: 회사 컨텍스트 메뉴
- 권한에 따라 메뉴 노출이 달라짐(EMPLOYEE vs MANAGER vs ADMIN vs OWNER vs PLATFORM_ADMIN)

**회사 선택 드롭다운 권장 규칙**
- 소속 회사 1개: 회사명만 표시(드롭다운 비활성)
- 소속 회사 2개 이상: 드롭다운 활성 + 마지막 선택 회사 기억
- PLATFORM_ADMIN: `/platform` 영역을 별도 분리

### 10.2 EMPLOYEE 메뉴(기본)
1) **대시보드**
2) **회사 캘린더(공용)** (요약 일정)
3) **내 캘린더**
4) **연차/휴가 신청**
5) **추가근무 신청**
6) **내 기록** (휴가/근태/원장)

### 10.3 MANAGER 추가 메뉴(팀 범위)
- **팀 승인함**
- **팀 캘린더(옵션)**

### 10.4 ADMIN/OWNER 추가 메뉴(회사 범위)
- **승인센터(회사)**
- **구성원 관리**
- **조직(부서) 관리**
- **휴가 정책/타입 관리**
- **연차 부여/조정(범위 부여)**
- **블랙아웃 관리**
- **감사 로그**

### 10.5 PLATFORM_ADMIN(서비스 전체) 메뉴
- **법정 기준(StatutoryPolicyVersion) 관리**

### 10.6 라우팅/네비게이션 예시(Nuxt)
- /login
- /select-company
- /app/{companyId}/dashboard
- /app/{companyId}/calendar
- /app/{companyId}/me/calendar
- /app/{companyId}/leave/request
- /app/{companyId}/overtime/request
- /app/{companyId}/me/records
- /app/{companyId}/team (manager)
- /app/{companyId}/admin (admin/owner)
- /platform (platform_admin)

---

## 11. 구현 체크리스트(MVP)
- [ ] Supabase Auth(Google) + 사용자 프로필
- [ ] 회사 생성 + 멤버십
- [ ] 기본 휴가 타입/정책 + StatutoryPolicyVersion/Link
- [ ] LeaveLedger 기반 잔여 계산
- [ ] 연차 신청/승인 트랜잭션
- [ ] 공용 캘린더 요약 이벤트 API
- [ ] 블랙아웃 CRUD + 신청 차단
- [ ] 관리자 범위 부여(개인/부서/회사)
- [ ] 감사 로그
- [ ] Supabase RLS(요약 캘린더 전체 허용 + 상세 테이블 범위 제한)

---

## 12. Codex/Claude Code용 프롬프트(바로 생성용)

### 12.1 백엔드(Supabase)
- 목표:
  1) 위 스키마 기반 SQL 마이그레이션
  2) RLS 정책(회사/역할 기반) 설계(deny-by-default)
  3) Edge Function 트랜잭션 구현(승인/블랙아웃/범위 부여/법정 강제 적용)
  4) Supabase Cron 배치 구현

### 12.2 프론트엔드(Nuxt.js)
- 목표:
  - 로그인/회사 선택
  - 공용 캘린더(요약)
  - 연차 신청(잔여 + 블랙아웃 비활성)
  - 관리자 화면(승인/블랙아웃/범위부여)
  - 권한별 메뉴/가드

---

## 13. 보안/감사(필수)
- 모든 변경은 AuditLog 기록
- 관리자 대량 조회/내보내기 로그
- 멤버십/역할 변경은 별도 액션으로 기록
- 공용 캘린더는 “요약 전용”으로 민감 정보 미노출
