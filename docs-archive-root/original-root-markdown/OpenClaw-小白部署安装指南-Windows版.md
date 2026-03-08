# OpenClaw 小白部署与配置完全指南 (Windows 版)

欢迎来到 OpenClaw 的世界！作为一个小白，面对一个全新的 AI Agent 框架可能会感到一头雾水。不用担心，这篇指南会手把手教你在 Windows 电脑上把 OpenClaw 跑起来，并且配置得舒舒服服。

---

## 第一部分：准备工作 (安装必备项)

在安装 OpenClaw 之前，你的 Windows 电脑需要准备两样东西：

### 1. 安装 Node.js
OpenClaw 是基于 Node.js 运行的程序，所以必须安装它。
1. 访问 Node.js 官网: [https://nodejs.org/](https://nodejs.org/)
2. 下载 **LTS (长期支持版)** 的 Windows 安装包。
3. 一路“下一步”默认安装即可（确保勾选“Add to PATH”）。
4. **验证安装：** 打开命令提示符 (CMD) 或 PowerShell，输入 `node -v` 和 `npm -v`，如果能看到版本号就说明成功了。

### 2. 获取大模型 API Key
OpenClaw 是大表哥，但干活的“大脑”还是大模型。你需要去申请一个大模型的 API Key。
推荐小白从便宜或免费的模型开始：
*   **国内推荐：** DeepSeek (深度求索)、Kimi (月之暗面)
*   **海外推荐：** Anthropic (Claude)、Google (Gemini)、OpenAI (ChatGPT) 或类似 OpenRouter 这种聚合平台。

记住你申请到的那一长串像密码一样的 API Key，稍后配置要用。

---

## 第二部分：下载与全局安装 OpenClaw

作为命令行工具，最推荐的用法是将它全局安装到你的电脑上。

1. 打开命令提示符 (CMD) 或 PowerShell（建议右键“以管理员身份运行”）。
2. 输入以下命令进行全局安装：
   ```bash
   npm install -g openclaw
   ```
   *(注意：如果安装失败，可能是网络问题，可以尝试使用淘宝镜像：`npm config set registry https://registry.npmmirror.com` 后再试一次)*
3. **验证安装：** 输入 `openclaw --version`，如果显示了版本号，恭喜你，安装成功！

---

## 第三部分：核心配置 (`openclaw.json`)

这是最关键的一步！OpenClaw 的行为完全由它的配置文件决定。在 Windows 上，这个配置文件的默认路径通常在你的用户目录下：

**路径：** `C:\Users\你的用户名\.openclaw\openclaw.json`

如果找不到这个文件/文件夹，你可以自己在用户目录下新建一个 `.openclaw` 文件夹（注意前面有个点），然后在里面新建一个叫 `openclaw.json` 的文本文件。

用记事本或 VSCode 打开它，把下面的“小白推荐配置”复制进去：

```json
{
  "$schema": "https://docs.openclaw.ai/schema.json",
  "version": "1.0",
  "agents": {
    "defaults": {
      // 1. 设置主脑模型 (这里以 Claude 3.5 Sonnet 为例，如果你用其他模型请看下面的说明)
      "model": "anthropic/claude-3-5-sonnet-20241022",
      
      // 2. 记忆系统配置 (开启基于 QMD 的本地向量检索)
      "memorySearch": {
        "enabled": true,
        "provider": "auto"
      },
      
      // 3. 各种黑科技工具开关
      "tools": {
        "web": {
          "search": {
            "enabled": true,            // 开启联网搜索
            "provider": "brave"         // 默认搜索引擎
          }
        },
        "browser": {
          "enabled": true               // 开启浏览器控制 (写网页必备)
        }
      }
    }
  }
}
```

### 🔑 环境变量 (配置你的 API Key)

密码 (API Key) 千万不要写在代码和配置里！OpenClaw 会自动读取系统环境变量。你需要把前面申请的 API Key 设置到 Windows 里。

**如何在 Windows 设置环境变量：**
1. 按 [Win](file:///d:/code/claw/research/openclaw/src/memory/qmd-manager.ts#49-67) 键搜索 “环境变量”，点击 “编辑系统环境变量”。
2. 点击右下角的 “环境变量” 按钮。
3. 在上方“用户变量”或者下方“系统变量”中，点击 “新建”。
4. **变量名：** (例如 `ANTHROPIC_API_KEY`)
5. **变量值：** (粘贴你的那一长串 Key)
6. 一路点击“确定”保存。
7. **⚠️ 重启你的命令行工具！** 这很重要，不然它读不到新变量。

**常用的变量名对应：**
*   Claude: `ANTHROPIC_API_KEY`
*   OpenAI / DeepSeek (兼容格式): `OPENAI_API_KEY`
*   Gemini: `GEMINI_API_KEY`
*   OpenRouter: `OPENROUTER_API_KEY`
*   Brave 搜索: `BRAVE_API_KEY` (如果你想让它能联网搜索，去申请个免费的 Brave Search API)

### 💡 进阶：如何把主模型换成 Claude Code CLI / Codex CLI？

如果你在这个项目里不想用 OpenClaw 默认的内置引擎（PI），想直接白嫖 `claude-cli` （例如你装了 Claude Code 命令）：

非常简单，直接改 `openclaw.json` 里的 [model](file:///d:/code/claw/research/openclaw/src/agents/model-selection.ts#36-39) 字段：

```json
{
  "agents": {
    "defaults": {
      // 把它改成这个！OpenClaw 就会自动切换到 CLI Backend 模式
      "model": "claude-cli/sonnet"
    }
  }
}
```
*注意：CLI 模式下，OpenClaw 会禁用自己的工具，把控制权完全交给 Claude Code。*

---

## 第四部分：在项目里跑起来！

现在，你的 OpenClaw 已经满血复活了。

1. 打开你需要写代码或者处理文档的文件夹。
2. 在该文件夹的路径栏输入 `cmd` 回车，或者在 VSCode 里打开终端。
3. 唤醒 OpenClaw！输入你的任务：
   ```bash
   openclaw "帮我用 React 写一个登录页面，需要有手机号验证码功能，放到 src/pages/Login 下面。"
   ```
4. **见证奇迹：** 你会看到 OpenClaw 开始思考，然后啪啪啪地帮你建文件、写代码！

### 🧠 怎么用好它的“记忆”功能？(小白必学)

OpenClaw 支持 RAG (检索增强生成)。意思是你教过它的规矩，写在文档里，它自己去翻书。

1. 在你的项目根目录，新建一个文件夹叫 `memory`。
2. 在里面放一些 Markdown ([.md](file:///d:/code/claw/research/openclaw/README.md)) 文件，比如 `API接口规范.md`、`UI设计风格.md`。
3. 以后你只需要对它说：“**按照我们 memory 里的 API 规范，帮我写一个用户列表接口。**” 
它就会触发内置的 `memory_search` 工具，准确找到规范并照着写。

---

## 避坑与常见问题

1. **终端乱码 (Windows 老问题)：**
   如果你发现命令行输出中文是乱码，检查是不是用了老旧的 CMD。强烈建议使用 Windows Terminal，或者直接用 VSCode 里面自带的终端。
   
2. **命令找不到：**
   如果输入 `openclaw` 提示“不是内部或外部命令”，说明安装 Node.js 时没配好环境变量，或者全局包的路径没加入到系统的 PATH 里。

3. **回答经常中断或者报错 API Error：**
   通常是网络问题 (国内直接连国外 API 可能不稳定) 或者模型账户没钱了。

大功告成！现在去你的代码文件夹里召唤 OpenClaw 吧！
