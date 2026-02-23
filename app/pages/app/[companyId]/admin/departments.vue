<template>
  <div class="space-y-6">
    <h1 class="text-2xl font-bold">조직(부서) 관리</h1>
    <p class="text-muted-foreground">부서 구조를 관리하세요.</p>

    <div class="rounded-xl border border-border bg-card p-6 shadow-sm min-h-[300px]">
      <p class="text-muted-foreground text-center py-16">
        부서 트리가 여기에 표시됩니다.
      </p>
    </div>
  </div>
</template>

<script setup lang="ts">
definePageMeta({
  middleware: ['auth', 'company'],
})
</script>
