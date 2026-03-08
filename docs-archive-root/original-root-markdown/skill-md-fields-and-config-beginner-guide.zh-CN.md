# SKILL.md 字段与配置手册（小白可直接用）

> 适用：OpenClaw / AgentSkills 目录结构
> 目标：看懂每个字段、会自己写 skill、会在 `openclaw.json` 里配置

## 1. 先记结论

1. `SKILL.md` 的核心触发字段只有两个：`name` 和 `description`。
2. 其他字段是增强能力（UI 展示、命令分发、依赖门控）。
3. Skill 是否可用，看两层：
- Skill 元数据依赖是否满足（`ready/missing`）
- 工具权限是否允许执行（`tools.profile/allow/deny`）

## 2. 最小可用 SKILL.md

```markdown
---
name: my-skill
description: Do X for Y. Use when user asks about ...
---

# My Skill

Write instructions here.
```

## 3. Frontmatter 字段逐个解释

## 3.1 必填字段

1. `name`
- Skill 唯一名字（建议小写+连字符，如 `pdf-editor`）。

2. `description`
- 触发判断最重要字段。
- 要写清“做什么 + 什么时候用 + 不适用场景”。

## 3.2 常用可选字段（OpenClaw）

1. `homepage`
- 技能主页 URL，UI 可显示。

2. `user-invocable: true|false`
- 是否允许用户手动触发该 skill（默认 `true`）。

3. `disable-model-invocation: true|false`
- 设为 `true` 后，该 skill 不自动注入给模型（但仍可用户手动调用）。

4. `command-dispatch: tool`
- 开启后，斜杠命令可直接分发到工具层。

5. `command-tool`
- 配合 `command-dispatch: tool`，指定要调用的工具名。

6. `command-arg-mode: raw`
- 把命令参数原样转给工具。

## 3.3 `metadata`（依赖门控与安装提示）

OpenClaw 常用 `metadata.openclaw`。

1. `always: true`
- 永远包含该 skill（跳过其他门控）。

2. `emoji`
- UI 展示表情。

3. `homepage`
- 可在 `metadata.openclaw.homepage` 里再定义主页。

4. `os: ["darwin"|"linux"|"win32"]`
- 限定操作系统。

5. `requires.bins`
- 这些命令必须都在 PATH 里。

6. `requires.anyBins`
- 这些命令里至少存在一个。

7. `requires.env`
- 这些环境变量必须存在（或在配置中提供）。

8. `requires.config`
- `openclaw.json` 里对应路径必须为真值。

9. `primaryEnv`
- 指定“这个 skill 的主密钥变量名”，便于 `skills.entries.<key>.apiKey` 注入。

10. `install`
- 给 UI 的安装提示（brew/node/go/download 规格）。

11. `skillKey`（如果有）
- 覆盖默认 skill 名作为配置键。若定义了它，`skills.entries` 要用 `skillKey`，不是 `name`。

## 4. 重要格式规则（容易踩坑）

1. `SKILL.md` 必须有 frontmatter。
2. `name`、`description` 要清晰。
3. `metadata` 建议写成单行 JSON 对象风格（OpenClaw 解析更稳）。
4. 代码块里的命令必须可执行，不要写伪命令。

## 5. 如果你来“配置 skill”，改哪里

配置文件：`~/.openclaw/openclaw.json`（Windows 通常在 `C:\Users\用户名\.openclaw\openclaw.json`）

所有 skill 配置在：`skills`。

## 5.1 全局技能加载配置

```json5
{
  skills: {
    allowBundled: ["gemini", "weather"],
    load: {
      extraDirs: ["D:/my-shared-skills"],
      watch: true,
      watchDebounceMs: 250
    },
    install: {
      preferBrew: true,
      nodeManager: "npm" // npm | pnpm | yarn | bun
    }
  }
}
```

## 5.2 单个 skill 开关与注入

```json5
{
  skills: {
    entries: {
      "nano-banana-pro": {
        enabled: true,
        apiKey: "YOUR_KEY",
        env: {
          GEMINI_API_KEY: "YOUR_KEY"
        },
        config: {
          endpoint: "https://example.invalid",
          model: "nano-pro"
        }
      },
      "weather": { enabled: true },
      "some-skill": { enabled: false }
    }
  }
}
```

解释：

1. `enabled: false` 直接禁用该 skill。
2. `env` 在该轮运行注入环境变量（仅宿主机侧，且仅在未设置时注入）。
3. `apiKey` 是给 `primaryEnv` 的快捷注入。
4. `config` 是该 skill 的自定义配置容器。

## 5.3 我只想安装自己写的 skill

目录优先级（高到低）：

1. `<workspace>/skills`
2. `~/.openclaw/skills`
3. 内置 skills

做法：

1. 把 skill 文件夹放进当前工作区的 `skills/`。
2. 跑 `openclaw skills list` 看是否被识别。
3. 跑 `openclaw skills list --eligible` 看是否 ready。

## 6. 三个可复制模板

## 6.1 纯本地工具依赖 skill

```markdown
---
name: my-cli-helper
description: Help run mycli for data export. Use when user asks to export data.
metadata: { "openclaw": { "requires": { "bins": ["mycli"] } } }
---

# My CLI Helper

Use `mycli export ...` for export tasks.
```

## 6.2 需要 API Key 的 skill

```markdown
---
name: my-api-skill
description: Call My API to fetch project records.
metadata: { "openclaw": { "requires": { "env": ["MY_API_KEY"] }, "primaryEnv": "MY_API_KEY" } }
---
```

对应配置：

```json5
{
  skills: {
    entries: {
      "my-api-skill": {
        enabled: true,
        apiKey: "YOUR_MY_API_KEY"
      }
    }
  }
}
```

## 6.3 平台限定 skill（只在 Windows）

```markdown
---
name: windows-only-task
description: Run Windows-specific diagnostics.
metadata: { "openclaw": { "os": ["win32"], "requires": { "bins": ["powershell"] } } }
---
```

## 7. 怎么验证你写的 skill 是否生效

```bash
openclaw skills list
openclaw skills list --eligible
openclaw skills info <skill-name>
openclaw skills check
```

## 8. 最常见问题

1. `skills list` 有，但 `--eligible` 没有
- 依赖没满足（bin/env/config/os 其中之一）。

2. skill ready 但执行时没效果
- 可能被工具权限限制（`tools.profile/allow/deny`）。

3. 改了 skill 文件却没立刻生效
- 同一会话有快照；开新会话最稳。

4. 配置键没生效
- 如果 skill 定义了 `metadata.openclaw.skillKey`，要用 `skillKey` 作为 `skills.entries` 键名。

## 9. 给你的推荐起步法

1. 先只写 `name + description + 最少正文`。
2. 能跑通后再加 `metadata.requires`。
3. 最后再加 `scripts/references/assets`。
4. 每加一层就跑一次 `openclaw skills check`。
