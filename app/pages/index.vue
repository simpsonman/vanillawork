<template>
  <div class="flex min-h-screen items-center justify-center bg-background">
    <div class="text-center space-y-4">
      <h1 class="text-4xl font-bold text-foreground">vanillawork</h1>
      <p class="text-muted-foreground">로딩 중...</p>
    </div>
  </div>
</template>

<script setup lang="ts">
definePageMeta({
  layout: false,
})

const user = useSupabaseUser()
const router = useRouter()

onMounted(async () => {
  if (user.value) {
    await router.push('/select-company')
  } else {
    await router.push('/login')
  }
})
</script>
