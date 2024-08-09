<script setup lang="ts">
  import TodoListFooter from '@/components/TodoListFooter.vue'

  const description =
    'This TodoList is created with Pnpm, Vue3, Vite, TypeScript, and Tailwind CSS.'

  const tip = "The todo list would be stored in browser's local storage."
</script>

<template>
  <div class="page-container">
    <div class="page-wrapper">
      <div class="mt-8 min-h-[200px]">
        <h2 class="text-3xl text-center font-bold">About TodoList</h2>
        <p class="mt-8 text-center">
          {{ description }}
        </p>
        <p class="mt-4 text-center">
          {{ tip }}
        </p>
      </div>

      <TodoListFooter />
    </div>
  </div>
</template>
