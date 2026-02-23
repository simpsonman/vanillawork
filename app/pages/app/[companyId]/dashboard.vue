<template>
  <div class="space-y-6">
    <h1 class="text-2xl font-bold">대시보드</h1>
    <p class="text-muted-foreground">{{ company?.name }}에 오신 것을 환영합니다.</p>

    <!-- Summary Cards -->
    <div class="grid gap-4 md:grid-cols-2 lg:grid-cols-4">
      <div class="rounded-xl border border-border bg-card p-6 shadow-sm">
        <div class="text-sm font-medium text-muted-foreground">잔여 연차</div>
        <div class="mt-2 text-3xl font-bold text-card-foreground">-- 일</div>
      </div>
      <div class="rounded-xl border border-border bg-card p-6 shadow-sm">
        <div class="text-sm font-medium text-muted-foreground">이번 달 근무일</div>
        <div class="mt-2 text-3xl font-bold text-card-foreground">-- 일</div>
      </div>
      <div class="rounded-xl border border-border bg-card p-6 shadow-sm">
        <div class="text-sm font-medium text-muted-foreground">대기 중 신청</div>
        <div class="mt-2 text-3xl font-bold text-card-foreground">-- 건</div>
      </div>
      <div class="rounded-xl border border-border bg-card p-6 shadow-sm">
        <div class="text-sm font-medium text-muted-foreground">추가근무</div>
        <div class="mt-2 text-3xl font-bold text-card-foreground">-- h</div>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
definePageMeta({
  middleware: ['auth', 'company'],
})

const { company } = useCompany()
</script>
