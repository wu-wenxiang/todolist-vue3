<template>
  <div>
    <div class="relative">
      <input
        ref="inputRef"
        v-model="inputText"
        class="inline-block mx-auto px-3 py-2 peer w-full rounded-lg border-2 border-solid border-cyan-700 placeholder-transparent focus:outline-none"
        :class="{ 'border-red-700': showInputErrorMessage }"
        type="text"
        name="task"
        placeholder="New Task"
        @keyup.enter="addTask"
        @keyup="checkInputText"
        @blur="showInputErrorMessage = false"
      />
      <label
        class="absolute -top-4 left-2 text-xs text-zinc-700 duration-300 pointer-events-none peer-placeholder-shown:text-base peer-placeholder-shown:top-3 peer-placeholder-shown:left-4 peer-placeholder-shown:text-zinc-300"
        :class="{ 'text-red-700': showInputErrorMessage }"
        for="task"
      >
        New Task
      </label>
      <div
        v-show="showInputErrorMessage"
        class="absolute bottom-0 right-2 mt-1 text-xs text-red-700 duration-300"
      >
        Task name is invalid
      </div>
    </div>

    <TodoListTab :active="activeTab" @toggle-active="toggleActiveTab" />

    <div class="flex justify-end mt-2">
      <!-- <button
        v-if="canEdit && activeTab === 'done'"
        class="btn-primary mt-2 bg-red-900 hover:bg-red-700 transition"
        type="button"
        @click="removeAllTasks"
      >
        Remove All Done Tasks
      </button> -->

      <button
        class="btn-primary mt-2 ml-2"
        type="button"
        @click="canEdit = !canEdit"
      >
        {{ canEdit ? 'Close Edit' : 'Edit Tasks' }}
      </button>
    </div>

    <div class="my-2 min-h-[300px] max-h-[500px] overflow-y-scroll">
      <transition-group name="flip-list" tag="div">
        <div v-if="!filteredTodoList.length">
          <p class="mt-8 text-center text-zinc-500">List is empty.</p>
        </div>

        <div
          v-for="item in filteredTodoList"
          :key="item.id"
          class="relative mt-2 px-4 py-2 bg-slate-300 rounded cursor-pointer"
          :class="{ 'text-slate-500': item.description === 'done' }"
          @click="toggleStatus(item)"
        >
          <div class="flex grow break-all">
            <input
              v-if="canEditText && targetTask.id === item.id"
              v-model="targetTask.name"
              class="w-8/12 px-1 rounded"
              type="text"
              @keyup.enter="saveEditTask"
            />

            <div
              v-else
              :class="{ 'line-through': item.description === 'done' }"
            >
              {{ item.name }}
            </div>

            <div
              class="flex gap-2 ml-auto transition"
              :class="{ 'opacity-0 pointer-events-none': !canEdit }"
            >
              <button
                v-if="canEditText && targetTask.id === item.id"
                class="text-cyan-700 hover:text-cyan-500"
                type="button"
                @click.self="saveEditTask"
              >
                Save
              </button>
              <button
                v-else
                class="text-cyan-700 hover:text-cyan-500"
                type="button"
                @click.self="openEdit(item, $event)"
              >
                Edit
              </button>
              <button
                class="text-red-700 hover:text-red-500"
                type="button"
                @click.self="removeTask(item.id, $event)"
              >
                Remove
              </button>
            </div>
          </div>

          <div class="shrink-0 text-right text-sm text-slate-500 leading-4">
            {{ convertDateText(item.updated_at || item.created_at) }}
          </div>
        </div>
      </transition-group>
    </div>
  </div>
</template>
<script setup lang="ts">
  import { ref, reactive, computed, onMounted } from 'vue'
  import TodoListTab from '@/components/TodoListTab.vue'
  import axios from 'axios'
  import dayjs from 'dayjs'

  const convertDateText = (date: Date) => {
    return dayjs(date).add(8, 'hour').format('YYYY/MM/DD HH:mm:ss')
    // return new Date(date)
    //   .toLocaleString()
    //   .replace('上午', 'am')
    //   .replace('下午', 'pm')
  }

  interface TodoListItem {
    id: number
    name: string
    description: string
    updated_at: Date
    created_at?: Date
  }

  const inputRef = ref<HTMLInputElement | null>(null)

  const inputText = ref<string>('')
  const clearInputText = () => (inputText.value = '')

  const showInputErrorMessage = ref<boolean>(false)
  const checkInputText = () => {
    const trimmedInputText = inputText.value.trim()

    showInputErrorMessage.value = !trimmedInputText && inputText.value !== ''
  }

  const activeTab = ref<string>('all')
  const toggleActiveTab = (active: string) => {
    activeTab.value = active
  }

  const todoList: TodoListItem[] = reactive([])

  const addTask = () => {
    const trimmedInputText = inputText.value.trim()

    if (!trimmedInputText) return
    const data = {
      id: new Date().getTime(),
      name: trimmedInputText,
      description: 'doing',
      created_at: new Date(),
      updated_at: new Date(),
    }
    // todoList.push(data)
    clearInputText()
    // setLocalStorageTodoList()
    createItem(data)
  }
  const removeTask = (id: number, event:any) => {
    event.stopPropagation();
    // const removedList: TodoListItem[] = todoList.filter(
    //   (item) => item.id !== id
    // )

    // todoList.length = 0
    // Object.assign(todoList, removedList)
    // setLocalStorageTodoList()
    axios
      .delete(`/api/v1/todoelems/${id}`, {
        headers: {
          'X-Auth-Token': '',
        },
      })
      .then((response: any) => {
        fetchList()
      })
  }
  // const removeAllTasks = () => {
  //   const removedAllDoneList: TodoListItem[] = todoList.filter(
  //     (item) => item.description !== 'done'
  //   )

  //   todoList.length = 0
  //   Object.assign(todoList, removedAllDoneList)
  //   setLocalStorageTodoList()
  // }

  const canEditText = ref<boolean>(false)
  const targetTask = ref<TodoListItem>({
    id: 0,
    name: '',
    description: '',
    updated_at: new Date(),
  })

  const openEdit = (item: TodoListItem, event:any) => {
    event.stopPropagation();
    canEditText.value = true
    targetTask.value = item
  }

  const saveEditTask = () => {
    canEditText.value = false
    // setLocalStorageTodoList()
    const data = {
      todoelem: {
        name: targetTask.value.name,
        // updated_at: new Date(),
      },
    }
    axios
      .put(`/api/v1/todoelems/${targetTask.value.id}`, data, {
        headers: {
          'X-Auth-Token': '',
        },
      })
      .then((response: any) => {
        console.log('response', response)
        fetchList()
      })
  }

  const filteredTodoList = computed<TodoListItem[]>(() => {
    if (activeTab.value === 'all') return todoList
    if (activeTab.value === 'doing')
      return todoList.filter((item) => item.description === 'doing')
    if (activeTab.value === 'done')
      return todoList.filter((item) => item.description === 'done')

    return todoList.filter((item) => item.description === activeTab.value)
  })

  const canEdit = ref<boolean>(false)



  const toggleStatus = (target: TodoListItem) => {
    if (canEdit.value) return;
    if (target.description === 'done' && activeTab.value === 'done') return;
    // todoList.forEach(
    // todoList.forEach((item) => {
    //   if (item.id === target.id)
    //     item.description = tem.description = item.description === 'doing' ? 'done' : 'doing'
    // })
    const description = target.description === 'doing' ? 'done' : 'doing'
    const data = {
      todoelem: {
        ...target,
        description,
        // updated_at: new Date(),
      },
    }
    axios
      .put(`/api/v1/todoelems/${target.id}`, data, {
        headers: {
          'X-Auth-Token': '',
        },
      })
      .then((response: any) => {
        console.log('response', response)
        fetchList()
      })
  }

  // const checkLocalStorageTodoList = () => {
  //   const localStorageTodoList: TodoListItem[] = JSON.parse(
  //     localStorage.getItem('_vue3-todo-list_list') || '[]'
  //   )

  //   if (localStorageTodoList.length)
  //     Object.assign(todoList, localStorageTodoList)
  // }

  const setLocalStorageTodoList = () => {
    localStorage.setItem('_vue3-todo-list_list', JSON.stringify(todoList))
  }

  const fetchList = () => {
    axios
      .get('/api/v1/todoelems', {
        headers: {
          'X-Auth-Token': '',
        },
      })
      .then((response: any) => {
        console.log('response', response)
        todoList.length = 0
        Object.assign(todoList, response.data.todoelems)
      })
  }

  const createItem = ({ name, description }: TodoListItem) => {
    const body = {
      todoelem: {
        name: name,
        description: description,
        // created_at: new Date()
      },
    }
    axios
      .post('/api/v1/todoelems', body, {
        headers: {
          'X-Auth-Token': '',
        },
      })
      .then((response: any) => {
        console.log('response', response)
        fetchList()
      })
  }

  onMounted(() => {
    inputRef.value?.focus()
    // checkLocalStorageTodoList()

    fetchList()
  })
</script>
