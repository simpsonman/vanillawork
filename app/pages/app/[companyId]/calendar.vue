<template>
  <div class="space-y-6">
    <h1 class="text-2xl font-bold">회사 캘린더</h1>
    <p class="text-muted-foreground">전체 구성원의 휴가 및 일정을 확인하세요.</p>

    <div class="rounded-xl border border-border bg-card p-6 shadow-sm min-h-[400px]">
      <p class="text-muted-foreground text-center py-20">
        캘린더 컴포넌트가 여기에 렌더링됩니다.
      </p>
    </div>
  </div>
</template>

<script setup lang="ts">
definePageMeta({
  middleware: ['auth', 'company'],
})
</script>
