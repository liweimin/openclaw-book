# 第三章：配置、命令与日常维护

## 1. 本章解决什么问题

如果第二章解决的是“怎么先跑起来”，这一章解决的就是：

- 配置文件在哪里
- 配置应该怎么改
- 最常用命令有哪些
- 正式版平时怎么更新，去哪里看这次更新了什么
- Windows + WSL2 用户每天到底该怎么用
- 出问题时先看什么
- 日常使用怎样逐步从“能用”变成“稳定”

前一章讲的是安装成功，这一章讲的是“以后每天怎么和它相处”。

### 1.1 本章实操场景

这一章你应该完成的，不是背概念，而是把 OpenClaw 调成一个以后每天都能继续用的稳定工作台。

更具体地说，这一章的实操产物应该是：

1. 找到 `~/.openclaw/openclaw.json`
2. 建好一个固定工作区习惯
3. 看懂自己现在到底要不要改 `tools.profile`
4. 知道正式版平时该怎么更新
5. 知道去哪里看 release 和 changelog
6. 改完后验证系统没有被你改坏

### 1.2 本章产物

读完这一章，你至少应该留下两类结果：

- 一份你能长期复用的工作区习惯
- 一份 `ch03-stable/WORKSPACE-GUIDE.md`

### 1.3 开始前先准备什么

这一章默认你已经完成第二章，至少满足：

- `openclaw dashboard` 能打开
- 你已经能在正确环境里运行 `openclaw`
- 如果你是 Windows 用户，你已经知道自己主要在 Ubuntu 里操作

## 2. 先建立一个最重要的认知：如果你走的是 WSL2，OpenClaw 现在住在 Linux 里

这一点对 Windows 用户尤其关键。

如果你按官方推荐路线使用 WSL2，那么：

- OpenClaw 的 CLI 在 Ubuntu 里
- OpenClaw 的配置在 Ubuntu 里
- OpenClaw 的工作区在 Ubuntu 里
- OpenClaw 的 Gateway 服务也是跑在 Ubuntu 里

所以你以后最常用的终端，不再只是 PowerShell，而是 Ubuntu 终端。

很多新手会在这里混乱，典型表现是：

- 在 Ubuntu 里装了 OpenClaw
- 然后回到 PowerShell 里敲 `openclaw`
- 发现命令不存在
- 以为自己装坏了

其实没坏。只是你把“装在哪里”和“在哪里运行”混成一件事了。

对你来说，最实用的理解是：

- 如果 OpenClaw 装在 WSL2 里，就优先在 Ubuntu 里运行它
- 如果你非要从 PowerShell 调它，也应该走 `wsl <command>` 这种方式

例如：

```powershell
wsl openclaw status
wsl openclaw gateway status
```

但对小白来说，最简单还是直接打开 Ubuntu。

## 3. OpenClaw 的配置文件到底在哪里

默认配置文件位置是：

```text
~/.openclaw/openclaw.json
```

这里的 `~` 指的是当前运行环境里的“用户家目录”。

### 在 macOS / Linux 上

通常就是你当前系统用户的 home 目录。

### 在 Windows + WSL2 上

这里指的是 Ubuntu 里的 home 目录，而不是 `C:\Users\你的用户名\`。

举个例子，如果你在 WSL2 里的 Linux 用户名叫 `levi`，那么配置文件大致会在：

```text
/home/levi/.openclaw/openclaw.json
```

这就是为什么我前面一直强调：WSL2 路线下，OpenClaw 的“家”在 Linux 里面。

## 4. 如果你是 WSL2 用户，怎么找到这些文件

这也是很多小白的高频问题。

### 方式一：直接在 Ubuntu 里进入目录

```bash
cd ~/.openclaw
ls
```

### 方式二：从 Ubuntu 里打开 Windows 资源管理器

如果你的 WSL 和 Windows 互操作正常，可以在 Ubuntu 里执行：

```bash
explorer.exe .
```

或者：

```bash
powershell.exe /c start .
```

如果你已经在 `~/.openclaw` 或工作区里执行这些命令，Windows 资源管理器通常会直接打开对应位置。

但这不是百分之百必然成功。如果你看到类似：

```text
-bash: /mnt/c/WINDOWS/explorer.exe: cannot execute binary file: Exec format error
```

通常说明 WSL 的 Windows 互操作没有正常工作。这时不要纠结这条命令本身，先直接用下面的 `\\wsl$` 方式访问，再检查：

- `echo $PATH` 里有没有 Windows 路径
- `/etc/wsl.conf` 里是否把 `[interop] enabled` 关掉了
- `/etc/wsl.conf` 里是否设置了 `appendWindowsPath=false`

### 方式三：在 Windows 里访问 `\\wsl$`

WSL2 的 Linux 文件系统可以从 Windows 里通过网络路径访问，例如：

```text
\\wsl$\Ubuntu-24.04\home\你的Linux用户名\
```

如果你的发行版名字不是 `Ubuntu-24.04`，就替换成你自己的实际名称。

### 一个很重要的实践建议

微软官方关于 WSL 文件系统的建议是：如果你主要在 Linux 工具链里工作，就把项目文件放在 Linux 文件系统里，性能更好。

对 OpenClaw 来说，这意味着：

- 推荐主要工作目录放在 `/home/...`
- 不推荐一开始就把主工作区放在 `/mnt/c/...`

如果你第一次看到 `/mnt/c/...` 这个写法，可以这样理解：

- 你现在人在 Ubuntu 里
- 但你去访问的是 Windows 的 `C:` 盘
- 所以 WSL2 会把 Windows 的 `C:` 盘映射成 Linux 路径 `/mnt/c`

例如：

```text
Windows 的 C:\Users\你的名字\Documents
≈
WSL2 里的 /mnt/c/Users/你的名字/Documents
```

所以 `/mnt/c/...` 的本质不是“OpenClaw 的目录”，而是“Ubuntu 里看到的 Windows C 盘路径”。

这里真正想让你记住的，不是某一个具体目录名，而是这个原则：

- 主练习工作区，优先用 `~/.openclaw/workspace`
- 如果你以后还要单独放源码、脚本或笔记，再另外在 `/home/...` 下建普通项目目录
- 不要一开始就把主要内容都堆到 `/mnt/c/...`

也就是说，对照本书主线时：

- 后面大多数练习会直接写进 `~/.openclaw/workspace`
- `~/projects` 这一类目录更适合放你额外克隆的源码、独立项目或学习笔记

## 5. `~/.openclaw/` 目录里到底有什么

学 OpenClaw 时，最好尽早熟悉这个目录。它不是神秘黑盒，而是整个系统的状态仓库。

通常你会在这里看到以下几类内容。

### `openclaw.json`

总配置文件。

### `workspace/`

默认工作区。Agent 的很多任务会围绕这里运转。

### `credentials/`

这里我要纠正一个非常重要的误解：`credentials/` 不是你第一次安装完就一定会看到的目录。

更准确的说法是：

- 某些渠道凭证、配对请求、allowlist 等状态，确实可能保存在 `~/.openclaw/credentials/` 下
- 但这个目录往往是在你真的开始使用相关功能后，才会出现
- 如果你现在没有看到它，这通常是正常现象，不代表安装有问题

例如，官方文档里明确提到过这些典型情况：

- 旧版 OAuth 导入可能在 `~/.openclaw/credentials/oauth.json`
- 某些渠道状态会在 `~/.openclaw/credentials/<channel>/...`
- 配对和允许列表也可能在 `credentials/` 下产生文件

但与此同时，另外一部分你以为会放在 `credentials/` 里的内容，其实已经放在别处了。最典型的就是模型认证配置文件，官方文档当前大量写的是：

```text
~/.openclaw/agents/<agentId>/agent/auth-profiles.json
```

所以你现在最应该这样理解：

- `credentials/` 可能会出现，但不是默认必有
- 没看到它，不代表错
- 真正要判断状态位置时，要结合你已经启用了哪些功能来看

### `agents/`

这个目录比很多新手以为的重要得多。

你以后很可能会在这里看到：

- Agent 自己的配置
- 会话数据
- 模型认证配置文件

所以如果你找不到某些“凭证类”内容，不要只盯着 `credentials/`，也要记得来 `agents/` 下面看。

### `devices/`

和节点设备配对相关的状态会在这里。

### `memory/`

如果你开始用 Memory 和记忆搜索，相关索引和状态也会逐步出现在 `.openclaw` 或工作区里。

你不一定要一开始就读懂所有内容，但你至少要知道：OpenClaw 的“生活痕迹”主要都在这里。

## 6. `openclaw.json` 为什么是 JSON5，而不是普通 JSON

配置文件格式是 JSON5。

这意味着你可以写：

- 注释
- 尾逗号

它比纯 JSON 更适合人工维护，但这并不代表你可以随便写。OpenClaw 对配置是严格校验的，所以：

- 键名写错
- 类型写错
- 值不合法
- 层级写错

都可能让 Gateway 拒绝启动。

这对新手其实是好事。因为它宁可在配置阶段报错，也不愿意让你带着一份错误配置继续运行。

## 7. 配置思路：先小后大，不要一上来把全系统打开

第一次配置，优先保证以下四件事：

1. 工作区位置明确
2. 模型认证可用
3. Gateway 正常
4. 至少一个入口可用

不要一上来就同时追求：

- 多 Agent
- 多模型回退
- 多渠道路由
- 很复杂的安全策略
- 高风险工具全开

这一点在 Windows + WSL2 环境里尤其重要，因为你还同时在熟悉 Linux 环境本身。

## 8. 当你需要手动改配置时，一个适合小白的最小改法

这一节不是让你“安装完以后再重配一遍”，也不是要求你把向导生成的配置推倒重来。

它真正服务的是下面这两种情况：

1. 你已经通过 `openclaw onboard` 或 `openclaw configure` 跑通了，但接下来想手动改一点点配置
2. 你把配置改乱了，想退回一个最容易理解、最容易排错的最小状态

如果你现在已经安装成功、Dashboard 正常、日常也能用，那么这一节可以先跳过。等你第一次准备手动改 `openclaw.json` 时，再回来看。

所谓“最小改法”，意思不是“重新配置整个系统”，而是：

- 一次只碰一小块
- 从最容易理解的字段开始
- 改完立刻验证

```json5
{
  agents: {
    defaults: {
      workspace: "~/.openclaw/workspace",
    },
  },
}
```

这个配置表达的意思非常简单：

- 默认 Agent 使用 `~/.openclaw/workspace` 作为工作目录

如果你已经有一份向导生成的配置，那这里真正想表达的是：

不要第一次手动编辑时就同时去改模型、端口、渠道、工具权限、路由等很多块。先从这种单一、容易理解的字段开始改。

### 8.1 第一次改配置，请直接照着做

如果你是第一次手动改 `openclaw.json`，不要一上来就改很多项。最稳妥的方式是：先备份，再只改一小块，然后立刻验证。

在 Ubuntu 里执行：

```bash
cp ~/.openclaw/openclaw.json ~/.openclaw/openclaw.json.bak
nano ~/.openclaw/openclaw.json
```

打开后，把你准备修改的内容控制在最小范围内。比如你只是想先确认默认工作区，就让配置尽量接近这一版：

```json5
{
  agents: {
    defaults: {
      workspace: "~/.openclaw/workspace",
    },
  },
}
```

如果你不会退出 `nano`，先记住这三步：

- `Ctrl + O` 保存
- 回车确认文件名
- `Ctrl + X` 退出

保存后不要立刻去做别的事，先执行第 15 节里的“改配置后的标准动作”。

## 9. 配置里最重要的几大块

### 9.1 `agents`

这部分决定：

- 默认 Agent 的工作区
- 会不会有多个 Agent
- 各 Agent 的行为差异

### 9.2 `gateway`

这部分决定：

- 网关怎么启动
- 端口和绑定方式
- 认证和访问控制

### 9.3 `channels`

这部分决定：

- 哪些消息渠道被接入
- 不同渠道的凭证、策略、群组规则

### 9.4 `tools`

这部分决定：

- OpenClaw 能调哪些工具
- 哪些工具要限制
- 不同场景下是否沙箱隔离

### 9.5 `session` / `routing`

这部分决定：

- 会话怎么组织
- 不同消息流如何映射到不同 Agent 或不同上下文

你不需要第一天就精通这些块，但至少要知道自己改的是哪一层。

## 10. Tools 到底要不要改，新手应该怎么配

这一节我要先把结论说在最前面：

如果你刚安装好，而且现在已经能正常聊天、正常打开 Dashboard、正常完成最小任务，那么你第一阶段通常**不需要主动改工具配置**。

也就是说，对新手来说，最推荐的顺序不是“先研究 Tool Access”，而是：

1. 先用向导生成的默认配置跑通
2. 先知道自己主要拿 OpenClaw 做什么
3. 只有当你发现“它能力太多”或“它能力不够”时，再来手动改工具配置

### 10.1 这里的配置键名一定是英文

这一点非常重要。`openclaw.json` 里的真实配置字段是英文，不可能写中文。

官方当前对应的核心字段主要是：

- `tools.profile`
- `tools.allow`
- `tools.deny`

其中：

- `tools.profile` 是基础工具档位
- `tools.allow` 是额外允许哪些工具
- `tools.deny` 是明确拒绝哪些工具

### 10.2 官方当前的基础档位是什么

官方文档当前写得很明确，`tools.profile` 主要有四种值：

- `minimal`
- `messaging`
- `coding`
- `full`

它们不是中文“消息型 / 编码型 / 全开型”的真实写法。真正写进配置文件时，你要写的是上面这些英文值。

你可以这样理解：

- `minimal`：最小能力，几乎只保留会话状态
- `messaging`：更适合消息入口型使用
- `coding`：更适合文件、命令、代码、记忆这类本地工作
- `full`：基本不限制，不建议新手一开始就用

### 10.3 新手默认建议：先不要手动改，保持向导默认

如果你现在还在系统学习阶段，我给你的默认建议非常直接：

- 已经能正常用，就先保持当前配置
- 不要为了“看起来更专业”去提前改 `tools.profile`
- 更不要第一天就上 `full`

你可以把是否需要改工具配置，简化成下面这个判断：

如果你主要只是：

- 在 Dashboard 聊天
- 接一个消息渠道
- 做轻量问答和简单辅助

那就先保持默认，不要急着改。

如果你开始明显想让它：

- 读文件
- 改文档
- 跑命令
- 帮你处理代码

那你再考虑进入 `coding` 方向。

### 10.4 真要改时，新手最推荐的三种写法

#### 写法一：继续保持当前默认

这是最推荐的新手路线。

你什么都不用改，继续用当前向导生成的配置。

#### 写法二：如果你主要把它当消息助手，用 `messaging`

适合：

- 飞书、Telegram、WhatsApp 这类入口优先
- 你不希望它一上来就有很强的本地执行能力

可抄的配置是：

```json5
{
  tools: {
    profile: "messaging",
  },
}
```

#### 写法三：如果你主要想让它处理本地文件、命令、代码，用 `coding`

适合：

- 你已经在本地稳定使用
- 你明确知道自己需要文件和运行时能力

可抄的配置是：

```json5
{
  tools: {
    profile: "coding",
  },
}
```

#### 不建议新手一开始就用 `full`

```json5
{
  tools: {
    profile: "full",
  },
}
```

这不是“高手必选项”，而是“限制最少的选项”。在你还没完全理解工具边界之前，不建议这样配。

### 10.5 你如果现在要跟着改，具体怎么操作

如果你决定手动改工具配置，直接按下面这组步骤走：

第一步，先备份配置：

```bash
cp ~/.openclaw/openclaw.json ~/.openclaw/openclaw.json.bak
```

第二步，打开配置文件：

```bash
nano ~/.openclaw/openclaw.json
```

第三步，只改 `tools` 这一小块。

如果文件里原来没有 `tools`，就加一小段，例如：

```json5
{
  tools: {
    profile: "coding",
  },
}
```

如果原来已经有 `tools`，那就只改里面的 `profile`，不要顺手把别的全改了。

第四步，保存退出。

第五步，立刻验证：

```bash
openclaw doctor
openclaw status
```

第六步，如果这次改动已经影响到 Gateway 的实际行为，再补一步：

```bash
openclaw gateway restart
```

### 10.6 这一节真正想让你做什么

这一节不是让你“学一个概念”，而是让你知道下面这条最实用的决策规则：

- 新手默认先保持向导配置
- 只有当你明确知道自己偏消息型还是偏本地执行型时，才去改 `tools.profile`
- 真要改，就只改一行英文配置，然后立刻验证

### 10.7 一个真正有用的练习：把工作台调成你以后愿意天天打开的样子

这一步不是为了“试功能”，而是为了给后面所有章节打基础。

你现在就做一个有实际价值的任务：让 OpenClaw 帮你写一份自己的工作台说明书，以后每天开始前看它一眼，你就知道资料该放哪、今天应该从哪开始。

第一步，先准备一个目录：

```bash
mkdir -p ~/.openclaw/workspace/ch03-stable
```

第二步，决定你这段时间到底属于哪种使用方式：

- 如果你现在主要是飞书私聊、轻量问答，就先保持向导默认，不主动改 `tools.profile`
- 如果你已经明确要让它读文件、改文档、看项目目录，那就按前一节的方法把 `tools.profile` 调成 `coding`

第三步，打开 Dashboard，直接发下面这段话：

```text
请基于我当前的 OpenClaw 工作区，帮我写一份工作台说明书，并保存为 ch03-stable/WORKSPACE-GUIDE.md。

要求：
1. 用中文。
2. 说明哪些目录适合放练习文档、Skills、Memory、源码和输出结果。
3. 给我一个“每天开始使用 OpenClaw 前的 3 步动作”。
4. 如果我的工作区结构还不合理，也请直接给出调整建议。
5. 最后告诉我文件保存到了哪里。
```

第四步，回到终端确认文件已经生成：

```bash
ls ~/.openclaw/workspace/ch03-stable
```

如果你现在能看到 `WORKSPACE-GUIDE.md`，那这一章就已经从“配置教学”变成了“给自己搭好长期工作台”。

## 11. 你最该先掌握的命令族

官方 CLI 文档已经把 OpenClaw 的命令体系列得很完整。对小白来说，第一阶段真正需要掌握的是下面这几组。

### 初始化与配置

```bash
openclaw onboard --install-daemon
openclaw configure
openclaw config get <path>
openclaw config set <path> <value>
openclaw config unset <path>
```

如果你现在只想先掌握最实用的一组，可以先只记住这三件事：

1. `openclaw onboard --install-daemon` 用来初始化
2. 手动编辑 `~/.openclaw/openclaw.json` 用来做小范围调整
3. 每次改完都要跑 `openclaw doctor` 和 `openclaw status`

### 状态与健康

```bash
openclaw status
openclaw status --all
openclaw health
openclaw gateway status
```

### 浏览器入口

```bash
openclaw dashboard
```

### 直接让 Agent 干活

```bash
openclaw agent --message "帮我整理今天待办"
```

### 渠道相关

```bash
openclaw channels list
openclaw channels status
openclaw channels add
openclaw channels login
```

### 配对与审批

```bash
openclaw pairing list whatsapp
openclaw pairing approve whatsapp <code>
```

### 日志与诊断

```bash
openclaw doctor
openclaw logs
```

如果你现在只学会这几组，已经足够进入稳定使用阶段。

## 12. Dashboard、CLI 和浏览器之间到底是什么关系

OpenClaw 的命令表看起来很多，是因为它有多种入口，但这些入口不是彼此独立的三套系统。

### Dashboard

适合：

- 第一次跑通
- 看整体状态
- 在浏览器里做直观操作

### CLI

适合：

- 配置
- 诊断
- 启停服务
- 自动化和脚本化操作

### Agent / Message 命令

适合：

- 在终端里直接发起任务
- 快速做一次小型操作

它们本质上都围绕同一个 Gateway 工作。

## 13. Windows + WSL2 用户最关心的问题：Ubuntu 里跑的 Gateway，Windows 浏览器能打开 Dashboard 吗

可以，而且这恰恰是 WSL2 非常方便的一点。

微软官方关于 WSL 网络的说明里明确提到：当 Linux 发行版里运行的是 localhost 网络应用时，Windows 主机通常可以直接通过 `localhost` 访问它。

对 OpenClaw 来说，这意味着：

- 你在 Ubuntu 里启动 Gateway
- 然后通常可以直接在 Windows 浏览器里打开 `http://127.0.0.1:18789/`

这也是为什么官方文档把 Dashboard 的本地默认地址写成：

```text
http://127.0.0.1:18789/
```

### 最稳的打开方式

在 Ubuntu 里执行：

```bash
openclaw dashboard
```

如果浏览器没有自动打开，就自己在 Windows 浏览器里手动输入：

```text
http://127.0.0.1:18789/
```

### 如果你看到 `unauthorized`

官方 Dashboard 文档给出的建议是：

再次运行：

```bash
openclaw dashboard
```

然后使用它打印出来的带 token 链接。

## 14. Windows + WSL2 用户的日常最小工作流

这是我最建议你养成的使用节奏。

### 开工前

先打开 Ubuntu 终端，然后执行：

```bash
openclaw gateway status
openclaw status
```

如果这两条都没有明显报错，你再继续打开 Dashboard 或开始发消息。

### 如果 Gateway 没起来

你可以先试：

```bash
openclaw gateway start
```

如果你想直接看前台日志，就用：

```bash
openclaw gateway --port 18789 --verbose
```

你可以这样记：

- 想正常开工，用 `openclaw gateway start`
- 想现场看错误，用 `openclaw gateway --port 18789 --verbose`

### 打开 Dashboard

```bash
openclaw dashboard
```

或者直接在 Windows 浏览器里访问：

```text
http://127.0.0.1:18789/
```

如果页面打不开，不要立刻怀疑浏览器，先回头检查上一节的 Gateway 状态。

### 改完配置后

先执行：

```bash
openclaw doctor
openclaw status
```

如果仍有问题，再看：

```bash
openclaw logs
```

如果你安装的是后台服务，而且这次改动会影响 Gateway 行为，例如端口、认证、渠道或路由，那就再补一步：

```bash
openclaw gateway restart
```

如果你本来就是前台运行 Gateway，那就结束当前进程，然后重新启动它。

### 收工前

如果你是安装成后台服务的，通常不需要每次手动关掉。你更需要做的是：

- 知道状态是否正常
- 知道日志有没有异常
- 知道今天有没有改动重要配置

## 15. 改配置后的标准动作

每次你手动改过配置，都建议执行以下动作：

```bash
openclaw doctor
openclaw status
```

如果是前台运行 Gateway，再看终端输出；如果是后台服务，再看：

```bash
openclaw logs
```

如果这次改动明确影响到 Gateway 行为，例如端口、认证、渠道、路由或工具权限，那就再补一步：

```bash
openclaw gateway restart
```

你可以把这整套动作记成固定模板：

1. 改配置
2. `openclaw doctor`
3. `openclaw status`
4. 需要时 `openclaw gateway restart`
5. 仍有问题就看 `openclaw logs`

这是最能避免“我改了一堆东西，但不知道哪一步出了问题”的做法。

## 16. 日常维护的最小工作流

如果你已经进入“每天都在用”的阶段，建议形成以下习惯。

### 启动或开工前

先看状态：

```bash
openclaw gateway status
openclaw status
```

### 有问题时

按这个顺序排：

1. `gateway status`
2. `status`
3. `health`
4. `doctor`
5. `logs`

### 升级后

先做健康检查，不要直接开始干活：

```bash
openclaw doctor
openclaw status
openclaw health
```

## 17. WSL2 用户最常见的五个坑

### 坑一：在 Ubuntu 里装了 OpenClaw，却在 PowerShell 里找命令

这是最常见的问题之一。

处理方式：

- 直接回 Ubuntu 里运行
- 或者用 `wsl openclaw ...`

不要把“Ubuntu 里已安装”和“PowerShell 里也能直接调用”默认看成同一件事。

### 坑二：Windows 装了 Node，但 WSL2 里的 Ubuntu 没装 Node

这也是典型误区。

Windows 里的 Node 和 Ubuntu 里的 Node 是两套环境。你在 WSL2 里运行 OpenClaw，检查的是 Ubuntu 里的：

```bash
node --version
npm --version
```

### 坑三：工作文件放在 `/mnt/c/...`，然后觉得慢、怪、路径混乱

这一条真正想表达的不是“一个抽象建议”，而是：

如果你现在已经把 OpenClaw 相关工作放在 `/mnt/c/...` 下面，而且已经开始觉得路径乱、速度怪、权限不顺，那你下一步不要继续纠结，直接把**后续新的 OpenClaw 工作**切到 `/home/...` 下面。

最小动作如下：

```bash
cd ~
pwd
```

如果你看到的是 `/home/你的Linux用户名` 开头，那就说明你已经回到了正确的 Linux 家目录。

那你接下来就这样做：

1. 后面这本书里的主练习，优先继续用 `~/.openclaw/workspace`
2. 不要再把新的主工作内容继续建在 `/mnt/c/...`
3. 如果你要单独放源码或笔记，再在 `/home/...` 下另外建普通目录

这才是这一条坑位真正想让读者执行的动作。

### 坑四：没启用 systemd，就去装 Gateway 服务

如果你走的是 WSL2 路线，又准备长期使用后台服务，那就应该先按第二章的方法启用 systemd。

### 坑五：看见 Windows 浏览器打不开 Dashboard，就以为 WSL2 不通

先别急着下结论。按这个顺序查：

1. Ubuntu 里 `openclaw gateway status` 是否正常
2. `openclaw dashboard` 是否打印了带 token 的链接
3. 直接访问 `http://127.0.0.1:18789/` 是否可达
4. 是否其实是认证问题而不是网络问题

## 18. 备份、更新与迁移，应该先记住什么

这一节我会把一个很容易混乱的问题讲清楚：

很多新手会把“更新正式版”“看这次更新了什么”“看源码主线又提前做了什么”混成一件事。

对日常使用来说，你最该先掌握的是 **正式版怎么安全更新**，而不是一上来就追 `main` 分支。

### 18.1 先建立一个判断：你平时默认跟的是正式版 `stable`

如果你没有刻意切换到 `beta` 或 `dev`，也没有长期在官方源码目录里自己 `git pull`，那你日常使用的主线就应该理解成：

- **正式版 / stable**
- 对应 npm 的 `latest`
- 重点看 release 和 changelog

这也是本书这一章的默认维护路线。

也就是说，普通读者平时最应该关心的是：

1. 怎么把 stable 安全更新上去
2. 更新之后先做什么检查
3. 去哪里看这次正式发布到底改了什么

而不是第一时间去盯 GitHub commits 页面。

### 18.2 更新前，先知道哪些东西最值得备份

至少知道下面这些位置：

- `~/.openclaw/openclaw.json`
- `~/.openclaw/workspace/`
- `~/.openclaw/credentials/`

如果你走的是 WSL2，请记住：这里的 `~` 是 Ubuntu 里的 home 目录。

这里我要补一句非常重要的话：

截至 **2026-03-09**，OpenClaw 官方源码和文档里已经出现了更正式的 `openclaw backup` 方案，但你当前日常 stable 是否已经带上这条命令，要以你手里的正式版版本为准。对小白来说，现在最稳的做法仍然是先知道上面这 3 类目录在哪里。

### 18.3 对大多数人来说，正式版平时怎么更新最合适

如果你现在的主要目标是“稳定使用”，那本书建议你优先把更新理解成：

- **跟 stable**
- **一次只做一次正常升级**
- **升级后先检查，不要立刻上强任务**

对大多数用户，最常用的正式版更新命令可以先记这一条：

```bash
openclaw update --channel stable
```

你也可以直接：

```bash
openclaw update
```

但如果你想明确表达“我就是要留在正式发布渠道”，那 `--channel stable` 更直观。

官方更新文档还推荐过一种更通用的做法：重新运行网站安装器进行原地升级。对已经熟悉安装流程的人，这也完全成立；但对本书主线读者来说，第三章更适合先记住 `openclaw update --channel stable` 这条日常命令。

### 18.4 更新正式版之前，建议照着做的顺序

如果你准备做一次正常升级，建议直接养成这个顺序：

1. 先确认当前状态正常：

```bash
openclaw gateway status
openclaw status
```

2. 再更新正式版：

```bash
openclaw update --channel stable
```

3. 更新后立刻做检查：

```bash
openclaw doctor
openclaw status
openclaw health
```

4. 如果你装的是后台 Gateway 服务，再补一步：

```bash
openclaw gateway restart
```

你可以把它记成一个固定模板：

- 更新前先看状态
- 更新后先跑 doctor / status / health
- 需要时再 restart

这比“更新完直接继续干活”稳得多。

### 18.5 去哪里看“这次正式版更新了什么”

这才是很多人真正想问的问题。

对 **正式版** 来说，优先级应该是下面这个顺序：

#### 第一看：`CHANGELOG.md`

如果你手边有官方源码参考目录，最直接的位置就是：

```text
sources/official/openclaw/CHANGELOG.md
```

这里适合做的事情是：

- 看最新 release 章节标题，例如 `2026.3.7`
- 看 `Changes`、`Fixes`、`Breaking` 三块
- 快速判断这次更新和你有没有关系

#### 第二看：GitHub Releases

正式版最适合看的网页是：

- https://github.com/openclaw/openclaw/releases

这里比 commits 页面更适合普通用户，因为它展示的是“已经整理过的版本变化”，而不是零碎提交流。

#### 第三看：本地版本号

先执行：

```bash
openclaw --version
```

你至少先知道自己现在在哪个版本上，再去看对应 release，才不会出现“我明明没更新到那个版本，却在研究那个版本的功能”的错位。

### 18.6 怎么判断某个新功能是不是已经进正式版了

这是小白非常容易踩的坑。

正确判断顺序是：

1. 先看 `openclaw --version`
2. 再看 `CHANGELOG.md` 或 Releases 里的对应版本
3. 最后才去看源码或 commits

因为 OpenClaw 的官方文档和主线源码，很多时候会比你手里的 stable 稍微走在前面。

举一个你这次就已经遇到的真实情况：

- 截至 **2026-03-09**，本地官方源码仓库最近的正式发布 tag 仍是 **`v2026.3.7`**
- 但主分支源码已经进入 **`2026.3.8`** 周期
- 也就是说，你在源码和文档里看到的新内容，不一定已经全部进入你手里的正式版

所以日常维护时，最重要的不是“看到新功能就兴奋”，而是先分清：

- 这是 **正式版已发布** 的内容
- 还是 **源码主线已出现但尚未正式发版** 的内容

### 18.7 如果你只想稳定使用，不要先拿 commits 页面当主入口

GitHub commits 页面当然有价值，但它更适合：

- 写书
- 跟踪源码
- 研究功能还没发版之前的变化
- 判断某个 bug 是否刚被修

对普通用户日常维护来说，它不是第一入口。

如果你只是想知道“这次正式升级以后我应该关心什么”，优先看：

1. `openclaw --version`
2. `CHANGELOG.md`
3. GitHub Releases

源码提交记录最多只需要作为补充。

### 18.8 什么时候才需要顺手提一下源码主线

如果你正在做下面这些事，就可以稍微看一眼源码主线：

- 写书
- 做教程
- 提前关注下一个版本可能会带来什么
- 想确认某个问题是不是刚在 `main` 里被修

这时再进入官方源码目录看：

```bash
git describe --tags --abbrev=0
git log -n 10 --oneline
```

但请记住，这一层在第三章只是补充说明，不是普通用户的主维护路线。

### 18.9 迁移到新机器时

只要你已经理解了 `.openclaw/` 和工作区的关系，迁移就不会再像“黑箱搬家”。你搬的是：

- 配置
- 工作区
- 认证与凭证状态
- 部分运行痕迹

## 19. 多环境怎么管理

很多人用一段时间后，会开始出现下面这些需求：

- 工作和私人分开
- 稳定环境和实验环境分开
- 一个环境只做消息，一个环境做代码

这时你可以再考虑：

- `--profile`
- `--dev`
- 单独工作区
- 单独配置目录

但小白第一阶段不要急着上多环境。先把一个环境用稳定，收益更大。

## 20. 小白最实用的三条日常原则

### 原则 1：先验证本体，再验证插件和渠道

只要 Dashboard 和基础 Agent 都不稳，就别急着接更多东西。

### 原则 2：每次只改一类问题

不要一次同时改：

- 模型
- 渠道
- 权限
- 端口
- 工作区

这样排错成本会暴涨。

### 原则 3：先学会读状态，再学会追求高级玩法

`status`、`health`、`doctor`、`logs` 是小白真正的护身符。

## 21. 本章小结

配置的本质不是“参数越多越厉害”，而是“让系统稳定且可理解”。

命令的本质也不是“越会越多越厉害”，而是“知道在什么场景下调用什么入口”。

如果你现在已经知道：

- 配置文件在哪
- WSL2 路线下文件实际住在哪里
- 最重要的命令有哪些
- 改配置后先做什么
- Windows 浏览器怎么访问 Ubuntu 里的 Dashboard
- 出问题时怎么排

那你已经从“会装”进入“会用”了。

### 21.1 本章验收标准

这一章读完后，你应该已经真的做过下面这些事：

- 进过 `~/.openclaw/`
- 看过自己的 `openclaw.json`
- 跑过 `openclaw gateway status`
- 跑过 `openclaw doctor`
- 知道正式版平时怎么更新，以及去哪里看 release / changelog
- 知道改配置后先验证，而不是盲改很多项
- 工作区里已经有一份 `ch03-stable/WORKSPACE-GUIDE.md`

### 21.2 如果你后面卡在这些问题，优先回看哪一章

- 不知道 `openclaw.json` 之外，工作区根目录那几份文件到底该怎么分工：
  - [16-OpenClaw-工作区根文件-AGENTS-SOUL-USER-IDENTITY-TOOLS-HEARTBEAT-BOOTSTRAP-MEMORY.md](/D:/00容器/openclaw/book/16-OpenClaw-工作区根文件-AGENTS-SOUL-USER-IDENTITY-TOOLS-HEARTBEAT-BOOTSTRAP-MEMORY.md)
- 不清楚为什么改了根文件、技能、工具之后，token 和上下文成本会变化：
  - [17-OpenClaw-系统提示词与上下文注入-模型到底看到了什么.md](/D:/00容器/openclaw/book/17-OpenClaw-系统提示词与上下文注入-模型到底看到了什么.md)
- 不明白 `dmScope`、`main`、`isolated`、`cron`、`heartbeat` 对自己后面做个人助手或研究助手到底有什么影响：
  - [18-OpenClaw-会话与定时机制-dmScope-main-isolated-cron-heartbeat.md](/D:/00容器/openclaw/book/18-OpenClaw-会话与定时机制-dmScope-main-isolated-cron-heartbeat.md)

## 22. 下一章

- [04-OpenClaw-Channels-Feishu-多入口接入实战.md](04-OpenClaw-Channels-Feishu-多入口接入实战.md)

> [!NOTE]
> 本章内容基于 OpenClaw 当前版本验证（截至 2026 年 3 月）。
> 如果你使用更新版本，关键命令和配置项请以官方源码为准。

## 本章核验依据（官方文档 / 源码）

- `../sources/official/openclaw/docs/zh-CN/cli/index.md`
- `../sources/official/openclaw/docs/zh-CN/web/dashboard.md`
- `../sources/official/openclaw/docs/zh-CN/platforms/windows.md`
- `../sources/official/openclaw/docs/zh-CN/install/updating.md`
- `../sources/official/openclaw/docs/zh-CN/install/development-channels.md`
- `../sources/official/openclaw/CHANGELOG.md`
- Microsoft Learn: [Install WSL](https://learn.microsoft.com/en-us/windows/wsl/install)
- Microsoft Learn: [Working across Windows and Linux file systems](https://learn.microsoft.com/en-us/windows/wsl/filesystems)
- Microsoft Learn: [Accessing network applications with WSL](https://learn.microsoft.com/en-us/windows/wsl/networking)

## 本章合并来源

这一章主要吸收并改写了以下归档文档中的主题：

- `openclaw_config_guide.md`
- `openclaw_config_sop.md`
- `openclaw_commands_beginners_reference_2026-03-06.md`
- `openclaw-tool-access-beginner-config-zh.md`
- `openclaw_user_guide.md`
- `openclaw_newbie_best_practice.md`
- `openclaw_newbie_best_practice_practical.md`
- `openclaw_dual_env_guide.md`


