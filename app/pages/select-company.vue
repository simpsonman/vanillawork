<template>
  <div class="flex min-h-screen items-center justify-center bg-background">
    <div class="w-full max-w-lg space-y-6 px-4">
      <h1 class="text-2xl font-bold text-center text-foreground">
        회사 선택
      </h1>
      <p class="text-center text-muted-foreground">
        접속할 회사를 선택하세요
      </p>

      <div v-if="loading" class="text-center text-muted-foreground">
        로딩 중...
      </div>

      <div v-else-if="companies.length === 0" class="space-y-4 text-center">
        <p class="text-muted-foreground">소속된 회사가 없습니다.</p>
        <button
          class="rounded-lg bg-primary px-6 py-2.5 text-sm font-medium text-primary-foreground shadow hover:bg-primary/90 transition-colors"
          @click="$router.push('/create-company')"
        >
          새 회사 만들기
        </button>
      </div>

      <div v-else class="space-y-3">
        <button
          v-for="company in companies"
          :key="company.id"
          class="w-full rounded-xl border border-border bg-card p-4 text-left shadow-sm transition-colors hover:bg-accent hover:text-accent-foreground"
          @click="selectAndGo(company.id)"
        >
          <div class="font-medium text-card-foreground">{{ company.name }}</div>
          <div class="mt-1 text-xs text-muted-foreground">{{ company.timezone }}</div>
        </button>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
definePageMeta({
  middleware: ['auth'],
  layout: false,
})

const companyStore = useCompanyStore()
const router = useRouter()

const companies = computed(() => companyStore.companies)
const loading = computed(() => companyStore.loading)

onMounted(async () => {
  await companyStore.fetchCompanies()
  // 회사가 1개면 자동 이동
  if (companies.value.length === 1) {
    await selectAndGo(companies.value[0].id)
  }
})

async function selectAndGo(companyId: string) {
  await companyStore.selectCompany(companyId)
  await router.push(`/app/${companyId}/dashboard`)
}
</script>
