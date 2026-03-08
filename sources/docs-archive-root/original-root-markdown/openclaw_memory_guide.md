# OpenClaw 记忆机制原理、实操指南与最佳实践

本文专门回答你关于 OpenClaw 记忆系统的问题：

- `memory_search` / `memory_get` 到底是什么机制
- 要不要配置 embedding 模型
- `MEMORY.md` 会不会每次都加载
- 哪些记忆是自动进入上下文的，哪些不是
- 记忆文件怎么组织、怎么读、怎么验证
- 你到底该不该明确要求 Agent 记忆
- 怎么把“记忆原则”写进 `AGENTS.md`

这份说明基于本地仓库 `D:\code\anzhuang\openclaw` 的当前源码和文档整理，重点核对了：

- `docs/concepts/memory.md`
- `docs/concepts/system-prompt.md`
- `docs/concepts/agent-workspace.md`
- `docs/cli/memory.md`
- `src/agents/tools/memory-tool.ts`
- `src/agents/memory-search.ts`
- `src/memory/manager.ts`
- `src/memory/internal.ts`
- `src/agents/workspace.ts`

---

## 1. 先说结论：OpenClaw 的记忆到底是什么

OpenClaw 的记忆，本质上不是“模型脑子里自动长期保存的内容”，而是**工作区里的 Markdown 文件**。

你可以把它拆成 3 层：

1. **记忆源文件**
   - `MEMORY.md`
   - `memory/YYYY-MM-DD.md`
2. **检索/读取工具**
   - `memory_search`
   - `memory_get`
3. **索引层**
   - SQLite 索引
   - 可选 embedding
   - 可选 QMD backend

最重要的一句：

**真正持久化的是 Markdown 文件；检索只是为了把相关片段再拉回模型上下文。**

所以你平时最应该关注的是：

- 工作区里的记忆文件写没写进去
- 写得是否合理
- 检索配置是否能正常工作

而不是把“记忆”理解成一个神秘的 AI 黑盒。

---

## 2. 记忆文件的组织形式是什么

官方推荐的默认结构是这样的：

```text
<workspace>/
  AGENTS.md
  SOUL.md
  TOOLS.md
  USER.md
  IDENTITY.md
  HEARTBEAT.md
  MEMORY.md
  memory/
    2026-03-05.md
    2026-03-06.md
    2026-03-07.md
```

其中最关键的是两类。

### 2.1 `MEMORY.md`

这是长期记忆文件，适合放：

- 长期偏好
- 稳定习惯
- 重要背景
- 长期项目约定
- 持久规则
- 经过沉淀后的结论

它应该像“提炼过的长期笔记”，而不是流水账。

### 2.2 `memory/YYYY-MM-DD.md`

这是短期/日记式记忆，适合放：

- 今天发生了什么
- 今天做过什么决定
- 临时讨论结果
- 今天新增的待办或状态变化
- 暂时还没沉淀到长期记忆的内容

它更像每天的工作日志。

---

## 3. 我如果直接查看这些文件，应该怎么读

这是个很实际的问题。

### 推荐阅读顺序

如果你直接进工作区看文件，建议这样读：

1. 先看 `MEMORY.md`
   - 它是浓缩版长期记忆
2. 再看最近两天的 `memory/YYYY-MM-DD.md`
   - 比如 `memory/2026-03-06.md` 和 `memory/2026-03-05.md`
3. 如果还需要更久的上下文，再往前翻 daily memory

### 你读这些文件时应该怎么理解

可以把它们理解成：

- `MEMORY.md`：整理后的长期脑图
- `memory/*.md`：每天的原始工作日志

所以：

- 想快速知道“这个 Agent 长期记得什么”，看 `MEMORY.md`
- 想知道“最近两天发生了什么”，看 `memory/最近日期.md`

### 你不需要优先看 SQLite 索引

OpenClaw 还会在状态目录里维护索引数据库，例如：

- `~/.openclaw/memory/<agentId>.sqlite`

但这只是检索索引，不是源数据。  
对于普通用户来说：

- **Markdown 文件才是你该看的内容**
- SQLite 只是在排查检索问题时才需要关心

---

## 4. 哪些记忆会自动加载，哪些不会

这是最容易搞混的地方。

## 4.1 会自动进入 prompt 的

根据 `docs/concepts/system-prompt.md` 和 `src/agents/workspace.ts` 当前主干源码，OpenClaw 的 bootstrap/context 注入里会把这些文件作为“工作区上下文”处理：

- `AGENTS.md`
- `SOUL.md`
- `TOOLS.md`
- `IDENTITY.md`
- `USER.md`
- `HEARTBEAT.md`
- `BOOTSTRAP.md`（如果存在）
- `MEMORY.md` 或 `memory.md`（如果存在）

也就是说：

**`MEMORY.md` 属于会被注入到上下文的文件。**

## 4.2 不会自动注入的

`memory/*.md` 这些 daily memory 文件，**不会自动注入 prompt**。

官方文档明确写了：

- `memory/*.md` 是通过 `memory_search` / `memory_get` 按需访问的
- 它们默认不直接占上下文窗口

这点很重要，因为它决定了：

- `MEMORY.md` 应该尽量精炼
- `memory/*.md` 可以更偏日志和流水

## 4.3 关于“MEMORY.md 只在私聊主会话加载”的说明

这里有一个你必须知道的细节：**文档和当前源码在这个点上并不是完全一致。**

文档里多次强调：

- `MEMORY.md` 适合作为 main/private session 的长期记忆
- 群聊/共享上下文里不建议依赖它

但当前源码里 `src/agents/workspace.ts` 的 bootstrap 过滤逻辑，明确只对：

- subagent
- cron

做了记忆文件过滤；对普通 session 并没有把 `MEMORY.md` 排除掉。

所以更稳妥的理解是：

1. **设计意图上**，`MEMORY.md` 应该更偏私有长期记忆
2. **当前源码行为上**，普通非 subagent / 非 cron session 可能仍然把它注入上下文

这意味着最佳实践是：

- 不要把极敏感内容乱放进 `MEMORY.md`
- 如果你同一个 agent 要同时跑群聊、共享渠道和私聊，最好做 agent 隔离
- 真正“全渠道都必须知道”的稳定规则，应优先放 `AGENTS.md` / `USER.md`

这一点我建议你按“源码优先、文档为意图参考”的方式理解。

---

## 5. `memory_search` 和 `memory_get` 的机制是什么

这是记忆系统的核心工具层。

## 5.1 `memory_search` 是干什么的

`memory_search` 是检索工具，不是读全文工具。

它会：

1. 对 `MEMORY.md` 和 `memory/**/*.md` 建索引
2. 把文件切成多个块（chunk）
3. 搜索与你问题最相关的块
4. 返回这些块的：
   - 片段文本
   - 文件路径
   - 起止行号
   - 分数
   - provider/model/fallback 信息

从中文文档和源码可以确认，它的 chunk 粗略策略是：

- 目标约 400 token 一块
- 80 token overlap
- 返回片段上限约 700 字符

也就是说，`memory_search` 更像：

**“帮 Agent 先从所有记忆里找相关片段”**

而不是：

**“把所有记忆全文再塞进 prompt”**

## 5.2 `memory_get` 是干什么的

`memory_get` 是定点读取工具。

它通常在 `memory_search` 之后使用，用来：

- 读取某个具体文件
- 从指定行开始读
- 只读指定行数

典型流程是：

1. 先 `memory_search`
2. 发现相关内容在 `MEMORY.md#L20-L35`
3. 再 `memory_get(path="MEMORY.md", from=20, lines=16)`

这样可以把上下文控制得更小，不至于一次性读全文件。

## 5.3 `memory_get` 的读取范围有限制吗

有。

从 `src/memory/manager.ts` 可以看出，`memory_get` 默认只允许读取：

- `MEMORY.md`
- `memory.md`
- `memory/` 目录下的 Markdown 文件
- 或你显式配置在 `memorySearch.extraPaths` 里的 Markdown 文件

这意味着它不是任意文件读取器，而是**受限制的记忆读取器**。

## 5.4 如果今天的 daily memory 还不存在会报错吗

不会硬报错。

官方文档和源码都说明：

- 如果文件不存在，`memory_get` 会优雅返回空文本
- 不会直接因为 `ENOENT` 崩掉

这对新手很友好：

- 你今天还没记任何东西
- 查 `memory/2026-03-06.md`
- 它会返回空，而不是直接出错

---

## 6. 需要配置 embedding 模型吗

答案是：**看你要什么效果。**

### 情况 1：你想要真正的语义检索

那就要 embedding。

也就是说，如果你希望：

- 词不一样也能搜到
- “上次讨论的部署方案” 能搜到 “服务器迁移方案”
- “我的偏好” 能搜到“我喜欢简短回答”

那需要有 embedding provider。

### 情况 2：你只想做关键词检索

那在某些情况下，不一定非要 embedding。

源码里 `src/memory/manager.ts` 和 `src/memory/embeddings.ts` 显示：

- 如果 embedding provider 不可用
- 但 FTS（全文检索）可用
- 会退化成 FTS-only mode

也就是说：

- 没 embedding，不代表完全不能搜
- 但会更像关键词检索，而不是语义检索

### 总结一下

- **想要好用的语义记忆检索：建议配置 embedding**
- **没配置 embedding：有时还能关键词搜，但体验会弱很多**

---

## 7. OpenClaw 的 embedding provider 怎么选

`docs/concepts/memory.md` 和 `src/agents/memory-search.ts` 写得很清楚。

如果你不手动指定 provider，OpenClaw 会自动选择：

1. `local`，前提是你配置了 `memorySearch.local.modelPath` 且模型文件存在
2. `openai`
3. `gemini`
4. `voyage`
5. `mistral`
6. 否则 memory search 处于不可用或弱化状态

注意：

- `ollama` 支持，但不会在 auto 模式里默认自动选中
- Codex OAuth 只管 chat/completions，不等于 embeddings 权限
- 所以如果你想用 OpenAI embeddings，仍然要真实 API key

### 最常见的几种方案

#### 方案 A：OpenAI embeddings

优点：

- 配置普遍
- 效果稳定

缺点：

- 要真实 API key
- 不是 Codex OAuth 就能替代的

#### 方案 B：Gemini embeddings

优点：

- 也是官方支持的一等路径

缺点：

- 也需要相应 API key

#### 方案 C：local embeddings

优点：

- 更本地化
- 不依赖远程 API

缺点：

- 要自己准备模型
- 初次配置稍麻烦

### 一个典型本地配置示例

```json5
{
  agents: {
    defaults: {
      memorySearch: {
        provider: "local",
        local: {
          modelPath: "D:/models/embedding-model.gguf"
        },
        fallback: "none"
      }
    }
  }
}
```

### 一个典型 Gemini 配置示例

```json5
{
  agents: {
    defaults: {
      memorySearch: {
        provider: "gemini",
        model: "gemini-embedding-001",
        remote: {
          apiKey: "YOUR_GEMINI_API_KEY"
        }
      }
    }
  }
}
```

---

## 8. 记忆索引是怎么更新的

你可以把记忆索引理解成“辅助搜索数据库”。

### 源数据在哪里

源数据在：

- `<workspace>/MEMORY.md`
- `<workspace>/memory/*.md`

### 索引在哪里

默认索引在：

- `~/.openclaw/memory/<agentId>.sqlite`

### 索引什么时候更新

官方文档和源码说明大致是：

- 会监视 `MEMORY.md` 和 `memory/`
- 改动后会标记索引 dirty
- 可在 session start / search / interval 时触发异步同步
- `watchDebounceMs` 默认约 1500ms

所以你改完记忆文件后：

- 不一定是立刻百分百完成索引
- 但通常很快就会被 watcher + 异步同步纳入

### 你可以手动触发/检查吗

可以。

CLI 文档给了这些命令：

```bash
openclaw memory status
openclaw memory status --deep
openclaw memory status --deep --index --verbose
openclaw memory index --verbose
openclaw memory search "release checklist"
```

这些命令对排查问题非常有用。

---

## 9. Agent 把内容“记住”的原理到底是什么

这是你最关心的实操问题，我直接说结论。

**OpenClaw 没有一个专门的“memory_write”魔法接口。**

当前主干里，面向 Agent 的记忆专用工具主要是：

- `memory_search`
- `memory_get`

也就是说：

- **读记忆**：有专门工具
- **写记忆**：主要靠通用文件工具去修改 Markdown 文件

所以当你让 Agent “记住这件事”时，底层实际发生的通常是：

1. Agent 决定把信息写到 `MEMORY.md` 或 `memory/YYYY-MM-DD.md`
2. 它使用普通文件编辑/写入工具
3. 工作区文件被改写
4. watcher / sync 更新索引
5. 后续检索时通过 `memory_search` / `memory_get` 找回来

所以它“记住”不是因为脑内状态变了，而是因为**工作区文件被改了**。

---

## 10. 我应该怎么跟 Agent 说，才能让它记长期还是短期记忆

建议你明确说清楚类型。

### 要写长期记忆时

直接这样说：

- “把这个偏好写进 `MEMORY.md`。”
- “把这个长期约定保存到长期记忆。”
- “把这条规则记进 `MEMORY.md`，以后按这个来。”

适合写长期记忆的内容：

- 我喜欢怎样的回答风格
- 我长期的项目约定
- 我常用的工作偏好
- 某个长期有效的禁忌或边界
- 值得长期保留的背景信息

### 要写短期/当天记忆时

直接这样说：

- “把今天这个决定记到今天的 memory 文件里。”
- “把这次会议结论记到 `memory/2026-03-06.md`。”
- “把今天临时改动记成短期记忆，不要放长期记忆。”

适合写短期记忆的内容：

- 今天发生的事情
- 今天的临时决定
- 本周可能会变的状态
- 还没确认是否值得长期保留的事项

---

## 11. 我怎么验证它真的记录下来了

这是实操里最重要的一步。

推荐你每次都让它“写入 + 回执 + 验证”。

### 最稳妥的说法

你可以这样说：

- “把这条长期偏好写入 `MEMORY.md`，然后把新增内容贴给我看。”
- “把今天这个决定记到今天的 memory 文件里，然后告诉我写到了哪一行。”
- “记完之后，再用 `memory_get` 验证一次给我看。”

### 你可以怎么人工验证

#### 方法 1：直接看工作区文件

最直接：

- 打开 `<workspace>/MEMORY.md`
- 或打开 `<workspace>/memory/2026-03-06.md`

看它是不是真的写进去了。

#### 方法 2：让 Agent 用 `memory_get` 回读

比如你可以让它：

- 先写入
- 再 `memory_get` 读取对应文件片段
- 把结果回给你

#### 方法 3：用 CLI 查

```bash
openclaw memory search "你的关键词"
```

如果索引已经更新，应该能搜到相关片段。

### 最靠谱的验证流程

我推荐你以后固定这样操作：

1. 明确要求写入长期或短期记忆
2. 要求它说明写到了哪个文件
3. 要求它用 `memory_get` 回读新内容
4. 你再人工看一眼文件

这样几乎不会出错。

---

## 12. 如果我不明确说，它会不会自动记录

答案是：**不保证。**

这是一个非常重要的边界。

### 12.1 默认情况

如果你不明确说“记住”或“写入 memory”，它有可能：

- 记录
- 也可能不记录

没有硬保证。

### 12.2 会让它更可能记录的因素

主要有这些：

1. 你明确要求它记录
2. 你的 `AGENTS.md` 明确写了什么情况下要写 memory
3. session 快要 compaction 时，系统可能触发 silent memory flush 提醒
4. 你的工作流本身反复强调“重要事项要落盘”

### 12.3 哪个是唯一稳妥的方法

**对重要内容，一定明确说。**

比如：

- “这条很重要，记到长期记忆。”
- “这个只是今天临时决定，写短期记忆。”

如果你不说，不能把“没记住”完全怪到模型头上，因为从机制上它本来就不是强制自动写入。

---

## 13. 让它自动更愿意记忆，原则能写进 `AGENTS.md` 吗

可以，而且我建议写。

这是很好的做法。

你可以把这类原则写进 `AGENTS.md`：

```md
## Memory Rules

- 当用户说“记住”“以后都这样”“长期偏好”时，写入 `MEMORY.md`。
- 当用户说“今天先这样”“本次会议结论”“临时决定”时，写入当天的 `memory/YYYY-MM-DD.md`。
- 写入记忆后，优先告诉用户写入了哪个文件。
- 对重要记忆，写完后再用 `memory_get` 验证一次。
- 如果不确定该写长期还是短期记忆，先问用户。
```

这样做的好处是：

- 你不用每次从零提醒
- Agent 会把“何时该记忆”当成稳定工作规则
- 记忆行为更可预期

### 但要注意

即使你写进了 `AGENTS.md`，对特别重要的信息，我仍建议你在聊天里明确说一次。  
因为“规则存在”和“这次一定执行”不是完全同一件事。

---

## 14. MEMORY.md 和 daily memory 应该怎么写，才最好用

我建议这样组织。

## 14.1 `MEMORY.md` 推荐结构

```md
# Long-Term Memory

## User Preferences
- 用户喜欢先给结论，再给细节。
- 用户偏好中文交流，代码注释尽量英文。

## Stable Project Rules
- 修改代码前先定位入口，再做验证。
- 高风险操作先说明影响。

## Persistent Context
- 用户主要工作目录在 `D:\code`。
- 常用项目是 openclaw、anzhuang。

## Important Ongoing Threads
- 正在持续整理 OpenClaw 使用手册。
- 正在完善 agent 调教方法论。
```

特点：

- 分区清楚
- 条目短
- 只保留稳定内容
- 不写日记流水

## 14.2 `memory/YYYY-MM-DD.md` 推荐结构

```md
# 2026-03-06

## Today
- 今天补写了 OpenClaw Agents 聚焦文档。
- 用户想进一步整理记忆机制和实操指南。

## Decisions
- 重要偏好：后续说明文档以中文为主。
- 对记忆相关说明，需要给到原理 + 实操 + 最佳实践。

## Open Loops
- 还要补 workspace 实际模板建议。
- 可能后续继续整理 SOUL.md / AGENTS.md 初稿。
```

特点：

- 像工作日志
- 可追加
- 不必太讲究结构完美
- 重点是“今天发生了什么”

---

## 15. 你该如何把记忆真正用起来

这是最实用的一部分。

### 推荐工作流

#### 场景 1：用户偏好

你说：

- “以后默认先给结论再展开，把这条写进长期记忆。”

Agent 应做：

- 写入 `MEMORY.md`
- 回执确认
- 最好再回读一次

#### 场景 2：今天的临时决定

你说：

- “今天这个阶段先不要动旧文档，把这个决定记到今天的 memory 文件里。”

Agent 应做：

- 写入 `memory/2026-03-06.md`
- 告诉你写入位置

#### 场景 3：可复用的工作规范

你说：

- “以后做源码分析都先看入口、再看文档、最后看 git 历史，这条放进 AGENTS.md，不要放 MEMORY.md。”

这是非常好的区分：

- 工作规则放 `AGENTS.md`
- 偏好/事实放 `MEMORY.md`
- 当天状态放 daily memory

#### 场景 4：你不确定该写哪

你可以直接说：

- “你判断一下这条更适合长期记忆还是今天记忆，并说明原因后再写。”

这会比一句“记住这个”更稳定。

---

## 16. 最佳实践

### 最佳实践 1：重要内容明确要求“写入哪类记忆”

不要只说“记住这个”。

更好的说法：

- “记到长期记忆”
- “记到今天的 memory 文件”
- “写进 AGENTS.md，不是 memory”

### 最佳实践 2：写完一定要求回执

这是防止“以为写了，实际没写”的最好办法。

### 最佳实践 3：长期记忆保持精炼

`MEMORY.md` 太大，会增加每轮上下文负担。  
要把它当作“精选摘要”，不是“全量历史仓库”。

### 最佳实践 4：daily memory 允许更松散

短期记忆文件本来就是工作日志，没必要像长期记忆一样精炼。

### 最佳实践 5：用 `AGENTS.md` 约束写记忆原则

比如：

- 什么进长期记忆
- 什么进短期记忆
- 写完要不要回读验证

这些都很适合写成稳定规则。

### 最佳实践 6：定期把 daily memory 提炼进 `MEMORY.md`

这其实和人写周报、做复盘很像。

- 日常先写 daily memory
- 过几天回头看
- 有价值的再沉淀到 `MEMORY.md`

这样 `MEMORY.md` 才不会越来越乱。

### 最佳实践 7：多人/群聊场景尽量隔离 agent

因为当前源码和部分文档在 `MEMORY.md` 自动注入边界上并不完全一致，最保险的办法不是赌规则，而是：

- 敏感私聊和公开群聊尽量别共用同一个 agent
- 真要共用，也别把过于敏感的信息放在 `MEMORY.md`

---

## 17. 常见误解

### 误解 1：memory_search 就是“记忆本体”

不是。  
它只是检索接口，记忆本体是 Markdown 文件。

### 误解 2：没有 embedding 就完全不能用记忆

不完全对。  
没有 embedding 时，某些情况下还能退化成 FTS-only 的关键词检索。  
但语义效果会明显变弱。

### 误解 3：我说过一次，系统就一定永久记住

不对。  
只有写入文件的东西，才是持久记忆。

### 误解 4：`MEMORY.md` 和 `memory/*.md` 是一回事

不是。

- `MEMORY.md`：长期、精选
- `memory/*.md`：每日、流水

### 误解 5：写记忆是某个专门隐藏 API

不是。  
当前实现里，写记忆主要还是普通文件写入/编辑工具完成的。

---

## 18. 给你的最终建议

如果你准备真正把 OpenClaw 的记忆用起来，我建议你就按下面这套执行：

1. 在 workspace 里补齐 `MEMORY.md` 和 `memory/` 目录。
2. 在 `AGENTS.md` 里写清楚“长期记忆 vs 短期记忆”的写入原则。
3. 重要事情明确要求：写长期还是写短期。
4. 每次写完都要它回执并回读验证。
5. 用 `openclaw memory status --deep --index --verbose` 和 `openclaw memory search` 做排查。
6. 定期整理 `MEMORY.md`，别让它越来越臃肿。
7. 如果你在意隐私和群聊隔离，优先用多 agent，而不是赌单 agent 的上下文边界。

如果只留一句最核心的话，那就是：

**OpenClaw 的记忆不是“让 AI 记住”，而是“让 AI 把重要内容写进可检索的 Markdown 文件，再在需要时拉回来”。**

一旦你按这个思路使用，它就会非常清楚、可控，而且容易验证。
