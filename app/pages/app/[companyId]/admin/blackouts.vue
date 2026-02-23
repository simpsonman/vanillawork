<template>
  <div class="space-y-6">
    <h1 class="text-2xl font-bold">블랙아웃 관리</h1>
    <p class="text-muted-foreground">연차 사용 불가 기간을 관리하세요.</p>

    <div class="rounded-xl border border-border bg-card p-6 shadow-sm min-h-[300px]">
      <p class="text-muted-foreground text-center py-16">
        블랙아웃 규칙 목록이 여기에 표시됩니다.
      </p>
    </div>
  </div>
</template>

<script setup lang="ts">
definePageMeta({
  middleware: ['auth', 'company'],
})
</script>
