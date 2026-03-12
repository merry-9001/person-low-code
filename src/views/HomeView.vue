<template>
  <div class="home-page">
    <div class="container page-card">
      <h1 class="page-title text-center">问卷管理系统</h1>
      <div class="action-row mb-15">
        <el-button type="primary" :icon="Plus" @click="goToEditor">创建问卷</el-button>
        <el-button type="success" :icon="Compass" @click="goToComMarket">组件市场</el-button>
      </div>
      <el-table :data="tableData" style="width: 100%" border stripe>
        <el-table-column
          fixed
          prop="createDate"
          label="创建日期"
          width="150"
          :formatter="formatDate"
        />
        <el-table-column prop="title" label="问卷标题" />
        <el-table-column prop="surveyCount" label="题目数" width="150" align="center" />
        <el-table-column
          prop="updateDate"
          label="最近更新日期"
          width="150"
          align="center"
          :formatter="formatDate"
        />
        <el-table-column fixed="right" label="操作" width="360" align="center">
          <template #default="scope">
            <el-button link type="primary" class="op-action-btn" @click="viewSurvey(scope.row)"
              >查看问卷</el-button
            >
            <el-button link type="primary" class="op-action-btn" @click="editSurvey(scope.row)"
              >编辑</el-button
            >
            <el-button link type="danger" class="op-action-btn" @click="delSurvey(scope.row)"
              >删除</el-button
            >
          </template>
        </el-table-column>
      </el-table>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref } from 'vue'
import { Plus, Compass } from '@element-plus/icons-vue'
// 路由
import { useRouter } from 'vue-router'
const router = useRouter()
// 类型
import type { SurveyDBData, SurveyDBReturnData } from '@/types'
// indexedDB
import { getSurveys } from '@/db/operation'
// 工具方法
import { formatDate } from '@/utils'
import { remove } from '@/utils/dboperate'

const tableData = ref<SurveyDBData[]>([])

function getSurveyData() {
  getSurveys().then((res) => {
    tableData.value = res
  })
}
getSurveyData()

const goToEditor = () => {
  localStorage.setItem('activeView', 'editor')
  router.push('/editor/survey-type')
}

const goToComMarket = () => {
  localStorage.setItem('activeView', 'materials')
  router.push('/materials')
}

const viewSurvey = (surveyInfo: SurveyDBReturnData) => {
  router.push({
    path: `/preview/${surveyInfo.id}`,
    state: { from: 'home' },
  })
}

const editSurvey = (surveyInfo: SurveyDBReturnData) => {
  router.push(`/editor/${surveyInfo.id}/survey-type`)
}

const delSurvey = (surveyInfo: SurveyDBReturnData) => {
  remove(Number(surveyInfo.id)).then(() => {
    getSurveyData()
  })
}
</script>

<style scoped>
.home-page {
  min-height: 100vh;
  padding: 28px;
  box-sizing: border-box;
}

.container {
  max-width: 1200px;
  margin: 0 auto;
  padding: 28px;
  animation: page-fade-in 0.5s ease;
}

.action-row {
  display: flex;
  gap: 12px;
}

:deep(.el-table) {
  border-radius: var(--border-radius-md);
  overflow: hidden;
}

:deep(.el-table th.el-table__cell) {
  background: var(--background-soft);
  color: var(--font-color);
  font-weight: 600;
}

:deep(.el-table tr) {
  transition: background-color var(--transition-base);
}

:deep(.op-action-btn) {
  font-size: 16px;
  font-weight: 600;
  padding: 10px 8px;
  line-height: 1;
}

:deep(.op-action-btn + .op-action-btn) {
  margin-left: 12px;
}

:deep(.op-action-btn .el-button__text) {
  transition: all var(--transition-base);
}

:deep(.op-action-btn:hover .el-button__text) {
  transform: translateY(-1px);
}

@keyframes page-fade-in {
  from {
    opacity: 0;
    transform: translateY(8px);
  }
  to {
    opacity: 1;
    transform: translateY(0);
  }
}
</style>
