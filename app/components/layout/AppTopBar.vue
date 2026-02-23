<template>
  <header class="sticky top-0 z-40 border-b border-border bg-background/95 backdrop-blur supports-[backdrop-filter]:bg-background/60">
    <div class="flex h-14 items-center px-4 lg:px-6">
      <!-- Logo -->
      <NuxtLink to="/" class="mr-4 flex items-center gap-2 font-bold text-lg">
        <span class="text-primary">vanillawork</span>
      </NuxtLink>

      <!-- Company Selector -->
      <div v-if="companies.length > 1" class="ml-4">
        <select
          :value="currentCompanyId ?? ''"
          class="rounded-md border border-input bg-background px-3 py-1.5 text-sm shadow-sm focus:outline-none focus:ring-1 focus:ring-ring"
          @change="onCompanyChange"
        >
          <option v-for="c in companies" :key="c.id" :value="c.id">
            {{ c.name }}
          </option>
        </select>
      </div>
      <div v-else-if="currentCompany" class="ml-4 text-sm text-muted-foreground">
        {{ currentCompany.name }}
      </div>

      <div class="flex-1" />

      <!-- Profile / Logout -->
      <div class="flex items-center gap-3">
        <span v-if="profile" class="text-sm text-muted-foreground">
          {{ profile.name }}
        </span>
        <button
          class="rounded-md px-3 py-1.5 text-sm text-muted-foreground hover:bg-accent hover:text-accent-foreground transition-colors"
          @click="logout"
        >
          로그아웃
        </button>
      </div>
    </div>
  </header>
</template>

<script setup lang="ts">
const { profile, logout } = useAuth()
const companyStore = useCompanyStore()
const router = useRouter()

const companies = computed(() => companyStore.companies)
const currentCompanyId = computed(() => companyStore.currentCompanyId)
const currentCompany = computed(() => companyStore.currentCompany)

function onCompanyChange(e: Event) {
  const id = (e.target as HTMLSelectElement).value
  if (id) {
    companyStore.selectCompany(id)
    router.push(`/app/${id}/dashboard`)
  }
}
</script>
