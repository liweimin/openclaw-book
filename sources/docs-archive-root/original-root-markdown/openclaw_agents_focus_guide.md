# OpenClaw Agents 聚焦导读：源码、工作方式与调教建议

本文是上一份总览文档的补充版，专门聚焦 OpenClaw 里的 `Agents`。  
目标不是讲概念名词，而是回答 4 个更实际的问题：

1. OpenClaw 的 Agent 到底是怎么跑起来的？
2. 哪些文件和配置会真正影响 Agent 的行为？
3. 作为用户，应该怎么“调教” Agent，效果才稳定？
4. 新手最容易踩哪些坑？

这份内容基于本地仓库 `D:\code\anzhuang\openclaw` 的实际源码和文档整理，重点参考了：

- `src/agents/`
- `src/agents/system-prompt.ts`
- `src/agents/workspace.ts`
- `src/agents/skills/workspace.ts`
- `src/agents/pi-embedded-runner/run.ts`
- `src/agents/pi-embedded-runner/run/attempt.ts`
- `docs/concepts/agent.md`
- `docs/concepts/agent-workspace.md`
- `docs/concepts/system-prompt.md`
- `docs/concepts/memory.md`
- `docs/tools/skills.md`
- `docs/tools/subagents.md`

---

## 1. 先用一句话理解 OpenClaw 的 Agent

OpenClaw 的 Agent 不是一个“固定人格的聊天机器人”，而是一个**每次运行时都重新组装上下文的执行体**。

它每次回复你时，都会重新拼这些东西：

- 系统提示词
- 你的工作区文件
- 当前会话历史
- 可用工具列表
- 可用技能列表
- 模型和认证信息
- 当前时间、运行环境、sandbox 信息

所以，**调教 OpenClaw Agent 的本质，不是给它说一次话，而是把稳定规则写进它每次都会看到的上下文里。**

这也是为什么 OpenClaw 里 `AGENTS.md`、`SOUL.md`、`TOOLS.md`、`MEMORY.md` 比“临时发一句 prompt”更重要。

---

## 2. Agent 的真实运行链路

如果只看源码，Agent 的主链路可以理解成这样：

```text
用户消息
  -> Gateway 收到消息
  -> 解析会话 / sessionKey / agentId
  -> 选择模型与认证
  -> 组装 system prompt
  -> 注入工作区文件与技能清单
  -> 运行 embedded pi agent
  -> 需要时调用工具 / 技能 / memory
  -> 产出回复并写入 session
```

结合文档和源码，关键节点如下。

### 2.1 Agent 的入口

从 `docs/concepts/agent-loop.md` 可以确认，真正的 Agent loop 入口主要有两类：

- Gateway RPC：`agent` / `agent.wait`
- CLI：`openclaw agent`

而实际执行层会进入：

- `runEmbeddedPiAgent`
- `subscribeEmbeddedPiSession`

这说明 OpenClaw 不是“聊天 UI 直接接模型 API”，而是先走 Gateway 和会话层，再进入 Agent runtime。

### 2.2 模型不是死的，可以在运行前被改写

`src/agents/pi-embedded-runner/run.ts` 里可以看到：

- 先跑 `before_model_resolve` hook
- 然后再最终确定 provider / model

这意味着模型选择不是完全写死在配置里的。高级玩法下，你甚至可以用插件在运行前改模型。

对普通用户的意义是：

- 基础调教：优先改配置和 session 模型
- 高级调教：再考虑 hook 做动态模型切换

### 2.3 Prompt 不是固定字符串，而是动态拼装

`src/agents/pi-embedded-runner/run/attempt.ts` 里可以看到 `before_prompt_build`，说明最终送给模型的 prompt 还能在构建阶段继续被插件改写。

而 `docs/concepts/system-prompt.md` 说明了 system prompt 的固定骨架大致包含：

- Tooling
- Safety
- Skills
- Workspace
- Documentation
- Workspace Files
- Sandbox
- Current Date & Time
- Runtime
- Reasoning

这很关键，因为它告诉你：

**OpenClaw 不是把 `AGENTS.md` 当成唯一 prompt，而是把它塞进一个更大的系统提示词框架里。**

所以调教时要知道每种信息应该放哪一层，而不是全部塞进 AGENTS。

---

## 3. 真正影响 Agent 行为的 7 个杠杆

对用户来说，最重要的不是所有源码细节，而是知道“哪些地方能稳定影响 Agent 的行为”。

我建议把调教杠杆理解成下面 7 层。

### 3.1 `AGENTS.md`：行为规则层

这是 Agent 的“工作守则”。

从 `docs/concepts/agent.md`、`docs/concepts/agent-workspace.md` 和默认模板看，`AGENTS.md` 适合放：

- 工作原则
- 决策偏好
- 安全边界
- 做事顺序
- 会话启动时必须做什么
- 在群聊/私聊里的行为差异
- 遇到某类任务时的标准处理方式

适合写进去的内容例子：

- 回答前先查 memory
- 遇到高风险命令先确认
- 处理 bug 时先复现再改
- 在群聊里不要抢话
- 输出尽量短，除非用户要求详细

不适合写进去的内容：

- 你的设备名、IP、路径细节
- 纯人格口吻
- 零散临时任务
- 很长的背景资料

### 3.2 `SOUL.md`：人格与说话风格层

从模板 `docs/reference/templates/SOUL.md` 看，`SOUL.md` 更像“人格和边界”。

它适合放：

- 说话风格
- 是否直接、温和、幽默
- 对外行为边界
- 是否避免废话
- 对公开发言和私密信息的态度

最实用的建议是：

- **把“怎么说”放进 SOUL.md**
- **把“怎么做”放进 AGENTS.md**

很多新手会把这两者混在一起，结果后面越改越乱。

### 3.3 `USER.md`：用户画像层

`USER.md` 适合放用户信息，而不是 Agent 规则。

例如：

- 你叫什么
- 你喜欢被怎么称呼
- 你在哪个时区
- 你的工作偏好
- 你的常见任务类型

这个文件适合做“对你是谁”的补充，不适合写“Agent 应该怎么执行任务”。

### 3.4 `TOOLS.md`：本地环境说明层

`TOOLS.md` 的官方模板写得很清楚：它是环境注释，不是工具定义。

适合放：

- 机器名
- 路径别名
- NAS / 服务器 / SSH 主机名
- 摄像头名字
- 常用命令别名
- TTS 声音偏好
- 你本地习惯用哪个浏览器/目录/播放器

这是一个特别容易被低估的文件。很多“Agent 看起来不聪明”的问题，不是模型不行，而是它根本不知道你环境里的命名习惯。

比如：

- `home-server` 是哪台机器？
- `nas` 指哪个盘？
- `前门摄像头` 对应哪个设备名？

这些不该塞进 skill，也不该塞进 MEMORY，更不该每次在聊天里重复说。  
应该写进 `TOOLS.md`。

### 3.5 `MEMORY.md` + `memory/YYYY-MM-DD.md`：记忆层

从 `docs/concepts/memory.md` 和 `system-prompt.ts` 可以看出，OpenClaw 的记忆不是“模型自己会记住”，而是：

- 长期记忆：`MEMORY.md`
- 日常记忆：`memory/YYYY-MM-DD.md`
- 查询方式：`memory_search` + `memory_get`

源码里 `buildMemorySection` 甚至明确告诉模型：

- 回答之前关于历史决策、偏好、待办、人物、日期的问题
- 先去 `memory_search`
- 再用 `memory_get` 拉需要的行

这说明一件事：

**OpenClaw 的记忆是“先写文件，再搜索文件”，不是靠聊天窗口里的上下文自动永久记住。**

所以调教建议非常明确：

- 想让它长期记住，就让它写入 `MEMORY.md`
- 想让它记录今天发生了什么，就写到 `memory/当天日期.md`
- 不要以为“我说过一次，它以后就会一直记得”

### 3.6 `skills/`：可复用流程层

技能是 OpenClaw 调教里非常关键的一层。

从 `docs/tools/skills.md` 和 `src/agents/system-prompt.ts` 可以看出，模型在 system prompt 里看到的不是全部技能正文，而是一个紧凑的 `available_skills` 列表，里面主要是：

- name
- description
- location

然后系统提示会要求模型：

- 先扫描技能描述
- 如果明显只有一个技能匹配，就去读那个 `SKILL.md`
- 如果多个都可能匹配，选最具体的一个
- 不要一上来乱读很多技能

这意味着：

**技能名和 description 的写法，会直接影响 Agent 能不能选对技能。**

这是调教里的重点。

### 3.7 配置与 Hook：高级调教层

如果说前 6 层是“普通用户可控层”，那配置和 hooks 就是“进阶层”。

比如文档和源码里能看到这些高级入口：

- `before_model_resolve`
- `before_prompt_build`
- `before_tool_call`
- `after_tool_call`
- `agent_end`
- `tool_result_persist`

这些适合做：

- 动态切模型
- 给某类会话自动加额外提示
- 统一改某个工具的参数
- 持久化前处理工具结果
- 运行结束后做审计

如果你还在“先让 Agent 用顺手”的阶段，不建议一开始就碰 hooks。  
先把工作区文件和 skills 用好，收益最大。

---

## 4. 小白最该掌握的调教原则

下面这些建议，是我认为最实用、最能直接改善体验的部分。

### 原则 1：把规则写到正确的文件里

最常见的错误就是“所有东西都往 AGENTS.md 里塞”。

正确分工建议：

- `AGENTS.md`：做事规则
- `SOUL.md`：说话风格和人格边界
- `USER.md`：用户画像
- `TOOLS.md`：本地环境说明
- `MEMORY.md`：长期记忆
- `memory/YYYY-MM-DD.md`：当天笔记
- `skills/<name>/SKILL.md`：可复用流程

如果分工清楚，后续改起来会非常顺。

### 原则 2：让 Agent 写下来，不要只靠聊天“记住”

OpenClaw 的核心记忆机制是文件，不是聊天框。

所以你以后调教时，建议多用这种说法：

- “把这条长期偏好写进 `MEMORY.md`”
- “把今天这个决定记录到今天的 `memory` 文件里”
- “把这个执行规范写进 `AGENTS.md`”
- “把这个环境说明补充到 `TOOLS.md`”

这种说法比“你记住这个”稳定得多。

### 原则 3：保持注入文件短而明确

`docs/concepts/system-prompt.md` 写得很明确：

- `AGENTS.md`
- `SOUL.md`
- `TOOLS.md`
- `IDENTITY.md`
- `USER.md`
- `HEARTBEAT.md`
- `BOOTSTRAP.md`
- `MEMORY.md`

这些文件都会进入 prompt 注入链路。  
这意味着它们会消耗 tokens。

所以建议：

- 一条规则尽量一句话讲清楚
- 避免重复表达同一个意思
- 大段背景资料不要放这类注入文件
- `MEMORY.md` 只留重要、稳定、长期有效的信息

否则会出现两个问题：

1. token 消耗过高
2. compaction 更频繁，效果反而变差

### 原则 4：重复任务不要靠聊天反复教，应该做成 Skill

如果某类任务你已经重复教了 3 次以上，就说明它适合技能化。

比如：

- 发布前检查
- 每日工作汇总
- 某个网站的数据采集
- 某类日志分析
- 某个固定格式的周报

这时正确做法不是继续在聊天里说“你以后都这么做”，而是：

1. 在 `workspace/skills/` 下新建技能目录
2. 写一个清晰的 `SKILL.md`
3. 把动作流程写进去
4. 用精准的 `name` 和 `description`

因为源码决定了：模型先靠描述选技能。  
所以 description 不要写成很泛的句子。

坏例子：

- `description: 帮助处理任务`

好例子：

- `description: 分析 Node.js 项目的测试失败，先找失败测试，再定位对应源码和最近改动`

越具体，越容易被选中。

### 原则 5：个人隐私不要指望在群聊里自动安全隔离

文档里有两个很重要的边界：

1. `MEMORY.md` 只建议在主私聊 session 用
2. 群聊和共享上下文里，不应该自动带入私人长期记忆

所以如果你打算把 OpenClaw 用在：

- 多人 DM
- 群聊
- 公共渠道

一定要重视：

- `session.dmScope`
- group/session 隔离
- 不要把隐私性太强的信息乱写到会在共享上下文里被引用的地方

如果是多用户收件箱，建议优先看 `docs/concepts/session.md` 里的 `dmScope` 安全说明。

### 原则 6：想让它更像“你的人”，优先调 `SOUL.md` 和 `USER.md`

很多人一上来就在 `AGENTS.md` 里疯狂加规则，结果 Agent 更像“公司流程机器人”，不像自己的助手。

如果你想调出“更像你喜欢的风格”，优先改：

- `SOUL.md`：口吻、性格、边界
- `USER.md`：你的背景、偏好、称呼方式

这样更自然。

### 原则 7：想让它更会干活，优先调 `AGENTS.md`、`TOOLS.md`、Skills

如果你的目标是“少废话、会做事、少犯重复错误”，优先级应是：

1. `AGENTS.md`
2. `TOOLS.md`
3. `skills/`
4. `MEMORY.md`

也就是说：

- 规则先定
- 环境先说明
- 重复流程技能化
- 长期经验沉淀到 memory

---

## 5. 面向用户的具体调教建议

下面这些建议是“你可以直接照着做”的版本。

## 5.1 教 Agent 规则时，尽量用“落盘语言”

推荐这样说：

- “把这条规则写进 `AGENTS.md`，以后都按这个来。”
- “把这个风格要求更新到 `SOUL.md`。”
- “把我对称呼和时区的偏好写进 `USER.md`。”
- “把这台机器/这个路径别名记到 `TOOLS.md`。”
- “把这个长期偏好写到 `MEMORY.md`。”
- “把今天这个临时决定记到今天的 `memory` 文件里。”

不推荐这样说：

- “你以后记住就行。”
- “下次别忘了。”
- “你应该知道我的习惯。”

因为这类说法不对应 OpenClaw 的真实持久化机制。

## 5.2 给规则时，写成“触发条件 + 动作”

Agent 最怕模糊规则。

坏规则：

- “谨慎一点。”
- “尽量聪明地做。”

好规则：

- “当任务涉及删除、覆盖、重置时，先说明风险再执行。”
- “当用户要求修改代码时，先定位入口文件，再改实现，再做验证。”
- “当用户问历史决定时，先查 `memory_search` 再回答。”

规则写得越像执行条件，越稳定。

## 5.3 把“人设”和“流程”分开教

推荐你这样分：

- `SOUL.md`：
  - 要不要简洁
  - 要不要直接
  - 要不要幽默
  - 是否避免奉承
- `AGENTS.md`：
  - 遇到代码问题先查什么
  - 遇到外发动作先确认什么
  - 会话启动时要读哪些文件
  - 群聊里怎么克制发言

这个分法能让人格调整和工作规则互不干扰。

## 5.4 本地环境信息一定要沉淀到 `TOOLS.md`

典型例子：

- “`nas` 其实就是 `192.168.1.8` 那台机器”
- “我常用项目都在 `D:\code`”
- “`prod-db` 是线上数据库，只能查不能写”
- “默认用中文回复我，但 commit message 用英文”

这些不是人格，也不是长期记忆里的人生事实，而是**环境操作知识**。  
最适合 `TOOLS.md`。

## 5.5 技能描述要精准，不要泛化

因为源码里的技能机制是“先扫 description 再决定读哪个技能”，所以你自定义 skill 时：

- skill 名称要清晰
- description 要直指场景
- 不要把 5 种不相干任务塞进一个 skill

建议一个 skill 只做一类事。  
如果你想让 Agent 更容易命中它，就让 skill 名和 description 尽量具体。

## 5.6 长任务和并行任务，优先考虑 Subagents

如果任务特点是：

- 很慢
- 需要查很多资料
- 可能跑很久
- 会阻塞主会话

那么不要硬塞在主 Agent 里跑。  
`docs/tools/subagents.md` 建议用 subagents 处理这类工作。

尤其值得注意的是：

- 子代理有自己独立 session
- 会在完成后回报结果
- 可以给子代理单独设 model / thinking / timeout
- 文档明确建议：**主 Agent 用强模型，Subagent 用便宜一点的模型**

这条很实用。对实际成本和响应速度都友好。

## 5.7 如果你刚改了 Skill，最好开一个新 session 验证

`docs/tools/skills.md` 里提到：skills 在 session 启动时会做 snapshot，后续会复用。

这意味着：

- 你虽然可以开 watcher 自动刷新
- 但最稳妥的验证方式仍然是新开 session

否则你很容易误判：

- 以为 skill 没生效
- 以为模型没学会
- 实际上只是旧 session 还在用旧快照

---

## 6. 新手最容易踩的 10 个坑

### 坑 1：把所有规则都堆进 `AGENTS.md`

后果：

- 文件变得很长
- token 消耗高
- 后期很难维护
- 风格、人设、环境信息混成一团

### 坑 2：以为聊天里说过的话会永久生效

不会。  
如果你没让它写入工作区文件或 memory，它下次不一定还记得。

### 坑 3：把长期记忆和当天笔记混着写

建议严格区分：

- `MEMORY.md`：长期、稳定、值得持续记住
- `memory/YYYY-MM-DD.md`：当天流水和短期上下文

### 坑 4：把敏感信息塞进 workspace 并提交到 git

`docs/concepts/agent-workspace.md` 已经明确提醒：

- workspace 建议做私有 git 备份
- 但不要把 secrets 放进去

所以不要把：

- API key
- token
- 密码
- 凭据文件

写进 workspace 再提交。

### 坑 5：把技能写得太大、太泛

技能越泛，模型越难准确命中。  
技能越大，阅读成本越高。  
技能应该是“明确场景 + 明确动作”。

### 坑 6：在群聊里期待它像私聊一样懂你的私人背景

官方设计本来就尽量避免私人长期记忆在共享上下文乱引用。  
所以群聊里别指望它天然拥有你所有私密上下文。

### 坑 7：忘了 workspace 不是绝对 sandbox

`docs/concepts/agent-workspace.md` 特别强调了一点：

- workspace 是默认 cwd
- 不是天然的硬隔离

如果你真想限制 Agent 的宿主机访问范围，要看 sandbox 配置，不是只改 workspace 路径。

### 坑 8：给 Agent 一个巨长的 `MEMORY.md`

这会直接影响：

- token 消耗
- prompt 注入大小
- compaction 频率
- 回答稳定性

长期记忆应该“精炼”，不是“把所有历史聊天全粘进去”。

### 坑 9：希望同一个 Agent 同时扮演多个完全不同角色

如果角色差异很大，比如：

- 一个负责 coding
- 一个负责社交/运营
- 一个负责家庭自动化

更合理的做法是多 agent 路由，而不是把一个 Agent 调成“三重人格”。

`docs/concepts/multi-agent.md` 已经说明：一个 agent 本质上是一套独立 workspace + auth + sessions。

### 坑 10：还没把工作区文件整理好，就急着上 hooks

hooks 很强，但它是高级层。  
如果你的基础文件都还没分工清楚，先别上插件钩子。  
先把：

- AGENTS
- SOUL
- USER
- TOOLS
- MEMORY
- skills

这几层用好，收益更大。

---

## 7. 一套给小白的推荐调教流程

如果你是从零开始，我建议按下面顺序调。

### 第一步：先把工作区文件补齐

至少整理清楚：

- `AGENTS.md`
- `SOUL.md`
- `USER.md`
- `TOOLS.md`
- `MEMORY.md`
- `memory/`

### 第二步：先调“做事规则”，再调“说话风格”

顺序建议：

1. 先改 `AGENTS.md`
2. 再改 `TOOLS.md`
3. 再改 `MEMORY.md`
4. 最后改 `SOUL.md`

原因很简单：先让它做对，再让它说得像你喜欢的样子。

### 第三步：把重复任务技能化

当你发现某个流程重复出现，就把它沉淀成 skill。  
不要永远靠聊天重复教学。

### 第四步：需要并行时再上 subagents

主 Agent 先稳住。  
确认主工作流顺畅后，再开始把慢任务交给 subagents。

### 第五步：最后再考虑 hooks 和高级自动化

这是优化项，不是起步项。

---

## 8. 一个很实用的“信息该写哪”的速查表

| 你想教 Agent 的内容 | 最适合放哪里 | 原因 |
| --- | --- | --- |
| 遇到危险命令先确认 | `AGENTS.md` | 这是行为规则 |
| 回答风格更直接少废话 | `SOUL.md` | 这是人格/语气 |
| 我喜欢被叫什么、在哪个时区 | `USER.md` | 这是用户画像 |
| 我本地服务器/设备/路径别名 | `TOOLS.md` | 这是环境知识 |
| 我长期偏好、长期项目背景 | `MEMORY.md` | 这是长期记忆 |
| 今天刚做的决定 | `memory/YYYY-MM-DD.md` | 这是短期/日记记忆 |
| 一个固定工作流 | `skills/<skill>/SKILL.md` | 这是可复用流程 |
| 按条件自动改模型或 prompt | plugin hooks | 这是高级动态调教 |

---

## 9. 我给你的实操建议

如果你的目标是“后续更好地使用和调教 agents”，我建议你现在就做这几件事：

1. 先把当前工作区里的 `AGENTS.md`、`SOUL.md`、`TOOLS.md`、`MEMORY.md` 职责重新分清。
2. 把那些你总在聊天里重复提醒 Agent 的内容，改成落盘规则。
3. 把环境信息系统化写进 `TOOLS.md`，不要再靠临时聊天补充。
4. 把 3 次以上重复出现的任务整理成 workspace skill。
5. 让 Agent 在合适的时候主动写 memory，而不是只“口头记住”。
6. 如果你要多人、多渠道用，尽快确认 `session.dmScope` 和多 agent 隔离策略。
7. 如果你要跑慢任务，开始规划 subagents，但给它们单独的模型和超时配置。

---

## 10. 最后的判断

如果只让我给一句最核心的建议，那就是：

**把 OpenClaw Agent 当成“每次都会重读工作区文件和技能说明的执行者”，而不是“会自动长期成长的聊天人格”。**

一旦你按这个思路去调教，很多事情都会变顺：

- 想永久生效，就写文件
- 想重复复用，就写 skill
- 想更像你，就调 SOUL / USER
- 想更会做事，就调 AGENTS / TOOLS / MEMORY
- 想跑得更复杂，再上 subagents 和 hooks

这才是最贴合 OpenClaw 源码设计的用法。
