# OpenClaw WebUI 全图解配置手册 (小白版)

本手册基于 OpenClaw 2026.3 版本，结合官方文档和源码分析编写。
目标：让你**从打开网页到让 AI 正式上班**，全程不碰一行代码。

---

## 📖 界面总览：认识你的仪表盘

打开 WebUI 后（例如 `http://127.0.0.1:18789`），你会看到左侧有一个导航栏。它是你操作一切的"遥控器"：

| 导航栏分区 | 包含的菜单项 | 用途说明 |
|:---|:---|:---|
| **聊天** | 聊天 | 💬 跟 AI 对话的主界面 |
| **控制** | 概览、频道、实例、会话、使用情况、定时任务 | 📊 查看系统运行状态、管理会话和任务 |
| **代理** | 代理、技能、节点 | 🤖 管理 AI 代理人、技能包和远程节点 |
| **设置** | 配置、调试、日志 | ⚙️ **核心配置入口**，所有设置都在这里改 |

---

## 🔐 场景一：首次连接 — 解决"未授权 (Unauthorized)"

### 问题现象
首次打开 WebUI 时，页面顶部会弹出红色横幅：
> `unauthorized: gateway token missing (open the dashboard URL and paste the token in Control UI settings)`

### 这是怎么回事？
OpenClaw 为了安全，要求浏览器必须提供一个"通行证" (Gateway Token) 才能连入网关。这个 Token 是网关在首次启动时**自动随机生成**的（或者你在 [.env](file:///d:/code/anzhuang/openclaw/.env) 文件里手动指定的）。

### 操作步骤

**第 1 步：找到你的 Token**

Token 的来源取决于你的安装方式：
- **日常全局版**：查看 `C:\Users\levimin\.openclaw\openclaw.json` 文件里的 `gateway.auth.token` 字段。
- **源码研究版**：查看 [d:\code\anzhuang\openclaw\.env](file:///d:/code/anzhuang/openclaw/.env) 文件里的 `OPENCLAW_GATEWAY_TOKEN=` 后面的值。
- **终端日志**：启动网关时，终端会打印一行包含 Token 的 URL，形如 `http://127.0.0.1:18789/?token=xxxxxxx`。

**第 2 步：在概览页填入 Token**

1. 在左侧导航栏点击 **控制 → 概览**。
2. 在页面的 **"网关访问"** 区域中，你会看到：
   - **WebSocket URL**：显示当前网关的连接地址（如 `ws://127.0.0.1:18790`）。
   - **网关令牌**：这就是你需要填入 Token 的输入框。
3. 把你找到的 Token 粘贴到 **"网关令牌"** 输入框中。
4. 点击下方的 **"连接"** 按钮。

> **回答你的问题**：是的！"概览"页面上这个"**网关令牌**"输入框，就是你之前在 [.env](file:///d:/code/anzhuang/openclaw/.env) 里设置的 `OPENCLAW_GATEWAY_TOKEN` 的值。它们是**同一个东西**——你的身份通行证。

**第 3 步：确认连接成功**

连接成功后，页面右上方的"快照"区域会显示：
- **状态**：🟢 正常
- **运行时间**：显示具体时间（如 `14s`）
- **最后频道刷新**：显示 `just now`

恭喜！你已经通过了身份认证。

---

## 🧠 场景二：配置 AI 模型 (API Key)

这是最关键的一步。没有 API Key，AI 就是一个空壳。

### 操作步骤

**第 1 步：进入配置页面**

1. 在左侧导航栏点击 **设置 → 配置**。
2. 你会看到一个配置编辑器，左侧是分类标签，右侧是表单。

**第 2 步：找到"Authentication"(认证)标签**

1. 在配置页面的**左侧分类标签列表**中，点击 **Authentication**。
2. 在这里你可以管理你的 **Auth Profiles (认证档案)**。

**第 3 步：（推荐方式）通过 [Raw](file:///d:/code/anzhuang/openclaw/src/config/io.ts#141-147) 模式添加 API Key**

配置页面底部有两个切换按钮：**Form** 和 **Raw**。
- **Form 模式**：图形化表单，适合修改已有配置。
- **Raw 模式**：直接编辑 JSON 源码，适合一次性批量配置。

点击 **Raw**，你会看到完整的 [openclaw.json](file:///d:/code/anzhuang/openclaw-data/openclaw.json) 内容。找到（或新增）`models` 块，按照以下模板添加你的 API Key：

```json
{
  "models": {
    "providers": {
      "anthropic": {
        "apiKey": "sk-ant-你的Anthropic密钥"
      },
      "openai": {
        "apiKey": "sk-你的OpenAI密钥"
      },
      "deepseek": {
        "baseUrl": "https://api.deepseek.com/v1",
        "apiKey": "sk-你的DeepSeek密钥"
      }
    }
  }
}
```

> **💡 小贴士**：如果你使用的是**中转站 / 第三方 API 代理**，只需要在对应的 provider 下添加 `"baseUrl": "https://你的中转地址/v1"` 即可。

**第 4 步：保存配置**

编辑完成后，点击页面右上角的 **Save (保存)** 按钮。系统会自动验证你的 JSON 格式是否正确：
- 如果正确：左上角会显示绿色的 [valid](file:///d:/code/anzhuang/openclaw/src/config/zod-schema.agent-runtime.ts#58-89) 标签，配置即时生效。
- 如果有错：会标红出错的位置，你按照提示修正即可。

---

## 🎭 场景三：管理代理人 (Agents)

### 操作步骤

**第 1 步：查看代理人列表**

1. 在左侧导航栏点击 **代理 → 代理**。
2. 你可以看到当前系统中所有已配置的 Agent 列表和各自的模型。

> [!WARNING]
> **已知 Bug 警示**：在当前版本中，如果你点击具体的 Agent 打算修改其模型，底部的 **Save** 按钮可能会失效（点击无反应）。如果遇到此情况，请跳至 [场景二](file:///d:/code/anzhuang/openclaw_webui_setup_guide.md#场景二配置-ai-模型-api-key) 使用 **Raw** 模式或直接编辑 `openclaw.json`。

**第 2 步：通过配置页修改 Agent 设置**

1. 进入 **设置 → 配置**。
2. 在左侧分类标签中点击 **Agents**。
3. 在 Form 模式下，你可以修改：
   - **默认模型**：Agent 使用哪个大模型（如 `anthropic/claude-sonnet-4-20250514`）。
   - **系统提示词**：自定义 Agent 的行为和人格。
   - **工具权限**：给 Agent 开放或禁止哪些工具。

---

## 🔧 场景四：管理技能 (Skills / Plugins)

### 操作步骤

1. 在左侧导航栏点击 **代理 → 技能**。
2. 这里会列出所有可用的技能包及其启用状态。
3. 在 **设置 → 配置** 页面中，你也可以通过 **All Settings** 搜索 `skills` 或 `plugins` 来找到对应的配置项，可以精确控制每个技能的开关和参数。

---

## 📺 场景五：接入外部频道 (Channels)

OpenClaw 支持将你的 AI 连接到 Telegram、Discord、Slack 等平台。

### 操作步骤

1. 在左侧导航栏点击 **控制 → 频道**。
2. 你可以查看当前已配置的频道及其运行状态。
3. 要添加新频道，进入 **设置 → 配置**，在左侧点击 **Channels**。
4. 在 Form 模式下，填入对应平台的 Bot Token（例如 Telegram 的 `TELEGRAM_BOT_TOKEN`）。
5. 保存后，回到"频道"页面确认状态是否变为在线。

---

## 🔍 场景六：查看日志和调试

当出现问题时，日志是你的"黑匣子"。

1. 在左侧导航栏点击 **设置 → 日志**。
2. 你可以实时查看网关的运行日志。
3. 点击 **设置 → 调试** 可以查看更底层的诊断信息。

---

## ⚡ 配置页面关键按钮说明

配置页面右上角有 4 个按钮，它们的功能如下：

| 按钮 | 功能 |
|:---|:---|
| **Reload** | 🔄 从磁盘重新加载配置文件（丢弃未保存的修改） |
| **Save** | 💾 保存当前修改到 [openclaw.json](file:///d:/code/anzhuang/openclaw-data/openclaw.json) 文件 |
| **Apply** | ✅ 保存并尝试热加载配置（不重启网关） |
| **Update** | 🔁 保存并标记"需要重启"，网关会在安全的时候自动重启 |

> **推荐操作**：修改 API Key 等简单配置用 **Save**。修改端口、认证模式等核心配置用 **Update**（会触发网关重启）。

---

## ❓ 常见问题

**Q: 我在 Form 模式里找不到某个配置项怎么办？**
切换到 **Raw** 模式，直接编辑 JSON。所有配置项都在那里。你也可以在 Form 模式的搜索框里输入关键词来快速搜索。

**Q: 配置保存后怎么确认生效了？**
1. 配置页面左上角的 [valid](file:///d:/code/anzhuang/openclaw/src/config/zod-schema.agent-runtime.ts#58-89) 绿色标签表示格式无误。
2. 在 **设置 → 日志** 中会看到 `[reload] config change detected` 的日志。
3. 如果修改了核心配置（如端口），日志还会显示 `config change requires gateway restart`。

**Q: 我改错了配置，网关启动不起来了怎么办？**
放心！OpenClaw 每次保存配置前，都会自动在同目录下生成一个 `.bak` 备份文件（如 `openclaw.json.bak`）。你只需要把 `.bak` 文件重命名回 [openclaw.json](file:///d:/code/anzhuang/openclaw-data/openclaw.json)，就能恢复到上一次的正常状态。

---

## 💻 常用命令速查表

以下命令既可以在终端 (CLI) 里直接敲，也可以在 WebUI 的聊天框里通过 Agent 间接使用。

### 🚀 启动与停止

| 命令 | 用途 |
|:---|:---|
| `openclaw gateway` | 启动网关服务（日常全局版） |
| `openclaw gateway --port 18790` | 指定端口启动（避免冲突） |
| `openclaw gateway --force` | 强制杀掉占用端口的老进程，然后启动 |
| `openclaw gateway stop` | 停止正在运行的网关 |
| `openclaw dashboard` | 自动用浏览器打开 WebUI 控制台 |

### ⚙️ 配置管理

| 命令 | 用途 |
|:---|:---|
| `openclaw configure` | 启动**交互式配置向导**（推荐新手用） |
| `openclaw config get gateway.auth.token` | 查看某个配置项的当前值 |
| `openclaw config set gateway.mode local` | 修改某个配置项 |
| `openclaw config file` | 显示配置文件路径 |
| `openclaw config validate` | 验证配置文件格式是否正确 |

### 🔑 认证与安全

| 命令 | 用途 |
|:---|:---|
| `openclaw agents login` | 登录模型提供商的 OAuth 授权 |
| `openclaw devices list` | 查看所有已配对的设备 |
| `openclaw devices approve <id>` | 批准远程设备的配对请求 |

### 🩺 诊断与排错

| 命令 | 用途 |
|:---|:---|
| `openclaw doctor` | **一键体检**：检查配置、依赖、网络等问题 |
| `openclaw health` | 查看运行中网关的健康状态 |
| `openclaw status` | 查看频道状态和最近的会话 |
| `openclaw logs` | 实时查看网关日志（等价于 WebUI 的"日志"页） |

### 🤖 模型与代理

| 命令 | 用途 |
|:---|:---|
| `openclaw models scan` | 扫描当前可用的模型列表 |
| `openclaw models list` | 列出已配置的所有模型 |
| `openclaw skills list` | 列出所有可用的技能包 |
| `openclaw agent --message "你好"` | 在终端直接跟 Agent 对话 |

### 📨 消息与频道

| 命令 | 用途 |
|:---|:---|
| `openclaw channels login` | 登录聊天频道（如微信、Telegram） |
| `openclaw channels status` | 查看所有频道的连接状态 |
| `openclaw message send --target <目标> --message "内容"` | 通过频道发送消息 |
| `openclaw sessions list` | 列出所有会话记录 |

### 🔄 更新与维护

| 命令 | 用途 |
|:---|:---|
| `npm install -g openclaw@latest` | 更新全局版到最新 |
| `openclaw update check` | 检查是否有新版本可用 |
| `openclaw reset` | 重置本地配置（CLI 保留，数据清空） |
| `openclaw uninstall` | 卸载网关服务和本地数据 |

> **💡 小贴士**：任何命令后面加 `--help` 都可以看到详细的用法说明，例如 `openclaw models --help`。
