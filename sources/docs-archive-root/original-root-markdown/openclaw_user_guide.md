# OpenClaw 安装与配置完全指南 (用户篇)

如果你是直接使用 OpenClaw 而非进行源码开发，你只需要关注你的“家目录”：`C:\Users\你的用户名\.openclaw` (在 Windows 上)。

这是 OpenClaw 的所有“记忆”和“设置”存放的地方。你可以随时备份或迁移这个文件夹。

---

## 🤖 进阶：如何给正式版配置模型？

如果你觉得网页配置太慢，这里有三种最高效的“专家级”配法：

### 1. 交互式向导 (最推荐小白)
在终端输入：
```powershell
openclaw configure
```
会有一个菜单提示你：是配置网关、模型还是频道。选择 **models** 即可按步骤填入 Key。

### 2. 快速极速登录 (适合 OpenAI / Claude)
如果你只想快速填个 Key 完事：
```powershell
openclaw agents login openai
# 或者
openclaw agents login anthropic
```
按提示粘贴 Key，它会自动帮你存进配置文件。

### 🛠️ 三大配置方法对比 (怎么选？)

| 方法 | 最适用场景 | 核心优势 |
| :--- | :--- | :--- |
| **交互式向导** | **首次配置、加新服务** | **最稳。** 自动引导，不会漏填或填错格式。 |
| **手动改 JSON** | **快速换 Key、改参数** | **最快。** 熟练后秒改秒存，无需过菜单。 |
| **WebUI 界面** | **调优人设、开关工具** | **直观。** 适合图形化管理 Agent 的复杂行为。 |

> **💡 小贴士**：手动修改 JSON 后，可以运行 `openclaw config validate` 检查格式是否正确。

### 3. 手动修改 JSON (最高效率)
直接打开 `C:\Users\你的用户名\.openclaw\openclaw.json`，在 `models.providers` 下添加你的 Key：

```json
{
  "models": {
    "providers": {
      "deepseek": {
        "baseUrl": "https://api.deepseek.com/v1",
        "apiKey": "sk-xxxxxx",
        "defaultModel": "deepseek-chat"
      }
    }
  }
}
```


---

## 📂 文件夹结构详解

在 `.openclaw` 目录下，你会看到以下核心文件夹：

### 1. `workspace/` (默认对话空间)
这是你最常用的地方。
- **用途**：存放你默认 Agent 的所有对话记录、思考过程和临时文件。
- **USER.md / SOUL.md / TOOLS.md**：这些是 Agent 的“记忆碎片”。如果你发现 AI 变得奇怪，或者你想清空记忆，可以重置这里。

### 2. `agents/` (多代理配置)
如果你运行过 `pnpm openclaw agents add`，这里就会出现子文件夹。
- **用途**：每个子文件夹代表一个独立的“数字分身”。
- **独立性**：你可以给不同的 Agent 配置不同的 API Key 和内存空间。

### 3. `devices/` (设备授权)
- **paired.json**：记录了哪些浏览器、手机 App 已经通过了你的网关认证。
- **pending.json**：正在等待你授权的设备列表。

### 4. `identity/` (机器身份)
- **device.json**：这台电脑在 OpenClaw 网络中的唯一 ID 和名字。

### 5. `canvas/` (界面引擎)
- **用途**：存放 Web 控制台的展示代码。通常不需要手动修改。

---

## 📄 核心配置文件

### `openclaw.json` (唯一真神)
这是最重要的文件！如果它不存在，你可以手动创建一个。

**常用配置项速查表：**

| 配置路径 | 作用说明 | 示例值 |
| :--- | :--- | :--- |
| `gateway.port` | 网页访问端口 | `18789` |
| `gateway.bind` | 访问限制 (lan=允许局域网, loopback=仅本机) | `"lan"` |
| `gateway.auth.token` | 网页登录的“暗号” | `"你的自定义密码"` |
| `models.providers` | API Key 和代理地址配置 | (见下文示例) |
| `logging.level` | 日志详细度 (debug, info, error) | `"info"` |

---

## 💡 进阶：如何手写一个 `openclaw.json`？

不需要改源码，直接在 `.openclaw` 目录下新建一个 `openclaw.json` 文件，粘贴以下内容即可生效：

```json5
{
  "$schema": "https://docs.openclaw.ai/schema.json",
  "gateway": {
    "bind": "lan",
    "auth": {
      "mode": "token",
      "token": "admin123456" // 你的网页登录密码
    }
  },
  "models": {
    "providers": {
      "openai": {
        "baseUrl": "https://api.openai.com/v1",
        "apiKey": "sk-xxxx..." // 你的 Key
      }
    }
  }
}
```

---

## 🛠️ 常见操作指南

### Q: 如何更换 API Key？
- **方法 A**：直接在 `openclaw.json` 里修改 `apiKey` 字段。
- **方法 B**：运行命令 `pnpm openclaw agents login [provider]` 重新授权。

### Q: 如何让同事也能访问我的页面？
1. 将 `gateway.bind` 改为 `"lan"`。
2. 告诉同事你的 IP 地址和端口（例如：`http://192.168.1.5:18789`）。
3. 如果设置了 `token`，让他们输入你的暗号即可。

### Q: 数据丢了能找回吗？
只要你不删 `.openclaw` 文件夹，数据就在。建议定期备份整个目录。

### 🚀 极简主义：最少配什么能跑起来？
如果你想用最快速度开始聊天，向导里的很多项其实可以**直接跳过**：

1.  **Workspace (可选)**：默认会存在 `~/.openclaw/workspace`。如果你不介意存这里，向导里直接回车跳过即可。
2.  **Model (必选)**：这是灵魂。必须填入 API Key。
3.  **Gateway (基础)**：通常只需要确认端口和 Token，保证你能连上。
4.  **其他 (全部跳过)**：Daemon、Channels、Skills 这些都可以等以后变强了再配。

**总结**：只要有**大脑 (Model)** 和**工位 (Workspace)**，OpenClaw 就能上班。

---

## 🏗️ 交互式配置向导 (`openclaw configure`) 详解

当你运行该命令时，系统会像安装软件一样一步步引导你。以下是每个环节的含义：

### 1. 确定位置 (Where will the Gateway run?)
- **Local (this machine)**：网关在这台电脑跑。这是 99% 用户的选择。
- **Remote (info-only)**：这台电脑只是控制台，网关在远程服务器上。

### 2. 配置项解析 (Select sections)
你可以用**空格键**多选，**回车**确认：

| 模块 | 它是配啥的？ |
| :--- | :--- |
| **Workspace** | 设置对话记录、记忆文件的存放目录。 |
| **Model** | 填入 **API Key**、**Base URL**，让 AI 开始认路。 |
| **Web tools** | 配置**联网搜索**工具（Perplexity / Brave）。 |
| **Gateway** | 核心设置：端口号、局域网访问权限、登录密码。 |
| **Daemon** | 将它安装为**系统后台服务**，不仅开机自启，也不怕误关命令行窗口。 |
| **Channels** | 绑定账号：Telegram、WhatsApp、Slack 等。 |
| **Skills** | 管理插件：启用或关闭特定的 Agent 技能。 |
| **Health check** | **一键诊断**：检查你刚才配的代码能不能跑通。 |

### 🔄 向导的基本逻辑
1. **多选项目** → 2. **依次回答问题** → 3. **确认保存** → 4. **完成体检**。
它比手动改 JSON 强的地方在于：它会告诉你每个参数的推荐值，且不会允许你填入格式错误的数据。

> **💡 配置小技巧：多选模型**  
> 在配置 `model` 步骤时，如果看到 `(multi-select)` 提示：
> - **空格键 (Space)**：勾选或取消勾选模型。你会看到 `◻` 变成 `◼`。
> - **回车键 (Enter)**：确认你的最终选择。
> 
> **为什么要多选？**  
> 多选后，你的 Agent 会具备“自动切换”能力。比如复杂任务用 `gpt-o1` 这种重思考模型，简单对话自动切换到更便宜高效的小模型，甚至在主模型挂掉时自动使用备用模型。
>
> **⚠️ 列表里的模型都可以用吗？**
> - **能力支持**：列表里的模型代表 OpenClaw **“会用”** 它们（有对应的适配器）。
> - **实际使用**：你必须拥有对应提供商的 **API Key**（且账号内有余额/额度）才能真正跑通。例如：勾选了 `openai/o1`，你必须在 `openai` 配置项里填入有效的 Key。
> - **环境依赖**：如果你使用的是国内中转站，某些模型可能由于中转站未提供而无法使用，即使你在 OpenClaw 里勾选了它。

---

## 🧠 深度解析：多模型是如何“智能切换”的？

当你勾选了多个模型时，OpenClaw 并不是随机选一个，它有一套严密的逻辑：

### 1. 故障自动备份 (Reliability Fallback)
这是最基础的“智能”。
- 如果主模型挂了（如 Codex 授权过期、API 宕机、触发风控），OpenClaw 会**瞬间秒级启动备用模型**继续执行任务，你甚至感觉不到中断。

### 2. 任务分包委派 (Subagent Specialization)
当你开启了 `subagents` (子代理) 功能时，OpenClaw 会展现真正的技术：
- **主思考者**：用你选的最强模型（如 `gpt-5.3-codex`）来规划全局。
- **采集员**：当需要联网搜索或处理海量网页时，它会自动派出一个“子代理”，并可能使用更轻快、更便宜的模型（如 `o4-mini`）去干这些脏活累活。

### 3. WebUI 手动“点菜”
在 Web 界面左侧，所有你勾选的模型都会进入下拉列表。你可以随时手动点击切换，让同一个问题由不同的“大脑”来回答，以此对比谁更聪明。

---

## 🧭 如何查看和调整当前的“大脑”？

既然你选了 3 个模型，你一定想知道现在是谁在干活。

### 1. 我怎么知道现在在用哪个？
- **看对话框左侧**：在 WebUI 的聊天窗口左边栏，会有一个模型名称的显示（或者是下拉菜单）。那里显示的名称就是当前会话的“主大脑”。
- **看日志/提示词**：如果你开启了 `verbose` (详细日志)，每次 AI 回复前，你都能在命令行界面看到一行提示，比如 `[openai-codex/gpt-5.3-codex] thinking...`。

### 2. 我想换一个模型试下，怎么调？

> [!WARNING]
> **重要提示 (WebUI Bug)**：在当前的测试版本中，WebUI 的“代理”页面底部的 **Save (保存)** 按钮由于一个已知的脚本错误，在修改模型后可能无法转为可点击状态。如果按钮是灰色的点不动，请使用下方的 **方法 B**。

- **方法 A：网页切换 (当前推荐仅作为查看)**
  你可以点击聊天界面左边那个模型名字尝试切换，但在“代理”设置页面点击 `Save` 可能会失效。
- **方法 B：配置文件直接修改 (最稳定、最推荐)**
  如果你想让某个模型以后默认就当“老大”，去修改 `openclaw.json`：
  ```json
  "agents": {
    "defaults": {
      "model": {
        "primary": "openai-codex/你最喜欢的模型名",
        "fallbacks": ["另外两个模型名"]
      }
    }
  }
  ```

### 3. 三个里面，谁说了算？
在向导里，你**第一个选中**的模型通常会被设定为 `primary` (首席)。其他的会被自动放入 `fallbacks` (备选库) 或者作为可选菜单项。

---

---

---

## 🆘 重启失败了怎么办？(故障排除)

如果日志显示了 `restarting` 但你等了半天网页还是打不开，这可能是“自动重生”失败了。

### 1. 为什么会自动重启失败？
- **配置报错**：新改的 `openclaw.json` 里有语法错误（比如少个逗号）。
- **端口被占用**：旧进程还没完全退出，新进程就开始抢占 `18789` 端口。
- **环境限制**：某些系统对“进程自我克隆”有限制。

### 2. 万能修复三部曲
如果自动重启没动静，请依次执行以下命令：

1.  **彻底清场**：
    ```powershell
    openclaw gateway stop
    ```
    (如果没反应，可以用大招：`Get-Process node | Stop-Process -Force`)
2.  **配置自检**：
    ```powershell
    openclaw config validate
    ```
    确保它返回 `Configuration is valid`。如果有红字报错，先去修 JSON。
3.  **手动起飞**：
    ```powershell
    openclaw gateway
    ```

### 3. 如何判断“真的起来了”？
控制台出现这行才算大功告成：
`[gateway] listening on ws://127.0.0.1:18789`

---
