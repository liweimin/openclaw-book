# Skill 依赖满足与文件结构说明（针对你当前 5 个 ready Skill）

> 生成时间：2026-03-05  
> 目标：解释“依赖满足”是什么意思，并把 5 个 ready skill 的完整结构列出来

## 1. “依赖满足（ready）”到底是什么意思

当你执行 `openclaw skills list --eligible` 时，系统会检查每个 skill 的 frontmatter 条件。

这些条件通常写在 `SKILL.md` 的 `metadata.openclaw.requires` 里，常见有：

1. `bins`：必须存在的命令行工具（全部都要有）。
2. `anyBins`：至少存在一个命令行工具。
3. `env`：必须存在的环境变量。
4. `config`：必须在 `openclaw.json` 里配置的键。
5. `os`：操作系统限制（比如只支持 `darwin`）。

所以：

- `✓ ready` = 这个 skill 的依赖检查通过，可以被模型选中使用。
- `✗ missing` = 至少有一项条件不满足（缺命令、缺变量、缺配置或系统不匹配）。

注意：

- `ready` 不等于“100%会执行成功”。
- 还要看工具权限（`tools.profile` / `tools.allow` / `tools.deny`）和网络/登录状态。

---

## 2. 你这 5 个 ready skill 的依赖结论

基于你机器的实测（`openclaw skills info <name>`）：

1. `coding-agent`
- 依赖：`anyBins = [claude, codex, opencode, pi]`
- 你机器：通过（检测到可用命令）

2. `gemini`
- 依赖：`bins = [gemini]`
- 你机器：通过（命令存在）

3. `healthcheck`
- 依赖：无显式 `requires`
- 你机器：通过

4. `skill-creator`
- 依赖：无显式 `requires`
- 你机器：通过

5. `weather`
- 依赖：`bins = [curl]`
- 你机器：通过

---

## 3. 5 个 ready skill 的完整结构与文件（真实路径）

技能根目录：

`D:\env\nodejs\node_global\node_modules\openclaw\skills`

### 3.1 coding-agent

根目录：

`D:\env\nodejs\node_global\node_modules\openclaw\skills\coding-agent`

结构：

```text
coding-agent/
└─ SKILL.md
```

文件清单：

1. `D:\env\nodejs\node_global\node_modules\openclaw\skills\coding-agent\SKILL.md`
- 作用：定义触发描述、PTY 要求、命令执行与进程管理流程。

### 3.2 gemini

根目录：

`D:\env\nodejs\node_global\node_modules\openclaw\skills\gemini`

结构：

```text
gemini/
└─ SKILL.md
```

文件清单：

1. `D:\env\nodejs\node_global\node_modules\openclaw\skills\gemini\SKILL.md`
- 作用：定义 Gemini CLI 的触发语义、调用示例与依赖要求。

### 3.3 healthcheck

根目录：

`D:\env\nodejs\node_global\node_modules\openclaw\skills\healthcheck`

结构：

```text
healthcheck/
└─ SKILL.md
```

文件清单：

1. `D:\env\nodejs\node_global\node_modules\openclaw\skills\healthcheck\SKILL.md`
- 作用：定义主机安全体检的步骤、确认机制、修复顺序与审计命令。

### 3.4 skill-creator

根目录：

`D:\env\nodejs\node_global\node_modules\openclaw\skills\skill-creator`

结构：

```text
skill-creator/
├─ license.txt
├─ SKILL.md
└─ scripts/
   ├─ init_skill.py
   ├─ package_skill.py
   ├─ quick_validate.py
   ├─ test_package_skill.py
   └─ test_quick_validate.py
```

文件清单：

1. `D:\env\nodejs\node_global\node_modules\openclaw\skills\skill-creator\SKILL.md`
- 作用：定义“如何创建/更新 skill”的方法论和流程。

2. `D:\env\nodejs\node_global\node_modules\openclaw\skills\skill-creator\license.txt`
- 作用：该技能包附带的许可文本。

3. `D:\env\nodejs\node_global\node_modules\openclaw\skills\skill-creator\scripts\init_skill.py`
- 作用：初始化新 skill 目录与基础文件。

4. `D:\env\nodejs\node_global\node_modules\openclaw\skills\skill-creator\scripts\package_skill.py`
- 作用：打包 skill。

5. `D:\env\nodejs\node_global\node_modules\openclaw\skills\skill-creator\scripts\quick_validate.py`
- 作用：快速校验 skill 结构与必需项。

6. `D:\env\nodejs\node_global\node_modules\openclaw\skills\skill-creator\scripts\test_package_skill.py`
- 作用：打包流程测试。

7. `D:\env\nodejs\node_global\node_modules\openclaw\skills\skill-creator\scripts\test_quick_validate.py`
- 作用：校验流程测试。

### 3.5 weather

根目录：

`D:\env\nodejs\node_global\node_modules\openclaw\skills\weather`

结构：

```text
weather/
└─ SKILL.md
```

文件清单：

1. `D:\env\nodejs\node_global\node_modules\openclaw\skills\weather\SKILL.md`
- 作用：定义天气查询场景、调用示例与 `curl` 依赖。

---

## 4. 你可以自己重复验证（命令）

```powershell
# 看 ready 列表
openclaw skills list --eligible

# 看某个 skill 的依赖说明
openclaw skills info coding-agent
openclaw skills info gemini
openclaw skills info healthcheck
openclaw skills info skill-creator
openclaw skills info weather

# 看完整（包含 missing）
openclaw skills list

# 看文件结构（以 skill-creator 为例）
Get-ChildItem -Path D:\env\nodejs\node_global\node_modules\openclaw\skills\skill-creator -Recurse -Force
```

---

## 5. 小白一句话理解

- Skill 像“岗位说明书 + 可选工具包”。
- `ready` 像“上岗条件达标”。
- 是否干得动，还看“权限开没开 + 网络和账号是否可用”。
