<template>
  <aside class="hidden lg:flex w-60 flex-col min-h-[calc(100vh-3.5rem)] bg-transparent">
    <div class="flex h-full flex-col py-6">
      <div class="px-6 mb-4">
      <h2 class="text-xs font-bold uppercase tracking-wider text-muted-foreground/70 mb-2">메뉴</h2>
    </div>
    
    <nav class="flex-1 space-y-1 px-4">
      <div v-for="link in availableLinks" :key="link.to">
        <!-- Section Divider -->
        <div v-if="link.divider" class="my-4 border-t border-border/50"></div>
        <div v-if="link.sectionLabel" class="px-2 mt-6 mb-2 text-xs font-bold uppercase tracking-wider text-muted-foreground/70">
          {{ link.sectionLabel }}
        </div>
        
        <!-- Navigation Link -->
        <NuxtLink
          v-if="!link.divider && !link.sectionLabel"
          :to="link.to"
          class="group flex items-center gap-3 rounded-md px-3 py-2.5 text-sm font-medium transition-all duration-200"
          :class="[
            $route.path === link.to || $route.path.startsWith(link.to + '/')
              ? 'bg-primary/10 text-primary font-semibold'
              : 'text-muted-foreground hover:bg-muted hover:text-foreground'
          ]"
        >
          <component :is="link.icon" class="h-5 w-5 shrink-0 transition-transform duration-200" :class="[
            $route.path === link.to || $route.path.startsWith(link.to + '/')
              ? 'text-primary scale-110'
              : 'text-muted-foreground group-hover:scale-110 group-hover:text-foreground'
          ]" />
          {{ link.name }}
          
          <!-- Optional Badge -->
          <span v-if="link.badge" class="ml-auto inline-flex items-center justify-center rounded-full bg-primary/10 px-2 py-0.5 text-xs font-bold text-primary">
            {{ link.badge }}
          </span>
        </NuxtLink>
      </div>
    </nav>
  </div>
  </aside>
</template>

<script setup lang="ts">
import { 
  LayoutDashboard, 
  CalendarDays, 
  Clock, 
  Users, 
  Settings, 
  Building2, 
  ShieldCheck 
} from 'lucide-vue-next'

const companyStore = useCompanyStore()
const currentCompanyId = computed(() => companyStore.currentCompanyId)
const role = computed(() => companyStore.currentMembership?.role)

const ALL_LINKS = computed<any[]>(() => {
  const cid = currentCompanyId.value
  if (!cid) return []
  return [
    { name: '대시보드', to: `/app/${cid}/dashboard`, icon: LayoutDashboard, roles: ['OWNER', 'ADMIN', 'MANAGER', 'EMPLOYEE'] },
    
    { divider: true, roles: ['OWNER', 'ADMIN', 'MANAGER', 'EMPLOYEE'] },
    { sectionLabel: '내 근무', roles: ['OWNER', 'ADMIN', 'MANAGER', 'EMPLOYEE'] },
    { name: '내 캘린더', to: `/app/${cid}/me/calendar`, icon: CalendarDays, roles: ['OWNER', 'ADMIN', 'MANAGER', 'EMPLOYEE'] },
    { name: '연차 신청', to: `/app/${cid}/leave/request`, icon: CalendarDays, roles: ['OWNER', 'ADMIN', 'MANAGER', 'EMPLOYEE'] },
    { name: '추가근무 신청', to: `/app/${cid}/overtime/request`, icon: Clock, roles: ['OWNER', 'ADMIN', 'MANAGER', 'EMPLOYEE'] },

    { divider: true, roles: ['OWNER', 'ADMIN', 'MANAGER'] },
    { sectionLabel: '팀 관리', roles: ['OWNER', 'ADMIN', 'MANAGER'] },
    { name: '팀원 현황', to: `/app/${cid}/team`, icon: Users, roles: ['OWNER', 'ADMIN', 'MANAGER'] },

    { divider: true, roles: ['OWNER', 'ADMIN'] },
    { sectionLabel: '관리자', roles: ['OWNER', 'ADMIN'] },
    { name: '회사 설정', to: `/app/${cid}/admin`, icon: Settings, roles: ['OWNER', 'ADMIN'] },
    { name: '멤버 관리', to: `/app/${cid}/admin/members`, icon: Users, roles: ['OWNER', 'ADMIN'] },
    
    { divider: true, roles: ['OWNER'] },
    { sectionLabel: '보안', roles: ['OWNER'] },
    { name: '감사 로그', to: `/app/${cid}/admin/audit`, icon: ShieldCheck, roles: ['OWNER'] },
  ]
})

const availableLinks = computed(() => {
  const userRole = role.value
  if (!userRole) return []
  return ALL_LINKS.value.filter(link => link.roles.includes(userRole))
})
</script>
