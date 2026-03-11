# OpenClaw 系统提示词与上下文注入：模型到底看到了什么

副标题：把 system prompt、工作区注入、session 历史、tool schema 和 `/context` 一次讲清楚

## 1. 为什么这一章很重要

很多人用 OpenClaw 用着用着，都会出现这些疑问：

- 我明明没再说一遍，它为什么还知道这些事？
- 我明明 `/new` 了，它为什么又像记得我今天做过什么？
- 为什么有时候它突然变笨，或者开始忘事？
- 为什么一个根文件写大了，整体体验就变差？
- 为什么明明只加了几个工具，token 消耗却明显上去了？

这些问题，表面看像“模型发挥不稳定”，本质上很多都和**上下文怎么组装**有关。

这一章的目标就是把这件事讲清楚：

- OpenClaw 每一轮到底给模型发了什么
- 哪些内容会自动注入
- 哪些内容不会自动注入
- Skills、工具、session 历史分别占哪一部分
- 你该怎么检查、怎么优化

---

## 2. 先记住一个总原则：上下文不是记忆

这是最容易混淆的一点。

### 上下文是什么

上下文是：

- 当前这一轮真正发给模型的全部内容

包括：

- 系统提示词
- 当前 session 历史
- 工具调用和工具结果
- 附件
- 注入的工作区根文件
- tool schema

### 记忆是什么

记忆更接近：

- 存在磁盘上、以后还能重新读回来的资料

例如：

- `MEMORY.md`
- `memory/*.md`
- `sessions/*.jsonl`

一句话：

**记忆是存储层，上下文是当前窗口里真正被模型看到的内容。**

这也是为什么：

- 你可以有很多记忆
- 但模型这一轮只能看到其中一部分

---

## 3. OpenClaw 每一轮的上下文，大致由哪几部分组成

最稳的理解是拆成 5 层。

## 第一层：OpenClaw 自己生成的 system prompt

这部分不是模型自带的，也不是你手写的。  
它是 OpenClaw 每一轮重新组装出来的。

官方文档明确写了 system prompt 里通常包括：

- Tooling
- Safety
- Skills
- Workspace
- Documentation
- Injected workspace files
- Sandbox
- Current Date & Time
- Heartbeats
- Runtime
- Reasoning

所以你可以把它理解成：

**OpenClaw 给模型写的一份“本轮工作说明”。**

## 第二层：自动注入的工作区根文件

这部分会进入 prompt 注入链路。

常见的是：

- `AGENTS.md`
- `SOUL.md`
- `TOOLS.md`
- `IDENTITY.md`
- `USER.md`
- `HEARTBEAT.md`
- `BOOTSTRAP.md`
- `MEMORY.md`

也就是说，这些文件不是“放在那里备用”，而是会真的被送进模型窗口。

## 第三层：当前 session 历史

包括：

- 你刚才说过的话
- agent 刚才回复过的话
- 可能还有 compaction 之后留下的摘要

这部分决定了：

- 为什么连续对话能接上
- 为什么长会话会越来越占窗口

## 第四层：工具调用与工具结果

包括：

- `read`
- `web_search`
- `web_fetch`
- `browser`
- `memory_search`
- `exec`

这些工具调用本身和返回结果，也会进入上下文。

所以：

- 工具不是“免费”的
- 调得越多，窗口压力越大

## 第五层：Skills 和工具 schema

很多人容易忽略这层，但它很重要。

### Skills

system prompt 里不会把 Skill 全文直接注入。  
默认更像是：

- 注入一个精简后的 skill list
- 告诉模型：需要时再去 `read` 对应的 `SKILL.md`

### tool schema

这是更容易被忽略的一部分。

工具不仅有“工具名称列表”，还有 JSON schema。  
这些 schema 也要算上下文成本。

所以有时候你会觉得：

- “我只是多开了几个工具”

但实际上：

- 你也让模型多背了一批工具定义

---

## 4. 哪些文件会自动注入，哪些不会

这件事一定要讲准。

## 会自动注入的

官方文档已经写得很明确，根文件注入通常包括：

- `AGENTS.md`
- `SOUL.md`
- `TOOLS.md`
- `IDENTITY.md`
- `USER.md`
- `HEARTBEAT.md`
- `BOOTSTRAP.md`
- `MEMORY.md` / `memory.md`

这些文件要特别注意：

- 它们会吃上下文
- 它们不是越长越好
- 你每多写一大段，几乎每轮都要为它付 token

## 不会自动注入的

下面这些不要想当然：

- `memory/YYYY-MM-DD.md`
- `memory/weekly/current-week.md`
- 普通工作区里的其他 `.md`
- `sessions/*.jsonl`

它们通常不会天然进入 prompt。

这也是为什么：

- 你不能指望“我把今天日志写在 daily 里，它每轮都会自动知道”

更常见的情况是：

- agent 在规则里被要求主动去读这些文件
- 或通过 `memory_search` / `memory_get` 再按需取回来

---

## 5. 为什么 `/new` 之后，它还是可能知道“今天发生了什么”

这是非常经典的困惑。

很多人会误以为：

- `/new` = 完全清空

其实不是。

`/new` 清掉的主要是：

- 旧聊天历史

但 `/new` 之后，OpenClaw 仍然会有这些东西：

1. 新一轮重新生成的 system prompt
2. 自动注入的根文件
3. Session Startup sequence

如果你的 `AGENTS.md` 规定了：

- 新会话开始先读今天 daily
- 再读昨天 daily
- 再读 `current-week.md`

那它即使 `/new` 了，也会重新把这些文件读进来。

所以更准确的话是：

**`/new` 清掉的是旧聊天，不是让 agent 变成一张白纸。**

---

## 6. sub-agent 为什么看起来“没主会话那么懂你”

这一点官方文档也讲得很清楚。

正常主会话和 sub-agent 的 prompt 不是同一套。

sub-agent 默认更接近：

- `minimal` prompt mode
- 注入更少的系统段落
- 只保留更少的工作区根文件

而且文档明确写了：

- sub-agent 通常只注入 `AGENTS.md` 和 `TOOLS.md`

这意味着：

- 它更轻
- 更快
- 但也更“没那么了解你”

所以如果你发现：

- 主 agent 很懂你的偏好
- sub-agent 反而比较机械

这通常不是 bug，而是设计选择。

---

## 7. `/context` 到底能帮你看什么

这是很多人没有真正用起来的排查工具。

如果你想理解“模型到底看到了什么”，最值得先记住这几个命令：

```text
/status
/context list
/context detail
/compact
/usage tokens
```

## `/status`

适合快速看：

- 当前窗口大概用了多少
- 当前 session 的设置

## `/context list`

适合看：

- 哪些根文件被注入了
- 每个文件大概占多大
- 有没有被截断
- skills 列表和 tools 大概占多少

## `/context detail`

适合进一步看：

- 哪些 tool schema 最重
- 哪些 skill entry 最重
- system prompt 本身大概多大

## `/compact`

适合：

- 长对话太长了
- 想把旧内容压成摘要，释放窗口

一句话：

**如果你怀疑“为什么它突然变傻了、忘了、慢了、贵了”，先看 `/context`，不要先怪模型。**

---

## 8. 为什么有时候只是改了几个文件，token 就明显变多

这里有 3 个最常见原因。

## 原因一：根文件写太长了

尤其是：

- `AGENTS.md`
- `SOUL.md`
- `TOOLS.md`
- `MEMORY.md`

这些是最容易长期膨胀的文件。  
一旦你把很多“本该放 daily 的内容”塞进根文件，每一轮都会更贵。

## 原因二：工具开太多了

工具不只是名字多了，还意味着：

- schema 更多
- tool list 更长

尤其是大工具，比如：

- `browser`
- `exec`

会比较重。

## 原因三：session 历史太长了

就算根文件没太大问题，长对话本身也会把窗口慢慢吃满。

这时就该考虑：

- `/compact`
- `/new`
- 把长期信息写回文件，而不是一直留在聊天里

---

## 9. 怎么优化 system prompt 和上下文，不容易改坏

这里给一套最稳的原则。

## 9.1 根文件只放长期有效信息

适合放：

- 稳定规则
- 长期偏好
- 长期角色设定

不适合放：

- 今天待办
- 本周流水账
- 临时实验要求

## 9.2 daily 和 weekly 放到对应文件，不要塞进根文件

也就是：

- `memory/YYYY-MM-DD.md`
- `memory/weekly/current-week.md`

这样可以把“长期规则”和“短期状态”分开。

## 9.3 不要把 Skill 全文思维方式复制进 `AGENTS.md`

Skill 是按需加载的。  
`AGENTS.md` 只保留最核心的分流和执行规则就够了。

## 9.4 当前状态问题先读文件，不先乱搜

例如：

- 今天我做了什么
- 本周重点是什么
- 当前计划是什么

这类问题更适合：

- 先读 today daily
- 再读 `current-week.md`

而不是一上来做模糊搜索。

## 9.5 怀疑成本过高时，先看 `/context detail`

不要凭感觉改。  
先看真正的大头是：

- 根文件
- tool schema
- 技能列表
- 还是长会话历史

---

## 10. 新手最容易踩的坑

### 坑一：把上下文和记忆当成一回事

不是。  
记忆能存在磁盘里，但不等于本轮一定看得到。

### 坑二：以为 daily 文件会自动注入

不会。  
daily 更常见的是按需读取。

### 坑三：根文件越详细越好

不对。  
根文件越长，每轮越贵，也越容易让重点被冲淡。

### 坑四：觉得 `/new` 后应该什么都不记得

不对。  
system prompt、根文件和启动序列还在。

### 坑五：只看回复内容，不看 `/context`

很多“体验问题”其实不是回答逻辑问题，而是上下文负载问题。

---

## 11. 本章最重要的结论

把下面这几句记住，后面你看 OpenClaw 的很多行为就不会再觉得玄学：

- system prompt 是 OpenClaw 每轮重建的，不是模型自带的
- 根文件会自动注入，所以要短、要稳
- daily 文件不会自动注入，通常靠主动读取
- `/new` 清的是旧聊天，不是全部上下文来源
- sub-agent 天生更轻，所以也更“没那么懂你”
- Skills 是按需读，tool schema 也会吃 token
- 真想排查“它为什么这样回答”，先看 `/context`

如果你接下来要继续深入，最适合顺着读的两章是：

- [15-OpenClaw-记忆与检索-从工作区文件到QMD.md](/D:/00容器/openclaw/book/15-OpenClaw-记忆与检索-从工作区文件到QMD.md)
- [16-OpenClaw-工作区根文件-AGENTS-SOUL-USER-IDENTITY-TOOLS-HEARTBEAT-BOOTSTRAP-MEMORY.md](/D:/00容器/openclaw/book/16-OpenClaw-工作区根文件-AGENTS-SOUL-USER-IDENTITY-TOOLS-HEARTBEAT-BOOTSTRAP-MEMORY.md)
