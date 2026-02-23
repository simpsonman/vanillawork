/**
 * 회사 멤버십 검증 미들웨어.
 * /app/[companyId]/** 경로에서 해당 회사의 ACTIVE 멤버인지 확인한다.
 */
export default defineNuxtRouteMiddleware(async (to) => {
    const companyId = to.params.companyId as string | undefined
    if (!companyId) return

    const companyStore = useCompanyStore()

    // 이미 로드된 회사와 같으면 스킵
    if (companyStore.currentCompanyId === companyId && companyStore.membership) {
        return
    }

    try {
        await companyStore.selectCompany(companyId)

        if (!companyStore.membership || companyStore.membership.status !== 'ACTIVE') {
            return navigateTo('/select-company')
        }
    } catch {
        return navigateTo('/select-company')
    }
})
