import { defineStore } from 'pinia'
import type { User } from '~/types'

export const useAuthStore = defineStore('auth', () => {
    const supabase = useSupabaseClient()
    const user = useSupabaseUser()

    const profile = ref<User | null>(null)
    const loading = ref(false)

    /** 현재 로그인 사용자의 프로필 가져오기 */
    async function fetchProfile() {
        if (!user.value) return
        loading.value = true
        try {
            const { data, error } = await supabase
                .from('users')
                .select('*')
                .eq('id', user.value.id)
                .single()

            if (error) throw error
            profile.value = data as User
        } finally {
            loading.value = false
        }
    }

    /** Google OAuth 로그인 */
    async function signInWithGoogle() {
        const { error } = await supabase.auth.signInWithOAuth({
            provider: 'google',
            options: {
                redirectTo: `${window.location.origin}/confirm`,
            },
        })
        if (error) throw error
    }

    /** 로그아웃 */
    async function signOut() {
        const { error } = await supabase.auth.signOut()
        if (error) throw error
        profile.value = null
    }

    return {
        user,
        profile,
        loading,
        fetchProfile,
        signInWithGoogle,
        signOut,
    }
})
