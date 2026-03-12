<template>
  <Header :isEditor="false" />
  <div class="materials-page">
    <h1 class="page-title text-center m0 p0">组件市场</h1>
    <div class="container mc flex page-card">
      <nav class="category mc">
        <Router-Link to="/select-group" class="category-item">
          <el-icon>
            <CircleCheck />
          </el-icon>
          <div>选择</div>
        </Router-Link>
        <Router-Link to="/input-group" class="category-item">
          <el-icon>
            <EditPen />
          </el-icon>
          <div>文本输入</div>
        </Router-Link>
        <Router-Link to="/advanced-group" class="category-item">
          <el-icon>
            <Files />
          </el-icon>
          <div>高级题型</div>
        </Router-Link>
        <Router-Link to="/note-group" class="category-item">
          <el-icon>
            <ChatLineSquare />
          </el-icon>
          <div>备注说明</div>
        </Router-Link>
        <Router-Link to="/personal-info-group" class="category-item">
          <el-icon>
            <User />
          </el-icon>
          <div>个人信息</div>
        </Router-Link>
        <Router-Link to="/contact-group" class="category-item">
          <el-icon>
            <Message />
          </el-icon>
          <div>联系方式</div>
        </Router-Link>
      </nav>
      <div class="coms">
        <Router-view />
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import Header from '@/components/Common/Header.vue'
// 引入对应图标
import { CircleCheck, Files, EditPen, ChatLineSquare, User, Message } from '@element-plus/icons-vue'
</script>

<style scoped lang="scss">
.container {
  width: 1180px;
  height: 600px;
  overflow: hidden;
}
.category {
  width: 70px;
  height: 100%;
  padding: 16px 0;
  background: linear-gradient(180deg, #eef2ff 0%, #f8fafc 100%);
  > .category-item {
    width: 70px;
    height: 70px;
    display: flex;
    flex-direction: column;
    justify-content: center;
    align-items: center;
    margin-bottom: 10px;
    text-align: center;
    text-decoration: none;
    font-size: var(--font-size-base);
    color: var(--primary-color);
    background: rgba(79, 70, 229, 0.08);
    border: 1px solid rgba(79, 70, 229, 0.14);
    border-top-left-radius: var(--border-radius-lg);
    border-bottom-left-radius: var(--border-radius-lg);
    transition: all var(--transition-base);
    &:hover {
      transform: translateX(2px);
      background: rgba(79, 70, 229, 0.14);
      border-color: rgba(79, 70, 229, 0.28);
    }
  }
}

.category-item.router-link-active,
.category-item.router-link-exact-active {
  color: var(--white);
  background: linear-gradient(135deg, var(--primary-color), #6366f1);
  border-color: transparent;
  box-shadow: 0 10px 20px rgba(79, 70, 229, 0.28);
}
.coms {
  width: calc(1180px - 60px);
  height: 100%;
  background: var(--surface-color);
}

h1 {
  height: 56px;
  margin: 20px 0;
}

.materials-page {
  padding: 0 20px 20px;
}

.custom-tabs-label .el-icon {
  vertical-align: middle;
}
.custom-tabs-label span {
  vertical-align: middle;
  margin-left: 5px;
}
</style>
