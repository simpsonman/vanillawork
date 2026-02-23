/**
 * Google OAuth 로그인/로그아웃 래퍼
 */
export function useAuth() {
    const authStore = useAuthStore()
    const router = useRouter()

    const user = computed(() => authStore.user)
    const profile = computed(() => authStore.profile)
    const isLoggedIn = computed(() => !!authStore.user)

    async function loginWithGoogle() {
        await authStore.signInWithGoogle()
    }

    async function logout() {
        await authStore.signOut()
        await router.push('/login')
    }

    return {
        user,
        profile,
        isLoggedIn,
        loginWithGoogle,
        logout,
    }
}
