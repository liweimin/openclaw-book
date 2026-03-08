# 🐦 OpenClaw × 飞书：一次搞定全配置指南

---

## ⚠️ 前提条件
- OpenClaw 网关已安装并能正常启动 (`openclaw gateway`)
- 你有飞书企业管理员权限（或者能找管理员帮你审批应用）

---

## 第一步：安装飞书插件（命令行）

飞书不是 OpenClaw 内置功能，需要先装插件：

```powershell
openclaw plugins install @openclaw/feishu
```

> 如果你是源码版，用这个：`openclaw plugins install ./extensions/feishu`

---

## 第二步：飞书开放平台配置（全在网页上操作）

打开 [飞书开放平台](https://open.feishu.cn/app)，用飞书账号登录。

### 2.1 创建应用
1. 点击 **"创建企业自建应用"**
2. 填写应用名称（比如 `AI 助手`）和描述
3. 选一个好看的图标

### 2.2 复制凭证
进入应用 → **"凭证与基础信息"** 页面，复制两样东西：
- **App ID**（格式 `cli_xxxxxx`）
- **App Secret**

### 2.3 一键导入全部权限（最关键！）

> 这一步解决了你 `app do not have bot` 的报错根源。

1. 进入左侧 **"权限管理"** 页面
2. 点击右上角的 **"批量导入"** 按钮
3. **直接复制粘贴下面这段 JSON**，一键全部导入：

```json
{
  "scopes": {
    "tenant": [
      "aily:file:read",
      "aily:file:write",
      "application:application.app_message_stats.overview:readonly",
      "application:application:self_manage",
      "application:bot.menu:write",
      "cardkit:card:write",
      "contact:user.employee_id:readonly",
      "corehr:file:download",
      "docs:document.content:read",
      "event:ip_list",
      "im:chat",
      "im:chat.access_event.bot_p2p_chat:read",
      "im:chat.members:bot_access",
      "im:message",
      "im:message.group_at_msg:readonly",
      "im:message.group_msg",
      "im:message.p2p_msg:readonly",
      "im:message:readonly",
      "im:message:send_as_bot",
      "im:resource",
      "sheets:spreadsheet",
      "wiki:wiki:readonly"
    ],
    "user": [
      "aily:file:read",
      "aily:file:write",
      "im:chat.access_event.bot_p2p_chat:read"
    ]
  }
}
```

4. 导入成功后，确认所有权限都是 ✅ 状态。

### 2.4 启用"机器人"能力

1. 在左侧菜单找到 **"应用能力"** → **"机器人"**
2. 点击 **开启**
3. 填写机器人名称（随便起）

### ✋ 2.5 到这里先暂停飞书平台！

> 后面的"事件订阅"和"发布"需要 OpenClaw 网关在线才能完成。
> 原因：飞书在保存事件订阅时，会实时尝试跟你的程序建立 WebSocket 连接来验证。如果网关没跑着，它找不到"接听方"，就会报错。
> **所以我们先去配 OpenClaw，启动网关，然后再回来。**

---

## 第三步：配置 OpenClaw 并启动网关

### 3.1 配置飞书渠道（二选一）

**方式 A：交互式向导（推荐）**
```powershell
openclaw channels add
```
选择 **Feishu**，按提示粘贴 App ID 和 App Secret。

**方式 B：直接改配置文件**
编辑 `C:\Users\levimin\.openclaw\openclaw.json`，加入：

```json5
{
  "channels": {
    "feishu": {
      "enabled": true,
      "dmPolicy": "open",       // "open" = 所有人可聊；"pairing" = 需要配对审批
      "groupPolicy": "open",    // "open" = 所有群组可用
      "accounts": {
        "main": {
          "appId": "cli_a922f7d1e3785bcb",
          "appSecret": "Wzai07S8TehACQ7FXQhYtezg1LcHu0UW"  
        }
      }
    }
  }
}
```

> ⚠️ **安全提醒**：appSecret 不要分享！正式环境建议换成 `"${FEISHU_APP_SECRET}"`。

### 3.2 启动网关

```powershell
openclaw gateway
```

确认看到 `[gateway] listening on ws://127.0.0.1:18789` 后，**保持黑框框别关！**

---

## 第四步：回到飞书平台，完成最后两步

### 4.1 配置事件订阅（网关必须正在运行！）

1. 回到飞书开放平台你的应用页面
2. 左侧 **"事件订阅"**
3. 选择 **"使用长连接接收事件"**（WebSocket 模式，不需要公网 IP）
4. 点击 **"添加事件"**，搜索并添加：`im.message.receive_v1`（接收消息事件）
5. 保存 —— 此时飞书会自动验证连接，看到 ✅ 绿勾就对了

### 4.2 发布应用

1. 左侧 **"版本管理与发布"**
2. 点 **"创建版本"** → 填版本号和更新说明
3. 提交审核（企业自建应用一般秒过）
4. **等管理员审批通过后才算完成！**

---

## 第五步：测试

打开飞书，找到你创建的机器人，发一条消息试试！

看到类似日志就说明飞书连接成功了：
> `[feishu] client ready`
> `[feishu] WebSocket connected`

---

## 🆘 常见翻车与急救

| 问题 | 原因 | 解决 |
|:---|:---|:---|
| `app do not have bot` | 没有开启"机器人"能力 | 回飞书平台 → 应用能力 → 开启机器人 |
| 机器人不回消息 | 应用没发布/没审批 | 去版本管理创建版本并发布 |
| 群里@机器人没反应 | 缺少 `im:message.group_at_msg` 权限 | 用上面的 JSON 重新批量导入权限 |
| 事件订阅保存失败 | OpenClaw 网关没有在运行 | 先 `openclaw gateway` 启动，再配事件订阅 |
| 发消息收到配对码 | `dmPolicy` 设为了 `pairing` | 用 `openclaw pairing approve feishu <码>` 审批，或改成 `"open"` |

---

## 📋 操作清单 Checklist

按顺序打勾，全部完成就能用了：

- [ ] 安装飞书插件 `openclaw plugins install @openclaw/feishu`
- [ ] 在飞书开放平台创建企业自建应用
- [ ] 复制 App ID 和 App Secret
- [ ] 批量导入权限 JSON
- [ ] 开启机器人能力
- [ ] **先启动 OpenClaw 网关**
- [ ] 配置事件订阅（长连接 + `im.message.receive_v1`）
- [ ] 发布应用并等待审批通过
- [ ] 在 OpenClaw 中配置飞书渠道（向导或 JSON）
- [ ] 重启网关，发消息测试
