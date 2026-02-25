import { defineStore } from 'pinia'
import type { Company, CompanyMembership, MemberRole } from '~/types'

export const useCompanyStore = defineStore('company', () => {
    const supabase = useSupabaseClient()

    const companies = ref<Company[]>([])
    const currentCompanyId = ref<string | null>(null)
    const membership = ref<CompanyMembership | null>(null)
    const loading = ref(false)

    /** 현재 선택된 회사 */
    const currentCompany = computed(() =>
        companies.value.find((c: Company) => c.id === currentCompanyId.value) ?? null,
    )

    /** 현재 역할 */
    const role = computed<MemberRole | null>(() => membership.value?.role ?? null)

    /** 역할 검사 헬퍼 */
    const isOwner = computed(() => role.value === 'OWNER')
    const isAdmin = computed(() => role.value === 'ADMIN' || role.value === 'OWNER')
    const isManager = computed(() => role.value === 'MANAGER' || isAdmin.value)

    /** 내 소속 회사 목록 가져오기 */
    async function fetchCompanies() {
        const { data: { user } } = await supabase.auth.getUser()
        if (!user?.id) return

        loading.value = true
        try {
            const { data, error } = await supabase
                .from('company_memberships')
                .select('company_id, companies(*)')
                .eq('user_id', user.id)
                .eq('status', 'ACTIVE')

            if (error) throw error

            companies.value = (data ?? [])
                .map((d: any) => d.companies as Company)
                .filter(Boolean)
        } finally {
            loading.value = false
        }
    }

    /** 새 회사/워크스페이스 생성 */
    async function createCompany(name: string, timezone: string, businessRegistrationNumber: string) {
        const { data: { user } } = await supabase.auth.getUser()
        if (!user?.id) return { data: null, error: new Error('User not authenticated') }

        // rpc를 호출하여 회사 생성과 OWNER 편입을 트랜잭션으로 안전하게 처리
        const { data: companyData, error } = await supabase
            .rpc('create_company_with_owner' as any, {
                p_name: name,
                p_timezone: timezone,
                p_business_registration_number: businessRegistrationNumber
            } as any)
            .single()

        if (error) return { data: null, error }

        // RPC 반환 타입이 배열일 수도 있고 단일 객체일 수도 있습니다 (single을 붙여서 객체로 반환되지만 만약을 대비)
        const companyObj = Array.isArray(companyData) ? companyData[0] : companyData
        const companyId = (companyObj as any)?.id

        if (!companyId) {
            return { data: null, error: new Error(`회사 생성 응답에서 ID를 찾을 수 없습니다: ${JSON.stringify(companyData)}`) }
        }

        await selectCompany(companyId)

        // 3. Update local state
        companies.value.push(companyObj as Company)
        return { data: companyObj as Company, error: null }
    }

    /** 회사 선택 & 멤버십 로드 */
    async function selectCompany(companyId: string) {
        const { data: { user } } = await supabase.auth.getUser()
        if (!user?.id) return

        currentCompanyId.value = companyId

        const { data, error } = await supabase
            .from('company_memberships')
            .select('*, companies(*)')
            .eq('company_id', companyId)
            .eq('user_id', user.id)
            .single()

        if (error) throw error

        // Extract membership data (excluding the joined companies object if we just want membership fields)
        const { companies: joinedCompany, ...membershipData } = data as any
        membership.value = membershipData as CompanyMembership

        // Ensure the company is in the companies list so currentCompany works
        if (joinedCompany) {
            const existing = companies.value.find((c: Company) => c.id === joinedCompany.id)
            if (!existing) {
                companies.value.push(joinedCompany as Company)
            }
        }
    }

    /** 초기화 */
    function $reset() {
        companies.value = []
        currentCompanyId.value = null
        membership.value = null
    }

    return {
        companies,
        currentCompanyId,
        currentCompany,
        membership,
        role,
        isOwner,
        isAdmin,
        isManager,
        loading,
        fetchCompanies,
        createCompany,
        selectCompany,
        $reset,
    }
})
