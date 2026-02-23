<template>
  <aside class="hidden lg:flex w-60 flex-col border-r border-border bg-card min-h-[calc(100vh-3.5rem)]">
    <nav class="flex-1 space-y-1 px-3 py-4">
      <!-- EMPLOYEE 기본 메뉴 -->
      <SideNavLink to="dashboard" icon="LayoutDashboard" label="대시보드" />
      <SideNavLink to="calendar" icon="Calendar" label="회사 캘린더" />
      <SideNavLink to="me/calendar" icon="CalendarHeart" label="내 캘린더" />
      <SideNavLink to="leave/request" icon="CalendarPlus" label="연차/휴가 신청" />
      <SideNavLink to="overtime/request" icon="Clock" label="추가근무 신청" />
      <SideNavLink to="me/records" icon="FileText" label="내 기록" />

      <!-- MANAGER 메뉴 -->
      <template v-if="isManager">
        <div class="pt-4 pb-1 px-2 text-xs font-semibold text-muted-foreground uppercase tracking-wider">
          팀 관리
        </div>
        <SideNavLink to="team" icon="Users" label="팀 승인함" />
      </template>

      <!-- ADMIN / OWNER 메뉴 -->
      <template v-if="isAdmin">
        <div class="pt-4 pb-1 px-2 text-xs font-semibold text-muted-foreground uppercase tracking-wider">
          관리자
        </div>
        <SideNavLink to="admin" icon="Shield" label="승인센터" />
        <SideNavLink to="admin/members" icon="UserCog" label="구성원 관리" />
        <SideNavLink to="admin/departments" icon="Building2" label="조직(부서) 관리" />
        <SideNavLink to="admin/leave-types" icon="Tag" label="휴가 정책/타입" />
        <SideNavLink to="admin/leave-adjust" icon="Coins" label="연차 부여/조정" />
        <SideNavLink to="admin/blackouts" icon="Ban" label="블랙아웃 관리" />
        <SideNavLink to="admin/audit" icon="ScrollText" label="감사 로그" />
      </template>
    </nav>
  </aside>
</template>

<script setup lang="ts">
const { isAdmin, isManager } = useCompany()
</script>
