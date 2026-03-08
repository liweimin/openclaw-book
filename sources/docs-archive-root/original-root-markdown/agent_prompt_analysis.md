# OpenClaw 提示词与上下文组装深度分析

当你与 OpenClaw 的 Agent (包括 main 或其他分身) 聊天时，系统并不仅仅是把你说的话发给大模型（如 GPT-4, Claude），而是会在背后自动拼接一个**超级长且高度定制化**的“系统提示词 (System Prompt)”。

这篇文档基于源码 [src/agents/system-prompt.ts](file:///d:/code/anzhuang/openclaw/src/agents/system-prompt.ts) 及 [workspace.ts](file:///d:/code/anzhuang/openclaw/src/agents/workspace.ts) 的深度分析，详细揭秘了大模型的“潜意识”里究竟被塞进了什么。

---

## 🧩 系统提示词的完整骨架 (按顺序组装)

OpenClaw 的提示词是**模块化**的，它会根据你当前的运行环境（是否在沙盒、是否开启某个工具）动态生成。完整骨架如下：

### 1. 基础人设 (Base Identity)
> *"You are a personal assistant running inside OpenClaw."*
最开头的一句话，确立了它不是一个网页聊天机器人的身份，而是你的专属助理。

### 2. 工具集定义 (Tooling & Tool Call Style)
OpenClaw 并不是让大模型“自由发挥”工具的能力，而是强行规定了能用什么：
- **动态列出全部可用工具**：比如 [read](file:///d:/code/anzhuang/openclaw/src/config/io.ts#640-641), [write](file:///d:/code/anzhuang/openclaw/src/config/io.ts#1036-1278), [exec](file:///d:/code/anzhuang/openclaw/src/agents/bash-tools.exec.ts#209-594), `web_search`, [browser](file:///d:/code/anzhuang/openclaw/Dockerfile.sandbox-browser) 等。如果不选装浏览器环境，提示词里压根就不会出现 [browser](file:///d:/code/anzhuang/openclaw/Dockerfile.sandbox-browser)。
- **强制使用规范**：大模型被告知“如果觉得事情复杂，要学会派生一个子代理（sessions_spawn）”，以及“非必要不废话（直接调工具，而不必描述过程）”。

### 3. 安全与自主性边界 (Safety)
> *"You have no independent goals... Prioritize safety and human oversight..."*
内置了一套类似于 Anthropic 宪法的安全指南，禁止它去追求“权力”，并强制它遵循你的暂停或审核要求。

### 4. 技能与记忆体系 (Skills & Memory Recall)
- **技能手册**：告诉模型必须用特定格式去读取工作区下的 [SKILL.md](file:///d:/code/anzhuang/openclaw/skills/weather/SKILL.md)，而不是瞎猜。
- **记忆检索**：如果它遇到“以前的工作、人的偏好、日期”等问题，提示词会**强制命令**它先去使用 `memory_search` 搜索你的记忆库。

### 5. CLI 快速参考与自我更新 (CLI & Self-Update)
模型被塞入了关于 OpenClaw 本身如何启停的知识（比如 `openclaw gateway restart`），让它懂得帮你 debug 甚至帮你重写 `openclaw.json`。

### 6. 工作区与沙盒感知 (Workspace & Sandbox)
大模型知道自己具体活在哪儿：
- **目录感知**：提示词明确写了当前目录在哪里（比如 `Your working directory is: d:\code\anzhuang\openclaw`）。
- **沙盒警告**：如果开启了 Docker 沙盒模式，提示词里会明确告诉模型：“你正被关在沙盒里，不能乱修改外面的文件”。

### 7. 身份与时间戳 (Identity & Time)
- 它拥有你机器所处时区的**绝对时间**的概念。
- **授权发件人**：即使群聊，它也能通过身份哈希分辨出“谁是真正的主人”。

---

## 📁 关键：动态注入的 Markdown (Project Context)

这是你感知最明显、也是你**最容易修改**的部分。在基础设定的后面，OpenClaw 会硬编码插入你 `.openclaw/workspace` 下的六个核心配置文件的**全文**。

顺序和作用如下：

1. **[AGENTS.md](file:///d:/code/anzhuang/openclaw/AGENTS.md)**: 定义了你有几个分身，不同分身分别擅长写代码、画图还是闲聊。它告诉大模型什么时候该叫谁。
2. **[SOUL.md](file:///C:/Users/levimin/.openclaw/workspace/SOUL.md) (灵魂预设)**: 这是最重要的“性格配置文件”。系统提示词特别强调：**"如果存在 SOUL.md，必须完美扮演里面的角色预设，不能显得生硬死板"。** 你想让它变身赛博女仆还是严格导师，改这里。
3. **[TOOLS.md](file:///C:/Users/levimin/.openclaw/workspace/TOOLS.md)**: 不是用来注册系统底层工具的，而是你（用户）对大模型使用工具的“行为规范（Guidance）”，比如“用搜索工具时，只查官方文档”。
4. **[IDENTITY.md](file:///C:/Users/levimin/.openclaw/workspace/IDENTITY.md)**: 定义了大模型眼中的“自己”，包括它的世界观背景。
5. **[USER.md](file:///C:/Users/levimin/.openclaw/workspace/USER.md)**: 大模型眼中的“你”。写在这里的内容（你的职位、喜好、口头禅），大模型每次聊天都会默读一遍。
6. **[HEARTBEAT.md](file:///C:/Users/levimin/.openclaw/workspace/HEARTBEAT.md)**: 后台静默唤醒的提示词。

> 💡 **进阶玩法**：如果你当前在一个包含某个项目代码的文件夹里，并且把代码通过某些方式作为 Context 传给（附加给）当前 Session，那些文件内容也会被无缝拼接到 `Project Context` 下。

---

## 🔇 静默与交互约定 (Silent Replies & Messaging)

OpenClaw 解决大模型话痨的秘密：
- **隐藏标签**：大模型被告知，如果想回复特定消息，要在开头秘密使用 `[[reply_to_current]]` 这种你看不见的标签。
- **SILENT_REPLY_TOKEN**：当它单纯地执行了命令（比如帮你建了个文件）并且没有额外需要报告的内容时，提示词**要求**它仅仅输出一串秘密字符（对你不可见），从而实现零打扰的操作。
- **心跳回应 (HEARTBEAT_OK)**：当系统偷偷叫醒大模型问“有没有事需要跟主人报告”时，如果没事，模型就会乖乖回复 `HEARTBEAT_OK` 睡觉去了。

---

## ⚙️ 核心模块的动态规则详解

OpenClaw 并不是静态地输出这些段落，而是根据运行时的状态**动态组装**的。以下是你最关心的三个核心模块的具体运作逻辑：

### 1. 🛠️ 工具集 (Tooling) 的动态规则
* **权限过滤**：系统在拼接提示词前，会检查当前会话的权限配置。如果你在 `openclaw.json` 里禁用了某些工具（例如 [browser](file:///d:/code/anzhuang/openclaw/Dockerfile.sandbox-browser)），提示词里不仅不会列出该工具，甚至相关的引导语（如沙盒浏览器说明）也不会写入。
* **特定环境引导**：
  * 如果开启了 ACP（增强计算平台），系统会在提示词里额外加一句：*"For requests like 'do this in codex/claude code/gemini', treat it as ACP harness intent and call `sessions_spawn` with `runtime: "acp"`."*
  * 强制让模型优先使用专门的子代理，而不是自己瞎跑脚本。
* **抑制废话策略**：提示词明确要求大模型：*"Default: do not narrate routine, low-risk tool calls (just call the tool)."* 这就是为什么处理简单命令时，它往往连个“好的”都不说，直接开始执行。

### 2. 🎓 技能 (Skills) 的动态规则
技能（Skill）的设计是为了应对更复杂的任务预设，而不仅仅是简单的系统提示。
* **前置扫描强制性**：如果工作区存在 [SKILL.md](file:///d:/code/anzhuang/openclaw/skills/weather/SKILL.md)，提示词会自动插入一段极其严厉的命令：*"Before replying: scan <available_skills> <description> entries."* 
* **二选一决断**：大模型被告知，如果存在多个看似相关的技能，必须**先**通过 [read](file:///d:/code/anzhuang/openclaw/src/config/io.ts#640-641) 工具读取具体的 `<location>/SKILL.md` 的内容后，才能行动；如果在扫描简介后发现没有对口的技能，就明确禁止瞎读。这极大地减少了模型乱吃 Token 的行为。

### 3. 🧠 记忆 (Memory) 的动态规则
记忆模块并非总是挂载，而是采用“需要时检索”的策略（RAG）。
* **触发条件**：只有当系统检测到当前配置支持且允许了 `memory_search` 和 `memory_get` 工具时，这段提示词才会被注入。
* **检索命令**：*"Before answering anything about prior work, decisions, dates, people, preferences, or todos: run memory_search on MEMORY.md + memory/*.md"*。这意味着一旦你问“上次那个决定为什么做”，它是被**命令捆绑**去搜索记忆库的，如果搜索后依然不知道，也要回答“我查了，没有”。
* **引文模式 (Citations Mode)**：系统甚至会基于配置给大模型下达指令，是否需要在回答中带上形如 `Source: <path#line>` 的后缀，以帮助你验证记忆来源。

### 4. 🗜️ 上下文边界与压缩机制 (Context Compaction)
这是为了防止“聊得越久，大模型越傻/工具越容易报错”而设计的核心防御机制。位于源码的 [compaction-safeguard.ts](file:///d:/code/anzhuang/openclaw/src/agents/pi-extensions/compaction-safeguard.ts) 中。当单次会话的对话轮数或 Token 逼近模型上限时，OpenClaw **不会简单地丢弃**早期对话，也不会因为上下文过载而导致工具解析失败。
* **背景总结与替换**：系统会在后台触发一次专门的摘要大模型请求，把早期的几十轮对话“压缩”成一段高信息密度的前情提要。
* **近期无损保留**：为了保证大模型依然能顺畅执行接下来的动作，最新的 3~12 轮对话（尤其是它刚调用的 Tool Result）会被**原封不动地保留** (`preservedMessages`)。
* **状态继承兜底**：哪怕经过了压缩，系统会强制把最近发生的**“工具报错记录 (Tool Failures)”**和**“文件修改列表 (File Operations)”**单独提取出来，拼接到新上下文中。这意味着哪怕聊了几天几夜，它依然记得“我半小时前修改过哪些文件，上一次运行遇到了什么报错”。

---

## 📝 完整提示词 (System Prompt) 示例解析

为了让你直观感受到大模型背后的“压力”，假设你正在 `D:\Code\项目A` 目录下，并开启了浏览器沙盒，大模型实际接收到的 System Prompt 大致如下：

```text
[身份确立]
You are a personal assistant running inside OpenClaw.

## Tooling
[工具集定义：动态生成的可用手脚列表]
Tool availability (filtered by policy):
Tool names are case-sensitive. Call tools exactly as listed.
- read: Read file contents           <-- 赋予读取文件权限
- write: Create or overwrite files   <-- 赋予新建文件权限
... [此处省略其他工具] ...
- sessions_spawn: Spawn an isolated sub-agent session <-- 允许模型“派生”子代理来处理复杂任务

[工具调用指引：防止模型废话和无限循环]
TOOLS.md does not control tool availability...
For long waits, avoid rapid poll loops...
If a task is more complex or takes longer, spawn a sub-agent...

## Tool Call Style
[潜规则：除非必要，否则直接干活，不要打招呼]
Default: do not narrate routine, low-risk tool calls (just call the tool).
Narrate only when it helps: multi-step work, complex/challenging problems...
Keep narration brief and value-dense...

## Safety
[安全宪法：防止模型“产生自我意识”或乱改底层系统]
You have no independent goals: do not pursue self-preservation, replication...
Prioritize safety and human oversight over completion...

## OpenClaw CLI Quick Reference
[基础知识储备：教大模型如何控制 OpenClaw 服务的启动和重启]
To manage the Gateway daemon service (start/stop/restart):
- openclaw gateway status
- openclaw gateway start
...

## Skills (mandatory)
[技能逻辑：强制要求模型在工作前先去翻看 SKILL.md 文档进行学习]
Before replying: scan <available_skills> <description> entries.
- If exactly one skill clearly applies: read its SKILL.md...
Constraints: never read more than one skill up front.

## Memory Recall
[记忆提取：遇到不懂的旧事，强制命令它去 .openclaw/workspace/memory 找答案]
Before answering anything about prior work...: run memory_search on MEMORY.md + memory/*.md...
Citations: include Source: <path#line>... <-- 强制要求带上记忆来源的出处

## Workspace
[工作空间：明确告诉模型现在是在哪个磁盘路径下工作，防止它跑错地方]
Your working directory is: D:\Code\项目A
Treat this directory as the single global workspace...

## Sandbox
[沙盒状态：如果是沙盒执行模式，会警告模型它被关在笼子里，能力受限]
You are running in a sandboxed runtime (tools execute in Docker).
Sandbox browser: enabled.
Host browser control: blocked.

## Current Date & Time
[时间锚点：提供绝对精准的北京时间，防止大模型出现时间错乱]
Time zone: Asia/Shanghai

## Workspace Files (injected)
[预加载文件：预告下面会有你的个人信息和性格文件注入]
These user-editable files are loaded by OpenClaw...

## Reply Tags
[协议标签：模型回复消息时的秘密前缀，用来支持 Telegram/Discord 的回复功能]
- [[reply_to_current]] replies to the triggering message.

## Messaging
[路由逻辑：教它如何跨平台发送消息]
- Reply in current session → automatically routes to the source channel...
- Cross-session messaging → use sessions_send...
...

# Project Context
[核心注入区：这里是模型“性格”和“常识”的来源]
If SOUL.md is present, embody its persona and tone. Avoid stiff, generic replies...

## D:\Code\项目A\SOUL.md
[这里会动态拼接你的 SOUL.md 原文内容。例如：你是一个幽默的技术大拿。]

## D:\Code\项目A\USER.md
[这里会动态拼接你的 USER.md 原文内容。例如：我的名字叫张三，喜欢用 Node.js。]

## Silent Replies
[防刷屏机制：如果只是简单建了个文件，模型会只回复一个不可见字符来保持安静]
When you have nothing to say, respond with ONLY: ␃

## Heartbeats
[心跳协议：系统后台定时唤醒模型，问它有没有异常。模型此时通常只回答 HEARTBEAT_OK。]
Heartbeat prompt: (configured)
If you receive a heartbeat poll... reply exactly: HEARTBEAT_OK

[运行时元数据：辅助大模型判断当前运行环境的硬件和底层版本]
Runtime: node=v20.x.x | channel=cli | thinking=off
```

---

## 📊 总结

当你在屏幕上只敲下了一句 **“帮我看一下今天的计划”** 时。

OpenClaw 实际上发给 OpenAI/Anthropic 的文本是：
**(几千个单词的系统底层规则) + 你的个人偏好(USER) + 它的性格(SOUL) + 它目前能用的手脚(Tools) + 当前时间 + 沙盒状态 + “帮我看一下今天的计划”**。

这种“重后端注入”的设计，正是 OpenClaw 被称为“Agent（自主体）”而非“Chat（聊天机器）”的核心原因。

