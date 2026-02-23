<template>
  <div class="space-y-6">
    <h1 class="text-2xl font-bold">연차 부여/조정</h1>
    <p class="text-muted-foreground">개인/부서/회사 단위로 연차를 부여하거나 조정하세요.</p>

    <div class="max-w-lg rounded-xl border border-border bg-card p-6 shadow-sm">
      <form class="space-y-4" @submit.prevent="submitAdjust">
        <div>
          <label class="block text-sm font-medium text-foreground mb-1.5">범위</label>
          <select
            v-model="form.scope_type"
            class="w-full rounded-md border border-input bg-background px-3 py-2 text-sm shadow-sm"
          >
            <option value="USER">개인</option>
            <option value="DEPARTMENT">부서</option>
            <option value="COMPANY">회사 전체</option>
          </select>
        </div>

        <div>
          <label class="block text-sm font-medium text-foreground mb-1.5">수량 (+/-)</label>
          <input
            v-model.number="form.amount"
            type="number"
            step="0.5"
            class="w-full rounded-md border border-input bg-background px-3 py-2 text-sm shadow-sm"
          />
        </div>

        <div>
          <label class="block text-sm font-medium text-foreground mb-1.5">사유 (필수)</label>
          <textarea
            v-model="form.memo"
            rows="3"
            class="w-full rounded-md border border-input bg-background px-3 py-2 text-sm shadow-sm resize-none"
            placeholder="부여/조정 사유를 입력하세요."
          />
        </div>

        <button
          type="submit"
          class="w-full rounded-lg bg-primary px-4 py-2.5 text-sm font-medium text-primary-foreground shadow hover:bg-primary/90 transition-colors"
        >
          부여/조정하기
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
  scope_type: 'USER',
  scope_id: '',
  leave_type_id: '',
  amount: 1,
  memo: '',
})

async function submitAdjust() {
  // TODO: Supabase leave adjustment 로직
  console.log('Leave adjustment:', form)
}
</script>
