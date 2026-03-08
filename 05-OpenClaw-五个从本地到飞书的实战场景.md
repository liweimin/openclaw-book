# 第五章：五个从本地到飞书的实战场景

## 1. 本章真正要做什么

这一章不再先讲抽象原理，而是带你做 5 个真的能落地、做完能留下结果的场景。

这些场景的设计原则只有两条：

1. 小白能照着做出来
2. 做完后对日常工作有实际价值，而不是只证明“某个功能能点开”

官方 Showcase 给了很多灵感，但那里面有些场景依赖更多外部服务、插件或已有工作流。为了保证你现在就能复现，这一章全部改写成更稳、更适合第一次上手的版本。

### 1.1 本章实操场景

1. 把一段混乱记录整理成可直接发人的日报
2. 让 OpenClaw 读一个项目目录，生成接手摘要
3. 把重复动作沉淀成一个真的能复用的 Skill
4. 让系统记住你的长期偏好和长期环境
5. 把本地整理结果真正带到飞书私聊里

### 1.2 这 5 个场景各自解决什么问题

这 5 个场景不是 5 个零散实验，而是一条很完整的进阶链路：

- 场景一，解决“我有原始材料，但整理成可交付结果很费时间”
- 场景二，解决“我面对一个目录或项目时，不知道怎么快速建立全局理解”
- 场景三，解决“同一类事我每次都要重新说一遍”
- 场景四，解决“我不想每次都重复交代偏好、目录和背景”
- 场景五，解决“结果不能只留在本地，还要进入我真正使用的入口”

### 1.3 本章产物

如果你把这一章完整做完，工作区里至少会留下下面这些结果：

- `ch05-lab/outputs/daily-brief.md`
- `ch05-lab/outputs/project-brief.md`
- `ch05-lab/outputs/daily-brief-from-skill.md`
- `ch05-lab/outputs/memory-based-brief.md`
- `~/.openclaw/workspace/skills/daily-brief-helper/SKILL.md`

### 1.4 开始前先准备什么

这一章默认你已经完成下面这些前提：

- 第二章已经跑通，本地可用
- 第三章已经让你至少能稳定读写工作区文件
- 如果第四章还没做完，你也可以先完成场景一到场景四，最后再做场景五

## 2. 开始前先做统一准备

为了保证你后面每一步都能复现，这一章先统一一个练习目录。

如果你还没有改过默认工作区，就先直接用：

```bash
mkdir -p ~/.openclaw/workspace/ch05-lab/outputs
mkdir -p ~/.openclaw/workspace/ch05-lab/materials
mkdir -p ~/.openclaw/workspace/ch05-lab/memory
```

如果你在第三章已经把工作区改成了别的路径，那就把这里的 `~/.openclaw/workspace` 换成你自己的工作区。

### 2.1 一个很重要的前提

这一章会用到读写文件能力。

如果你在第二章、第三章只是能聊天，但还不能稳定读写工作区文件，那么先回到第三章确认两件事：

1. 你当前工作区到底在哪里
2. 你当前是否需要把 `tools.profile` 调整为 `coding`

如果你现在已经能在 Dashboard 里让它读写本地 Markdown 文件，这一章就可以直接往下做。

### 2.2 如果你暂时没有自己的素材，先用这一份练习材料

在 Ubuntu 里执行：

```bash
nano ~/.openclaw/workspace/ch05-lab/materials/raw-note.md
```

把下面这段内容贴进去：

```markdown
今天事情很多，先记一下，晚点整理：

- 上午 9:30 和产品过了一版需求，确定这周先不上导出功能，先把权限页补完。
- 测试提了 3 个问题：登录态偶发失效、表单提交后 toast 偶尔不消失、移动端有一个按钮挤压。
- 研发这边今天修掉了登录态问题，另外两个还没处理。
- 客户 A 说明天想看一个更新说明，不要太技术，要让业务能看懂。
- 我自己明天上午要先补更新说明，下午跟进移动端按钮问题。
- 风格上希望最后给同事的内容短一点，不要写成长文章。
```

这份材料后面会在场景一、场景三、场景四里重复使用。

## 3. 场景一：把混乱记录整理成可直接发人的日报

这是最值得你先做通的一个场景。

因为绝大多数人第一次真正感受到 OpenClaw 有用，不是在“它回答得像不像人”，而是在“它能不能把混乱输入变成我能直接拿去用的输出”。

### 3.1 这个场景解决什么问题

很多人平时手里都有原始材料：

- 群聊摘录
- 会议纪要
- 零散待办
- 随手记下来的项目进展

但真正费时间的不是记录，而是最后要把这些东西整理成一份能发给别人看的文本。

### 3.2 你现在就照着做

打开 Dashboard，直接发下面这段话：

```text
请读取工作区里的 ch05-lab/materials/raw-note.md，把它整理成一份可以直接发给同事的中文日报。

要求：
1. 只保留关键事实。
2. 用 Markdown。
3. 分成“今天完成了什么”“还剩什么问题”“明天先做什么”三部分。
4. 整体风格简洁，不要写成长文章。
5. 保存为 ch05-lab/outputs/daily-brief.md。
6. 最后告诉我你保存到了哪里。
```

### 3.3 做到什么算成功

回到终端执行：

```bash
ls ~/.openclaw/workspace/ch05-lab/outputs
```

如果你已经看到了 `daily-brief.md`，这个场景就成立了。

更进一步，你还可以直接打开看看：

```bash
nano ~/.openclaw/workspace/ch05-lab/outputs/daily-brief.md
```

### 3.4 这个场景为什么有实际价值

因为它已经是一个真实工作闭环：

- 你给的是原始材料
- 它给的是可交付结果
- 结果还被保存了下来

这已经不是“聊天演示”，而是“把一段真实整理劳动交给系统”。

## 4. 场景二：让 OpenClaw 读一个项目目录，生成接手摘要

官方 Showcase 里有很多“帮你理解项目、系统、资料库”的玩法。对小白来说，最稳、最实用的版本就是这一种：

让它先帮你读懂一个目录，然后给你产出一页摘要。

### 4.1 这个场景解决什么问题

你以后非常可能会遇到这种情况：

- 刚接手一个项目
- 打开一个代码仓库
- 面前有一堆 Markdown、配置、目录
- 不知道该从哪开始看

OpenClaw 在这里最有价值的，不是替你做所有决策，而是先帮你把“信息地图”搭起来。

### 4.2 该用哪个目录练手

优先顺序建议这样选：

1. 你自己正在做的一个项目目录
2. 如果你手头没有项目，就用你已经下载好的 OpenClaw 官方源码目录
3. 如果你现在只想先做实验，也可以让它读 `~/.openclaw/workspace/ch05-lab`

如果你没有自己的项目，一个很稳的练习对象就是你本地克隆的 OpenClaw 官方源码目录。

例如：

```text
Windows 示例：D:\你的学习目录\research\openclaw
WSL2 / Linux 示例：~/projects/openclaw-source
```

### 4.3 你现在就照着做

如果你有自己的项目，就把下面提示词里的目录换成你自己的。最稳的写法，是把目标目录一起明确告诉它。

```text
目标目录是：<你的项目路径>

请阅读我的项目目录，并帮我写一份“第一次接手说明”，保存为 ch05-lab/outputs/project-brief.md。

要求：
1. 先说明这个目录大概是做什么的。
2. 列出最值得先看的 5 个文件或目录。
3. 说明如果我是第一次接手，建议先看什么、后看什么。
4. 用中文，控制在 1 页左右。
5. 最后告诉我文件保存到了哪里。
```

如果你要补充目标目录，可以直接在同一条消息前面加一句：

```text
目标目录是：<你的项目路径>
```

### 4.4 做到什么算成功

回到终端执行：

```bash
ls ~/.openclaw/workspace/ch05-lab/outputs
```

如果你看到了 `project-brief.md`，并且里面已经包含“目录做什么、先看哪几个文件、接手顺序建议”，这个场景就成立了。

### 4.5 这个场景为什么有实际价值

因为它直接对应一个常见工作成本：

“面对一个陌生目录时，前 30 分钟通常都在迷路。”

如果 OpenClaw 能先帮你搭出一页接手摘要，你后面再自己看源码、看文档、看配置，效率会高很多。

## 5. 场景三：把重复动作沉淀成一个真的能复用的 Skill

如果前两个场景让你感觉“这东西挺能干活”，那第三个场景解决的问题就是：

我不想每次都重新写同一段要求。

### 5.1 这个场景解决什么问题

你已经发现自己经常让它做同一类事，比如：

- 把零散记录整理成日报
- 把会议纪要压缩成三段
- 读取某类目录后输出固定格式摘要

这时就不该每次都重新打一大段提示词了，而应该把方法沉淀成 Skill。

### 5.2 先创建一个“日报整理助手” Skill

在 Ubuntu 里执行：

```bash
mkdir -p ~/.openclaw/workspace/skills/daily-brief-helper
nano ~/.openclaw/workspace/skills/daily-brief-helper/SKILL.md
```

写入下面这段内容：

```markdown
---
name: daily_brief_helper
description: 将零散项目记录整理成简洁的中文日报。
---

# Daily Brief Helper

Use this skill when the user wants to turn rough notes into a short daily brief.

Workflow:
1. Read the source note file carefully.
2. Keep only concrete progress, unresolved issues, and next actions.
3. Write in concise Chinese.
4. Prefer three sections:
   - 今天完成了什么
   - 还有什么问题
   - 明天先做什么
5. If the user asks to save the result, save it as Markdown and report the path.

Do not:
- invent progress that is not in the source material
- write long motivational prose
- turn a short brief into a long report
```

保存后，重启 Gateway 或新开一个会话，让它重新感知 Skill：

```bash
openclaw gateway restart
```

### 5.3 再做一次真正的复用测试

先再准备一份原始材料：

```bash
nano ~/.openclaw/workspace/ch05-lab/materials/raw-note-2.md
```

你可以贴入下面这段：

```markdown
- 今天把权限页的按钮状态补齐了。
- 移动端按钮挤压问题还没修完，但已经定位到样式冲突。
- 客户更新说明准备了一半，明天上午补完。
- 希望最后输出还是短一点，适合直接发团队群。
```

然后在 Dashboard 里发：

```text
请使用刚才的 daily_brief_helper skill，读取 ch05-lab/materials/raw-note-2.md，并把结果保存为 ch05-lab/outputs/daily-brief-from-skill.md。
```

### 5.4 做到什么算成功

如果下面这条命令能看到新文件，说明 Skill 已经开始真正替你减少重复劳动：

```bash
ls ~/.openclaw/workspace/ch05-lab/outputs
```

你应该能看到：

- `daily-brief.md`
- `daily-brief-from-skill.md`

### 5.5 这个场景为什么有实际价值

因为从这一刻起，你不是“会用一次提示词”，而是在开始沉淀自己的工作方法。

这也是 OpenClaw 和很多一次性聊天工具最本质的差别之一：

它允许你把经验固定下来，后面反复复用。

## 6. 场景四：让系统记住你的长期偏好和长期环境

很多人会在这里犯一个错误：

把 Memory 理解成“聊天记录自动变聪明”。

更有用的理解是：

Memory 用来保存你不想每次重说、而且跨会话仍然重要的信息。

### 6.1 这个场景解决什么问题

如果你每天都在说这些话：

- 请用中文
- 请一步一步写
- 风格短一点
- 我的工作区主要在某个目录

那这些就不该每次靠你重打一遍，而应该进入长期记忆。

### 6.2 你现在就照着做

第一步，写长期记忆文件：

```bash
nano ~/.openclaw/workspace/MEMORY.md
```

写入下面这段最小内容：

```markdown
# Memory

- 用户偏好中文输出。
- 用户偏好一步一步的操作说明。
- 用户偏好简洁、不冗长的日报风格。
- 用户当前主要在工作区里做 OpenClaw 学习与资料整理。
```

第二步，再写一条当天记录：

```bash
nano ~/.openclaw/workspace/ch05-lab/memory/2026-03-08.md
```

可以先写：

```markdown
# 2026-03-08

- 今天跑通了日报整理场景、目录摘要场景和第一个自定义 Skill。
```

第三步，建立索引并搜索：

```bash
openclaw memory status
openclaw memory index --verbose
openclaw memory search "简洁 日报 中文"
```

### 6.3 再做一次带 Memory 的实用测试

回到 Dashboard，发下面这段话：

```text
请根据你已经记住的长期偏好，重新整理 ch05-lab/materials/raw-note.md，并保存为 ch05-lab/outputs/memory-based-brief.md。
```

这一步的重点，不是追求“它 100% 必须显式说出自己用了哪条记忆”，而是让你建立正确使用方式：

- 长期规则写进 `MEMORY.md`
- 当天进展写进日期文件
- 真正需要时，用 `memory search` 去查，而不是靠猜

### 6.4 这个场景为什么有实际价值

因为它解决的是“重复交代”的成本。

一个系统只有在开始记住你的稳定偏好后，才会慢慢从“能用一次”变成“值得长期用”。

## 7. 场景五：把本地整理结果真正带到飞书私聊里

到这一步，前面四个场景已经把本地能力跑起来了。

最后一个场景解决的问题是：

结果不能只停在工作区里，它还要进入你真实使用的消息入口。

### 7.1 这个场景的前提

这一节默认你已经完成第四章，至少已经让飞书私聊可以正常工作。

如果你还没有接通飞书，请先回到第四章，不要硬做这一节。

### 7.2 你现在就照着做

先确认本地至少已经有下面这类文件中的一个：

- `ch05-lab/outputs/daily-brief.md`
- `ch05-lab/outputs/daily-brief-from-skill.md`
- `ch05-lab/outputs/memory-based-brief.md`

然后打开飞书私聊，对机器人发下面这段话：

```text
请读取工作区里的 ch05-lab/outputs/daily-brief-from-skill.md。

要求：
1. 保留原始结论，不要编造新内容。
2. 压缩成 3 条适合飞书私聊阅读的要点。
3. 每条尽量控制在 1 行。
4. 直接回复在当前飞书私聊里。
```

如果你还没有 `daily-brief-from-skill.md`，就换成你已经生成的其他输出文件。

### 7.3 做到什么算成功

下面三件事同时成立，就说明你已经把“本地 -> 飞书”这条链跑通了：

1. 飞书私聊里确实收到了基于本地文件整理出的结果
2. 结果不是闲聊，而是一条对你今天真的有用的信息
3. 你知道以后要发日报、发摘要、发待办时，可以沿用同一条路径

### 7.4 这个场景为什么有实际价值

因为到这里为止，OpenClaw 才真正进入你的日常入口。

如果结果永远只留在本地 Dashboard 里，它更像实验工具。

一旦结果能进入飞书私聊，它才开始像一个真正能融入日常工作的个人助手。

## 8. 做完这 5 个场景后，再回头理解 Tools

这时你再看 Tools，就不会把它理解成一堆抽象开关了。

从这 5 个场景来看，Tools 最少承担了三类工作：

1. 读写文件
2. 读取目录和项目内容
3. 把结果带回会话或消息入口

所以 Tools 的本质不是“给 AI 增加一点功能”，而是让它有能力把原始材料变成结果。

## 9. 做完这 5 个场景后，再回头理解 Skills

Skill 的价值也会更清楚。

它不是拿来炫技的，也不是“神秘提示词包”，而是把你已经证明有用的一类动作固定下来。

本章里最典型的例子就是：

你先手工跑通了“日报整理”这件事，然后再把它沉淀成 `daily_brief_helper`。

这个顺序非常重要。

先有真实任务，再有 Skill。

不要反过来。

## 10. 做完这 5 个场景后，再回头理解 Memory

Memory 也一样。

它最有价值的地方，从来不是“记得越多越高级”，而是：

能不能稳定记住那些你每次都不想重说、但对后续输出非常重要的东西。

例如：

- 你偏好中文
- 你喜欢简洁风格
- 你主要在工作区里做资料整理和项目摘要

这些信息不该每轮重说，也不该淹没在长聊天记录里。

## 11. 这五个场景背后的真正组合方式

如果把这一章压成一句最重要的话，就是：

OpenClaw 的价值，不在于某个单独功能，而在于它能把一条完整工作链条串起来。

在这一章里，你已经实际做过了这条链：

1. 原始材料进入工作区
2. Tools 帮你读写和整理
3. Skill 帮你固定方法
4. Memory 帮你保留长期偏好
5. 渠道把结果送到飞书

这条链一旦跑顺，你后面就可以把它迁移到更多真实任务上。

## 12. 本章小结

这一章最重要的收获不是你知道了几个新名词，而是你已经亲手把下面这些事做成了：

- 用 OpenClaw 整理本地原始材料
- 用它读一个目录并生成接手摘要
- 亲手做出一个可以复用的 Skill
- 亲手写入和搜索 Memory
- 把结果带到飞书私聊里

这已经足够构成一本真正有价值的入门主线。

### 12.1 本章验收标准

这一章读完后，你最好已经真的做成下面这 5 件事：

1. `ch05-lab/outputs/daily-brief.md` 已经生成
2. `ch05-lab/outputs/project-brief.md` 已经生成
3. `~/.openclaw/workspace/skills/daily-brief-helper/SKILL.md` 已经存在，并且你跑通过至少一次复用
4. 你已经执行过 `openclaw memory status`、`openclaw memory index --verbose`、`openclaw memory search ...`
5. 你已经在飞书里拿到过基于本地文件整理出来的一条实际结果

## 13. 下一章

- [06-OpenClaw-稳定使用-排错与安全.md](06-OpenClaw-稳定使用-排错与安全.md)

## 本章核验依据（官方文档 / 源码）

- `research/openclaw/docs/zh-CN/tools/index.md`
- `research/openclaw/docs/zh-CN/tools/skills.md`
- `research/openclaw/docs/zh-CN/tools/creating-skills.md`
- `research/openclaw/docs/zh-CN/cli/memory.md`
- `research/openclaw/docs/zh-CN/channels/feishu.md`
- `research/openclaw/src/agents/tools/memory-tool.ts`
- OpenClaw official showcase: [https://www.openclaw.ai/showcase](https://www.openclaw.ai/showcase)

## 本章合并来源

这一章主要吸收并改写了以下归档文档中的主题：

- `openclaw_tools_reference.md`
- `openclaw_skills_reference.md`
- `openclaw_memory_guide.md`
- `openclaw-tools-skills-beginner-guide-zh-cn-full.md`
- `skill-beginner-learning-guide-5-ready-skills.md`
- `skill-dependencies-and-structure-5-ready.md`
- `skill-md-fields-and-config-beginner-guide.zh-CN.md`
