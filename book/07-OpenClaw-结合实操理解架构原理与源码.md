# 第七章：结合实操理解架构原理与源码

## 1. 本章要解决什么问题

到前面几章为止，你已经知道 OpenClaw 能装起来、能配起来、能接入口，也已经跑过一些真实场景。现在再回头讲原理，才有意义。

很多人卡在这一关，不是因为不会写代码，而是因为脑子里没有一张结构图。命令越学越多，页面越看越多，最后的感觉往往是：每一块我都见过，但它们为什么会连在一起，我说不清。

这一章的任务，就是把这种“会用但看不透”的状态，推进到“知道它为什么这样设计”。

### 1.1 本章实操场景

这一章不是让你纯看理论，而是让你带着前面已经做过的动作，去源码里验证：

1. 你在 Dashboard 或飞书里发出的那条任务，是怎么跑起来的
2. Gateway 为什么是中枢
3. Tools、Hooks、审批为什么不是附属功能
4. 你前面做过的那些场景，在源码里各自落在哪一层
5. 最后给自己写出一页“以后排错先看哪”的源码笔记

### 1.2 本章产物

读完这一章，你手里至少应该有下面这些结果：

- 一条清晰的请求执行路径
- 一份自己的源码速查笔记

### 1.3 开始前先准备什么

开始前，最好先满足这几个条件：

- 你已经完成前面的至少一个本地实操场景
- 你已经知道 Gateway、Dashboard、飞书这些词分别对应什么
- 你本地已经有一份 OpenClaw 源码副本可供查看

## 2. 先记住一个总判断

从官方架构文档和当前源码来看，OpenClaw 最重要的事实不是“它能聊天”，而是：

OpenClaw 是一个围绕长期运行的 Gateway 组织起来的个人 AI 助手系统。

这句话里有三个关键词。

### 长期运行

Gateway 不是你发一条消息才临时拉起的脚本，而是系统持续存在的中枢。

### 围绕 Gateway 组织

Dashboard、CLI、Web 界面、自动化、渠道、节点，并不是各自独立的小程序。它们都在和同一个 Gateway 发生关系。

### 个人 AI 助手系统

它不是单一模型，也不是单一网页。它同时要处理消息、会话、工具、技能、记忆、设备、权限和安全边界。

如果你先把这个总判断记稳，后面很多“为什么设计成这样”的问题，都会自然简单很多。

## 3. 用四层结构来理解 OpenClaw

最适合小白的理解方式，不是直接钻函数名，而是先画出四层。

### 第一层：入口层

入口层是你最容易看到的部分，包括：

- `openclaw` CLI
- Dashboard / Control UI
- WebChat
- 飞书、Telegram、WhatsApp、Discord、Slack 等消息渠道
- 自动化或外部触发入口

这一层只解决一件事：你从哪里把任务送进系统。

### 第二层：Gateway 层

Gateway 是整个系统的中枢。官方架构文档明确写到，控制面客户端通过 WebSocket 连接到 Gateway，节点也通过 WebSocket 连接到同一个 Gateway，本地默认绑定地址是 `127.0.0.1:18789`。

它负责的事情包括：

- 维护长期连接
- 暴露控制平面
- 接收请求并返回事件
- 管理身份、认证、配对和一部分安全边界
- 把不同入口汇总到同一套系统里

这一层解决的是：系统如何被组织起来。

### 第三层：Agent 执行层

当一个请求真正开始“思考并执行”时，进入的就是 Agent 执行层。

它要处理的不是单次问答，而是更完整的一次任务运行：

- 准备上下文
- 解析模型与认证
- 选择是否调用工具
- 处理工具输出
- 形成流式事件
- 在结束时给出最终结果

这一层解决的是：任务到底是怎么跑完的。

### 第四层：能力层

能力层包括：

- Tools
- Skills
- Memory
- Browser
- Nodes
- Channels 相关能力
- 审批、Hook、沙箱等治理机制

这一层解决的是：系统除了回复一句话之外，还能具体做什么。

## 4. 为什么 Gateway 是轴心，而不是配角

很多新手会把 Dashboard 当成 OpenClaw 的主体。这种误解很常见，因为你最容易“看见”的东西，往往就是浏览器页面。

但从官方文档和源码组织方式看，真正的轴心始终是 Gateway。

原因很直接。

第一，所有入口最终都在汇合到 Gateway。CLI 调状态、Dashboard 打开控制界面、节点接入、渠道收消息，这些事情都不是各玩各的，而是围绕 Gateway 展开。

第二，系统状态主要汇总在 Gateway。健康检查、连接情况、会话推进、事件流、配对关系，都会在这里留下痕迹。

第三，安全边界也大量依附于 Gateway。无论是 token、pairing、allowlist，还是远程访问和控制面握手，核心都和 Gateway 的连接模型有关。

所以学 OpenClaw 时，一个很实用的判断方法是：先判断问题发生在 Gateway 之前、之中，还是之后。只要这一步判断对了，排错路径通常就不会乱。

## 5. 从“我发了一句话”到“系统给我答案”，中间到底发生了什么

真正让人看懂 OpenClaw 的，不是死记架构词汇，而是顺着一次请求走一遍。

你可以把一次典型请求拆成两条相关链路来看：一条是执行链路，一条是控制链路。

### 5.1 执行链路：任务是怎么跑起来的

从当前源码看，命令入口会先落到 `src/commands/agent.ts`。在这里，`agentCommand` 最终会调用 `runEmbeddedPiAgent(...)`，把一次用户请求交给嵌入式 PI Agent 运行器。

接着，在 `src/agents/pi-embedded-runner/run/attempt.ts` 里，执行尝试会做几件关键事情：

1. 通过 `createOpenClawCodingTools(...)` 装配可用工具
2. 通过 `createAgentSession(...)` 创建真正的 Agent 会话
3. 通过 `subscribeEmbeddedPiSession(...)` 订阅这次会话的事件流
4. 一边消费流式输出，一边等待执行结束

这比“调一次模型 API”复杂得多，也正是 OpenClaw 和普通网页聊天工具的关键差别。

### 5.2 控制链路：Gateway 怎么知道它什么时候结束

在 Gateway 这一侧，`src/gateway/server-methods/agent.ts` 会通过 `waitForAgentJob(...)` 等待本次运行的终态快照。也就是说，Gateway 不只是把请求转发出去，它还要知道：

- 这次运行有没有被接受
- 是否成功结束
- 有没有报错
- 最终应该如何把状态返回给调用方

所以更准确的表述不是“一条函数调用链从头串到尾”，而是：

- 执行层负责把任务真正跑起来
- Gateway 侧负责接住这次运行并等待可交付的终态

这两条线合在一起，才是你在 Dashboard、CLI 或渠道里看到的完整体验。

### 5.3 你可以自己在源码里验证一次

如果你不想只相信这本书的描述，可以自己顺手在源码里验证一遍。最小动作如下。

第一步，进入你克隆下来的 OpenClaw 仓库根目录。

例如：

```powershell
cd D:\你的学习目录\research\openclaw
```

如果你是在 WSL2 或 Linux 里读源码，也可以是类似下面的路径：

```bash
cd ~/projects/openclaw-source
```

第二步，先找命令入口里 `runEmbeddedPiAgent` 在哪。

```powershell
Select-String -Path .\src\commands\agent.ts -Pattern 'runEmbeddedPiAgent'
```

第三步，再找执行尝试里的工具装配、会话创建和事件订阅。

```powershell
Select-String -Path .\src\agents\pi-embedded-runner\run\attempt.ts -Pattern 'createOpenClawCodingTools|createAgentSession|subscribeEmbeddedPiSession'
```

第四步，最后找 Gateway 侧的等待逻辑。

```powershell
Select-String -Path .\src\gateway\server-methods\agent.ts -Pattern 'waitForAgentJob'
```

如果你想直接看上下文，再执行类似下面的命令：

```powershell
Get-Content .\src\commands\agent.ts | Select-Object -First 220
Get-Content .\src\agents\pi-embedded-runner\run\attempt.ts | Select-Object -First 260
Get-Content .\src\gateway\server-methods\agent.ts | Select-Object -First 220
```

你不需要第一天就读懂每一行。你只要先确认三件事真的存在就够了：

1. 命令入口确实把请求交给了嵌入式 Agent 运行器
2. 运行器里确实有工具装配、会话创建和事件订阅
3. Gateway 侧确实在等待任务终态

### 5.4 把这次读源码结果变成一份以后真的能用的笔记

这一步很关键。很多人读源码时只是在屏幕上扫几眼，第二天又全忘了。

你现在就把这次验证结果写成一页自己的架构速查笔记，后面排错会非常有用。

如果你当前主要用的是 Windows，可以在 PowerShell 里执行：

```powershell
New-Item -ItemType Directory -Force -Path '.\notes'
@'
# OpenClaw 架构速查笔记

- 我最常用的入口：
- 入口文件：
- Gateway 相关文件：
- Agent 执行相关文件：
- 工具或 Hook 相关文件：
- 以后如果“飞书收到消息但不执行”，我会先看哪一层：
'@ | Set-Content -Path '.\notes\openclaw-architecture-note.md'
```

然后把你刚才看到的命令入口、Gateway 文件和执行入口填进去。这样做的价值很直接：

1. 以后不是“重新从头找”
2. 你会开始把功能表现和源码结构对应起来
3. 当你以后要扩写这本书、做 PDF / EPUB 或对外讲解时，这就是最早的一份底稿

## 6. Session、sessionId、sessionKey、runId：理解行为差异的四把钥匙

OpenClaw 之所以经常让新手觉得“明明都在聊天，为什么表现不一样”，核心原因之一就是它不是只处理消息文本，而是在处理会话和运行实体。

### Session

可以把 Session 理解成一次持续上下文的容器。你看到的“继续聊上一次的话题”，本质上就是系统在续用某个会话。

### sessionId

从源码注释看，`sessionId` 更像一次具体会话实例的标识。在 `/new`、`/reset` 这类操作后，它可能会变化。

### sessionKey

`sessionKey` 更接近“这类会话归属到哪条持续主线”的概念。私聊、群聊、频道、不同 Agent，往往会落到不同的 `sessionKey` 上。

### runId

`runId` 是某一次执行的唯一运行标识。一个会话里可以有很多次 run，每次 run 都有自己的生命周期和结束状态。

你暂时不必把这几个标识全部背下来，但一定要知道：OpenClaw 的很多“看起来很复杂”的行为，其实都是因为它认真地区分了“会话”和“本次运行”。

## 7. Prompt 为什么不能被理解成“一大段固定提示词”

很多旧文档最容易把人带偏的地方，就是把 Prompt 写得像一个巨大静态模板。这样写不是完全错，但不够准确。

更接近当前系统实际的说法应该是：

OpenClaw 的上下文是分层拼装的，而不是单块固定文本。

通常至少有几类来源会一起作用：

- 系统级规则和安全约束
- 当前会话与渠道信息
- 工作区中的上下文文件
- Skills 列表以及需要时读取的 `SKILL.md`
- Memory 和记忆检索结果
- 工具调用产生的中间结果

这也是为什么你会感觉“同一句话，在不同渠道、不同工作区、不同会话里，AI 的表现不完全一样”。那不是偶然，而是系统设计本来就允许运行时上下文深度参与。

## 8. Tools、Hooks 和审批为什么属于架构核心

如果把 Tools 看成“额外插件”，你会低估 OpenClaw 的设计重点。

从源码里可以直接看到，执行尝试阶段会显式创建工具集合，也就是 `createOpenClawCodingTools(...)`。这说明工具不是外围外挂，而是 Agent 运行时的一部分。

更关键的是，工具调用并不是无条件直通。`src/plugins/hooks.ts` 里存在 `before_tool_call` Hook，官方实现明确支持在工具调用之前进行修改、阻断或补充说明。

这一点非常重要，因为它意味着 OpenClaw 的工具调用天然具备治理能力：

- 可以被审查
- 可以被拦截
- 可以改参数
- 可以在高风险场景下直接阻断

这就是为什么审批、Hook、allowlist、沙箱这些东西不应被看成“高级玩法”。它们其实是在给一个能执行真实操作的 AI 系统加上边界。

## 9. 为什么群聊、路由、多 Agent 一下子就会变复杂

你会发现，很多人一开始只想做两件事：

- 接一个新渠道
- 再加一个 Agent

结果系统复杂度马上上来了。原因并不神秘，而是这两件事都会直接碰到会话模型。

一旦从单一私聊进入下面这些场景，复杂度就会迅速增加：

- 私聊和群聊并存
- 一个渠道对应多个群
- 多个渠道要区分工作与个人流量
- 多 Agent 需要不同工作区或不同权限
- 不同渠道要走不同路由或不同安全策略

这些复杂度最后都会回到同一个问题：谁的消息，落到哪个会话，使用哪个 Agent，能调用哪些能力。

所以后面学 Channels、Skills、Memory、路由时，你会越来越感觉：第四章其实在讲一件“总开关级”的事情，那就是会话和中枢。

## 10. 小白读源码的正确顺序，不要一上来满仓库乱翻

如果你现在决定开始读官方仓库，最合理的顺序不是“看到什么点什么”，而是按问题链来读。

### 第一步：先读官方架构定义

先看：

- `../sources/official/openclaw/docs/zh-CN/concepts/architecture.md`
- `../sources/official/openclaw/docs/zh-CN/start/getting-started.md`
- `../sources/official/openclaw/docs/zh-CN/web/dashboard.md`

这一轮只做一件事：确认官方自己是怎么定义 Gateway、Dashboard 和控制面的。

### 第二步：再看命令入口

接着读：

- `../sources/official/openclaw/src/commands/agent.ts`

你要看的不是所有细节，而是：用户的一次请求到底是从哪里进执行层的。

### 第三步：再看执行尝试

继续读：

- `../sources/official/openclaw/src/agents/pi-embedded-runner/run.ts`
- `../sources/official/openclaw/src/agents/pi-embedded-runner/run/attempt.ts`

这一轮重点看三件事：

- 工具是怎么装配的
- 会话是怎么创建的
- 事件是怎么订阅和输出的

### 第四步：最后看 Gateway 等待与 Hook

然后再看：

- `../sources/official/openclaw/src/gateway/server-methods/agent.ts`
- `../sources/official/openclaw/src/gateway/server-methods/agent-job.ts`
- `../sources/official/openclaw/src/plugins/hooks.ts`

到这里，你对“请求如何被接住、运行、等待、收尾”的整体图景就已经比较完整了。

### 10.1 按 30 分钟做一次最小源码导读

如果你是第一次认真读 OpenClaw 源码，我建议你不要超过 30 分钟，也不要试图把仓库读完。最稳的做法是做一次“最小源码导读”。

你可以直接照着下面这组节奏来：

1. 先读 `docs/zh-CN/concepts/architecture.md`，只看它怎么定义 Gateway、Agent、入口和控制面。
2. 再读 `src/commands/agent.ts`，只回答“请求从哪进去”。
3. 再读 `src/agents/pi-embedded-runner/run/attempt.ts`，只回答“任务怎么真正跑起来”。
4. 最后读 `src/gateway/server-methods/agent.ts` 和 `src/plugins/hooks.ts`，只回答“Gateway 怎么等结果、Hook 怎么插进来”。

这一轮里，你只需要写下四句自己的总结：

- 入口在哪里
- 执行在哪里
- 等待终态在哪里
- 风险控制点在哪里

只要这四句你能自己说清楚，第四章就算真正学进去了。

## 11. 读源码时，最值得避免的三个误区

### 误区一：先追每个函数，再想整体

正确顺序应该反过来。先看整体，再看局部函数。

### 误区二：把测试文件当成主入口

测试很重要，但第一次读仓库时，先找生产入口文件。否则你会被各种边界场景和 mock 带偏。

### 误区三：看见复杂就以为设计混乱

OpenClaw 处理的是长期运行、中枢网关、会话模型、多入口和真实工具调用。它比普通聊天页复杂，是正常结果，不等于无序。

## 12. 本章小结

学到这里，你至少要建立六个稳定认知。

1. OpenClaw 的真正轴心是 Gateway，不是 Dashboard。
2. OpenClaw 不是单次请求系统，而是长期运行系统。
3. 一次请求同时包含执行链路和控制链路。
4. 会话、运行标识和上下文分层，是理解系统行为的基础。
5. Tools、Hooks、审批和沙箱都属于架构核心，不是附属功能。
6. 读源码时要先按链路读，再按模块读。

只要这六点站稳，后面去理解 Tools、Skills、Memory 和 Channels，就不容易再被零散概念拖着跑。

### 12.1 本章验收标准

这一章读完后，你至少应该能自己验证下面这些点：

1. 在源码里找到一次请求的入口
2. 在源码里找到执行尝试和事件订阅的位置
3. 在源码里找到 Gateway 等待任务终态的位置
4. 能把前面做过的某个实操场景，说清楚它在架构里经过了哪几层
5. 已经写出一份自己的源码速查笔记

## 13. 下一章

- [10-OpenClaw-飞书-12个可实操场景与配置清单.md](10-OpenClaw-飞书-12个可实操场景与配置清单.md)

> [!NOTE]
> 本章内容基于 OpenClaw 当前版本验证（截至 2026 年 3 月）。
> 如果你使用更新版本，关键命令和配置项请以官方源码为准。

## 本章核验依据（官方文档 / 源码）

- `../sources/official/openclaw/docs/zh-CN/concepts/architecture.md`
- `../sources/official/openclaw/src/commands/agent.ts`
- `../sources/official/openclaw/src/agents/pi-embedded-runner/run.ts`
- `../sources/official/openclaw/src/agents/pi-embedded-runner/run/attempt.ts`
- `../sources/official/openclaw/src/plugins/hooks.ts`
- `../sources/official/openclaw/src/gateway/server-methods/agent.ts`
- `../sources/official/openclaw/src/gateway/server-methods/agent-job.ts`

## 本章合并来源

这一章主要吸收并改写了以下归档文档中的主题：

- `OpenClaw-完整学习手册-小白版.md`
- `openclaw_source_analysis.md`
- `openclaw_agents_focus_guide.md`
- `openclaw_agent_framework_analysis.md`
- `agent_prompt_analysis.md`
- `OpenClaw-回复逻辑-小白说明书.md`


