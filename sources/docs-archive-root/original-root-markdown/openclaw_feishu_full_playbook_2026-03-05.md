# OpenClaw -> Feishu 落地手册（完整版）

- 生成日期：2026-03-05
- 适用前提：你只有 Feishu 通道
- Showcase 全量案例来源：https://openclaws.io/showcase
- 全量案例清单（84 条）见：D:\code\cod\openclaw_showcase_report_2026-03-05.md

## 1. 全量场景迁移结论

- 社区场景总数：84
- 分类数：12
- 迁移到 Feishu 结论：
  - 可直接迁移：Setup / Productivity / Personal / Family / General / 大部分 Automation / 大部分 Developer
  - 有条件迁移：Integration / Smart Home / Hardware / Creative / Power User

### 1.1 分类与可用性

| 分类 | 数量 | Feishu 可用性 | 说明 |
|---|---:|---|---|
| Automation | 14 | 可用 | 飞书作为交互入口 + cron 定时任务 |
| Creative | 2 | 有条件可用 | 需要外部媒体模型或 API |
| Developer | 33 | 可用 | 飞书下发任务，OpenClaw 在本机/服务器执行 |
| Family | 3 | 可用 | 用飞书群作为家庭协作入口 |
| General | 1 | 可用 | 探索型场景 |
| Hardware | 2 | 有条件可用 | 需要外设，不依赖 Telegram/WhatsApp |
| Integration | 10 | 有条件可用 | 取决于第三方 API/账号，不受通道限制 |
| Personal | 3 | 可用 | 飞书 DM 作为个人主入口 |
| Power User | 1 | 有条件可用 | 需要预算、监控、多 Agent 管理 |
| Productivity | 9 | 可用 | 飞书最适合日程/待办/摘要 |
| Setup | 1 | 可用 | 强烈建议先完成 |
| Smart Home | 5 | 有条件可用 | 需要家庭设备/API 接入 |

## 2. 落地前检查清单（必做）

- [ ] 机器上 OpenClaw 可运行：`openclaw --version`
- [ ] 网关可运行：`openclaw gateway status`
- [ ] 本地时区明确（建议 `Asia/Shanghai`）
- [ ] 为机器人准备独立账号（建议独立 Feishu app + 独立业务账号体系）
- [ ] 预留一个测试群和一个生产群

## 3. Feishu 通道配置（官方推荐路径）

### 3.1 安装插件

```bash
openclaw plugins install @openclaw/feishu
```

### 3.2 在 Feishu Open Platform 建应用

1. 打开 https://open.feishu.cn/app （国际租户用 https://open.larksuite.com/app）。
2. 创建企业应用。
3. 复制 `App ID(cli_xxx)` 和 `App Secret`。
4. 在权限页批量导入官方文档给的 scopes。
5. 启用 Bot capability。
6. 事件订阅选择 long connection(WebSocket) 并添加 `im.message.receive_v1`。
7. 发布应用。

### 3.3 OpenClaw 侧接入

```bash
openclaw channels add
openclaw gateway restart
openclaw gateway status
openclaw logs --follow
```

### 3.4 首次配对

在飞书给 bot 发消息后：

```bash
openclaw pairing list feishu
openclaw pairing approve feishu <CODE>
```

## 4. 建议配置模板（openclaw.json）

文件：`~/.openclaw/openclaw.json`

```json5
{
  channels: {
    feishu: {
      enabled: true,
      connectionMode: "websocket",
      dmPolicy: "pairing",
      groupPolicy: "allowlist",
      groupAllowFrom: ["oc_DEV_GROUP", "oc_HOME_GROUP"],
      typingIndicator: false,
      resolveSenderNames: true,
      accounts: {
        main: {
          appId: "cli_xxx",
          appSecret: "xxx",
          botName: "Ops Bot"
        }
      },
      groups: {
        oc_DEV_GROUP: {
          requireMention: true,
          allowFrom: ["ou_admin_1", "ou_admin_2"]
        },
        oc_HOME_GROUP: {
          requireMention: true
        }
      }
    }
  }
}
```

说明：

- 生产环境建议 `groupPolicy: "allowlist"`，避免机器人进入未知群。
- 群内建议默认 `requireMention: true`，防止刷屏。
- 如 API 配额紧张，可保持 `typingIndicator: false`。

## 5. 只用飞书时的路由与定时策略

### 5.1 路由策略

- 你的唯一通道是 Feishu，因此建议把关键流程都固定在 Feishu DM 或指定飞书群。
- 多 Agent 时用 `bindings` 按 `peer.id`（`ou_xxx` / `oc_xxx`）路由。

示例：

```json5
{
  agents: {
    list: [
      { id: "main", default: true },
      { id: "dev", workspace: "D:/work/dev" },
      { id: "ops", workspace: "D:/work/ops" }
    ]
  },
  bindings: [
    {
      agentId: "dev",
      match: { channel: "feishu", peer: { kind: "group", id: "oc_DEV_GROUP" } }
    },
    {
      agentId: "ops",
      match: { channel: "feishu", peer: { kind: "direct", id: "ou_admin_1" } }
    }
  ]
}
```

### 5.2 cron 策略

根据官方 `cron-jobs` 文档，`delivery.channel` 枚举未明确列出 `feishu`。实践上建议：

1. 先在飞书会话发一条消息，确保 last route 是飞书。
2. cron 使用 `--announce`（不强制指定 channel），让结果回到当前会话路由。

示例：

```bash
openclaw cron add \
  --name "Morning brief" \
  --cron "0 9 * * *" \
  --tz "Asia/Shanghai" \
  --session isolated \
  --message "总结邮件、日历和待办，输出3个优先事项" \
  --announce
```

## 6. 10 个可快速复刻的飞书场景（可直接落地）

### 6.1 晨间邮件+日历简报（高优先）

- 目标：每天 09:00 推送今日关键事项。
- 依赖：Gmail/Calendar 授权。

```bash
openclaw cron add \
  --name "Feishu Morning Brief" \
  --cron "0 9 * * *" \
  --tz "Asia/Shanghai" \
  --session isolated \
  --message "读取我的邮件和日历，输出：1) 今日3个优先事项 2) 风险提醒 3) 建议时间块" \
  --announce
```

### 6.2 邮件未读摘要 + 自动待办

```bash
openclaw cron add \
  --name "Unread Mail To Todos" \
  --cron "30 9 * * *" \
  --tz "Asia/Shanghai" \
  --session isolated \
  --message "汇总未读邮件，提取可执行事项，写入待办并回报飞书" \
  --announce
```

### 6.3 HN 趋势推送

```bash
openclaw cron add \
  --name "HN Digest" \
  --cron "0 10 * * *" \
  --tz "Asia/Shanghai" \
  --session isolated \
  --message "抓取 Hacker News 热门，按 AI/工程效率筛选 5 条并给出一句点评" \
  --announce
```

### 6.4 Reddit 抓取日报

```bash
openclaw cron add \
  --name "Reddit Digest" \
  --cron "0 11 * * *" \
  --tz "Asia/Shanghai" \
  --session isolated \
  --message "抓取我关注的 subreddit 新帖，输出 5 条摘要和链接" \
  --announce
```

### 6.5 YouTube 信息摄取防沉迷

```bash
openclaw cron add \
  --name "YouTube Summary" \
  --cron "0 20 * * *" \
  --tz "Asia/Shanghai" \
  --session isolated \
  --message "汇总今日订阅视频，按主题给关键点，控制在 300 字" \
  --announce
```

### 6.6 电子收据自动结构化

```bash
openclaw cron add \
  --name "Receipt Structuring" \
  --cron "*/30 * * * *" \
  --tz "Asia/Shanghai" \
  --session isolated \
  --message "处理新收据邮件，提取商户、金额、日期、品类，输出表格并回报飞书" \
  --announce
```

### 6.7 聊天式日历管理

- 在飞书直接发送：
  - "帮我把周五 14:00-15:00 设成面试准备"
  - "今天还有哪些会议会撞车？"

### 6.8 家庭周菜单/周报（飞书群）

```bash
openclaw cron add \
  --name "Family Weekly Plan" \
  --cron "0 9 * * 0" \
  --tz "Asia/Shanghai" \
  --session isolated \
  --message "根据本周日历和历史偏好，输出家庭菜单和采购建议" \
  --announce
```

### 6.9 飞书内技能安装与调用

- 在飞书里让 Bot 执行：安装 skill -> 调用 skill -> 回传结果。
- 典型场景：GA4 查询、邮件聚合、Notion 同步。

### 6.10 开发任务飞书派单

- 在飞书里提需求：
  - "在 D:\\proj\\app 里把登录页文案国际化，做成 PR 说明"。
- 适用：Developer 类场景 33 条的主流模式。

## 7. 分阶段上线清单（7 天）

### Day 1（基础可用）

- [ ] Feishu App 创建 + 发布
- [ ] `openclaw plugins install @openclaw/feishu`
- [ ] 配对成功，DM 能正常回复

### Day 2（安全收口）

- [ ] `groupPolicy=allowlist`
- [ ] 关键群 `requireMention=true`
- [ ] sender allowFrom 加到管理账号

### Day 3（第一条自动化）

- [ ] 上线“晨报” cron
- [ ] 跑通一次手动 `openclaw cron run <jobId>`

### Day 4（信息摄取）

- [ ] HN / Reddit / YouTube 三选一上线

### Day 5（事务自动化）

- [ ] 邮件摘要 -> 待办
- [ ] 收据结构化

### Day 6（协作）

- [ ] 家庭或团队群场景上线
- [ ] 确认 @mention gating 正常

### Day 7（复盘）

- [ ] 清理无效 cron
- [ ] 调整 prompt 与频率
- [ ] 汇总 ROI（节省时间、减少手工步骤）

## 8. 验收标准（你可以直接对照）

- [ ] 飞书 DM 发消息 5 秒内有响应
- [ ] 群内不 @bot 不触发；@bot 能触发
- [ ] 至少 3 条 cron 稳定运行 3 天
- [ ] 一条信息摄取任务 + 一条事务任务 + 一条协作任务稳定
- [ ] `openclaw logs --follow` 无持续错误刷屏

## 9. 排障命令速查

```bash
openclaw gateway status
openclaw gateway restart
openclaw logs --follow
openclaw pairing list feishu
openclaw cron list
openclaw cron runs --id <jobId>
openclaw doctor
```

## 10. 常见失败点

1. 机器人不回：App 未发布/权限没全开/事件订阅没配 `im.message.receive_v1`。
2. 群不回：没 @bot 或 `groupPolicy` 限制。
3. cron 无回传：last route 不是飞书，先在目标飞书会话发一条消息再触发。
4. API 报错：App Secret 失效或配额不足。

## 11. 你下一步最小动作（今天就能做）

1. 先跑通飞书 DM（安装插件 -> channels add -> pairing）。
2. 只上线 1 条 cron：Morning Brief。
3. 跑 24 小时后再加第二条（收据结构化或未读邮件摘要）。
