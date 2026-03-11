# 第四章：先接入一个真实入口，Channels 与 Feishu 实战

## 1. 为什么渠道是 OpenClaw 真正进入日常生活的关键

如果说 Dashboard 解决的是“先在本地跑通”，那么 Channels 解决的就是：

如何让 OpenClaw 真正进入你的日常工作和生活入口。

这也是 OpenClaw 和很多单机式 AI 工具最不一样的地方之一。它不是只能待在一个网页里聊天，而是可以进入：

- WhatsApp
- Telegram
- Discord
- Slack
- Feishu
- 以及更多消息入口

一旦渠道接通，OpenClaw 才会从“本地实验环境里的 AI”变成“你原本就在使用的工具链的一部分”。

## 2. 小白为什么一接渠道就容易乱

渠道接入最容易让人混乱，不是因为配置字段特别多，而是因为几件不同层次的问题会同时出现：

- OpenClaw 本体是否已经正常
- Gateway 是否在运行
- 平台凭证是否正确
- 私信和群聊策略是否合理
- 未知发送者是否需要审批
- 群里到底要不要 @ 提及

如果这些问题一起涌上来，你会感觉“渠道配置又碎又乱”。但本质上，它们并不属于同一层。

所以这一章的目标不是把所有渠道细节堆给你，而是先给你一套统一模型，再用飞书作为重点实战案例。

### 1.1 本章实操场景

这一章你应该完成的真实场景是：

把 OpenClaw 从“只在本地网页里可用”，推进到“至少在飞书私聊里可用”，并把第二章产出的 `ch02-first-run/first-plan.md` 真正带进飞书私聊里完成一次有价值的收发。

### 1.2 本章产物

读完这一章，你手里至少应该有下面这些结果：

- 飞书插件已经装好
- Feishu 渠道已经配置完成
- 飞书私聊里已经收到一条对你真的有用的结果

### 1.3 开始前先准备什么

开始前，先确认这几件事：

- 第二章已经跑通，本地 Dashboard 可用
- 你这次只准备先接飞书一个入口
- 你愿意先从私聊开始，而不是一上来就放开群聊

## 3. 先理解 Channels 的统一模型

虽然不同平台的术语和后台页面不一样，但 OpenClaw 在设计上尽量统一了几类核心问题。

### 私信访问

谁可以直接和机器人建立私聊关系。

### 群聊访问

某个群组、频道、房间是否允许机器人参与。

### 回复触发条件

群里是不是必须 @ 提及，回复机器人消息时算不算触发。

### 配对与 allowlist

未知发送者或新设备能不能先接进来，是否需要显式审批。

只要把这四件事分开理解，你看任何一个渠道文档都会轻松很多。

## 4. Pairing 到底是什么，为什么它不是“多余步骤”

官方配对文档给了一个很清楚的定义：配对是 OpenClaw 的显式所有者批准步骤。它主要用于两个地方：

1. 私信配对，也就是谁可以和机器人私聊
2. 节点配对，也就是哪些设备可以加入 Gateway 网络

对新手来说，最常遇到的是第一种。

当渠道的私信策略是 `pairing` 时，未知发送者会先收到一段短代码，他们的消息不会被处理，直到你批准。

这个机制之所以重要，是因为它把系统默认姿态从“谁来都能聊”改成了“由你决定谁能进入”。对于一个能执行工具、能读写文件、能接入工作渠道的系统来说，这不是麻烦，而是必要边界。

## 5. 群组规则为什么看起来很绕

群组比私聊复杂，是因为它天然多了一层公共空间规则。

官方群组文档可以被压缩成三步判断：

1. `groupPolicy` 允许这个群组吗
2. 群组本身在不在允许列表里
3. 当前消息是否满足触发条件，比如需要 @ 提及

如果你把这三件事混成一句“为什么群里不回我”，那当然会觉得很绕。

对小白来说，最关键的两个默认认知是：

- 群组通常是受限的，默认更接近 allowlist 思维
- 除非你明确放开，群里通常需要提及才会真正触发回复

所以群聊行为“不像私聊那样直接”，不是异常，而是设计使然。

## 6. 新手接渠道的统一步骤

不管你接的是哪一个平台，最稳的顺序通常都一样。

### 第一步：先把本体跑通

先确认：

- `openclaw gateway status`
- `openclaw status`
- `openclaw health`
- `openclaw dashboard`

这一步的意义不是走流程，而是把“渠道问题”和“本体问题”隔离开。

### 第二步：准备平台凭证

不同平台不一样：

- 有的是 token
- 有的是 App ID / Secret
- 有的是扫码登录
- 有的还要额外插件

### 第三步：用向导或 `channels add` 接入

小白优先用交互式流程：

```bash
openclaw onboard
```

或者：

```bash
openclaw channels add
```

### 第四步：接入后先看状态和日志

```bash
openclaw gateway status
openclaw logs --follow
```

如果你怀疑问题已经缩小到“渠道层”，再补一条：

```bash
openclaw channels status --probe
```

这条命令的价值很高，因为它不是只看 Gateway 活没活着，而是进一步检查渠道健康和常见配置错误。

### 第五步：先做最小测试

先私聊，后群聊。先简单消息，后复杂工作流。

这套顺序的价值非常大，因为它能显著降低排错时的变量数量。

### 6.1 渠道接入前的 30 秒检查单

真正开始接任何渠道前，你可以先用这张最小检查单过一遍：

1. `openclaw --version` 正常
2. `openclaw gateway status` 正常
3. `openclaw dashboard` 能打开
4. 你已经准备好该平台需要的凭证
5. 你决定好了这次只先接一个渠道

这五条里只要有一条不成立，就先不要往下接渠道。

## 7. 飞书为什么值得单独写一节

对中文用户来说，飞书是特别关键的渠道。很多人愿意继续投入 OpenClaw，恰恰是因为它不只会在本地网页里聊天，而是真能进入飞书这种日常工作入口。

更重要的是，官方飞书文档给出的支持状态不是“实验性”，而是：

- 生产就绪
- 支持机器人私聊和群组
- 使用 WebSocket 长连接模式接收消息

这说明飞书不是演示型集成，而是可以认真投入使用的正式入口。

## 8. 飞书接入前，先记住三个事实

### 第一，当前版本通常已经内置飞书插件

截至 2026 年 3 月，OpenClaw 当前版本里的 Feishu 通常已经是 bundled 插件，不需要再额外安装一遍。

你可以先检查：

```bash
openclaw plugins info feishu
```

如果你看到类似下面这些信息：

- `Status: loaded`
- `Source: stock:feishu/index.ts`
- `Origin: bundled`

就说明你现在 WSL 里用的，和官方当前版本内置的 Feishu 插件是同一条线，不是另一套平行实现。

只有在下面两种情况，才需要手动装：

- 你用的是较旧版本
- 你用的是没有内置 Feishu 的自定义安装

那时再执行：

```bash
openclaw plugins install @openclaw/feishu
```

这里还有一个很容易混的点要单独说清楚：

- 你现在机器上用的是 OpenClaw 的 Feishu 渠道插件
- 不是“飞书平台官方自己出的那套平台内插件能力”的同一个概念

按当前本机包信息，这个包名是 `@openclaw/feishu`，属于 OpenClaw 生态里的 Feishu/Lark 渠道插件；当前发布包描述里写的是 community maintained，并被当前 OpenClaw 版本 bundled 进来了。

所以更准确的理解是：

- 它不是你自己随便装的野路子三方包
- 但它也不是“飞书官方平台自己出品的插件包”
- 它是 OpenClaw 这一侧的正式集成入口

### 第二，推荐仍然是走向导或 `channels add`

对普通用户，最省心的入口依然是：

```bash
openclaw onboard
```

或者：

```bash
openclaw channels add
```

### 第三，先把 Gateway 跑稳，再去飞书后台点配置

如果 Gateway 没起来，你在飞书平台里做再多设置，也很难判断问题到底出在哪一层。

## 9. 一套适合小白的飞书接入顺序

如果把飞书实战重写成一本书里的标准流程，最推荐的顺序是下面这样。

### 第一步：先确认 OpenClaw 本体可用

不要一上来就在飞书后台狂点。先确认你本地的 Gateway、Dashboard、基础聊天都已经通了。

### 第二步：先确认飞书插件已经可用

优先先查状态：

```bash
openclaw plugins info feishu
```

如果当前版本里已经是 bundled，就不用重复安装。

只有旧版或自定义安装，才需要：

```bash
openclaw plugins install @openclaw/feishu
```

### 第三步：到飞书开放平台创建应用

你需要准备：

- App ID
- App Secret

如果你使用的是国际版 Lark，还要额外注意域名配置。

### 第四步：配置机器人能力、权限和事件订阅

官方文档给出的关键动作包括：

- 启用机器人能力
- 配置所需权限
- 使用长连接接收事件

对于第一次接入的人，这一步最重要的不是先把回调、签名、Webhook 全研究一遍，而是先把长连接模式跑通。

### 第五步：回到 OpenClaw 配置渠道

优先用：

```bash
openclaw channels add
```

按提示选择 Feishu，再填入 App ID 和 App Secret。

### 第六步：先看日志，再做测试

```bash
openclaw gateway status
openclaw channels status --probe
openclaw logs --follow
```

如果你在执行 `openclaw status`、`openclaw channels status --probe` 之类命令时，开头总看到：

```text
[plugins] feishu_doc: Registered feishu_doc, feishu_app_scopes
[plugins] feishu_chat: Registered feishu_chat tool
[plugins] feishu_wiki: Registered feishu_wiki tool
[plugins] feishu_drive: Registered feishu_drive tool
[plugins] feishu_bitable: Registered bitable tools
```

这通常不是报错，而是插件加载时在注册工具：

- `feishu_doc`
- `feishu_chat`
- `feishu_wiki`
- `feishu_drive`
- `feishu_bitable`
- `feishu_app_scopes`

也就是说，OpenClaw 每次启动一个 CLI 进程时，会先把已加载插件和工具注册一遍；你现在看到的是正常启动信息，不是异常。

### 第七步：先测私聊，再测群聊

这是整个飞书接入里最值得坚持的顺序。先验证私聊可达，再去验证群组策略、提及规则和权限边界。

### 9.1 一份更稳的批量导入权限

飞书后台的权限名字会随着时间调整，而且 OpenClaw 中英文文档快照之间也可能有轻微漂移。

所以书里最稳的做法不是说“这一份永远不变”，而是给你一份截至 2026 年 3 月、基于 OpenClaw 官方文档快照合并出的实操版。

下面这份更适合你现在这种用途：

- 先把私聊和群聊跑通
- 文档、知识库、云盘、表格能力先一次性开到位
- 后面如果真的要重度用多维表格或权限管理，再按报错补 scope

```json
{
  "scopes": {
    "tenant": [
      "aily:file:read",
      "aily:file:write",
      "application:application.app_message_stats.overview:readonly",
      "application:application:self_manage",
      "application:bot.menu:write",
      "cardkit:card:read",
      "cardkit:card:write",
      "contact:user.employee_id:readonly",
      "corehr:file:download",
      "docs:document.content:read",
      "event:ip_list",
      "im:chat",
      "im:chat.access_event.bot_p2p_chat:read",
      "im:chat.members:bot_access",
      "im:message",
      "im:message.group_at_msg:readonly",
      "im:message.group_msg",
      "im:message.p2p_msg:readonly",
      "im:message:readonly",
      "im:message:send_as_bot",
      "im:resource",
      "sheets:spreadsheet",
      "wiki:wiki:readonly"
    ],
    "user": [
      "aily:file:read",
      "aily:file:write",
      "im:chat.access_event.bot_p2p_chat:read"
    ]
  }
}
```

这份权限已经比“最小可用”宽很多了，但仍然要知道两个边界：

1. 它不是飞书平台所有权限的全集，而是当前 OpenClaw 飞书接入最实用的一份大合集。
2. 如果你后面要重度使用 `feishu_bitable_*` 或权限分配类工具，仍然可能需要补新的 scope。

最稳的排错方式是：

1. 先让机器人跑起来
2. 真遇到某个飞书工具权限不足
3. 再让它执行 `feishu_app_scopes` 自检，并回飞书后台补授权

### 9.2 事件与回调到底怎么配

这一块最容易把人绕晕，其实先分两种模式就行。

#### 情况 A：你现在这种 WSL / 本机 OpenClaw 常规接法

优先用：

- 长连接
- WebSocket
- 使用长连接接收事件

飞书后台要做的关键动作只有两个：

1. 开启机器人能力
2. 在事件订阅里添加 `im.message.receive_v1`

这种模式下，你通常不需要：

- 配公网回调 URL
- 配反向代理
- 配 `verificationToken`

因为消息是由 OpenClaw 主动发起长连接来接收的。

如果你在飞书后台保存长连接配置时，看到类似：

```text
未检测到应用连接信息，请确保长连接建立成功后再保存配置
```

优先不要回飞书后台反复点保存，而是先回本机检查这 3 件事：

1. 新机器人的 `App ID / App Secret` 是否已经写进 `~/.openclaw/openclaw.json`
2. 这个新账号是否已经通过 `bindings` 路由给目标 agent
3. `openclaw gateway restart` 之后，`openclaw channels status --probe` 里这个账号是否已经显示为 `running, works`

只有当这一步已经成立，飞书后台那边的“长连接已建立”才更容易保存成功。

#### 情况 B：你明确要走 Webhook

只有在下面这类场景，才建议研究 Webhook：

- 你有自己的公网入口
- 你明确要走回调 URL 模式
- 你不是按 OpenClaw 当前默认推荐方式来接飞书

这时你才需要关心：

- 回调地址
- 加密策略
- `verificationToken`
- `channels.feishu.connectionMode: "webhook"`

所以如果你现在在飞书后台看到“事件与回调”“加密策略”“Verification Token”这些词，不要先慌。

对你当前这套做法，优先级是：

1. 先选长连接
2. 先加 `im.message.receive_v1`
3. 先把机器人发布出来
4. 先回到 OpenClaw 跑通消息收发

### 9.3 如果私聊需要审批，你该怎么做

飞书这类渠道默认常常会把私聊策略收得比较紧。对新手来说，这不是坏事，而是保护。

如果私聊触发了 pairing，你可以直接这样处理：

先查看待审批列表：

```bash
openclaw pairing list feishu
```

然后批准某个配对码：

```bash
openclaw pairing approve feishu <CODE>
```

如果你希望对方在批准后收到通知，可以按官方 CLI 方式加上 `--notify`。

这一节最重要的认知是：很多“私聊没反应”并不代表飞书接入失败，而只是因为它还在等你审批配对。

### 9.4 第一次飞书验证，不要只发“你好”

飞书一旦接通，很多人第一反应是去发一句“你好”。这能说明渠道活着，但不能说明它已经进入了你的实际工作流。

更有价值的做法是：把第二章生成的 `ch02-first-run/first-plan.md` 拿来，在飞书私聊里做一次真正有用的整理。

你可以直接在飞书私聊里发下面这段话：

```text
请读取工作区里的 ch02-first-run/first-plan.md，把它压缩成“今天最该做的 3 件事”。

要求：
1. 每条不超过 20 个字。
2. 用中文。
3. 直接回复在当前飞书私聊里。
4. 最后再补一句：如果今天只有 30 分钟，先做哪一件。
```

如果你前面还没有生成 `first-plan.md`，也可以换成你当前工作区里任意一个 Markdown 文件。关键不是文件名，而是你已经把“本地材料 -> 飞书结果”这条链路真正跑通。

### 9.5 如果你想给 `archive-search` 单独接第二个飞书机器人

这是很值得写进实战书里的一个升级动作。

因为：

- `main` 适合日常综合处理
- `archive-search` 适合低频搜全局历史
- 单独给 `archive-search` 一个机器人，比让它混进 `main` 更清爽

最小配置思路是：

1. 再创建一个飞书企业自建应用
2. 这个应用同样开启机器人能力、长连接和 `im.message.receive_v1`
3. 在 `~/.openclaw/openclaw.json` 里新增一个 Feishu account
4. 用 `bindings` 把这个新 account 路由给 `archive-search`

示例：

```json5
{
  channels: {
    feishu: {
      enabled: true,
      accounts: {
        main: {
          appId: "cli_main_xxx",
          appSecret: "xxx"
        },
        archive: {
          appId: "cli_archive_xxx",
          appSecret: "yyy",
          botName: "Archive Search"
        }
      }
    }
  },
  bindings: [
    { channel: "feishu", accountId: "main", agentId: "main" },
    { channel: "feishu", accountId: "archive", agentId: "archive-search" }
  ]
}
```

配置完后执行：

```bash
openclaw gateway restart
openclaw channels status --probe
```

如果你是第一次和这个新机器人私聊，还要再走一次 pairing。

这一点和“同一个机器人改绑到别的 agent，不需要重新 pairing”是两回事：

- 同一个飞书账号改绑 agent：通常不用重新 pairing
- 全新的飞书机器人账号：要重新 pairing

## 10. 飞书最小配置应该怎么理解

官方文档给出的配置结构并不难。对小白来说，第一次只需要抓住三件事：

- 飞书渠道有没有启用
- 账号凭证写在哪里
- 私信策略是什么

一个适合入门理解的最小配置大致像这样：

```json5
{
  channels: {
    feishu: {
      enabled: true,
      dmPolicy: "pairing",
      accounts: {
        main: {
          appId: "cli_xxx",
          appSecret: "xxx",
          botName: "我的 AI 助手",
        },
      },
    },
  },
}
```

这个例子最值得你看懂的，不是字段多不多，而是：

- 飞书挂在 `channels.feishu` 下面
- `accounts` 里放账号凭证
- `dmPolicy: "pairing"` 代表私信默认要先审批

一旦这三个点弄明白，你就已经能读懂大多数飞书配置了。

## 11. 私聊和群聊，应该怎样逐步放开

最稳的顺序通常是三阶段。

### 阶段一：只验证私聊

先确认：

- 能收到消息
- 能回消息
- pairing 逻辑正常

### 阶段二：只验证一个群

重点看三件事：

- 群是否被允许
- 是否必须 @ 提及
- 哪些人可以触发

### 阶段三：再扩到更多群和更多渠道

这个顺序的好处非常现实：一旦失败，你能快速判断问题是出在 DM 配对、群组策略、权限设置，还是平台事件接收。

## 12. 多渠道接入时，最务实的策略是什么

### 先确定一个主渠道

不要第一次就想把所有 IM 都接齐。先选一个你最常用、最愿意长期使用的入口。

### 再决定是否需要分 Agent

如果不同渠道承担完全不同的工作，比如飞书负责工作事务，Telegram 负责个人提醒，Discord 用于技术社区，那么后面再考虑多 Agent 或多路由才更合理。

### 安全策略永远先于“功能全开”

pairing、allowlist、groupPolicy、requireMention 这些看起来麻烦，但它们决定的是：

- 你的机器人会不会被滥用
- 哪些群组会不会变成噪声源
- 你是否还能解释清楚“为什么这条消息会被处理”

## 13. 新手最常见的三类渠道问题

### 私聊没反应

优先怀疑：

- 配对还没批准
- 平台凭证有误
- Gateway 根本没起来

### 私聊可以，群里不回

优先看：

- `groupPolicy`
- 群是否在允许列表里
- 是否要求 @ 提及

### 配置看着都对，但完全收不到消息

优先看：

- 插件是否安装
- 平台事件订阅是否生效
- 日志里有没有渠道连接错误

把问题按这三类去拆，排错速度会快很多。

### 13.1 飞书接入成功的最小验收标准

对新手来说，不要用“感觉差不多”来判断飞书有没有接成功。用下面这 5 条更稳：

1. Feishu 插件已经可用；当前版本通常会显示为 bundled
2. `openclaw channels add` 已经完成 Feishu 配置
3. `openclaw channels status --probe` 没有明显致命错误
4. 私聊里至少能完成一次收消息和回消息
5. 群聊里至少能按你的策略完成一次触发

这五条里，前四条通过了，才建议你开始调群聊策略。

## 14. 本章小结

你可以把 Channels 理解成“OpenClaw 进入真实入口的那一步”。

接渠道不是简单填个 token，而是把下面这些东西一起接进系统：

- 身份
- 权限
- 回复策略
- 安全边界
- 会话模型

其中飞书之所以值得重点写，是因为它对中文用户非常关键，而且官方已经把它做成了可以认真使用的正式渠道。

### 14.1 本章验收标准

做到下面这 5 条，这一章才算真正完成：

1. 飞书插件已经可用；当前版本通常不需要额外安装
2. `openclaw channels add` 已经完成 Feishu 配置
3. `openclaw channels status --probe` 没有明显致命错误
4. 你已经在飞书里完成过至少一次真实的私聊收发
5. 你已经在飞书里拿到一条对自己真的有用的结果，而不是只做了“你好”测试

### 14.2 如果你后面卡在这些问题，优先回看哪一章

- 不清楚飞书、网页搜索、浏览器取证、Skills 这些能力在真实场景里怎么搭配：
  - [12-OpenClaw-搜索工具与技能-从web_search到ClawHub.md](/D:/00容器/openclaw/book/12-OpenClaw-搜索工具与技能-从web_search到ClawHub.md)
- 不清楚为什么同一个飞书机器人里，不同消息会像落到不同对话桶里；或者为什么 cron/heartbeat 会“自己开一轮”：
  - [18-OpenClaw-会话与定时机制-dmScope-main-isolated-cron-heartbeat.md](/D:/00容器/openclaw/book/18-OpenClaw-会话与定时机制-dmScope-main-isolated-cron-heartbeat.md)
- 不清楚根文件、系统提示词、技能列表到底什么时候会进入上下文：
  - [16-OpenClaw-工作区根文件-AGENTS-SOUL-USER-IDENTITY-TOOLS-HEARTBEAT-BOOTSTRAP-MEMORY.md](/D:/00容器/openclaw/book/16-OpenClaw-工作区根文件-AGENTS-SOUL-USER-IDENTITY-TOOLS-HEARTBEAT-BOOTSTRAP-MEMORY.md)
  - [17-OpenClaw-系统提示词与上下文注入-模型到底看到了什么.md](/D:/00容器/openclaw/book/17-OpenClaw-系统提示词与上下文注入-模型到底看到了什么.md)

## 15. 下一章

- [05-OpenClaw-五个从本地到飞书的实战场景.md](05-OpenClaw-五个从本地到飞书的实战场景.md)

> [!NOTE]
> 本章内容基于 OpenClaw 当前版本验证（截至 2026 年 3 月）。
> 如果你使用更新版本，关键命令和配置项请以官方源码为准。

## 本章核验依据（官方文档 / 源码）

- `../sources/official/openclaw/docs/zh-CN/channels/feishu.md`
- `../sources/official/openclaw/docs/zh-CN/channels/pairing.md`
- `../sources/official/openclaw/docs/zh-CN/channels/groups.md`
- `../sources/official/openclaw/docs/zh-CN/start/getting-started.md`

## 本章合并来源

这一章主要吸收并改写了以下归档文档中的主题：

- `openclaw_feishu_guide.md`
- `openclaw_feishu_codex_guide.md`
- `openclaw_feishu_full_playbook_2026-03-05.md`
- `openclaw_newbie_guide.md`
- `openclaw_commands_beginners_reference_2026-03-06.md`


