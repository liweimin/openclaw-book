# 03. 配置、常用命令与日常排错

这一章解决 3 个问题：

- 配置文件在哪
- 最常用命令有哪些
- 出问题时先查什么

## 1. 配置文件在哪里

OpenClaw 默认配置文件是：

```text
~/.openclaw/openclaw.json
```

它使用的是 JSON5。

也就是说你可以写：

- 注释
- 尾逗号

这对小白比纯 JSON 友好一点。

## 2. 配置的基本原则

### 原则 1：先让它能跑，再谈“配得漂亮”

第一次不要追求“所有渠道、所有规则、所有 Agent 都配好”。

先保证：

- 能启动
- 能聊天
- 能做基础健康检查

### 原则 2：OpenClaw 配置是严格校验的

这点很重要。

OpenClaw 不是“多写几个错键也凑合运行”的风格。

如果配置：

- 键名错了
- 类型错了
- 值不合法

Gateway 可能直接拒绝启动。

所以一旦你手改配置后出问题，第一时间看：

```bash
openclaw doctor
```

## 3. 一个足够小白的最小配置示例

```json5
{
  agents: {
    defaults: {
      workspace: "~/.openclaw/workspace",
    },
  },
}
```

这个例子表达的意思很简单：

- 给默认 Agent 指定一个工作目录

如果你还没明确知道自己要改什么，不要一开始写一大坨配置。

## 4. 小白最该先记住的命令

下面这些命令已经够你完成 80% 的入门阶段工作。

### 安装与初始化

```bash
openclaw onboard --install-daemon
openclaw configure
```

### 查看状态

```bash
openclaw status
openclaw status --all
openclaw health
openclaw gateway status
```

### 打开界面

```bash
openclaw dashboard
```

### 直接让 Agent 做事

```bash
openclaw agent --message "帮我整理今天待办"
```

### 配置项读写

```bash
openclaw config get agents.defaults.workspace
openclaw config set agents.defaults.workspace "~/.openclaw/workspace"
openclaw config unset agents.defaults.workspace
```

### 调试与排错

```bash
openclaw doctor
openclaw logs
```

### 渠道相关

```bash
openclaw channels list
openclaw channels status
openclaw channels login
```

### 配对相关

```bash
openclaw pairing list whatsapp
openclaw pairing approve whatsapp <code>
```

## 5. 这些命令你现在可以怎么理解

### `onboard`

第一次安装后的总入口。

### `configure`

更偏“补配置、改配置、走交互式流程”。

### `dashboard`

最快验证界面和可用性的方式。

### `status` / `health`

告诉你它是不是活着，是不是健康。

### `doctor`

你不确定问题在哪时，先跑它。

### `agent`

你直接让 AI 干活的入口。

### `channels`

用来查看和管理 WhatsApp、Telegram、Discord、Feishu 等消息渠道。

## 6. 日常最实用的排错顺序

如果今天突然“不工作了”，按这个顺序查：

1. `openclaw gateway status`
2. `openclaw status`
3. `openclaw health`
4. `openclaw doctor`
5. `openclaw logs`

如果这 5 步都还看不出来，再去看更细的渠道或模型认证问题。

## 7. 最常见的配置误区

### 误区 1：把配置文件当成“越全越好”

不是。

配置越多，出错面越大。

### 误区 2：一开始就多 Agent、多渠道、多策略并存

更合理的是：

- 先一个默认 Agent
- 先一个默认 workspace
- 先一个能用的认证方式
- 先跑 Dashboard

### 误区 3：改完配置不做健康检查

只要你手改过配置，建议立刻跑：

```bash
openclaw doctor
openclaw status
```

## 8. Tools、Skills、Memory 先怎么理解

### Tools

Tools 是 OpenClaw 的“手和脚”。

比如：

- 读写文件
- 执行命令
- 浏览器操作
- 调消息渠道

### Skills

Skills 更像“预先写好的能力说明书”或“操作套路包”。

它不是模型本身，而是给 Agent 的可复用工作方式。

### Memory

Memory 是“长期记住什么”的机制，不是普通上下文窗口本身。

小白阶段先知道它存在就行，不需要一开始就深挖。

## 9. 每天都能用的最小工作流

如果你已经装好了，日常其实可以很简单：

1. `openclaw gateway status`
2. `openclaw dashboard`
3. 开始聊天或下任务
4. 有问题就 `openclaw doctor`
5. 看不懂就 `openclaw logs`

## 10. 什么时候再去学复杂配置

只有在你真的碰到下面这些需求时，再深入研究：

- 想接多个渠道
- 想做多 Agent 路由
- 想做更细的权限和安全策略
- 想接 Nodes、Browser、Automation
- 想让不同人或不同群走不同工作区

## 这一章看完后，你该做什么

继续看：

- [04-how-it-works-and-what-next.md](04-how-it-works-and-what-next.md)

## 核验依据

- 官方配置文档：`research/openclaw/docs/zh-CN/gateway/configuration.md`
- 官方 CLI 文档：`research/openclaw/docs/zh-CN/cli/index.md`
- 已核验源码位置：
  - `research/openclaw/src/commands/dashboard.ts`
  - `research/openclaw/src/gateway/server.impl.ts`
