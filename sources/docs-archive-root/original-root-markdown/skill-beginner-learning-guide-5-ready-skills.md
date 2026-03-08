# Skill 小白学习文档（基于你当前的 5 个可用 Skill）

> 生成时间：2026-03-05  
> 适用环境：你的 OpenClaw 当前输出 `openclaw skills list --eligible` 显示 5 个 ready

## 0. 先给你结论（1 分钟看懂）

1. Skill 不是“只有一段提示词”。
2. Skill = `触发说明 + 操作说明 + 可选脚本/资料/资源` 的一个文件夹。
3. Skill 先看“是否 ready”（依赖齐不齐），再看“工具权限是否允许执行”。
4. 你现在 5 个 ready skill 是：`coding-agent`、`gemini`、`healthcheck`、`skill-creator`、`weather`。
5. 你当前工具配置是 `tools.profile = messaging`，所以有些需要命令执行的 skill 在聊天里可能受限。

---

## 1. Skill 到底是什么

可以把 Skill 理解成：

- 给 AI 的“岗位 SOP（标准作业流程）”
- 不是让 AI 变聪明，而是让 AI **按你的场景稳定做事**

一个 Skill 的典型目录（简化版）：

```text
skill-name/
├─ SKILL.md            # 必需：名字、描述、使用规则
├─ scripts/            # 可选：可执行脚本（提高稳定性）
├─ references/         # 可选：参考资料（按需加载）
└─ assets/             # 可选：模板/素材（输出时使用）
```

重点：

- `SKILL.md` 里最关键的是 frontmatter 的 `name` 和 `description`。
- 系统先用 `name/description` 判断“要不要用这个 skill”。
- 真正触发后，再读取正文说明和附加资源。

---

## 2. Skill 是怎么触发的

你可以理解成 4 步：

1. **加载候选技能**
- OpenClaw 扫描内置和本地技能目录。

2. **资格筛选（ready/missing）**
- 检查依赖是否满足：`bin`、`env`、`config`、`os`。
- 满足就是 `✓ ready`，不满足就是 `✗ missing`。

3. **语义匹配**
- 当用户问题和某个 skill 的描述匹配时，模型会优先参考该 skill 说明。

4. **执行动作**
- 不是 skill 自己执行，而是 skill 引导模型去调用工具/命令。

所以：

- `ready` 只代表“这个 skill 可被选中”。
- 是否真正跑起来，还取决于工具权限（比如 `tools.profile`、`tools.allow/deny`）。

---

## 3. Skill 有啥用

1. 让输出更稳定：同类任务不再每次即兴发挥。
2. 降低出错率：把高风险步骤写死（比如必须先检查再执行）。
3. 降低提问成本：你不用每次都重新描述工作流。
4. 便于团队复用：同一套 skill 可复制到多个环境。

---

## 4. 什么时候该用 Skill，什么时候不用

该用 Skill：

1. 流程固定、重复率高（如体检、摘要、批处理）。
2. 有外部依赖（CLI/API/账号权限）。
3. 对结果格式和步骤有明确要求。

不一定要 Skill：

1. 一次性小任务。
2. 纯聊天解释，不涉及工具调用。
3. 你希望模型自由发挥，而不是按 SOP。

---

## 5. 用你这 5 个 ready skill 做例子

## 5.1 coding-agent

用途：

- 委托编码任务给 Codex / Claude Code / Pi / OpenCode。
- 适合中大任务（新功能、重构、PR 修复）。

触发话术示例：

- “用 coding-agent 在当前仓库定位 TODO 并给我修复方案。”
- “把这个模块重构成可测试结构，并给 patch。”

你机器的状态：

- `openclaw skills info coding-agent` 显示 `✓ Ready`
- 依赖命令存在：`codex --version`、`claude --version` 可执行

验证方式：

```powershell
openclaw skills info coding-agent
codex --version
claude --version
```

注意：

- 这个 skill 往往依赖命令执行能力（runtime 工具）。
- 你当前 `tools.profile=messaging`，在聊天里可能无法完整发挥 coding-agent。

---

## 5.2 gemini

用途：

- 用 Gemini CLI 做一问一答、摘要、生成文本。

触发话术示例：

- “用 gemini 总结这段内容，给 5 条要点。”

你机器的状态：

- `openclaw skills info gemini` 显示 `✓ Ready`
- `where gemini` 能找到命令路径
- 但 `gemini --help` 与直接调用出现超时（通常是首次登录/认证未完成或网络问题）

验证方式：

```powershell
openclaw skills info gemini
where gemini
gemini
```

如果弹登录流程，按提示完成一次后再测。

---

## 5.3 healthcheck

用途：

- 做主机安全体检和加固建议（防火墙、权限、暴露面、升级状态）。

触发话术示例：

- “用 healthcheck 做一份安全体检，只做只读检查。”

你机器的状态：

- `openclaw skills info healthcheck` 显示 `✓ Ready`
- 已实测可执行：`openclaw security audit`、`openclaw update status`

验证方式：

```powershell
openclaw skills info healthcheck
openclaw security audit
openclaw update status
```

补充：

- 你当前机器已查出若干权限风险（audit 给出 2 critical）。

---

## 5.4 skill-creator

用途：

- 专门用于创建/更新 skill。
- 帮你把“任务经验”沉淀成可复用 skill 包。

触发话术示例：

- “用 skill-creator 帮我做一个会议纪要 skill，输出目录结构和 SKILL.md 初稿。”

你机器的状态：

- `openclaw skills info skill-creator` 显示 `✓ Ready`

验证方式：

```powershell
openclaw skills info skill-creator
```

实操验证（最直观）：

- 让它生成一个新 skill 目录草稿，看是否包含 `name/description` 和最小结构。

---

## 5.5 weather

用途：

- 查实时天气和预报（不需要 API key，默认可走 wttr/open-meteo）。

触发话术示例：

- “用 weather 查上海今天天气和明天是否下雨。”

你机器的状态：

- `openclaw skills info weather` 显示 `✓ Ready`
- `curl` 存在
- `wttr.in` 在你当前网络下超时，但 `open-meteo` 请求成功

验证方式：

```powershell
openclaw skills info weather
curl --version
curl "https://api.open-meteo.com/v1/forecast?latitude=31.23&longitude=121.47&current=temperature_2m"
```

---

## 6. 你现在为什么会“看得懂 ready，但用起来有时不对劲”

核心原因：你混了两层状态。

第一层：Skill 资格层

- `openclaw skills list --eligible` 看到 `✓ ready`
- 表示依赖满足，可以被系统选中。

第二层：工具权限层

- 由 `tools.profile` + `tools.allow/deny` 决定。
- 你当前是 `messaging`，偏消息场景。
- 某些需要执行命令/文件操作的 skill 可能被限制。

你当前配置实测：

```json
{ "profile": "messaging" }
```

---

## 7. 小白最实用的验证清单（照抄即可）

```powershell
# A. 看 ready（资格）
openclaw skills list --eligible
openclaw skills info coding-agent
openclaw skills info gemini
openclaw skills info healthcheck
openclaw skills info skill-creator
openclaw skills info weather

# B. 看权限（能不能执行）
openclaw config get tools

# C. 看依赖命令
codex --version
claude --version
where gemini
curl --version

# D. 做功能烟雾测试
openclaw security audit
openclaw update status
curl "https://api.open-meteo.com/v1/forecast?latitude=31.23&longitude=121.47&current=temperature_2m"
```

---

## 8. 一句话记忆法

- Skill 像“岗位 SOP”。
- `ready` 像“员工到岗了”。
- `tools.profile/allow/deny` 像“门禁权限”。
- 到岗不等于能进所有门。
