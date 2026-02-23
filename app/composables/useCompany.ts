import type { MemberRole } from '~/types'

/**
 * 현재 회사 컨텍스트에 접근하는 composable.
 * [companyId] 라우트 파라미터 기반으로 회사/멤버십을 자동 로드한다.
 */
export function useCompany() {
    const companyStore = useCompanyStore()
    const route = useRoute()

    const companyId = computed(() => route.params.companyId as string | undefined)
    const company = computed(() => companyStore.currentCompany)
    const membership = computed(() => companyStore.membership)
    const role = computed(() => companyStore.role)

    /** 역할 권한 검사 */
    function hasRole(...roles: MemberRole[]) {
        return role.value ? roles.includes(role.value) : false
    }

    const isAdmin = computed(() => hasRole('ADMIN', 'OWNER'))
    const isManager = computed(() => hasRole('MANAGER', 'ADMIN', 'OWNER'))

    return {
        companyId,
        company,
        membership,
        role,
        hasRole,
        isAdmin,
        isManager,
    }
}
