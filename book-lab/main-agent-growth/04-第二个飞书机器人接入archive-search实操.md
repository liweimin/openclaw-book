# 第二个飞书机器人接入 archive-search 实操

这份文档解决的是一个很具体的问题：

- `main` 已经是默认总入口了
- `archive-search` 已经建好了
- 现在想再给 `archive-search` 单独接一个飞书机器人

这样做的价值是：

- `main` 继续负责日常综合处理
- `weekly-assistant` 继续负责 weekly / daily
- `industry-research-assistant` 继续负责研究
- `archive-search` 单独负责“搜全局历史、搜归档、搜共享知识”

这比把所有搜索需求都塞给 `main` 更清爽。

## 1. 先回答一个常见疑问：官方插件和我 WSL 里的插件是不是同一个

截至 2026 年 3 月，这里本机实测到的结果是：

```bash
openclaw plugins info feishu
```

会显示类似：

- `Status: loaded`
- `Source: stock:feishu/index.ts`
- `Origin: bundled`
- `Version: 2026.3.8-beta.1`

这说明你现在 WSL 里的 Feishu 插件，就是 OpenClaw 当前版本自带的那套官方插件，不是另一套平行实现。

如果你在网上看到“飞书官方插件更新了”，更接近的理解通常是：

- 文档更新了
- 内置插件版本更新了
- 旧版安装方式和新版 bundled 方式并存了一段时间

而不是：

- 你本机正在用一套，官方又另有一套完全不同的插件

只有在旧版或者自定义安装里，才需要手动执行：

```bash
openclaw plugins install @openclaw/feishu
```

另外要把两个“插件”概念分开：

- 你现在机器上用的是 OpenClaw 侧的 Feishu 渠道插件
- 你听说的“飞书官方自己出了插件能力更强”，更可能是在说飞书平台自身的插件/能力体系

这两者不是同一个东西。

按当前本机包信息，`@openclaw/feishu` 是 bundled 到 OpenClaw 里的 Feishu/Lark channel plugin；当前包描述里写的是 community maintained。最稳的理解是：

- 它是 OpenClaw 生态里的正式集成入口
- 不是你自己乱装的包
- 但也不是飞书官方平台那边发布的同一套插件

## 2. 第二个飞书机器人的定位

这只新机器人建议只做一件事：

- 把消息路由给 `archive-search`

不要把它再做成第二个 `main`，不然你后面会混乱：

- 这件事该问 `main`
- 还是该问 `archive-search`

更稳的边界是：

### `main`

- 日常综合处理
- 起草
- 执行
- 默认入口

### `archive-search`

- 搜旧聊天
- 搜旧草稿
- 搜跨 agent 历史
- 搜归档内容
- 搜共享知识层

## 3. 飞书后台怎么配

### 第一步：创建企业自建应用

进入：

- 中国大陆版：`https://open.feishu.cn/app`
- 国际版 Lark：`https://open.larksuite.com/app`

创建一个新的企业自建应用。

建议命名时就写清楚用途，比如：

- `OpenClaw Archive Search`
- `OpenClaw 历史搜索`

### 第二步：开启机器人能力

在应用能力里：

1. 开启机器人能力
2. 配置机器人名称
3. 选一个容易辨认的头像

### 第三步：权限批量导入

这份 JSON 适合当前这类 OpenClaw 飞书接入场景。

它的思路是：

- 先把聊天、文档、知识库、云盘、表格相关权限尽量一次性开齐
- 避免后面每做一件事就回飞书后台补一次

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

1. 它不是飞书平台所有权限的全集。
2. 如果你后面重度使用多维表格权限管理，仍可能要补 scope。

所以更稳的工作流是：

1. 先导这份
2. 先把机器人跑通
3. 真遇到权限不足，再让 OpenClaw 用 `feishu_app_scopes` 自检

### 第四步：事件与回调怎么配

这里最容易误会。

你现在这套 OpenClaw WSL 接法，推荐的是：

- 长连接
- WebSocket
- 使用长连接接收事件

飞书后台最关键的动作只有：

1. 在事件订阅里选择“使用长连接接收事件”
2. 添加事件：`im.message.receive_v1`

这种模式下，你通常不需要先配置：

- 回调 URL
- 公网地址
- `verificationToken`

因为消息不是靠飞书主动回调到你的公网服务，而是 OpenClaw 主动用长连接接收。

如果你在飞书后台点保存时，看到：

```text
未检测到应用连接信息，请确保长连接建立成功后再保存配置
```

这通常不是飞书后台坏了，而是本机这边还没满足长连接建立条件。

最稳的处理顺序是：

1. 先把新机器人的 `App ID / App Secret` 写进 `~/.openclaw/openclaw.json`
2. 先把这个账号通过 `bindings` 路由给 `archive-search`
3. 执行：

```bash
openclaw gateway restart
openclaw channels status --probe
```

4. 看到新账号已经显示为 `running, works`
5. 再回飞书后台保存“使用长连接接收事件”

这轮真实实践里，`archive-search` 这只新机器人就是先卡在这里，等 OpenClaw 本机账号和路由配好、Gateway 重启完成后，后台保存才更容易通过。

### 第五步：发布应用

在版本管理与发布里：

1. 创建版本
2. 提交并发布
3. 如果企业内需要审批，就等审批完成

## 4. OpenClaw 这边怎么配

### 4.1 先确认当前结构

你现在的推荐结构是：

- `main`：默认总入口
- `weekly-assistant`：daily / weekly
- `industry-research-assistant`：专题研究
- `archive-search`：全局历史搜索

### 4.2 在 `openclaw.json` 里新增第二个飞书账号

思路是：

- 飞书渠道仍然是同一个 `feishu`
- 但 `accounts` 里新增一个新账号，比如 `archive`
- 再通过 `bindings` 把 `archive` 路由给 `archive-search`

示例：

```json5
{
  channels: {
    feishu: {
      enabled: true,
      dmPolicy: "pairing",
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

## 5. 配完后怎么启动和验证

### 第一步：重启 Gateway

```bash
openclaw gateway restart
```

### 第二步：看渠道状态

```bash
openclaw gateway status
openclaw channels status --probe
openclaw logs --follow
```

重点关注：

- 新账号有没有显示为 `running`
- 有没有明显的鉴权失败
- 有没有事件订阅失败

如果你在执行 `openclaw status` 或 `openclaw channels status --probe` 时，开头总看到：

```text
[plugins] feishu_doc: Registered feishu_doc, feishu_app_scopes
[plugins] feishu_chat: Registered feishu_chat tool
[plugins] feishu_wiki: Registered feishu_wiki tool
[plugins] feishu_drive: Registered feishu_drive tool
[plugins] feishu_bitable: Registered bitable tools
```

这不是报错，而是当前 OpenClaw 进程在启动时把 Feishu 相关工具注册了一遍。

你可以把它理解成：

- 插件已经加载
- 工具已经挂上
- 还没出问题

真正要担心的是：

- `not configured`
- `auth failed`
- `stopped`
- `permission denied`

### 第三步：第一次私聊时走 pairing

这是一个全新的飞书机器人账号，所以你第一次私聊它时，通常还要走一次 pairing。

先看待审批列表：

```bash
openclaw pairing list feishu
```

再批准：

```bash
openclaw pairing approve feishu <CODE>
```

### 第四步：做两轮最小验证

第一轮，先只验证它活着：

```text
ping
```

第二轮，验证它是不是已经真路由到 `archive-search`：

```text
请告诉我：shared knowledge 里和“当前工作主战场”相关的结论有哪些。请给出处。
```

如果你看到它开始回引：

- `knowledge/`
- `archive/`
- 其他 agent 历史

那说明这只机器人已经不是在走 `main`，而是在走 `archive-search`。

## 6. 和 `main` 的关系怎么记最简单

最简单的规则就是：

- 平时默认找 `main`
- 要搜旧记录、旧判断、退役 agent、共享知识时，再找 `archive-search`

也就是说：

- `main` 是默认总入口
- `archive-search` 是低频全局检索入口

## 7. 最后一个排错提醒

如果你在飞书后台已经全配了，但机器人还是没响应，优先按这个顺序查：

1. 应用是否已经发布
2. OpenClaw 里这个 account 的 `appId / appSecret` 是否正确
3. `openclaw channels status --probe` 是否显示新账号正常
4. 是不是还没 pairing
5. 事件订阅是不是选成了 Webhook，而不是长连接

这一组里，第 4 和第 5 最容易被忽略。
