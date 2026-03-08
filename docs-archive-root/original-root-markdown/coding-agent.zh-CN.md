---
name: coding-agent
description: '通过后台进程把编码任务委托给 Codex、Claude Code 或 Pi 代理。适用场景：(1) 构建/创建新功能或应用，(2) 评审 PR（建议在临时目录执行），(3) 重构大型代码库，(4) 需要遍历文件并多轮迭代的编码任务。非适用场景：简单一行修复（直接改即可）、纯读代码（用 read 工具）、聊天线程内 ACP harness 请求（例如在 Discord 线程里运行 Codex 或 Claude Code；应使用 sessions_spawn + runtime:"acp"）、或在 ~/clawd 工作区中执行任何任务（绝对不要）。需要支持 pty:true 的 bash 工具。'
metadata:
  {
    "openclaw": { "emoji": "🧩", "requires": { "anyBins": ["claude", "codex", "opencode", "pi"] } },
  }
---

> 原始 `SKILL.md` 的 `description`（英文）  
> `Delegate coding tasks to Codex, Claude Code, or Pi agents via background process. Use when: (1) building/creating new features or apps, (2) reviewing PRs (spawn in temp dir), (3) refactoring large codebases, (4) iterative coding that needs file exploration. NOT for: simple one-liner fixes (just edit), reading code (use read tool), thread-bound ACP harness requests in chat (for example spawn/run Codex or Claude Code in a Discord thread; use sessions_spawn with runtime:"acp"), or any work in ~/clawd workspace (never spawn agents here). Requires a bash tool that supports pty:true.`
>
> 对应中文直译  
> `通过后台进程把编码任务委托给 Codex、Claude Code 或 Pi 代理。适用于：(1) 构建/创建新功能或应用，(2) 评审 PR（在临时目录启动），(3) 重构大型代码库，(4) 需要文件探索的迭代式编码任务。不适用于：简单一行修复（直接编辑即可）、仅仅读代码（用 read 工具）、聊天线程绑定的 ACP harness 请求（例如在 Discord 线程里运行 Codex 或 Claude Code；请使用 sessions_spawn 且 runtime:"acp"），以及在 ~/clawd 工作区内的任何任务（绝对不要）。要求 bash 工具支持 pty:true。`

# Coding Agent（bash-first）

所有编码代理任务统一用 **bash**（可选后台模式），简单且有效。

## ⚠️ 必须使用 PTY 模式

编码代理（Codex、Claude Code、Pi）是**交互式终端应用**，需要伪终端（PTY）才能正确运行。没有 PTY 时，常见问题是输出异常、颜色缺失、进程卡住。

运行编码代理时，**始终使用 `pty:true`**：

```bash
# ✅ 正确：带 PTY
bash pty:true command:"codex exec 'Your prompt'"

# ❌ 错误：不带 PTY，代理可能异常
bash command:"codex exec 'Your prompt'"
```

### Bash 工具参数

| 参数         | 类型    | 说明 |
| ------------ | ------- | ---- |
| `command`    | string  | 要执行的 shell 命令 |
| `pty`        | boolean | **编码代理必开**：为交互式 CLI 分配伪终端 |
| `workdir`    | string  | 工作目录（代理只会看到该目录上下文） |
| `background` | boolean | 后台运行，返回 `sessionId` 供后续追踪 |
| `timeout`    | number  | 超时秒数（超时会杀进程） |
| `elevated`   | boolean | 如果允许，可在宿主机上执行而非沙箱 |

### Process 工具动作（用于后台会话）

| 动作        | 说明 |
| ----------- | ---- |
| `list`      | 列出所有运行中/近期会话 |
| `poll`      | 查询会话是否仍在运行 |
| `log`       | 读取会话输出（可带 offset/limit） |
| `write`     | 向 stdin 发送原始数据 |
| `submit`    | 发送数据并附带换行（等同输入后按回车） |
| `send-keys` | 发送按键 token 或十六进制字节 |
| `paste`     | 粘贴文本（可选 bracketed 模式） |
| `kill`      | 终止会话 |

---

## 快速开始：一次性任务

快速问答/小任务时，创建临时 git 仓库再执行：

```bash
# 快速聊天（Codex 需要 git 仓库）
SCRATCH=$(mktemp -d) && cd $SCRATCH && git init && codex exec "Your prompt here"

# 或在真实项目中运行（要带 PTY）
bash pty:true workdir:~/Projects/myproject command:"codex exec 'Add error handling to the API calls'"
```

**为什么要 git init？** Codex 不会在非受信任 git 目录中运行。临时仓库能解决 scratch 场景。

---

## 标准模式：workdir + background + pty

长任务建议用“后台 + PTY”：

```bash
# 在目标目录启动代理（务必 PTY）
bash pty:true workdir:~/project background:true command:"codex exec --full-auto 'Build a snake game'"
# 返回 sessionId，用于跟踪

# 查看进度
process action:log sessionId:XXX

# 查看是否完成
process action:poll sessionId:XXX

# 代理提问时输入
process action:write sessionId:XXX data:"y"

# 输入并回车
process action:submit sessionId:XXX data:"yes"

# 需要时终止
process action:kill sessionId:XXX
```

**为什么 `workdir` 很重要？** 代理会在限定目录中工作，避免乱读无关文件。

---

## Codex CLI

**模型：** 默认 `gpt-5.2-codex`（在 `~/.codex/config.toml` 配置）

### 常用参数

| 参数            | 作用 |
| --------------- | ---- |
| `exec "prompt"` | 一次性执行，完成即退出 |
| `--full-auto`   | 在沙箱内自动审批工作区操作 |
| `--yolo`        | 关闭沙箱和审批（最快但风险最高） |

### 构建/开发

```bash
# 快速一次性执行（自动审批）- 记得 PTY
bash pty:true workdir:~/project command:"codex exec --full-auto 'Build a dark mode toggle'"

# 长任务后台跑
bash pty:true workdir:~/project background:true command:"codex --yolo 'Refactor the auth module'"
```

### PR 评审

**⚠️ 关键：不要在 OpenClaw 自己的项目目录里直接评审 PR。**
请克隆到临时目录或使用 git worktree。

```bash
# 临时目录评审
REVIEW_DIR=$(mktemp -d)
git clone https://github.com/user/repo.git $REVIEW_DIR
cd $REVIEW_DIR && gh pr checkout 130
bash pty:true workdir:$REVIEW_DIR command:"codex review --base origin/main"
# 完成后清理：trash $REVIEW_DIR

# 或用 git worktree（不污染主目录）
git worktree add /tmp/pr-130-review pr-130-branch
bash pty:true workdir:/tmp/pr-130-review command:"codex review --base main"
```

### 批量 PR 评审（并行）

```bash
# 先拉取所有 PR 引用
git fetch origin '+refs/pull/*/head:refs/remotes/origin/pr/*'

# 每个 PR 起一个 Codex（都要 PTY）
bash pty:true workdir:~/project background:true command:"codex exec 'Review PR #86. git diff origin/main...origin/pr/86'"
bash pty:true workdir:~/project background:true command:"codex exec 'Review PR #87. git diff origin/main...origin/pr/87'"

# 统一查看状态
process action:list

# 把结果回贴到 GitHub
gh pr comment <PR#> --body "<review content>"
```

---

## Claude Code

```bash
# 带 PTY，确保终端输出正常
bash pty:true workdir:~/project command:"claude 'Your task'"

# 后台执行
bash pty:true workdir:~/project background:true command:"claude 'Your task'"
```

---

## OpenCode

```bash
bash pty:true workdir:~/project command:"opencode run 'Your task'"
```

---

## Pi Coding Agent

```bash
# 安装: npm install -g @mariozechner/pi-coding-agent
bash pty:true workdir:~/project command:"pi 'Your task'"

# 非交互模式（仍建议 PTY）
bash pty:true command:"pi -p 'Summarize src/'"

# 指定 provider/model
bash pty:true command:"pi --provider openai --model gpt-4o-mini -p 'Your task'"
```

**说明：** Pi 已启用 Anthropic prompt caching（PR #584，2026 年 1 月合并）。

---

## 用 git worktrees 并行修多个 issue

```bash
# 1) 为每个 issue 建 worktree
git worktree add -b fix/issue-78 /tmp/issue-78 main
git worktree add -b fix/issue-99 /tmp/issue-99 main

# 2) 每个 worktree 启一个 Codex（后台 + PTY）
bash pty:true workdir:/tmp/issue-78 background:true command:"pnpm install && codex --yolo 'Fix issue #78: <description>. Commit and push.'"
bash pty:true workdir:/tmp/issue-99 background:true command:"pnpm install && codex --yolo 'Fix issue #99 from the approved ticket summary. Implement only the in-scope edits and commit after review.'"

# 3) 监控进度
process action:list
process action:log sessionId:XXX

# 4) 修完提 PR
cd /tmp/issue-78 && git push -u origin fix/issue-78
gh pr create --repo user/repo --head fix/issue-78 --title "fix: ..." --body "..."

# 5) 清理
git worktree remove /tmp/issue-78
git worktree remove /tmp/issue-99
```

---

## ⚠️ 规则

1. **始终开 `pty:true`**，编码代理需要真实终端。
2. **尊重用户指定工具**：用户点名 Codex 就用 Codex。
   - 编排模式下，不要偷偷自己手改所有 patch。
   - 代理失败/卡住时，重拉起或向用户确认，不要无声接管。
3. **要有耐心**：别因为“看起来慢”就乱杀会话。
4. **用 `process:log` 观察进度**，尽量不要干扰执行。
5. **构建任务优先 `--full-auto`**。
6. **评审任务通常用默认参数即可**。
7. **可以并行**：多个 Codex 进程可同时跑。
8. **绝不要在 `~/.openclaw/` 启动 Codex**。
9. **绝不要在 `~/Projects/openclaw/` 直接 checkout 分支**，那是线上 OpenClaw 实例目录。

---

## 进度更新（关键）

当你在后台启动编码代理时，要给用户清晰进度：

- 启动时发 1 条短消息（跑了什么、在哪个目录）。
- 之后只在状态变化时更新：
  - 里程碑完成（构建完成、测试通过）
  - 代理提出问题，需要用户输入
  - 出错或需要用户动作
  - 任务完成（说明改了什么、改在哪）
- 若你手动 kill 会话，要立即说明“已终止 + 原因”。

这样用户不会只看到“Agent failed before reply”却不知道发生了什么。

---

## 完成后自动通知

长任务建议在 prompt 末尾附加 wake 触发，完成后立刻通知 OpenClaw：

```
... your task here.

When completely finished, run this command to notify me:
openclaw system event --text "Done: [brief summary of what was built]" --mode now
```

**示例：**

```bash
bash pty:true workdir:~/project background:true command:"codex --yolo exec 'Build a REST API for todos.

When completely finished, run: openclaw system event --text \"Done: Built todos REST API with CRUD endpoints\" --mode now'"
```

这样会触发即时唤醒事件，通常几秒内能通知到，而不是等心跳周期。

---

## 经验总结（2026 年 1 月）

- **PTY 是刚需**：没有 `pty:true`，输出容易坏或卡住。
- **必须在 git 仓库里跑**：Codex 不在非 git 目录运行，scratch 场景用 `mktemp -d && git init`。
- **`exec` 很实用**：`codex exec "prompt"` 一次执行完就退出，适合 one-shot。
- **`submit` vs `write`**：`submit` 会自动回车，`write` 只写入不回车。
- **轻松 prompt 也有效**：例如让它写“给太空龙虾打下手”的俳句也能正常响应。
