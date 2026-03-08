# 为什么有的 Skill 很短、有的 Skill 很长（小白版）

## 1. 先回答你的问题

是的，你看到的现象很正常：

- `skill-creator` 很长
- `gemini` / `weather` 很短

这不代表短 skill 不专业，也不代表长 skill 一定更好。

Skill 长短主要由“任务复杂度”和“错误代价”决定。

---

## 2. 一个好理解的类比

把 Skill 当“岗位说明书”：

1. `gemini`、`weather` 这种技能
- 像“单一步骤岗位”：工具就 1 个，流程很直。
- 只要告诉你“何时用、怎么调命令、注意什么”就够。

2. `healthcheck`、`coding-agent`、`skill-creator` 这种技能
- 像“多步骤岗位”：要判断上下文、分阶段执行、控制风险、处理例外。
- 必须写清楚顺序、边界、回滚和确认点，所以会更长。

---

## 3. 为什么 `skill-creator` 特别长

因为它不是“做某一个业务动作”的 skill，而是“教你怎么做 skill 的方法论 skill”。

它要覆盖：

1. 结构规范（SKILL.md/frontmatter）
2. 资源设计（scripts/references/assets）
3. 触发机制（description 设计）
4. 初始化脚本和打包流程
5. 质量校验与迭代策略

它本质上是“元技能（meta-skill）”，天然会更长。

---

## 4. 一般 Skill 都这么简单吗？

不一定。一般分三类：

1. 轻量 skill（常见）
- 10~80 行
- 只有 `SKILL.md`
- 典型：`weather`、`gemini`

2. 中等 skill
- 80~250 行
- 有明确流程，可能有少量脚本
- 典型：`coding-agent`、`healthcheck`

3. 重型 skill
- 200+ 行，带 scripts/references/assets
- 面向高风险或高复用复杂流程
- 典型：`skill-creator`

所以“简单 skill 很多”是正常的。

---

## 5. 怎么判断一个 Skill 应该写多长

看三件事：

1. 任务是否多步骤、易出错
- 越复杂越要写细。

2. 是否有外部依赖和权限风险
- 有命令执行、系统改动、网络写操作时，要写约束和确认流程。

3. 是否高频复用
- 高频任务值得沉淀脚本和参考文档，不要每次临场发挥。

---

## 6. 你的 5 个 ready skill 分层

1. 轻量：`gemini`、`weather`
- 核心是“命令模板 + 场景边界”。

2. 中等：`coding-agent`、`healthcheck`
- 核心是“流程控制 + 风险控制 + 命令约束”。

3. 重型：`skill-creator`
- 核心是“创建技能的方法论 + 工具链（初始化/打包/校验）”。

---

## 7. 最实用结论

- Skill 不是越长越好，而是“够用且稳定”最好。
- 简单任务用短 skill，复杂高风险任务用长 skill。
- 你现在看到“4 个短/中 + 1 个长”是合理分布，不是异常。
