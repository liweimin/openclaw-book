# OpenClaw 内置工具全维度解析 (基于源码剥析)

OpenClaw 并非简单地封装了大模型 API，它的强大来源于其极其丰富的底层工具链。通过对源码 `src/agents/tools/` 及其核心依赖栈的分析，**系统目前内置了不多不少刚好 24 个核心工具**。我将这套复杂的工具网络分为了 **六大核心能力集群**。

这份文档不仅告诉你这 24 个工具“是什么”，还会告诉你大模型在**底层是怎么用它们**的。

---

## 一、📂 核心文件系统集群 (Core File Tools)

这部分能力决定了模型作为一名“程序员”的基础读写能力。其实现在底层依赖了 `@mariozechner/pi-agent-core` 的标准文件系统 API。

- **[read](file:///d:/code/anzhuang/openclaw/src/config/io.ts#1047-1048) (读取文件)**
  - **能力**：精准读取绝对或相对路径的文件内容。
  - **原理**：底层有沙盒逃逸检测（防目录穿越 `../`），并会对过大的文件自动进行行数截断，防止大模型爆显存（Token 耗尽）。
- **[write](file:///d:/code/anzhuang/openclaw/src/config/io.ts#1383-1400) (新建/覆写)**
  - **能力**：直接创建一个新文件或完全覆盖旧文件。
  - **原理**：基于流写入，如果目录不存在会自动级联创建（`mkdir -p`）。
- **`edit` (精确修改)**
  - **能力**：对文件进行局部修改，而不是全量替换。
  - **原理**：底层使用了复杂的文本块定位算法（Block-based replacement）。模型给出“旧片段”和“新片段”，系统会在原文中寻找最匹配的片段并替换。
- **`apply_patch` (多文件补丁)**
  - **能力**：可以一次性对多个文件应用标准的 Diff 补丁。
- **`grep` & `find` & [ls](file:///d:/code/anzhuang/openclaw/src/config/types.gateway.ts#5-17) (局域网雷达)**
  - **原理**：底层并没有粗暴地调用 Shell 脚本，而是使用了 Node.js 原生的 `fs.readdir` 和流式正则过滤来实现跨平台兼容的目录及内容搜索。

---

## 二、🖥️ 算力执行集群 (Execution Tools)

这是 OpenClaw 区分于普通聊天机器人的**命脉**（位于 [bash-tools.exec.ts](file:///d:/code/anzhuang/openclaw/src/agents/bash-tools.exec.ts) 和 [process.ts](file:///d:/code/anzhuang/openclaw/src/agents/bash-tools.process.ts)）。

- **[exec](file:///d:/code/anzhuang/openclaw/src/agents/bash-tools.exec.ts#209-594) (执行 Shell 命令)**
  - **能力**：运行任意 Bash/PowerShell/Python 等终端命令。
  - **底层精粹 (Yield / Background)**：大模型不只能执行“立刻返回”的命令。它可以设置 `background: true` 或者使用 `yieldMs`。比如你想跑一个需要 30 分钟的模型训练：大模型会调用并挂起，让任务进入后台。
  - **沙盒与提权**：如果在 Docker 沙盒模式下，这会被隔离执行。如果宿主机开启了提权 (`elevated`)，执行敏感命令（如 `rm -rf`）时会自动拦截并触发手机端或终端的审批（Ask）。
  - **预编译拦截 (Preflight)**：源码内有一种很有趣的安全机制，它会在执行 `python` 或 `node` 脚本前扫描，看看大模型有没有把 Shell 语法（如 `$VAR`）错误地写进代码里并提前阻断。
- **`process` (后台进程管理)**
  - **能力**：列出、轮询、发送按键输入、终止甚至清理先前的后台 [exec](file:///d:/code/anzhuang/openclaw/src/agents/bash-tools.exec.ts#209-594) 子进程。

---

## 三、🌐 赛博冲浪集群 (Web & Browser Tools)

- **`web_search` (搜索引擎)**
  - **能力**：使用 Brave Search API 进行全局网络搜索。
  - **原理**：大模型给关键词，工具返回精简过的搜索摘要（过滤广告和乱码）。
- **`web_fetch` (网页抓取)**
  - **能力**：读取任意公开网页。
  - **原理**：底层使用 Readability.js 剔除所有的 HTML 标签、CSS 和 JS，只把干净、高信息密度的 Markdown 文本喂给大模型。
- **[browser](file:///d:/code/anzhuang/openclaw/Dockerfile.sandbox-browser) (真机浏览器控制)**
  - **能力**：如果网页需要登录或有反爬策略，模型可以启动真实的 Chrome/Chromium。
  - **原理**：底层基于 Playwright 的 CDP (Chrome DevTools Protocol) 桥接，大模型可以直接操控坐标点击、填写表单、甚至对页面截图来进行多模态分析（如果启用了视觉大模型）。

---

## 四、🤖 Agent 首脑编排集群 (Orchestration Tools)

这部分构成了 OpenClaw 的多 Agent 架构（位于 `sessions-*` 等多个文件）。

- **`sessions_spawn` (派生子代理)**
  - **能力**：遇到大任务，主 Agent 能够在这个节点裂变出一个独立的思维实例来干活。
  - **原理**：可以在独立的进程/沙盒中运行新的大模型 Session。大模型甚至可以选择是否为其开启 ACP（一种高度专业的代码运算流）。
- **`sessions_send` & `subagents` (跨进程对讲机)**
  - **能力**：让主 Agent 和子 Agent 发送数据、纠正方向（steer）或者发现子代理陷入死循环时杀掉它。
- **`sessions_list` & `sessions_history` (记忆与状态读取)**
  - **能力**：列出目前有几个 Session 在跑，或者随时拉取某个子代理的历史聊天记录，防止子代理干了坏事瞒报（“监工模式”）。
- **`session_status` & `agents_list` (自我诊断与身份列表)**
  - **能力**：大模型可以查询自己的“系统指标（Token 花了多少钱、运行了多久使用什么模型）”，也可以使用 `agents_list` 读取你可以生成的所有分身模板。

---

## 五、📱 全域通讯集群 (Channel Messaging)

- **`message` (信道推包)**
  - **能力**：这不限于在终端的黑框框里打字。它可以主动跨信道发送消息。
  - **原理**：在 Telegram、Discord、Slack 等开启下，它可以发文字、可以加内联按钮（Inline Buttons 发起用户投票）、可以回应特定的 Thread（帖子）。
- **`cron` (时序感知)**
  - **能力**：设置定时任务。
  - **原理**：当倒计时结束，系统会伪造一条后台指令塞给大模型（System Event），例如：“这是一个定时倒计时，提醒用户吃药时间到了”，然后大模型会利用 `message` 工具把消息推送给你。

---

## 六、⚙️ 宿主共生集群 (Host & Device Tools)

- **`gateway` (网关自管)**
  - **能力**：重启、拉取新配置甚至更新整个底座代码库。这是大模型自我迭代能力的来源。
- **`nodes` (节点雷达)**
  - **能力**：如果在内网部署了分布式的 OpenClaw，大模型可以通过它操控远端手机的屏幕、拉起摄像头画面。
- **`canvas` (可视化渲染)**
  - **能力**：类似于 Cursor/Claude 的 Artifacts，如果需要展示复杂的图表或 UI 代码，可以直接控制本地的浏览器画框渲染。

---

### 💡 核心设计理念：

从源码结构可以看出，当你在使用 OpenClaw 时，你的大模型不是一个人在战斗。
它手握着一套**微缩的操作系统 (OS)**。它的 [exec](file:///d:/code/anzhuang/openclaw/src/agents/bash-tools.exec.ts#209-594) 就是控制台，`sessions_spawn` 实现了线程裂变，`cron` 掌控了时钟，而 `message` 跨越了设备次元。这也是为什么系统提示词要花长篇大论来教导它如何调遣这支千军万马。
