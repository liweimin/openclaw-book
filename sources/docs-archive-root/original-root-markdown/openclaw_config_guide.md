# OpenClaw 深度配置与使用教程 (openclaw.json)

本文档基于 OpenClaw 源码分析，旨在帮助你从零开始配置 `openclaw.json`，实现服务的统一管理。

---

## 1. 为什么需要 `openclaw.json`？

虽然 [.env](file:///d:/code/anzhuang/openclaw/.env) 方便，但 `openclaw.json` 才是 OpenClaw 的“大脑”。
- **统一管理**：所有的网关、模型、插件、渠道配置都在一个 JSON 里，一目了然。
- **动态引用**：支持 `${VAR}` 语法引用环境变量，兼顾安全与灵活。
- **高级排序**：可以精确控制多个 API Key 的使用优先级和轮换策略。

---

## 2. 核心配置项深度解读

### 🌐 Gateway (网关：控制访问)
`gateway` 块决定了谁能访问你的 OpenClaw，以及通过什么方式访问。

- **`gateway.bind` (绑定模式)**:
  - `loopback`: **(默认)** 只允许本机访问 (`127.0.0.1`)。最安全，但其他设备打不开。
  - `lan`: 允许局域网甚至互联网访问 (`0.0.0.0`)。如果你想在手机上用，选这个。
  - `tailnet`: 如果你用了 Tailscale，它会优先绑定到你的私有网络 IP。
  - `auto`: 聪明模式。优先尝试 `127.0.0.1`，如果不行（比如容器环境）则回退到 `0.0.0.0`。
- **`gateway.port`**: 默认 `18789`。如果被占用可以改掉。
- **`gateway.auth`**:
  - `mode`: 推荐选 `"token"`。
  - `token`: 你的“万能钥匙”。设置后，访问 Web UI 只需输入这个。

---

### 🤖 Models (模型：定义大脑)
这是你问的最多的部分。OpenClaw 支持**无限扩展**模型提供商。

```json5
"models": {
  "providers": {
    "my-openai-proxy": { // 给这个提供商起个名字
      "baseUrl": "https://api.openai.com/v1", // API 地址
      "apiKey": "${OPENAI_API_KEY}",           // 引用变量保持安全
      "models": [                              // 定义该提供商下的具体模型
        {
          "id": "gpt-4o",                      // 官方 ID
          "name": "我的主力模型",               // 在 UI 里显示的各种名字
          "contextWindow": 128000              // 上下文窗口大小
        },
        {
          "id": "gpt-3.5-turbo",
          "name": "速度最快"
        }
      ]
    },
    "anthropic": {
       "baseUrl": "https://api.anthropic.com/v1",
       "apiKey": "${ANTHROPIC_API_KEY}",
       "models": [
         { "id": "claude-3-5-sonnet-20240620", "name": "Claude 3.5 Sonnet" }
       ]
    },
    // --- ⬇️ 国内主流大模型配置建议 (针对中国用户) ⬇️ ---
    "zai": { // 智谱 AI (Zhipu AI)
       "apiKey": "${ZAI_API_KEY}",
       "models": [
         { "id": "glm-5", "name": "智谱 GLM-Plus (强推理)", "reasoning": true },
         { "id": "glm-4.7", "name": "智谱 GLM-4.7 (主力)" },
         { "id": "glm-4.5-flash", "name": "智谱极速版" }
       ]
    },
    "moonshot": { // Kimi (月之暗面)
       "apiKey": "${MOONSHOT_API_KEY}",
       "models": [{ "id": "kimi-k2.5", "name": "Kimi 主力" }]
    },
    "volcengine": { // 豆包 (字节跳动)
       "apiKey": "${VOLC_API_KEY}",
       "models": [{ "id": "doubao-pro-32k", "name": "豆包 Pro" }]
    }
  }
}
```

#### 💡 智谱 AI (Zhipu AI) 特别说明
*   **前缀标识**：在 OpenClaw 中，智谱的模型前缀是 `zai/` (代表 Zhipu AI)。
*   **模型名称映射**：
    *   `zai/glm-5`：目前的顶配版本，对应官方的 **GLM-4-Plus**。如果你在找类似“glmplan”或者高性能版本，选这个。
    *   `zai/glm-4.7`：极高性价比的主力模型。
    *   `zai/glm-4.5-flash`：极其快速且廉价，适合简单对话。
*   **中国地区可用性**：所有 `zai/` 开头的模型均在国内直接可用，无需特殊网络环境。

#### ❓ Agent 到底在用哪个模型？模型配置了有什么用？

很多刚接触配置的人会问：**“我在这里配了这么多模型，Agent 到底用的是哪个？”** 以及 **“配这么多模型比如 gpt-4o 和 gpt-3.5-turbo 有啥区别？”**

**1. 配置的这些模型代表什么意思？有什么用？**
我们在 `openclaw.json` 里配置它们，本质上是给 Agent 建立了一个**“模型武器库”**。不同模型有不同的专长：
- **重型主力模型（如 `gpt-4o`, `claude-3-5-sonnet` 等）**：这些是最聪明的“大脑”，拥有极强的**复杂逻辑推理**、**代码编写**、**复杂工具调用**（比如自主规划步骤、上网搜索、执行本地命令）的能力。当你让Agent解决高难度问题时，主要靠它们。
- **轻量极速模型（如 `gpt-3.5-turbo`, `gemini-1.5-flash` 等）**：反应极快、成本极低。如果只是让Agent做简单的文本翻译、总结文章大意、或者日常简单指令，选用它们可以体验到几乎无延迟的“秒回”。

**2. 既然配置了这么多，Agent 运行时到底用哪个？**
在 OpenClaw 中，模型的选择并没有在 Web UI 页面里提供随时手动切换的下拉框，而是**通过配置与 Agent 甚至系统默认进行绑定**的：

- **Agent 专属绑定 (最精确)**：在 `openclaw.json` 的 `agents.list` 配置中，你可以为每一个具体的 Agent 绑定它的专属模型。当你与这个特定的 Agent 聊天时，它就会使用绑定的脑子。（例如：给写代码的 Agent 绑定 `"gpt-4o"`，给聊天的 Agent 绑定 `"gpt-3.5-turbo"`）。
- **全局默认兜底 (最省事)**：如果你没有给某个 Agent 特别指定模型，系统会使用在 `agents.defaults.model` 里配置的默认兜底模型。
- **自动回退与高可用 (最稳妥)**：这不是简单的绑定，你可以为 Agent 绑定一个“策略”。比如配置首发主责模型为 `gpt-4o`，但同时配置一个 `fallbacks: ["gpt-3.5-turbo"]`（备胎数组）。如果主模型因为网络抖动断联，OpenClaw 底层的调度会自动无缝切换到备用模型继续回答，防止动不动报错中断。

一句话总结——在这份 JSON 配置文件里的作用是**“向全局的武器库上架新模型”**，而在配置各个 Agent（或者设置全局默认）时，就是**“给不同的工种发最合适的枪”**。当你和某个 Agent 对话时，其实你是在使用它背后的那把专属武器。

---

### 🔐 Auth (认证：账号分发)
如果你用了 `agents login`，在这里关联：

- `auth.order`: 指定当有多个 Key 时，先用哪一个。
  - `"openai": ["my-cool-profile", "env"]`：先用名为 `my-cool-profile` 的登录授权，没有就用 [.env](file:///d:/code/anzhuang/openclaw/.env)。

---

## 3. WebUI 配置与常见 Bug 揭秘 (为什么 Save 点不了？)

除了直接改文件，你也可以在 OpenClaw 的 Web 管理页面（Control UI）的 Settings 中进行可视化配置。

### A. WebUI 改配置的原理与“双向同步”
你在 Web UI 上的所有操作，本质上都是在调用底层的 `config.patch` 接口。系统会把你的修改直接写入 `openclaw.json` 文件并永久保存，随后触发系统热重载让配置立即生效（比如你关掉某个工具，Agent 面板会瞬间刷新权限）。

### B. 为什么有时候改了配置，`Save` 按钮却是灰色的？
这是很多新手遇到的坑。当你通过 WebUI 表单修改配置时，如果发现 `Save` 按钮置灰无法点击，这是因为触发了前端源码（`ui/src/ui/views/config.ts`）里的**严格校验逻辑**。导致保存被禁用的常见原因有：

1. **必填项没填 (Missing Required Fields)**：如果某个高级特性被你打开，但它下面的必填项（比如绑定的端口号、或者回调的 URL）你留空了，系统校验不通过，就不会让你保存。
2. **结构不兼容 (Unsupported Schema Paths)**：有时底层的 JSON 配置层级过于复杂或存在旧版残留数据，Web 端的“可视化表单 (Form 视角)”无法安全地解析或表达这些数据结构。此时系统为了防止“保存后把你的配置搞乱”，会主动在 Form 视角禁用 Save 按钮，并在界面上提示 *“Form view can't safely edit some fields. Use Raw to avoid losing config entries.”*

**💡 终极解决办法（小白必学）：**
遇到 `Save` 置灰时，不要卡在 `Form`（表单）模式！**在页面左下角将视角切换到 `Raw`（源码）模式**。在 Raw 模式下你直接修改底层的 JSON5 文本，系统的拦截逻辑会完全放开，此时 `Save` 按钮必定恢复可用。保存后系统会自动帮你格式化并生效。

---

## 4. 全局参数指南：必填、选填与默认值

在这份庞大的 `openclaw.json` 里，到底哪些是必须写的？其实非常少！系统极度依赖**智能默认 (Smart Defaults)**。

### ☑️ 必填项 (Required)
严格来说：**几乎没有什么是必填的。**
连 `openclaw.json` 这个文件本身都可以不存在（系统会全用默认值跑在内存里）。但在真实使用中，以下算是“业务级必填”：
*   **网关令牌 (`gateway.auth.token`)**：如果不配，任何人只要知道 IP 都能登录你的控制面板。
*   **API Key (`models.providers.*.apiKey`)**：不配没法调大模型（除非你在 `.env` 里配了全局宏）。

### ⚙️ 选填项与系统默认行为 (Defaults)
大部分配置你不填，系统都有完美的兜底方案：
*   **`gateway.bind`**：你不配，默认是 `loopback` (也就是 `127.0.0.1`，仅限本机访问最安全)。
*   **`gateway.port`**：你不配，默认是 `18789`。
*   **`agents.defaults.workspace`**：你不配，系统默认在你启动命令的当前目录下创建一个叫 `.agent` 的工作区。
*   **`models.providers.*.models` 里的模型属性**：你不配 `contextWindow`，系统会自动拉取官方的数据或者设定为 200k 安全上限。

**结论**：保持配置文件**越短越好**。只写你想修改的东西，不要把默认配置全都抄写到 JSON 里，那样反而不利于后续升级。

---

## 5. 一个“最佳实践”的 `openclaw.json` 示例 (极简派)

作为新手，最佳配置方式是**“剥离账号密码 + 极简声明”**。

```json5
{
  "$schema": "https://docs.openclaw.ai/schema.json",
  // 1. 网络与安全：暴露给所有人，但强制密码访问
  "gateway": {
    "bind": "lan",             
    "port": 18789,
    "auth": {
      "mode": "token",
      // 【最佳实践】绝对不要把真实密码写死在这里！
      // 通过 ${} 引用系统环境变量，防止密码泄露
      "token": "${MY_SUPER_SECRET_TOKEN}"   
    }
  },
  
  // 2. 核心武器库：只登记你想用的，或者想在 WebUI 里起别名的模型
  "models": {
    "providers": {
      "openai-codex": {
        "models": [
          { "id": "gpt-5.3-codex", "name": "GPT 5.3 代码特化版 (主推)" }
        ]
      },
      "zai": {
        "apiKey": "${ZAI_API_KEY}",
        "models": [
          { "id": "glm-5", "name": "智谱 GLM-Plus (强推理)" },
          { "id": "glm-4.7", "name": "智谱 GLM-4.7 (主力)" }
        ]
      }
    }
  },
  
  // 3. 员工配置：给系统设置一个聪明的兜底大脑
  "agents": {
    "defaults": {
      // 全局兜底模型：如果下面具体 Agent 没指定模型，就默认用这个
      "model": "openai-codex/gpt-5.3-codex"
    }
    // 至于各个专属工种的配置 (agents.list)，建议通过 WebUI 页面直接点选创建，
    // 系统会自动帮你写入到文件的这个位置，不用手写复杂的 JSON
  },
  
  // 4. 开发利器：只抓取警告以上级别的日志
  "logging": {
    "level": "warn"
  }
}
```

按照上面这个极简思路配置，你的系统既安全（密码解耦），又清晰（只有你关心的高级模型配置），同时完全享受 OpenClaw 的所有原生能力！
