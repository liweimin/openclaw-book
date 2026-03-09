# OpenClaw 维护手册（小白进阶版）

这份手册不是只告诉你“怎么更新”，而是帮你解决 4 个更实际的问题：

1. 我现在看到的 OpenClaw，到底是正式版、测试版，还是源码主线？
2. 今天早上更新后，究竟新增了哪些值得关心的能力？
3. 我在 WSL2 里日常维护时，优先该看哪些命令、哪些目录、哪些网页？
4. 如果后续我要写书、做教程、排错，应该怎么把“官网信息”“GitHub 信息”“源码实现”三者串起来？

---

## 1. 先说结论：你今天早上看到的“更新”是什么

基于 **2026-03-09（北京时间）** 的本地源码、官方文档和 GitHub 信息核验，当前可以明确得出下面几个结论：

| 结论 | 说明 |
| :--- | :--- |
| **最新正式发布版本仍是 `v2026.3.7`** | 本地官方源码仓库的最近 tag 是 `v2026.3.7`，对应 2026-03-08 发布流程提交 `42a1394c`。 |
| **主分支已经进入 `2026.3.8` 开发周期** | 源码 `package.json` 里的版本号已经是 `2026.3.8`，`CHANGELOG.md` 顶部也已经出现 `## 2026.3.8`。 |
| **你的源码快照比 `v2026.3.7` 多了 205 个提交** | 本地执行 `git rev-list --count v2026.3.7..HEAD` 的结果是 `205`。 |
| **这不是“你看错了”，而是 OpenClaw 本来就分“发布版”和“主线源码”两条节奏** | 发布版给日常使用，主线源码给持续开发、修复和功能前置。 |

换句话说：

- 如果你是通过 `openclaw update` 更新日常环境，你更接近 **stable/release**。
- 如果你在 `sources/official/openclaw/` 里看源码并 `git pull`，你看到的是 **main 主线**。
- 这两者经常不是同一天、同一个提交。

---

## 2. 不要再只分“正式版”和“源码版”，而要分 3 个渠道

官方文档现在已经把更新渠道写得很明确了：OpenClaw 有 **stable / beta / dev** 三条渠道。

| 渠道 | 你可以怎么理解 | 适合谁 |
| :--- | :--- | :--- |
| `stable` | 已发布、相对稳、默认日常使用 | 大多数用户 |
| `beta` | 测试中的候选构建 | 想抢先试但仍希望有一定稳定性的人 |
| `dev` | 直接跟着 `main` 主分支走 | 写书、研究源码、抢先体验、愿意自己排错的人 |

官方文档给出的切换方式是：

```bash
openclaw update --channel stable
openclaw update --channel beta
openclaw update --channel dev
```

这比“只会 `openclaw update`”更重要，因为它解释了一个常见误区：

> 你看到某个功能已经出现在源码和文档里，不代表它已经进入你当前正在使用的 stable 版本。

---

## 3. 本次更新里，普通用户最值得关注的功能

下面这些不是“代码整理”，而是你后续写书、维护或日常使用时真正会碰到的变化。

### 3.1 新增一等公民备份命令：`openclaw backup`

这次 `2026.3.8` 周期里，最实用的新增能力之一，就是官方把备份做成了正式 CLI：

```bash
openclaw backup create
openclaw backup create --verify
openclaw backup create --only-config
openclaw backup create --no-include-workspace
openclaw backup verify ./xxx-openclaw-backup.tar.gz
```

这意味着以后你在执行高风险动作前，不用再只靠手动复制目录了。  
它会按规则把下面这些东西打包进归档里：

- OpenClaw 状态目录（通常是 `~/.openclaw`）
- 当前激活的配置文件
- OAuth / 凭据目录
- 工作区目录（可选）

对小白来说，这个命令的意义非常大：

- 升级前先备份
- 大改配置前先备份
- 准备执行 `reset` / `uninstall` 前先备份
- 写书做实验前先留一份“可回滚状态”

一句话总结：**以后“维护”不只是更新，还包括可恢复。**

### 3.2 WSL2 + Windows 分离式浏览器控制，官方终于写清楚了

如果你的 OpenClaw 跑在 **WSL2**，但浏览器在 **Windows** 这边打开，这是一个非常典型、也非常容易踩坑的组合。

这次官方文档专门新增了分层排障指南，重点讲了两件事：

1. **Control UI 要优先用 Windows 本机回环地址打开**

   ```text
   http://127.0.0.1:18789/
   ```

   不要默认拿局域网 IP 去打开控制台，否则你以为是浏览器控制问题，实际上可能是 Control UI 的不安全来源校验、允许来源配置或认证问题。

2. **只有当你真的跨 WSL2/Windows 边界使用扩展 relay 时，才需要 `browser.relayBindHost`**

   例如：

   ```json5
   {
     browser: {
       enabled: true,
       defaultProfile: "chrome",
       relayBindHost: "0.0.0.0",
     },
   }
   ```

   默认 loopback 更安全；只有真的跨命名空间访问时，才考虑放开。

这部分对你尤其重要，因为你就是在 WSL2 环境里观察更新的人。

### 3.3 `openai-codex/gpt-5.4` 上下文窗口被修正到 1M 级别

你本地当前主线的最新提交就是：

```text
fix(models): use 1M context for openai-codex gpt-5.4
```

这说明 OpenClaw 最近刚修正了 `openai-codex/gpt-5.4` 的上下文能力认知，不再沿用旧的 Codex 限制，而是把它提升到约 **1,050,000 tokens 上下文窗口**，并配套更合理的最大输出 token 设置。

这类改动有两个实际影响：

- `models list/status` 看到的模型能力会更接近真实值
- 长上下文任务、源码分析、大文档处理时，OpenClaw 的调度和显示会更准确

### 3.4 TUI、版本号、Docker 和 Control UI 这批改动都很“维护友好”

`2026.3.8` 顶部变更里还有几项非常适合写进维护手册：

- **TUI 自动推断当前工作区对应的 agent**
  - 在 agent 工作区里启动 TUI 时，更不容易进错 agent。
- **`openclaw --version` 开始带短提交哈希**
  - 后续排障时，你不只知道“版本号”，还知道“接近哪个提交”。
- **新增/加强 Docker 构建缓存与运行镜像瘦身**
  - 更新容器环境时，拉取和构建体验更好。
- **Control UI 404 修复**
  - 解决全局安装、软链接包装器或打包根目录场景下，控制台静态资源找不到的问题。
- **配置写入后运行时快照刷新**
  - 改完配置后，后续读取更容易拿到最新状态，不容易出现“文件改了但运行时像没改”的错觉。

---

## 4. 小白维护时，最常用的一组命令

如果你不想一上来就钻源码，先记住下面这组命令就够用了。

### 4.1 看自己现在到底跑的是什么版本

```bash
openclaw --version
```

如果后面带有短提交哈希，说明你拿到的是更便于排障的新版本逻辑。

### 4.2 更新到不同渠道

```bash
openclaw update --channel stable
openclaw update --channel beta
openclaw update --channel dev
```

如果你只是日常使用，优先 `stable`。  
如果你要写书、追功能、看新能力，可以观察 `dev`，但不要把“研究环境”和“生产使用环境”混成一套。

### 4.3 检查运行状态

```bash
openclaw status
openclaw status --all
openclaw doctor
```

建议理解成：

- `status`：看“现在活得怎么样”
- `status --all`：看“所有通道、入口、会话都怎样”
- `doctor`：看“哪里坏了，能不能顺手修”

### 4.4 在高风险操作前做备份

```bash
openclaw backup create --verify
```

如果你只是要留存配置：

```bash
openclaw backup create --only-config
```

### 4.5 看源码主线到底改了什么

进入官方源码目录：

```bash
cd /mnt/d/00容器/openclaw/sources/official/openclaw
```

然后看下面几条：

```bash
git describe --tags --abbrev=0
git rev-list --count v2026.3.7..HEAD
git log -n 20 --oneline
git diff --stat v2026.3.7..HEAD
```

你可以把它们理解为：

- `describe --tags`：最近正式发布版本是谁
- `rev-list --count`：主线比发布版多走了多少步
- `log`：最近都在修什么
- `diff --stat`：这次到底动了多少文件、多少量级

---

## 5. WSL2 用户的维护重点

你现在的环境就是 **Windows + WSL2**，所以这一节特别关键。

### 5.1 官方态度已经很明确：Windows 请优先走 WSL2

官方 Windows 文档现在强调的是：

- OpenClaw 推荐运行在 WSL2 里的 Linux 环境
- 原生 Windows 路线不是主要推荐路径
- CLI + Gateway 放在 WSL2 里，可以获得更一致的 Node/Bun/pnpm/二进制工具行为

这也解释了为什么很多“OpenClaw 教程里的 Linux 命令”你在 WSL2 里最容易成功。

### 5.2 `systemd` 很重要，不开它会影响后台服务安装

如果你希望 Gateway 在 WSL2 里作为用户服务长期跑着，最好确认：

```bash
systemctl --user status
```

如果报错，优先检查 `/etc/wsl.conf` 里有没有：

```ini
[boot]
systemd=true
```

然后在 Windows PowerShell 里执行：

```powershell
wsl --shutdown
```

再重新进入 WSL。

### 5.3 Control UI、Gateway、Windows 浏览器是三层，不要混着排错

新手最容易犯的错误，是把下面 3 件事混成一件事：

1. Gateway 是否启动成功
2. Control UI 是否能被浏览器正确访问
3. 浏览器自动化/CDP/扩展 relay 是否打通

正确顺序应该是：

1. 先确认 `openclaw status` 正常
2. 再确认 Windows 浏览器能打开 `http://127.0.0.1:18789/`
3. 最后才去调远程 Chrome、CDP、relay、扩展

### 5.4 如果要给局域网设备访问 WSL 服务，记得这是 Windows 侧 portproxy 的问题

这一点官方 Windows 文档也写得很清楚：

- WSL2 有自己的虚拟网络
- 你要让别的机器访问 WSL 里的服务，通常得在 Windows 侧做 `portproxy`
- WSL 的 IP 重启后可能会变，所以转发规则可能要刷新

这不是 OpenClaw 独有问题，而是 WSL2 的网络模型决定的。

---

## 6. 如果你准备写书，源码目录该怎么读

你现在做的是“写书工程”，所以只知道“命令怎么跑”还不够，最好知道源码目录的角色分工。

结合当前官方源码仓库，可以先这样理解：

| 目录 | 作用 | 写书时最适合用来干什么 |
| :--- | :--- | :--- |
| `src/` | 核心 TypeScript 实现 | 写 CLI、Gateway、工具、会话、配置、浏览器控制的源码解析 |
| `docs/` | 官方文档原文 | 核事实、找术语、找官方推荐做法 |
| `apps/` | macOS / iOS / Android 配套应用 | 写跨端架构、节点能力、移动端集成 |
| `extensions/` | 各类渠道与插件扩展 | 写 Feishu、Telegram、Discord 等接入 |
| `skills/` | 官方技能与技能模板 | 写 Skills 生态和自动化能力 |
| `test/`、`*.test.ts` | 测试与回归用例 | 反向验证“这个功能到底保证到什么程度” |
| `CHANGELOG.md` | 面向版本的变化汇总 | 写“版本演进史”最方便 |
| `README.md` | 面向全局的能力说明 | 写“全景总览”和路线图最方便 |

如果你后面要把这份手册并进书里，最有价值的升级方式不是“复制更多命令”，而是把每个命令都落到对应源码目录上。

例如：

- `openclaw backup` 对应 `src/commands/backup.ts`
- CLI 总命令注册对应 `src/cli/program/command-registry.ts`
- 浏览器跨 WSL2/Windows 排障对应 `docs/tools/browser-wsl2-windows-remote-cdp-troubleshooting.md`
- Windows 官方说明对应 `docs/zh-CN/platforms/windows.md`

---

## 7. 一套适合你现在的日常维护流程

下面这套流程适合“你平时在 WSL2 用 OpenClaw，同时又在写书和跟踪更新”这种状态。

### 7.1 日常使用环境

1. 先看版本：

   ```bash
   openclaw --version
   ```

2. 更新 stable：

   ```bash
   openclaw update --channel stable
   ```

3. 看状态：

   ```bash
   openclaw status --all
   ```

4. 感觉不对时跑：

   ```bash
   openclaw doctor
   ```

### 7.2 研究/写书环境

1. 进入源码目录：

   ```bash
   cd /mnt/d/00容器/openclaw/sources/official/openclaw
   ```

2. 更新主线：

   ```bash
   git pull
   ```

3. 看最近发布版与主线差距：

   ```bash
   git describe --tags --abbrev=0
   git rev-list --count v2026.3.7..HEAD
   git log -n 20 --oneline
   ```

4. 需要记录“本次更新值不值得写进书里”时，优先筛下面几类提交：

   - `feat:`
   - `fix:` 但会影响用户体感
   - `docs:` 且对应官方新增操作指南
   - `build:` / `Docker:` 且影响安装维护体验

### 7.3 做高风险操作前

```bash
openclaw backup create --verify
```

这是以后最应该养成的习惯。

---

## 8. 本次更新（2026-03-09）值得写进书里的重点摘要

如果你想把今天这次观察压缩成适合书稿或章节更新说明的版本，可以直接用下面这段逻辑：

### 8.1 当前版本状态

- 截至 **2026-03-09**，本地官方源码仓库最近正式发布 tag 仍为 **`v2026.3.7`**。
- 但主分支源码已经进入 **`2026.3.8`** 周期，且本地 HEAD 比 `v2026.3.7` **领先 205 个提交**。

### 8.2 这批变化里最有维护价值的点

- OpenClaw 新增了正式的 **备份命令** `openclaw backup create/verify`
- 官方补上了 **WSL2 + Windows + 远程 Chrome/CDP** 的分层排障文档
- `openai-codex/gpt-5.4` 的上下文窗口修正到了 **1M 级别**
- `openclaw --version` 开始包含 **短提交哈希**
- Control UI、Docker、配置刷新、插件加载这些“日常维护容易踩坑”的地方都在持续修补

### 8.3 对普通用户的建议

- 日常使用优先 `stable`
- 研究和写书可以跟 `dev/main`
- 不要把“源码里有”误判成“正式版已经有”
- 每次大改前先做 `openclaw backup create --verify`

---

## 9. 本文核验依据（方便你后续写进书里）

### 9.1 本地源码核验

- `sources/official/openclaw/package.json`
  - 当前源码版本号：`2026.3.8`
- `sources/official/openclaw/CHANGELOG.md`
  - 顶部已有 `2026.3.8` 条目
- `git describe --tags --abbrev=0`
  - 最近 tag：`v2026.3.7`
- `git rev-list --count v2026.3.7..HEAD`
  - 本地结果：`205`
- `git log -n 15 --oneline`
  - 最近提交包含：
    - `fix(models): use 1M context for openai-codex gpt-5.4`
    - `Docker: improve build cache reuse`
    - `gateway: fix global Control UI 404s for symlinked wrappers and bundled package roots`
    - `fix(config): refresh runtime snapshot from disk after write`

### 9.2 官方文档

- 开发渠道：
  - https://docs.openclaw.ai/install/development-channels
- Windows（WSL2）：
  - https://docs.openclaw.ai/platforms/windows
- 备份命令：
  - https://docs.openclaw.ai/cli/backup
- WSL2 + Windows + remote Chrome CDP 排障：
  - https://docs.openclaw.ai/tools/browser-wsl2-windows-remote-cdp-troubleshooting

### 9.3 GitHub 页面

- Releases：
  - https://github.com/openclaw/openclaw/releases
- 主分支提交：
  - https://github.com/openclaw/openclaw/commits/main
- `v2026.3.7` 发布页：
  - https://github.com/openclaw/openclaw/releases/tag/v2026.3.7

---

## 10. 最后给小白的一句话

如果你只是想把 OpenClaw **用稳定**，重点看：

- `openclaw update --channel stable`
- `openclaw status --all`
- `openclaw doctor`
- `openclaw backup create --verify`

如果你想把 OpenClaw **学明白、写成书、持续追更新**，重点再加上：

- `git pull`
- `git log`
- `CHANGELOG.md`
- 官方 docs
- GitHub Releases / Commits

维护 OpenClaw 的核心，不是“记住很多命令”，而是学会区分：

- **正式发布了什么**
- **主线又提前做了什么**
- **哪些改动已经会影响你手里的环境**

