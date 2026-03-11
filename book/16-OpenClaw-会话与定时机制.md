# OpenClaw 会话与定时机制：`dmScope`、`main`、`isolated`、`cron`、`heartbeat`

副标题：把“消息进哪个会话、定时任务跑在哪、为什么会串上下文”一次讲清楚

## 1. 为什么这一章很重要

很多人把 OpenClaw 用到飞书、Telegram、Slack 这类真实渠道后，最容易困惑的就是：

- 为什么我明明在同一个机器人里说话，却像是在不同对话里？
- 为什么 `/new` 以后像开了新会话，但定时任务又像还能继续？
- 为什么 cron 跑出来的内容和主私聊不像在同一个上下文里？
- `dmScope: "main"`、`per-peer`、`per-channel-peer` 到底有什么区别？
- `heartbeat` 和 `cron` 都能定时，到底该用哪个？

这些问题如果不讲清楚，后面做：

- 个人待办助手
- 行业研究助手
- 飞书长期助手
- 多用户机器人

都很容易踩坑。

这一章的目标就是把这些机制拆开。

---

## 2. 先记住一个总原则：消息入口不等于会话边界

这是最关键的一句。

很多新手会自然地以为：

- “我都在同一个飞书机器人里发消息，所以应该就是一个会话”

实际上不是。

在 OpenClaw 里，更准确的是：

- 渠道只是消息入口
- 会话边界由 `session key` 规则决定

也就是说：

- 同一个入口
- 同一个机器人
- 同一个人

都不一定天然等于“同一个 session”

这就是为什么要理解：

- `dmScope`
- `main`
- `isolated`
- `cron:<jobId>`

---

## 3. 什么是 session key，为什么它这么重要

可以把 session key 理解成：

**OpenClaw 用来决定“这条消息应该接到哪段历史后面”的那把钥匙。**

如果两条消息落到同一个 session key：

- 它们会共享同一段对话连续性

如果两条消息落到不同 session key：

- 它们就像不同对话桶

官方文档里已经把常见 key 规则写得很清楚：

- 主私聊常见是：`agent:<agentId>:<mainKey>`
- 群聊、频道、topic、cron 都会有各自的 key

所以这件事的本质不是“你在哪说话”，而是：

**Gateway 最终把这条消息映射到了哪个 session key。**

---

## 4. `dmScope`：私聊到底怎么分桶

`dmScope` 控制的是：

- Direct Message，也就是私聊消息
- 到底按什么粒度分 session

官方现在主要有这几种：

- `main`
- `per-peer`
- `per-channel-peer`
- `per-account-channel-peer`

## 4.1 `dmScope: "main"`

这是“连续性优先”的模式。

效果是：

- 所有私聊都尽量并到 agent 的主会话里

你可以把它理解成：

- 这个 agent 有一个长期主私聊脑子
- 你每次来私聊它，基本都接在这个脑子后面

### 适合什么场景

最适合：

- 单人自用
- 个人助手
- 一个 owner 长期跟同一个 agent 对话

例如：

- `weekly-assistant`
- 个人待办助手
- 个人知识助手

### 风险是什么

如果一个机器人会同时被很多人私聊，这个模式就危险了。

因为可能出现：

- A 的私聊上下文
- 被 B 的提问接上

所以官方文档也明确提醒：

**多用户 DM 场景不要默认用 `main`。**

## 4.2 `dmScope: "per-peer"`

这是“按人分桶”的模式。

效果是：

- 不同发送者，各自一条私聊上下文

适合：

- 多个用户私聊同一个 agent
- 但不太在意跨渠道细分

## 4.3 `dmScope: "per-channel-peer"`

这是更稳的多用户私聊模式。

效果是：

- 同一个渠道里的不同用户，各自隔离

例如：

- 飞书里的 A 和 B 各自一个 session
- Telegram 里的 A 和 B 各自一个 session

这也是官方更推荐给共享 inbox 场景的模式。

## 4.4 `dmScope: "per-account-channel-peer"`

这是更细的一档。

适合：

- 同一个渠道有多个 bot/account
- 又要多用户隔离

### 一句话怎么选

可以这样记：

- 单人自用：`main`
- 多人共享：`per-channel-peer`
- 多账号多用户：`per-account-channel-peer`

---

## 5. `main` 会话到底是什么

很多人把 `main` 误会成“主 agent”或者“默认账号”。

其实这里至少有 3 个不同的 `main`，不要混：

1. `main agent`
2. `session main`
3. `channels.<channel>.accounts.main`

它们不是一回事。

### 5.1 `main agent`

指 agent 的 id 叫 `main`。

### 5.2 `session main`

指主私聊会话键，常见是：

- `agent:<agentId>:main`

### 5.3 `accounts.main`

指某个渠道账号的配置名叫 `main`

例如：

- 飞书机器人账号 `main`

这不等于：

- 消息一定进 `main agent`

也不等于：

- 一定走主私聊上下文

所以看配置时一定要分清：

- 这是 agent id
- 还是 session main key
- 还是渠道账号 id

---

## 6. `cron` 跑在哪里，为什么它像“自己开了新对话”

这是定时任务最容易让人误解的地方。

官方文档把 cron 分成两类：

- `main session`
- `isolated`

## 6.1 main session cron

这种模式不是直接单开一个独立 agent turn。  
它更像：

- 往主会话里投一个 system event
- 然后在下一次 heartbeat 时处理

所以它更适合：

- 真正属于主会话连续上下文的一部分
- 希望它和主助手强连续

## 6.2 isolated cron

这是现在更常见、也更容易控制的一类。

它会：

- 进入 `cron:<jobId>` 这条专用 session key
- 跑一轮独立 agent turn
- 默认每次 fresh session id
- 然后再按 delivery 规则投递结果

这就是为什么你会感觉：

- cron 不是在你当前聊天里继续想
- 而像自己开了个后台任务

因为它本来就是独立 session。

## 6.3 为什么这样设计是合理的

因为很多定时任务本来就不应该污染主会话。

例如：

- 每天行业日报
- 定时检查网站更新
- 定时汇总 overnight 动态

如果这些都直接灌进主私聊历史：

- 主会话会越来越乱
- token 成本也会上去

所以 `isolated` cron 的本质是：

**把“后台定时工作”和“主对话脑子”分开。**

---

## 7. `heartbeat` 跑在哪里，和 cron 有什么本质区别

如果只记一句话：

**heartbeat 更像“主会话定期自检”，cron 更像“按时间表启动一个任务”。**

## 7.1 `heartbeat`

heartbeat 默认更像：

- 周期性在主 session 里跑一轮 agent turn
- 让 agent 检查有没有需要提醒、跟进、确认的事

它更适合：

- 检查今天有没有更新 daily
- 检查是否该提醒你复盘
- 轻量 check-in

## 7.2 `cron`

cron 更适合：

- 每天 10 点一定提醒
- 每天下午 5 点一定追问
- 每周五 17:30 一定做周复盘

也就是说：

- heartbeat 更偏“检查式”
- cron 更偏“时间触发式”

---

## 8. `heartbeat` 和 `cron` 到底怎么选

这里给一个最实用的判断标准。

## 8.1 如果你要“准时发生”

选：

- `cron`

典型例子：

- 每天 10 点提醒我今天先做什么
- 每天 17 点问我今天进度
- 每周五 17:30 做周复盘

## 8.2 如果你要“定期检查，但不一定每次都发”

选：

- `heartbeat`

典型例子：

- 如果今天还没写进度，再提醒
- 如果今天已经补了 daily，就别再打扰
- 检查是否有需要注意的后台状态

## 8.3 如果你是第一版实验

更建议：

- 先用 `cron`

原因很简单：

- 更容易理解
- 更容易验证
- 更容易排错

这也是为什么前面个人助手实验里，我们最后先选了 cron 版。

---

## 9. 为什么 cron 触发了，但你后续在私聊里回复时，还需要 `AGENTS.md` 配合

这是很容易被忽视的一层。

很多人会以为：

- “定时任务已经问了我问题，所以后续自然会写回 daily”

其实不完全是。

因为在很多配置里：

- cron 是 `isolated`
- 它在 `cron:<jobId>` 会话里启动
- 结果通过渠道投递给你

而你后续直接在飞书私聊回复时，消息通常会回到：

- 这个 agent 的主 DM session

所以“问”和“后续回复写回”不一定发生在同一个 session key 里。

这时候真正把行为接起来的，是：

- `AGENTS.md` 的规则

也就是说：

- cron 负责把事情提起来
- `AGENTS.md` 负责规定：无论这轮是定时触发，还是你后续手动补充，都按同一套规则维护 daily

所以别把 cron 理解成“全部逻辑都在 cron 自己里面”。

---

## 10. 结合真实场景，怎么理解这几种机制

## 10.1 个人待办助手

更推荐：

- `dmScope: "main"`
- cron 用 `isolated`
- 规则写在 `AGENTS.md`

原因：

- 人只有你一个
- 主对话连续性很重要
- 定时任务最好别污染主会话

## 10.2 行业研究助手

如果是你自己用：

- `dmScope: "main"` 也可以

如果以后多人共享：

- 更适合 `per-channel-peer`

而行业日报、周报、定时研究：

- 更适合 `isolated` cron

原因：

- 研究结果更像后台任务产物
- 不适合一直混进主聊天历史

## 10.3 多人共享机器人

优先考虑：

- `per-channel-peer`
- 甚至 `per-account-channel-peer`

不要默认用：

- `main`

否则上下文串人风险会很高。

---

## 11. 新手最容易踩的坑

### 坑一：把 `main` 当成一个概念

其实可能是：

- `main agent`
- 主 session
- 渠道账号 `main`

这三个要分开看。

### 坑二：以为 cron 一定接在主会话后面

不一定。  
`isolated` cron 本来就是独立 session。

### 坑三：以为 heartbeat 和 cron 只是两个不同名字的定时器

不是。  
它们的工作方式和适合场景不同。

### 坑四：多人共享还坚持用 `dmScope: "main"`

这很容易把不同用户的上下文混到一起。

### 坑五：以为定时任务后续一定会自动写回文件

如果后续回复已经回到主 DM，会不会写回，取决于规则有没有写清楚。

---

## 12. 本章最重要的结论

把下面这几句记住，后面你做各种 agent 就不容易乱：

- 渠道入口不等于会话边界
- `dmScope` 决定私聊怎么分 session
- 单人自用更适合 `main`
- 多人共享更适合 `per-channel-peer`
- `isolated` cron 天生就是独立后台任务
- `heartbeat` 更像主会话定期自检
- `cron` 更适合固定时间动作
- cron 负责把事情提起来，规则文件负责把后续动作做完整

如果你已经读完前面几章，这一章之后最适合回看的章节是：

- [02-OpenClaw-安装部署与首次跑通.md](/D:/00容器/openclaw/book/02-OpenClaw-安装部署与首次跑通.md)
- [03-OpenClaw-配置命令与日常维护.md](/D:/00容器/openclaw/book/03-OpenClaw-配置命令与日常维护.md)
- [16-OpenClaw-工作区根文件-AGENTS-SOUL-USER-IDENTITY-TOOLS-HEARTBEAT-BOOTSTRAP-MEMORY.md](/D:/00容器/openclaw/book/16-OpenClaw-工作区根文件-AGENTS-SOUL-USER-IDENTITY-TOOLS-HEARTBEAT-BOOTSTRAP-MEMORY.md)
- [17-OpenClaw-系统提示词与上下文注入-模型到底看到了什么.md](/D:/00容器/openclaw/book/17-OpenClaw-系统提示词与上下文注入-模型到底看到了什么.md)
