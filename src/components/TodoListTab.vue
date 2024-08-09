<script setup lang="ts">
  import { reactive } from 'vue'

  interface Props {
    active: string
  }

  const { active } = defineProps<Props>()

  const emit = defineEmits(['toggle-active'])

  const tabOptions: string[] = ['all', 'doing', 'done']
</script>

<template>
  <div class="flex mt-4">
    <div
      v-for="item in tabOptions"
      :key="item"
      class="grow py-1 text-center text-cyan-700 uppercase rounded-t-lg border-solid border-b-2 border-cyan-700 cursor-pointer transition duration-300"
      :class="{ '!text-teal-100 bg-cyan-700': item === active }"
      @click.prevent="emit('toggle-active', item)"
    >
      {{ item }}
    </div>
  </div>
</template>
