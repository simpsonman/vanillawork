<template>
  <NuxtLink
    :to="fullPath"
    class="flex items-center gap-3 rounded-md px-3 py-2 text-sm font-medium transition-colors"
    :class="isActive
      ? 'bg-accent text-accent-foreground'
      : 'text-muted-foreground hover:bg-accent hover:text-accent-foreground'"
    active-class="bg-accent text-accent-foreground"
  >
    <component :is="iconComponent" class="h-4 w-4" />
    <span>{{ label }}</span>
  </NuxtLink>
</template>

<script setup lang="ts">
import * as icons from 'lucide-vue-next'

const props = defineProps<{
  to: string
  icon: string
  label: string
}>()

const route = useRoute()
const companyId = computed(() => route.params.companyId as string)

const fullPath = computed(() => `/app/${companyId.value}/${props.to}`)

const isActive = computed(() => route.path === fullPath.value)

const iconComponent = computed(() => {
  return (icons as any)[props.icon] ?? icons.Circle
})
</script>
