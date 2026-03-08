# 🔬 源码解密：OpenClaw的“灵魂”到底是个啥？

```
刚帮你把官方的源码克隆下来，我立刻钻进去“扒”了一遍它的底层代码（重点侦查了 src/agents/ 目录和核心配置）。
```

```
如果你觉得配置文档看着有点玄乎，没关系！接下来我用大专生也能听懂的“机甲与驾驶员”比喻，结合源码真实的文件名，给你彻底讲透 OpenClaw 到底是怎么运行的。
```

---

## 1. 🤖 核心真相：谁才是真正的“Agent（智能体）”？

在源码的 `package.json` 里，我发现了一个惊天大秘密：**OpenClaw 其实自己并不“生产”最基础的单机 Agent 循环代码！**

它的核心生命线，深度依赖了三个外部神级轮子：

- `@mariozechner/pi-agent-core` （核心灵魂）
- `@mariozechner/pi-coding-agent` （写代码的特战服）
- `@mariozechner/pi-ai` （大模型通信器）

> **💡 小白秒懂：**
>
> - **Pi Agent** 就是市面上一款开源的、能力极强的“裸体纯战斗机甲”。
> - **OpenClaw** 是一个“机甲航母与信号塔”。它把这台机甲买回来，改装了上百种武器（飞书、Telegram 接入，原生系统级的 exec/bash 监控，复杂的权限墙），然后重新包装成了可以多端操控的“超级智能助理”。

---

## 2. 🫀 运作原理：在代码里，它是怎么思考和执行的？

我们在 `src/agents/pi-embedded-runner/run/attempt.ts` 这个文件里找到了它真正发力的**心脏起搏器** —— 函数：`runEmbeddedAttempt()`。

它的核心运行原理是一套**严密的循环（Loop）机制**：

1. **挂载武器舱 (Tools & Hooks)**
  源码里有一行叫 `createOpenClawCodingTools()`。当你抛给它一个任务时，它不是直接去问大模型，而是先扫描它有多高权限：
  - *你能读我 C 盘吗？(tool-fs-policy.ts)*
  - *你能发飞书消息吗？(channel-tools.ts)*
    然后把这些合法的“工具（大马士革刀、沙漠之鹰）”挂载给机甲。
2. **唤醒思考循环 (Thought Loop)**
  交接给了 `pi-agent-core` 的 `SessionManager.open()`。
    模型开始输出 `[Tool Call: bash]`，这个时候它其实在调用系统的 PowerShell 命令行。
3. **安全屏障与缓冲压缩 (Context Window & Compaction)**
  它怕模型变成“话痨”把内存撑爆（Context Overflow），所以在外层套了几个保险圈：
  - 如果上下文快满了，`compaction.ts` 就会强行把老对话“压缩”成一句摘要（例如：“之前我们在聊修 Bug”）。

---

## 3. 🤝 OpenClaw 如何与这个 Agent 交互？

既然 Agent 核心是外部引入的“黑盒”，OpenClaw 作为网关是怎么获取情报的呢？
答案是：**“窃听与截脉” (Subscribe & Intercept)**。

在 `src/agents/pi-embedded-subscribe.ts` 中，OpenClaw 使用了 `subscribeEmbeddedPiSession()`：

- **截获思维过程**：寻找输出流里的 `<think>` 这个标签（DeepSeek 或 GLM 等推理模型的标志）。如果检测到了，它就把这段流剥离出来，在你的控制台或者页面里打上“正在思考…”的灰色字体，防止主答案混淆。
- **截获工具使用**：每当机甲拿起“Bash（系统终端）”试图砸你的 `d:\code` 时，OpenClaw 会跳出来阻挡：*“且慢！我先看看 Workspace 规则允许吗？”* 如果允许，它就代替机甲物理执行这行命令，再把命令行终端打印出来的红绿字反馈回去。

---

## 4. 🧠 Agent 与 Model 的终极关系（代码视角）

这是很多小白最容易搞晕的：“我用的到底是 GPT 还是 OpenClaw？”

从代码层面的定义（`resolveModel()`）：

🎯 **Model（模型 / 脑髓）**：

- **本质：** 一段可以通过网络（HTTP/API）接收文本输入，计算概率，并一个字一个字蹦出结果的黑盒。
- **代码里长啥样：** 在 `models-config.providers.ts` 里，它只是一堆 URL 地址和 Token。
- **比喻：** 它是**驾驶员的大脑**。不管你是智谱（GLM）、Codex，它其实都“没有手脚”，只会说话。

🦾 **Agent（代理 / 机甲）**：

- **本质：** 一套围绕 Model 运行的循环脚本（While/For Loop）。
- **代码里长啥样：** 上文提到的包含了 `SessionManager`, `Tools` 的那一大坨逻辑。
- **比喻：** 它是**包裹在驾驶员外面的机甲外骨骼**。
当大脑（Model）说：“我要执行 `ls -la`” 时。大脑只是发出了这段字符串（JSON）。
**机甲（Agent）** 截获了这段字符串，真正调用 Node.js 的 `child_process.exec()` 去你的硬盘里跑了这句话，然后把命令行里的输出结果，塞回大脑的耳朵里：“报告长官，结果是 xxx。” 大脑基于这句反馈，再决定下一步说什么。

---

> 🚀 **用一句话总结你的系统结构：**
> 你把 **智谱 GLM**（Model/大脑） 塞进了 **Pi Agent**（核心代驾员/四肢），然后把这一切丢到了 **OpenClaw**（航母基地/中介塔）里，最后通过这只手，稳稳地握住了你的 **飞书**！🦞

---

## 5. 🛡️ “套娃”之谜：提示词与工具会冲突吗？

既然内外都有两层框架（OpenClaw + Pi Agent），很多小白肯定会问：**“它们各自的提示词（Prompt）和工具会不会打架？”**

为了给你个准信，我顺藤摸瓜，直接把 `pi-agent-core` 的源码拉下来看了个底朝天：

### 提示词（Prompt）冲突吗？

答案是：**绝对不会冲突，因为 OpenClaw “夺权”了。**

- 在 `pi-agent-core` 的底层，它自己**全真空**，完全不带任何硬编码的系统提示词（`AgentState.systemPrompt = ""`）。
- 在上层 `pi-coding-agent` 中，官方确实给了一套默认的系统提示词（包含了让机器人少说话、怎么用工具的指令）。
- **但是！** OpenClaw 在启动机甲时，用了 `createSystemPromptOverride()` 技术（位于 `attempt.ts`）。这就好比 OpenClaw 开通了“最高管理员权限”，直接覆盖并注入了自己的定制版提示词。所以，我们在使用时，模型听到的全都是 OpenClaw 定制的终极指令，内部绝不会“内讧”。

### 工具（Tools）到底是谁的？

Pi Agent 原生其实自带了基础的 4 件套打工人工具：`read`（读文件）、`write`（写文件）、`edit`（局部修改）、`bash`（终端运行）。
OpenClaw 又是怎么处理的呢？我们在 `src/agents/pi-tools.ts` 里看到了它的神级操作：

1. **拿来主义**：它直接 `import { codingTools }`，把原生的 4 件套当做“毛坯房”拿了过来。
2. **“包浆与精装”升级（沙盒化）**：
  - 原生工具毫无顾忌，大模型如果发癫，发个指令就能把你的 C 盘删了。
  - OpenClaw 用了 `createSandboxedReadTool` 等包装函数，把原本粗糙的读写工具，强行关在了一个“安全视界（Workspace/Sandbox）”里。没有 OpenClaw 的点头，大模型哪里都动不了。
  - 最狠的是，它把原生的危险分子 `bash` 直接扔掉不用，换成了自己手搓的带着拦截审批、背景执行检测的超级 `execTool`。
  - 最后，这套机甲不仅保留了代码能力，还被额外加装了飞书消息收发器、网页浏览器抓取等强大的额外通道工具。
3. **结论**：OpenClaw 把原生的“危险菜刀”没收了，重新包上剑鞘后，再加上自己打造的“长枪短炮”，才交给大模型使用！

---

## 6. 🍰 三层蛋糕：pi-agent-core、pi-coding-agent 与 OpenClaw 的三角关系

既然 OpenClaw 引入了这俩兄弟，它们在源码里的分工到底是什么呢？
在阅读了 `pi-mono` 仓库和 OpenClaw 的包依赖关系后，我们可以把它们比作一个**“三层蛋糕”**：

### 🍰 底层蛋糕胚：`@mariozechner/pi-agent-core`

- **定位**：最纯粹、最底层的**抽象灵魂与骨架**。
- **职责**：它里面**没有任何具体功能**（不会读文件，不会执行终端，没有 UI）。它只定义了“大模型通信的基础数据结构”（例如 `AgentMessage`, `AgentTool`, `AgentState`），以及一个原始的 `agentLoop`（请求-响应的死循环引擎）。
- **比喻**：它就是一个**光秃秃的 V8 发动机**。

### 🍰 中层奶油涂层：`@mariozechner/pi-coding-agent`

- **定位**：赋予骨架血肉的**实体外设与工具箱**。
- **职责**：它 `import` 了 `pi-agent-core`，并给这个光秃秃的引擎装上了轮子。
  1. **造工具**：它手搓了 `read`, `write`, `edit`, `bash` 这四大原生代码生成工具，也就是 `codingTools`。
  2. **造记忆**：它实现了 `SessionManager`（会话管理器），负责把你的历史聊天记录序列化存成 `.json` 塞进 `.pi/agent/sessions/` 文件夹里。
  3. **造中枢**：包含 `ModelRegistry` (模型注册表)、系统提示词生成器等具体逻辑。
- **比喻**：它是**一辆装好了方向盘、车轮、后备箱的成品轿车**（这也是为什么它自带了一个可以在终端直接运行的命令行 CLI 工具）。

### 🍰 顶层豪华裱花：`OpenClaw`

- **定位**：多端、多用户的**航母级调度中心与跨次元网关**。
- **与这两者的分工与关系**：
  1. 从 `pi-agent-core` 借走：底层的接口定义（如 `AgentMessage`, `AgentToolResult`）。
  2. 从 `pi-coding-agent` 借走：四大原始工具的“图纸”（schema），以及强大的记忆管理系统 `SessionManager`。
  3. **大换血与重生**：OpenClaw 拿到这辆成品轿车后，极其嫌弃它的安全性。于是：
    - 丢弃了容易删根目录的原生 `bash` 工具，换成了经过黑客级审计拦截的 `execTool`。
    - 给原生的 `read/write` 强行包裹了一层“沙盒护盾”（Sandbox机制）。
    - 接入了各种即时通讯通道（Feishu, Telegram, Discord），把单机工具升维成了在线协作网关。
- **比喻**：OpenClaw 是一个**把轿车爆改成带有防弹装甲、全地形雷达、且能同时让上百人远程协同驾驶的赛博巨无霸**。

---

## 7. 🗂️ 记忆管理：从“老实人记账”到“大脑压缩机”

你提到的另一个关键点非常敏锐：“那 OpenClaw 自己的上下文系统跟 `pi-coding-agent` 的 `SessionManager` 又是啥关系？”

这也生动诠释了 OpenClaw 的“魔改”艺术。我们在 `src/agents/compaction.ts` 和 `src/core/session-manager.ts` 的源码中，看到了这一套极其精密的组合拳：

### 📝 pi-coding-agent 的 `SessionManager`（老实人记账本）

- **原理**：它真的就是一个老实巴交的“硬盘记录员”。你每发一句话，大模型每回一句话，它就往 `.pi/agent/sessions/` 目录下的一个 `.jsonl` 文件里追加一行。
- **致命弱点**：它**没有记忆衰退机制**。如果你们聊了三天三夜，记录长达几万行，当下一次提问时，它会把这几万行全部塞给大模型的 API。这会导致两种后果：
  1. 直接把模型撑爆（超出 Context Window 上限报错）。
  2. 哪怕没爆，每一轮对话都要烧掉天价的 Token 费用。

### 🧠 OpenClaw 的 `Compaction` 机制（智能大脑压缩机）

为了解决老实人的致命缺陷，OpenClaw 没有抛弃 `SessionManager`，而是**留用它的硬盘记录功能，并在它上面挂载了一个由 AI 驱动的“消化代谢系统”—— Compaction（上下文压缩）**。

在 OpenClaw 的源码中，有一整套复杂的算力监控：

1. **Token 探针预警**：OpenClaw 每一轮都会用 `estimateTokens()` 扫描当前的对话字数。当发现字数逼近模型上下文极限时，它会拉响警报（触发溢出截断）。
2. **切片与总结（`summarizeWithFallback`）**：它会把过去的“几十页长篇流水账”切成几块，然后偷偷在后台调用大模型：*“请把这段对话浓缩成一段极其精炼的摘要，并保留一切关键参数、ID 和决定！”*
3. **记忆替换**：总结完成后，它调用 `SessionManager` 插入一条特殊的 `[Compaction]` 记录。再次面对大模型时，它会用这几百字的精炼总结，替换掉原来那几万字的废话。
4. **病历修复（Session Repair）**：此外，大模型有时候会发疯（比如给了一个拿报错的 Tool 回复但不给对应的请求），直接传过去会让 Anthropic 的原生 API 崩溃。OpenClaw 增加了一个 `sanitizeSessionHistory` 拦截层，像个老练的外科医生，在提交给大模型前先把损坏的对话记录自动开刀修好。

**总结一下：**
`SessionManager` 只是**物理硬盘（ROM）**，负责记录所有的流水账。
OpenClaw 是**内存与脑皮层（RAM + 大脑）**，它负责实时监控这块硬盘占了多大，快满的时候就用自己的 AI 技术把它精简压缩（Compaction），防止系统崩溃和省钱。

---

## 8. 🎭 幕后调用：除了配给 Agent，OpenClaw 自己也在偷用大模型？

你抓盲点的能力太准了！没错，你在 `openclaw.json` 里配置的各种大模型（智谱、OpenAI、Claude），不仅会分配给前台的 Pi Agent 用于跟你聊天和写代码，**OpenClaw 这个系统自己，在后台默默发力时也会去调用大模型**。

我在源码里通过全局搜索大模型底层接口包 `@mariozechner/pi-ai` 和 `completeSimple` 找到了 OpenClaw “夹带私货”直调大模型的三大核心场景：

### 核心场景 1：自动记忆压缩（Compaction）
* **源码位置**：`src/agents/compaction.ts`
* **干嘛用**：也就是上一节提到的“大脑压缩机”。当你的对话快达到上下文极限时，OpenClaw 会切分旧聊天记录并偷偷发给大模型。
* **它的专属提示词**：
  > *"Merge these partial summaries into a single cohesive summary. Preserve decisions, TODOs, open questions, and any constraints."*
  > （中文大意：把这些对话合并成一个连贯的摘要。请务必保留之前做过的决策、待办事项、开放性问题和任何约束条件。）

### 核心场景 2：语音播报（TTS）长文本总结
* **源码位置**：`src/tts/tts-core.ts` 中的 `summarizeText` 函数
* **干嘛用**：如果你让 OpenClaw 把一段很长的文章转换为语音（TTS），为了不浪费高昂的语音合成费用和生成时间，OpenClaw 会先唤醒大模型，让它把长文本提取成核心摘要，再去朗读摘要。
* **它的专属提示词**：
  > *"You are an assistant that summarizes texts concisely while keeping the most important information... Reply only with the summary, without additional explanations."*
  > （中文大意：请精准总结文本并保留最重要信息，把字数控制在限定范围内。只允许回复摘要，不许加额外的解释废话。）

### 核心场景 3：视觉图像理解（Image Understanding）
* **源码位置**：`src/media-understanding/providers/image.ts`
* **干嘛用**：当你在飞书或者 Telegram 给它发了一张截图，如果当前的主聊天模型是个“瞎子”（只支持文本），OpenClaw 会在后台立刻调一个支持懂图的模型，帮主模型“看”这张图。
* **它的专属提示词**：通常只有极简的 *"Describe the image."*（请描述这张图片），然后把描述文本无缝塞进对话流里。

### 🔄 多模型协作：如果你配置了多个模型，它怎么分配？
这正是 OpenClaw 配置框架的杀手锏之一：**角色路由（Routing）**。
OpenClaw 有一套非常灵活的 `resolveModel()` 和参数回退机制。

1. **绝对主力（Default Model）**：你在 `openclaw.json` 里配的 `defaultModel`，永远是那个站在前台、跟你聊天、拿工具写代码的“代驾员”（通常是最聪明的模型，比如 `gpt-4o` 或 `claude-3-5-sonnet`）。
2. **专职打杂（Summary Model）**：阅读源码（如 `resolveSummaryModelRef`）发现，像记忆压缩和语音概括这种对智商要求没那么高，但需要看大量长文本的苦力活，如果你一直用 `claude-3-5-sonnet` 肯定要破产。
   因此，OpenClaw 允许你在配置里指定专属的 `summaryModel`（摘要模型）。你可以把后台打杂的工作切给便宜又快速的模型（比如智谱的 `glm-4-flash` 或者 `gpt-4o-mini`）。
3. **视觉眼综合（Vision Model）**：处理图片时，源码会自动检测当前模型具不具备 `model.input?.includes("image")`（看图能力）。如果不具备，它会自动将图片请求“路由”给拥有视觉能力的备用模型。

**小结：**
在 OpenClaw 的世界里，多模型不再是“要么选 A 要么选 B”的单选题。而是一个**由各个专精模型构成的“智囊团”**：让贵的模型写代码，便宜的模型缩写笔记，带眼睛的模型专门审图！

---

## 9. 💡 终极思考：能把内核换成闭源大厂 Agent（如 Claude Code）吗？

你完全切中了当今 AI 开发的核心痛点！既然 OpenAI 和 Anthropic 提供的原生 Coding Agent（比如 Claude Code）在编码能力上肯定强于普通的开源实现，**那我们可以直接把 OpenClaw 肚子里的 `pi-coding-agent` 拔出来，换成 Claude Code 吗？**

### 先说结论：
**第一问：OpenClaw 调模型是不是全靠 `pi-ai`？**
**是的。** `@mariozechner/pi-ai` 就是 OpenClaw 的“统一翻译官”。无论背后是哪个模型，OpenClaw 都通过 `pi-ai` 的 `completeSimple` 等接口来发请求。

**第二问：能把 `pi-coding-agent` 替换成 Claude Code 吗？**
**从代码架构上来说，不能直接替换（极度困难）。** 

### 为什么不能直接替换？（三大排异反应）
前面我们分析过，OpenClaw 和 `pi-coding-agent` 并不是简单的“插座与插头”的关系，而是**“血脉相连”**的：
1. **记忆系统不兼容**：OpenClaw 的上下文压缩（`compaction.ts`）完全依赖于 `pi-coding-agent` 独有的 `SessionManager` 数据结构，它俩是绑死的。Claude Code 根本不暴露这种数据结构给你压缩。
2. **工具接管失败**：OpenClaw 最引以为傲的是它给所有工具（Tool）加上了“沙盒边界”、“权限审批”和“飞书卡片拦截”。闭源的 Claude Code 工具链是封装起来的（在它的 CLI 内部），OpenClaw 无法把自己的权限护盾注入（Inject）到 Claude Code 的底层逻辑里。
3. **闭源黑盒**：你无法控制 Claude Code 什么时候停下，也无法拿到它的中间思考过程（Streaming state），OpenClaw 就没法把它推流到 Feishu 等聊天软件上。

### 理想的使用方式是什么？（王炸组合：包工头与最强打工人）

既然不能在这个躯壳里“换心”，那应该怎么使用呢？
事实上，**OpenClaw 和 Claude Code 根本不是竞争关系，而是“上下级”关系！**

在实际开发中，最理想、最强大的方式是**让它们同处一个 Workspace（工作区），并开启“包工头 + 打工人”模式**：

#### 模式 1：让 OpenClaw 当“全自动指挥官（包工头）”
OpenClaw 具备强大的 `Bash`（执行终端命令）的能力。什么是 Claude Code？Claude Code 本质上就是一个可以通过终端运行的命令（比如 `claude "帮我重构这个文件"`）。
- **玩法**：你可以在飞书上对 OpenClaw 说：*“当前项目有个认证 BUG，你用 Claude Code 帮我修一下。”*
- **执行**：OpenClaw 会作为一个“智能中间件”，它会自己在底层终端里敲入 `claude "fix the authentication bug"` 命令，然后静静等待 Claude Code 修完，最后把修复结果总结发给远在飞书端的你！
- **优势**：完美结合了 Claude Code 的无敌编码能力，以及 OpenClaw 的 24 小时在线、跨端协作和自动调度的能力。

#### 模式 2：双打模式（协同操作本地文件）
- **OpenClaw 负责**：系统调研、读长文档、日志监控、需求分析、代码审查（利用它的 Session 压缩能力和多渠道沟通能力）。
- **Claude Code 负责**：具体的、大规模的代码重构和生成。
- **关联桥梁**：**本地文件系统**。因为它们共享你的项目文件夹，OpenClaw 刚帮你梳理出了 `architecture.md`，你接着在终端里唤醒 Claude Code：*“根据 architecture.md，实现这段代码。”* 两者无缝衔接。

**总结：**
不要想着把 `pi-coding-agent` 拆掉，因为它是 OpenClaw 在飞书/Telegram上与你沟通交流的基础“语言引擎”；
你应该把闭源黑科技（如 Claude Code、Cursor）看作**最强的外部兵器**。把 OpenClaw 视作**在线指挥大厅**，让指挥大厅在必要时去呼叫大规模杀伤性武器为你下场干活，这才是生产力的巅峰状态！

---

## 10. 🕸️ 节点系统 (Node)：为什么 AI 能拿到你的手机定位？

你在文档里看到的“节点（Node）”、“获取手机位置”以及“Web 网页系统”，其实构成了 OpenClaw 的**“章鱼网络架构”**。

在传统的思维里，AI 代码大模型只是一段在服务器上跑的程序，它怎么可能知道我在哪？
为了解决这个问题，OpenClaw 把自己拆分成了三个主要部分：

### 第一部分：Gateway（大脑网关）
我们在电脑上启动的 `openclaw daemon` 服务，就是整个系统的**超级大脑**。
- 它负责连接飞书、Telegram。
- 它负责存储所有的对话记录（Session）、系统提示词。
- 它负责调用大模型的 API 接口（如智谱、ChatGPT）。

### 第二部分：Node（神经末梢/客户端设备）
光有大脑还不够，大模型需要手和眼睛！
**“Node（节点）”**，指的就是**安装了 OpenClaw 客户端 App 的手机（iOS/Android）和电脑（Mac/Windows）**。

在源码和文档（如 `docs/zh-CN/nodes/location-command.md`）中，整个交互流程是这样的：
1. **配对建联**：你的手机 App（Node）通过 WebSocket 长连接，与你的中央电脑（Gateway）连在了一起。
2. **物理外挂**：手机拥有大量电脑没有的传感器硬件，比如：**前置后置摄像头（Camera）、麦克风设备、GPS 芯片（Location）**。
3. **获取位置**：当你在飞书里对大模型说：“给我推荐一下我现在位置附近的餐馆”，大模型并不是自己去定位！
   - 大模型调用了一个特殊的内部 Tool（`location_get`）。
   - Gateway（大脑）接到指令后，通过 WebSocket **向你的手机 App 发送一条 RPC 内部指令 `"command": "location.get"`**。
   - 你的手机 App 弹出一个原生操作系统的确认框：*“OpenClaw 请求获取位置”*。
   - 在你允许后，你的手机硬件读取到真实的 GPS 经纬度，并顺着 WebSocket 传回给大脑 Gateway。
   - 大模型拿到了地理坐标，为你推荐餐馆！

同样的原理，大模型可以通过 Node 节点体系，控制你的手机前置摄像头自动拍一张照，或者自动开始在手机上录屏。

### 第三部分：Web System（视觉面板与控制台）
你提到的“提供的 web 系统”主要承担两个作用：
1. **控制台 UI**：由于 OpenClaw 是一个非常复杂的分布式系统（要连接各种 LLM，要配对多台手机和电脑 Node），它在本地开放了一个供你进行可视化管理的 React 网页（源码位于 `ui/` 目录下）。在这里，你可以像配置路由器一样管理各种硬件权限和模型。
2. **Canvas 投射面板**：结合 Node 体系，Web 系统还能充当大模型的“画板”（Canvas）。大模型可以通过命令 `canvas.navigate`，直接在你的手机屏幕上弹出并渲染一个网页（比如直接给你渲染一个互动的天气图表）。

**小结：**
在 OpenClaw 中，**Gateway（网关/服务）**是运筹帷幄的大脑，**Web 系统**是给大模型展示交互界面和给你配置后台的面板，而**Node（手机等设备）**则是大模型的千里眼和顺风耳。大模型之所以能获取位置，是因为你的手机心甘情愿地成为了这个 AI 帝国的“智能 IoT 设备节点”！

---

## 11. 👨‍💻 “我是谁，你是谁”：从用户的视角彻底理解 OpenClaw 三位一体

你在问题里的直觉非常敏锐，而且问到了一个超级核心的点：“这个节点其实是给我这个主人用的吧？Agent 本身不可能有个手机去溜达吧？”

这就引出了 OpenClaw 最精妙的用户级三位一体架构（Trinity）：**Channel（通道）、Agent（智能体）与 Node（节点）**。
我们可以用一个简单粗暴的比喻来对应这三个概念：**嘴巴/耳朵（通道）、不同岗位的打工人（智能体）、打工人的工具箱（节点）**。

### 🔈 1. Channel（通道）：我们用什么说话？
* **直观理解**：Channel 就是你和 Agent 沟通的**即时通讯软件**。
* **OpenClaw 支持哪些？** 除了你提到的 **Feishu（飞书）、Web 端控制台、CLI（命令行终端）**之外，阅读源码还会发现它完整支持了当今海外主流的所有聊天软件：**Telegram、Discord、Slack、WhatsApp、Line，甚至还支持苹果全家桶的 iMessage！**
* **用户视角**：你每天只要掏出手机打开飞书发消息，或者打开电脑聊 Telegram，你就是在通过不同的 Channel 给后端的大脑发指令。它彻底打破了“使用 AI 必须要打开网页浏览器”的束缚。

### 🧠 2. Agent（智能体）：你在跟谁说话？
* **直观理解**：Agent 就是被 Gateway 分配了不同人设、不同底层大模型、不同工具箱的**“数字员工”**。
* **多智能体（Multi-Agent）**：是的，正因为 OpenClaw 是一个网关底座，你完全可以在 `openclaw.json` 里配置多个 Agent。
  - 你可以配置一个名为 `@coder` 的 Agent（背后挂载 Claude-3-5，赋予 Bash 和文件读写权限，专职敲代码）。
  - 你还可以配置一个名为 `@secretary` 的 Agent（背后挂载最聪明的模型，只赋能日历、发邮件权限，专职当贴身秘书）。
* **用户视角**：你在同一个飞书群里，喊不同的名字（或者配置不同 Channel 绑不同的 Agent），就是在唤醒不同岗位的牛马员工。

### 📱 3. Node（节点）：是谁在替 AI “长眼睛”和“跑腿”？
* **你的理解完全正确！** Node **就是你（主人）的私人设备（手机、MacBook 等）！**
* **为什么要叫 Node？** 因为 AI 是一段被困在服务器暗无天日机房里的代码（你可以想象黑客帝国里的 Matrix母体系统）。**大模型就像是个长着超级大脑却全身瘫痪的高智商外星人，没有手没有脚，也没有手机，它根本出不了门！**
* **Node 就是你借给 AI 的感官假肢**：
   - 如果你想让大模型知道你此刻在哪，光在云端算力中心是无法做到的。你需要用你随身携带的手机（Node 设备），在后台静静地把自己当前的 GPS 地址（眼睛/触觉）授权上报给大模型。
   - 如果遇到 macOS 的疑难杂症，AI 会向你的 MacBook（Node 设备）发送一条执行 `System.Run` 的诊断指令。你的笔记本在这里成为了替大模型执行命令的“手”。

### 👑 终极架构画面（你是唯一的上帝）：
当你（用户对象/Master）今天拿着一台带摄像头的安卓手机走在外滩，并在飞书上敲下一句指令时，整个 OpenClaw 庞大帝国的齿轮是这样转动的：
1. **你（主人）** -> 打开飞书 **（Channel / 嘴巴）** 说：“我前面这个建筑是什么？”
2. 远在北京机房的服务器 **Gateway（中央处理器）** 接收到了你的飞书消息。
3. Gateway 把这句话抛给了最懂分析图像的 **Agent（大模型脑子）**。
4. Agent 脑子一转，觉得：“要回答这个问题我得知道位置还得有照片啊！” 于是它请求调用 `location_get` 和 `camera_snap` 工具。
5. Gateway 立刻通过 WebSocket 指令下发给你手里这台连着网的手机 **（这台手机就是 Node / 眼睛与脚）**。
6. 你的手机“Node”在后台获取了上海外滩的 GPS 并拍下了一张东方明珠的照片，原路闪电传回给 Gateway，再交回给 Agent。
7. Agent 看完图和坐标，得出结论：“这是东方明珠电视塔啊！” 随后通过飞书 **Channel** 回复给你。

在这个体系下，**所有的大型底层模型（Agent）都在天上的云端，而所有的数据抓取、物理感知甚至终端行动（Node）都在你的手边。你，就是那个调度天上诸神为你凡间琐事效力的指挥官！**

---

## 12. ⚙️ 一切皆可配：控制台 UI 覆盖了所有配置吗？

你可能会关心，作为这样一个拥有海量工具、多模型路由、多 Agent 还有各种平台 Channel 的庞大框架，我是不是需要天天去对着一个黑漆漆的配置文件改代码？控制台的 Web 页面能搞定一切吗？

**结论是：是的！不仅能搞定，而且 Web 端控制台提供了 100% 的配置覆盖率！**

### 为什么能做到 100% 覆盖？（源码揭秘）
在分析源码后我发现，OpenClaw 用了一个非常聪明的“前端动态表单（Dynamic Schema Form）”技术：
1. **统一的后端校验层设计**：在后端的 `src/config/zod-schema.ts` 中，OpenClaw 把**所有的配置项**抽象成了一套极度严谨的 JSON 结构规范（Zod Schema），并给每个字段写好了注释。
2. **前端的动态渲染**：Web 端的设置页面（源码在 `ui/src/ui/views/config.ts` 中）**并不是前端程序员手写出来的页面**！Web 页面会在打开的瞬间，向后端请求那个巨大的 JSON Schema 结构体。随后，React 前端会自动根据 Schema，**动态生成**所有的配置表单（下拉框、开关、输入框）。
3. **双擎模式**：Web 界面上不仅有美观易用的“Form（填表）”模式，还内置了“Raw（原始形态 JSON5 代码）”编辑模式。即使是非常冷门的系统高级参数也能在面板里修改。

这种设计意味着：只要后端加了一个新功能或新开关，控制台的 Web UI 不需要改动任何代码，第二天你刷新页面就会发现多出一个配置按钮！

### 完整解析：OpenClaw 到底有哪些顶级配置门类？
根据系统源码（`ui/src/ui/views/config.ts` 的 Section 定义），你在控制台上几乎可以定制这个 AI 帝国的每一个细胞：

#### 1. 核心 AI 行为（大脑配置）
- **Agents (多智能体配置)**：**这是整个系统的灵魂。** 你可以在这里新建、编辑你所有的智能体队伍。包括分配大模型（给编码员配 Claude，给分析师配 GPT-4o），调整人格预设，为不同智能体搭配不同的系统提示词和调用工具（比如不准某个 Agent 动你本地文件系统）。
- **Models (模型配置)**：填入各种大模型厂商（比如你在飞书配置里面用到的智谱，或者 OpenAI、Anthropic）的 API Key。并且定义多模型路由：谁扛鼎做逻辑推理（Default），谁偷偷躲在后台做文字总结压缩（Summary），谁专门看图片（Vision）。

#### 2. 通讯与感知网络（四肢配置）
- **Channels (通道配置)**：把你搭建好的智能体队伍，注入到飞书（Feishu）、Telegram、Discord、Slack 等各大聊天软件里，并管理各个平台的 Webhook 通信密钥。你可以设定只有“主人”的账号才能唤醒它。
- **Tools (工具配置)**：全维度管理 AI 能够使用的原子工具！包括为浏览器自动化配置安全策略、为 Bash 终端配置沙盒白名单（防误删跑路）、为系统级别的操作设定免密边界。
- **Skills (技能库)**：给你的 Agent 配置特定场景下的集成技能模块。

#### 3. 运维与记忆管理（系统底座）
- **Gateway (大脑网关)**：配置这台核心控制服务器自己的安全认证、监听端口、绑定地址。这里是所有通讯的总电闸。
正是在这套通过 Web UI **100%可视化、动态下发**的全量配置能力的加持下，你完全不必每次进入命令行跟黑乎乎的代码肉搏。你只需在任何一台设备的浏览器里打开管理面板，便可以轻松配置、调用、指挥属于你自己的多 Agent 军团！

---

## 13. 🛠️ 装备库大揭秘：工具、技能与外部插件

OpenClaw 作为一个 Agent Framework，如果大模型是大脑，那么“工具”就是它的手脚。为了适应不同复杂度和安全级别的场景，OpenClaw 将给 AI 赋能的机制分为了三个等级：**内置工具 (Tools)、技能包 (Skills) 以及 深入内存的插件 (Plugins)**。

### 1. 内置工具 (Tools)：系统原生的超级能力
Tools 是 OpenClaw 核心代码里用 TypeScript/网关级别原生写死、提供**最高权限、强类型约束**的底层接口。它们不需要通过命令行转译，执行效率极高。
- 包括不仅限于：`browser`（操作专用的无头浏览器）、`exec`/`process`（终端命令沙盒执行）、`canvas`（前端 UI 绘画与渲染）、`nodes`（上文提到的控制你私人手机/电脑）、`message`（夸平台的即时通讯分发）、`web_search` 和 `image`（视觉大模型调用）。
- **特点**：在 `openclaw.json` 里受非常严格的 `allow/deny`（白名单/黑名单）控制。你可以给某个做客服的 Agent 只配一个 `message` 工具，而给做后台开发的 Agent 配置 `exec` 终端工具。

### 2. 技能库 (Skills)：给 Agent 的“SOP 说明书”
如果你有一个顺手的外部命令行软件（比如你想让 AI 用 `ffmpeg` 剪视频），你不需要去改 OpenClaw 源码。你可以直接用 **Skills**。
- **什么是 Skill？** 它其实兼容了开源社区的 [AgentSkills 标准](https://agentskills.io)。一个 Skill 就是一个文件夹，里面有一个 `SKILL.md` 的 Markdown 文件。
- **原理**：在这个 Markdown 里，你会告诉 Agent：“如果你想获取天气，请运行 `curl wttr.in`”。Agent 看到这个说明书（Skill），就会去调用内置的 `exec` 工具执行这行代码。
- **如何安装**：OpenClaw 内置了极多第三方开发者写的官方技能（在 `~/.openclaw/skills` 下），比如控制 Notion、控制 1Password 等共 52 种。你可以直接通过命令 `clawhub install <skill-slug>` 从云端技能商店下载别的大神写好的说明书。

### 3. TypeScript 插件 (Plugins)：原生级扩展
如果你需要极其深度的集成（比如你要接入一个新的聊天平台、要注册一个新的本地 HTTP 接口），那就需要写 Plugin。
- 它是能在 Gateway（网关主控端）**同进程内运行的高优代码**。
- `plugins.entries` 配置能在 Web 端直接热重载。

### 🚨 高级玩家必备：我怎么接入外部第三方工具？(MCP 支持)
随着 Anthropic 主推的 **MCP（Model Context Protocol / 模型上下文协议）** 越来越火，很多开发者在问 OpenClaw 能不能直接用海量的各种 MCP Server。
- **答案是能用，但是是以“桥接（Bridge）”的方式**。
- 根据查阅 `VISION.md` 原则文档，OpenClaw 的架构师认为原生的 MCP 接入会影响主网关系统的安全和稳定性，因此他们官方推荐使用开源项目 **`mcporter`** (https://github.com/steipete/mcporter) 作为中介。
- **方案**：你可以把 MCP server 挂在 `mcporter` 这个工具上，OpenClaw 通过调用 `mcporter` 的原生连接（比如在 Memory 管理模块里就深度集成了 `qmd-manager` 与 `mcporter` 的对话），从而间接获得访问全网开源 MCP 工具库的能力。这种“物理隔离”也是出于安全考量的极佳设计！

---

## 14. 🧠 核心揭秘：ACP 协议与不同后端架构的控制力

很多同学好奇，OpenClaw 既然可以接入 Claude Code、Codex 这类强大的闭源/外部 Coding Agent，它在底层到底是怎么和它们交互的？源码里提到的 "ACP"、"CLI 后端"、"Embedded 后端" 究竟有什么区别？通过深挖源码（如 `docs/tools/acp-agents.md`、`docs/gateway/cli-backends.md` 以及 `src/acp/` 目录），我们可以理清这三者的分工与 OpenClaw 对它们的控制权。

### 1. Embedded Pi Backend (内嵌原生后端)：100% 绝对控制权
这是 OpenClaw 的 **默认核心引擎**。它直接将开源的 `pi-coding-agent` 作为库导入，在 Node.js 同进程内运行。
- **运行模式**：原生子智能体 (Sub-agent)。
- **控制程度（极高）**：OpenClaw 对它拥有“上帝视角”。由于运行在同一内存空间，OpenClaw 可以：
  1. 动态拦截和重写它的 System Prompt。
  2. 精确管控每一个工具（Tools）的调用，甚至是文件读写层面的沙盒校验。
  3. 精细化管理它的上下文记忆矩阵（触发精密的 Token 压缩机制）。
- **适用场景**：所有常规对话、高度需要安全控制和多 Agent 协同的编程任务。

### 2. CLI Backend (命令行后端)：只进不出的“盲盒打字机”
源码中明确指出，CLI Backend 被设计为一种 **Text-only Fallback（纯文本兜底方案）**。当你配置的 API Key 挂了或者服务商宕机时，OpenClaw 可以调用你本地安装的终端命令（比如 `claude` CLI 或者 `codex` CLI）。
- **运行模式**：纯文本的命令行传参（`text in → text out`）。
- **控制程度（极低）**：OpenClaw 仅仅是把你的问题拼接成字符串，通过命令行参数塞给外部程序，然后死等它输出文本。
  - **失去工具能力**：在 CLI 后端模式下，**OpenClaw 会强制禁用所有工具调用路由**（"Tools are disabled"）。你不能指望 OpenClaw 监控 CLI 中途调用了什么本地命令，它就只被当做一个“能生成下一段文本的高级模型接口”。
- **适用场景**：作为大模型 API 断网时的最后一道防线，不适合用来执行复杂的自动化代码特工任务。

### 3. ACP Protocol (Agent Client Protocol)：外包团队对接局
前面提到，CLI 后端无法发挥 Claude Code 这种外部特工的真正实力，因为 OpenClaw 看不到它的思考过程且禁用了工具代理。那如何优雅地使用 Claude Code 和 Codex 呢？答案就是源码中重点集成的 **ACP 协议**（引用包名：`@agentclientprotocol/sdk`）。
- **什么是 ACP？** 这是一个旨在标准化 IDE（如 Cursor、Zed）与代码智能体（如 Claude Code、OpenCode 等）之间通信的开源协议。
- **OpenClaw 如何使用它？** 
  - OpenClaw 内置了专门的 ACP 运行时插件（通过利用外部的 `acpx` 桥接后端）。你可以直接在跨平台聊天框输入 `/acp spawn claude` 或 `/acp spawn codex` 命令。
  - 此时，OpenClaw 会以 **ACP 客户端** 的高级身份，把 Claude Code 等唤起为一个完全独立的高级进程，并通过一条标准化数据链路与它对话。
- **控制程度（中等：项目经理式协作）**：
  - OpenClaw 就像一个“项目合伙人”，它不干涉 Claude Code（外部团队）具体是用什么私有工具读写代码的，也不管它内部是怎么思考的（闭源能力）。对方拥有自己的“自由活动权”。
  - 但 OpenClaw 可以通过 ACP 协议对它进行 **状态管理**：你可以发送指示（Steer）、取消当前回合（Cancel）、强行中断会话（Close），或者获取对方的当前状态（Status）。外包团队自行干完活后，会把结果经过 ACP 汇集到主网关，再透过飞书等渠道无缝发到你的手机上。
- **适用场景**：你想**满血利用** Claude Code 等顶级闭源代理原生极其强大的文件重构、自驱动编码能力，同时又想享受 OpenClaw 提供的跨多端平台、记忆追踪、远程挂机等宏观优势。

**总结**：如果你要安全和自底向上深度整合，用默认的 Embedded 模式；如果你只是断网想让备胎大模型对付一下日常问答，用 CLI 后端；如果你想白嫖闭源专属的超强 Agent 能力并把它变成自己在外随时可调用的数字特工，用基于 ACP 协议的调用。

---

## 15. 🎮 实战指南：三大后端的配置、使用与“灵魂”差异

你可能会问：既然 CLI 后端和 ACP 外包出去了，那原来我在 OpenClaw 里面精心配置的 **“灵魂（System Prompt 人设规则）”** 和 **“记忆（会话历史、长期检索）”** 还会继承过去吗？

以下是这三种模式的**具体配置方式**和关于**灵魂与记忆归属**的通俗总结：

### 1. Embedded Pi Backend (内嵌原生模式 - 默认满血版)

*   **它的灵魂/记忆**：**满血拥有**。它不仅绝对服从你在 `openclaw.json` 里写的上万字的 System Prompt，还能无缝享受 OpenClaw 首创的“会话总结压缩引擎（Compaction）”以及可选的 LanceDB 向量记忆库。
*   **如何配置**：这是系统默认状态。你只需在 `agents.defaults.model.primary` 中填入你的大模型（如 `anthropic/claude-3-5-sonnet`）。如果你想有多个专项特工，在 `agents.list` 数组里增加带有专属提示词的 Agent 即可。
*   **如何使用**：什么都不用管。直接在聊天框发消息、发起普通 Thread 对话，或者带着文件路径发送，它就自动在后台原生运转。

### 2. CLI Backend (命令行兜底模式 - 本地打字机)

*   **它的灵魂/记忆**：**灵魂残留，高级记忆丧失**。
    *   **灵魂 (Prompt)**：OpenClaw 非常贴心地做了一个“翻译转换”，它在背后启动你的本地命令行大模型时，会尽可能把原版 Agent 的 System Prompt 作为 `stdin` 或 `--system` 参数一并塞给它。所以它勉强“知道自己是谁”。
    *   **记忆 (Memory)**：它只能依赖命令行程序自己提供的 `--session-id` 参数来维持最基本的多轮历史上下文。OpenClaw 的**精密记忆压缩和主动长期检索对它无效**（因为工具链被禁用了）。
*   **如何配置**：
    在 `openclaw.json` 或 Web 面板中添加一个 `cliBackends` 定义（比如指向本地安装的 Claude Code），然后把它加进你的“失败回退列表（Fallbacks）”。
    ```json5
    agents: {
      defaults: {
        model: {
          primary: "anthropic/claude-opus-4-6",
          // 当主力 API 宕机时，按顺序退役到被阉割工具的主力命令行：
          fallbacks: ["claude-cli/opus-4.6"] 
        },
        cliBackends: {
          "claude-cli": {
            command: "/opt/homebrew/bin/claude"
          }
        }
      }
    }
    ```
*   **如何使用**：不需要用户手动操作。当你发送一条消息，如果首选模型超时或报错，OpenClaw 会静默接管，在后端直接调起本地命令执行，把打印在屏幕上的文字抽出来返回给你。

### 3. ACP Protocol (外包特工模式 - 本机高薪团队)

*   **它的灵魂/记忆**：**拥有自己完全不可侵犯的专属独立灵魂与记忆**。
    *   既然你都花大功夫通过 ACP 协议聘请了诸如 **Claude Code** 或 **Codex** 这样的外部“顶级大牛”，OpenClaw 就会尊重专家的独立性。
    *   **灵魂/记忆**：OpenClaw **不会**向它注入自己的 System Prompt 或是上下文压缩。外包 Agent 凭借它私有代码自己去管理上下文和系统指令（比如 Claude Code 就是个独立黑盒，有自己读取本地 Git Repo、总结思考的逻辑）。
*   **如何配置**：
    你需要通过插件开启底层的 ACP 桥接器支持。
    ```json5
    acp: {
      enabled: true,
      dispatch: { enabled: true },
      allowedAgents: ["claude", "codex"]
    }
    ```
    并且你可以通过 `openclaw plugins install @openclaw/acpx` 来确保核心通信器可用。
*   **如何使用**：不走常规的聊天通道。你需要使用 **`/acp` 唤醒指令族**。
    *   **雇佣/进场**：`/acp spawn codex --mode persistent`（告诉 OpenClaw：给我把 codex 特工拽过来，建立一个长期的任务线程）。
    *   **视察/督促**：`/acp steer 优先修复红色的报错`（在不打破它上下文逻辑的情况下，中途给它下达干涉指令）。
    *   **结账/走人**：`/acp close`（彻底关闭此特工的进程连接）。

---

## 16. 💡 进阶解惑：CLI 真的一无是处吗？ACP 和 Subagent 有啥区别？

在彻底深研源码和官方 QA 原则归档之后，我们针对大家最常见的两个架构疑问进行解答：

### 疑问一：如果大模型断网了，那接了 API 的 CLI (比如 Claude Code) 也是抓瞎。CLI 后端还有啥用？

这个直觉很敏锐！的确，如果你在 `cliBackends` 里配的是 `claude` (Anthropic API)，断网瞬间两个都会挂。**但 CLI 模式的终极奥义在于它的“无门槛外部包容性”。**

参考 `docs/zh-CN/help/faq.md` 中对于断网保护的官方建议：
*   **真正的物理断网兜底：本地大模型**。
*   你可以将 CLI Backend 指向诸如 **Ollama** 或 **llama.cpp** 的本地终端命令行调用（例如 `command: "ollama", args: ["run", "llama3"]`，或者指向使用 LM Studio 的本地客户端脚本）。
*   它的价值在于：OpenClaw 作为一个复杂的网关代理，万一它的 Node.js 网络请求库因为 TLS 握手、代理配置错误或者 DNS 问题**无法请求外网**时，它可以无缝直接切给本地磁盘上的命令程序。
*   所以，CLI 后端不是让你再去连一个依赖网络的外部特工，而是让你在拔掉网线时，能自动唤醒你主机显卡里跑着的**纯本地弱智版语言模型**，保证你的聊天助手“永远有声出”。

### 疑问二：`/acp spawn` 和 `/subagents spawn` 感觉很像啊，有什么区别？

在源码 `src/routing/session-key.ts` 和 `docs/tools/acp-agents.md` 中，有着极其严格的界定标准。它们看起来都是“叫个小弟来干活”，但**底层架构截然不同**。

| 对比维度 | Subagent 模式 (如 `/subagents spawn`、`sessions_spawn`) | ACP 模式 (如 `/acp spawn`) |
| :--- | :--- | :--- |
| **生世/血统** | **内生的细胞分裂**。OpenClaw 在相同的 Node.js 进程内存中，用自家的开源 `pi-coding-agent` 生成了一个沙盒化的子运行环境。 | **外包的独立法人**。OpenClaw 通过标准的跨进程协议，去操作系统里强行拉起了一个完全属于别家公司（比如 Claude Code）的高级进程。 |
| **会话 Key 标识** | `agent:<agentId>:subagent:<uuid>`（在路由键上它打着明晃晃的 subagent 烙印，最高能嵌套出很多层） | `agent:<agentId>:acp:<uuid>`（在路由分发时被拦截器分发至专属的 ACP Plugin 处理） |
| **心智/工具控制** | 绝对掌控。主程序决定小弟能不能用文件读写、能不能发 HTTP 请求。深度管控工具配置。 | 黑盒盲转。主程序只能看着对方，不知道对方用了什么内部的闭源绝技，只是负责把最后结果通过协议拿过来。 |
| **底层调用点** | 同样基于工具函数 `sessions_spawn`，但隐藏参数 `runtime: "subagent"`（这是默认值）。 | 基于工具函数 `sessions_spawn`，但强制传入特定的隐藏参数 `runtime: "acp"`。 |

**通俗打比方**：
用 **Subagent（子特工）**，就像是你开了一家公司，遇到大活儿，你让公司 HR 临时给你再**招个新员工**，用的电脑、遵守的规章制度全是你们公司的，随时能查他监控。
用 **ACP**，就像你遇到硬茬儿自己搞不定，你**向大厂的高级技术顾问中心（IDE 协议池）发包**，请个身经百战的闭源老特工来帮你解决，你只负责验收他完工丢出来的代码。

---

## 17. 🕰️ 代码考古：OpenClaw 的进化时间线与演进史

为了让你更立体地理解 OpenClaw 是怎么一步步变成今天这个庞然大物的，我在本地执行了 `git log --reverse --tags`，翻阅了项目最底层的提交记录。这是一部非常精彩的框架演化史！

### 阶段一：起源 —— 简陋的短信机器人 (v0.1.x 时代，2025 年 11 月)
*   **诞生时刻** (`f6dd362d3 Initial commit`)：项目最开始甚至不叫 OpenClaw，只是一个非常简单的 CLI 工具，叫 `warelay`。
*   **最初级的功能**：早期的代码几乎全是围绕 `Twilio Webhook` 和 `Tailscale Funnel` 写的（比如提交记录：`Add warelay CLI with Twilio webhook support`）。
*   **当时的形态**：作者最初的需求很简单：想通过手机发短信（借助 Twilio API 服务）来和一个跑在自己电脑黑框框里的大语言模型聊天。为了让手机的短信 Webhook 能打通家里的电脑，他深度集成了 Tailscale 穿透技术。

### 阶段二：重构与安全加固 (v1.x 时代，2025 年 11 月末 - 12 月初)
*   仅仅过了几天，框架开始支持处理复杂结构（如图片、录音等文件）。
*   **核心变更点**：
    *   增加了针对大模型的“自定义提示词（Claude Prompt）”和 Auto-reply (超时托底回复) 的轮询机制。
    *   引入了严重的安全补丁（如拦截文件穿透攻击：`Fix path traversal vulnerability in media server` 以及 `block symlink traversal`）。
    *   项目有了第一个正式发布的里程碑：**v1.0.4**。

### 阶段三：野心勃勃的架构大清洗 (v2.0.0-beta 系列，2025 年 12 月中旬 - 2026 年初)
*   **RPC 重构介入** (`origin/rpc-refactor`)：这是项目从“单机玩具”走向“多端协同架构”的转折点。代码中开始引入了原生的 RPC 通信。
*   **跨端能力开始爆发**：
    *   开发者们引入了专属的 iOS 设置页面 (`origin/ios/settings-local-ip` / `fix/gateway-ios-client-id`)。
    *   加入了纯给极客用的终端图形界面：TUI (Terminal UI) 版本 (`feat: add tui ui kit`, `overhaul tui controller`)。
*   从此，它有了一个标准的中心网关 (Gateway) 和多个分离的前端（Web、App、终端端）。这段重构过程非常漫长，连续发布了 5 个 beta 版本。

### 阶段四：大一统与日历版本控制 (v2026.x.x 现代版本，2026 年 1 月 - 至今)
*   到 2026 年初，开源社区贡献爆发，项目彻底抛弃了旧的 v2 命名法，改用类似 Ubuntu 的**日历版本控制（Calendar Versioning，如 v2026.1.5）**。
*   **这个阶段疯狂堆料的代表作：**
    1.  **多渠道大融合**：短短一个月内接入了 Slack、Telegram (`feat: telegram-gif-animation`)、Feishu 飞书。特别是在 2026 年 2 月，以 `@kevinWangSheng` 和 `@kcinzgg` 为代表的社区开发者疯狂给飞书贡献代码，支持了代码块映射、飞书文档表单读写、图文混排。
    2.  **万物 Node 节点化**：加入 Android 端节点能力（在 2 月中旬提交的 `feat(android): wire runtime canvas capability refresh` 和 `device diagnostics`）。可以让 Android 手机作为外置摄像头、电量检测器提供给网关使用。
    3.  **大模型生态兼容**：集成了本地 Ollama 的零配置发现、加入了高端的 LanceDB 向量数据库（用于超长期的记忆存储）、完善了 Claude Code 桥接所需的 ACP 协议以及 OpenAI-responses 处理。

**总结演进路线**：
**短信/Twilio 转发器 (v0)** ➔ **本地文件及安全网关 (v1)** ➔ **具有 RPC 能力的主从分离架构 (v2-beta)** ➔ **横跨移动端/PC/十几种办公软件的全平台智能体网关操作系统 (v2026)**。

---

## 18. 🕵️ 深扒黑魔法：OAuth 劫持、合规风险与国产模型（智谱等）的接入配置

在 OpenClaw 的极客玩法中，最让人惊掉下巴的就是**“直接白嫖官方第一方代码助手的 OAuth 登录”**。这到底是黑科技还是灰产违规操作？如果是国产的智谱大模型，没有默认网址怎么配？我们从底层源码为你一一道来。

### 1. OpenAI Codex 网页授权登录：黑魔法还是违规？

如果你在安装向导中选择了 `OpenAI Codex OAuth`，你会发现竟然不用填极其昂贵的 API Key，而是直接弹弹出一个网页让你拿着订阅账号登录，接着 OpenClaw 就能直接跑 GPT 的代码模型了。

*   **它是怎么做到的？**
    查阅源码 `src/commands/openai-codex-oauth.ts`，OpenClaw 实际上是在本地起了一个拦截端口（`localhost:1455`）。它伪装成了 OpenAI Codex 的官方命令行客户端，当用户在网页端授权并回调时，OpenClaw 会截获官方下发的 OAuth Token，并把这个 Token 保存在自己的 `auth.json` 令牌池里。
*   **这是违规的吗？**
    **严格来说，是的。** 在业界这被称为 "Client ID Spoofing"（客户端 ID 欺骗）。你使用了 OpenAI 专门为第一方内部应用颁发的 Client ID 强行接到了第三方开源项目上。
    *   **OpenAI 的态度**：目前睁一只眼闭一只眼，没有进行强力封杀，但一旦发现批量违规滥用，可能随时封禁涉事账号的访问权限。
    *   **局限性**：由于这种 Token 并不是万能的 API 密钥，源码文档（`faq.md`）里也特地警告了：**OAuth 拿到的令牌只有聊天（Chat/Completions）权限**。它**无法**调用 Embeddings 向量化接口，这意味着极其强大的向量记忆搜索根本跑不起来。

### 2. 为什么不支持 Claude Code 的网页一键授权？

细心的用户会发现，向导里不再提供 `claude-cli oauth` 网页登录了，取而代之的是要求用户手动粘贴一个叫 **`setup-token`** 的东西。

*   **背后的博弈**：Anthropic（Claude 母公司）在条款把控上极其严格。在此前的版本中，OpenClaw 也支持类似 OpenAI 的伪装拦截。但 Anthropic 很快开展了大规模封号，明确禁止在任何第三方工具中复用 Claude Pro/Max 的 OAuth 令牌。
*   **OpenClaw 的妥协方案**：源码（`src/commands/onboard.ts`）里有一句注释：“Auth choice `claude-cli` is deprecated; using setup-token flow instead.” OpenClaw 为了规避法律和审查风险，选择了“物理隔离”。它要求用户自己去官方的 Claude 环境执行 `claude setup-token` 拿到令牌字符串，然后再由用户自己“复制粘贴”喂给 OpenClaw。
*   **责任转移**：这样一来，OpenClaw 变成了一个纯接收配置的工具，不参与违规获取的流程，大幅降低了框架被 Anthropic 官方拉黑的风险。

### 3. 接国产模型（如：智谱 Codingplan），网址是系统猜的吗？

很多小白在接入“非御三家”的第三方兼容模型（如国内的智谱大模型、月之暗面 Kimi 等）时会有个错觉：只要名字取对了，OpenClaw 就自动知道去连哪家。

*   **其实并不是自动猜的！绝无魔法！**
    在深挖配置解析模块（`src/config/schema.help.ts`）后，我们发现对于不在原生内置列表里的模型，必须要**手动指定 `baseUrl`**。
*   **正确接入智谱等自定义 OpenAI 兼容协议的方式**：
    由于智谱等大部分国产模型完全兼容 OpenAI API 格式，你只需要在配置文件（或前端 Dashboard 设置）中**强制覆盖**基准链接（Base URL）即可。
    ```json5
    // ~/.openclaw/openclaw.json 中的配置片段
    models: {
      providers: {
        custom_zhipu: {
          // 这里极为关键！必须手动填入模型厂商给你的 Endpoint
          baseUrl: "https://open.bigmodel.cn/api/paas/v4/", 
          apiKey: "你的智谱API_KEY",
          protocol: "openai" // 告诉系统按照 OpenAI 协议去打包发包
        }
      },
      mode: "merge" // 保持和内置提供商的合并共存
    }
    ```
    配置完成后，当你在对话时指名道姓要求调用 `custom_zhipu/glm-4`（如果模型可用），OpenClaw 就会通过这套参数去正确的网址发起网络请求。没有任何自动写死硬编码的魔法。


  ## 🎭 【Chapter 19 (进阶)】OpenAI Codex OAuth 深度揭秘与“双模型双待”配置

你在实战中提到的几个高阶疑问：Codex OAuth 是不是有诸多限制？如何让 GPT-5.2 管聊天，让智谱管记忆（Embeddings）？接下来为你硬核剖析。

### 1. Codex OAuth 的“紧箍咒” (合规与工具限制)
通过 OAuth 白嫖 Codex 的 GPT 模型确实极具性价比，但这并非没有代价。从 OpenClaw 源码级别扒出来的真相揭示了它的局限性：

*   **无法使用内置 Tools (工具剥夺)**：
    OpenClaw 在源码底层为 Codex OAuth 分配了专有的协议类型 `openai-codex-responses`。在这个协议的定义中，为了保持与 Codex CLI 原生网页端对话行为一致（并躲避 OpenAI 复杂的风控检测），**系统会主动移除所有工具调用请求 (Tools)**。
    *也就是：你在配置了 Codex OAuth 后，助手将无法帮你直接运行脚本、写文件或搜网页，它退化成了一个纯粹的“打字机”。*
*   **合规风险 (ToS Violation)**：
    这属于 Client ID 伪造 (Spoofing) 越权调用，OpenAI 完全可以在服务器端轻易阻断这种连接（正如它时不时会让你的 Refresh Token 失效一样）。
    *作为对比，Claude Code 就聪明地绕开了 OAuth，要求用户手动提取 `setup-token` 来避免被精准封控。*
*   **无法使用 Embeddings (向量记忆缺失)**：
    Codex OAuth 给到的权限 Token **只允许调用聊天接口 (Chat/Completions)**，根本就没有给向量接口 (Embeddings) 权限。这就导致你没法使用需要向量数据库支持的长记忆搜索和匹配能力。

### 2. 模型选型与“思考深度” (Reasoning Depth)
好消息是，Codex 支持的优质模型，在 OpenClaw 中均可通过别名映射启用：
*   **理论可用模型**：凡是在官方 Codex 网页版和 CLI 里能选的（目前主要为 `gpt-5.3-codex` 或相关衍生版），在 OpenClaw 均可通过配置使用。如果输入了错误的缩写，OpenClaw 底层的 [resolveModel](file:///d:/code/vb/claw/research/openclaw/src/agents/pi-embedded-runner/model.ts#42-128) 也会尽力帮你匹配到相近的变体。
*   **思考深度配置 (Thinking/Reasoning Level)**：
    完全等同于你看到的 Codex CLI 选项！你可以直接在 [openclaw.json](file:///d:/code/vb/claw/openclaw.json) 里配置它的**思考深度**（低、中、高等级别）。
    只需要在 `agents.defaults` 对象中添加 `thinkingDefault` 属性：
    ```json
    {
      "agents": {
        "defaults": {
          "model": {
            "primary": "openai-codex/gpt-5.3-codex"
          },
          "thinkingDefault": "high"  // 可选值："off", "minimal", "low", "medium", "high", "xhigh"
        }
      }
    }
    ```
    配置完成后，如果是飞书这类聊天端，某些情况下中间的“思考过程”（`<think>...`）会平滑地流式展示出来。如果想临时改写某次对话的深度，可以在飞书里发特定斜杠指令（例如 `/think high`）来当场变更！

### 3. “双模型双待”：GPT-5.2 负责聊天，智谱 (Zhipu) 负责记忆
这是你提出来的绝妙架构，**完全可行！** 此方案能完美弥补 Codex OAuth 没有 Embeddings 的缺陷。

既然 Codex 无法处理长久记忆，我们就把这部分外包给你的智谱 Codingplan。

#### 配置实操 (修改 [openclaw.json](file:///d:/code/vb/claw/openclaw.json))
你需要在配置文件的 `agents.defaults` 中，为 `memorySearch` 单独指定 Embeddings 服务提供商，并将其指向智谱的 API。

```json
{
  "agents": {
    "defaults": {
      "model": {
        "primary": "openai-codex/gpt-5.2-codex"  // 主聊天大脑：使用 Codex 薅羊毛
      },
      "memorySearch": {
        "provider": "openai",                    // 智谱兼容 OpenAI 格式
        "model": "embedding-3",                  // 填入智谱的向量模型名
        "remote": {
          "baseUrl": "https://open.bigmodel.cn/api/paas/v4/embeddings", // 智谱的向量专属路由
          "apiKey": "你的智谱API_KEY"
        },
        "fallback": "local"                      // 万一智谱挂了，还能降级到本地模型
      }
    }
  }
}
```
**配置解析**：
*   **`model.primary`**：日常聊天的入口，跑的是 Codex 薅来的羊毛。
*   **`memorySearch.remote.baseUrl`**：关键魔法。由于 OpenClaw 不认识第三方国内云商的专属网址，你需要**显式地**在这里告诉它去找智谱，而不是傻傻地跑去 OpenAI 官网。

这样操作后，你同时拥有了 GPT-5.2 的聪明才智，又利用智谱解决了大容量记忆数据库的问题！🦀

---

## 👥 【Chapter 20 (底层揭秘)】模型 (`model.primary`) 与 智能体 ([Agent](file:///d:/code/vb/claw/research/pi-mono/packages/agent/src/agent.ts#96-560)) 是什么关系？

正如你敏锐察觉到的，OpenClaw 是一个**完全以智能体 (Agent) 为核心**的框架。这意味着它的大脑（模型）其实是**“寄生”**在各个不同的智能体身上的。

通过查阅底层源码 [src/agents/agent-scope.ts](file:///d:/code/vb/claw/research/openclaw/src/agents/agent-scope.ts) 中的 [resolveAgentEffectiveModelPrimary](file:///d:/code/vb/claw/research/openclaw/src/agents/agent-scope.ts#177-186) 机制，这层关系可以归纳为两句话：

### 1. 为什么配置都在 `agents.defaults` 里？
在大部分小白的 [openclaw.json](file:///d:/code/vb/claw/openclaw.json) 里，只有这一个地方配了模型：
`agents` -> `defaults` -> [model](file:///d:/code/vb/claw/research/openclaw/src/agents/model-selection.ts#36-39) -> `primary`

这个 `defaults` 的本质是：**“当且仅当一个智能体没有自己专属的大脑时，系统默认分发给它的公共大脑”**。
因为系统出厂时会默认给你分配一个叫做 `main`（大管家）的隐形智能体，而这个主助理没有写死任何独立模型，所以它就顺理成章地继承了 `agents.defaults` 里的 `primary` 模型。

### 2. 局部覆写 (Override)：给特定智能体换上自己的脑子
这也是 OpenClaw 发挥终极威力的地方：**模型是可以按 Agent 定制的！**
如果我们在终端敲指令 `openclaw agents add coder` 创建了一个专职写代码的新助手，并且你想让它独立使用 Claude 3.5 敲代码，你完全可以在 [openclaw.json](file:///d:/code/vb/claw/openclaw.json) 的 **`agents.list`** 里单独为它“上脑”：

```json
{
  "agents": {
    "list": [
      {
        "id": "coder",                   // 这个 Agent 的名字
        "model": {
          "primary": "anthropic/claude-3-5-sonnet-20241022"  // 给它专用的模型！不吃大锅饭
        }
      }
    ],
    "defaults": {
      "model": {
        "primary": "openai-codex/gpt-5.3-codex"  // 没设定模型的主力助手 (main) 用的公共脑
      }
    }
  }
}
```

**总结**：
*   `agents.list[...].model` 是小灶（最高优先级）。
*   `agents.defaults.model` 是大锅饭（兜底模型）。
*   所有的模型选择，在源码里最终都会穿透并绑定到某一个具体的 Agent ID 上去执行。

## 🧭 【Chapter 21 (实战)】我有几个智能体？平时怎么切换它俩？

看了上面关于模型和智能体的关系，你一定很好奇：“那我现在的系统里到底装了几个助理？我怎么翻它们的牌子？”

### 1. 我现在有哪些智能体？谁是默认的？
在 OpenClaw 中，你可以随时通过终端指令或者 Web UI 查户口：
在命令行输入：`openclaw agents list`
你会看到类似如下的输出：
```text
Agents:
- main (default)
  Workspace: ~\.openclaw\workspace
  Agent dir: ~\.openclaw\agents\main\agent
  Model: zai/glm-4.7
  Routing: default (no explicit rules)
```
**这就是答案：**
默认情况下，系统出厂**有且仅有一个**智能体，它的代号叫 **`main`**（并且被标记了 [default](file:///d:/code/vb/claw/research/pi-mono/packages/agent/src/agent.ts#28-34)）。如果你没有刻意去创建别的助理，那么你在飞书、Web 端跟它说的每一句话，**全都是这个 `main` 助理在伺候你**。

### 2. 怎么添加专职新助理？
如果你嫌弃 `main` 助理不够专业，想专门弄一个写代码的助理（并给它配上特定的系统词，比如“你是一个傲慢的资深程序员，只写 Python”）：
你可以直接在命令行召唤它：
`openclaw agents add coder`
此时你的花名册上就多了一个叫 `coder` 的打工人。

### 3. 如何选择跟哪一个智能体聊天？
当你的系统里有了多个助理（如 `main` 和 `coder`），你有两种方式翻牌子：

*   **方式一：在对话中“圈”它 (随叫随到)**
    在飞书或者终端里聊天时，直接在输入框使用 `@` 提及特定助理，或者使用斜杠指令（如果信道支持）。比如：
    `@coder 帮我重构一下这段函数`
    系统识别到 `@coder`，就会临时把这句话路由给 `coder` 助理的专属大脑和记忆去处理，而 `main` 就被闲置了。

*   **方式二：绑定专线 (Binding 路由)**
    如果你拉了一个飞书群组，且你希望这个群组里**所有**的聊天默认都交由 `coder` 助理来处理，不需要每次都 `@` 它：
    你可以在 Web UI 的 **Routing / Bindings** 配置里，把那个特定的“飞书群ID” 强制绑定给 `coder`。
    或者在终端里修改路由绑定：`openclaw agents bind coder --target <飞书群号>`

这样一来，你在私人拉的吹水小群里，就是 `main` 在接客；而在严肃的项目代码群里，就是只懂技术的 `coder` 助理在自动答疑了！
