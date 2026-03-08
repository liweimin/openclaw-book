# OpenClaw 完整学习手册（小白版，含源码对比）

> 适用对象：非程序员/刚接触 AI Agent 的同学  
> 写作目标：把 OpenClaw 从“能跑起来”讲到“理解为什么这么设计”  
> 时间快照：截至 **2026-02-27**

---

## 0. 我对你诉求的理解（先确认）

你要的不是一篇“安装教程”，而是一份**完整学习手册**，并且要满足这 6 件事：

1. 讲清 OpenClaw 原理，且小白能看懂。
2. 必须结合 **OpenClaw 源码 + 官方文档**，不是空谈。
3. 必须加入 **Claude Code 对比**（你认为 Claude Code 更偏编码，而 OpenClaw 更偏个人助手）。
4. 必须加入开源代码 Agent 的源码对比，至少 **OpenCode** 和 **Kode**。
5. 必须覆盖 Windows 场景（你指定 Windows 原生，文中会给“原生可用路线 + 官方更推荐路线”）。
6. 还要结合官方最佳实践和 Twitter/X 的最新动态（会标注“官方/镜像来源”与可信度）。

这份文档就是按这个标准写的。

---

## 1. 先用一句话懂 OpenClaw

OpenClaw 不是“只会写代码的 AI”，而是一个**本地可控的 AI 助理中枢**：

- 你通过聊天、CLI、Web 面板给它任务；
- 它把任务交给 Agent（内置 PI 运行时，或 ACP 外部编码 Agent）；
- 它能调用工具（读写文件、执行命令、浏览器、消息渠道、定时任务等）；
- 它把结果回传到你正在使用的渠道（Web/IM/CLI）。

可以把它理解成：

- **Claude Code / OpenCode / Kode**：更像“程序员工作台上的智能开发助手”；
- **OpenClaw**：更像“你个人生活+工作自动化的总控台”，编码只是其中一种能力。

---

## 2. OpenClaw 架构（小白类比版）

### 2.1 三层模型

1. **入口层（你看到的）**
- CLI（`openclaw ...`）
- Dashboard / Control UI
- 各种聊天渠道（WhatsApp/Telegram/Discord/Slack...）

2. **控制层（Gateway）**
- OpenClaw 的“大脑中枢”
- 管会话、鉴权、路由、事件、状态、工具权限
- 官方定义是一个长期运行的 WebSocket 控制平面

3. **执行层（Agent Runtime）**
- 默认是嵌入式 PI 运行时（源自 `pi-mono`）
- 也可通过 ACP 调起外部编码 harness（如 Codex、Claude、OpenCode、Gemini、PI）

### 2.2 最关键的官方架构结论

- 一个 host 上通常一个长期运行 Gateway。
- 客户端与节点通过 WebSocket 接入。
- Agent 运行是“按会话串行”的，避免并发乱写上下文。

参考：
- https://docs.openclaw.ai/concepts/architecture
- https://docs.openclaw.ai/concepts/agent-loop

---

## 3. OpenClaw 的 PI Agent 原理（源码链路）

这是你最关心的点：OpenClaw 里的 Agent 是怎么跑起来的。

### 3.1 调用主链路（从命令到回复）

1. 你触发 `openclaw agent` 或 RPC `agent`  
2. Gateway 先回一个 `accepted`（给你 `runId`），任务异步继续  
3. `agentCommand(...)` 组织参数、会话、模型、路由  
4. `runEmbeddedPiAgent(...)` 进入 PI 嵌入运行时  
5. `createAgentSession(...)` 建立 PI 会话  
6. `subscribeEmbeddedPiSession(...)` 把 PI 事件桥接为 OpenClaw 事件流（assistant/tool/lifecycle）  
7. `agent.wait` 用 `waitForAgentJob(...)` 等 lifecycle end/error

### 3.2 对应源码位置（你可以直接按路径看）

- `research/openclaw/src/commands/agent.ts:223`  
  `agentCommand` 入口
- `research/openclaw/src/agents/pi-embedded-runner/run.ts:192`  
  `runEmbeddedPiAgent`
- `research/openclaw/src/agents/pi-embedded-runner/run/attempt.ts:711`  
  `createAgentSession(...)`
- `research/openclaw/src/agents/pi-embedded-runner/run/attempt.ts:949`  
  `subscribeEmbeddedPiSession(...)`
- `research/openclaw/src/agents/pi-embedded-runner/run/attempt.ts:1200`  
  `activeSession.prompt(...)`
- `research/openclaw/src/agents/pi-tools.ts:182`  
  `createOpenClawCodingTools`（工具总装配）
- `research/openclaw/src/agents/pi-tools.before-tool-call.ts:136`  
  `before_tool_call` hook 接入
- `research/openclaw/src/gateway/server-methods/agent.ts:719`  
  `agent.wait` RPC
- `research/openclaw/src/gateway/server-methods/agent-job.ts:144`  
  `waitForAgentJob(...)`

### 3.3 为什么这套设计重要

- 先 `accepted` 再异步执行：前端不卡死，长任务能跟踪。
- 事件流分为 assistant/tool/lifecycle：便于 UI 展示“正在思考/正在调工具/已完成”。
- 串行 lane：降低会话污染和并发冲突风险。
- PI 嵌入而不是外部黑盒：OpenClaw 能深度定制工具、策略和安全钩子。

参考：
- https://docs.openclaw.ai/concepts/agent-loop
- https://docs.openclaw.ai/concepts/agent
- `research/openclaw/docs/pi.md`

---

## 4. 安装与启动（Windows 重点）

## 4.1 先说结论

- 你指定“Windows 原生”，可以做。
- 但官方明确：**Windows 推荐 WSL2**，原生可能更折腾。

参考：https://docs.openclaw.ai/platforms/windows

## 4.2 前置条件

- Node.js 22+（官方要求）
- PowerShell（Windows）

参考：
- https://docs.openclaw.ai/start/getting-started
- https://docs.openclaw.ai/install/node

## 4.3 路线 A（官方推荐，稳定）WSL2

1. 安装 WSL2
```powershell
wsl --install
```
2. 在 WSL 内安装 OpenClaw 并引导
```bash
openclaw onboard --install-daemon
openclaw gateway status
openclaw dashboard
```

## 4.4 路线 B（你要的 Windows 原生）

1. 安装 OpenClaw
```powershell
iwr -useb https://openclaw.ai/install.ps1 | iex
```
2. 运行引导向导
```powershell
openclaw onboard --install-daemon
```
3. 检查与打开面板
```powershell
openclaw gateway status
openclaw dashboard
```

如果遇到环境问题，优先执行：
```powershell
openclaw doctor
openclaw status --all
```

---

## 5. 配置怎么理解（不是“背参数”）

## 5.1 配置文件在哪里

默认：`~/.openclaw/openclaw.json`（JSON5）

官方说明：配置有严格校验，错了 Gateway 会拒绝启动。

参考：https://docs.openclaw.ai/gateway/configuration

## 5.2 最小可用配置（理解结构）

```json5
{
  agents: { defaults: { workspace: "~/.openclaw/workspace" } },
  channels: { whatsapp: { allowFrom: ["+15555550123"] } },
}
```

你可以这样理解：

- `agents.defaults.workspace`：AI 工作目录
- `channels.*`：消息入口和谁能联系你

## 5.3 三个最常用配置动作

```bash
openclaw config get agents.defaults.workspace
openclaw config set agents.defaults.heartbeat.every "2h"
openclaw config unset tools.web.search.apiKey
```

---

## 6. 日常使用（从“能聊”到“能干活”）

## 6.1 最快第一条消息

```bash
openclaw dashboard
```
浏览器打开控制面板直接聊，不用先配聊天渠道。

## 6.2 CLI 直跑一回合

```bash
openclaw agent --message "帮我整理今天的待办" --thinking medium
```

## 6.3 发消息到渠道

```bash
openclaw message send --target +15555550123 --message "Hello from OpenClaw"
```

## 6.4 多 Agent（工作/生活分离）

```bash
openclaw agents add work
openclaw agents add life
```

然后用 bindings 把不同渠道或账号路由给不同 agent。

---

## 7. 官方最佳实践（你真正该照着做的）

1. **先跑 onboard 向导**，不要手搓全部配置。  
2. **优先用 token/auth + pairing/allowlist**，别一上来全开放。  
3. **改配置后跑 doctor/status**，尽早发现问题。  
4. **把 secrets 从明文迁移到 secret refs**（`openclaw secrets audit/configure/apply/reload`）。  
5. **Windows 尽量上 WSL2**，原生只在你明确知道依赖链时使用。  
6. **高风险场景启用 sandbox 与收敛工具权限**。  

参考：
- https://docs.openclaw.ai/start/wizard
- https://docs.openclaw.ai/gateway/configuration
- https://docs.openclaw.ai/gateway/security
- https://docs.openclaw.ai/gateway/secrets

---

## 8. 与 Claude Code 的原理对比（你关心的核心）

先说边界：Claude Code 是闭源产品，我们只能基于官方文档和行为做架构对比，不能做源码级逐行对比。

## 8.1 定位差异（一句话）

- **Claude Code**：以“编码任务完成”为中心的 agentic coding tool。  
- **OpenClaw**：以“个人助手/消息中枢/自动化协作”为中心，编码能力可通过 PI 或 ACP 外挂进来。

参考：
- https://code.claude.com/docs/en/overview
- https://code.claude.com/docs/en/quickstart

## 8.2 关键能力对照

1. 交互面
- Claude Code：终端/IDE/Web/Desktop，核心仍是编码工作流。
- OpenClaw：CLI + Web + 多 IM 渠道 + 节点设备，偏“随时可达的个人助手”。

2. 任务执行
- Claude Code：直接在代码仓上做修改、命令、提交流程。
- OpenClaw：先过 Gateway 路由，再由 PI runtime 或 ACP harness 执行。

3. 安全模式
- Claude Code：有 permission mode、plan mode 等机制（官方文档可见）。
- OpenClaw：强调 Gateway trust boundary、pairing/allowlist、sandbox、security audit。

4. 多代理协作
- Claude Code：支持 subagents、worktrees 等编码并行。
- OpenClaw：支持 subagent + ACP runtime，能把编码 Agent 当“外部工人”挂接。

---

## 9. OpenClaw vs OpenCode vs Kode（源码级对比）

你要求必须带 OpenCode/Kode 源码，这里给你“工程结构+运行循环”对照。

## 9.1 OpenCode（已归档，迁移到 Crush）

### 项目状态

- `research/opencode/README.md:1` 明确标注已归档，迁移到 Crush。

### 运行主链

- CLI 入口：`research/opencode/cmd/root.go:49` (`RunE`)
- 非交互：`research/opencode/internal/app/app.go:100` (`RunNonInteractive`)
- Agent 主循环：
  - `agent.Run`：`research/opencode/internal/llm/agent/agent.go:198`
  - `processGeneration`：`.../agent.go:233`
  - `streamAndHandleEvents`：`.../agent.go:322`
  - `processEvent`：`.../agent.go:445`
- 工具集：
  - `CoderAgentTools`：`research/opencode/internal/llm/agent/tools.go:14`
  - `TaskAgentTools`：`.../tools.go:43`

### 结论

OpenCode 是典型“代码工作台 Agent”：结构清晰、循环直接，核心是“模型流式输出 + 工具调用 + 回写会话”。

## 9.2 Kode（活跃，Windows 原生友好）

### 项目特性

- README 写明 Windows OOTB（原生二进制优先，Node 回退）：
  - `research/Kode-cli/README.md:21`
  - `research/Kode-cli/README.md:131-132`
- 默认 YOLO 风格权限（需谨慎）：
  - `research/Kode-cli/README.md:48`

### 运行主链

- CLI 入口：`research/Kode-cli/src/entrypoints/cli/runCli.tsx:97`
- 核心递归循环：`research/Kode-cli/src/app/query.ts:522` (`queryCore`)
- 工具执行：`research/Kode-cli/src/app/query.ts:828` (`runToolUse`)
- LLM 调度：`research/Kode-cli/src/services/ai/llm.ts:869` (`queryLLM`)
- 工具注册：`research/Kode-cli/src/tools/index.ts:28` (`getAllTools`)

### 结论

Kode 是“高执行效率导向”的代码 Agent 平台，工具面很全，适合开发者重度终端工作流。

## 9.3 与 OpenClaw 的本质差异

1. **中心对象不同**
- OpenCode/Kode：中心是“代码仓+开发任务”
- OpenClaw：中心是“你这个人 + 多渠道消息 + 自动化生活/工作流”

2. **控制平面不同**
- OpenCode/Kode：更偏单进程 CLI/TUI 模式
- OpenClaw：Gateway 是一层显式控制平面，面向多渠道、多设备、多会话

3. **扩展方式不同**
- OpenCode/Kode：工具扩展偏开发环境
- OpenClaw：除了工具，还有 channel、node、cron、hooks、ACP harness 编排

---

## 10. OpenClaw 与“编程 Agent”如何融合（ACP 是关键）

官方 ACP 文档已经把这件事说透了：OpenClaw 可以把外部编码 harness 当执行器。

关键点（官方文档）：

- ACP 可接 Pi、Claude、Codex、OpenCode、Gemini 等 harness。
- 你可以自然语言说“run this in Codex”，OpenClaw 路由到 ACP runtime。
- ACP 支持 thread-bound 会话和完整生命周期控制。

参考：https://docs.openclaw.ai/tools/acp-agents

这就是你提的核心对比结论：

- Claude Code/OpenCode/Kode：更像“专业施工队”  
- OpenClaw：更像“总包 + 调度中心 + 个人助理”  
- ACP：把“总包”和“施工队”接起来。

---

## 11. 官方动态与 Twitter/X 最新实践（截至 2026-02-27）

> 说明：X 原站抓取常受限，这里使用 @openclaw 的公开镜像页面 + 对应 GitHub Release 做交叉核验。

## 11.1 近两天关注点

从 @openclaw 时间线可见高频主题：

1. **Secrets 管理上线并强化**
- 推出 `openclaw secrets audit/configure/apply/reload`
- 目标是把 API key 从明文配置迁出

2. **ACP 线程化编排加强**
- 明确支持“在线程里跑 Codex/Claude/等 harness”
- 生命周期控制更完整

3. **持续安全硬化**
- 几乎每个 release 都有大量 security hardening/fix

参考：
- TwStalker 时间线（@openclaw）  
  https://www.twstalker.com/openclaw
- Release 2026.2.26  
  https://github.com/openclaw/openclaw/releases/tag/v2026.2.26
- Release 2026.2.24  
  https://github.com/openclaw/openclaw/releases/tag/v2026.2.24

## 11.2 你该怎么用这些“最新实践”

1. 每次升级后先跑 `openclaw doctor` 与 `openclaw security audit`。  
2. 把密钥先治理（secrets），再做大规模自动化。  
3. 把“编码重活”交给 ACP harness（Codex/Claude/OpenCode/Kode），OpenClaw 负责流程和上下文。  
4. 新功能优先在隔离 workspace 或测试 agent 验证，再推到主 agent。

---

## 12. 新手学习路线（由浅入深）

## 第 1 周：会装、会跑、会聊

1. 按本手册第 4 章完成安装。  
2. 跑通 `onboard -> gateway status -> dashboard`。  
3. 完成一次 `openclaw agent --message ...`。

## 第 2 周：会配

1. 看懂 `openclaw.json` 最小配置。  
2. 配一个你常用渠道（比如 Telegram/Discord）。  
3. 学会 `config get/set/unset` 和 `doctor`。

## 第 3 周：懂原理

1. 按第 3 章走一遍源码链路。  
2. 重点读 `agentCommand -> runEmbeddedPiAgent -> createAgentSession -> subscribeEmbeddedPiSession`。

## 第 4 周：会对比与编排

1. 对照第 9 章看 OpenCode/Kode 主循环。  
2. 按第 10 章尝试 ACP 思路（先概念后实操）。  
3. 为“个人助手 + 编码助手协作”设计你的流程模板。

---

## 13. 常见误区（提前避坑）

1. 误区：OpenClaw = 另一个 Claude Code。  
- 正解：OpenClaw 是总控助理平台，编码是其一部分能力。

2. 误区：先把功能全打开再说。  
- 正解：先最小可用，再逐步开权限和工具。

3. 误区：Windows 原生一定最省事。  
- 正解：你可以原生，但官方仍推荐 WSL2 以减少运行时兼容问题。

4. 误区：升级不重要。  
- 正解：OpenClaw 版本节奏快，安全修复密集，升级是必要维护动作。

---

## 14. 参考资料与源码入口

## 14.1 OpenClaw 官方

- Getting Started: https://docs.openclaw.ai/start/getting-started
- Wizard: https://docs.openclaw.ai/start/wizard
- Windows: https://docs.openclaw.ai/platforms/windows
- Gateway Architecture: https://docs.openclaw.ai/concepts/architecture
- Agent Loop: https://docs.openclaw.ai/concepts/agent-loop
- Configuration: https://docs.openclaw.ai/gateway/configuration
- Security: https://docs.openclaw.ai/gateway/security
- Secrets: https://docs.openclaw.ai/gateway/secrets
- ACP Agents: https://docs.openclaw.ai/tools/acp-agents

## 14.2 OpenClaw 源码（本地快照）

- `research/openclaw` (commit: `84a88b2`, 2026-02-27)

## 14.3 Claude Code 官方文档（用于对比）

- Overview: https://code.claude.com/docs/en/overview
- Quickstart: https://code.claude.com/docs/en/quickstart
- Common workflows: https://code.claude.com/docs/en/common-workflows

## 14.4 OpenCode 与 Kode 源码（本地快照）

- OpenCode: `research/opencode` (commit: `73ee493`, README 标注已归档)
- Kode: `research/Kode-cli` (commit: `214c12f`)

## 14.5 Twitter/X 近况（镜像可访问源）

- https://www.twstalker.com/openclaw

> 注：社媒镜像用于“动态趋势”观察；具体改动细节请以官方 release 与 docs 为准。

---

## 15. BashClaw 加入研究：它怎么接 Claude/Codex/API？

你新增的要求非常关键，因为 BashClaw 是“纯 Bash 版 OpenClaw 思路”，非常适合拿来做对照学习。

### 15.1 先说结论（回答你的核心问题）

你问：  
“BashClaw 里对接 codex/claudecode + 支持 API key，这和 OpenClaw 里把 PI 换成 codex 的原理一样吗？”

结论：**有相似点，但不是同一层原理。**

1. 相似点  
- 都能把外部编码 Agent（Claude/Codex）当执行器。  
- 都能走 API key 直连模型（不依赖订阅 CLI）。

2. 不同点  
- **BashClaw**：是“引擎分发层”做切换（`claude`/`builtin`）。  
- **OpenClaw**：是“ACP runtime 协议层”做切换（`runtime: "acp"` + `agentId: codex/claude/pi/...`）。

一句话：  
- BashClaw 更像“应用内 if/else 选引擎”；  
- OpenClaw 更像“控制平面 + 协议后端（ACP）选运行时”。

### 15.2 BashClaw 的真实实现证据（源码）

#### A) 引擎检测有 `codex`，但执行分发目前主要是 `claude` 与 `builtin`

- `research/BashClaw/lib/engine.sh`
  - `engine_detect()`：先看 `claude`，再看 `codex`，否则 `builtin`。  
  - `engine_resolve()`：允许 `builtin|claude|codex|auto`。  
  - `engine_run()`：当前主要分支是 `claude` 和 `builtin`（`codex` 未见独立执行分支）。

这意味着：当前 BashClaw 代码里 `codex` 已被“识别/声明支持”，但在主执行入口上还不是和 `claude` 对称的完整分支。

#### B) Claude Code 是怎么接的

- `research/BashClaw/lib/engine_claude.sh`
  - 明确注释：委托给 Claude Code CLI。  
  - 实际调用：`claude -p ... --output-format json`。  
  - 支持 `--model`、`--max-turns`、`--fallback-model`、`--resume`。  
  - 通过 `--settings` 注入 hooks。  
  - BashClaw 特有工具通过 `bashclaw tool <name>` 桥接给 Claude 的 Bash 工具调用。

这是一种“CLI 子进程委托 + 工具桥接”方案。

#### C) API key 是怎么接的（Builtin）

- `research/BashClaw/lib/api_caller.sh`
  - 统一入口 `agent_call_api()`，按 provider 的 API format 分发：`anthropic/openai/google`。
- `research/BashClaw/lib/models.sh`
  - 数据驱动 provider 配置：`api_key_env`、`base_url`、`api` 格式。  
  - 支持 fallback model、provider registry。
- `research/BashClaw/lib/models.json`
  - 预置 `ANTHROPIC_API_KEY`、`OPENAI_API_KEY` 等 provider key 映射。

所以 BashClaw 的 API 模式本质是：**统一模型路由 + 多协议 HTTP 封装**。

### 15.3 BashClaw 与 OpenClaw（对接 codex 替 PI）是否同原理

#### OpenClaw 的做法（证据）

- `research/openclaw/docs/tools/acp-agents.md`  
  明确 ACP 会话用于 Pi、Claude Code、Codex、OpenCode、Gemini 等 harness。
- `research/openclaw/src/agents/tools/sessions-spawn-tool.ts`  
  `sessions_spawn` 支持 `runtime: "acp"`。
- `research/openclaw/extensions/acpx/index.ts` + `src/service.ts`  
  把 `acpx` 注册成 ACP runtime backend。
- `research/openclaw/extensions/acpx/src/runtime.ts`  
  通过 `acpx <agent> prompt --session ...` 真正驱动 `agentId` 对应 harness。
- `research/openclaw/extensions/acpx/src/config.ts`  
  固定使用插件本地 `acpx` 二进制，并有 pinned version。

#### 对比总结

1. OpenClaw 替换 PI 为 Codex/Claude（在 ACP 路径）  
- 不是改一个 if/else。  
- 是切换到 ACP runtime，让 `acpx` 去驱动对应 harness。

2. BashClaw 替换执行路径  
- 更直接：选 `claude` 引擎或 `builtin` API。  
- 架构更轻，但协议层抽象没有 OpenClaw ACP 这么系统。

---

## 16. 小白也能做：MiniOpenClaw 实现指南（动手版）

你提得非常好。看源码最好的方式，就是自己做一个“缩小版 OpenClaw”。

目标：做一个 **MiniOpenClaw**，只保留 6 个核心能力：

1. 收消息（CLI 输入）  
2. 会话管理（JSONL）  
3. 模型调用（API 模式）  
4. 工具调用（最小 3 个工具）  
5. 任务路由（普通问答 vs 编码任务）  
6. ACP 外部编码会话（可选进阶）

### 16.1 先定范围（避免一上来做太大）

V1（3 天能跑通）：
- CLI 单会话
- OpenAI 兼容 API 调用
- `read_file` / `write_file` / `shell` 三个工具
- 工具调用记录进 JSONL

V2（再加 3-5 天）：
- 多会话（session key）
- Web 简单面板（可选）
- `runtime: local|acp` 路由

V3（进阶）：
- ACP backend（接 codex 或 claude）
- 简单权限策略（allow/deny tools）
- 简单定时提醒（cron）

### 16.2 目录结构（照抄即可）

```text
miniopenclaw/
  src/
    main.ts                # 入口
    gateway.ts             # 收消息 + 路由
    session-store.ts       # JSONL 会话
    model-client.ts        # API 调用封装
    tools/
      index.ts
      read-file.ts
      write-file.ts
      shell.ts
    runtimes/
      local-runtime.ts     # 本地工具循环
      acp-runtime.ts       # 可选：外部 harness
  data/
    sessions/
  .env
  package.json
```

### 16.3 最小执行链（这就是 OpenClaw 原理缩影）

每次用户输入都走这 8 步：

1. 读取输入文本  
2. 解析 `sessionKey`（默认 `agent:main:main`）  
3. 从 `session-store` 载入历史  
4. 拼系统提示词 + 历史消息  
5. 调模型拿回复  
6. 若模型要求工具调用 -> 执行工具 -> 回填结果  
7. 直到 `done`  
8. 把 assistant 输出和工具轨迹写回 JSONL

这就是 OpenClaw `Agent Loop + Tool Loop + Session` 的最小复刻。

### 16.4 配置建议（适合你“打造自己的助手”）

在 `config.json` 里先只做这几个字段：

```json
{
  "defaultRuntime": "local",
  "defaultModel": "gpt-4o-mini",
  "fallbackModels": ["gpt-4o-mini"],
  "toolPolicy": {
    "allow": ["read_file", "write_file", "shell"],
    "deny": []
  },
  "taskRouting": {
    "codingKeywords": ["修复", "重构", "代码", "bug", "PR"]
  }
}
```

### 16.5 多模型多任务（你关心的重点）

做一个最简单规则路由：

1. 普通问答 -> `gpt-4o-mini`（便宜快）  
2. 复杂分析 -> `o3-mini`（推理强）  
3. 编码任务 -> 走 `acp`（codex/claude）

实现上不用复杂 AI 分类器，先关键词规则就够。

### 16.6 “把 PI 换成 Codex/Claude”在 Mini 里怎么做

你可以这样设计运行时接口：

```text
runTurn(input, runtimeType)
  if runtimeType == "local": 走本地 API + 工具循环
  if runtimeType == "acp":   走 acpx/codex/claude CLI 会话
```

这就是 OpenClaw 的思想：  
**控制平面不变，执行后端可替换。**

### 16.7 Windows 小白落地建议

1. 先在 Windows 原生 PowerShell 做 V1（最直观）。  
2. 一旦涉及 ACP/复杂依赖，优先切 WSL2，少踩路径和进程兼容坑。  
3. 每次只加一个能力，保证“可运行状态”。

### 16.8 MiniOpenClaw 学习路线（7 天）

1. Day1：搭 CLI + session JSONL。  
2. Day2：接 API 模型，能问答。  
3. Day3：加 3 个工具，跑通工具循环。  
4. Day4：做 runtime 抽象（local/acp 接口）。  
5. Day5：接入 codex 或 claude 的一个 ACP 路径。  
6. Day6：加最小权限策略与日志。  
7. Day7：整理成你自己的“个人助手模板”。

### 16.9 你最终会学到什么

做完这个 Mini，你会真正吃透 OpenClaw 的 4 个核心：

1. 为什么要有 Gateway 控制层  
2. 为什么会话必须可追踪可恢复  
3. 为什么工具调用要有策略边界  
4. 为什么“个人助手”和“编码 Agent”要做运行时解耦

