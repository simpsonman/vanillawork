<template>
  <div class="space-y-6">
    <h1 class="text-2xl font-bold">팀 승인함</h1>
    <p class="text-muted-foreground">팀원의 휴가/추가근무 신청을 승인하세요.</p>

    <div class="rounded-xl border border-border bg-card p-6 shadow-sm min-h-[300px]">
      <p class="text-muted-foreground text-center py-16">
        대기 중인 신청 목록이 여기에 표시됩니다.
      </p>
    </div>
  </div>
</template>

<script setup lang="ts">
definePageMeta({
  middleware: ['auth', 'company'],
})
</script>
