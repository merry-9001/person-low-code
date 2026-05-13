# person-low-code

一个基于 Vue 3 + Vite + TypeScript 的低代码问卷编辑器。项目提供问卷管理、组件市场、拖拽式编辑、问卷预览、本地 PDF 打印、在线问卷生成与答题提交等能力，适合作为学习“低代码编辑器 / 表单搭建器”的前端项目。

## 技术栈

- Vue 3：页面和组件开发
- TypeScript：类型约束
- Vite：开发服务与生产构建
- Vue Router：页面路由
- Pinia：编辑器状态管理
- Element Plus：基础 UI 组件
- Dexie：浏览器 IndexedDB 封装，用于本地保存问卷
- vuedraggable：拖拽编排组件
- Font Awesome / Element Plus Icons：图标
- Docker + Nginx：生产部署

## 快速开始

```sh
pnpm install
pnpm dev
```

常用命令：

```sh
pnpm dev       # 本地开发
pnpm build     # 类型检查并构建生产包
pnpm preview   # 预览生产构建
pnpm lint      # ESLint 修复
pnpm format    # 格式化 src 目录
```

开发代理在 [vite.config.ts](./vite.config.ts) 中配置：

- `/api` -> `http://localhost:3000`
- `/uploads` -> `http://localhost:3000`

也就是说，在线问卷生成、问卷获取、答案提交等接口需要一个本地后端服务配合。

## 项目结构

```txt
person-low-code
├─ src
│  ├─ assets                 # 全局样式和图片资源
│  ├─ components
│  │  ├─ Common              # 公共组件，例如 Header
│  │  ├─ Editor              # 编辑器内部组件
│  │  └─ SurveyComs          # 问卷物料组件和属性编辑器
│  ├─ configs                # 组件映射、物料分组、默认状态
│  ├─ db                     # Dexie / IndexedDB 数据库封装
│  ├─ router                 # Vue Router 路由
│  ├─ stores                 # Pinia 状态仓库和状态更新动作
│  ├─ types                  # TypeScript 类型定义
│  ├─ utils                  # 工具方法、事件总线、组合式函数
│  └─ views                  # 页面级视图
├─ deploy                    # Docker Compose 和部署脚本
├─ Dockerfile                # 前端镜像构建
├─ nginx.conf                # Nginx 静态资源服务配置
└─ vite.config.ts            # Vite 配置
```

## 页面入口

- `/`：问卷管理首页，创建、查看、编辑、删除问卷
- `/materials`：组件市场，浏览不同类型的问卷组件
- `/editor/:id?/survey-type`：问卷编辑器
- `/editor/:id?/outline`：编辑器大纲视图
- `/preview/:id?`：问卷预览和 PDF 打印
- `/quiz/:id`：在线答题页

路由定义在 [src/router/index.ts](./src/router/index.ts)。

## 核心模块

### 1. 组件物料

物料组件集中在：

```txt
src/components/SurveyComs/Materials
├─ SelectComs      # 单选、多选、下拉、图片选择
├─ InputComs       # 文本输入
├─ AdvancedComs    # 日期时间、评分
└─ NoteComs        # 文本说明
```

组件市场的分组配置在 [src/configs/SurveyGroupConfig.ts](./src/configs/SurveyGroupConfig.ts)。组件名称和实际 Vue 组件的映射在 [src/configs/componentMap.ts](./src/configs/componentMap.ts)。

### 2. 默认状态

每一种问卷组件都有一份默认状态，位于：

```txt
src/configs/defaultStatus
```

例如 `SingleSelect.ts` 定义单选题初始标题、选项、样式、编辑面板等状态。低代码编辑器的关键思想之一就是：页面不是直接写死的，而是由一组可序列化的组件状态驱动渲染。

### 3. 编辑器状态

编辑器主仓库在 [src/stores/useEditor.ts](./src/stores/useEditor.ts)，核心字段包括：

- `currentComponentIndex`：当前选中的画布组件索引
- `surveyCount`：问卷题目数量
- `coms`：画布上的组件状态数组

状态更新动作分布在：

- [src/stores/actions.ts](./src/stores/actions.ts)
- [src/stores/dispatch.ts](./src/stores/dispatch.ts)

编辑器页面 [src/views/EditorView/Index.vue](./src/views/EditorView/Index.vue) 通过 `provide` 向子组件提供 `updateStatus`，属性编辑器通过它修改当前组件状态。

### 4. 本地数据库

本地问卷使用 IndexedDB 保存，Dexie 封装在：

- [src/db/db.ts](./src/db/db.ts)
- [src/db/operation.ts](./src/db/operation.ts)

数据表为 `surveys`，主要保存问卷标题、题目数、创建/更新时间和组件状态数组。

### 5. 预览、在线问卷和提交

预览页在 [src/views/Preview.vue](./src/views/Preview.vue)，它会根据保存的组件状态重新渲染问卷。

主要功能：

- 从 IndexedDB 读取问卷
- 生成在线问卷链接
- 调用 `window.print()` 打印或保存 PDF

答题页在 [src/views/QuizView.vue](./src/views/QuizView.vue)，通过接口获取问卷数据并提交答案：

- `POST /api/saveQuiz`
- `GET /api/getQuiz/:id`
- `POST /api/submitAnswers`

## 核心数据流

```txt
组件市场选择物料
        ↓
根据 defaultStatus 创建组件状态
        ↓
加入 Pinia 的 editor.coms
        ↓
画布根据 componentMap 动态渲染组件
        ↓
右侧属性面板修改当前组件状态
        ↓
保存到 IndexedDB
        ↓
预览 / 打印 PDF / 生成在线问卷
```

学习这个项目时，重点理解两个映射：

- `componentMap`：组件名 -> Vue 组件
- `defaultStatusMap`：组件名 -> 默认状态

这两个映射串起来后，就形成了低代码编辑器的“配置驱动渲染”模型。

## 推荐学习路线

1. 先看 [src/router/index.ts](./src/router/index.ts)，弄清楚有哪些页面。
2. 再看 [src/views/HomeView.vue](./src/views/HomeView.vue)，理解问卷列表从哪里来。
3. 看 [src/db/db.ts](./src/db/db.ts) 和 [src/db/operation.ts](./src/db/operation.ts)，理解 IndexedDB 保存逻辑。
4. 看 [src/views/EditorView/Index.vue](./src/views/EditorView/Index.vue)，理解编辑器如何初始化状态。
5. 看 [src/stores/useEditor.ts](./src/stores/useEditor.ts)，理解画布组件数组 `coms`。
6. 看 [src/configs/componentMap.ts](./src/configs/componentMap.ts)，理解动态组件渲染。
7. 看 [src/configs/defaultStatus](./src/configs/defaultStatus)，理解一个组件需要哪些可编辑状态。
8. 最后看 [src/views/Preview.vue](./src/views/Preview.vue) 和 [src/views/QuizView.vue](./src/views/QuizView.vue)，串起预览、分享和答题流程。

## 如何新增一个问卷组件

以新增一个 `email-input` 组件为例：

1. 在 `src/components/SurveyComs/Materials` 下创建展示组件。
2. 在 `src/configs/defaultStatus` 下创建默认状态文件。
3. 在 `defaultStatusMap.ts` 中注册默认状态。
4. 在 `componentMap.ts` 中注册组件名和 Vue 组件的映射。
5. 在 `SurveyGroupConfig.ts` 中把它加入组件市场。
6. 如果需要新的属性编辑能力，在 `src/components/SurveyComs/EditItems` 中新增编辑器，并接入状态更新逻辑。

## 构建与部署

生产构建：

```sh
pnpm build
```

Docker 部署相关文件：

- [Dockerfile](./Dockerfile)
- [nginx.conf](./nginx.conf)
- [deploy/docker-compose.prod.yml](./deploy/docker-compose.prod.yml)
- [deploy/deploy.sh](./deploy/deploy.sh)

部署脚本默认使用镜像：

```sh
your-dockerhub-username/person-low-code:latest
```

可以通过环境变量覆盖：

```sh
APP_IMAGE=your-name/person-low-code:latest sh deploy/deploy.sh
```

## 学习重点

这个项目最值得学习的不是某个 UI 组件，而是低代码编辑器的通用设计方式：

- 用配置描述组件
- 用状态驱动画布渲染
- 用映射表解耦组件名和组件实现
- 用统一的属性编辑器修改组件状态
- 把画布状态序列化保存，再反序列化恢复

理解这些之后，再做表单搭建器、页面搭建器、流程配置器，思路都是相通的。
