# OpenClaw 零基础安装与配置指南

无论你是否懂技术，只要跟着下面这几个简单的步骤，就能把强大的 OpenClaw 部署到你的电脑上并立刻开始使用！

---

## 🟢 第一步：一键下载与安装

官方推荐的最简单的方法是使用一键安装脚本（它会自动帮你下载必需的环境和 OpenClaw 程序）。

1. 打开你电脑的 **PowerShell**（按下键盘上的 `Win` 键，搜索 `PowerShell`）。
2. 将下面的命令复制进去，然后按回车：
   ```powershell
   irm https://openclaw.ai/install.ps1 | iex
   ```
   *(如果你遇到网络问题，可能需要在下载前开启科学上网工具。)*

### 🤖 安装过程中会自动发生什么？
安装脚本在后台帮你装好 Node.js 和代码后，会提醒你运行 `openclaw onboard`。这是专门为第一次使用的用户准备的**“基础安全与初始化向导”**。

在运行它时，主要会经过以下几个步骤（**小白建议：大部分直接按回车选默认即可**）：
1. **安全确认 (Security)**：它会提醒你不要随便给别人开放权限。输入 `y` 确认了解风险。
2. **模式选择 (Mode)**：选择 `QuickStart` (快速开始) 即可，它会自动帮你把端口设为默认的 18789。
3. **模型和 API Key (Model)**：这步最重要！它会列出 OpenAI、Anthropic 等服务商，让你选择你想用的大模型，并粘贴你的 API Key。
4. **工作区位置 (Workspace)**：询问你的存档放在哪里，直接按回车放在默认路径下面。

*因为 `onboard` 已经帮你干了初始化最核心的活儿，所以这里请注意：*

> **什么时候需要运行 `openclaw config`？**
> 1. **想绑定聊天工具时**：如果你想把 AI 接入飞书、微信、钉钉等作为聊天机器人，必须通过它来配置参数。
> 2. **想更换或添加新的模型 Key 时**：比如你原来用的是 OpenAI，现在想换成国产大模型，就需要运行它重新填入新的 API Key。
>
> 💡 *如果上面两项你目前都不需要，那么这一步你可以直接跳过，向下看第三步！*

在刚才的黑框框（PowerShell）里，输入这行命令并按回车：
```powershell
openclaw config
```

这就是我们强大的**交互式配置向导**。请按照以下最重要的两步进行设置（使用键盘的**上下方向键移动，回车键确认**）：

### 1. 配置模型 (Model)
这是必须要做的！
- 在菜单里选择 `Model (模型配置)`。
- 从列表中选择你想用的 AI 服务商（例如：我想用智谱，就找到并选中它）。
- 把你在该服务商官网上申请的 **API Key**（一串长长的字母数字）粘贴进去。

### 2. 绑定聊天软件 (Channels) - 可选
如果你想让 OpenClaw 接管你的微信或飞书：
- 选择 `Channels (通道接入)`。
- 选择对应的聊天软件（比如 Feishu），然后按照向导提示填入你的 App ID 等信息。

*配置完成后，向导会自动退出。你不用担心把代码改坏，向导会自动帮你把所有输入的信息稳妥地保存好。*

---

## 🚀 第三步：启动并使用！

配置完成啦！现在我们可以正式让 OpenClaw 跑起来了。

在 PowerShell 里输入启动命令：
```powershell
openclaw gateway
```

**怎么判断启动成功了？**
如果你在屏幕上一堆滚动的英文字母中，看到了类似下面这句话：
> `listening on ws://127.0.0.1:18789`

恭喜你！OpenClaw 已经在你的电脑后台完美运行了。

### 🌐 打开你的控制面板
现在，打开你的电脑浏览器（比如 Chrome 或 Edge），在网址栏输入：
**[http://127.0.0.1:18789](http://127.0.0.1:18789)**

这就是你的 OpenClaw 可视化控制台主页。从现在起，你就可以在这里和各种强大的 AI 插件进行交互啦！

---

> **💡 日常使用小贴士：**
> - **怎么重新启动？** 以后每次电脑重启，你只需要打开 PowerShell，输入 `openclaw gateway` 就能重新唤醒它。
> - **想修改设置怎么办？** 如果你想更换模型或者修改通道设置，随时可以关掉后台（`Ctrl+C`），然后再次运行 `openclaw config` 重新配置即可，你的之前数据都不会丢！
> - **想创建新的“智能体 (Agent)”分身？** 因为网页控制台目前主要用来开关技能，如果你想捏一个有独立记忆和人设的新 AI：
>   - 先按 `Ctrl+C` 停掉运行中的服务。
>   - 在黑框框里输入：**`openclaw agents add`** 然后敲回车。
>   - 跟着向导，给它起个名字、选定大模型即可！完成后，你可以随时在网页端切换并使用它。

---

## 🛠️ 建议操作：开启长期记忆（小白必备）

虽然你已经能用了，但为了让你的 AI 拥有官宣中那种“过目不忘”的本领，**我强烈建议你立刻执行下面这行命令**。

默认情况下，OpenClaw 出于保护你的带宽考虑，没有开启本地记忆模型。这会导致你的 AI 无法记住之前的对话细节。

**执行下面这行命令（在 PowerShell 中粘贴并回车）：**
```powershell
openclaw config set agents.defaults.memorySearch.provider local
```

**为什么推荐这么做？**
1. **零成本**：本地运行模型，不花你的一分钱流量费。
2. **隐私安全**：你的记忆存储在你自己电脑上，不上传云端。
3. **功能保障**：这能确保 OpenClaw 最核心的“记忆”功能不再是摆设。

> 💡 **小贴士**：跑完这行命令后，下次你运行 `openclaw gateway` 时，系统会自动从网上下载一个约 300MB 的模型。请耐心等待它下完，记忆功能就会自动起飞！

---

## ⛔ 必看：国内小白"防踩坑"工具与技能开关指南

OpenClaw 自带的能力分为两大类，请务必区分：
1. **内置工具 (Tools)**：代码自带、不需要额外安装，但部分需要配置才能工作。
2. **外置技能 (Skills)**：52 个可选的第三方命令行工具，需要单独安装对应软件。

---

### 一、内置工具 (Tools)：核心中的核心

这些是 OpenClaw 代码自带的工具，在 WebUI 或 `openclaw config` 的 Tools 部分管理开关。

| 工具名 | 功能 | 是否需要额外配置 | 建议 |
|---|---|---|---|
| `read` / `write` / `edit` | 读写文件 | ❌ 直接可用 | ✅ 保持开启 |
| `exec` / `process` | 执行系统命令 | ❌ 直接可用 | ✅ 保持开启 |
| `web_fetch` | 抓取网页内容 | ❌ 直接可用 | ✅ 推荐开启 |
| `memory_get` / `memory_search` | 长期记忆存取 | ⚠️ 需要 Embedding 模型（见下方说明） | ⚠️ 重要但需配置 |
| `browser` | 浏览器自动化 | ⚠️ 需要 Chromium + CDP（见下方说明） | 🟡 见排查步骤 |
| `message` | 发送消息（需配合通道） | ⚠️ 需先配好通道 | 🟡 按需 |
| **`web_search`** | **联网搜索** | **⚠️ 必须配 API Key** | **🟡 配好了再开** |

---

### 🧠 重点：Memory 记忆功能（非常重要！必须配好）

**记忆是 OpenClaw 最核心的卖点之一**——它让你的 AI 能"记住"之前对话的内容、你的偏好和工作上下文，不再每次都从零开始。官方宣传中大篇幅介绍的"长期记忆"就是靠这个。

**但如果 Embedding 没配好，记忆功能就是一个摆设。**

#### 如何诊断记忆是否可用？

打开 PowerShell，运行：
```powershell
openclaw memory status --deep
```

如果你看到类似这样的输出：
```
Provider: none (requested: auto)
Embeddings: unavailable
Embeddings error: No API key found for provider "openai"...
```
**说明记忆功能目前不可用！** 因为系统尝试了所有远程 Embedding 提供商（openai → google → voyage → mistral），都没找到 API Key，本地模型也没就绪。

#### 如何修好它？（推荐步骤：先本地，后云端）

**1. 首选：按照上文建议开启“本地模式”**
运行：
```powershell
openclaw config set agents.defaults.memorySearch.provider local
```
只要你的电脑能成功下载模型（见下文注意事项），这是最省心的方案。

**2. 进阶：如果你追求更好的搜索质量，或本地模式报错**
你可以改用远程 API 服务。例如你如果有 OpenAI 的 Key，运行：
```powershell
openclaw config set agents.defaults.memorySearch.provider openai
```
然后确保你的 `OPENAI_API_KEY` 环境变量已设置，或在 `openclaw.json` 中配好了 Model 的 API Key。

如果你用国产模型，也可以通过编辑 `~/.openclaw/openclaw.json` 来配，在其中添加：
```json
{
  "agents": {
    "defaults": {
      "memorySearch": {
        "provider": "openai",
        "remote": {
          "baseUrl": "https://你的兼容API地址/v1",
          "apiKey": "sk-xxxx你的key"
        }
      }
    }
  }
}
```

配好后重新运行 `openclaw memory status --deep`，看到 `Embeddings: ready` 就说明成功了！

#### 为什么我的本地模型没有自动下载？

你可能会问："安装的时候不是应该默认下载好了吗？"

**答案是：为了保护你的流量和磁盘，OpenClaw 默认不会自动下载模型。**

从源码 `embeddings.ts`（第 81 行）看，当你的 Provider 设为 `auto`（默认值）时，系统为了防止在后台悄悄下载几百 MB 的文件，**会故意忽略掉需要从 HuggingFace 下载的模型**。它只会去寻找你已经配好 API Key 的远程服务（如 OpenAI）。

#### 如果我就想用本地模型，怎么开启？

必须通过以下命令显式开启，它才会触发下载：

1. **手动设为 local 模式：**
   ```powershell
   openclaw config set agents.defaults.memorySearch.provider local
   ```

2. **触发“真”下载：**
   输入以下命令并按回车：
   ```powershell
   openclaw memory status --deep
   ```
   **你会发现：** 系统不仅在检查状态，还会因为发现你指定了 `local` 但没文件，从而**立刻开始从网上抓取**那张 300MB 的模型。你能直接在黑框框里看到下载进度。

> **💡 经验之谈**：这就是为什么我们推荐先跑这个命令，而不是直接开 `gateway`。这样你可以盯着它下完，心里更踏实。

> **⚠️ 注意：** 在 Windows 上，本地模式依赖一个叫 `node-llama-cpp` 的组件，它在安装时需要编译（需要你电脑上有 Python 和 Visual Studio 编译工具）。如果下载失败或报错 `module not found`，通常是因为编译环境不全，这也是为什么我们更推荐小白使用**远程 API 方式**。

#### 🍎 Mac 系统用户会有这些问题吗？

如果你是 macOS 用户，情况会稍微好一些，但逻辑是一样的：

1. **自动下载逻辑全平台一致**：无论 Mac 还是 Windows，`auto` 模式下都不会自动下载本地模型。Mac 用户也必须运行 `openclaw config set agents.defaults.memorySearch.provider local` 才能触发下载。
2. **安装更顺滑**：`node-llama-cpp` 对 Mac（尤其是 M1/M2/M3 芯片）的支持非常好，通常自带预编译好的文件，不需要像 Windows 那样折腾 Python 和 C++ 编译环境。
3. **特权技能**：很多在 Windows 上显示的 **blocked** 技能（如 `peekaboo` 截屏、`apple-notes` 笔记、`model-usage` 统计等），在 Mac 上只要装好对应工具就能直接起飞。

---

> **总结：** 不管什么系统，**“先设 Provider，再跑 Status”** 是开启本地记忆功能的通用口诀！

Browser 工具可以让 AI 直接操作你电脑上的浏览器（打开网页、点击按钮、截图等），确实是个很有用的功能。

#### 它在 Windows 上能工作吗？

从源码 `chrome.executables.ts` 看到，它会**自动搜索以下浏览器**（按顺序）：
1. **Chrome** → `%LOCALAPPDATA%\Google\Chrome\Application\chrome.exe`
2. **Brave** → `%LOCALAPPDATA%\BraveSoftware\Brave-Browser\Application\brave.exe`
3. **Edge** → `%LOCALAPPDATA%\Microsoft\Edge\Application\msedge.exe`
4. 以及它们的 `Program Files` 系统安装路径

**好消息：Windows 自带 Edge，所以理论上应该能自动发现！**

#### 排查步骤

```powershell
# 1. 确保 browser 已启用
openclaw config set browser.enabled true

# 2. 用 doctor 命令检查
openclaw doctor

# 3. 如果自动发现失败，手动指定你的浏览器路径（以 Edge 为例）
openclaw config set browser.executablePath "C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe"
```

#### 使用注意事项
- 启动 browser 时，**必须关闭你正在使用的同款浏览器**（同一个浏览器只能被一个调试端口控制）
- 如果还是不行，可以尝试设置 headless 模式：`openclaw config set browser.headless true`
- `web_fetch` 是 browser 的轻量替代——它可以直接抓取网页内容，不需要启动真正的浏览器

---

> **💡 重点说明 `web_search` 搜索工具：**
> 它支持多个搜索后端（从源码 `schema.labels.ts` 中找到的）：
> - **Brave Search**（默认后端，需要 Brave API Key）
> - **Perplexity**（需要 Perplexity API Key）
> - **Gemini**（需要 Gemini API Key）
> - **Grok**（需要 xAI API Key）
> - **Kimi（月之暗面）**（需要 Kimi API Key，国内友好！）
>
> 通过 `openclaw config` 选择 `Web` 部分进行配置。**如果不配 Key，这个工具即使开了也用不了。**

---

### 二、外置技能 (Skills)：52 个里大部分可以关掉

#### 💡 默认开关策略说明

> **初始化后的默认状态是：所有工具和技能都"开启"，但大部分技能处于 blocked 状态。**
>
> 从源码看：`disabled = skillConfig?.enabled === false`，只有你**显式设为 false** 才算关闭。初始化时没有自动关闭任何技能。
>
> 但 blocked ≠ 能用。`eligible = !disabled && !blockedByAllowlist && requirementsSatisfied`。大部分技能因为缺少前置条件（CLI 工具、环境变量、OS 限制），虽然"开着"但实际不可用。
>
> **简单说：blocked 的不用管，它们不会真正执行。但如果你发现 AI 总想调用某个 blocked 的工具导致浪费时间，可以去 WebUI 或 `openclaw.json` 里手动关掉它：**
> ```json
> { "skills": { "entries": { "discord": { "enabled": false } } } }
> ```

#### 💡 关于 WebUI 里看到的 "blocked" 状态

> 从源码 `skills-status.ts` 查到，一个 skill 显示 blocked，**本质上就是它的前置条件 (`requires`) 没满足**：
> 1. **缺少对应的命令行工具 (bins)**：比如 `obsidian` 技能需要你电脑上装了 `obsidian-cli`，没装就 blocked。
> 2. **缺少环境变量 (env)**：比如 `notion` 技能需要你设置了 `NOTION_API_KEY`，没设就 blocked。
> 3. **操作系统不对 (os)**：比如 `peekaboo` 只支持 macOS (`darwin`)，Windows 上必然 blocked。
>
> **所以大部分 blocked 是正常的！不用担心。**

#### ✅ 有通用价值、值得保留的（不需要关掉）
| 技能 | 功能 | 前置条件 | 国内可用 |
|---|---|---|---|
| `healthcheck` | 安全审计和加固建议 | 无需安装额外工具 | ✅ |
| `summarize` | 总结网页/文章/视频 | 需装 `summarize` CLI + 大模型 Key | ✅ |
| `nano-pdf` | 自然语言编辑 PDF | 需装 Python 工具 `nano-pdf` | ✅ |
| `notion` | 操作 Notion 笔记 | 需要 `NOTION_API_KEY` | ✅ 如果你用 Notion |
| `weather` | 查看天气 | 需装 `weather` CLI | ✅ |
| `obsidian` | 操作 Obsidian 笔记库 | 需装 `obsidian-cli` | ✅ 如果你用 Obsidian |
| `canvas` | 在客户端展示 HTML 内容 | 需有 Mac/iOS/Android 客户端 | 🟡 看需求 |

#### ❌ 强烈建议关闭的

**macOS 专属（Windows 完全无法使用，必然 blocked）：**
`peekaboo`、`apple-notes`、`apple-reminders`、`things-mac`、`bear-notes`、`imsg`、`blucli`、`camsnap`、`sonoscli`、`model-usage`(需要 macOS 的 codexbar)

**海外服务（国内网络访问困难或无法注册）：**
`xurl`(Twitter/X)、`discord`、`slack`、`trello`、`github`、`gh-issues`、`spotify-player`、`bluebubbles`、`wacli`(WhatsApp)

**需要专门 API Key、安装复杂且小白用不到：**
`gemini`(需装 Gemini CLI + Google 认证)、`openai-image-gen`(需要 OPENAI_API_KEY + Python)、`openai-whisper`(需装 whisper CLI)、`openai-whisper-api`(需要 OPENAI_API_KEY)、`sherpa-onnx-tts`

**极客/开发者专用：**
`coding-agent`、`skill-creator`、`tmux`、`oracle`、`session-logs`、`sag`、`gog`、`mcporter`

**其他小众/功能有限：**
`gifgrep`、`songsee`、`voice-call`、`video-frames`、`nano-banana-pro`、`openhue`(智能灯泡)、`eightctl`、`ordercli`、`goplaces`、`clawhub`、`blogwatcher`

---

## 💬 聊天命令速查表（飞书 / WebUI / TUI 通用）

在任何聊天窗口中，你都可以直接输入以 `/` 开头的命令来控制 OpenClaw。以下是从源码 `commands-registry.data.ts` 提取的完整命令列表。

### 🔥 最常用命令（小白必背）

| 命令 | 功能 | 使用场景 |
|---|---|---|
| `/new` | **开始新对话** | 聊完一个话题想换下一个时用 |
| `/reset` | 重置当前会话 | 和 `/new` 类似，清空当前上下文 |
| `/model 模型名` | **切换模型** | 例如 `/model openai/gpt-4o` |
| `/models` | 列出所有可用模型 | 忘了模型全名时用它查 |
| `/status` | 查看当前状态 | 看当前用的什么模型、什么Agent |
| `/help` | 显示帮助 | 忘了命令时救急 |
| `/commands` | 列出全部命令 | 比 /help 更完整的列表 |
| `/stop` | **停止当前执行** | AI 跑太久或方向不对时用 |

### 🧪 调试利器（看 AI 怎么"想"和"做"）

这就是你提到的"可以看到模型一步步怎么思考、怎么执行"的功能，非常实用：

| 命令 | 功能 | 说明 |
|---|---|---|
| `/think 级别` | **设置思考深度** | 让 AI 在回答前先"想一想"再回答，思考越深回答越好 |
| `/reasoning on` | **显示推理过程** | 开启后，你能看到 AI 内部的推理链条！最适合调试 |
| `/reasoning stream` | **实时流式显示推理** | 边想边显示，像看 AI "直播思考" |
| `/verbose on` | **详细模式** | 显示工具调用、执行步骤等详细过程 |
| `/usage tokens` | 显示 Token 消耗 | 每条回复后显示用了多少 Token（帮你省钱） |
| `/usage full` | 显示完整消耗 | 包含整个会话的累计 Token 统计 |

**`/think` 的级别说明：**
```
/think off       → 不思考，直接回答（最快）
/think minimal   → 简单思考
/think low       → 轻度思考（默认）
/think medium    → 中度思考
/think high      → 深度思考（更准确但更慢）
/think xhigh     → 超级深度思考（仅 GPT-5 系列支持）
/think adaptive  → 自适应（AI 自己决定思考多深）
```

> 💡 **推荐组合**：想调试 AI 行为？直接输入：
> ```
> /reasoning on
> /verbose on
> /think medium
> ```
> 这三行下去，你就能看到 AI 的完整"思维链"——它为什么选了这个工具、为什么这样回答，一目了然。

### 🤖 智能体与会话管理

| 命令 | 功能 |
|---|---|
| `/compact` | 压缩会话上下文（对话太长时用，防止超出 Token 上限） |
| `/session idle 24h` | 设置空闲超时（24 小时没动静就自动结束会话） |
| `/subagents list` | 查看当前正在跑的子智能体 |
| `/kill all` | 杀掉所有正在跑的子智能体 |
| `/steer 目标 消息` | 给正在运行的子智能体发送指令 |
| `/export` | 导出当前会话为 HTML 文件 |
| `/whoami` | 查看你的发送者 ID |
| `/context` | 查看当前上下文是怎么构建的 |

### 🔐 安全与权限

| 命令 | 功能 |
|---|---|
| `/elevated on` | 开启提权模式（允许执行更多系统命令） |
| `/elevated ask` | 每次执行系统命令前询问你是否同意 |
| `/elevated off` | 关闭提权（最安全） |
| `/approve` | 审批执行请求 |
| `/exec` | 设置命令执行的安全策略 |
| `/activation mention` | 群聊中只有 @机器人 才回复 |
| `/activation always` | 群聊中每条消息都回复 |

### 🎵 其他

| 命令 | 功能 |
|---|---|
| `/tts on` | 开启文字转语音 |
| `/tts off` | 关闭文字转语音 |
| `/skill 技能名` | 手动调用某个技能 |
| `/config show` | 在聊天中查看当前配置 |
| `/debug show` | 查看运行时调试开关 |
| `/restart` | 重启 OpenClaw 服务 |

---

## 💡 WebUI 专属进阶技巧：如何创建纯净"无绑定"的新会话？

**问题痛点：**
很多用户在飞书里和机器人聊天后，如果在 WebUI 中打开该对话，即使用界面的 `New Session` 按钮或输入 `/new`，新建的对话**依然会绑定在飞书通道下**（所有的回复还是可能被发送给飞书）。这是因为 `/new` 命令的底层逻辑是“清空当前通道的上下文历史”，而不是“完全脱离所属通道”。

**解决方法：利用 URL 魔术跳转强行新建**
OpenClaw 网页端实际上是通过网址上的 `?session=` 参数来识别对话的。
1. 当前你在聊天界面的网址可能类似：`http://127.0.0.1:18789/?session=feishu:xxxx`
2. **直接把浏览器地址栏最后的 `=` 后面改成一个随便起的新名字**，比如改成：
   `http://127.0.0.1:18789/?session=my-clean-chat`
3. 按下回车键。系统发现这是一个不存在的新会话 ID，立刻就会为你开启一个绝对纯净、没有任何飞书通道绑定的新对话！

以后每次想开彻底新的、跟其他平台无关的独立对话，只需要在网址栏随便敲个新名字回车就行了！

---

> 💡 **小贴士**：
> - 以上所有命令在**飞书机器人聊天**和 **WebUI 聊天窗口**中都可以直接输入使用。
> - 大部分命令不带参数时会显示当前值（比如单独输入 `/model` 会告诉你现在用的什么模型）。
> - 如果在飞书群聊中使用，记得先 @机器人 再输命令。
