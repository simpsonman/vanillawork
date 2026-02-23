<template>
  <div class="space-y-6">
    <h1 class="text-2xl font-bold">추가근무 신청</h1>
    <p class="text-muted-foreground">추가근무를 신청하세요.</p>

    <div class="max-w-lg rounded-xl border border-border bg-card p-6 shadow-sm">
      <form class="space-y-4" @submit.prevent="submitRequest">
        <div>
          <label class="block text-sm font-medium text-foreground mb-1.5">시작 시간</label>
          <input
            v-model="form.start_at"
            type="datetime-local"
            class="w-full rounded-md border border-input bg-background px-3 py-2 text-sm shadow-sm focus:outline-none focus:ring-1 focus:ring-ring"
          />
        </div>

        <div>
          <label class="block text-sm font-medium text-foreground mb-1.5">종료 시간</label>
          <input
            v-model="form.end_at"
            type="datetime-local"
            class="w-full rounded-md border border-input bg-background px-3 py-2 text-sm shadow-sm focus:outline-none focus:ring-1 focus:ring-ring"
          />
        </div>

        <div>
          <label class="block text-sm font-medium text-foreground mb-1.5">사유</label>
          <textarea
            v-model="form.reason"
            rows="3"
            class="w-full rounded-md border border-input bg-background px-3 py-2 text-sm shadow-sm focus:outline-none focus:ring-1 focus:ring-ring resize-none"
            placeholder="추가근무 사유를 입력하세요."
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
  start_at: '',
  end_at: '',
  reason: '',
})

async function submitRequest() {
  // TODO: Supabase overtime request 생성 로직
  console.log('Overtime request:', form)
}
</script>
