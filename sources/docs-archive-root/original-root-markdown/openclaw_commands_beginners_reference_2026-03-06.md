# OpenClaw 命令完整查阅手册（小白版）

更新时间：2026-03-06  
适用仓库源码：`openclaw_src`（本地源码扫描整理）

---

## 1. 先看这三句话

1. 聊天里输入 `/...` 是“聊天命令”（Web、飞书等文本通道可用）。
2. 终端里输入 `openclaw ...` 是“CLI 命令”（命令行可用）。
3. 聊天命令不是都耗模型 tokens：很多是本地控制命令，不会走模型。

---

## 2. 命令在哪里可以用

### 2.1 聊天命令（`/xxx`）

- `WebChat`：可用（文本命令）
- `飞书 Feishu`：可用（文本命令）
- `WhatsApp/Signal/iMessage/Google Chat`：可用（文本命令）
- `Discord/Telegram/Slack`：文本命令可用，且支持原生命令（native slash）

说明：
- 飞书和 Web 主要用“文本命令”路径。
- `!` 命令（例如 `!poll`）本质是 `/bash` 的聊天别名。

### 2.2 CLI 命令（`openclaw ...`）

- 仅终端可用（PowerShell、CMD、Bash、zsh 等）。

---

## 3. 聊天命令总表（Web/飞书重点）

### 3.1 基础信息与帮助

| 命令 | 用途 | 可用位置 | tokens |
|---|---|---|---|
| `/help` | 查看帮助 | Web/飞书/其他文本通道 | 不消耗 |
| `/commands` | 查看命令列表 | Web/飞书/其他文本通道 | 不消耗 |
| `/status` | 查看当前会话状态 | Web/飞书/其他文本通道 | 不消耗 |
| `/whoami` | 查看当前发送者身份 | Web/飞书/其他文本通道 | 不消耗 |
| `/id` | `/whoami` 别名 | Web/飞书/其他文本通道 | 不消耗 |
| `/context [list\|detail\|json]` | 查看上下文组成 | Web/飞书/其他文本通道 | 不消耗 |
| `/export-session [path]` | 导出会话为 HTML | Web/飞书/其他文本通道 | 不消耗 |
| `/export [path]` | `/export-session` 别名 | Web/飞书/其他文本通道 | 不消耗 |

### 3.2 会话与上下文管理

| 命令 | 用途 | 可用位置 | tokens |
|---|---|---|---|
| `/new [model]` | 开新会话（可带模型提示） | Web/飞书/其他文本通道 | 通常消耗 |
| `/reset` | 重置当前会话 | Web/飞书/其他文本通道 | 通常消耗 |
| `/compact [instructions]` | 手动压缩上下文 | Web/飞书/其他文本通道 | 通常消耗 |
| `/stop` | 停止当前运行 | Web/飞书/其他文本通道 | 不消耗 |
| `/session idle <duration\|off>` | 线程绑定空闲超时 | 主要 Discord 线程场景 | 不消耗 |
| `/session max-age <duration\|off>` | 线程绑定最大寿命 | 主要 Discord 线程场景 | 不消耗 |

### 3.3 模型、思考、输出策略

| 命令 | 用途 | 可用位置 | tokens |
|---|---|---|---|
| `/model <name>` | 设置/查看模型 | Web/飞书/其他文本通道 | 视情况 |
| `/models ...` | 查看模型/提供商列表 | Web/飞书/其他文本通道 | 不消耗 |
| `/think <level>` | 思考级别 | Web/飞书/其他文本通道 | 视情况 |
| `/thinking <level>` | `/think` 别名 | Web/飞书/其他文本通道 | 视情况 |
| `/t <level>` | `/think` 别名 | Web/飞书/其他文本通道 | 视情况 |
| `/verbose on\|full\|off` | 详细输出级别 | Web/飞书/其他文本通道 | 视情况 |
| `/v ...` | `/verbose` 别名 | Web/飞书/其他文本通道 | 视情况 |
| `/reasoning on\|off\|stream` | 推理可见性 | Web/飞书/其他文本通道 | 视情况 |
| `/reason ...` | `/reasoning` 别名 | Web/飞书/其他文本通道 | 视情况 |
| `/usage off\|tokens\|full\|cost` | usage 显示与成本摘要 | Web/飞书/其他文本通道 | 不消耗 |
| `/queue ...` | 排队模式与队列参数 | Web/飞书/其他文本通道 | 视情况 |

### 3.4 权限、执行、配置

| 命令 | 用途 | 可用位置 | tokens |
|---|---|---|---|
| `/approve <id> allow-once\|allow-always\|deny` | 审批执行请求 | Web/飞书/其他文本通道 | 不消耗 |
| `/allowlist ...` | 管理白名单 | Web/飞书/其他文本通道 | 不消耗 |
| `/config show\|get\|set\|unset` | 改写磁盘配置 | Web/飞书/其他文本通道 | 不消耗 |
| `/debug show\|set\|unset\|reset` | 改运行时覆盖（不落盘） | Web/飞书/其他文本通道 | 不消耗 |
| `/elevated on\|off\|ask\|full` | 提权执行策略 | Web/飞书/其他文本通道 | 视情况 |
| `/elev ...` | `/elevated` 别名 | Web/飞书/其他文本通道 | 视情况 |
| `/exec host=... security=... ask=... node=...` | exec 默认参数 | Web/飞书/其他文本通道 | 视情况 |
| `/restart` | 重启 OpenClaw | Web/飞书/其他文本通道 | 不消耗 |

### 3.5 技能、子智能体、ACP

| 命令 | 用途 | 可用位置 | tokens |
|---|---|---|---|
| `/skill <name> [input]` | 按名字运行技能 | Web/飞书/其他文本通道 | 视情况 |
| `/<技能命令>` | 直接调用技能命令 | Web/飞书/其他文本通道 | 视情况 |
| `/subagents list\|kill\|log\|info\|send\|steer\|spawn` | 子智能体管理 | Web/飞书/其他文本通道 | 视情况 |
| `/acp spawn\|cancel\|...` | ACP 会话与运行时控制 | Web/飞书/其他文本通道 | 视情况 |
| `/agents` | 查看线程绑定 agent | Web/飞书/其他文本通道 | 不消耗 |
| `/focus <target>` | 绑定线程目标 | 主要 Discord | 不消耗 |
| `/unfocus` | 解除线程绑定 | 主要 Discord | 不消耗 |
| `/kill <id\|#\|all>` | 终止子智能体任务 | Web/飞书/其他文本通道 | 不消耗 |
| `/steer <id\|#> <msg>` | 给运行中子智能体发新指令 | Web/飞书/其他文本通道 | 通常消耗 |
| `/tell <id\|#> <msg>` | `/steer` 别名 | Web/飞书/其他文本通道 | 通常消耗 |

### 3.6 渠道与发送策略

| 命令 | 用途 | 可用位置 | tokens |
|---|---|---|---|
| `/activation mention\|always` | 群激活方式 | 群聊会话 | 不消耗 |
| `/send on\|off\|inherit` | 发送策略 | Web/飞书/其他文本通道 | 不消耗 |
| `/dock-telegram` | 回复路由到 Telegram | 支持 dock 的会话 | 不消耗 |
| `/dock_telegram` | `/dock-telegram` 别名 | 支持 dock 的会话 | 不消耗 |
| `/dock-discord` | 回复路由到 Discord | 支持 dock 的会话 | 不消耗 |
| `/dock_discord` | `/dock-discord` 别名 | 支持 dock 的会话 | 不消耗 |
| `/dock-slack` | 回复路由到 Slack | 支持 dock 的会话 | 不消耗 |
| `/dock_slack` | `/dock-slack` 别名 | 支持 dock 的会话 | 不消耗 |

### 3.7 Bash 聊天命令（高风险，谨慎）

| 命令 | 用途 | 可用位置 | tokens |
|---|---|---|---|
| `/bash <command>` | 执行主机 shell 命令 | Web/飞书/其他文本通道 | 不消耗 |
| `! <command>` | `/bash` 简写 | Web/飞书/其他文本通道 | 不消耗 |
| `!poll` / `/bash poll` | 查询后台 bash 作业状态 | Web/飞书/其他文本通道 | 不消耗 |
| `!stop` / `/bash stop` | 停止后台 bash 作业 | Web/飞书/其他文本通道 | 不消耗 |

### 3.8 TTS 命令

| 命令 | 用途 | 可用位置 | tokens |
|---|---|---|---|
| `/tts on\|off\|status` | TTS 开关和状态 | Web/飞书/其他文本通道 | 不消耗 |
| `/tts provider <name>` | 选择 TTS 提供商 | Web/飞书/其他文本通道 | 不消耗 |
| `/tts limit <n>` | 设置长度上限 | Web/飞书/其他文本通道 | 不消耗 |
| `/tts summary on\|off` | 长文本摘要策略 | Web/飞书/其他文本通道 | 不消耗 |
| `/tts audio <text>` | 文本转语音 | Web/飞书/其他文本通道 | 不消耗（但可能有 TTS 费用） |

---

## 4. 聊天命令 token 消耗规则（重点）

### 4.1 不消耗模型 tokens

典型是“本地控制/状态查询/配置命令”，例如：
- `/help` `/commands` `/status` `/whoami`
- `/usage` `/allowlist` `/approve`
- `/config` `/debug` `/send` `/activation`
- `/stop` `/restart`
- `/bash` `!poll` `!stop`（执行的是系统命令，不是语言模型推理）

### 4.2 视情况（取决于是否继续跑模型）

- `/model` `/think` `/verbose` `/reasoning` `/elevated` `/exec` `/queue`
- `/skill`
- 规则：如果只是“指令单发并返回确认”通常不走模型；如果同一条消息还有正文要继续对话，则会进入模型。

### 4.3 通常会消耗 tokens

- `/new` `/reset`（会触发新会话欢迎轮）
- `/compact`（触发压缩）
- `/steer`、部分 `/subagents`、部分 `/acp`、部分 `/skill`（会发起 agent run）

---

## 5. 终端 CLI 命令（完整树）

> 这些命令在终端执行，不在聊天窗口执行。

```text
openclaw setup
openclaw onboard
openclaw configure
openclaw config get|set|unset|file|validate
openclaw doctor
openclaw dashboard
openclaw reset
openclaw uninstall

openclaw agent
openclaw agents list|bindings|bind|unbind|add|set-identity|delete

openclaw status
openclaw health
openclaw sessions
openclaw sessions cleanup

openclaw message send|broadcast|poll|react|reactions|read|edit|delete|pin|unpin|pins|permissions|search
openclaw message thread create|list|reply
openclaw message emoji list|upload
openclaw message sticker send|upload
openclaw message role info|add|remove
openclaw message channel info|list
openclaw message member info
openclaw message voice status
openclaw message event list|create|timeout|kick|ban

openclaw memory status|index|search

openclaw browser status|start|stop|reset-profile|tabs|open|focus|close|profiles|create-profile|delete-profile
openclaw browser tab|tab new|tab select|tab close
openclaw browser screenshot|snapshot
openclaw browser navigate|resize|click|type|press|hover|scrollintoview|drag|select|fill|wait|evaluate
openclaw browser upload|waitfordownload|download|dialog
openclaw browser console|pdf|responsebody
openclaw browser highlight|errors|requests|trace start|trace stop
openclaw browser set viewport|offline|headers|credentials|geo|media|timezone|locale|device
openclaw browser cookies|cookies set|cookies clear
openclaw browser storage local get|set|clear
openclaw browser storage session get|set|clear
openclaw browser extension install|path

openclaw acp
openclaw acp client

openclaw gateway run|status|install|uninstall|start|stop|restart|call|usage-cost|health|probe|discover
openclaw daemon status|install|uninstall|start|stop|restart
openclaw logs
openclaw system event|heartbeat last|heartbeat enable|heartbeat disable|heartbeat presence

openclaw models list|status|set|set-image|scan
openclaw models aliases list|add|remove
openclaw models fallbacks list|add|remove|clear
openclaw models image-fallbacks list|add|remove|clear
openclaw models auth add|login|setup-token|paste-token|login-github-copilot
openclaw models auth order get|set|clear

openclaw approvals get|set|allowlist

openclaw nodes status|describe|list
openclaw nodes pending|approve|reject|rename
openclaw nodes invoke|run|notify|push
openclaw nodes screen record
openclaw nodes location get
openclaw nodes camera list|snap|clip
openclaw nodes canvas snapshot|present|hide|navigate|eval
openclaw nodes canvas a2ui push|reset

openclaw devices list|remove|clear|approve|reject|rotate|revoke
openclaw node run|status|install|uninstall|stop|restart

openclaw sandbox list|recreate|explain
openclaw cron status|list|add|edit|rm|runs|run
openclaw dns setup
openclaw docs
openclaw hooks list|info|check|enable|disable|install|update
openclaw webhooks gmail setup|run
openclaw qr
openclaw clawbot qr
openclaw pairing list|approve
openclaw plugins list|info|enable|disable|uninstall|install|update|doctor
openclaw channels list|status|capabilities|resolve|logs|add|remove|login|logout
openclaw directory self|peers list|groups list|groups members
openclaw security audit
openclaw secrets reload|audit|configure|apply
openclaw skills list|info|check
openclaw update wizard|status
openclaw completion
```

---

## 6. CLI 按场景分类（小白快速定位）

### 6.1 安装与初始化

- `setup`：初始化本地配置与工作目录
- `onboard`：交互式引导
- `configure`：配置向导
- `config ...`：配置文件读写

### 6.2 日常运行与排错

- `status` / `health` / `sessions`
- `doctor`
- `gateway ...` / `daemon ...` / `logs`

### 6.3 聊天收发与渠道管理

- `message ...`
- `channels ...`
- `pairing`
- `devices`
- `directory ...`

### 6.4 Agent 与模型

- `agent`
- `agents ...`
- `models ...`
- `memory ...`
- `approvals ...`

### 6.5 自动化与系统

- `cron ...`
- `hooks ...`
- `webhooks ...`
- `system ...`

### 6.6 浏览器 / 节点 / 沙箱

- `browser ...`
- `nodes ...`
- `node ...`
- `sandbox ...`

### 6.7 安全、扩展、维护

- `security audit`
- `secrets ...`
- `skills ...`
- `plugins ...`
- `update ...`
- `docs`
- `completion`

---

## 7. 最常用 20 条（复制即用）

```bash
openclaw status
openclaw health
openclaw sessions
openclaw doctor
openclaw models list
openclaw models status
openclaw models set openai/gpt-5.2
openclaw channels list
openclaw channels status
openclaw message send --channel telegram --target <chat_id> --message "hello"
openclaw plugins list
openclaw hooks list
openclaw cron list
openclaw gateway status
openclaw gateway probe
openclaw logs
openclaw security audit
openclaw skills list
openclaw update status
openclaw completion
```

---

## 8. 给新手的使用建议

1. 先记住 4 个聊天命令：`/help`、`/status`、`/new`、`/stop`。  
2. 改策略优先用：`/model`、`/think`、`/verbose`。  
3. 涉及执行命令时先看：`/elevated`、`/exec`、`/approve`。  
4. 终端排障先跑：`openclaw status` + `openclaw doctor`。  
5. 群聊里谨慎开：`/reasoning`、`/verbose`（可能暴露更多内部信息）。

