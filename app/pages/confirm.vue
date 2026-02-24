<template>
  <div class="space-y-4 text-center py-12">
    <h1 class="text-xl font-semibold">로그인 확인 중...</h1>
    <p class="text-muted-foreground">잠시만 기다려주세요.</p>
  </div>
</template>

<script setup lang="ts">
definePageMeta({
  layout: false,
})

const user = useSupabaseUser()
const router = useRouter()

watch(user, (currentUser) => {
  if (currentUser) {
    router.push('/select-company')
  }
}, { immediate: true })
</script>
