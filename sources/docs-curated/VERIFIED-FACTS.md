# OpenClaw 源码与官网核验清单

这份清单只记录“容易写错、容易过时、必须核验”的事实。

核验基线：

- 官方 GitHub 仓库：`https://github.com/openclaw/openclaw`
- 本地源码快照：`sources/official/openclaw`
- 当前克隆提交：`bfc36cc`
- 官网：`https://openclaw.ai`
- 官方文档站：`https://docs.openclaw.ai`

## 1. Windows 的官方推荐路线是 WSL2，不是原生 Windows

结论：

- 官方文档明确写的是“Windows 推荐通过 WSL2 使用 OpenClaw”。
- 原生 Windows 不是官方主推荐路径，更多属于“能做，但更容易踩坑”。

依据：

- [官方 README（本地源码）](../official/openclaw/README.md)
- [官方 Windows 文档（本地英文）](../official/openclaw/docs/platforms/windows.md)
- [官方 Windows 文档（本地中文）](../official/openclaw/docs/zh-CN/platforms/windows.md)
- [官网 Windows 页](https://docs.openclaw.ai/platforms/windows)

对当前根目录文档的影响：

- 所有“Windows 原生安装”类文档都应视为经验补充，不应取代官方默认路线。

## 2. 当前官方源码要求的 Node 版本是 `>=22.12.0`

结论：

- “Node 22+”是官网对外说法。
- 更精确的源码约束是 `>=22.12.0`。

依据：

- `sources/official/openclaw/package.json:414`
- [官方入门指南（本地英文）](../official/openclaw/docs/start/getting-started.md)
- [官方入门指南（本地中文）](../official/openclaw/docs/zh-CN/start/getting-started.md)

对当前根目录文档的影响：

- 只写“Node 22+”基本不算错，但如果要写得严谨，应该写 `>=22.12.0`。

## 3. Windows 安装脚本 `install.ps1` 默认走 npm，也支持 git 安装

结论：

- `install.ps1` 的默认 `InstallMethod` 是 `npm`。
- 可以显式传 `-InstallMethod git`。

依据：

- `sources/official/openclaw/scripts/install.ps1:5-11`
- [官方安装器说明（本地英文）](../official/openclaw/docs/install/installer.md)
- [官方安装器说明（本地中文）](../official/openclaw/docs/zh-CN/install/installer.md)
- [官网安装器说明页](https://docs.openclaw.ai/install/installer)

对当前根目录文档的影响：

- 看到“Windows 只能全局 npm 安装”的说法时，要知道那只是默认方式，不是唯一方式。

## 4. 官方推荐的新手主命令是 `openclaw onboard --install-daemon`

结论：

- 安装完之后，官方推荐用 onboarding wizard 完成认证、Gateway、渠道和可选后台服务。

依据：

- [官方 README（本地源码）](../official/openclaw/README.md)
- [官方入门指南（本地英文）](../official/openclaw/docs/start/getting-started.md)
- [官方 onboard 命令文档（本地英文）](../official/openclaw/docs/cli/onboard.md)
- [官方 onboard 命令文档（本地中文）](../official/openclaw/docs/zh-CN/cli/onboard.md)
- [官网 onboard 参考页](https://docs.openclaw.ai/cli/onboard)

## 5. 最快的第一条聊天路径确实是 `openclaw dashboard`

结论：

- 官网入门页明确把 Dashboard / Control UI 当作最快的首聊路径。
- 源码里 `dashboardCommand(...)` 会根据配置拼出 Control UI 链接。

依据：

- [官方入门指南（本地英文）](../official/openclaw/docs/start/getting-started.md)
- [官方 dashboard 命令文档（本地英文）](../official/openclaw/docs/cli/dashboard.md)
- [官方 dashboard 命令文档（本地中文）](../official/openclaw/docs/zh-CN/cli/dashboard.md)
- `sources/official/openclaw/src/commands/dashboard.ts:83-139`

## 6. Gateway 默认本地地址仍然是 `127.0.0.1:18789`

结论：

- 默认端口仍是 `18789`。
- Dashboard 的默认本地地址仍然是 `http://127.0.0.1:18789/`。
- Gateway 与 Control UI 共用这一端口。

依据：

- [官方架构文档（本地英文）](../official/openclaw/docs/concepts/architecture.md)
- [官方入门指南（本地英文）](../official/openclaw/docs/start/getting-started.md)
- `sources/official/openclaw/src/commands/dashboard.ts:89-109`
- `sources/official/openclaw/src/gateway/server.impl.ts:265-267`
- `sources/official/openclaw/src/gateway/client.ts:112`
- [官网架构页](https://docs.openclaw.ai/concepts/architecture)

## 7. 架构上是“一个长期运行的 Gateway + WebSocket 控制面”

结论：

- OpenClaw 的关键不是某个单独 CLI 命令，而是一个长期运行的 Gateway。
- 控制面客户端和节点都通过 WebSocket 接入这个 Gateway。
- 官方文档明确强调“通常一台主机一个 Gateway”。

依据：

- [官方架构文档（本地英文）](../official/openclaw/docs/concepts/architecture.md)
- [官方架构文档（本地中文）](../official/openclaw/docs/zh-CN/concepts/architecture.md)
- [官网架构页](https://docs.openclaw.ai/concepts/architecture)

## 8. 当前嵌入式 Agent 主链路可以在源码里直接验证

结论：

- 当前版本下，可以把 Agent 的主要调用路径整理为：
  `agentCommand` -> `runEmbeddedPiAgent` -> `createAgentSession` -> `subscribeEmbeddedPiSession` -> `waitForAgentJob`

依据：

- `sources/official/openclaw/src/commands/agent.ts:1033-1063`
- `sources/official/openclaw/src/agents/pi-embedded-runner/run.ts:253-325`
- `sources/official/openclaw/src/agents/pi-embedded-runner/run/attempt.ts:1173-1189`
- `sources/official/openclaw/src/agents/pi-embedded-runner/run/attempt.ts:1505-1529`
- `sources/official/openclaw/src/gateway/server-methods/agent-job.ts:144-195`

说明：

- 根目录里已有多篇“源码分析”文档提到类似链路，但旧文档中的具体行号未必仍与当前官方仓库一致。
- 这次整合以后，概念可以继续沿用，精确定位以当前源码为准。

## 9. Tool 装配和 `before_tool_call` Hook 也能在源码中确认

结论：

- OpenClaw 的工具集合不是纯文档概念，源码里存在明确的工具装配入口。
- `before_tool_call` 插件 Hook 也是真实存在的能力，不是分析文档的想象层。

依据：

- `sources/official/openclaw/src/agents/pi-tools.ts:197-255`
- `sources/official/openclaw/src/agents/pi-tools.before-tool-call.ts:150-193`

## 10. 文档冲突时的优先级

建议你以后统一按这个顺序判断：

1. 官网当前页面
2. 官方仓库当前源码和官方文档源码
3. 根目录里的中文整理解读文档

如果是下面这些主题，务必优先查 1 和 2：

- 安装方式
- Node 版本
- Windows/WSL2 支持状态
- CLI 命令名和参数
- 默认端口、默认路径、默认安全策略

## 官网入口

- [OpenClaw 官网](https://openclaw.ai)
- [官方文档首页](https://docs.openclaw.ai)
- [Getting Started](https://docs.openclaw.ai/start/getting-started)
- [Windows (WSL2)](https://docs.openclaw.ai/platforms/windows)
- [Architecture](https://docs.openclaw.ai/concepts/architecture)
- [CLI Reference](https://docs.openclaw.ai/cli)

