// ── Enums ──────────────────────────────────────────

export type MemberRole = 'OWNER' | 'ADMIN' | 'MANAGER' | 'EMPLOYEE'
export type MemberStatus = 'PENDING' | 'ACTIVE' | 'REJECTED' | 'INVITED' | 'LEFT'
export type LeaveUnit = 'DAY' | 'HOUR'
export type LedgerReasonType = 'ACCRUAL' | 'USAGE' | 'ADJUST' | 'EXPIRE'
export type LedgerRefType = 'LEAVE_REQUEST' | 'ADMIN_ADJUST' | 'JOB' | 'PLATFORM_MIGRATION'
export type RequestStatus = 'PENDING' | 'APPROVED' | 'REJECTED' | 'CANCELED'
export type AttendanceStatus = 'NORMAL' | 'LEAVE' | 'ABSENT' | 'ETC'
export type AttendanceSource = 'AUTO' | 'MANUAL' | 'INTEGRATION'
export type BlackoutPolicy = 'HARD' | 'SOFT'
export type BlackoutScopeType = 'COMPANY' | 'DEPARTMENT' | 'USER'
export type EventVisibility = 'PUBLIC_COMPANY' | 'SCOPE_DEPARTMENT' | 'PRIVATE_SELF'
export type EventType = 'LEAVE' | 'COMPANY_EVENT' | 'OT_APPROVED'
export type AccrualBasis = 'HIRE_DATE' | 'FISCAL_YEAR'
export type ApplyMode = 'FORCE_GLOBAL'

// ── Entities ───────────────────────────────────────

export interface User {
    id: string
    google_sub: string
    email: string
    name: string
    created_at: string
}

export interface Company {
    id: string
    name: string
    timezone: string
    created_at: string
}

export interface Department {
    id: string
    company_id: string
    name: string
    parent_id: string | null
}

export interface CompanyMembership {
    id: string
    company_id: string
    user_id: string
    role: MemberRole
    department_id: string | null
    status: MemberStatus
    joined_at: string | null
}

export interface WorkPolicy {
    id: string
    company_id: string
    accrual_basis: AccrualBasis
    fiscal_year_start_mmdd: string | null
    allow_hourly_leave: boolean
    overtime_weekly_limit_minutes: number
    created_at: string
    updated_at: string
}

export interface LeaveType {
    id: string
    company_id: string
    code: string
    name: string
    unit: LeaveUnit
    paid: boolean
    is_statutory: boolean
    is_active: boolean
}

export interface StatutoryPolicyVersion {
    id: string
    version_code: string
    effective_from: string
    effective_to: string | null
    rules_json: Record<string, unknown>
    is_active: boolean
    created_by_platform_admin: string
    created_at: string
}

export interface CompanyStatutoryPolicyLink {
    company_id: string
    statutory_policy_version_id: string
    applied_at: string
    applied_by: string
    apply_mode: ApplyMode
}

export interface LeaveLedger {
    id: string
    company_id: string
    user_id: string
    leave_type_id: string
    occurred_at: string
    amount: number
    reason_type: LedgerReasonType
    ref_type: LedgerRefType | null
    ref_id: string | null
    memo: string | null
    created_by: string | null
    created_at: string
}

export interface LeaveRequest {
    id: string
    company_id: string
    user_id: string
    leave_type_id: string
    start_at: string
    end_at: string
    amount: number
    status: RequestStatus
    approver_id: string | null
    decided_at: string | null
    comment: string | null
    created_at: string
}

export interface AttendanceDaily {
    id: string
    company_id: string
    user_id: string
    date: string
    scheduled_minutes: number
    worked_minutes: number
    break_minutes: number
    status: AttendanceStatus
    source: AttendanceSource
}

export interface OvertimeRequest {
    id: string
    company_id: string
    user_id: string
    start_at: string
    end_at: string
    minutes: number
    status: RequestStatus
    approver_id: string | null
    decided_at: string | null
    reason: string | null
    created_at: string
}

export interface LeaveBlackoutRule {
    id: string
    company_id: string
    scope_type: BlackoutScopeType
    scope_id: string | null
    start_at: string
    end_at: string
    policy: BlackoutPolicy
    reason: string | null
    repeat_rrule: string | null
    is_active: boolean
    created_by: string
    created_at: string
    updated_at: string
}

export interface AuditLog {
    id: string
    company_id: string
    actor_user_id: string | null
    action: string
    target_type: string
    target_id: string
    diff_json: Record<string, unknown> | null
    created_at: string
    ip: string | null
    user_agent: string | null
}

// ── Calendar Event (공용 캘린더 요약) ──────────────

export interface CalendarEvent {
    id: string
    event_type: EventType
    title: string
    start_at: string
    end_at: string
    visibility: EventVisibility
    owner_user_id: string | null
    owner_display_name: string | null
    owner_department_id: string | null
    status: RequestStatus | null
}

// ── API Error ──────────────────────────────────────

export type ErrorCode =
    | 'AUTH_REQUIRED'
    | 'FORBIDDEN_ROLE'
    | 'MEMBERSHIP_INACTIVE'
    | 'LEAVE_BALANCE_INSUFFICIENT'
    | 'LEAVE_OVERLAP'
    | 'LEAVE_BLACKOUT_HARD'
    | 'LEAVE_BLACKOUT_SOFT_REASON_REQUIRED'
    | 'OVERTIME_LIMIT_EXCEEDED'
    | 'CALENDAR_EVENT_FORBIDDEN_DETAIL'

export interface ApiError {
    code: ErrorCode
    message: string
    details?: Record<string, unknown>
}
