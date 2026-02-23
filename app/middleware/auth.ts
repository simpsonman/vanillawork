/**
 * 미인증 사용자를 /login으로 리다이렉트하는 미들웨어
 */
export default defineNuxtRouteMiddleware((to) => {
    const user = useSupabaseUser()

    if (!user.value && to.path !== '/login') {
        return navigateTo('/login')
    }
})
