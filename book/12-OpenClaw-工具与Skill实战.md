# 第十四章：工具与 Skill 创建实战

## 1. 为什么这一章是独立的

前面几章里，你已经用过工具和 Skill：

- 第 5 章里，你亲手做了一个 `daily_brief_helper` Skill
- 第 11 章里，你看到了行业研究助手 Skill 的完整设计
- 第 12 章里，你搞清楚了 `web_search`、`web_fetch`、`browser`、`memory_search` 和 Skill 各自的分工

但上面这些都是分散在不同场景里的。这一章要做的事情是：

**把工具精选和 Skill 创建变成一套你随时可以复用的方法。**

### 1.1 本章实操场景

这一章你应该完成的真实场景是：

1. 完善第 5 章里那个最简 Skill，让它符合正式规范
2. 从零创建一个新 Skill，能在飞书里稳定触发
3. 学会调试 Skill 不生效的问题

### 1.2 本章产物

读完这一章，你手里至少应该有：

- 一个完善版的 `daily-brief-helper/SKILL.md`
- 一个新建的 Skill（或对行业研究 Skill 的完善版）
- 你能自己说清楚 Skill 调试的 3 步排查法

### 1.3 开始前先准备什么

- 你已经跑通过第 5 章的场景三（Skill 复用测试）
- 你至少看过第 12 章对工具分工的解释

## 2. Tool 和 Skill 的分工再强调

这个分工贯穿整本书，但值得在这里再用最短的话定义一次：

- **Tool** = 执行能力。由系统内置或插件提供。例如 `web_search`、`read`、`write`、`exec`、`browser`。
- **Skill** = 流程约束 + 行为说明。由你自己写。本质上是一份给 Agent 的可复用工作说明书。

两者如何配合：

- Skill 告诉 Agent "遇到这类任务时，先做什么、再做什么、不能做什么"
- Tool 让 Agent 真正有能力完成 Skill 里描述的动作

一句话：

**Skill 管流程，Tool 管执行。Skill 不会自动帮你搜网页，Tool 不会自动帮你先问清楚需求。**

## 3. Skill 的文件结构

### 3.1 最小结构

一个 Skill 至少需要一个文件：

```
skills/my-skill/SKILL.md
```

### 3.2 完整结构

更完整的 Skill 通常长这样：

```
skills/my-skill/
├── SKILL.md                    # 主文件，必须有
├── references/                 # 参考资料，可选
│   ├── style-guide.md
│   └── source-list.md
```

### 3.3 SKILL.md 的 frontmatter

frontmatter 是文件开头用 `---` 包裹的那段 YAML。它决定了 OpenClaw 怎么识别这个 Skill。

```yaml
---
name: my-skill-name
description: 一句话描述这个 Skill 做什么。
metadata: {"openclaw": {"requires": {"config": ["browser.enabled"]}}}
---
```

**必须有的字段：**

- `name`：Skill 的唯一标识。建议小写加连字符。
- `description`：一句话说明。Agent 用这个来判断什么时候该启用这个 Skill。

**建议补充的字段（在 metadata 里）：**

- `requires.config`：需要哪些配置项
- `requires.tools`：需要哪些工具可用（如 `web_search`、`browser`）
- `requires.env`：需要哪些环境变量（如 `BRAVE_API_KEY`）

> [!TIP]
> `description` 非常重要。Agent 主要靠它来判断"当前用户的需求是否应该触发这个 Skill"。如果写得太模糊，Skill 可能不会被触发；如果写得太泛，可能会应该不触发的时候也触发。

### 3.4 正文部分

frontmatter 之后就是 Markdown 正文。这部分是 Skill 的核心——你要在这里说清楚：

1. 什么时候使用这个 Skill
2. 使用时的具体步骤和规则
3. 什么时候不要用
4. 输出应该是什么格式

正文不需要是可执行代码，它更像一份"工作说明书"。

## 4. 从零完善一个 Skill：日报整理助手

第 5 章里你创建的 `daily-brief-helper` 是一个最简版。现在让我们把它完善成符合正式规范的版本。

### 4.1 原来的版本

```markdown
---
name: daily_brief_helper
description: 将零散项目记录整理成简洁的中文日报。
---

# Daily Brief Helper
...
```

### 4.2 完善后的版本

在 Ubuntu 里执行：

```bash
nano ~/.openclaw/workspace/skills/daily-brief-helper/SKILL.md
```

替换为下面的内容：

```markdown
---
name: daily-brief-helper
description: 当用户要求把零散记录或笔记整理成简洁日报时，使用这个 Skill。适用于会议纪要、聊天摘录、临时待办、项目进展等场景。
metadata: {"openclaw": {"requires": {"tools": ["read", "write"]}}}
---

# 日报整理助手

当用户要求把原始记录整理成日报时，使用这个 Skill。

## 什么时候使用

- 用户发来一段混乱的记录，要求整理
- 用户让你读取某个文件，然后整理成日报
- 用户要求"帮我写今天的日报"

## 什么时候不要使用

- 用户只是普通问答
- 用户要求做行业研究或搜索任务
- 用户要求写长文章或报告

## 工作流程

1. 先读取用户指定的源文件或接收用户发来的原始文本
2. 只保留具体事实：完成了什么、还有什么问题、下一步做什么
3. 整理成固定的三段式结构
4. 如果用户要求保存，写入指定路径并报告

## 输出结构

固定使用以下三段式：

1. **今天完成了什么**
2. **还有什么问题**
3. **明天先做什么**

## 风格要求

- 用中文
- 保持简洁，每段不超过 5 条
- 不要写成长文章
- 不要编造不在源材料里的内容
- 不要加激励性文字

## 参考

如果需要了解用户偏好的风格细节，先读：

- `references/style-guide.md`（如果存在）
```

### 4.3 可选：创建 references

```bash
mkdir -p ~/.openclaw/workspace/skills/daily-brief-helper/references
nano ~/.openclaw/workspace/skills/daily-brief-helper/references/style-guide.md
```

写入：

```markdown
# 日报风格指南

- 全部用中文
- 每条控制在 20 个字以内
- 用列表，不用长段落
- "完成"用完成时态，"明天"用建议语气
- 如果只有一件事，也要写进对应段落
```

### 4.4 验证 Skill 是否识别

```bash
openclaw skills list
openclaw skills info daily-brief-helper
openclaw gateway restart
```

然后在 Dashboard 或飞书里新开一个会话：

```text
/new
```

再发一段测试文本，看它是否套用了三段式结构。

## 5. 理解行业研究 Skill 的设计

本书实验区里已经有一个更复杂的 Skill 示例：

- [skill/SKILL.md](../book-lab/industry-research-assistant/skill/SKILL.md)

它和日报助手 Skill 的区别在于：

| 维度 | 日报助手 | 行业研究助手 |
|---|---|---|
| 触发条件 | 整理记录、写日报 | 行业研究、赛道跟踪、日报周报 |
| 核心逻辑 | 读取 → 整理 → 输出 | 追问 → 确认 → 检索 → 输出 → 记忆 |
| 需要的工具 | `read`、`write` | `web_search`、`web_fetch`、`browser`、`read`、`write` |
| 复杂度 | 低 | 高 |

行业研究 Skill 的设计有几个特别值得学的地方：

1. **先追问，再执行**——缺少 2 个及以上关键字段时必须先追问
2. **标准追问模板**——固定了 7 个追问问题的顺序
3. **检索执行规则**——明确了来源优先级
4. **输出结构**——一次性研究和持续跟踪有不同模板
5. **记忆和定时规则**——什么时候写 Memory，什么时候建 cron

如果你准备自己创建一个复杂 Skill，建议参照行业研究 Skill 的结构来写。

## 6. Skill 调试：3 步排查法

如果你发现 Skill 似乎没有生效，不要急着改内容。先按这 3 步排查：

### 第 1 步：确认 Skill 被加载了

```bash
openclaw skills list
```

如果你的 Skill 不在列表里，通常是因为：

- 文件位置不对
- `SKILL.md` 的 frontmatter 语法错了
- Skill 所需的先决条件不满足

### 第 2 步：确认上下文里有 Skill

在飞书或 Dashboard 里：

```text
/new
/context list
```

看返回的上下文信息里是否包含你的 Skill 名称。

如果 `/new` 之前的旧会话不包含新装的 Skill，那是因为 Skill 列表是在会话创建时快照的。**必须开新会话才能刷新。**

### 第 3 步：确认触发条件匹配

用一句明确的话去触发。例如：

```text
帮我把这段记录整理成日报。
```

如果用模糊的方式说（比如"帮我看看这个"），Agent 可能不会判定需要启用 Skill。

**如果这 3 步都通过了但 Skill 仍然表现不对，再去检查 Skill 正文的规则写法。**

## 7. Skill 的安装位置和优先级

OpenClaw 会在 3 个位置寻找 Skills：

### 第一层：bundled skills

OpenClaw 自带的内置技能。你通常不需要改它们。

### 第二层：`~/.openclaw/skills`

用户级技能。在这里安装的 Skill 对所有 Agent 可用。

### 第三层：`<workspace>/skills`

工作区级技能。只对使用这个 workspace 的 Agent 可用。

### 优先级规则

如果同名 Skill 出现在多个位置：

**workspace > user > bundled**

也就是说，workspace 里的 Skill 优先级最高。这意味着你可以在某个 Agent 的 workspace 里放一个特定版本的 Skill，覆盖全局版本。

## 8. ClawHub：找别人写好的 Skill

ClawHub 是 OpenClaw 生态里的公共技能注册表。

### 安装 CLI

```bash
npm i -g clawhub
```

### 搜索技能

```bash
clawhub search "research"
clawhub search "daily report"
```

### 安装技能

```bash
clawhub install <skill-slug>
```

### 什么时候该用 ClawHub

- 你需要的能力不是自己的核心场景，用别人的就够了
- 你想看看某类 Skill 通常怎么写
- 你想把自己写好的 Skill 发布给社区

### 什么时候该自己写

- 你的流程有独特的追问逻辑或来源偏好
- 你需要精确控制输出格式
- 你需要和自己的 Memory、workspace 文件深度配合

## 9. 工具进阶：tools profile 和精选

### 9.1 两种内置 profile

- `messaging`：偏消息场景。工具集更保守，不含命令执行等高风险工具。
- `coding`：偏开发场景。工具集更开放，包含文件操作、命令执行、代码分析等。

### 9.2 精选工具

如果你既想要基础消息能力，又想额外开放搜索和读写，可以用 `alsoAllow`：

```json5
{
  tools: {
    profile: "messaging",
    alsoAllow: ["web_search", "web_fetch", "browser"]
  }
}
```

如果你想在 coding 基础上禁掉某些高风险工具，用 `deny`：

```json5
{
  tools: {
    profile: "coding",
    deny: ["exec"]
  }
}
```

### 9.3 场景示例

| 场景 | 推荐配置 |
|---|---|
| 纯对话助手 | `messaging` |
| 行业研究助手 | `messaging` + `alsoAllow: ["web_search", "web_fetch", "browser"]` |
| 代码项目助手 | `coding` |
| 搜索测评实验 | `messaging` + `alsoAllow: ["web_search", "web_fetch", "browser"]` |

## 10. 常见问题

### Skill 不触发

排查顺序：

1. `openclaw skills list` 里有没有
2. `/new` 后 `/context list` 里有没有
3. 你的提示词是否足够明确
4. `description` 字段是否准确描述了触发条件

### SKILL.md 语法错误

frontmatter 的 `---` 必须是 3 个短横线，不能有多余空格。`name` 不能有空格。

如果 frontmatter 有语法错误，Skill 通常会被静默跳过，不会报错。这是最容易掉坑的地方。

### 多 Skill 冲突

如果两个 Skill 的 `description` 覆盖了类似的场景，Agent 可能会在两者之间犹豫。

最好的做法是：每个 Skill 的触发条件尽量互斥，或者在正文里明确写"什么时候不要使用这个 Skill"。

## 11. 本章小结

工具和 Skill 是 OpenClaw 长期使用中最值得投入的两个方向。

记住这三条原则：

1. **先手工跑通，再写 Skill**——不要上来就写 Skill，先确认流程真的有效
2. **Skill 管流程，Tool 管执行**——不要试图在 Skill 里替代工具能力
3. **每个 Skill 只管一类任务**——不要把"日报整理"和"行业研究"写在同一个 Skill 里

### 11.1 本章验收标准

1. 你已经完善了 `daily-brief-helper/SKILL.md` 的 frontmatter 和正文
2. 你已经用 `/new` + `/context list` 验证过 Skill 被加载
3. 你已经用一段真实文本触发过 Skill，并确认输出符合预期
4. 你知道 Skill 的 3 个安装位置和优先级规则
5. 你知道 Skill 不触发时的 3 步排查法

## 12. 下一章

- [15-OpenClaw-记忆与检索-从工作区文件到QMD.md](15-OpenClaw-记忆与检索-从工作区文件到QMD.md)

> [!NOTE]
> 本章内容基于 OpenClaw 当前版本验证（截至 2026 年 3 月）。
> 如果你使用更新版本，关键命令和配置项请以官方源码为准。
