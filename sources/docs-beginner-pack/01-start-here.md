# 01. 先认识 OpenClaw

## 一句话理解

OpenClaw 不是“一个会聊天的模型壳子”，也不是“只会写代码的 Agent”。

它更像是一个你自己掌控的个人 AI 助手中枢：

- 你可以通过 CLI、浏览器面板、消息渠道跟它交互。
- 它背后有一个长期运行的 Gateway 负责连接、路由、状态和安全。
- 它内部可以调用 Agent、Tools、Skills、Memory、Nodes 去完成任务。

## 小白最容易搞混的 4 件事

### 1. OpenClaw 不等于某个模型

OpenClaw 是运行框架，不是模型本身。

模型只是它的大脑来源之一。你可以在 onboarding 过程中接 OpenAI、Anthropic、OpenRouter 等不同提供商。

### 2. OpenClaw 不等于“只有代码能力”

它当然能做代码相关事情，但官方定位更偏“个人 AI 助手”：

- 聊天
- 收消息、发消息
- 调工具
- 管会话
- 连手机或别的节点设备
- 跑定时任务

所以你把它理解成“你的个人 AI 控制台”会比“另一个编程 Agent”更准确。

### 3. OpenClaw 的核心不是 Dashboard，而是 Gateway

很多人第一次看到浏览器页面，会以为 WebUI 才是主体。

其实不是。

真正的核心是 Gateway：

- 它长期运行。
- 它监听默认端口 `18789`。
- CLI、Dashboard、自动化、节点设备，都是连到这个 Gateway。

### 4. 小白第一步不该先折腾渠道

最常见误区是：

- 一上来先接 WhatsApp/Telegram
- 一上来先研究几十个 Skills
- 一上来先改很长的配置文件

更合理的顺序是：

1. 先安装
2. 先跑通 Gateway
3. 先打开 Dashboard
4. 先确认本地能聊天
5. 再去加渠道、加工具、加技能

## 你脑子里应该先建立的简化模型

可以先把 OpenClaw 看成 4 层：

### 第 1 层：你看到的入口

- `openclaw` 命令行
- `openclaw dashboard` 打开的浏览器控制台
- WhatsApp / Telegram / Discord / Feishu 等消息入口

### 第 2 层：Gateway

Gateway 是中枢。

它负责：

- 接收连接
- 管理会话
- 做路由
- 做认证
- 维护状态
- 对外提供 WebSocket / HTTP 控制面

### 第 3 层：Agent Runtime

当你让它“帮我做一件事”时，Agent 才真正开始工作。

它会：

- 读上下文
- 选模型
- 决定要不要调用工具
- 逐步生成结果

### 第 4 层：执行能力

这些能力包括：

- Tools
- Skills
- Memory
- Browser
- Nodes
- Channels

这也是 OpenClaw 和普通网页聊天最本质的差别。

## 小白阶段你真正要掌握的重点

先只掌握下面这些就够了：

- 它是“个人 AI 助手框架”，不是单一模型产品。
- 它依赖一个长期运行的 Gateway。
- 第一次先跑 Dashboard，不要先配所有渠道。
- 配置文件是 `~/.openclaw/openclaw.json`。
- 先会看 `status`、`health`、`doctor`、`logs`。

## 哪些事实已经核验过

- 官方定位：personal AI assistant
- Windows 官方推荐：WSL2
- 当前源码 Node 要求：`>=22.12.0`
- 官方推荐新手命令：`openclaw onboard --install-daemon`
- 默认本地入口：`http://127.0.0.1:18789/`

## 这一章看完后，你该做什么

直接继续看：

- [02-install-and-first-run.md](02-install-and-first-run.md)

不要回头先刷几十篇根目录文档。那样只会让你重新进入信息过载。

## 核验依据

- 官方源码 README：`sources/official/openclaw/README.md`
- 官方入门文档：`sources/official/openclaw/docs/zh-CN/start/getting-started.md`
- 官方架构文档：`sources/official/openclaw/docs/concepts/architecture.md`
- 源码入口：
  - `sources/official/openclaw/package.json`
  - `sources/official/openclaw/src/commands/dashboard.ts`
  - `sources/official/openclaw/src/gateway/server.impl.ts`

