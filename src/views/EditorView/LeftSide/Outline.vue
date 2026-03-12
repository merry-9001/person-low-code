<template>
  <div v-if="store.surveyCount">
    <draggable v-model="store.coms" item-key="index" @start="dragstart">
      <template #item="{ element, index }">
        <div
          class="mb-10"
          @click="clickHandle(index)"
          :key="element.id"
          v-show="isSurveyComName(element.name)"
          :class="{
            active: store.currentComponentIndex === index,
          }"
        >
          <div class="item">
            {{ serialNum[index] }}.
            {{
              element.status.title.status.length > 10
                ? element.status.title.status.substring(0, 10) + '...'
                : element.status.title.status
            }}
          </div>
        </div>
      </template>
    </draggable>
  </div>
  <div v-else class="tip flex align-items-center justify-content-center">请添加题目</div>
</template>

<script setup lang="ts">
import { computed } from 'vue'
// EventBus
import EventBus from '@/utils/eventBus'
import { useEditorStore } from '@/stores/useEditor'
const store = useEditorStore()
// 拖动组件
import draggable from 'vuedraggable'
// 类型
import { isSurveyComName } from '@/types'
// 组合式函数
import { useSurveyNo } from '@/utils/hooks'
// 获取题目编号
const serialNum = computed(() => useSurveyNo(store.coms).value)
// 组件名
defineOptions({
  name: 'Outline',
})
// 拖动开始
function dragstart() {
  // 拖动开始的时候，将当前选中的组件取消选中
  store.setCurrentComponentIndex(-1)
}
const clickHandle = function (index: number) {
  if (store.currentComponentIndex === index) {
    store.setCurrentComponentIndex(-1)
  } else {
    store.setCurrentComponentIndex(index)
    EventBus.emit('scrollToCenter', index)
  }
}
</script>

<style scoped>
.item {
  color: var(--font-color-light);
  font-size: var(--font-size-base);
  padding: 10px;
  cursor: pointer;
  border-radius: var(--border-radius-md);
  border: 1px solid transparent;
  transition: all var(--transition-base);
}
.item:hover {
  border-color: #cbd5e1;
  background-color: #f8fafc;
}
.tip {
  height: calc(100% - 40px);
}
.active {
  transform: translateY(-1px);
  transition: all var(--transition-base);
  background-color: #eef2ff;
  border-radius: var(--border-radius-md);
}
</style>
