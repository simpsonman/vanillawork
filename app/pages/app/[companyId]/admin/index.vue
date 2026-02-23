<template>
  <div class="space-y-6">
    <h1 class="text-2xl font-bold">승인센터</h1>
    <p class="text-muted-foreground">전사 휴가/추가근무 신청을 관리하세요.</p>

    <div class="flex gap-2 border-b border-border">
      <button
        v-for="tab in tabs"
        :key="tab.key"
        class="px-4 py-2 text-sm font-medium transition-colors"
        :class="activeTab === tab.key
          ? 'border-b-2 border-primary text-foreground'
          : 'text-muted-foreground hover:text-foreground'"
        @click="activeTab = tab.key"
      >
        {{ tab.label }}
      </button>
    </div>

    <div class="rounded-xl border border-border bg-card p-6 shadow-sm min-h-[300px]">
      <p class="text-muted-foreground text-center py-16">
        {{ activeTab === 'leave' ? '휴가' : '추가근무' }} 신청 목록이 여기에 표시됩니다.
      </p>
    </div>
  </div>
</template>

<script setup lang="ts">
definePageMeta({
  middleware: ['auth', 'company'],
})

const tabs = [
  { key: 'leave', label: '휴가 신청' },
  { key: 'overtime', label: '추가근무 신청' },
]
const activeTab = ref('leave')
</script>
