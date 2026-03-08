# OpenClaw GitHub 源码结构、文档与提交历史分析

本文基于本地克隆下来的仓库 `D:\code\anzhuang\openclaw` 进行整理，目的是给第一次接触 OpenClaw 源码的人一个能快速上手的全景图。  
注意：这是一份新的独立文档，没有修改你目录里原来的任何说明文件。

## 1. 先说结论：这个仓库是什么

OpenClaw 不是一个“单体小项目”，而是一个体量很大的多端 AI 助手平台仓库。

从仓库根目录的 `package.json` 可以确认：

- 项目名是 `openclaw`
- 当前版本是 `2026.3.3`
- 描述是 `Multi-channel AI gateway with extensible messaging integrations`
- 根项目使用 `pnpm workspace`
- 运行时要求是 Node.js `22.12+`

从 `pnpm-workspace.yaml` 可以看出，这个仓库本质上是一个 monorepo，主要包含：

- 根包 `.`：主 CLI 和主运行时
- `ui`：Web 控制台前端
- `packages/*`：兼容包或附属包
- `extensions/*`：扩展能力和插件式模块

一句话理解：

**OpenClaw = 一个本地/自托管运行的 AI Gateway + 多聊天渠道接入层 + Agent 运行层 + Web 控制台 + 移动/桌面节点能力。**

它不是只做聊天，也不是只做前端页面，而是在做“多渠道入口 + AI 调度 + 设备能力 + 自动化 + 扩展体系”。

## 2. 源码应该怎么读

如果你是小白，不建议一上来就钻进所有子目录。建议按下面顺序读。

### 第一层：先理解启动链路

最重要的几个文件：

- `openclaw.mjs`
- `src/entry.ts`
- `src/cli/run-main.ts`
- `src/cli/program.ts`

启动链路大致是：

1. 用户在命令行执行 `openclaw ...`
2. 先进入 `openclaw.mjs`
3. 这个文件检查 Node 版本、尝试加载构建产物 `dist/entry.js`
4. 真实入口在 `src/entry.ts`
5. `src/entry.ts` 最后会把流程交给 `src/cli/run-main.ts`
6. `run-main.ts` 负责解析参数、加载环境、组装 CLI 命令、再分发到具体子命令

所以，如果你想知道“这个项目怎么启动”，先看这 4 个文件就够了。

### 第二层：理解核心运行面

理解启动后，下一层应该看这些目录：

- `src/cli`
- `src/gateway`
- `src/agents`
- `src/channels`
- `src/providers`
- `src/web`
- `ui`

可以把它们理解成下面这张图：

```text
聊天渠道/设备/网页
        ↓
     Gateway
        ↓
   Agents / Sessions
        ↓
 Tools / Providers / Memory / Extensions
```

## 3. 顶层目录怎么理解

下面是仓库根目录里最值得关注的目录和它们的作用。

### `src/`

这是主 TypeScript 源码目录，也是最核心的业务逻辑所在地。

按文件数量看，当前最重的几个子模块大概是：

- `src/agents`：约 770 个文件
- `src/infra`：约 354 个文件
- `src/commands`：约 342 个文件
- `src/gateway`：约 332 个文件
- `src/cli`：约 284 个文件
- `src/auto-reply`：约 279 个文件
- `src/config`：约 221 个文件
- `src/channels`：约 163 个文件

这已经能说明项目重心：

- Agent 逻辑很多
- Gateway 非常重要
- CLI 是一等公民
- 配置、自动回复、渠道接入都不是边角功能

### `ui/`

这是 Web 控制台前端。  
`ui/package.json` 显示它使用：

- `vite`
- `lit`
- `vitest`
- `playwright`

所以前端不是 React，而是基于 Lit 的一套轻量 Web UI。  
`ui/src` 下还有：

- `i18n`
- `styles`
- `ui`

说明它不仅有页面，还考虑了国际化和样式分层。

### `apps/`

这里是原生应用相关代码，不是 Web 前端。

- `apps/android`：Android 客户端，Gradle/Kotlin 项目
- `apps/ios`：iOS 客户端，Xcode/Swift 相关
- `apps/macos`：macOS 应用
- `apps/shared`：共享代码，当前能看到 `OpenClawKit`

从各自的 `README.md` 可以看出：

- Android 还在“非常早期但在快速推进”
- iOS 被明确标注为 `Super Alpha`
- macOS 有比较清晰的打包和签名流程

这意味着 OpenClaw 不只是一个 CLI 工具，它在往“多端 AI 助手产品”方向走。

### `extensions/`

这里是扩展模块区，当前大约有 40 个扩展目录。  
从目录名就能看到很多能力是以扩展方式挂进来的，比如：

- `telegram`
- `slack`
- `discord`
- `feishu`
- `matrix`
- `whatsapp`
- `voice-call`
- `llm-task`
- `lobster`
- `memory-core`
- `memory-lancedb`

这说明项目架构上并不想把所有能力死写进主程序，而是保留“扩展式增长”的路线。

### `skills/`

这里是技能目录，当前大约有 52 个技能包。  
比如：

- `coding-agent`
- `github`
- `weather`
- `notion`
- `tmux`
- `voice-call`
- `openai-image-gen`

可以把它理解成“给 Agent 增加具体工作能力的说明/模板/工具包集合”。

### `docs/`

这是正式文档主目录，而且规模很大。  
按本地统计，`docs` 下的 Markdown/MDX/JSON 文档里：

- `zh-CN` 相关文档约 308 篇
- `cli` 约 46 篇
- `gateway` 约 33 篇
- `providers` 约 29 篇
- `channels` 约 29 篇
- `tools` 约 28 篇
- `platforms` 约 27 篇
- `concepts` 约 27 篇
- `reference` 约 25 篇
- `install` 约 20 篇

所以这个仓库并不是“代码多、文档少”，而是代码和文档都很多。

### `packages/`

当前主要能看到两个包：

- `packages/clawdbot`
- `packages/moltbot`

这两个包的 `package.json` 都写着：

- `Compatibility shim that forwards to openclaw`

也就是兼容旧名字的壳。  
再结合 `VISION.md` 里提到的演进路径：

`Warelay -> Clawdbot -> Moltbot -> OpenClaw`

可以推断这个仓库经历过品牌和产品命名演变，而 `clawdbot`、`moltbot` 这两个包是为兼容旧入口保留的。

### 其他值得知道的目录

- `test/`：测试夹具、集成测试、e2e 测试
- `scripts/`：脚本工具
- `assets/`：静态资源
- `vendor/`：第三方或外部依赖代码
- `.github/`：CI、工作流、社区模板
- `patches/`：依赖 patch

## 4. `src/` 里最关键的模块分别负责什么

如果你只想“看懂主干”，下面这几个目录优先级最高。

### `src/cli`

这是命令行系统。

从文件名能看到它覆盖面非常广：

- `gateway-cli.ts`
- `channels-cli.ts`
- `devices-cli.ts`
- `pairing-cli.ts`
- `models-cli.ts`
- `memory-cli.ts`
- `skills-cli.ts`
- `sandbox-cli.ts`
- `security-cli.ts`
- `tui-cli.ts`
- `docs-cli.ts`

这说明 OpenClaw 的 CLI 不是薄薄一层，而是项目的主要操作入口之一。

### `src/gateway`

这是整个系统的“控制平面”。

这个目录里能看到很多高频关键词：

- `server.ts`
- `server.impl.ts`
- `server-http.ts`
- `server-chat.ts`
- `server-cron.ts`
- `server-plugins.ts`
- `server-runtime-config.ts`
- `server-node-events.ts`
- `control-ui.ts`
- `openai-http.ts`
- `openresponses-http.ts`

从这些文件名可以判断 Gateway 负责：

- 对外提供 HTTP / WebSocket 服务
- 承接聊天消息
- 管理节点和设备事件
- 加载运行时配置
- 提供 Control UI
- 处理模型 API 兼容层
- 处理定时任务、插件和安全控制

如果你要搞清楚“OpenClaw 的总枢纽在哪里”，答案就是 `src/gateway`。

### `src/agents`

这是 AI Agent 真正干活的地方，也是当前代码量最大的模块。

从近期提交和文件名能看到它处理的事情包括：

- 模型目录和模型兼容
- 工具调用
- 子代理 `subagents`
- 压缩/整理上下文 `compaction`
- 认证和 OAuth
- 会话工具结果保护
- Pi embedded runner

通俗一点说：

`src/gateway` 更像“总线和调度中心”，  
`src/agents` 更像“AI 大脑和执行逻辑”。

### `src/channels`

这是多聊天渠道抽象层。  
从目录和文件名能看出它在处理：

- allowlist / 权限控制
- command gating
- mention gating
- typing 状态
- session 绑定
- sender identity
- transport / telegram / web

如果你关注“怎么接 Telegram、Slack、Discord、WhatsApp 这类渠道”，这里是主入口之一。

### `src/providers`

这里处理模型提供商相关逻辑。  
当前看到的文件包括：

- `github-copilot-auth.ts`
- `github-copilot-models.ts`
- `qwen-portal-oauth.ts`
- 若干 `google-shared` 相关文件

虽然目录看上去不如 `agents` 和 `gateway` 大，但它对“支持哪些模型、怎么认证、怎么适配”很关键。

### `src/web`

这是 Web 侧能力，不等于 `ui/` 前端本身。  
可以理解为：

- `src/web` 偏后端/网关侧的 Web 能力
- `ui/` 偏浏览器里的控制台前端

## 5. 给小白的实际阅读路线

如果你不是来做全量二开，而只是想快速看懂项目，建议按这个顺序。

### 路线 A：想知道“怎么启动”

看：

1. `openclaw.mjs`
2. `src/entry.ts`
3. `src/cli/run-main.ts`
4. `src/cli/program.ts`

### 路线 B：想知道“消息怎么进来又怎么出去”

看：

1. `src/channels`
2. `src/gateway/server-chat.ts`
3. `src/sessions`
4. `src/agents`

### 路线 C：想知道“网页控制台怎么工作的”

看：

1. `src/gateway/control-ui.ts`
2. `src/gateway/server-http.ts`
3. `ui/package.json`
4. `ui/src`

### 路线 D：想知道“手机/桌面端怎么接进来”

看：

1. `apps/android/README.md`
2. `apps/ios/README.md`
3. `apps/macos/README.md`
4. `docs/platforms/*`
5. `docs/nodes/*`

### 路线 E：想知道“怎么扩展能力”

看：

1. `extensions/`
2. `skills/`
3. `src/plugin-sdk`
4. `docs/tools/plugin.md`
5. `docs/tools/skills.md`

## 6. 仓库里有哪些文档，分别讲什么

OpenClaw 的文档体系是比较完整的，不只是一个 `README.md`。

## 6.1 根目录的核心文档

根目录最关键的 Markdown 文档有：

- `README.md`
- `CHANGELOG.md`
- `CONTRIBUTING.md`
- `SECURITY.md`
- `VISION.md`
- `docs.acp.md`
- `AGENTS.md`

它们各自作用如下。

### `README.md`

这是项目门面，也是总入口。

里面主要包含：

- 项目定位：个人 AI 助手 / 多渠道 AI Gateway
- 支持的聊天渠道和平台
- 安装方式
- 快速启动命令
- 从源码构建的方法
- 安全默认值说明
- 功能总览
- 系统结构图

如果你只允许自己先读一篇文档，就先读它。

### `CHANGELOG.md`

这是超大的变更日志文件，本地大小约 600KB。  
它适合做两件事：

- 看项目最近在密集修什么
- 看版本演进的节奏

缺点是信息量太大，不适合第一次入门直接通读。

### `CONTRIBUTING.md`

这是贡献指南。  
里面不仅讲提 PR 流程，还直接写了维护者和各自关注模块，比如：

- Telegram
- iOS
- TUI
- Security
- Agents
- Web UI

对理解“谁在维护什么”很有帮助。

### `SECURITY.md`

这是安全说明。  
因为 OpenClaw 会连接真实聊天渠道、设备权限、API 凭据，所以安全不是装饰文档，而是核心文档。

### `VISION.md`

这是方向文档。  
它比 README 更像“产品和架构理念说明”，里面很关键的点包括：

- 项目想做的是“真正能做事的 AI”
- 强调运行在用户自己的设备和规则下
- 优先级是安全、稳定、首次配置体验
- 明确说了名字演进：`Warelay -> Clawdbot -> Moltbot -> OpenClaw`

### `docs.acp.md`

这是 ACP 相关说明，偏协议/能力层，不是入门第一优先，但对深入理解代理通信有帮助。

### `AGENTS.md`

这是给 agent/自动化协作使用的仓库说明，不是普通用户入门文档，但对理解项目协作规范很有价值。

## 6.2 `docs/` 里的正式文档体系

从 `docs/index.md` 和 `docs/start/docs-directory.md` 可以看出，官方文档体系大致分成下面几类。

### `start/`

适合第一次接触项目的人。

常见内容：

- getting started
- quickstart
- wizard
- onboarding
- docs-directory
- hubs

如果你是新手，应该从这里开始。

### `install/`

安装和部署文档。

能看到的主题包括：

- node
- bun
- docker
- nix
- ansible
- fly
- gcp
- hetzner
- render
- railway
- updating
- uninstall

这说明 OpenClaw 很强调“不同部署路径”的支持。

### `gateway/`

这是理解系统核心的文档区。

主题包括：

- configuration
- authentication
- discovery
- health
- doctor
- protocol
- remote
- sandboxing
- tailscale
- tools-invoke-http-api

如果你在看源码时总搞不清“Gateway 到底承担什么职责”，先配套读这里。

### `channels/`

每种聊天渠道基本都有独立文档。  
比如：

- whatsapp
- telegram
- discord
- slack
- signal
- imessage
- matrix
- mattermost
- feishu
- line
- twitch
- zalo

这个文档区能帮助你从“代码目录名”映射到“实际产品能力”。

### `platforms/`

这是平台端文档，包括：

- macOS
- iOS
- Android
- Linux
- Windows
- Raspberry Pi

如果你要理解 `apps/` 目录，这个文档区很有用。

### `tools/`

这里讲 Agent 可调用的工具和能力，包括：

- browser
- exec
- skills
- subagents
- plugin
- slash commands
- apply-patch
- firecrawl
- clawhub

如果你想知道“OpenClaw 不是只聊天，它还能干嘛”，这里非常关键。

### `concepts/`

这是概念文档区，更偏架构和运行机制。

比如：

- architecture
- agent
- agent-loop
- memory
- session
- streaming
- retry
- model-providers
- model-failover
- typing-indicators

小白如果直接硬啃源码容易晕，这里可以先补概念。

### `cli/`

CLI 子命令文档非常细，基本每个重要命令都有页面。  
比如：

- `openclaw gateway`
- `openclaw agent`
- `openclaw config`
- `openclaw channels`
- `openclaw docs`
- `openclaw sandbox`
- `openclaw skills`

### `reference/`

偏参考资料和模板。

比如：

- test
- token-use
- rpc
- RELEASING
- templates/*

### `automation/`

自动化相关文档，包括：

- cron jobs
- webhook
- hooks
- gmail pubsub
- troubleshooting

### `providers/`

模型和服务提供商文档。  
当前能看到的提供商文档包括：

- openai
- anthropic
- bedrock
- github-copilot
- ollama
- qwen
- moonshot
- minimax
- glm
- openrouter

### `zh-CN/`

这是中文文档区，而且体量非常大。  
这说明官方确实在维护一套比较系统的中文文档，而不是零散翻译几个页面。

## 6.3 仓库里还有哪些 README

除了主文档体系，仓库里还能看到一些局部 README：

- `apps/android/README.md`
- `apps/ios/README.md`
- `apps/macos/README.md`
- `extensions/*/README.md`
- `scripts/shell-helpers/README.md`
- `assets/chrome-extension/README.md`
- `Swabble/README.md`

这些文档通常更适合“局部开发”场景，比如你只关心 Android，或者只关心某个扩展。

## 7. 从源码反推 OpenClaw 的总体架构

如果不看宣传语，只看目录和文件，大致可以反推出下面这个结构。

### 7.1 控制核心：Gateway

Gateway 是总枢纽，至少负责：

- 接受 CLI / Web / 节点连接
- 承接聊天消息流
- 管理会话
- 调用 Agent
- 暴露 HTTP / WS 能力
- 托管 Control UI
- 管理插件、工具、cron、认证和运行时配置

所以它不是“一个小服务”，而是整个系统的控制平面。

### 7.2 智能核心：Agents

Agent 层负责：

- 选模型
- 组织上下文
- 管理工具调用
- 进行多代理协作
- 处理模型兼容和 fallback
- 处理输出压缩和结果回写

这也是为什么 `src/agents` 的文件量最大。

### 7.3 入口层：Channels + Apps + Web

OpenClaw 不想把自己绑定在一个渠道上，而是要做到：

- WhatsApp 来消息也能进
- Telegram 来消息也能进
- Discord/Slack/Signal/Feishu 等也能进
- 浏览器控制台也能进
- iOS/Android/macOS 节点也能进

所以“入口统一、后端统一、Agent 统一”是它的重要设计思路。

### 7.4 扩展层：Extensions + Skills + Plugin SDK

从目录结构上看，OpenClaw 明显在追求一种“主干稳定、能力外扩”的模式。

- `extensions/`：更像程序级扩展
- `skills/`：更像 Agent 能力包
- `src/plugin-sdk`：开发扩展和插件的接口层

## 8. Git 提交历史概览

下面这部分是基于本地 Git 仓库直接统计出来的，不是凭感觉写的。

### 基本数据

- 当前分支：`main`
- 当前最新提交日期：`2026-03-06`
- 本地 `HEAD` 提交：`0e2bc588c`
- 仓库最早提交日期：`2025-11-24`
- 当前提交总数：`17011`
- 当前标签总数：`70`

这个数字很夸张。  
一个从 2025-11-24 到 2026-03-06 的仓库，已经积累了 17011 个提交，说明它的开发节奏极快。

## 8.1 版本标签透露出的演进

最早一批标签可以看到：

- `v0.1.0`
- `v0.1.1`
- `v0.1.2`
- `v0.1.3`
- `v1.0.4`
- `v1.1.0`
- `v1.2.0`

较新的标签变成了日期风格：

- `v2026.2.23`
- `v2026.2.24-beta.1`
- `v2026.2.24`
- `v2026.2.25`
- `v2026.2.26`
- `v2026.3.1`
- `v2026.3.2`

这说明项目从“传统语义版本号风格”逐渐切到了“日期版本号风格”。  
这通常意味着团队进入了更高频率、接近日更的发布模式。

## 8.2 提交时间分布

按月份统计，近几个月的提交量大致是：

- `2025-11`：288
- `2025-12`：2151
- `2026-01`：6117
- `2026-02`：6995
- `2026-03`：1460（截至 2026-03-06）

这个分布很能说明问题：

1. `2025-11` 更像启动期
2. `2025-12` 开始明显加速
3. `2026-01` 和 `2026-02` 进入爆发式开发阶段
4. `2026-03` 前 6 天就已经有 1460 个提交，节奏依旧很猛

如果按每天看，仓库创建当天 `2025-11-24` 就有 54 个提交，第二天 `2025-11-25` 有 148 个提交。  
这不是“慢慢养成型项目”，而是明显的高密度迭代仓库。

## 8.3 主要贡献者

按提交数粗看，当前最靠前的贡献者包括：

- Peter Steinberger：11341
- Vignesh Natarajan：363
- Ayaan Zaidi：288
- Vincent Koc：247
- Gustavo Madeira Santana：229
- Shadow：190
- cpojer：156

从这个数据可以看出两个明显特征：

1. **项目有非常强的核心作者主导特征**  
   Peter Steinberger 的提交数远高于其他人，说明项目最主要的设计和推进很大概率由他主导。

2. **项目不是单人仓库**  
   后面已经有一批持续贡献者分布在 Telegram、iOS、UI、Security、Agents、CLI 等不同方向。

这和 `CONTRIBUTING.md` 里列出的维护者分工是对应得上的。

## 8.4 最近阶段的提交主题

对 `2026-02-20` 之后的提交标题做粗分类，出现频率最高的是：

- `fix`：1624
- `test`：787
- `refactor`：457
- `docs`：300
- `feat`：152
- `chore`：115
- `perf`：63

这个比例很有意思，说明最近阶段的开发重点不是疯狂加新功能，而是：

- 修 bug
- 补测试
- 做重构
- 补文档

也就是说，项目已经不是“纯原型期”，而是在快速走向稳定化和工程化。

## 8.5 最近几天提交透露出的方向

从最近提交可以看到一些典型主题：

- `fix(gateway): support image_url in OpenAI chat completions`
- `fix(agents): disable usage streaming chunks on non-native openai-completions`
- `feat(openai): add gpt-5.4 support for API and Codex OAuth`
- `fix(agents): avoid xAI web_search tool-name collisions`
- `fix: clear Telegram DM draft after materialize`
- `Fix Control UI duplicate iMessage replies for internal webchat turns`

这些提交说明当前项目在并行推进几件事：

- 跟上新的模型和 provider 能力
- 修复网关与 Agent 之间的兼容问题
- 稳定实际聊天渠道的行为
- 持续修前端控制台问题

如果只看最近一段改动，`src/agents`、`src/gateway`、`ui` 的活跃度非常高。

## 9. 我对这份 Git 历史的分析

### 9.1 这是一个“高速演进中的产品型仓库”

从目录结构和提交节奏看，OpenClaw 更像一个在快速推产品边界的仓库，而不是只做学术实验或 demo。

理由有：

- 渠道很多
- 平台很多
- 文档很多
- 测试很多
- 发布标签密集
- 最近提交大量集中在修复和稳定

### 9.2 架构正在“平台化”

目录里同时出现：

- Gateway
- Agents
- Channels
- Skills
- Extensions
- Apps
- Plugin SDK

这说明它已经不是“写几个脚本接模型 API”的阶段，而是在做一个平台。

### 9.3 兼容历史包说明项目还在照顾迁移成本

`packages/clawdbot` 和 `packages/moltbot` 的存在，说明项目虽然已经统一到 OpenClaw，但仍在照顾历史用户入口。  
这类兼容层通常出现在产品开始扩圈、名字升级、但又不能粗暴切断旧生态的时候。

### 9.4 当前阶段非常强调稳定性

最近提交里 `fix/test/refactor/docs` 占比很高，说明团队当前不是只图“功能表演”，而是在解决：

- 兼容性
- 可靠性
- 安全默认值
- 文档覆盖
- 运维和配置体验

这一点和 `VISION.md` 里的优先级基本一致。

## 10. 对小白最有用的几个判断

### 判断 1：先把它当成“AI Gateway 平台”，不要当成“聊天机器人脚本”

如果你把它理解成一个简单 bot，你会觉得目录太大、太乱。  
如果你把它理解成“一个多端 AI Gateway 平台”，这些目录就顺了。

### 判断 2：先读入口和文档，再读细节模块

强烈建议先读：

1. `README.md`
2. `VISION.md`
3. `docs/start/getting-started.md`
4. `docs/start/docs-directory.md`
5. `openclaw.mjs`
6. `src/entry.ts`
7. `src/cli/run-main.ts`

这样你才知道后面在看什么。

### 判断 3：最核心的不是前端，而是 Gateway + Agents

虽然仓库里有 `ui/`，也有 iOS/Android/macOS，但真正的核心还是：

- `src/gateway`
- `src/agents`
- `src/cli`

### 判断 4：如果你只想定制某一个渠道，不一定要读完整仓库

比如你只想改 Telegram、Feishu、WhatsApp，那么可以先读：

- `docs/channels/<渠道名>.md`
- `src/channels`
- 对应 `extensions/<渠道名>` 或相关实现目录

### 判断 5：这个项目变化非常快

因为提交量和版本节奏都很高，所以你看教程、查 issue、改代码时，要优先相信：

- 当前源码
- 当前 `README.md`
- 当前 `docs/`
- 当前 `CHANGELOG.md`

不要太相信几个月前的二手博客。

## 11. 一个适合小白的阅读顺序

如果你现在就要开始看，我建议按下面顺序走：

1. 读 `README.md`，知道项目定位和安装/运行方式
2. 读 `VISION.md`，知道它为什么这样设计
3. 读 `docs/start/getting-started.md` 和 `docs/start/docs-directory.md`
4. 看 `openclaw.mjs` 和 `src/entry.ts`
5. 看 `src/cli/run-main.ts`
6. 看 `src/gateway`
7. 看 `src/agents`
8. 再根据你的兴趣分叉到 `ui/`、`apps/`、`extensions/`、`skills/`

## 12. 最后的总结

OpenClaw 这个仓库的特点，可以概括成 6 句话：

1. 它不是单一程序，而是一个大型 monorepo。
2. 核心主干是 `CLI + Gateway + Agents`。
3. 它把多聊天渠道、多端设备和 AI 能力统一到同一个控制平面里。
4. 仓库文档很多，而且中文文档并不少。
5. Git 历史显示它迭代极快，最近明显在走稳定化和工程化。
6. 如果你是小白，最正确的打开方式不是乱翻目录，而是先读入口、再读文档、最后按场景看模块。

---

## 附：这份分析使用到的本地仓库事实

- 仓库路径：`D:\code\anzhuang\openclaw`
- 当前分支：`main`
- 提交总数：`17011`
- 最早提交日期：`2025-11-24`
- 最新提交日期：`2026-03-06`
- 标签数：`70`
- `docs/` 中文文档区：约 `308` 篇
- `extensions/` 目录数：约 `40`
- `skills/` 目录数：约 `52`

如果你后面要，我还可以继续在这个基础上给你补两种文档：

- “只讲运行链路”的源码导读版
- “只讲二次开发入口”的改造指南版
