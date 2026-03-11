# OpenClaw 多智能体知识共享与归档：别让每个 agent 都变成信息孤岛

副标题：把 `sessions`、`workspace`、`QMD`、`memory scope`、共享知识层、归档层一次讲明白

## 1. 为什么这一章很重要

当你开始有多个 agent 时，最容易冒出来的疑问就是：

- `main`、`weekly-assistant`、`research-agent` 各自记了什么
- 我跟某个 agent 聊出来的内容，以后还要不要重新再说一遍
- 开了 `QMD` 以后，是不是所有 agent 就自动共用一个大脑了
- 某个实验 agent 不用了，聊天记录和工作文件要不要删
- 以后 agent 越来越多，会不会每个都变成信息孤岛

这些问题如果不讲清楚，后面做多 agent，迟早会遇到这几种情况：

- 同样的信息反复输入
- 不知道该把什么写进哪个地方
- 某个 agent 退役后，有价值的内容一起丢掉
- 以为开了检索就自动全局共享，结果实际并没有

这一章就是专门讲这些边界的。

---

## 2. 先用一个最通俗的比喻：把多个 agent 当成多个同事

如果把你的 OpenClaw 系统想成一个小团队，会更好理解。

### `sessions`

它像：

- 每个同事自己的聊天记录
- 每次会话的原始录音

特点是：

- 原始
- 细碎
- 上下文很强
- 适合留底，不适合直接当长期知识库

### `workspace`

它像：

- 每个同事自己的工位
- 自己桌上的文件夹

里面通常会有：

- daily
- weekly
- 草稿
- 项目文件
- `MEMORY.md`

它更像“这个 agent 正在工作的现场”。

### `QMD`

它像：

- 这个同事自己的档案检索系统

它不是内容本身，而是帮 agent 去搜：

- 自己的聊天记录
- 自己的 memory
- 自己被允许索引的文件

### `memory scope`

它像：

- 档案室的准入规则

它解决的是：

- 什么内容允许进记忆库
- 什么聊天允许被索引
- 这个 agent 能检索哪类材料

它不是“全局共享开关”。

### `knowledge/`

它像：

- 团队共享知识库

这里放的不是原始聊天，而是整理过、以后别的 agent 也值得看的稳定信息。

### `archive/`

它像：

- 退役项目档案室

某个 agent 不再活跃时：

- 原始聊天
- 旧 workspace
- 旧草稿

都可以先归档到这里，而不是立刻删掉。

---

## 3. 一句话先讲清：QMD 到底是不是“全局大脑”

默认情况下，不是。

更准确地说：

- `QMD` 是检索能力
- 但通常是“每个 agent 各有各的检索库”

所以：

- 开了 `QMD`
- 不等于所有 agent 自动共享所有聊天

你可以把它理解成：

- `weekly-assistant` 有自己的检索器
- `research-agent` 有自己的检索器
- `main` 也有自己的检索器

它们默认不是自动混成一锅。

即使你后来把“共享知识目录”统一接进了 `QMD`，也还要再分清一件事：

- 共享路径是否已经挂进系统
- 某个 agent 有没有权限和习惯去查它

这两件事都成立，那个 agent 才算真的“能用共享知识”。

---

## 4. 再讲清一个常被误会的概念：`memory scope`

很多人看到 `scope`，会直觉以为它是在控制：

- “要不要全局共享”

其实更接近：

- “什么内容允许进入这个 agent 的记忆和检索范围”

所以 `memory scope` 更像：

- 准入规则
- 索引边界
- 检索边界

它不是：

- 全局共享总开关
- 所有 agent 自动共脑的开关

一句话：

**`QMD` 管怎么搜，`memory scope` 管什么能进来被搜。**

---

## 5. 多个 agent 到底各自存了什么

最稳的理解是：每个 agent 至少有 3 套东西。

### 第一套：原始聊天记录

常见位置类似：

```text
~/.openclaw/agents/<agent-id>/sessions/
```

这是：

- 原始会话
- 原始问答
- 原始工具调用痕迹

它的价值在于：

- 留底
- 复盘
- 以后重新抽取信息

但它不适合直接做“共享知识层”。

### 第二套：工作现场

常见位置类似：

```text
~/.openclaw/workspace-<agent-id>/
```

这里更像：

- 这个 agent 的办公桌

会放：

- `AGENTS.md`
- `SOUL.md`
- `MEMORY.md`
- `memory/YYYY-MM-DD.md`
- `memory/weekly/current-week.md`
- `drafts/`
- 其他项目文件

### 第三套：检索索引

常见位置类似：

```text
~/.openclaw/agents/<agent-id>/qmd/
```

这里不是原文，而是索引。

可以把它理解成：

- 档案目录
- 倒排索引
- 检索数据库

---

## 6. 为什么我不建议“所有 agent 直接共享所有 raw chat”

因为 raw chat 有 4 个天然问题。

### 1. 太碎

很多聊天只在当时有意义，过几周再看，信息密度不高。

### 2. 上下文太强

当时说得通的话，换一个 agent、换一个时间，不一定还成立。

### 3. 容易互相矛盾

你今天说的想法，可能明天就推翻了。

### 4. 噪音太大

如果以后每个 agent 都去搜所有 raw chat，很容易把无关内容也拉进来。

所以：

**raw chat 更适合留底，不适合直接做全局共享层。**

---

## 7. 真正适合跨 agent 共享的，应该是什么

应该是“整理过的稳定信息”，而不是“所有原始会话”。

最适合被共享的内容通常有这些：

- 当前工作盘子的概览
- 长期不变或短期较稳定的约束
- 关键项目背景
- 书稿方向和写作原则
- 已经验证过的方法
- 某个退役 agent 提炼出来的结论

这类内容更适合写成文件，放进统一的共享目录。

---

## 8. 我最推荐的做法：做成 4 层结构

### 第 1 层：各 agent 的本地工作层

这一层保留原始现场。

例如：

- `weekly-assistant` 负责 daily 和 weekly
- `research-agent` 负责研究记录和测评材料
- `main` 负责总入口和一些通用文件

这一层不要强求全共享。

### 第 2 层：共享知识层

这一层放整理过的稳定知识。

我最推荐直接放到 `main` 的 workspace 下，比如：

```text
~/.openclaw/workspace/knowledge/
```

为什么推荐放这里：

- `main` 往往是长期存在的总入口
- 最适合承接跨 agent 的共识信息
- 以后新的 agent 也容易约定去读这里

### 共享知识不是“所有 agent 默认全开”

这是实战里非常关键的一条经验。

很多人会想：

- 既然都做了共享知识层
- 那是不是每个 agent 都应该默认能搜

表面看这样最省事，实际上往往会带来新的问题：

- 噪音变大
- 不相关的旧信息被拉进来
- 专项 agent 更容易串味
- 实验 agent 会把上下文越用越脏

更稳的做法不是：

- 所有 agent 都默认读全部共享知识

而是：

- 共享知识路径可以统一挂载
- 但共享知识的检索权限要按角色分层授权

通俗一点说：

- `memory.qmd.paths` 像“把共享资料室接到整栋楼里”
- `memory_search`、`memory_get` 像“把钥匙发给哪些同事”

只有共享路径接进来了，而且某个 agent 又拿到了检索权限，它才真的能在对话里去用这套共享知识。

### 我最推荐的分层授权方式

#### `main`

建议：

- 一定能检索共享知识
- 也能检索自己的 workspace 和自己的 sessions

因为它通常是：

- 默认总入口
- 综合判断入口
- 跨主题协调入口

#### `weekly-assistant`

建议：

- 可以检索共享知识
- 但主要读取和当前工作盘子有关的稳定资料

例如：

- `knowledge/work/current-context.md`
- `knowledge/work/long-term-constraints.md`
- 关键项目背景

不要让它默认把大量历史归档也一起背上。

#### `research-agent`

建议：

- 可以检索共享知识
- 但重点放在研究方法、业务边界、已有稳定结论

例如：

- `knowledge/research/`
- 书里已经跑通过的定位口径
- 已提炼过的研究方法

这样它更容易保持研究线的清晰度。

#### `archive-search`

建议：

- 检索范围最大
- 负责全局历史搜索

它最适合负责：

- 跨 agent 找旧资料
- 找某个判断最早来自哪里
- 查退役 agent 留下了什么

#### 临时 agent / 实验 agent

建议：

- 默认不要开共享知识检索

等它真的出现明确需求时，再加：

- `memory_search`
- `memory_get`

这样能显著减少上下文污染。

### 这套设置到底怎么落地

如果你想让共享知识“可用但不混乱”，最稳的设置顺序是：

1. 先在配置里把共享知识目录统一挂进 `memory.qmd.paths`
2. 只给长期 agent 开 `memory_search`、`memory_get`
3. 如果某个 agent 还需要稳定读取少量共享文件，再在它的 `AGENTS.md` 里明确写“优先读取哪些文件”
4. 共享知识层只放整理过的稳定信息，不要把 raw chat 直接倒进去

这样做的好处是：

- 共享知识有统一入口
- 不是每个 agent 都要背全部历史
- 长期 agent 能复用共识
- 临时 agent 不容易被旧上下文污染

### 第 3 层：主入口层

这一层通常就是 `main`。

它的职责不是：

- 吞掉所有 raw chat

而是：

- 读取共享知识层
- 做综合判断
- 充当总入口

### 第 4 层：归档层

这一层放已经退役或低频使用 agent 的原始材料。

例如：

```text
~/.openclaw/archive/agents/<agent-id>/
```

可以放：

- `sessions/`
- 原 workspace 副本
- 老草稿

这一层平时不常用，但以后要回看原文时很有价值。

---

## 9. 你可以直接照抄的目录结构

如果你已经开始有多个 agent，我建议至少先建这两块。

### 共享知识层

```text
~/.openclaw/workspace/
  knowledge/
    work/
      current-context.md
      long-term-constraints.md
    book/
      openclaw-book-direction.md
    research/
      key-findings.md
    decisions/
      major-decisions.md
    archive/
      retired-agent-summaries/
```

### 原始归档层

```text
~/.openclaw/archive/
  agents/
    personal-ceo/
      sessions/
      workspace/
    some-old-agent/
      sessions/
      workspace/
```

这里要注意：

- `knowledge/` 放的是整理过、以后还要复用的内容
- `archive/` 放的是原始留档

不要把它们混成一个目录。

---

## 10. `main`、`weekly`、`research` 最稳的分工

如果你已经有多个 agent，最容易落地的分工通常是这样。

### `main`

负责：

- 总入口
- 读取共享知识层
- 跨主题协调
- 综合判断

不负责：

- 吞掉所有 agent 的 raw chat

### `weekly-assistant`

负责：

- today / daily / weekly
- 进展记录
- 插单变化
- 明天第一步

它更像：

- 执行秘书

### `research-agent`

负责：

- 专题研究
- 搜索验证
- 资料汇总
- 研究结论沉淀

它更像：

- 研究专员

所以最稳的工作流通常不是：

- 大家都看所有内容

而是：

1. 每个 agent 先维护自己的工作现场
2. 真正要跨 agent 共享的内容，提炼进 `knowledge/`
3. `main` 读取 `knowledge/` 做综合使用

---

## 11. 一套已经跑通过的实战结构

如果你不想停在概念层，最容易落地的一套结构其实就是：

- `main`
- `weekly-assistant`
- `research-agent`
- `archive-search`

### `main`

建议继续做：

- 默认主入口
- 日常综合助手
- 共享知识入口

更适合它的方向是：

- 保留默认主 Agent 思路
- 工具面尽量完整
- 发现稳定重复场景后，再拆专用 agent 或 Skill

### `weekly-assistant`

建议继续做：

- daily / weekly
- 进展记录
- 插单收口
- 明天第一步

### `research-agent`

建议继续做：

- 专题研究
- 搜索验证
- 证据链沉淀

### `archive-search`

如果你已经开始有：

- 活跃 agent
- 退役 agent
- 共享知识层

那很值得单独做一个：

- 低频使用的全局历史搜索器

它最适合负责：

- 搜以前聊过没有
- 搜某个判断最早来自哪里
- 搜退役 agent 留下了什么
- 跨多个 agent 查旧资料

它不适合负责：

- 日常主聊天
- 优先级判断
- 经营决策

一句话：

**`main` 负责当前，`archive-search` 负责历史。**

---

## 12. 渠道路由变了，为什么有时不需要重新 pairing

这个点很容易被误会。

很多人会以为：

- “我把消息从 agent A 换到 agent B，就应该重新 pairing”

其实不一定。

因为这里是两层事：

### pairing 解决的是

- 谁可以和这个渠道账号说话

### binding 解决的是

- 这条消息应该路由到哪个 agent

所以如果你做的只是：

- 保持同一个飞书机器人账号
- 只是把它从 `personal-ceo` 改绑到 `main`

那很多时候不需要重新 pairing。

因为你改的是：

- 路由

不是：

- 渠道账号本身的 DM 准入审批

换句话说：

**pairing 更偏渠道账号层，binding 更偏 agent 路由层。**

---

## 13. 某个 agent 不用了，到底该怎么处理

这一点很关键。

很多人会想直接：

- 删 agent
- 清 workspace

但更稳的顺序其实是：

### 第 1 步：先提炼总结

先把这个 agent 里以后还值得复用的内容写成总结文件。

例如：

```text
knowledge/archive/retired-agent-summaries/personal-ceo-summary-2026-03.md
```

里面只写：

- 稳定结论
- 值得复用的方法
- 长期约束
- 以后还会用到的判断口径

### 第 2 步：再做原始归档

把原始内容搬到：

```text
~/.openclaw/archive/agents/<agent-id>/
```

保留：

- `sessions`
- 原 workspace

### 第 3 步：最后再移除活跃配置

这时你再从活跃 agent 列表里移除它，会更稳。

这样做的结果是：

- 活跃区更干净
- 真正有价值的内容没丢
- 原始材料以后还能翻

---

## 14. 原始归档到底有没有必要一直保留

可以把它理解成 3 层温度。

### 热层

就是你现在还在用的共享知识层。

例如：

- `knowledge/work/`
- `knowledge/book/`
- `knowledge/research/`

### 温层

就是退役 agent 的原始归档。

例如：

- `archive/agents/personal-ceo/`

这一层平时不常看，但以后想复盘、抽素材时很有用。

### 冷层

如果一段时间后你确认：

- 该提炼的都提炼完了
- 原始内容也很久没再翻

这时再考虑：

- 压缩备份
- 或彻底删除

所以：

**不是所有原始记录都要永远放在活跃区，但也不建议一退役就立刻删。**

---

## 15. 关于 QMD，最实用的一句判断

你可以这样理解：

- `QMD` 不是自动的“全局共享脑”
- `QMD` 是一个 agent 的检索能力

如果你想要“全局感”，最稳的办法不是：

- 让所有 agent 去搜所有聊天

而是：

1. 先把值得共享的东西整理进 `knowledge/`
2. 再让需要的 agent 去读这些共享文件
3. 必要时再让它们各自的 `QMD` 去索引这些共享文件

所以最终是：

- `QMD` 解决“怎么搜”
- `knowledge/` 解决“共享什么”

---

## 16. 能不能让 `main` 变成总检索入口

可以，技术上是可行的。

如果你愿意，`main` 的检索范围完全可以同时包括：

- `main` 自己的 `sessions`
- `main` 自己的 `workspace`
- `main` 下面的 `knowledge/`
- 其他 agent 的部分工作文件
- 甚至其他 agent 的 `sessions` 转换结果

换句话说：

**`main` 可以做成“总搜索入口”，但不建议一上来就把所有东西都喂进去。**

### 更稳的 3 个层级

#### 第一层：一定要进 `main` 的

最推荐一定纳入 `main` 检索范围的，是：

- `main` 自己的 `sessions`
- `main` 自己的 `workspace`
- `main/knowledge/`

这层通常问题不大，也是最应该先做的。

#### 第二层：适合选择性接入的

这层更推荐接入“整理过的稳定资料”，例如：

- `weekly-assistant` 的 `memory/weekly/current-week.md`
- `research-agent` 的结论文件
- 某个退役 agent 的 summary 文件

这层很适合做跨 agent 共享。

#### 第三层：最谨慎接入的

这层就是其他 agent 的 raw `sessions`。

技术上可以做，但风险最大。

因为它们通常：

- 很长
- 很碎
- 很依赖当时语境
- 容易和后来结论冲突

### 最推荐的结论

如果你想让 `main` 变成总入口，最佳顺序通常是：

1. 先让 `main` 检索自己
2. 再让 `main` 检索 `knowledge/`
3. 最后只按需接入其他 agent 的少量稳定文件

不推荐一开始就让 `main` 默认搜所有 agent 的原始会话。

### 这样做的主要弊端

#### 1. 噪音会明显变大

库越大，搜出来的东西越容易夹杂无关内容。

#### 2. 旧判断会污染新判断

别的 agent 以前聊出来的结论，可能已经过期，但检索时还是会被搜到。

#### 3. 不同 agent 的角色边界会互相串味

例如：

- `weekly-assistant` 的执行语境
- `research-agent` 的探索语境

如果都被 `main` 直接吃进去，容易把本来不同职责的上下文混在一起。

#### 4. 检索质量可能下降

不是资料越多越好。

很多时候：

- 少一点
- 稳一点
- 更干净一点

反而更容易搜对。

#### 5. 后期维护更麻烦

你以后会遇到：

- 哪些目录要重建索引
- 哪些旧 agent 应该移除
- 哪些会话还值得保留

如果一开始全接，后面会越来越乱。

所以最稳的做法通常是：

- `main` 检自己的全部
- `main` 检共享知识层
- 其他 agent 的 raw `sessions` 只做按需接入，不做默认全量接入

---

## 17. 最容易踩的 5 个坑

### 1. 以为开了 `QMD` 就自动全局共享

实际通常不是。

### 2. 以为 `memory scope` 就是共享开关

它更像准入和索引规则。

### 3. 把 raw chat 当长期知识库

这样后面一定会乱。

### 4. 什么都塞给 `main`

`main` 适合做共享入口，不适合做垃圾堆。

### 5. 退役 agent 直接删除

这样最容易把以后还会用到的素材一起删掉。

---

## 18. 给落地用户的最简最佳实践

如果你不想一开始就做得很复杂，最推荐先做这 5 件事：

1. 保留少量长期 agent
   - 例如 `main`、`weekly-assistant`、`research-agent`
2. 每个 agent 继续维护自己的本地工作文件
3. 在 `main` 的 workspace 下建立 `knowledge/`
4. 只有“稳定、可复用”的内容才进入 `knowledge/`
5. 退役 agent 先提炼、再归档、最后再删除

---

## 19. 这一章的结论

把这几个概念记住就够了：

- `sessions`
  - 原始聊天记录
- `workspace`
  - 这个 agent 的工作现场
- `QMD`
  - 这个 agent 的检索器
- `memory scope`
  - 什么内容允许进入这个 agent 的记忆和检索范围
- `knowledge/`
  - 跨 agent 共享的整理后知识层
- `archive/`
  - 退役 agent 的原始归档层

所以真正稳的体系不是：

- 所有 agent 自动共享所有聊天

而是：

- 各 agent 有自己的本地现场
- 共享内容进入 `knowledge/`
- 退役内容进入 `archive/`
- `main` 作为总入口去读共享知识层

如果你把这套结构搭起来，多 agent 才会越用越清楚，而不是越用越乱。
