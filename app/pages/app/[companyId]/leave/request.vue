<template>
  <div class="space-y-6">
    <h1 class="text-2xl font-bold">연차/휴가 신청</h1>
    <p class="text-muted-foreground">새로운 휴가를 신청하세요.</p>

    <div class="max-w-lg rounded-xl border border-border bg-card p-6 shadow-sm">
      <form class="space-y-4" @submit.prevent="submitRequest">
        <!-- 휴가 타입 -->
        <div>
          <label class="block text-sm font-medium text-foreground mb-1.5">휴가 종류</label>
          <select
            v-model="form.leave_type_id"
            class="w-full rounded-md border border-input bg-background px-3 py-2 text-sm shadow-sm focus:outline-none focus:ring-1 focus:ring-ring"
          >
            <option value="">선택하세요</option>
          </select>
        </div>

        <!-- 시작일 -->
        <div>
          <label class="block text-sm font-medium text-foreground mb-1.5">시작일</label>
          <input
            v-model="form.start_at"
            type="date"
            class="w-full rounded-md border border-input bg-background px-3 py-2 text-sm shadow-sm focus:outline-none focus:ring-1 focus:ring-ring"
          />
        </div>

        <!-- 종료일 -->
        <div>
          <label class="block text-sm font-medium text-foreground mb-1.5">종료일</label>
          <input
            v-model="form.end_at"
            type="date"
            class="w-full rounded-md border border-input bg-background px-3 py-2 text-sm shadow-sm focus:outline-none focus:ring-1 focus:ring-ring"
          />
        </div>

        <!-- 사용일수 -->
        <div>
          <label class="block text-sm font-medium text-foreground mb-1.5">사용 일수</label>
          <input
            v-model.number="form.amount"
            type="number"
            step="0.5"
            min="0.5"
            class="w-full rounded-md border border-input bg-background px-3 py-2 text-sm shadow-sm focus:outline-none focus:ring-1 focus:ring-ring"
          />
        </div>

        <!-- 사유 (SOFT 블랙아웃 시 필수) -->
        <div>
          <label class="block text-sm font-medium text-foreground mb-1.5">사유 (선택)</label>
          <textarea
            v-model="form.reason"
            rows="3"
            class="w-full rounded-md border border-input bg-background px-3 py-2 text-sm shadow-sm focus:outline-none focus:ring-1 focus:ring-ring resize-none"
            placeholder="블랙아웃(SOFT) 기간에 신청 시 사유를 입력하세요."
          />
        </div>

        <button
          type="submit"
          class="w-full rounded-lg bg-primary px-4 py-2.5 text-sm font-medium text-primary-foreground shadow hover:bg-primary/90 transition-colors"
        >
          신청하기
        </button>
      </form>
    </div>
  </div>
</template>

<script setup lang="ts">
definePageMeta({
  middleware: ['auth', 'company'],
})

const form = reactive({
  leave_type_id: '',
  start_at: '',
  end_at: '',
  amount: 1,
  reason: '',
})

async function submitRequest() {
  // TODO: Supabase leave request 생성 로직
  console.log('Leave request:', form)
}
</script>
