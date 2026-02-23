<template>
  <div class="space-y-6">
    <h1 class="text-2xl font-bold">내 기록</h1>
    <p class="text-muted-foreground">휴가 사용/잔여, 근태 내역, 원장을 확인하세요.</p>

    <!-- 탭 -->
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
        {{ activeTabLabel }} 데이터가 여기에 표시됩니다.
      </p>
    </div>
  </div>
</template>

<script setup lang="ts">
definePageMeta({
  middleware: ['auth', 'company'],
})

const tabs = [
  { key: 'leave', label: '휴가 내역' },
  { key: 'attendance', label: '근태 내역' },
  { key: 'ledger', label: '원장(LeaveLedger)' },
]

const activeTab = ref('leave')
const activeTabLabel = computed(() => tabs.find(t => t.key === activeTab.value)?.label ?? '')
</script>
