<template>
  <div>
    <div
      class="survey-com-item-container pointer flex justify-content-center align-items-center self-center"
      @click="addSurveyComItem"
    >
      <div>{{ item?.comName }}</div>
    </div>
  </div>
</template>

<script setup lang="ts">
// EventBus
import EventBus from '@/utils/eventBus'
import type { PropType } from 'vue'
import type { MaterialItem } from '@/types'
import { defaultStatusMap } from '@/configs/defaultStatus/defaultStatusMap'
// 仓库
import { useEditorStore } from '@/stores/useEditor'
const store = useEditorStore()
import { updateInitStatusBeforeAdd } from '@/utils'
const props = defineProps({
  item: Object as PropType<MaterialItem>,
})

const addSurveyComItem = () => {
  const newMaterialName = props.item?.materialName
  if (!newMaterialName) {
    console.warn('newMaterialName is required')
    return
  }
  const status = defaultStatusMap[newMaterialName]()
  updateInitStatusBeforeAdd(status, newMaterialName)
  store.addCom(store.coms, status)
  EventBus.emit('scrollToBottom')
}
</script>

<style scoped lang="scss">
.survey-com-item-container {
  width: calc(50% - 4px);
  min-width: 74px;
  height: 44px;
  box-sizing: border-box;
  padding: 0 8px;
  background-color: var(--background-color);
  border-radius: var(--border-radius-md);
  font-size: var(--font-size-base);
  color: var(--font-color-light);
  user-select: none;
  transition: all var(--transition-base);
  > div {
    line-height: 1.2;
    white-space: nowrap;
    word-break: keep-all;
  }
}
.survey-com-item-container:hover {
  background-color: #e8eefc;
  color: var(--primary-color);
}
</style>
