# Skills 跨 Agent 兼容与安装指南（小白版）

适用场景：你想把 Skills 用在 OpenClaw、Codex、Claude Code 或其他支持 Skill 的 Agent 里。

## 1. 先说结论

1. **可以跨 Agent 复用，但不是 100% 无改动通用。**
2. 现在有一个公开规范（Agent Skills），核心结构基本统一：`技能目录 + SKILL.md`。
3. 真正落地时，**每个 Agent 都有自己的扩展字段、权限系统、目录约定和触发逻辑**，所以常见情况是“同一份 Skill 稍改后可复用”。

## 2. “统一标准”到底统一了什么？

统一的是“骨架”：

- 一个 skill 至少是一个目录，里面有 `SKILL.md`
- `SKILL.md` 由 YAML frontmatter + Markdown 指令组成
- 可选目录通常有 `scripts/`、`references/`、`assets/`

不统一的是“运行时”：

- 安装路径（每家目录不同）
- 触发/调度方式（自动触发、斜杠命令、API 容器参数等）
- 权限与工具字段（有的支持，有的忽略）
- Agent 私有 metadata（例如 `metadata.openclaw.*`）

## 3. 你这 5 个技能，能不能装到别家？

你当前 `ready` 的 5 个：`coding-agent`、`gemini`、`healthcheck`、`skill-creator`、`weather`。

可移植性（给小白的直观判断）：

1. `skill-creator`：偏“说明类”，可移植性高。
2. `weather`：依赖 `curl`，中等偏高（目标环境有 curl 就好）。
3. `gemini`：依赖 `gemini` CLI，可移植但要先装 CLI + 登录。
4. `coding-agent`：依赖多个 CLI（`claude/codex/opencode/pi`）和会话工具，跨 Agent 迁移常要改指令。
5. `healthcheck`：大量 OpenClaw 命令（如 `openclaw security audit`），迁移到非 OpenClaw 基本要重写。

一句话：**“指令越通用，越好迁移；越绑定某平台工具，越要改。”**

## 4. 安装方法（Windows 小白版）

### A) 装到 Codex（官方 `skill-installer` 路线）

`skill-installer` 会把技能装到 `~/.codex/skills`（Windows 即 `$HOME\.codex\skills`）。

1. 列出可安装技能（来自 `openai/skills`）

```powershell
python C:\Users\Yuca\.codex\skills\.system\skill-installer\scripts\list-skills.py
```

2. 安装 curated 技能（示例）

```powershell
python C:\Users\Yuca\.codex\skills\.system\skill-installer\scripts\install-skill-from-github.py --repo openai/skills --path skills/.curated/<skill-name>
```

3. 从任意 GitHub 目录安装（示例）

```powershell
python C:\Users\Yuca\.codex\skills\.system\skill-installer\scripts\install-skill-from-github.py --url https://github.com/<owner>/<repo>/tree/main/<path-to-skill>
```

4. 重启 Codex（官方建议）

### B) 装到 Claude Code（本地目录法）

1. 新建个人 skills 目录（全局可用）

```powershell
New-Item -ItemType Directory -Force "$HOME\.claude\skills\my-skill"
```

2. 放入 `SKILL.md`（必要时附带 `scripts/`、`references/`）
3. 在 Claude Code 里测试：
   - 直接问一个匹配描述的问题（自动触发）
   - 或用 `/my-skill ...`（手动触发）

### C) 装到 OpenClaw（本地/工作区）

OpenClaw 会从这些位置加载 skill（优先级从高到低）：

1. `<workspace>/skills`
2. `~/.openclaw/skills`
3. 内置 skills

验证命令：

```powershell
openclaw skills list --eligible
openclaw skills check
```

## 5. 你之前问的 `full` / `tools.allow` 是什么？

这不是 Skill 标准本身，而是 **OpenClaw 的工具权限配置**：

1. `tools.profile`：基础工具集合
   - `minimal`、`coding`、`messaging`、`full`
2. `full`：不限制基础工具（等同不开基础限制）
3. `tools.allow`：额外“只允许这些工具”
4. `tools.deny`：显式拒绝（优先级高于 allow）

小白建议：

1. 先用 `messaging` 或 `coding`
2. 按需加 `tools.allow`
3. 不要一上来就 `full`

## 6. “这些 skill 都有官网吗 / GitHub 吗？”

不是必须都有。

1. Skill 的 `homepage` 字段是可选项，没有也正常。
2. 很多 skill 只有仓库目录，没有单独官网。
3. 来源通常是：
   - 官方仓库（如 OpenAI、Anthropic）
   - 官方注册表（如 ClawHub）
   - 社区仓库（质量差异大，需要审计）

## 7. 小白判断“能不能装”的 5 步

1. 看结构：是否有 `SKILL.md`
2. 看依赖：`requires.bins` / 脚本里要的命令，你机器有没有
3. 看平台字段：是否写了平台私有 metadata（可能要改）
4. 先小范围测试触发
5. 再决定是否放到全局目录

## 8. 官方入口（建议从这里找）

- Agent Skills 开放规范（总规范）：https://agentskills.io/
- Agent Skills 规范详情：https://agentskills.io/specification
- OpenAI Skills 仓库（Codex）：https://github.com/openai/skills
- Codex Skills 文档（OpenAI）：https://developers.openai.com/codex/skills
- Claude Code Skills 文档：https://code.claude.com/docs/en/skills
- Anthropic Skills 仓库：https://github.com/anthropics/skills
- OpenClaw Skills 文档：https://docs.openclaw.ai/tools/skills
- ClawHub（OpenClaw 技能注册表）：https://clawhub.com

