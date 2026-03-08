# 🦞 OpenClaw 新手保姆级安装与飞书接入指南

本指南将带你从零开始，在本地电脑上部署强大的个人 AI 助理 **OpenClaw**，为其装上 **OpenAI Codex** 的智慧大脑，并将它完美无缝地对接到你的**飞书 (Feishu/Lark)** 工作流中！

---

## 🛠️ 第一阶段：准备工作（必须检查！）

在动手之前，请确保你已经准备好了以下三件套：

1. **环境依赖：Node.js**
   - **硬性要求**：你的电脑必须安装 **Node.js 且版本 ≥ 22**。
   - 打开终端（Terminal/PowerShell），输入 `node -v` 检查版本。如果不满足，请前往 [Node.js 官网](https://nodejs.org/) 下载最新的 LTS 版本。
2. **AI 大脑：OpenAI Codex 账号**
   - 确保你的账号具有调用 Codex 订阅服务的权限。
3. **交互终端：飞书/Lark 账号**
   - 你需要有权限登录并使用 [飞书开发者开放平台](https://open.feishu.cn/)（海外用户请使用 [Lark 开放平台](https://open.larksuite.com/)）。

---

## 🚀 第二阶段：OpenClaw 核心安装与初始化

这是让一切运转起来的地基。

**1. 全局安装 OpenClaw**
打开终端，运行安装命令（国内如遇网络卡顿可切换淘宝镜像）：
```bash
npm install -g openclaw@latest
```

**2. 运行向导并将服务驻留后台**
紧接着执行以下命令。这会将 OpenClaw 注册为你电脑的后台守护进程（Daemon），确保它能 24 小时待命：
```bash
openclaw onboard --install-daemon
```

*🎉 恭喜！OpenClaw 已经成功安家在你的电脑上了。*

---

## 🧠 第三阶段：配置聪明的 Codex 大脑

让一个“空壳”助理变得聪明，我们需要给它接上 OpenAI 的神经元。

**1. 手动配置 Codex 订阅凭证**
因为你在电脑上使用过 Codex 命令行，你可以直接复用本地的订阅凭证，无需 `API Key`。
打开 OpenClaw 的 Agent 授权配置文件：
`C:\Users\你的用户名\.openclaw\agents\main\agent\auth-profiles.json`

将里面的内容修改为（复用 OAuth 结构）：
```json
{
  "openai-codex": {
    "type": "oauth",
    "token": {
      "access_token": "填入你 ~/.codex/auth.json 里的 access_token",
      "refresh_token": "填入你 ~/.codex/auth.json 里的 refresh_token"
    }
  }
}
```
保存即可，OpenClaw 会自动读取这个配置。

**2. 将 Codex 设为默认模型**
找到你电脑上的 OpenClaw 主配置文件：
`~/.openclaw/openclaw.json` (Windows 通常在 `C:\Users\你的用户名\.openclaw\openclaw.json`)

用记事本打开它，将默认模型修改为 `"openai-codex/gpt-5.3-codex"`：
```json
{
  "agents": {
    "defaults": {
      "model": {
        "primary": "openai-codex/gpt-5.3-codex"
      }
    }
  }
}
```

---

## 💬 第四阶段：连接飞书（Feishu/Lark）

无需公网服务器，借助 WebSocket 长连接，你可以直接把家里的 OpenClaw 连上公司的飞书！

### 步骤 A：去飞书后台“捏”一个机器人
1. 登录 [飞书开放平台](https://open.feishu.cn/) -> 点击【开发者后台】。
2. 点击【创建企业自建应用】，为机器人起个霸气的名字并上传头像。
3. **获取绝密凭证**：进入应用的左侧菜单【凭证与基础信息】页面，复制并保存你的 **App ID** 和 **App Secret**。
4. **开通机器人权限**：
   - 左侧菜单 ->【添加应用能力】-> 添加【机器人】能力。
   - 左侧菜单 ->【权限管理】-> 搜索并开通以下 4 个权限：
     - `接收群聊、单聊消息`
     - `获取用户发给机器人的单聊消息`
     - `获取群组中被@的消息`
     - `获取用户基本信息` (英文名称: `contact:contact.base:readonly`)
5. **设置直连模式（重中之重）**：
   - 左侧菜单 ->【事件订阅】。
   - 点击“订阅方式”旁边的编辑按钮，将协议修改为 **"WebSocket"**（千万别选 Webhook）。
   - 在下方事件列表中，点击【添加事件】，把刚刚申请的那 3 个接收消息事件勾选上。
6. **发布应用**：前往【版本管理与发布】创建一个新版本并申请发布该应用。

### 步骤 B：在 OpenClaw 中配置飞书通道并开启常用技能
继续打开那个主配置文件：`~/.openclaw/openclaw.json`。

在文件的最外层（和 `agents`、`gateway` 同级），加入 `channels` 和 `plugins` 配置：
```json
{
  "channels": {
    "feishu": {
      "appId": "cli_替换成你的真实AppID",
      "appSecret": "替换成你的真实AppSecret",
      "domain": "feishu"
    }
  },
  "plugins": {
    "entries": {
      "browser": {
        "enabled": true
      },
      "code-search": {
        "enabled": true
      }
    }
  }
}
```

保存文件后，在终端中**启动（或重启）网关服务**：
```bash
openclaw gateway --port 18789
```

---

## 🛡️ 第五阶段：安全机制与终极测试

这个 AI 超级强大，甚至能在你的电脑上执行代码，因此官方**默认拉满了针对陌生人的防御机制**。

**如何进行首次对话测试并“破冰”：**

1. **去飞书发消息被“无视”**
   现在去飞书里找到你创建的机器人，发送一句：“你好”。
   此时在飞书里，它**不会**回复你。
2. **回到终端获取并批准“短码”**
   查看你电脑终端的 OpenClaw 控制台输出！你会看到一条系统提示：告知收到了一条未认证的陌生人消息，并为你提供了一个【配对短码】（Pairing Code，比如 `A1B2C3`）。
   请在终端中敲入以下命令来批准自己的账号：
   ```bash
   openclaw pairing approve feishu A1B2C3
   ```
   *(请将 `feishu` 替换为你实际的通道名，并将 `A1B2C3` 替换为真实的短码)*
3. **起飞！🚀**
   此时，你的飞书账号已经被永久加入了白名单。
   重新回到飞书，再发一句“你好”，享受装配了 Codex 大脑的超级 AI 助理光速响应的快感吧！

---

## 🚑 附录：万能排雷郎中

如果在后续使用中遇到任何网络断开、消息不回档、权限报错等灵异现象，**请第一时间在终端运行**：

```bash
openclaw doctor
```

它会自动做全身体检，并告诉你哪里出了问题以及怎么解决。祝你玩的开心！🦞
