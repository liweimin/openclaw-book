# OpenClaw 工具与 Skills 完整使用清单（全中文）

- 生成时间：2026-03-05 21:19:03
- 源码目录：`D:/code/cod/openclaw`
- 总计：工具 26 个（含运行时 `pdf`），Skills 52 个

## 1. 小白先做这 5 步

1. 健康检查：`openclaw doctor`、`openclaw status --all`、`openclaw gateway status`。
2. 看你机器上真正可用的技能：`openclaw skills list --eligible`。
3. 工具权限先用 `messaging` 或 `coding`，不要一开始就 `full`。
4. Skills 按需启用，不要全开。建议先启用：`summarize`、`weather`、`github`、`coding-agent`、`session-logs`。
5. 涉及命令执行（`exec/process`）和设备采集（`nodes`）时，先确认权限边界。

## 2. 常用命令

```bash
openclaw doctor
openclaw status --all
openclaw gateway status
openclaw skills list --eligible
openclaw skills info <name>
openclaw skills check
openclaw config get tools.profile
openclaw config set tools.profile messaging
```

## 3. 先把这几个词看懂（你问的重点）

你在表格里看到的 `full`、`tools.allow`，本质是在说“这个工具默认给不给你用”。

1. `tools.profile` 是“默认权限套餐”
- `minimal`：最小权限（几乎只看状态）
- `messaging`：偏消息协作（发消息、查会话）
- `coding`：偏开发（读写文件、执行命令、子代理等）
- `full`：全开（所有内置工具都可见）

2. `tools.allow` 是“额外放行名单”
- 意思：在当前 profile 基础上，再手动加某些工具。
- 例子：你用 `messaging`，但还想用 `web_search`，就把 `web_search` 写进 `tools.allow`。

3. `tools.deny` 是“强制禁用名单”
- 意思：无论 profile/allow 怎么配，这些工具都不让用（deny 优先级最高）。
- 常见做法：永远禁掉 `exec`，避免误执行命令。

4. 表格里“需 full 或 tools.allow”到底啥意思
- 白话：这个工具在 `minimal/messaging/coding` 里默认都不开。
- 你要么把 `tools.profile` 设成 `full`，
- 要么继续用较保守 profile，然后单独用 `tools.allow` 放行这个工具（更推荐）。

### 三个可直接复制的配置示例

示例 A：保守消息模式（推荐新手）

```json5
{
  tools: {
    profile: "messaging",
    deny: ["exec", "process"]
  }
}
```

示例 B：开发模式，但禁止联网搜索

```json5
{
  tools: {
    profile: "coding",
    deny: ["web_search", "web_fetch"]
  }
}
```

示例 C：消息模式 + 只额外开放网页搜索

```json5
{
  tools: {
    profile: "messaging",
    allow: ["web_search", "web_fetch"]
  }
}
```

## 4. 工具完整清单（中文）

| 工具 | 类别 | 什么时候能用（白话） | 中文说明 |
|---|---|---|---|
| `agents_list` | agents | 默认不开；设 `full` 或放进 `tools.allow` | 列出当前可用于 `sessions_spawn` 的智能体。 |
| `cron` | automation | `coding` 或 `full` 默认可用 | 管理定时任务（增删改查与立即运行）。 |
| `gateway` | automation | 默认不开；设 `full` 或放进 `tools.allow` | 管理/重启 Gateway 网关并应用配置。 |
| `apply_patch` | fs | `coding` 或 `full` 默认可用 | 用结构化补丁批量改文件。 |
| `edit` | fs | `coding` 或 `full` 默认可用 | 对文件做精确编辑。 |
| `read` | fs | `coding` 或 `full` 默认可用 | 读取文件内容。 |
| `write` | fs | `coding` 或 `full` 默认可用 | 写入或覆盖文件。 |
| `image` | media | `coding` 或 `full` 默认可用 | 调用图像模型做图片理解。 |
| `pdf` | media | 运行时可用（不走 profile 列表） | 分析一个或多个 PDF（支持回退模型）。 |
| `tts` | media | 默认不开；设 `full` 或放进 `tools.allow` | 文本转语音。 |
| `memory_get` | memory | `coding` 或 `full` 默认可用 | 读取记忆文件。 |
| `memory_search` | memory | `coding` 或 `full` 默认可用 | 语义检索记忆内容。 |
| `message` | messaging | `messaging`/`coding`/`full` 常见可用 | 发送和管理多渠道消息。 |
| `nodes` | nodes | 默认不开；设 `full` 或放进 `tools.allow` | 管理节点设备、通知、摄像头/屏幕采集。 |
| `exec` | runtime | `coding` 或 `full` 默认可用 | 执行 shell 命令。 |
| `process` | runtime | `coding` 或 `full` 默认可用 | 管理后台命令会话（日志、输入、终止）。 |
| `session_status` | sessions | `minimal`/`messaging`/`coding`/`full` 均可用 | 查看当前或指定会话状态。 |
| `sessions_history` | sessions | `messaging`/`coding`/`full` 可用 | 读取会话历史消息。 |
| `sessions_list` | sessions | `messaging`/`coding`/`full` 可用 | 列出会话列表。 |
| `sessions_send` | sessions | `messaging`/`coding`/`full` 可用 | 向其他会话发送消息。 |
| `sessions_spawn` | sessions | `coding` 或 `full` 默认可用 | 创建子智能体会话执行任务。 |
| `subagents` | sessions | `coding` 或 `full` 默认可用 | 管理子智能体（状态、生命周期等）。 |
| `browser` | ui | 默认不开；设 `full` 或放进 `tools.allow` | 浏览器自动化（打开、快照、交互、截图）。 |
| `canvas` | ui | 默认不开；设 `full` 或放进 `tools.allow` | 控制节点 Canvas 展示与交互。 |
| `web_fetch` | web | 默认不开；设 `full` 或放进 `tools.allow` | 抓取网页并提取正文内容。 |
| `web_search` | web | 默认不开；设 `full` 或放进 `tools.allow` | 执行网页搜索。 |

## 5. Skills 完整清单（中文）

| Skill | 中文用途 |
|---|---|
| `1password` | 安装并使用 1Password CLI（op），用于登录账号、读取/注入密钥与安全变量。 |
| `apple-notes` | 在 macOS 上通过 memo CLI 创建、搜索、编辑、移动和导出 Apple Notes。 |
| `apple-reminders` | 通过 remindctl 管理提醒事项（列表、添加、修改、完成、删除、按日期过滤）。 |
| `bear-notes` | 通过 grizzly CLI 创建、搜索和管理 Bear 笔记。 |
| `blogwatcher` | 用 blogwatcher CLI 监控博客与 RSS/Atom 更新。 |
| `blucli` | 通过 blu CLI 控制 BluOS 设备（发现、播放、分组、音量）。 |
| `bluebubbles` | 经 BlueBubbles 发送或管理 iMessage（走 message 工具的 bluebubbles 渠道）。 |
| `camsnap` | 抓取 RTSP/ONVIF 摄像头截图或短视频片段。 |
| `canvas` | 在节点设备上展示 HTML Canvas 页面，用于看板、演示和可视化。 |
| `clawhub` | 使用 ClawHub CLI 搜索、安装、更新、发布 Skills。 |
| `coding-agent` | 把编码任务委托给 Codex/Claude/Pi/OpenCode 代理，适合中大型开发任务。 |
| `discord` | 通过 message 工具操作 Discord 渠道消息。 |
| `eightctl` | 控制 Eight Sleep（状态、温度、闹钟、计划）。 |
| `gemini` | 用 Gemini CLI 做一次性问答、总结和内容生成。 |
| `gh-issues` | 批量拉取 GitHub Issues，派生子代理修复并发 PR，再跟进评审意见。 |
| `gifgrep` | 搜索 GIF 资源、下载结果并提取静帧或拼图。 |
| `github` | 通过 gh CLI 处理 GitHub 议题、PR、CI、评审和 API 查询。 |
| `gog` | Google Workspace CLI：Gmail、Calendar、Drive、Contacts、Sheets、Docs。 |
| `goplaces` | 通过 Google Places API 查询地点搜索、详情、解析和评论。 |
| `healthcheck` | 做主机安全加固与风险体检（防火墙、SSH、更新策略、暴露面）。 |
| `himalaya` | 使用 himalaya CLI 管理 IMAP/SMTP 邮件（读写、回复、转发、搜索、归档）。 |
| `imsg` | 通过 Messages.app 的 CLI 查看聊天、历史并发送 iMessage/SMS。 |
| `mcporter` | 用 mcporter CLI 管理和调用 MCP 服务器/工具（HTTP 或 stdio）。 |
| `model-usage` | 统计 CodexBar 的模型级使用量与费用（含当前模型与分模型报表）。 |
| `nano-banana-pro` | 用 Gemini 3 Pro Image 生成或编辑图片。 |
| `nano-pdf` | 通过自然语言指令编辑 PDF。 |
| `notion` | 调用 Notion API 管理页面、数据库和块内容。 |
| `obsidian` | 对 Obsidian 知识库做笔记读写与自动化。 |
| `openai-image-gen` | 批量调用 OpenAI Images API 生成图片并产出画廊页。 |
| `openai-whisper` | 本地 Whisper CLI 语音转文字（无需 API Key）。 |
| `openai-whisper-api` | 调用 OpenAI Whisper API 做音频转写。 |
| `openhue` | 通过 OpenHue CLI 控制 Philips Hue 灯光和场景。 |
| `oracle` | 提供 oracle CLI 的最佳实践（提示词、文件绑定、会话与引擎使用）。 |
| `ordercli` | 查询 Foodora 历史订单与当前订单状态。 |
| `peekaboo` | 在 macOS 上采集并自动化桌面 UI（Peekaboo CLI）。 |
| `sag` | 用 ElevenLabs 做文本转语音（接近 macOS say 体验）。 |
| `session-logs` | 用 jq 检索和分析历史会话日志。 |
| `sherpa-onnx-tts` | 本地离线 TTS（sherpa-onnx，无云依赖）。 |
| `skill-creator` | 创建或更新 Agent Skills（结构、脚本、参考资料、资源打包）。 |
| `slack` | 通过 Slack 工具处理消息、表情反应、置顶等操作。 |
| `songsee` | 把音频生成为频谱图和特征可视化面板。 |
| `sonoscli` | 控制 Sonos 设备（发现、播放、音量、分组）。 |
| `spotify-player` | 终端下控制 Spotify 播放与搜索（spogo/spotify_player）。 |
| `summarize` | 对网页、播客、本地文件做摘要或转录文本提取。 |
| `things-mac` | 在 macOS 通过 things CLI 管理 Things 3 任务和项目。 |
| `tmux` | 远程控制 tmux 会话，适合驱动交互式 CLI。 |
| `trello` | 通过 Trello REST API 管理看板、列表、卡片。 |
| `video-frames` | 用 ffmpeg 提取视频帧或短片段。 |
| `voice-call` | 通过 OpenClaw voice-call 插件发起语音通话。 |
| `wacli` | 通过 wacli 发送 WhatsApp 消息或同步/检索 WhatsApp 历史。 |
| `weather` | 查询实时天气与预报（wttr.in / Open-Meteo，无需 API Key）。 |
| `xurl` | 调用 X（Twitter）API 进行发帖、回复、搜索、私信和媒体上传。 |

## 6. 新手推荐组合

1. 办公信息流：`summarize` + `session-logs` + `weather`。
2. 开发流：`coding-agent` + `github` + `gh-issues` + `tmux`。
3. 多媒体流：`openai-whisper`/`openai-whisper-api` + `video-frames` + `songsee` + `nano-pdf`。
4. 协作消息流：`slack` + `discord` + `wacli`（按需启用）。
5. 设备家居流：`openhue` + `sonoscli` + `spotify-player` + `eightctl`。

## 7. 新手避坑

1. 不要把 `tools.profile` 直接设成 `full`。
2. 先跑 `openclaw skills check`，确认二进制和环境变量齐全。
3. 第三方 Skills 先审查再启用。
4. 外部平台 token 一律最小权限。
5. 高风险操作（命令执行、摄像头/屏幕）要有明确授权。

## 8. 你的场景：信息检索专用配置（可直接用）

目标：只做“搜网页 + 抓网页 + 查记忆 + 读文件”，尽量不让它执行命令或改文件。

把下面内容合并到 `~/.openclaw/openclaw.json`（Windows 通常是 `C:\\Users\\你的用户名\\.openclaw\\openclaw.json`）：

```json5
{
  tools: {
    // 最小默认权限
    profile: "minimal",

    // 只额外开放：网页检索、记忆检索、读文件
    allow: ["group:web", "memory_search", "memory_get", "read"],

    // 明确禁掉高风险能力
    deny: [
      "group:runtime",      // exec/process
      "group:automation",   // cron/gateway
      "group:nodes",        // 摄像头/屏幕/设备调用
      "group:ui",           // browser/canvas
      "write",
      "edit",
      "apply_patch",
      "sessions_spawn",
      "subagents",
      "sessions_send"
    ],

    web: {
      search: {
        enabled: true,
        provider: "brave",
        apiKey: "换成你的 BRAVE_API_KEY",
        maxResults: 5,
        timeoutSeconds: 30
      },
      fetch: {
        enabled: true,
        maxChars: 50000,
        timeoutSeconds: 30
      }
    }
  }
}
```

配置完后执行：

```bash
openclaw doctor
openclaw status --all
openclaw skills check
```

如果你暂时没有 `BRAVE_API_KEY`：

- `web_fetch` 仍可用（抓网页正文）
- `web_search` 会提示你先配置搜索密钥
