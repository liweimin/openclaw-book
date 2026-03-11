# 第十三章：Agent 管理与多 Agent 实战

## 1. 为什么需要多个 Agent

当你开始真正长期使用 OpenClaw 后，很快就会遇到这个问题：

不同任务之间的上下文、规则和偏好，开始互相干扰。

比如：

- 你用一个 Agent 做周计划和每日待办
- 同时又想让它帮你做行业研究
- 还可能偶尔拿它来调代码

如果这些任务全挤在一个 Agent 里，很快就会出现：

- `AGENTS.md` 越写越长，因为要兼顾所有场景
- Memory 里混着不同类型的偏好
- Skill 彼此冲突或触发条件重叠
- 飞书里同一个机器人既收个人提醒又收研究指令，对话混在一起

更好的做法是：让不同任务域使用各自独立的 Agent。

### 1.1 本章实操场景

这一章你应该完成的真实场景是：

在现有的 main Agent 之外，再创建一个独立 Agent，给它配好独立的工作区和独立的飞书机器人入口，并验证两个 Agent 之间的消息不会互相串。

### 1.2 本章产物

读完这一章，你手里至少应该有：

- 一个新的独立 Agent（例如 `industry-search-eval`）
- 一个独立的飞书机器人与之绑定
- 一份能证明"两条路由不串"的验证结果

### 1.3 开始前先准备什么

- 你已经完成第 4 章，飞书私聊可用
- 你已经至少有一个正在使用的 Agent（通常是 `main` 或 `weekly-assistant`）

## 2. Agent 的核心概念

在开始创建之前，先把几个关键概念记住。

### Agent ID

每个 Agent 都有唯一标识。例如 `main`、`weekly-assistant`、`industry-search-eval`。

### Workspace

每个 Agent 可以有自己独立的工作区目录。这意味着它的 `AGENTS.md`、`MEMORY.md`、Skills、Memory 文件都可以独立维护。

### 默认 Agent

`openclaw.json` 里可以用 `default: true` 把某个 Agent 指定为默认。没有明确路由规则的消息通常会落到默认 Agent 上。

### tools profile

每个 Agent 可以独立配置工具权限：

- `messaging`：偏消息交互，工具集更保守
- `coding`：偏开发任务，工具集更开放
- 也可以用 `alsoAllow` 和 `deny` 精选

## 3. 创建第一个额外 Agent

### 第一步：用命令创建

```bash
openclaw agents add industry-search-eval --workspace ~/.openclaw/workspace-industry-search-eval
```

这条命令会：

1. 在 Agent 列表里注册一个新 Agent
2. 创建它的独立工作区目录
3. 但不会自动给它绑定任何渠道入口

### 第二步：确认已经注册

```bash
openclaw agents list
```

你应该能看到至少两个 Agent。

### 第三步：查看详情

```bash
openclaw agents info industry-search-eval
```

确认它的 workspace 路径和工具配置是否符合预期。

## 4. Agent 与飞书的路由绑定

创建了 Agent 只是第一步。更关键的问题是：飞书消息怎么知道该发给谁？

答案是：**通过 bindings 配置做路由**。

### bindings 的基本结构

```json5
{
  bindings: [
    {
      agentId: "weekly-assistant",
      match: { channel: "feishu", accountId: "main" }
    },
    {
      agentId: "industry-search-eval",
      match: { channel: "feishu", accountId: "eval" }
    }
  ]
}
```

这里最关键的是 `accountId`。不同的 `accountId` 对应不同的飞书机器人。

### 路由逻辑很直接

1. 飞书机器人 A（`accountId: "main"`）收到消息 → 转给 `weekly-assistant`
2. 飞书机器人 B（`accountId: "eval"`）收到消息 → 转给 `industry-search-eval`
3. 如果没有匹配到任何 binding → 转给默认 Agent

## 5. 实操：搭建独立的行业研究实验 Agent

这一节给完整的操作步骤。如果你刚才已经创建了 Agent，可以直接从第二步开始。

### 第一步：创建实验 Agent

```bash
openclaw agents add industry-search-eval --workspace ~/.openclaw/workspace-industry-search-eval
```

### 第二步：在飞书开放平台创建第二个机器人

不要复用现有机器人，直接新建一只。

1. 在飞书开放平台创建新的企业自建应用
2. 记录新的 `App ID` 和 `App Secret`
3. 开启机器人能力
4. 启用长连接事件订阅，添加 `im.message.receive_v1`
5. 创建版本并发布应用

建议命名成容易辨认的名字，例如 `OpenClaw-Search-Eval` 或 `行业搜索测评助手`。

### 第三步：更新 `openclaw.json`

最稳的做法是直接编辑配置文件。参考配置如下：

```json5
{
  agents: {
    list: [
      { id: "main", default: true },
      {
        id: "weekly-assistant",
        workspace: "~/.openclaw/workspace-weekly-assistant"
      },
      {
        id: "industry-search-eval",
        workspace: "~/.openclaw/workspace-industry-search-eval"
      }
    ]
  },

  bindings: [
    {
      agentId: "weekly-assistant",
      match: { channel: "feishu", accountId: "main" }
    },
    {
      agentId: "industry-search-eval",
      match: { channel: "feishu", accountId: "eval" }
    }
  ],

  channels: {
    feishu: {
      defaultAccount: "main",
      dmPolicy: "pairing",
      accounts: {
        main: {
          appId: "cli_xxx_main",
          appSecret: "xxx_main",
          botName: "weekly-assistant"
        },
        eval: {
          appId: "cli_xxx_eval",
          appSecret: "xxx_eval",
          botName: "industry-search-eval"
        }
      }
    }
  }
}
```

这份配置有 3 个关键点：

1. `channels.feishu.accounts.eval` 是第二只机器人
2. `bindings` 里用 `accountId: "eval"` 把它固定路由到 `industry-search-eval`
3. `defaultAccount` 保留 `main`，原来的 Agent 不受影响

### 第四步：给实验 Agent 精选工具

```json5
{
  agents: {
    list: [
      {
        id: "industry-search-eval",
        tools: {
          profile: "messaging",
          alsoAllow: ["web_search", "web_fetch", "browser"]
        }
      }
    ]
  }
}
```

这里用 `messaging` 做基础，再额外允许搜索和读取能力，是最稳的起步方式。

### 第五步：重启 Gateway

```bash
openclaw gateway restart
openclaw gateway status
openclaw channels status --probe
```

确认：

1. Gateway 正常
2. 两个飞书 account 都加载成功
3. 没有凭证或连接错误

### 第六步：验证路由不串

先测原来的机器人：

1. 在飞书里私聊原机器人，发 `ping`
2. 终端检查：

```bash
openclaw sessions --agent weekly-assistant
openclaw sessions --agent industry-search-eval
```

验收标准：

- `weekly-assistant` 出现新 session
- `industry-search-eval` **不因为这条消息**新增 session

再测新机器人：

1. 在飞书里私聊新的测评机器人，发 `ping`
2. 如果触发 pairing，执行：

```bash
openclaw pairing list feishu
openclaw pairing approve feishu <CODE>
```

3. 再次发送 `ping`
4. 终端检查：

```bash
openclaw sessions --agent industry-search-eval
openclaw sessions --agent weekly-assistant
```

验收标准：

- `industry-search-eval` 出现新 session
- `weekly-assistant` **不因为这条消息**新增 session

只要这一步通过，两个 Agent 就可以放心独立使用了。

## 6. Agent 级别的配置覆盖

OpenClaw 支持在 Agent 级别覆盖很多全局默认值。

### 模型覆盖

```json5
{
  agents: {
    list: [
      {
        id: "industry-search-eval",
        model: {
          primary: "anthropic/claude-sonnet-4-5"
        }
      }
    ]
  }
}
```

这样测评 Agent 可以使用不同的模型，而不影响其他 Agent。

### 独立 memorySearch 配置

```json5
{
  agents: {
    list: [
      {
        id: "industry-search-eval",
        memorySearch: {
          provider: "openai",
          model: "text-embedding-3-small",
          remote: {
            apiKey: "YOUR_KEY"
          }
        }
      }
    ]
  }
}
```

### 工具精选

用 `alsoAllow` 和 `deny` 精确控制每个 Agent 能调用什么工具。

这种分层设计的价值很直接：你可以让不同 Agent 有不同的成本、能力和安全边界。

## 7. 多 Agent 的日常管理

### 查看所有 Agent

```bash
openclaw agents list
```

### 查看特定 Agent 的详情

```bash
openclaw agents info industry-search-eval
```

### 查看特定 Agent 的会话

```bash
openclaw sessions --agent industry-search-eval
```

### 调试实时日志

```bash
openclaw logs --follow
```

你可以通过日志中的 `subsystem` 或 `module` 字段来区分不同 Agent 的活动。例如，飞书渠道的日志通常包含 `gateway/channels/feishu`。

> [!NOTE]
> 当前版本的 CLI `logs` 命令主要支持按 `--channel` 过滤，暂不支持直接按 `--agent` 过滤。查看特定 Agent 活动的最快方式是检查其 `sessions`。

## 8. 常见问题

### 消息路由到了错误的 Agent

最常见的原因：

1. `bindings` 里的 `accountId` 写错了
2. 没有重启 Gateway，新配置还没生效
3. `defaultAccount` 的设置让消息落到了默认 Agent

排查顺序：

1. 先检查 `openclaw.json` 里的 bindings
2. 再执行 `openclaw gateway restart`
3. 再用 `openclaw sessions --agent <agentId>` 确认消息落在哪

### Workspace 路径冲突

如果两个 Agent 共享同一个 workspace，它们的 `AGENTS.md`、Skills、Memory 会互相影响。

**最佳实践：每个 Agent 用独立的 workspace 路径。**

### 多 Agent 时 Gateway 重启

修改了 Agent 列表、bindings 或 accounts 后，必须重启 Gateway。

```bash
openclaw gateway restart
```

不重启的话，旧的路由规则仍然生效。

## 9. 本章小结

多 Agent 不是"高级玩法"，而是一个很实际的组织方式。

当你有多类任务时：

- 把不同任务分到不同 Agent
- 给每个 Agent 独立的 workspace
- 通过 bindings 把消息路由到对应 Agent
- 独立管理各自的 model、tools、skills、memory

这样做的好处不只是"不串"，更重要的是：每个 Agent 都可以独立演进，你调 A 的时候不担心影响 B。

### 9.1 本章验收标准

1. 你已经创建了至少一个额外 Agent
2. 这个 Agent 有独立的 workspace
3. 你已经给它绑定了独立的飞书机器人入口
4. 你已经验证过两个 Agent 的消息不会互串
5. 你知道怎么用 `--agent` 参数过滤日志和会话

## 10. 下一章

- [14-OpenClaw-工具与Skill创建实战.md](14-OpenClaw-工具与Skill创建实战.md)

> [!NOTE]
> 本章内容基于 OpenClaw 当前版本验证（截至 2026 年 3 月）。
> 如果你使用更新版本，关键命令和配置项请以官方源码为准。
