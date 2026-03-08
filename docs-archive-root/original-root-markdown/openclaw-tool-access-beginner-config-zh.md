# OpenClaw Tool Access 小白配置说明（基于你当前安装状态）

## 1. 你截图里每一块是什么意思

你当前截图里的关键信息是：

- `Profile: messaging`
- `Source: global default`
- `5/38 enabled`

这三行可以直译成：

1. 现在这个 agent 的基础工具策略是 `messaging`。
2. 这个策略来源于“全局默认配置”，不是这个 agent 自己单独改的。
3. 当前运行时可见工具一共 38 个，其中 5 个是开启状态。

在源码里，页面就是这样计算的：

- `profile = agentTools.profile ?? globalTools.profile ?? "full"`：先看 agent 自己，再看全局，最后才是默认 `full`。
- `profileSource` 会显示 `agent override` / `global default` / `default`。
- `enabledCount/toolIds.length` 就是你看到的 `5/38`。

对应代码：

- `D:/code/cod/openclaw/ui/src/ui/views/agents-panels-tools-skills.ts`（约第 37-42, 79, 129-133 行）

## 2. 你刚安装就是这个配置，是否正常？

是正常的，而且是“刻意的安全默认值”。

### 2.1 源码证据：本地 onboarding 默认就是 `messaging`

OpenClaw 在本地首次引导时写入：

- `ONBOARDING_DEFAULT_TOOLS_PROFILE = "messaging"`
- 如果你没手动设过 `tools.profile`，就会写 `messaging`

对应代码：

- `D:/code/cod/openclaw/src/commands/onboard-config.ts`（第 6, 31 行）
- `D:/code/cod/openclaw/src/commands/onboard-config.test.ts`（第 17 行验证）

### 2.2 你的本机配置证据

你机器当前配置文件里确实是：

```json
"tools": {
  "profile": "messaging"
}
```

对应文件：

- `C:/Users/Yuca/.openclaw/openclaw.json`（第 31-33 行）

而且你的备份配置也都是 `messaging`（说明安装后一直是这个策略）。

### 2.3 你的日志证据

配置审计日志显示在 2026-03-05 发生过 `onboard` 写配置事件（`argv` 里就是 `openclaw ... onboard`）：

- `C:/Users/Yuca/.openclaw/logs/config-audit.jsonl`（第 1-3 行）

所以结论：这是安装引导默认行为，不是异常。

## 3. `Minimal / Coding / Messaging / Full` 到底差别在哪

OpenClaw 内置四个 profile：

- `minimal`：只开 `session_status`
- `coding`：文件/运行时/会话/内存/图片相关
- `messaging`：`message + sessions_list/history/send + session_status`
- `full`：不做基础限制（等价于未设置）

对应定义：

- `D:/code/cod/openclaw/src/agents/tool-catalog.ts`（第 1, 117-137, 157-185, 248-259, 280-285 行）

文档里也写了同样规则：

- `D:/code/cod/openclaw/docs/zh-CN/gateway/configuration.md`（第 2084-2091 行）

## 4. 你应该怎么配（小白建议）

### 场景 A：你主要是“聊天/飞书/消息机器人”（推荐）

保持 `messaging` 不动。

优点：默认更安全，不会给文件读写、命令执行这类高风险能力。

### 场景 B：你要让 agent 帮你改代码、跑命令

把 profile 改成 `coding`。

最简单做法：

1. 进 `Agents -> 选中 agent -> Tools`
2. 点 `Coding`
3. 点右上角 `Save`

如果这个页面点不动，直接看下面第 8 节，用 CLI 改会更稳。

### 场景 C：你非常清楚风险，想全开

才考虑 `full`。  
如果你是刚上手，不建议直接用 `full`。

## 5. 这个页面几个按钮怎么用

- `Enable All`：把当前列表里工具全部打开（会写入覆盖项）
- `Disable All`：全部关闭（会写入 deny 覆盖）
- `Reload Config`：丢弃当前界面未保存改动，重新从网关配置读取
- `Save`：提交到网关 `config.set`
- `Inherit`：清掉该 agent 的 `tools.profile`，回到全局 `tools.profile`

按钮背后写配置路径（很关键）：

- 改 preset：`agents.list[i].tools.profile`
- 单工具开关：`agents.list[i].tools.alsoAllow` / `agents.list[i].tools.deny`

对应代码：

- `D:/code/cod/openclaw/ui/src/ui/app-render.ts`（第 665-721 行）
- `D:/code/cod/openclaw/ui/src/ui/controllers/config.ts`（第 143 行 `config.set`）

## 6. 常见坑（你大概率会遇到）

1. `Save` 按钮灰色  
原因：没有未保存变更（`configDirty=false`）或正在保存。

2. 开关改不了（灰色）  
如果该 agent 配了显式 `tools.allow`，UI 会提示“请在 Config 页管理”，并禁用这里的 per-tool toggle。

3. 我开了某个工具，但还是用不了  
可能被全局 `tools.allow`/`tools.deny` 卡住；`deny` 优先级最高。

4. `allow` 和 `alsoAllow` 不能一起配  
配置校验会报错。  
可用组合是：`profile + alsoAllow`，或者单独 `allow`。

对应测试：

- `D:/code/cod/openclaw/src/config/config.tools-alsoAllow.test.ts`（第 7-12, 21-30, 42-47 行）

## 7. 给你一个最实用的配置模板

### 模板 1：全局默认安全，某个 agent 才开启 coding

```json5
{
  tools: { profile: "messaging" },
  agents: {
    list: [
      { id: "main", tools: { profile: "coding" } }
    ]
  }
}
```

### 模板 2：保持 messaging，只额外放一个工具

```json5
{
  tools: { profile: "messaging" },
  agents: {
    list: [
      { id: "main", tools: { alsoAllow: ["read"] } }
    ]
  }
}
```

## 8. 如果 UI 改不了，不一定是 BUG

从源码看，如果下面这些条件成立，UI 本来就会禁用编辑，不一定是前端坏了：

- 配置还没加载出来
- 正在加载配置或正在保存
- 这个 agent 已经用了显式 `tools.allow`
- 全局 `tools.allow` 限制了某些工具

源码里的关键条件是：

- `editable = Boolean(configForm) && !configLoading && !configSaving && !hasAgentAllow`

也就是说：

- 如果按钮是灰的，大概率是“被策略禁用了”，不是 BUG
- 如果按钮能点，但点了没有任何变化、也没有出现 `unsaved` 状态，那才更像 UI 问题

对应代码：

- `D:/code/cod/openclaw/ui/src/ui/views/agents-panels-tools-skills.ts`（第 43-46, 136-148, 174-186 行）

## 9. 小白最推荐的更改方式

按稳妥程度，我建议你这样选：

1. 先改全局 `tools.profile`
原因：你当前配置里只有 `agents.defaults`，没有单独的 `agents.list`，所以先改全局最简单、最不容易配错。

2. 只在你明确需要时，再做 `main` 这个 agent 的单独覆盖
原因：按 agent 改法要多一层 `agents.list[0]` 路径，新手更容易写错。

3. 不建议一上来就用 `full`
原因：`full` 相当于不给基础限制，风险最高。

结合你现在的使用场景，可以直接这样选：

- 飞书/聊天机器人：`messaging`
- 想让它读写文件、改代码、跑命令：`coding`
- 只想做最小诊断：`minimal`
- 非常清楚风险，想全开：`full`

## 10. 最稳的命令改法（推荐）

这些命令我已经按你当前环境核对过，`openclaw` 命令在你机器上可用。

### 10.1 先看看当前配置

```powershell
openclaw config file
openclaw config get tools.profile
openclaw config validate
```

说明：

- `config file`：看当前实际在用哪个配置文件
- `config get tools.profile`：看当前全局 profile
- `config validate`：检查配置是否合法

### 10.2 把全局工具切到 coding

```powershell
openclaw config set tools.profile coding
openclaw config validate
```

### 10.3 切回 messaging

```powershell
openclaw config set tools.profile messaging
openclaw config validate
```

### 10.4 切到 minimal

```powershell
openclaw config set tools.profile minimal
openclaw config validate
```

### 10.5 切到 full

```powershell
openclaw config set tools.profile full
openclaw config validate
```

### 10.6 只给 `main` 这个 agent 单独改成 coding（进阶）

如果你只想改 `main`，而不是全局都改：

```powershell
openclaw config set agents.list[0].id main
openclaw config set agents.list[0].tools.profile coding
openclaw config validate
```

如果以后想让它恢复“继承全局”：

```powershell
openclaw config unset agents.list[0].tools.profile
openclaw config validate
```

### 10.7 在 messaging 基础上额外开放一个工具（进阶）

例如只额外开 `read`：

```powershell
openclaw config set agents.list[0].id main
openclaw config set agents.list[0].tools.alsoAllow '["read"]' --strict-json
openclaw config validate
```

注意：

- 数组值最好加 `--strict-json`
- `allow` 和 `alsoAllow` 不能在同一层一起配

CLI 参考和实现：

- `D:/code/cod/openclaw/docs/zh-CN/cli/config.md`（第 15-57 行）
- `D:/code/cod/openclaw/src/cli/config-cli.ts`（第 417-475 行）

## 11. CLI 不想用时，直接改文件也可以

这是 Windows 小白最容易理解的方法。

先打开配置文件：

```powershell
notepad C:\Users\Yuca\.openclaw\openclaw.json
```

你现在文件里关键位置大概是这样：

```json
"tools": {
  "profile": "messaging"
}
```

如果要改成 coding，就改成：

```json
"tools": {
  "profile": "coding"
}
```

保存后执行：

```powershell
openclaw config validate
```

如果校验通过，再重启 Gateway。

手改文件适合这些场景：

- UI 点不动
- CLI 路径写法你一时看不懂
- 你只想改一个很小的值，比如 `messaging -> coding`

手改文件不适合这些场景：

- 你要改数组、对象、多个 agent
- 你经常改来改去
- 你不熟 JSON，容易漏逗号或引号

## 12. 改完以后怎么生效

这个很重要：

- UI 页里的 `Reload Config` 只是重新读配置到界面，不等于 Gateway 运行时已经切换
- `openclaw config set` 也是改配置文件，源码提示是“改完后重启 Gateway 生效”

最简单的做法：

1. 先改配置
2. 跑一次 `openclaw config validate`
3. 退出 OpenClaw / 本地 Gateway
4. 重新打开

如果你是用本机批处理启动 Gateway，也可以重新运行这个文件：

```powershell
C:\Users\Yuca\.openclaw\gateway.cmd
```

如果它已经在别的窗口运行着，先关掉原来的窗口，再启动新的。  
如果你不确定自己是怎么启动的，最稳妥还是直接退出再重开 OpenClaw。

## 13. 一句话总结

你现在这个 `messaging + global default + 5/38` 是 OpenClaw 本地安装后的正常安全默认，不是配置错了。  
新手先保持 `messaging`，需要代码能力时再切 `coding`；如果 UI 点不动，优先用 `openclaw config set tools.profile coding`，然后 `openclaw config validate`，最后重启 Gateway。
