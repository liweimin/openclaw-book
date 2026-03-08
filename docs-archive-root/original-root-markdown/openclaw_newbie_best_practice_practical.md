# OpenClaw 小白最佳实践补丁版：刚安装好以后怎么真正配起来

这份文档是对 [openclaw_newbie_best_practice.md](/D:/code/anzhuang/openclaw_newbie_best_practice.md) 的实操补充版。

目标不是重复讲理念，而是解决你这种场景：

- 刚装好 OpenClaw
- 还没怎么聊天
- workspace 里很多文件还没有
- Web UI 里改不了太多东西
- 现在工具很少，不知道怎么加
- 不知道内置 skills 哪些该用，哪些先别管
- 想把调试命令也一起纳入日常使用

这份文档基于当前本地仓库 `D:\code\anzhuang\openclaw` 的源码和文档整理，重点讲：

1. 刚安装完，哪些东西会自动有，哪些不会
2. `MEMORY.md`、`memory/`、`skills/` 没有时怎么补
3. 工具到底怎么增加，改哪里才算数
4. 内置 skills 怎么看、怎么选、怎么先用最少的一批
5. 如何把调试命令纳入第一周的日常流程

---

## 1. 先纠正一个最容易误解的点

### 1.1 `TOOLS.md` 不会帮你“开工具”

这是新手最容易误解的地方。

`TOOLS.md` 只是写给 Agent 看的“说明文件”，告诉它：

- 你本机有哪些常用路径
- 你习惯怎么用工具
- 哪些命令危险
- 哪些目录重要

但它**不决定工具是否可用**。

真正决定工具是否可用的，是：

- `~/.openclaw/openclaw.json`
- 是否启用了对应插件
- 是否配置了 API key / 浏览器 / 外部依赖
- 当前 tools profile / allow / deny
- 当前 skill 是否满足加载条件

所以你现在“工具很少”，优先看配置和插件，不要先改 `TOOLS.md`。

### 1.2 `MEMORY.md` 和 `memory/` 不是装完就一定有

从工作区和 memory 文档来看：

- `MEMORY.md` 是可选的长期记忆文件
- `memory/YYYY-MM-DD.md` 是每日记忆日志

它们属于推荐结构，但不是“刚安装完一定已经自动生成”。

所以如果你现在没有：

- 不代表坏了
- 不代表记忆功能失效
- 只是你还没开始建立自己的工作区记忆层

### 1.3 `openclaw setup` 是“初始化骨架”，不是“帮你把系统全配满”

`openclaw setup` 会初始化：

- `~/.openclaw/openclaw.json`
- agent workspace

文档还说明，首次 bootstrapping 会 seed 一些基础文件，例如：

- `AGENTS.md`
- `BOOTSTRAP.md`
- `IDENTITY.md`
- `USER.md`

但很多东西仍然要你自己补：

- `SOUL.md`
- `TOOLS.md`
- `MEMORY.md`
- `memory/`
- `skills/`
- 各类 API key
- 插件和外部工具

所以正确理解应该是：

**setup 负责“起盘”，不是“替你完成个性化配置”。**

---

## 2. 刚安装完，先检查这 4 个地方

### 2.1 先确认配置和工作区位置

默认重点目录是：

- 配置：`~/.openclaw/openclaw.json`
- 工作区：`~/.openclaw/workspace`

如果你不确定，就先用默认位置，不要一上来换路径。

### 2.2 先跑一次 setup

```bash
openclaw setup
```

如果你想通过向导再补一遍：

```bash
openclaw setup --wizard
```

### 2.3 确认 gateway 正常

```bash
openclaw gateway status
openclaw health
```

### 2.4 检查当前 skills 和 plugins 状态

```bash
openclaw plugins list
openclaw skills list
openclaw skills list --eligible
openclaw skills check
```

这 4 条很重要。

它们分别回答：

- 现在装了哪些插件
- 现在系统识别到了哪些 skills
- 哪些 skills 当前真的可用
- 哪些 skills 因为缺少依赖/API key/二进制而不可用

---

## 3. 如果工作区里缺文件，该怎么补

这里给你一个最实用的判断标准。

### 3.1 一开始必须有的

建议最少保证这 4 个文件存在：

- `AGENTS.md`
- `SOUL.md`
- `USER.md`
- `TOOLS.md`

如果 setup 没自动给全，你可以自己补。

### 3.2 一开始建议补的

- `MEMORY.md`
- `memory/`

这两个不是必须立刻有，但非常建议你在第一周就建立起来。

### 3.3 一开始可以没有的

- `skills/`
- `HEARTBEAT.md`
- `BOOT.md`
- `canvas/`

这些都属于“以后按需加”，不是第一天必须有。

---

## 4. 给小白的最小工作区模板

如果你现在 workspace 里不完整，可以先手工补成下面这样：

```text
~/.openclaw/workspace/
  AGENTS.md
  SOUL.md
  USER.md
  TOOLS.md
  MEMORY.md
  memory/
```

### 4.1 `AGENTS.md`

先只写规则，不要写太长。

建议最小内容：

```md
# AGENTS.md

## Working Rules
- 默认使用中文沟通。
- 先理解任务，再动手。
- 修改文件前先说明要改什么。
- 不要覆盖用户已有文档，除非明确要求。
- 如果需要写入长期记忆，写入后告诉用户写到了哪个文件。

## Output Rules
- 先给结论，再给必要细节。
- 文档适合小白阅读。
- 优先给可执行步骤。
```

### 4.2 `SOUL.md`

```md
# SOUL.md

- 说话直接、清楚、少废话。
- 不要套话。
- 优先像一个务实的工程助手。
```

### 4.3 `USER.md`

```md
# USER.md

- Preferred language: 中文
- Timezone: Asia/Shanghai
- Main use cases:
  - 源码分析
  - 文档整理
  - Agent 调教
  - 配置管理
```

### 4.4 `TOOLS.md`

这里不要写“我要哪些工具”，而是写“怎么安全使用现有工具”。

```md
# TOOLS.md

- 默认工作目录以 workspace 为主。
- 涉及删除、覆盖、批量改动时先确认。
- 读取文件时优先小范围、定向读取。
- 如果要联网、搜索或调用外部服务，先说明用途。
- 调试时优先用状态类命令，不要默认暴露所有内部细节。
```

### 4.5 `MEMORY.md`

这就是最小长期记忆。

```md
# Long-Term Memory

## Preferences
- 默认使用中文。
- 优先给结论，再给步骤。
- 文档适合小白理解。

## Work Style
- 用户主要用 OpenClaw 做源码分析、文档整理和 Agent 调教。
- 不要覆盖原有文档，除非明确要求。
```

### 4.6 `memory/`

在 `memory/` 下面新建当天文件，例如：

```text
memory/2026-03-06.md
```

初始可以先空着，或者只写当天很重要的测试背景。

---

## 5. 工具到底怎么增加：最实用的理解方式

把工具分成 4 类看，最容易理解。

### 5.1 核心内置工具

这些是 OpenClaw 核心里自带的，例如：

- 文件类：`read`、`write`、`edit`、`apply_patch`
- 运行类：`exec`、`bash`、`process`
- 会话类：`sessions_*`、`session_status`
- 记忆类：`memory_search`、`memory_get`
- Web 类：`web_search`、`web_fetch`
- UI 类：`browser`、`canvas`

这些工具是否会暴露给模型，主要由 `tools.profile`、`tools.allow`、`tools.deny` 控制。

### 5.2 需要额外配置的核心工具

有些虽然是核心工具，但你不配好就不好用，典型是：

- `web_search`：需要 Brave 或 Perplexity 配置
- `browser`：需要浏览器配置
- `memory_search`：需要 memorySearch 和 embedding 配置

### 5.3 插件带来的工具

插件可以注册新工具。

流程通常是：

1. `openclaw plugins list`
2. `openclaw plugins install <plugin>`
3. 改 `openclaw.json`
4. 重启 gateway

### 5.4 Skills 不是“工具本体”，而是“教 Agent 怎么用工具”

很多新手把 skill 和 tool 混在一起。

更准确地说：

- tool = 真正的能力接口
- skill = 给 Agent 的使用说明和工作流指导

所以：

- 没有 tool，skill 也干不了活
- 有 tool 没有 skill，模型也可能不会正确用

---

## 6. 小白第一版 `openclaw.json` 该怎么配工具

如果 Web UI 改不了，就直接改：

- `~/.openclaw/openclaw.json`

先用“够用版”，不要一上来配复杂。

### 6.1 推荐的第一版思路

目标：

- 保留 coding 常用工具
- 加上 web 工具
- 打开 browser
- 先不碰太多高风险插件工具

可以参考这个思路：

```json5
{
  tools: {
    profile: "coding",
    allow: ["group:web", "browser"]
  },
  browser: {
    enabled: true,
    defaultProfile: "openclaw"
  }
}
```

这个配置的意义是：

- `coding` 给你文件、运行时、会话、记忆等基础能力
- 额外允许 `group:web`
- 额外允许 `browser`

### 6.2 如果你想让网页搜索能用

还要继续配 web search：

```json5
{
  tools: {
    profile: "coding",
    allow: ["group:web", "browser"],
    web: {
      search: {
        enabled: true,
        provider: "brave",
        apiKey: "你的 BRAVE_API_KEY"
      },
      fetch: {
        enabled: true
      }
    }
  }
}
```

如果你不配搜索提供商，通常会出现：

- `web_fetch` 可能还能用
- `web_search` 不一定能正常工作

### 6.3 如果你想让 browser 真正好用

再补：

```json5
{
  browser: {
    enabled: true,
    defaultProfile: "openclaw",
    headless: false
  }
}
```

然后可以用 CLI 先测：

```bash
openclaw browser --browser-profile openclaw status
openclaw browser --browser-profile openclaw start
```

### 6.4 如果你想让 memory 搜索工具更稳定可用

记忆文件本身是 Markdown，但 `memory_search` 是否真正可用，还和 embedding 配置有关。

可以走两条路：

- 远程 embedding：OpenAI / Gemini
- 本地 embedding：local model

如果你现在只是刚装好，我建议先用远程 embedding，省事。

思路示例：

```json5
{
  agents: {
    defaults: {
      memorySearch: {
        provider: "openai",
        model: "text-embedding-3-small"
      }
    }
  }
}
```

前提是你已经配置了对应 API key。

如果你现在不想折腾 embedding，也没关系：

- 先建好 `MEMORY.md` 和 `memory/`
- 先让 Agent 学会“往文件写记忆”
- 等后面再开语义检索

这比一开始追求“完整记忆系统”更实用。

### 6.5 改完配置后别忘了重启

插件配置、工具配置、浏览器配置、skills 配置变化后，最好都重启 gateway。

```bash
openclaw gateway restart
```

---

## 7. 内置 skills 到底要不要用

结论先说：

**大多数内置 skills，小白第一周都不用急着上。**

原因很简单：

- 很多 skills 是场景化的
- 很多有外部依赖
- 很多需要额外 CLI、账号、API key
- 你现在更需要的是“把主 Agent 跑顺”

### 7.1 先做这 3 件事

先跑：

```bash
openclaw skills list
openclaw skills list --eligible
openclaw skills check
```

你只需要先回答两个问题：

1. 现在有哪些 skill 被识别到了
2. 哪些 skill 当前真的可用

### 7.2 小白第一周建议关注的 skill

优先只关注下面几类。

#### `clawhub`

用途：

- 搜索、安装、更新 skills

适合你现在这种“想逐步加能力”的阶段。

前提：

- 本机有 `clawhub` CLI

如果没有，这个 skill 也不会 eligible。

#### `session-logs`

用途：

- 查旧会话日志
- 做调试复盘

很适合和调试文档配套。

前提：

- 有 `jq`
- 有 `rg`

#### `coding-agent`

用途：

- 把复杂编码任务委托给 Codex、Claude Code、Pi 等后台 agent

这个不是入门必须，但如果你后面要做复杂代码工作，它会很有价值。

前提：

- 你机器上装了对应 CLI，比如 `codex`、`claude`、`pi`

### 7.3 你现在先不用急着管的大量内置 skill

像这些：

- Apple Notes
- Bear
- Spotify
- Sonos
- Trello
- Notion
- Discord
- Slack
- OpenHue
- OpenAI image
- nano-banana-pro
- 各种平台专用 skill

都属于：

- 要么很场景化
- 要么依赖额外账号/API
- 要么不适合第一周

你完全可以先忽略。

### 7.4 如果你接入飞书，哪些插件自带 skill 值得知道

仓库里 Feishu 插件自带这些 skill：

- `feishu-doc`
- `feishu-drive`
- `feishu-perm`
- `feishu-wiki`

但注意：

- 这些是给“飞书生态操作”用的
- 不等于装了飞书渠道就立刻全可用
- 还要看插件是否启用、账号权限是否完整、相关配置是否齐

所以第一阶段别急着全开，先把“飞书聊天通道 + 基础调试命令”跑顺。

---

## 8. 第一次安装后，推荐你按这个顺序加能力

这是最重要的一段，建议直接照着做。

### 第 1 步：先只保留最基础的一套

- workspace 基础文件
- `tools.profile: "coding"`
- `browser.enabled: true`
- `group:web`

### 第 2 步：先把飞书远程调试跑通

接入飞书后，先不要追求复杂自动化。

优先测试：

```text
/status
/context list
/model status
/usage tokens
```

如果需要放大观察：

```text
/verbose on
```

测试完记得关：

```text
/verbose off
```

### 第 3 步：再补 `MEMORY.md` 和 `memory/`

不要等“未来有空再弄”，第一周就补。

最少做到：

- 建一个 `MEMORY.md`
- 建一个 `memory/`
- 建当天 `memory/YYYY-MM-DD.md`

### 第 4 步：再决定要不要开 embedding 记忆检索

如果你已经开始积累记忆文件，再决定是否加：

- OpenAI embedding
- Gemini embedding
- local embedding

### 第 5 步：最后才考虑安装更多 skill / plugin

顺序建议：

1. `clawhub`
2. `session-logs`
3. 场景相关 skill
4. 插件工具

---

## 9. 把调试文档融进你的第一周流程

这个部分是对前面调试文档的落地补充。

### 每次改完配置后，固定做 1 次状态检查

发：

```text
/status
/context list
/model status
```

重点看：

- 现在是不是你想要的模型
- 上下文文件有没有被注入
- tools 和 session 状态是否正常

### 每次怀疑“工具没调起来”时

先发：

```text
/verbose on
/status
```

然后给一个明确任务，例如：

```text
请读取 AGENTS.md，总结当前工作规则。
```

### 每次怀疑“记忆没生效”时

不要先猜。

先做 4 件事：

1. 确认 `MEMORY.md` 是否存在
2. 确认 `memory/当天文件` 是否存在
3. 让 Agent 明确写入
4. 自己打开文件检查

### 每次怀疑“会话脏了”时

先用：

```text
/status
/compact
/status
```

不行再：

```text
/reset
```

### 每次远程飞书上看不清楚时

回到 gateway 主机看：

```bash
openclaw gateway status
openclaw logs --follow
```

这一步不能省。

---

## 10. 给小白的最终建议：第一周别追求“全都配好”

你现在最应该做的，不是一次把 OpenClaw 变成超级复杂系统。

更实际的路线是：

1. 先把 workspace 基础文件补齐
2. 先把 `tools.profile`、web、browser 配到能用
3. 先补 `MEMORY.md` 和 `memory/`
4. 先学会 `openclaw skills list --eligible` 和 `openclaw skills check`
5. 先用 `/status`、`/context`、`/verbose` 做日常调试
6. 一周后再决定要不要上更多 plugins / skills / memory embedding

如果你按这个顺序走，OpenClaw 会更像一个“逐步长出来的工作助手”，而不是一上来就失控的复杂系统。

---

## 11. 你现在最值得立刻做的事

按优先级执行：

1. 跑 `openclaw setup`
2. 打开 `~/.openclaw/openclaw.json`，把工具配置成 `coding + group:web + browser`
3. 在 workspace 里补 `SOUL.md`、`TOOLS.md`、`MEMORY.md`、`memory/`
4. 跑 `openclaw skills list --eligible`
5. 跑 `openclaw plugins list`
6. 接入飞书后先用 `/status`、`/context list`、`/model status` 做远程验证

如果你愿意，下一步我可以继续直接给你产出两份可复制模板：

- 一份适合小白刚装好就能用的 `openclaw.json` 初始配置
- 一份适合你当前场景的 workspace 初始文件包（`AGENTS.md`、`SOUL.md`、`TOOLS.md`、`MEMORY.md`）模板
