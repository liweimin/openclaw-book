# OpenClaw 配置实战完整手册（Windows 版）

> 目标读者：小白和进阶用户都能直接照着落地  
> 时间快照：2026-02-27  
> 写作重点：个性化助手、多模型分工、PI 切换到 Codex/Claude 驱动、关键上下文配置

---

## 0. 你的目标，我的理解

你要的是一份可以直接落地的手册，不是概念介绍。核心有 4 件事：

1. 把 OpenClaw 配成“适合你本人”的助手。  
2. 让不同任务自动用不同模型（省钱 + 稳定 + 效果）。  
3. 明确怎么把默认 PI 路径切到 Codex/Claude Code 路径。  
4. 配置关键上下文（SOUL/IDENTITY/USER/MEMORY 等），让助手长期稳定。

这份文档按照“先跑通，再优化，再替换执行器”的顺序写。

---

## 1. 先选路线：你到底想怎么驱动

OpenClaw 里有三条常见路线，很多人会混淆。

### 路线 A：PI 作为主运行时（默认）

- 任务主要在 OpenClaw 内部 Agent 循环完成。  
- 你通过 `agents.defaults.model` 选主模型（例如 `anthropic/...`、`openai/...`）。  
- 优点：稳定、功能完整、最像“个人助手主脑”。

### 路线 B：ACP 运行时驱动外部编码 harness（Codex/Claude/OpenCode/Gemini/PI）

- 用 `runtime: "acp"` + `agentId: "codex"|"claude"|...`。  
- 由 ACP backend（通常 `acpx` 插件）去驱动外部 harness。  
- 优点：最适合“编码重任务外包”。

### 路线 C：CLI Backend 兜底（claude-cli/codex-cli）

- 这是“文本兜底路径”，主要用于 provider API 故障时 fallback。  
- 重点限制：这条路径是 text-only，OpenClaw 工具调用不走它。  
- 优点：抗故障，服务不断。

一句话：  
- 日常助手主脑用 A。  
- 编码外包用 B。  
- 容灾兜底用 C。

---

## 2. Windows 安装与准备（先可用）

## 2.1 安装方式

官方推荐 Windows 用 WSL2（兼容性最好），但你要原生也可跑。

PowerShell 原生安装：

```powershell
iwr -useb https://openclaw.ai/install.ps1 | iex
```

初始化：

```powershell
openclaw onboard --install-daemon
openclaw gateway status
openclaw dashboard
```

如果有异常，先跑：

```powershell
openclaw doctor
openclaw status --all
```

## 2.2 配置文件位置

默认配置文件：

```text
~/.openclaw/openclaw.json
```

说明：
- JSON5 格式（可注释、可尾逗号）。  
- 配置校验是严格的，未知字段/错误类型会导致 Gateway 拒绝启动。

---

## 3. 先上一个“稳健可用”的基线配置

下面这个配置适合个人助手起步：先安全，再逐步放开。

```json5
{
  gateway: {
    mode: "local",
    bind: "loopback",
    auth: {
      mode: "token",
      token: "请换成你自己的长随机token"
    }
  },

  agents: {
    defaults: {
      workspace: "~/.openclaw/workspace",

      model: {
        primary: "anthropic/claude-sonnet-4-5",
        fallbacks: ["openai/gpt-5.2"]
      },

      models: {
        "anthropic/claude-sonnet-4-5": { alias: "Sonnet" },
        "openai/gpt-5.2": { alias: "GPT-5.2" }
      },

      thinkingDefault: "medium",
      timeoutSeconds: 1200,
      heartbeat: {
        every: "0m" // 先关掉，稳定后再开
      }
    },
    list: [
      {
        id: "main",
        default: true
      }
    ]
  },

  session: {
    dmScope: "per-channel-peer",
    threadBindings: {
      enabled: true,
      idleHours: 24,
      maxAgeHours: 0
    }
  },

  tools: {
    profile: "messaging",
    fs: { workspaceOnly: true },
    exec: { security: "deny", ask: "always" },
    elevated: { enabled: false }
  }
}
```

生效与检查：

```powershell
openclaw gateway restart
openclaw doctor
openclaw security audit
```

---

## 4. 个性化助手：关键上下文怎么配

很多人只改模型，不改上下文文件，结果助手人格和记忆都很漂。

OpenClaw 正常会注入这些工作区文件（普通会话）：

- `AGENTS.md`
- `SOUL.md`
- `TOOLS.md`
- `IDENTITY.md`
- `USER.md`
- `HEARTBEAT.md`
- `BOOTSTRAP.md`（仅全新工作区）
- `MEMORY.md` / `memory.md`（若存在）

注意：
- 大文件会被 `agents.defaults.bootstrapMaxChars` 截断（默认 20000）。  
- 总注入量受 `agents.defaults.bootstrapTotalMaxChars` 限制（默认 150000）。  
- `memory/*.md` 每日文件不会自动注入，通常通过 memory 工具按需读取。

## 4.1 你该怎么写这些文件（实用建议）

1. `SOUL.md`：人格与语气（你希望它怎么说话）。  
2. `IDENTITY.md`：角色边界（你是谁、它是谁、不能越界的点）。  
3. `USER.md`：你的偏好（时间、任务风格、输出风格）。  
4. `MEMORY.md`：长期事实（稳定信息，不写“今天临时状态”）。  
5. `HEARTBEAT.md`：主动提醒策略（频率、触发条件、禁止骚扰规则）。

## 4.2 建议的可执行动作

```powershell
openclaw setup
openclaw config set agents.defaults.workspace "\"~/.openclaw/workspace\""
```

然后把你的人设和偏好写进上述文件，再重启 Gateway。

---

## 5. 多模型多任务分工：可直接复制的策略

你的目标不是“一个最强模型干所有活”，而是“正确任务给正确模型”。

## 5.1 推荐分工

1. 日常问答/协调：快且便宜模型。  
2. 复杂推理：高推理模型。  
3. 编码重活：ACP 外包给 codex/claude harness。

## 5.2 模板：主模型 + 回退链

```json5
{
  agents: {
    defaults: {
      model: {
        primary: "openai/gpt-5.2",
        fallbacks: [
          "anthropic/claude-sonnet-4-5",
          "openai/gpt-4o-mini"
        ]
      },
      models: {
        "openai/gpt-5.2": { alias: "gpt-main" },
        "anthropic/claude-sonnet-4-5": { alias: "claude-safe" },
        "openai/gpt-4o-mini": { alias: "cheap-fast" }
      }
    }
  }
}
```

## 5.3 模板：多 Agent 分角色（最实用）

```json5
{
  agents: {
    defaults: {
      workspace: "~/.openclaw/workspace-main",
      model: { primary: "openai/gpt-5.2" }
    },
    list: [
      {
        id: "main",
        default: true,
        workspace: "~/.openclaw/workspace-main"
      },
      {
        id: "coder",
        workspace: "~/.openclaw/workspace-coder",
        model: {
          primary: "anthropic/claude-opus-4-6",
          fallbacks: ["openai/gpt-5.2"]
        }
      },
      {
        id: "assistant-fast",
        workspace: "~/.openclaw/workspace-fast",
        model: { primary: "openai/gpt-4o-mini" }
      }
    ]
  },
  bindings: [
    { agentId: "main", match: { channel: "whatsapp", accountId: "personal" } },
    { agentId: "coder", match: { channel: "discord", accountId: "work" } }
  ]
}
```

这个模式的价值：
- 个人生活和编码上下文彻底隔离。  
- 每个 agent 的模型、工作区、会话独立。  
- 回退链也可按 agent 定制。

---

## 6. 把 PI 切到 Codex/Claude：三种可落地方式

你问“怎么把 PI 换掉，用 codex/claudecode 驱动”，这里给你实战答案。

## 6.1 方式 A（推荐）：ACP runtime（真正 harness 驱动）

这是 OpenClaw 官方 ACP 路径，适合你说的“编码 Agent 驱动”场景。

### Step 1：安装并启用 acpx 插件

```bash
openclaw plugins install @openclaw/acpx
openclaw config set plugins.entries.acpx.enabled true
openclaw gateway restart
```

### Step 2：配置 ACP 基线

```json5
{
  acp: {
    enabled: true,
    dispatch: { enabled: true },
    backend: "acpx",
    defaultAgent: "codex",
    allowedAgents: ["pi", "claude", "codex", "opencode", "gemini"],
    maxConcurrentSessions: 8,
    stream: {
      coalesceIdleMs: 300,
      maxChunkChars: 1200
    },
    runtime: {
      ttlMinutes: 120
    }
  }
}
```

关键说明（非常重要）：
- `acp.enabled` 默认不是强制 false，但建议显式写 `true`。  
- `acp.dispatch.enabled` 必须显式 `true`，否则会报“dispatch disabled”。  
- `allowedAgents` 为空时等于不限制；生产建议显式白名单。  
- `defaultAgent` 让你不用每次都写 `agentId`。

### Step 3：验证 ACP 后端

在聊天里执行：

```text
/acp doctor
```

如果 backend 不可用，会给你安装/修复提示。

### Step 4：启动 Codex/Claude 会话

```text
/acp spawn codex --mode persistent --thread auto
/acp spawn claude --mode oneshot --thread off
```

或在工具调用里：

```json
{
  "task": "请重构这个模块并加测试",
  "runtime": "acp",
  "agentId": "codex",
  "thread": true,
  "mode": "session"
}
```

说明：
- `sessions_spawn` 默认 runtime 是 `subagent`，要走 ACP 必须写 `runtime: "acp"`。  
- 未传 `agentId` 时会回落到 `acp.defaultAgent`（若已配置）。

## 6.2 方式 B：CLI backends（claude-cli/codex-cli）做 fallback

这条更像“容灾后备”。不是 ACP harness 管理层。

示例：

```json5
{
  agents: {
    defaults: {
      model: {
        primary: "anthropic/claude-opus-4-6",
        fallbacks: ["codex-cli/gpt-5.3-codex", "claude-cli/opus-4.6"]
      },
      models: {
        "anthropic/claude-opus-4-6": {},
        "codex-cli/gpt-5.3-codex": {},
        "claude-cli/opus-4.6": {}
      }
    }
  }
}
```

重点限制：
- 这条路径是 text-only fallback。  
- OpenClaw 工具调用不会在 CLI backend 路径里完整执行。

## 6.3 方式 C：在 PI runtime 里直接改为 OpenAI Codex provider

这不是 ACP 外包，而是把主模型设为 `openai-codex/...`。

```json5
{
  agents: {
    defaults: {
      model: { primary: "openai-codex/gpt-5.3-codex" }
    }
  }
}
```

适用：
- 你希望仍用 PI 主循环，但底层模型来自 Codex 体系。

## 6.4 三种方式怎么选

1. 你要“最像编程 agent、会话可控、线程化编排”：选 A（ACP）。  
2. 你要“API 故障也能回答”：加 B（CLI fallback）。  
3. 你要“PI 不变，只换模型供应商”：选 C。

---

## 7. 关键上下文与稳定性参数（高级但实用）

这部分决定“长期使用是否稳”。

## 7.1 上下文注入体积控制

```json5
{
  agents: {
    defaults: {
      bootstrapMaxChars: 16000,
      bootstrapTotalMaxChars: 120000
    }
  }
}
```

用途：
- 防止 SOUL/MEMORY 过大把上下文挤爆。  
- 降低 token 成本和 compaction 频率。

## 7.2 图像 token 成本控制

```json5
{
  agents: {
    defaults: {
      imageMaxDimensionPx: 1000
    }
  }
}
```

截图多的场景可明显降成本。

## 7.3 心跳（Heartbeat）建议

初期：

```json5
{
  agents: { defaults: { heartbeat: { every: "0m" } } }
}
```

稳定后再开（如 `30m` 或 `55m`），并配好 `HEARTBEAT.md`，避免“无意义打扰”。

## 7.4 源码解读：OpenClaw 的上下文管理（小白版）

你可以把它想成一个“装箱系统”：每次回答前，OpenClaw 都在做一次“装箱”，把最重要的信息塞进模型可见窗口。

### 7.4.1 装箱第 1 步：收集工作区上下文文件

按当前源码，OpenClaw 会从 workspace 读取固定文件名集合（`AGENTS.md`、`SOUL.md`、`TOOLS.md`、`IDENTITY.md`、`USER.md`、`HEARTBEAT.md`、`BOOTSTRAP.md`、`MEMORY.md`/`memory.md`）。  
实现点在 `workspace.ts + bootstrap-files.ts`：

- 只认“白名单文件名”，避免乱注入。  
- 读取时做工作区边界校验（不能越界读到 workspace 之外）。  
- 文件读取有缓存（按文件 inode/mtime 标识），减少重复 IO。  
- 子代理/cron 会话会做缩减注入（当前源码是保留 `AGENTS/TOOLS/SOUL/IDENTITY/USER`）。

### 7.4.2 装箱第 2 步：做上下文体积预算

注入不是无限的，源码里有两层预算：

1. 单文件预算：`agents.defaults.bootstrapMaxChars`（默认 20000）。  
2. 全部文件总预算：`agents.defaults.bootstrapTotalMaxChars`（默认 150000）。

如果超限，会做“头尾保留 + 中间截断标记”。  
这就是你有时看到“明明文件很长，但模型像只看了前后两段”的根本原因。

### 7.4.3 装箱第 3 步：拼系统提示词（System Prompt）

OpenClaw 每次运行都会重建 system prompt（不是沿用 PI 默认系统提示词）。  
`system-prompt.ts` 里会拼出：

- 工具清单和规则  
- Workspace 信息  
- Skills 信息  
- 时间/运行时信息  
- 注入的 `# Project Context` 文件块

并且有 `promptMode`：

- `full`：主会话完整上下文  
- `minimal`：子代理精简上下文  
- `none`：极简

### 7.4.4 装箱第 4 步：控制“窗口大小”

模型能看多少 token（context window）也有解析顺序：

1. `models.providers.*.models[].contextWindow` 覆盖值  
2. 模型注册信息里的 contextWindow  
3. 默认值

然后再受 `agents.defaults.contextTokens` 二次封顶。  
所以你可以“人为给上限”，避免某些模型宣称窗口很大但实际不稳。

### 7.4.5 装箱第 5 步：窗口快满时怎么处理

OpenClaw 有两种减压机制，很多人会混：

1. `contextPruning`（会话修剪）  
- 只修剪旧 `toolResult`。  
- 用户/助手正文不改。  
- 是“本次请求内存态修剪”，不改磁盘历史。

2. `compaction`（会话压缩）  
- 把较旧对话做摘要并写回 session 历史。  
- 是“持久化变更”。

一句话：pruning 是临时瘦身，compaction 是永久归档。

## 7.5 源码解读：OpenClaw 的记忆系统（小白版）

记忆系统可以分成 5 层。

### 7.5.1 文件层（你能看见的记忆）

默认记忆文件是：

- `MEMORY.md`：长期稳定记忆  
- `memory/*.md`：日记式短中期记忆（通常按天）

核心认知：Markdown 文件才是“记忆真相源”。模型本身不长期记住，写盘才算记住。

### 7.5.2 工具层（给模型用的记忆接口）

两把关键工具：

1. `memory_search`：语义检索，返回片段+路径+行号。  
2. `memory_get`：按路径/行号精读。

源码里 `memory_get` 有安全边界：默认只允许 `MEMORY.md`、`memory/*.md`（以及你显式配置的 extraPaths）。  
不存在文件会优雅返回空文本，不会直接炸会话。

### 7.5.3 索引层（SQLite/向量/全文）

内置 backend（builtin）下，记忆索引核心是 `MemoryIndexManager`：

- 存储：SQLite（`files/chunks/meta/embedding_cache`）  
- 可选向量加速：`sqlite-vec`  
- 可选关键词检索：FTS5  
- 文本切块：默认约 `400 token`，重叠 `80 token`

触发重建索引的典型条件：

- embedding provider/model 变化  
- chunk 参数变化  
- source 范围变化（memory/sessions）

并且源码用了“安全重建”：先写临时库，再原子替换，降低索引损坏风险。

### 7.5.4 检索层（怎么把结果找得更准）

builtin 下默认是 hybrid 思路（向量 + 关键词），再支持：

- MMR 去重重排（减少重复片段）  
- temporal decay 时间衰减（新记忆优先）

所以如果你感觉“老信息总压过新信息”，可以启用 temporal decay；  
如果你感觉“结果总是重复同一件事”，启用 MMR。

### 7.5.5 后端层（builtin 与 qmd）

`memory.backend` 支持：

1. `builtin`（默认）  
2. `qmd`（实验）

而且 qmd 失败时，源码会自动 fallback 到 builtin（`search-manager.ts` 的 FallbackMemoryManager）。  
这意味着：你可以试 qmd，但生产不容易“一挂全挂”。

### 7.5.6 预压缩记忆刷写（memory flush）

当会话接近 compaction 阈值时，会触发一轮“静默记忆刷写”：

- 配置入口：`agents.defaults.compaction.memoryFlush.*`  
- 目的是先把关键长期信息写进记忆文件，再压缩会话  
- 默认 prompt 会引导返回 `NO_REPLY`，避免打扰用户  
- 每个 compaction 周期只触发一次，避免刷写风暴

## 7.6 小白怎么用：从“能用”到“好用”的实操方案

### 7.6.1 推荐起步配置（先稳）

```json5
{
  agents: {
    defaults: {
      bootstrapMaxChars: 12000,
      bootstrapTotalMaxChars: 60000,
      contextTokens: 128000,
      memorySearch: {
        enabled: true,
        provider: "openai",
        model: "text-embedding-3-small",
        fallback: "none",
        query: { maxResults: 6, minScore: 0.35 },
        sync: { onSessionStart: true, onSearch: true, watch: true }
      },
      contextPruning: {
        mode: "cache-ttl",
        ttl: "1h"
      },
      compaction: {
        mode: "safeguard",
        memoryFlush: {
          enabled: true,
          softThresholdTokens: 4000
        }
      }
    }
  },
  memory: {
    backend: "builtin",
    citations: "auto"
  }
}
```

这套配置对应的使用感受是：

- system prompt 不会因为文件太大失控  
- 记忆能检索，但成本可控  
- 长会话会自动“先记忆再压缩”  
- 上下文爆炸概率明显下降

### 7.6.2 你每天该怎么和助手配合

1. 说“记住这条偏好/决定”，让它写入 `MEMORY.md` 或当天 `memory/YYYY-MM-DD.md`。  
2. 讨论“以前做过什么”时，提醒它先 `memory_search` 再答。  
3. 每周整理一次 `MEMORY.md`（把日记里的长期信息提炼进去）。  
4. 如果回答变迟钝或丢细节，先 `/context detail` 看是不是注入超载。

### 7.6.3 排障顺序（最省时间）

1. `/status` 看窗口和会话状态。  
2. `/context list` 看哪些文件占空间。  
3. `/context detail` 看是不是工具 schema 或大文件占比过高。  
4. `/compact` 手动做一次压缩。  
5. 再调整 `bootstrap*`、`contextTokens`、`memorySearch.query.*`。

---

## 8. 安全与密钥（别跳过）

## 8.1 先做安全审计

```bash
openclaw security audit
openclaw security audit --deep
```

重点盯：
- Gateway 认证和暴露面。  
- 是否开启了高风险工具。  
- 文件权限是否过宽。

## 8.2 用 Secrets 管理 API Key（推荐）

不要把明文 key 长期放在配置里。  
建议用 `secrets` provider（env/file/exec）做 SecretRef。

日常运维：

```bash
openclaw doctor
openclaw models status
```

---

## 9. 你关心的对比：BashClaw 对接 Codex/Claude 和 OpenClaw 是同原理吗

结论：不是同一层，但目标相似。

1. BashClaw  
- 更偏“引擎分发”思路（`claude` / `builtin`）。  
- `claude` 通过 CLI 子进程调用，`builtin` 走 API key 多 provider。

2. OpenClaw  
- 更偏“控制平面 + ACP runtime 协议”思路。  
- 用 `runtime: "acp"` 和 `agentId` 把任务交给 `acpx` 驱动 codex/claude/pi/opencode/gemini。

所以：
- 都能接 Codex/Claude。  
- 但 OpenClaw 的切换是协议后端级，BashClaw 更像应用内引擎分支。

## 9.1 和 Claude Code / OpenCode / Kode 的定位差异（快速记忆）

1. Claude Code / OpenCode / Kode  
- 核心是“编码任务执行”。  
- 交互中心在代码仓、终端、IDE。

2. OpenClaw  
- 核心是“个人助手控制平面”。  
- 交互中心是多渠道会话、长期记忆、策略化工具与自动化。

3. 最稳的组合方式  
- OpenClaw 负责路由、上下文、渠道、治理。  
- 编码重任务交给 Codex/Claude/OpenCode/Kode（ACP 或 CLI fallback）。

---

## 10. 常见报错与快速修复

1. `ACP is disabled by policy`  
- 配 `acp.enabled=true`。

2. `ACP dispatch is disabled by policy`  
- 配 `acp.dispatch.enabled=true`。

3. `ACP agent "<id>" is not allowed by policy`  
- 把该 id 加进 `acp.allowedAgents`。

4. `ACP target agent is required`  
- 调用时传 `agentId`，或设置 `acp.defaultAgent`。

5. `/acp spawn ... --thread here` 报必须在线程内  
- 换 `--thread auto` 或在线程上下文执行。

6. 配置改完网关起不来  
- 跑 `openclaw doctor`，按诊断修复 schema 问题。

---

## 11. MiniOpenClaw：自己实现一版（最能吃透原理）

你要求“给小白一个可以自己实现的 MiniOpenClaw 指南”，这里给最小闭环。

## 11.1 目标能力（V1）

1. CLI 收消息。  
2. JSONL 存会话。  
3. API 调模型。  
4. 三个工具：`read_file`、`write_file`、`shell`。  
5. 基础任务路由（普通问答/编码）。

## 11.2 目录骨架

```text
miniopenclaw/
  src/
    main.ts
    gateway.ts
    session-store.ts
    model-client.ts
    tools/
      read-file.ts
      write-file.ts
      shell.ts
      index.ts
    runtimes/
      local-runtime.ts
      acp-runtime.ts
  data/sessions/
  .env
  package.json
```

## 11.3 执行链（和 OpenClaw 主原理一一对应）

1. 读取输入。  
2. 解析 `sessionKey`。  
3. 载入会话历史。  
4. 拼系统提示 + 历史。  
5. 调模型。  
6. 处理工具调用并回写。  
7. 结束条件 `done`。  
8. 持久化 assistant/tool 轨迹。

## 11.4 V2/V3 进阶

- V2：多 agent + bindings + 简易 Web UI。  
- V3：ACP 接 codex/claude + 权限策略 + 定时任务。

你做完这个 Mini，就会真正理解：
- 为什么 OpenClaw 要有 Gateway。  
- 为什么会话和工具轨迹必须持久化。  
- 为什么运行时（PI/ACP/CLI）要解耦。

---

## 12. 最后给你一套“现在就可执行”的命令清单

1. 基础上线

```powershell
openclaw onboard --install-daemon
openclaw gateway status
openclaw dashboard
```

2. 安全与健康

```powershell
openclaw doctor
openclaw security audit
openclaw models status
```

3. 启用 ACP（Codex 默认）

```powershell
openclaw plugins install @openclaw/acpx
openclaw config set plugins.entries.acpx.enabled true
openclaw config set acp.enabled true
openclaw config set acp.dispatch.enabled true
openclaw config set acp.backend "\"acpx\""
openclaw config set acp.defaultAgent "\"codex\""
openclaw config set acp.allowedAgents "[\"pi\",\"claude\",\"codex\",\"opencode\",\"gemini\"]"
openclaw gateway restart
```

4. 运行时验证（在聊天里）

```text
/acp doctor
/acp spawn codex --mode persistent --thread auto
```

---

## 13. 本文关键依据（源码/文档）

OpenClaw 文档与源码：
- `research/openclaw/docs/gateway/configuration.md`
- `research/openclaw/docs/tools/acp-agents.md`
- `research/openclaw/docs/gateway/cli-backends.md`
- `research/openclaw/docs/providers/openai.md`
- `research/openclaw/docs/providers/anthropic.md`
- `research/openclaw/docs/concepts/context.md`
- `research/openclaw/docs/concepts/memory.md`
- `research/openclaw/docs/concepts/compaction.md`
- `research/openclaw/docs/concepts/session-pruning.md`
- `research/openclaw/docs/concepts/system-prompt.md`
- `research/openclaw/src/config/zod-schema.ts`
- `research/openclaw/src/config/zod-schema.agent-defaults.ts`
- `research/openclaw/src/config/zod-schema.agent-runtime.ts`
- `research/openclaw/src/config/defaults.ts`
- `research/openclaw/src/acp/policy.ts`
- `research/openclaw/src/agents/acp-spawn.ts`
- `research/openclaw/src/agents/workspace.ts`
- `research/openclaw/src/agents/bootstrap-cache.ts`
- `research/openclaw/src/agents/bootstrap-files.ts`
- `research/openclaw/src/agents/system-prompt.ts`
- `research/openclaw/src/agents/context-window-guard.ts`
- `research/openclaw/src/agents/pi-extensions/context-pruning/pruner.ts`
- `research/openclaw/src/agents/tools/memory-tool.ts`
- `research/openclaw/src/agents/memory-search.ts`
- `research/openclaw/src/memory/manager.ts`
- `research/openclaw/src/memory/manager-sync-ops.ts`
- `research/openclaw/src/memory/search-manager.ts`
- `research/openclaw/src/memory/memory-schema.ts`
- `research/openclaw/src/auto-reply/reply/memory-flush.ts`
- `research/openclaw/extensions/acpx/src/runtime.ts`
- `research/openclaw/extensions/acpx/src/service.ts`

BashClaw 对照：
- `research/BashClaw/lib/engine.sh`
- `research/BashClaw/lib/engine_claude.sh`
- `research/BashClaw/lib/api_caller.sh`
- `research/BashClaw/lib/models.sh`
- `research/BashClaw/lib/models.json`
