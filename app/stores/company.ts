import { defineStore } from 'pinia'
import type { Company, CompanyMembership, MemberRole } from '~/types'

export const useCompanyStore = defineStore('company', () => {
    const supabase = useSupabaseClient()
    const user = useSupabaseUser()

    const companies = ref<Company[]>([])
    const currentCompanyId = ref<string | null>(null)
    const membership = ref<CompanyMembership | null>(null)
    const loading = ref(false)

    /** 현재 선택된 회사 */
    const currentCompany = computed(() =>
        companies.value.find(c => c.id === currentCompanyId.value) ?? null,
    )

    /** 현재 역할 */
    const role = computed<MemberRole | null>(() => membership.value?.role ?? null)

    /** 역할 검사 헬퍼 */
    const isOwner = computed(() => role.value === 'OWNER')
    const isAdmin = computed(() => role.value === 'ADMIN' || role.value === 'OWNER')
    const isManager = computed(() => role.value === 'MANAGER' || isAdmin.value)

    /** 내 소속 회사 목록 가져오기 */
    async function fetchCompanies() {
        if (!user.value) return
        loading.value = true
        try {
            const { data, error } = await supabase
                .from('company_memberships')
                .select('company_id, companies(*)')
                .eq('user_id', user.value.id)
                .eq('status', 'ACTIVE')

            if (error) throw error

            companies.value = (data ?? [])
                .map((d: any) => d.companies as Company)
                .filter(Boolean)
        } finally {
            loading.value = false
        }
    }

    /** 회사 선택 & 멤버십 로드 */
    async function selectCompany(companyId: string) {
        if (!user.value) return
        currentCompanyId.value = companyId

        const { data, error } = await supabase
            .from('company_memberships')
            .select('*')
            .eq('company_id', companyId)
            .eq('user_id', user.value.id)
            .single()

        if (error) throw error
        membership.value = data as CompanyMembership
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
        selectCompany,
        $reset,
    }
})
