---
name: skill-creator
description: 创建或更新 AgentSkills。适用于设计、结构化、打包包含 scripts/references/assets 的技能包。
---

> 原始 `SKILL.md` 的 `description`（英文）  
> `Create or update AgentSkills. Use when designing, structuring, or packaging skills with scripts, references, and assets.`
>
> 对应中文直译  
> `创建或更新 AgentSkills。用于设计、结构化或打包包含脚本、参考资料与资源文件的 skills。`

# Skill Creator

这个 skill 用于指导你创建高质量技能（skills）。

## 关于 Skills

Skill 是模块化、可自包含的能力包。它通过提供专业知识、工作流和工具集来扩展 Codex 能力。
你可以把它理解成面向某类任务的“上岗手册”：让通用模型在某领域里更像专家执行者。

### Skill 能提供什么

1. 专项工作流：某领域的多步骤流程
2. 工具集成：特定文件格式或 API 的使用方法
3. 领域知识：公司内规则、schema、业务逻辑
4. 配套资源：脚本、参考资料、模板素材

## 核心原则

### 简洁优先

上下文窗口是公共资源。Skill 会和系统提示词、会话历史、其他 skill 元数据、用户请求共同竞争上下文。

**默认假设：Codex 已经很聪明。**
仅补充“模型不容易自带”的信息。每段都问自己：

- “这段是必须的吗？”
- “它值不值得占用 token？”

优先短示例，不要长篇解释。

### 设定合适的自由度

根据任务脆弱性和变化性，选择控制力度：

- **高自由度（纯文本规则）**：多种做法都可行、需按上下文判断。
- **中自由度（伪代码/参数化脚本）**：有推荐范式，但允许变化。
- **低自由度（固定脚本、少参数）**：步骤脆弱、容错低、必须一致执行。

可类比为：窄桥需要护栏（低自由度），平地可以多路径（高自由度）。

### Skill 解剖结构

每个 skill 必须有 `SKILL.md`，并可附带资源：

```text
skill-name/
├── SKILL.md (必需)
│   ├── YAML frontmatter (必需)
│   │   ├── name
│   │   └── description
│   └── Markdown 说明正文
└── Bundled Resources（可选）
    ├── scripts/     可执行脚本（Python/Bash 等）
    ├── references/  按需加载的参考文档
    └── assets/      输出要使用的资源文件（模板、图标、字体等）
```

#### SKILL.md（必需）

SKILL.md 由两部分组成：

- **Frontmatter（YAML）**：包含 `name` 与 `description`。这是触发判断最关键的信息。
- **Body（Markdown）**：触发后才加载的执行说明。

#### Bundled Resources（可选）

##### Scripts（`scripts/`）

用于需要稳定可重复执行的逻辑。

- 何时需要：同类代码总被重复写、或必须确定性执行
- 示例：`scripts/rotate_pdf.py`
- 优势：省 token、可直接执行、稳定性高
- 注意：脚本也可能需要被读取以适配环境

##### References（`references/`）

用于按需加载的参考资料，帮助模型做正确判断。

- 何时需要：需要文档支持才能正确执行
- 示例：schema、API 文档、公司规则、业务流程
- 优势：让 SKILL.md 保持精简，仅在必要时加载
- 建议：大文件（>10k 字）在 SKILL.md 给出 grep 提示
- 避免重复：同一信息要么在 SKILL.md，要么在 references，不要两边都写

##### Assets（`assets/`）

不用于上下文阅读，而用于最终产物。

- 何时需要：输出需要模板/素材
- 示例：logo、PPT 模板、前端模板、字体
- 优势：把“文档”与“输出素材”分离

#### 什么不要放进 Skill

不要创建和执行任务无关的附加文档，例如：

- README.md
- INSTALLATION_GUIDE.md
- QUICK_REFERENCE.md
- CHANGELOG.md

Skill 只保留让 AI 完成任务所需的核心信息。

### 逐层加载（Progressive Disclosure）

Skill 设计采用 3 层加载：

1. **元数据（name/description）**：始终在上下文
2. **SKILL.md 正文**：仅在触发后加载
3. **资源文件**：按需加载（脚本可直接执行而不必全文注入）

#### 逐层加载的实践模式

SKILL.md 建议控制在 500 行以内，超出后拆分为 references。拆分后要在 SKILL.md 明确链接和“何时读取”。

**关键原则：** 当一个 skill 支持多个变体/框架时，SKILL.md 只保留核心流程，把变体细节放到 references。

**模式 1：总览 + 引用**

```markdown
# PDF Processing

## Quick start

Extract text with pdfplumber:
[code example]

## Advanced features

- Form filling -> FORMS.md
- API reference -> REFERENCE.md
- Examples -> EXAMPLES.md
```

需要时再读对应文件。

**模式 2：按领域拆分**

例如 BigQuery skill：

```text
bigquery-skill/
├── SKILL.md
└── reference/
    ├── finance.md
    ├── sales.md
    ├── product.md
    └── marketing.md
```

问销售指标时只读 `sales.md`。

框架/云平台同理：

```text
cloud-deploy/
├── SKILL.md
└── references/
    ├── aws.md
    ├── gcp.md
    └── azure.md
```

用户选 AWS 时只读 `aws.md`。

**模式 3：条件细节**

正文放常规流程，复杂场景给跳转链接。

```markdown
# DOCX Processing

## Creating documents
Use docx-js for new documents. See DOCX-JS.md

## Editing documents
For simple edits, modify XML directly.
For tracked changes -> REDLINING.md
For OOXML details -> OOXML.md
```

**重要建议：**

- 引用不要层层嵌套（避免深链）
- 超过 100 行的 reference 文件建议加目录

## Skill 创建流程

创建 skill 建议按 6 步走：

1. 用具体例子理解需求
2. 规划可复用资源（scripts/references/assets）
3. 初始化 skill（运行 `init_skill.py`）
4. 编辑 skill（实现资源 + 写 SKILL.md）
5. 打包 skill（运行 `package_skill.py`）
6. 在真实使用中迭代

除非有明确理由，否则不要跳步。

### Skill 命名

- 仅用小写字母、数字、连字符
- 用户输入标题需转为连字符风格（如 `Plan Mode -> plan-mode`）
- 名称长度 < 64
- 倾向短、动词导向名称
- 需要时可按工具命名空间（如 `gh-address-comments`）
- 文件夹名必须与 skill 名一致

### 第 1 步：用具体例子理解 skill

若场景已非常明确可跳过，但通常建议做。

你需要搞清楚“用户会怎么说、希望得到什么”。可通过用户给例子，或你提出候选例子让用户确认。

例如做图片编辑 skill，可问：

- 支持哪些功能（裁剪、旋转、修复等）？
- 典型使用话术有哪些？
- 除“去红眼”“旋转图片”外还会怎么用？
- 哪些用户话术应触发该 skill？

避免一次提太多问题；先问关键问题，再逐步追问。

### 第 2 步：规划可复用内容

把具体例子转成可复用资产：

1. 先想“从零完成一次要做什么”
2. 再识别“哪些脚本/文档/模板值得沉淀”

示例：

- `pdf-editor`：每次旋转 PDF 都要重写代码 -> 放 `scripts/rotate_pdf.py`
- `frontend-webapp-builder`：每次都要脚手架 -> 放 `assets/hello-world/`
- `big-query`：每次都要重新摸表结构 -> 放 `references/schema.md`

最终输出“要沉淀的脚本/参考/素材列表”。

### 第 3 步：初始化 Skill

若 skill 已存在且只做迭代/打包，可跳过。

新建 skill 时，始终优先运行 `init_skill.py`，它会生成标准骨架，减少漏项。

用法：

```bash
scripts/init_skill.py <skill-name> --path <output-directory> [--resources scripts,references,assets] [--examples]
```

示例：

```bash
scripts/init_skill.py my-skill --path skills/public
scripts/init_skill.py my-skill --path skills/public --resources scripts,references
scripts/init_skill.py my-skill --path skills/public --resources scripts --examples
```

它会自动：

- 创建 skill 目录
- 生成带 frontmatter 与 TODO 占位符的 `SKILL.md`
- 按 `--resources` 创建资源目录
- `--examples` 开启时附带示例文件

初始化后，按实际需求改 `SKILL.md` 并补资源；示例占位文件不需要就删除。

### 第 4 步：编辑 Skill

注意你是在给“另一个 Codex 实例”写说明。要写“对执行者有帮助且不显而易见”的信息。

#### 先实现可复用内容

先落地 `scripts/`、`references/`、`assets/`。

这一步常需要用户提供材料（品牌素材、模板、内部文档等）。

新增脚本要实际运行测试，确认输出正确。若脚本很多，可抽样验证。

若用了 `--examples`，不需要的占位文件要删掉；只保留确实要用的目录。

#### 再更新 SKILL.md

**写作要求：** 用祈使/不定式风格，直接给执行动作。

##### Frontmatter 写法

只写两个字段：

- `name`
- `description`

其中 `description` 是最核心触发信息，必须写清：

- skill 做什么
- 在什么触发场景使用

并且“何时使用”要写在 `description`，不要只写在正文（正文触发前不会加载）。

不要在 frontmatter 里添加其他字段。

##### Body 写法

正文写“如何使用 skill 及资源”。

### 第 5 步：打包 Skill

开发完成后，要打包成可分发的 `.skill` 文件。打包会先自动校验。

```bash
scripts/package_skill.py <path/to/skill-folder>
```

可选输出目录：

```bash
scripts/package_skill.py <path/to/skill-folder> ./dist
```

打包脚本会：

1. **先校验**：
   - YAML 格式与必填字段
   - 命名规范与目录结构
   - 描述完整性与质量
   - 文件组织与资源引用

2. **再打包**（校验通过后）：
   - 产出 `my-skill.skill`（本质是 zip，扩展名为 `.skill`）
   - 包含全部文件并保持目录结构

安全限制：

- 若包含 symlink（软链接），打包会失败。

若校验失败，脚本会报错并停止。修复后重新执行打包。

### 第 6 步：迭代

skill 上线后通常会快速收到改进反馈。

迭代流程：

1. 在真实任务中使用
2. 观察卡点或低效处
3. 确认应修改 `SKILL.md` 还是资源文件
4. 修改并再次测试
