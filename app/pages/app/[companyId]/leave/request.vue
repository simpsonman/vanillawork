<template>
  <div class="space-y-8 animate-in fade-in slide-in-from-bottom-4 duration-700 max-w-2xl mx-auto">
    <!-- Header Section -->
    <div class="space-y-2">
      <h1 class="font-heading text-3xl font-bold tracking-tight text-slate-800 dark:text-slate-100">
        연차/휴가 신청
      </h1>
      <p class="text-[15px] flex items-center gap-2 text-slate-500 dark:text-slate-400">
        <span>새로운 휴가를 신청하세요.</span>
        <span v-if="!loadingInit" class="px-2 py-0.5 rounded-full bg-indigo-50 dark:bg-indigo-900/30 text-indigo-700 dark:text-indigo-300 text-xs font-semibold">
          내 잔여 연차: {{ remainingLeave }}일
        </span>
      </p>
    </div>

    <!-- Main Form Card -->
    <div class="relative overflow-hidden rounded-2xl bg-white/40 dark:bg-slate-950/40 backdrop-blur-xl border border-white/60 dark:border-slate-800/50 shadow-[0_8px_30px_-12px_rgba(0,0,0,0.06)] dark:shadow-[0_8px_30px_-12px_rgba(0,0,0,0.3)] p-6 sm:p-8">
       <!-- Subtle inner highlight -->
       <div class="absolute inset-x-0 top-0 h-px bg-gradient-to-r from-transparent via-white/50 dark:via-white/10 to-transparent"></div>

       <div v-if="loadingInit" class="flex flex-col items-center justify-center py-12 space-y-4">
          <div class="w-8 h-8 rounded-full border-[3px] border-indigo-500/30 border-t-indigo-500 animate-spin"></div>
          <p class="text-sm text-slate-500">데이터를 불러오는 중입니다...</p>
       </div>

       <form v-else class="space-y-6 relative z-10" @submit.prevent="submitRequest">
        <!-- Error Alert -->
        <div v-if="errorMsg" class="p-4 rounded-xl bg-red-50 dark:bg-red-900/20 border border-red-200 dark:border-red-800/50 flex items-start gap-3 text-red-600 dark:text-red-400">
          <AlertCircle class="w-5 h-5 shrink-0 mt-0.5" />
          <div class="text-sm">{{ errorMsg }}</div>
        </div>

        <div class="grid gap-6 sm:grid-cols-2">
          <!-- 휴가 타입 -->
          <div class="space-y-2 sm:col-span-2">
            <label class="text-sm font-medium text-slate-700 dark:text-slate-300">휴가 종류</label>
            <select
              v-model="form.leave_type_id"
              class="w-full h-12 rounded-xl border border-slate-200 dark:border-slate-700/50 bg-white/60 dark:bg-slate-900/60 px-4 text-sm text-slate-800 dark:text-slate-200 shadow-sm focus:outline-none focus:ring-2 focus:ring-indigo-500/50 focus:border-indigo-500 transition-all appearance-none"
              :disabled="loadingSubmit"
              required
            >
              <option value="" disabled>휴가 종류를 선택하세요</option>
              <option v-for="type in leaveTypes" :key="type.id" :value="type.id">
                {{ type.name }}
              </option>
            </select>
          </div>

          <!-- 시작일 -->
          <div class="space-y-2">
            <label class="text-sm font-medium text-slate-700 dark:text-slate-300">시작일</label>
            <input
              v-model="form.start_at"
              type="date"
              class="w-full h-12 rounded-xl border border-slate-200 dark:border-slate-700/50 bg-white/60 dark:bg-slate-900/60 px-4 text-sm text-slate-800 dark:text-slate-200 shadow-sm focus:outline-none focus:ring-2 focus:ring-indigo-500/50 focus:border-indigo-500 transition-all"
              :disabled="loadingSubmit"
              required
            />
          </div>

          <!-- 종료일 -->
          <div class="space-y-2">
            <label class="text-sm font-medium text-slate-700 dark:text-slate-300">종료일</label>
            <input
              v-model="form.end_at"
              type="date"
              class="w-full h-12 rounded-xl border border-slate-200 dark:border-slate-700/50 bg-white/60 dark:bg-slate-900/60 px-4 text-sm text-slate-800 dark:text-slate-200 shadow-sm focus:outline-none focus:ring-2 focus:ring-indigo-500/50 focus:border-indigo-500 transition-all"
              :disabled="loadingSubmit"
              required
            />
          </div>

          <!-- 사용일수 -->
          <div class="space-y-2 sm:col-span-2">
            <label class="text-sm font-medium text-slate-700 dark:text-slate-300">사용 일수</label>
            <input
              v-model.number="form.amount"
              type="number"
              step="0.5"
              min="0.5"
              class="w-full h-12 rounded-xl border border-slate-200 dark:border-slate-700/50 bg-white/60 dark:bg-slate-900/60 px-4 text-sm text-slate-800 dark:text-slate-200 shadow-sm focus:outline-none focus:ring-2 focus:ring-indigo-500/50 focus:border-indigo-500 transition-all"
              :disabled="loadingSubmit"
              required
            />
          </div>

          <!-- 사유 (SOFT 블랙아웃 시 필수) -->
          <div class="space-y-2 sm:col-span-2">
            <label class="text-sm font-medium flex items-center gap-2 text-slate-700 dark:text-slate-300">
              사유
              <span class="text-[11px] font-normal text-slate-500 bg-slate-100 dark:bg-slate-800 px-1.5 py-0.5 rounded">선택</span>
            </label>
            <textarea
              v-model="form.comment"
              rows="3"
              class="w-full rounded-xl border border-slate-200 dark:border-slate-700/50 bg-white/60 dark:bg-slate-900/60 p-4 text-sm text-slate-800 dark:text-slate-200 shadow-sm focus:outline-none focus:ring-2 focus:ring-indigo-500/50 focus:border-indigo-500 transition-all resize-none placeholder:text-slate-400"
              placeholder="특정 기간(블랙아웃) 신청 시 사유 작성이 필수일 수 있습니다."
              :disabled="loadingSubmit"
            />
          </div>
        </div>

        <div class="pt-4 flex gap-3">
          <Button
            type="button"
            variant="outline"
            class="flex-1 h-12 rounded-xl bg-white/50 dark:bg-slate-800/50 hover:bg-white dark:hover:bg-slate-800 border-slate-200 dark:border-slate-700/50 text-slate-700 dark:text-slate-300 transition-all"
            @click="$router.push(`/app/${company?.id}/dashboard`)"
            :disabled="loadingSubmit"
          >
            취소
          </Button>
          <Button
            type="submit"
            class="flex-[2] h-12 bg-indigo-600 hover:bg-indigo-700 text-white shadow-md transition-all duration-300 rounded-xl font-medium text-base relative overflow-hidden group"
            :disabled="loadingSubmit || !isValid"
          >
            <div class="absolute inset-0 bg-white/20 translate-y-full group-hover:translate-y-0 transition-transform duration-300 ease-out"></div>
            <span class="relative flex items-center justify-center gap-2">
              <div v-if="loadingSubmit" class="h-5 w-5 rounded-full border-[2.5px] border-white/30 border-t-white animate-spin"></div>
              <span>신청서 제출</span>
            </span>
          </Button>
        </div>
      </form>
    </div>
  </div>
</template>

<script setup lang="ts">
import { AlertCircle } from 'lucide-vue-next'
import { Button } from '@/components/ui/button'

definePageMeta({
  middleware: ['auth', 'company'],
})

const { company } = useCompany()
const supabase = useSupabaseClient()
const user = useSupabaseUser()
const router = useRouter()

const loadingInit = ref(true)
const loadingSubmit = ref(false)
const errorMsg = ref('')

const leaveTypes = ref<any[]>([])
const remainingLeave = ref(0)

const form = reactive({
  leave_type_id: '',
  start_at: '',
  end_at: '',
  amount: 1,
  comment: '', // 명세에 따라 사유는 leave_requests.comment 매핑
})

const isValid = computed(() => {
  return form.leave_type_id && form.start_at && form.end_at && form.amount > 0
})

async function fetchInitialData() {
  if (!company?.value?.id || !user.value?.id) return
  errorMsg.value = ''
  
  try {
    const companyId = company.value.id
    
    // 1. 활성화된 휴가 종류 가져오기
    const { data: types, error: typeErr } = await supabase
      .from('leave_types')
      .select('*')
      .eq('company_id', companyId)
      .eq('is_active', true)
      
    if (typeErr) throw typeErr
    leaveTypes.value = types || []

    // 2. 내 잔여 연차 가져오기 (원장 합계)
    const { data: ledgerData, error: ledgerErr } = await supabase
      .from('leave_ledger')
      .select('amount')
      .eq('company_id', companyId)
      .eq('user_id', user.value.id)

    if (ledgerErr) throw ledgerErr

    if (ledgerData && ledgerData.length > 0) {
      remainingLeave.value = (ledgerData as any[]).reduce((acc, row) => acc + Number(row.amount || 0), 0)
    }
  } catch (err: any) {
    console.error('Initial data load error:', err)
    errorMsg.value = '데이터를 불러오는데 실패했습니다.'
  } finally {
    loadingInit.value = false
  }
}

async function submitRequest() {
  if (!isValid.value || loadingSubmit.value || !company?.value?.id || !user.value?.id) return
  
  errorMsg.value = ''
  
  // 간단한 클라이언트 측 잔여 확인 로직 (MVP)
  // 하드/소프트 차단은 서버 로직 검증에 맡깁니다.
  if (form.amount > remainingLeave.value) {
    errorMsg.value = `잔여 연차(${remainingLeave.value}일)가 부족합니다.`
    return
  }

  loadingSubmit.value = true
  
  try {
    const { error } = await supabase
      .from('leave_requests')
      .insert({
        company_id: company.value.id,
        user_id: user.value.id,
        leave_type_id: form.leave_type_id,
        start_at: form.start_at,
        end_at: form.end_at,
        amount: form.amount,
        comment: form.comment || null,
        status: 'PENDING'
      } as any)

    if (error) throw error

    // 성공 시 대시보드나 내 기록으로 이동
    router.push(`/app/${company.value.id}/dashboard`)
    
  } catch (err: any) {
    console.error('Submit error:', err)
    errorMsg.value = err.message || '휴가 신청 중 오류가 발생했습니다.'
  } finally {
    loadingSubmit.value = false
  }
}

onMounted(() => {
  fetchInitialData()
})
</script>
