# 04. 它到底怎么工作，以及你下一步学什么

如果你已经安装并跑通过一次，这一章就是帮你把“会用”升级成“看得懂”。

## 1. 最简工作原理

你给 OpenClaw 发一个任务后，背后大致发生的是：

1. 入口接收你的请求
2. Gateway 接管请求和会话
3. Agent Runtime 开始处理任务
4. Agent 决定是否调用工具
5. 工具执行结果回流
6. 最终结果返回到 CLI、Dashboard 或消息渠道

这就是它和普通网页聊天的真正差别：

- 它不只是“生成一句话”
- 它是“接任务 -> 调能力 -> 回结果”

## 2. Gateway、Agent、Tools、Skills、Memory 的关系

### Gateway

Gateway 是中枢和控制面。

你可以把它理解成：

- 网络入口
- 会话总管
- 安全检查点
- 运行状态中心

### Agent

Agent 是真正“思考和决策”的执行者。

它负责：

- 看提示词和上下文
- 结合模型生成下一步动作
- 决定是否调用工具

### Tools

Tools 是 Agent 的操作能力。

没有 Tools，Agent 很多时候只能“说”，不能“做”。

### Skills

Skills 是给 Agent 的现成方法论和流程模版。

可以把它理解成：

- 一份可复用的工作说明书
- 一套对某类任务的做法约束

### Memory

Memory 是长期记忆层。

它帮助 OpenClaw 在多轮或长期使用中保留重要信息，而不只是依赖当前对话窗口。

## 3. 已经用源码核过的一条主链路

当前官方源码版本下，可以把嵌入式 Agent 的主要链路理解为：

`agentCommand`
-> `runEmbeddedPiAgent`
-> `createAgentSession`
-> `subscribeEmbeddedPiSession`
-> `waitForAgentJob`

这对小白的意义不是让你背函数名，而是让你明白：

- 任务不是“一次函数调用就完事”
- 它包含会话建立、事件订阅、工具执行、结果回收这些过程

## 4. 为什么 OpenClaw 会显得“比普通聊天工具复杂”

因为它同时在做几件事：

- 接收消息
- 管理会话
- 路由到不同 Agent
- 访问工具
- 保持安全边界
- 跟踪状态

所以你看到它有很多命令、很多文档是正常的。

问题不在于“它太复杂”，而在于“阅读顺序不对”。

## 5. 小白真正应该怎么继续学

### 如果你的目标是“先稳定用起来”

下一步重点看：

- Dashboard
- status / health / doctor / logs
- 基础配置
- 一个你最常用的渠道

### 如果你的目标是“让它更像个人助手”

下一步重点看：

- channels
- pairing
- memory
- skills

### 如果你的目标是“做自动化或更深度玩法”

下一步重点看：

- gateway configuration
- browser
- nodes
- cron / hooks / webhooks

### 如果你的目标是“研究源码和架构”

下一步重点看：

- `research/openclaw/src/commands/agent.ts`
- `research/openclaw/src/agents/pi-embedded-runner/run.ts`
- `research/openclaw/src/agents/pi-embedded-runner/run/attempt.ts`
- `research/openclaw/src/agents/pi-tools.ts`
- `research/openclaw/src/gateway/server-methods/agent-job.ts`

## 6. 根目录原文档现在该怎么用

现在更合理的用法是：

- 把这个 `docs-beginner-pack/` 当主线
- 把根目录 `.md` 当专题资料库

你不需要再从几十篇文档里自己猜顺序。

建议按下面方式回查：

- 想看安装经验：看根目录 Windows 文档
- 想看命令表：看 `openclaw_commands_beginners_reference_2026-03-06.md`
- 想看源码分析：看 `openclaw_source_analysis.md`、`openclaw_agents_focus_guide.md`
- 想看技能专题：看 skill 系列文档
- 想看飞书专题：看 feishu 系列文档

## 7. 一个务实的学习路线

如果你想真正学会 OpenClaw，而不是看热闹，建议这样走：

1. 先跑通本地 Dashboard
2. 先完成一次真实任务
3. 先学最小配置
4. 再接一个常用渠道
5. 再学 Tools / Skills / Memory
6. 最后再碰多 Agent、Nodes、自动化、远程访问

## 8. 你现在最不该做的事

- 不要一次接 3 个以上渠道
- 不要一开始堆很长的配置
- 不要本地都没通就先搞远程
- 不要把所有根目录文档从头看到尾

## 9. 继续深入时，建议看的官方资料

- 官方源码仓库：`research/openclaw`
- 官方文档入口：`research/openclaw/docs/zh-CN`
- 更细核验清单：`docs-curated/VERIFIED-FACTS.md`
- 原文档地图：`docs-curated/ORIGINAL-DOC-MAP.md`

## 这套合并包的边界

这 4 份文档已经足够小白建立一套正确的 OpenClaw 认知和操作顺序。

如果你后面还想继续压缩，我建议下一步不是再写更多文档，而是：

- 按你的实际环境再做一套“只针对你机器”的安装 SOP
- 或者按你的目标做一套“只针对飞书 / 只针对 WhatsApp / 只针对 Coding Agent”的专题包

## 核验依据

- 官方架构文档：`research/openclaw/docs/concepts/architecture.md`
- 官方中文概念文档：`research/openclaw/docs/zh-CN/concepts/architecture.md`
- 当前源码链路位置：
  - `research/openclaw/src/commands/agent.ts`
  - `research/openclaw/src/agents/pi-embedded-runner/run.ts`
  - `research/openclaw/src/agents/pi-embedded-runner/run/attempt.ts`
  - `research/openclaw/src/agents/pi-tools.ts`
  - `research/openclaw/src/agents/pi-tools.before-tool-call.ts`
  - `research/openclaw/src/gateway/server-methods/agent-job.ts`
