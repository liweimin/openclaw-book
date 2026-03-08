# OpenClaw 调试可见性与远程调试最佳实践

## 这份文档解决什么问题

你现在的核心诉求不是“让 Agent 更聪明”，而是先把它变得**更可观察**。

对小白来说，调试 Agent 最痛苦的点通常有 4 个：

1. 不知道它当前用的是哪个模型、哪个会话、哪些设置。
2. 不知道它到底看到了哪些上下文文件。
3. 不知道它有没有真的调用工具、为什么结果不一样。
4. 远程用飞书测的时候，很多内部细节看不见，不知道是没生效，还是渠道不显示。

结合源码看，OpenClaw 其实已经有一套适合调试的命令和机制，只是分散在 slash commands、status、context、verbose、reasoning、channel dispatcher 这些模块里。你现阶段最应该做的不是先改一堆源码，而是先把已有调试能力用起来，再决定哪些信息确实还不够，再补扩展命令。

---

## 先说结论

如果你现在就要开始调试，最有用的一组命令是：

```text
/status
/context list
/context detail
/usage tokens
/usage full
/verbose on
/verbose full
/verbose off
/model
/model status
/queue
/new
/reset
/compact
/export-session
```

这组命令已经能解决大部分“它现在到底在干嘛”的问题。

但有一个很关键的结论要先记住：

**OpenClaw 并不是所有渠道都会把内部过程完整显示出来。**

从源码看，`reasoning`、`block reply`、`tool result` 这些内部信息，是否真的会出现在聊天里，和具体渠道实现强相关。飞书可以做得比普通 web/WhatsApp 更丰富，但它也不是“完整内部镜像”。所以远程调试一定要采用：

**聊天命令观察 + 网关日志兜底 + 必要时导出会话**

而不是只盯着聊天气泡本身。

---

## 一、源码里已经有的调试能力

### 1. `/status`：先看“当前运行状态”

这是最先用的命令。

结合 `src/auto-reply/status.ts`，`/status` 会给出几类核心信息：

- 当前 session key
- 最近活动时间
- 当前上下文占用 `Context: 已用/总窗口`
- 压缩次数 `Compactions`
- 当前 runtime
- 当前 think 等级
- 当前 verbose 是否开启
- 当前 reasoning 是否开启
- 当前 elevated 是否开启
- 当前 queue 模式
- 当前 group activation 模式
- 当前模型和部分 provider usage 信息

对小白来说，你可以把 `/status` 理解成：

**“我现在这个会话的运行控制面板快照。”**

适合回答的问题：

- 现在是不是还在原来的会话里？
- 上下文是不是快爆了？
- `/verbose` 到底开没开？
- `/reasoning` 到底是不是 off？
- 当前是不是换成了别的模型？
- 队列是不是堆住了？

### 2. `/context list` 和 `/context detail`：看它到底吃进去了什么上下文

这是调试里最容易被忽视、但其实最重要的一组。

结合 `docs/concepts/context.md` 和 `src/auto-reply/reply/commands-context-report.ts`，`/context` 不是给你看“聊天记录全文”，而是给你看：

- 当前 workspace 是哪个目录
- bootstrap 文件注入了哪些
- 每个文件是否存在
- 每个文件是否被截断
- 每个文件原始大小和注入大小
- skills 列表占多少 prompt
- tools 列表和 tool schema 占多少 prompt
- system prompt 总体大小
- session token 总量

其中：

- `/context list` 适合日常排查
- `/context detail` 适合深入排查
- `/context json` 适合后续做自动分析或自己写工具

你可以把它理解成：

**“模型真正看到的上下文构成报告。”**

这条命令尤其适合排查：

- 为什么它没遵守 `AGENTS.md`
- 为什么 `TOOLS.md` 看起来写了，但行为没生效
- 为什么 `MEMORY.md` 里的内容它这轮没记住
- 为什么上下文越来越重
- 为什么它突然忘了前面说过的话

### 3. `/verbose on|full|off`：看更多工具过程，但不是无限展开

结合 `docs/zh-CN/tools/thinking.md`：

- `off`：默认，最安静
- `on`：显示更明显的工具摘要 / 元信息消息
- `full`：比 `on` 更激进，还会转发一部分工具输出

源码说明它的目标是“debugging and extra visibility”，不是日常默认开启。

对小白来说，这个命令可以理解成：

- `/verbose on`：看“做了哪些动作”
- `/verbose full`：看“做了哪些动作 + 动作返回了什么”

但要注意两点：

1. 它是**会话级设置**，不是全局永久设置。
2. 具体渠道不一定把所有内部 block/tool 信息都原样展示出来。

所以 `verbose` 很有用，但不要误解成“打开后一定能看到完整内部流程”。

### 4. `/usage tokens|full|cost`：看每轮消耗

如果你要长期调试 Agent，这个命令非常值。

它能让普通回复后面附 usage 信息，用来观察：

- 这轮是不是吃了很多 token
- 最近是不是因为上下文变长成本上升了
- 某个技能、某个工具是不是导致 token 爆炸

建议：

- 平时开 `/usage tokens`
- 深入排查时开 `/usage full`

### 5. `/model` 和 `/model status`：确认模型层有没有跑偏

很多“Agent 怎么变笨了”的问题，本质是模型、provider、auth profile、endpoint 变了。

`/model` 用来切换模型。
`/model status` 用来查：

- 当前模型
- 当前 provider
- endpoint / baseUrl
- api 模式
- 认证相关状态

如果你准备飞书远程测，这条命令很重要，因为你没法总坐在电脑前面看本地控制台。

### 6. `/queue`、`/new`、`/reset`、`/compact`

这组是会话调试辅助命令：

- `/queue`：看当前消息队列模式
- `/new` / `/reset`：清理会话污染
- `/compact`：压缩旧历史，防止上下文过重

如果你在远程测试时发现“它像在带着旧话题继续跑”，优先怀疑会话污染，而不是先怀疑模型坏了。

### 7. `/export-session`

这是非常适合调试归档的命令。

它可以把当前 session 导出成 HTML，包含完整系统提示词。对后续复盘很有价值，尤其适合：

- 某次错误行为要留档
- 想分析“这轮到底注入了什么”
- 想把一次复杂测试导出来慢慢看

---

## 二、你最想看的几种“内部信息”，源码上分别是什么情况

### 1. “把思考过程显示出来”

这里要分清楚两件事：

- `thinking`：模型预算/思考强度
- `reasoning visibility`：是否把 reasoning 作为消息显示出来

源码里对应的是：

- `/think <level>`
- `/reasoning on|off|stream`

但这里必须非常谨慎。

从源码可以确认：`ReplyPayload.isReasoning` 明确标记了 reasoning block，而且注释里写了：

- 没有 dedicated reasoning lane 的渠道应该 suppress

此外：

- `stream` 只明确支持 Telegram
- generic dispatch 路径会 suppress reasoning payload
- web 渠道测试里也明确有 suppress reasoning 的逻辑

这说明：

**你不能把“显示完整思考过程”当成一个跨渠道稳定能力。**

而且从产品设计上，这类信息也不适合长期对外暴露。

更好的做法不是追求“完整思维链外显”，而是做下面这些更稳的调试能力：

- 当前 think 等级
- 当前 reasoning 是否开启
- 最近一次关键决策摘要
- 最近一次工具调用链摘要
- 最近一次失败原因摘要

也就是说，更推荐“结构化调试痕迹”，而不是“完整思考原文”。

### 2. “把工具调用显示出来”

这比显示 thinking 更现实。

结合 `docs/zh-CN/tools/thinking.md`，`/verbose on/full` 会让工具调用以元信息消息形式更明显地暴露出来。

但渠道仍然重要。

源码里能看到：

- generic dispatch 有 suppress tool summary 的场景
- Feishu reply dispatcher 的测试里明确有 `suppresses internal block payload delivery`
- 这意味着你在飞书上不应该期待完整内部 block 全部可见

所以更稳妥的思路是：

- 用 `/verbose on` 看“调用了哪些工具”
- 用 `/verbose full` 尽量看更多结果
- 用 `/status` + `/context` 辅助判断
- 真正深入排查时，用 `openclaw logs --follow`

### 3. “看上下文”

这个需求 OpenClaw 其实已经有现成能力，最对应的就是：

- `/status`
- `/context list`
- `/context detail`
- `/export-session`

其中 `/context detail` 是最关键的。

如果你以后还想扩展，我建议不要做一个笼统的“/show-context”，而是拆成几类：

- 当前 bootstrap 文件注入情况
- 当前 memory 文件是否存在/是否截断
- 当前 system prompt 体积
- 当前 session 历史体积
- 当前 tool schema 占用

这样更适合调试。

---

## 三、飞书远程调试时，你能看到什么，不能看到什么

结合 `docs/channels/feishu.md`、`extensions/feishu/src/reply-dispatcher.ts`、`extensions/feishu/src/streaming-card.ts`，可以得出一个比较实用的判断。

### 飞书现有优势

飞书不是最弱的渠道，它已经支持：

- 文本 slash commands（注意：不是 native 菜单）
- streaming replies
- interactive cards
- block streaming card 更新
- typing indicator（可关）

这意味着它做远程“观察最终状态”和“观察流式回答”是可行的。

### 飞书现有限制

但飞书并不是完整的内部调试控制台。

源码里有几个很重要的限制：

1. 文档写明 Feishu 目前不支持 native command menus，所以命令要手输文本。
2. reply dispatcher 测试明确写了 `suppresses internal block payload delivery`。
3. reasoning / block payload 是否显示，不应按“本地 TUI 的预期”来理解。
4. 某些内部工具结果不会像你想象中那样稳定地逐条外显。

所以你在飞书里更适合看的是：

- `/status` 的状态快照
- `/context` 的上下文报告
- `/usage` 的 token/cost 信息
- `/model status` 的模型状态
- 最终回复结果
- 部分 streaming / card 过程

而不适合期待：

- 完整 reasoning 链
- 所有内部 block
- 所有 tool result 原样逐条外放

### 结论

飞书适合做：

- 远程功能测试
- 远程状态排查
- 远程会话控制
- 远程轻量 debug

飞书不适合单独承担：

- 深度内部链路调试
- 完整工具过程取证
- 全量推理可视化

真正深调时，还是要结合：

```text
openclaw gateway status
openclaw logs --follow
```

---

## 四、给你一套“飞书远程调试”的实际流程

这是我建议你刚接飞书时直接照着用的一套流程。

### 场景 1：怀疑 Agent 配置没生效

先发：

```text
/status
/context list
/context detail
```

重点看：

- 当前是不是你预期的 session
- `AGENTS.md` / `SOUL.md` / `TOOLS.md` / `USER.md` / `MEMORY.md` 是否存在
- 文件是否被截断
- system prompt 体积是不是过大
- 当前上下文是不是已经接近上限

### 场景 2：怀疑它没正确调用工具

先发：

```text
/verbose on
/status
```

然后让它执行一个明确任务，比如：

```text
请读取当前目录下的 AGENTS.md 并总结重点。
```

如果你还不够确定，再切：

```text
/verbose full
```

测完记得关：

```text
/verbose off
```

### 场景 3：怀疑上下文太脏，前后污染了

先发：

```text
/status
/compact
/status
```

如果还是不对：

```text
/reset
/status
```

### 场景 4：怀疑是模型/渠道问题，不是 Prompt 问题

发：

```text
/model status
/status
/usage full
```

重点看：

- 当前 provider / model
- token usage 是否异常
- 当前运行是不是你想要的模型

### 场景 5：一次复杂问题要留档

发：

```text
/export-session
```

然后结合本地日志一起复盘。

---

## 五、如果你后面要扩展“调试命令”，最值得加什么

你这个想法是对的，但建议不要先做“显示全部思考过程”。

更实用的是补一组**结构化调试命令**。

我建议优先级如下。

### 第一优先级：`/debug-session`

建议输出：

- 当前 agentId
- sessionKey
- parentSessionKey
- 当前 channel
- 当前 queue mode
- 当前 model/provider
- think / verbose / reasoning / elevated
- 当前是否 group session
- 当前 activation mode

为什么值钱：

因为现在这些信息分散在 `/status` 和内部状态里，小白看起来不够聚合。

### 第二优先级：`/debug-bootstrap`

建议输出：

- `AGENTS.md`
- `SOUL.md`
- `TOOLS.md`
- `IDENTITY.md`
- `USER.md`
- `MEMORY.md`
- `HEARTBEAT.md`
- `BOOTSTRAP.md`

每个项目显示：

- 是否存在
- 原始大小
- 注入大小
- 是否截断
- 最后修改时间

为什么值钱：

这比 `/context detail` 更贴近“调教 Agent 时我到底写进去了什么”。

### 第三优先级：`/debug-tools`

建议输出最近 N 次工具调用：

- 工具名
- 参数摘要
- 开始时间
- 完成时间
- 是否成功
- 结果摘要
- 是否被截断

为什么值钱：

这正对应你最想看的“工具到底有没有被调用”。

### 第四优先级：`/debug-memory`

建议输出：

- 当前 workspace 的 `MEMORY.md` 是否存在
- `memory/` 目录是否存在
- 最近几条 memory 文件
- 最近一次 memory_search / memory_get 是否命中
- 当前这轮是否注入了 memory bootstrap 文件

为什么值钱：

很多用户以为“记忆没生效”，其实是文件没写进去、没被检索到，或者根本不是当前 agent/workspace。

### 第五优先级：`/debug-channel`

建议输出：

- 当前渠道是否支持 native commands
- 是否支持 block streaming
- 是否支持 reasoning lane
- 是否支持 tool result 直出
- 是否启用了 streaming card
- typingIndicator 是否开启

为什么值钱：

这能直接解决“为什么飞书上看不到、但本地能看到”的误解。

---

## 六、如果你真的要自己做这些命令，源码从哪里下手

结合源码，调试命令的入口大致在这几块：

### 1. 命令注册

看：

- `src/auto-reply/commands-registry.data.ts`
- `src/auto-reply/commands-registry.ts`

这里负责：

- 命令定义
- 参数描述
- 文本别名
- native command spec

简单理解：

**先在这里把命令“挂出来”。**

### 2. 命令处理逻辑

你重点可以参考现成实现：

- `src/auto-reply/reply/commands-context-report.ts`
- `src/auto-reply/reply/commands-status.ts`

如果你要加 `/debug-session`、`/debug-bootstrap`、`/debug-tools`，最像的实现模板其实就是这两个。

简单理解：

**这里负责真正组织返回文本。**

### 3. 状态来源

看：

- `src/auto-reply/status.ts`
- `src/auto-reply/thinking.ts`
- `src/auto-reply/reply/session.ts`
- `src/auto-reply/reply/get-reply-directives.ts`

这里能拿到：

- think / verbose / reasoning / elevated
- session 状态
- queue
- context token 信息
- 当前 run 的部分控制状态

### 4. 飞书渠道适配

看：

- `extensions/feishu/src/reply-dispatcher.ts`
- `extensions/feishu/src/streaming-card.ts`
- `extensions/feishu/src/feishu-command-handler.ts`

这里决定的是：

- 消息最终怎么在飞书里展示
- streaming card 怎么更新
- 某些 block / command 怎么处理

简单理解：

**命令能不能显示是一回事，显示成什么样是渠道层的事。**

---

## 七、我对你这个需求的实现建议

### 不建议直接做

- “显示完整思考过程”
- “把所有内部工具输出都默认发到聊天里”

原因：

- 容易泄露不该暴露的内部内容
- 不稳定，跨渠道一致性差
- 信息噪声太大，小白反而更看不懂
- 飞书这类渠道并不适合承载完整内部链路

### 更建议做

做“结构化调试层”，而不是“裸露内部链路”。

推荐组合：

1. 用现成命令先覆盖 70% 调试需求。
2. 追加 3-5 个聚合型 debug 命令。
3. 在飞书里只看摘要，在本地日志里看细节。
4. 把 `/verbose` 保持为临时开关，不要长期默认打开。
5. 对 reasoning 做摘要化，而不是直接暴露全部内容。

---

## 八、你现在最适合立刻执行的调试配置

### 对话侧

建议你先把这几条当成固定调试手册：

```text
/status
/context list
/context detail
/usage tokens
/model status
/verbose on
/verbose off
/reset
/export-session
```

### 飞书侧

先确保：

- 能正常收发消息
- `streaming` 开着
- `blockStreaming` 开着
- 你知道飞书只支持文本命令，不支持 native command menu

### 排障侧

一旦飞书上看不清楚，就去本地/服务器看：

```text
openclaw gateway status
openclaw logs --follow
```

这是必须保留的兜底手段。

---

## 九、最终建议

如果你的目标是“把 Agent 调教到能稳定帮你干活”，调试体系应该按这个顺序迭代：

1. 先把现有命令用熟，不要上来就改源码。
2. 先在飞书上做轻量调试，不把它当完整开发控制台。
3. 用 `/status` + `/context` 建立“当前状态快照”的习惯。
4. 用 `/verbose` 做临时放大镜，而不是常驻模式。
5. 真要扩展时，优先加结构化 debug 命令，不要追求完整思维链外显。

如果你后面愿意继续往前走，下一步最值的是：

**直接为你设计一套“调试增强命令方案”**，包括：

- `/debug-session`
- `/debug-bootstrap`
- `/debug-tools`
- `/debug-memory`
- `/debug-channel`

并进一步给出一版“改哪些源码文件、命令返回什么字段、飞书里怎么展示”的具体实现草案。
