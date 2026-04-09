# Docker Hub 自动部署说明

这套配置已经改成：

1. 代码 push 到 GitHub `main`
2. GitHub Actions 自动构建 Docker 镜像
3. GitHub Actions 把镜像 push 到 Docker Hub
4. GitHub Actions 通过 SSH 登录服务器
5. 服务器拉取最新镜像并重启容器

也就是现在的流程不再是“服务器本地 build”，而是“服务器只 pull 镜像并运行”。

## 一、为什么要改成 Docker Hub

相比服务器本地构建，这种方式更适合正式部署：

- 服务器更轻，只负责拉镜像和运行容器
- 不需要在服务器上安装 Node、pnpm 这些前端构建环境
- 多台服务器可以复用同一个镜像
- 回滚更方便，可以切回旧 tag
- 构建过程集中在 GitHub，更清晰

## 二、这些文件现在分别干什么

### `Dockerfile`

负责定义镜像怎么构建。

它会：

1. 用 Node 环境安装依赖并执行 `pnpm build`
2. 把打包产物复制到 `nginx` 镜像里

### `nginx.conf`

负责让 nginx 正确托管前端静态文件，并支持 Vue 路由刷新不 404。

### `docker-compose.prod.yml`

负责定义服务器上容器怎么启动。

现在它不再本地 build，而是直接使用镜像：

```yaml
image: ${APP_IMAGE:-your-dockerhub-username/person-low-code:latest}
```

意思是：

- 优先使用环境变量 `APP_IMAGE`
- 如果没传，就默认用占位值

### `deploy/deploy.sh`

负责服务器上的部署动作。

它现在会：

1. 拉取最新仓库代码
2. 读取 `APP_IMAGE`
3. 执行 `docker compose pull`
4. 执行 `docker compose up -d`

### `.github/workflows/deploy.yml`

负责自动化流程：

1. `checkout` 代码
2. 登录 Docker Hub
3. 构建镜像
4. push 到 Docker Hub
5. SSH 到服务器触发部署

### `.dockerignore`

负责减少 Docker 构建时不必要的上下文文件。

## 三、当前自动部署流程

你每次 push 到 `main` 时，流程是：

1. GitHub Actions 被触发
2. GitHub 使用 `Dockerfile` 构建镜像
3. 镜像 push 到 Docker Hub
4. GitHub SSH 登录服务器
5. 服务器运行 `deploy/deploy.sh`
6. 服务器执行 `docker compose pull`
7. 服务器更新为最新镜像版本

## 四、你需要准备什么

### 1. Docker Hub 账号

你需要有一个 Docker Hub 账号。

比如用户名是：

```text
yourname
```

那镜像名就会像这样：

```text
yourname/person-low-code:latest
```

### 2. 服务器基础环境

服务器需要安装：

- `git`
- `docker`
- `docker compose`

注意：

- 服务器不需要安装 Node
- 服务器不需要安装 pnpm

### 3. 服务器要先 clone 仓库

假设你把项目放到：

```bash
/opt/person-low-code
```

那就在服务器执行：

```bash
git clone <你的仓库地址> /opt/person-low-code
cd /opt/person-low-code
chmod +x deploy/deploy.sh
```

## 五、GitHub Secrets 现在要填什么

打开仓库：

`Settings > Secrets and variables > Actions`

然后添加这些 secrets。

### 服务器相关

- `SERVER_HOST`
- `SERVER_PORT`
- `SERVER_USERNAME`
- `SERVER_SSH_KEY`
- `SERVER_DEPLOY_PATH`

### Docker Hub 相关

- `DOCKERHUB_USERNAME`
- `DOCKERHUB_TOKEN`

## 六、Docker Hub Token 怎么拿

不要用密码，建议用 Access Token。

步骤：

1. 登录 Docker Hub
2. 进入 `Account Settings`
3. 找到 `Personal access tokens`
4. 创建一个新 token
5. 把 token 填到 GitHub Secret `DOCKERHUB_TOKEN`

`DOCKERHUB_USERNAME` 就填你的 Docker Hub 用户名。

## 七、服务器第一次怎么手动验证

建议先手动 pull 一次镜像，确认服务器能正常启动容器。

### 第一步：登录 Docker Hub

在服务器执行：

```bash
docker login -u your-dockerhub-username
```

然后输入你的 Docker Hub token 或密码。

如果你的镜像是公开仓库，这一步通常不是必须的。
如果你的镜像是私有仓库，这一步一般需要先做。

### 第二步：手动指定镜像并部署

```bash
cd /opt/person-low-code
export APP_IMAGE=your-dockerhub-username/person-low-code:latest
./deploy/deploy.sh main
```

### 第三步：检查容器

```bash
docker ps
docker logs person-low-code
```

### 第四步：访问页面

```text
http://你的服务器IP:8080
```

## 八、GitHub Actions 现在具体做什么

工作流文件是：

`/.github/workflows/deploy.yml`

它现在会做这些事：

### 1. 拉取仓库代码

```yaml
uses: actions/checkout@v4
```

### 2. 登录 Docker Hub

```yaml
uses: docker/login-action@v3
```

### 3. 生成镜像标签

它会推送两个 tag：

- `latest`
- 当前 commit 的 sha

比如：

```text
yourname/person-low-code:latest
yourname/person-low-code:abcdef1
```

### 4. 构建并推送镜像

```yaml
uses: docker/build-push-action@v6
```

### 5. 远程登录服务器部署

服务器会收到：

```bash
export APP_IMAGE="yourname/person-low-code:latest"
./deploy/deploy.sh main
```

## 九、服务器部署脚本现在做什么

`deploy/deploy.sh` 现在的核心逻辑是：

```bash
git pull --ff-only origin main
docker compose -f docker-compose.prod.yml pull
docker compose -f docker-compose.prod.yml up -d --remove-orphans
```

意思是：

1. 同步最新仓库代码
2. 拉取最新镜像
3. 重启容器到最新版本

## 十、一步一步完整配置

### 第一步：确认本地文件已经更新

确认仓库里有这些文件：

- `Dockerfile`
- `nginx.conf`
- `docker-compose.prod.yml`
- `deploy/deploy.sh`
- `.github/workflows/deploy.yml`
- `.dockerignore`
- `DEPLOY.md`

### 第二步：准备 Docker Hub

1. 注册或登录 Docker Hub
2. 创建 Access Token
3. 记下 Docker Hub 用户名

### 第三步：配置 GitHub Secrets

添加：

- `DOCKERHUB_USERNAME`
- `DOCKERHUB_TOKEN`
- `SERVER_HOST`
- `SERVER_PORT`
- `SERVER_USERNAME`
- `SERVER_SSH_KEY`
- `SERVER_DEPLOY_PATH`

### 第四步：准备服务器

在服务器安装：

```bash
git --version
docker --version
docker compose version
```

确保这些命令可用。

### 第五步：clone 仓库到服务器

```bash
git clone <你的仓库地址> /opt/person-low-code
cd /opt/person-low-code
chmod +x deploy/deploy.sh
```

### 第六步：服务器先手动测试一次

```bash
docker login -u your-dockerhub-username
cd /opt/person-low-code
export APP_IMAGE=your-dockerhub-username/person-low-code:latest
./deploy/deploy.sh main
```

### 第七步：push 代码到 GitHub

```bash
git add .
git commit -m "chore: switch deploy to docker hub"
git push origin main
```

### 第八步：查看 GitHub Actions

进入 GitHub 仓库的 `Actions` 页面。

你应该能看到工作流：

`Deploy To Server`

如果成功：

1. Docker 镜像会被推送到 Docker Hub
2. 服务器会自动 pull 最新镜像并更新容器

## 十一、怎么访问

当前端口映射是：

```yaml
8080:80
```

所以访问地址是：

```text
http://你的服务器IP:8080
```

如果你想改成 80 端口，可以修改：

```yaml
ports:
  - "80:80"
```

然后重新部署。

## 十二、常见问题

### 1. GitHub Actions push 镜像失败

检查：

- `DOCKERHUB_USERNAME` 是否正确
- `DOCKERHUB_TOKEN` 是否正确
- Docker Hub token 是否还有效

### 2. 服务器部署时报 pull 镜像失败

检查：

- `APP_IMAGE` 是否正确
- 镜像是否已经成功 push 到 Docker Hub
- 如果是私有镜像，服务器是否先执行过 `docker login`

### 3. 页面打不开

检查：

- `docker ps`
- `docker logs person-low-code`
- 服务器是否放行 `8080`
- 云安全组是否放行 `8080`

### 4. 刷新前端路由 404

当前 `nginx.conf` 已经配置：

```nginx
try_files $uri $uri/ /index.html;
```

正常不会有这个问题。

## 十三、后面怎么升级

以后你只需要：

1. 改代码
2. `git commit`
3. `git push origin main`

剩下的流程会自动完成：

1. 构建镜像
2. push 到 Docker Hub
3. 服务器 pull 最新镜像
4. 更新容器

## 十四、当前默认值

当前默认配置是：

- 自动部署分支：`main`
- 容器名：`person-low-code`
- 访问端口：`8080`
- 镜像名格式：`DOCKERHUB_USERNAME/person-low-code:latest`

如果你后面想扩展成：

- 按分支部署不同环境
- 使用固定版本 tag
- 使用域名
- 配 HTTPS
- 多服务器部署

都可以在这套基础上继续加。
