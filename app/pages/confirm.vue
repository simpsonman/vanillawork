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

const router = useRouter()

onMounted(async () => {
  // Supabase Auth 콜백 처리 후 회사 선택 페이지로 이동
  await router.push('/select-company')
})
</script>
