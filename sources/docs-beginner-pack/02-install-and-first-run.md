# 02. 安装与第一次跑通

这份文档只回答一个问题：

怎么用最少步骤，把 OpenClaw 真正跑起来。

## 第一步：先选安装路线

### 路线 A：Windows 用户的官方推荐路线

如果你在 Windows 上，官方推荐是：

- 先装 WSL2
- 再在 WSL2 里的 Linux 环境运行 OpenClaw

这是官方主路线，不是可选附属说明。

原因很简单：

- 运行时更稳定
- Linux 工具兼容性更好
- Skills、Node、pnpm、二进制依赖更不容易出怪问题

### 路线 B：原生 Windows

原生 Windows 可以尝试，但你要知道它不是官方推荐主路线。

更准确的说法是：

- 能装
- 能跑
- 但更容易遇到编码、子进程、依赖、脚本兼容问题

如果你只是想“尽快学会 OpenClaw”，优先 WSL2。

## 第二步：确认前置条件

当前官方源码要求：

- Node `>=22.12.0`

你可以先检查：

```bash
node --version
```

如果你是从源码构建，还建议有：

- `pnpm`

## 第三步：安装 OpenClaw

### macOS / Linux / WSL2

官方推荐安装方式：

```bash
curl -fsSL https://openclaw.ai/install.sh | bash
```

### Windows PowerShell

官方安装脚本：

```powershell
iwr -useb https://openclaw.ai/install.ps1 | iex
```

这个 `install.ps1` 默认用 npm 安装，也支持 git 安装。

### 直接全局安装

如果你已经有合适的 Node 环境，也可以：

```bash
npm install -g openclaw@latest
```

或：

```bash
pnpm add -g openclaw@latest
```

## 第四步：运行 onboarding 向导

真正的主命令是：

```bash
openclaw onboard --install-daemon
```

这是小白阶段最关键的一步。

它会帮你处理：

- 模型认证
- Gateway 基础设置
- 是否安装后台服务
- 工作区初始化
- 可选渠道配置
- Skills 初始设置

如果你不知道怎么选，就用向导默认推荐项。

## 第五步：检查 Gateway 是否已经跑起来

```bash
openclaw gateway status
```

如果正常，你已经有了“可用的中枢”。

如果你想前台看日志运行：

```bash
openclaw gateway --port 18789 --verbose
```

## 第六步：先用 Dashboard 验证，不要先配复杂渠道

第一次最推荐：

```bash
openclaw dashboard
```

然后在浏览器打开：

```text
http://127.0.0.1:18789/
```

为什么先这样做：

- 最快
- 最少变量
- 出问题最容易定位

如果 Dashboard 能打开并能聊天，你的 OpenClaw 已经基本跑通。

## 第七步：做最小健康检查

第一次建议至少跑这几条：

```bash
openclaw status
openclaw health
openclaw doctor
```

如果你已经前台跑着 Gateway，再看：

```bash
openclaw logs
```

## 第八步：什么时候再去接 WhatsApp / Telegram / 飞书

只有在下面这 3 件事都成立之后，再去加渠道：

1. `openclaw gateway status` 正常
2. `openclaw dashboard` 能打开
3. 你已经能在本地确认一次基本对话

否则你会把“安装问题、Gateway 问题、渠道问题、模型认证问题”全混在一起。

## 一条最合理的小白路径

建议严格按这个顺序：

1. 安装 CLI
2. 跑 `openclaw onboard --install-daemon`
3. 跑 `openclaw gateway status`
4. 跑 `openclaw dashboard`
5. 跑 `openclaw status` 和 `openclaw health`
6. 本地聊通一次
7. 再接渠道

## 常见误区

### 误区 1：一上来就原生 Windows + 大量插件

这样最容易把环境问题放大。

### 误区 2：一上来就手改大段配置

小白最开始应该优先相信 onboarding，而不是自己堆配置。

### 误区 3：只看“安装成功”，不看“第一次可用聊天”

真正的成功标准不是装上命令，而是你能：

- 打开 Dashboard
- 和它完成一次对话

### 误区 4：还没跑通本地，就先折腾远程访问

本地都没通时，不要加 SSH 隧道、Tailscale、反向代理这些额外变量。

## 如果你坚持原生 Windows

可以参考根目录这些经验文档，但请记住它们不是官方默认路线：

- `README.md`
- `openclaw-windows-native-install.md`
- `OpenClaw-小白部署安装指南-Windows版.md`
- `OpenClaw-配置实战完整手册-Windows版.md`

更稳妥的用法是：

- 先按官方 WSL2 路线理解正确流程
- 再把这些原生 Windows 文档当“额外经验补丁”

## 这一章看完后，你该做什么

继续看：

- [03-config-and-common-commands.md](03-config-and-common-commands.md)

## 核验依据

- 官方安装器文档：`sources/official/openclaw/docs/install/installer.md`
- 官方入门文档：`sources/official/openclaw/docs/zh-CN/start/getting-started.md`
- 官方 Windows 文档：`sources/official/openclaw/docs/platforms/windows.md`
- 安装脚本：`sources/official/openclaw/scripts/install.ps1`
- 源码与配置：
  - `sources/official/openclaw/package.json`
  - `sources/official/openclaw/src/commands/dashboard.ts`
  - `sources/official/openclaw/src/gateway/server.impl.ts`

