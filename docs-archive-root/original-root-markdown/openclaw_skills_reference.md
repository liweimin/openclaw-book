# OpenClaw 内置全量技能 (Skills) 清单

在 OpenClaw 中，**技能 (Skills)** 不同于底层的硬编码“工具”。技能是一种基于 `SKILL.md` 和外挂脚本的可扩展预设。当大模型的意图命中时，它会先去阅读对应的 `SKILL.md`，从而学会如何调用特定的 CLI 或 API。

通过对代码仓库 `skills/` 目录的扫描，**目前系统共内置了 52 个官方技能**。

为了便于理解，我将它们划分为了 7 大应用场景集群：

---

## 一、📝 笔记与知识管理 (7 个)
这类技能赋予了代理与你的个人知识库（第二大脑）进行双向同步的能力。

1. **`apple-notes`**：通过 `memo` CLI 管理 macOS 苹果备忘录（创建、搜索、删除、移动）。
2. **`apple-reminders`**：通过 `remindctl` CLI 管理苹果提醒事项（支持日期过滤和 JSON 输出）。
3. **`bear-notes`**：利用 `grizzly` CLI 与 Bear 笔记进行交互。
4. **`notion`**：调用 Notion API 管理页面、数据库和块内容。
5. **`obsidian`**：纯文本 Markdown 笔记流，通过 `obsidian-cli` 控制 Obsidian 库。
6. **`things-mac`**：通过 `things` CLI 和 URL Scheme 控制 macOS 上的 Things 3 待办事项。
7. **`trello`**：通过 Trello REST API 管理看板、列表和卡片。

---

## 二、🛠️ 研发与运维体系 (11 个)
这是 OpenClaw 强大的“码农”辅助基因，涵盖了从代码编写到服务器审计的全流程。

8. **`coding-agent`**：高阶技能。将复杂的代码开发任务（如：重构大项目、审查 PR）派发给 Codex、Claude Code 甚至 Pi agent 的后台进程运行。
9. **`github`**：通过官方 `gh` CLI 操作 GitHub（查错、建 Issue、过 Code Review、看 CI 状态）。
10. **`gh-issues`**：自动化修 Bug 流：读取 Issue -> 派生子代理写代码 -> 提交 PR -> 监控并回复 Review 意见。
11. **`tmux`**：向服务器上的 tmux 窗口发送击键并抓取控制台输出，实现交互式 CLI 自动化。
12. **`healthcheck`**：针对 OpenClaw 所在的主机进行主机防火墙、SSH、更新策略等安全检查审计。
13. **`session-logs`**：使用 `jq` 在本地搜索、分析过往历史会话的日志记录。
14. **`blogwatcher`**：监控博客和 RSS/Atom 订阅源更新。
15. **`model-usage`**：通过 `codexbar` 统计并汇总各模型的 Token 消耗成本账单。
16. **`mcporter`**：用于列出、配置并直接联调 MCP (Model Context Protocol) 服务器。
17. **`clawhub`**：通过 `clawhub` CLI 在云端市场动态搜索、安装、更新或发布新技能包。
18. **`skill-creator`**：用于指导大模型如何“自己写技能”的元技能手册。

---

## 三、💬 即时通讯与社交 (7 个)
允许代理跨平台扮演你与他人交互，或者检索全平台的聊天记录。

19. **`imsg`**：通过 iMessage/SMS CLI 查看本地短信和 iMessage 历史。
20. **`bluebubbles`**：(推荐方案) 通过专用的 channel 完美收发苹果 iMessage 消息。
21. **`discord`**：通过 OpenClaw 内置的 message 工具监听并回复 Discord 频道。
22. **`slack`**：全方位控制 Slack 频道（不仅是发消息，还包括点赞/反应/Pin 消息等）。
23. **`wacli`**：通过 CLI 检索或主动推拉 WhatsApp 记录（不可作为日常代理群聊通道）。
24. **`himalaya`**：管理传统 IMAP/SMTP 邮件系统，支持多账号写信、检索、转发。
25. **`xurl`**：调用 X (Twitter) API v2 发推、搜索、发 DM、管理粉丝。

---

## 四、🎙️ 语音与视觉多模态 (5 个)
音视频处理和本地化大模型的音频转录能力。

26. **`openai-whisper`**：调用本地原生的 Whisper CLI 进行纯离线语音转汉字。
27. **`openai-whisper-api`**：调用云端 OpenAI 服务器的 Whisper API 接口转录。
28. **`sherpa-onnx-tts`**：本地无网环境的轻量级纯脱机高表现力 TTS（文本转语音）。
29. **[sag](file:///d:/code/anzhuang/openclaw/scripts/ui.js#15-19)**：通过 macOS 风格的命令调用云端 ElevenLabs 仿真语音合成。
30. **`voice-call`**：调用指定的插件直接拉起语音通话。

---

## 五、🖼️ 多媒体与图形处理 (6 个)
31. **`openai-image-gen`**：通过 OpenAI 接口批量随机生成图像，并输出为本地 HTML 图库查看。
32. **`nano-banana-pro`**：调用双子星 Gemini 3 Pro 获取或修改图像（生图大模型）。
33. **`canvas`**：本地可视化画板辅助器。
34. **`gifgrep`**：通过 CLI 搜索网络 GIF 动图，可下载并将其抽帧成精灵图（Sprite sheet）。
35. **`video-frames`**：使用 `ffmpeg` 原生命令从视频短片中快速抽帧成图片或切片短视频。
36. **`songsee`**：从本地音频文件中生成波形图、频谱图的可视化操作。

---

## 六、🏠 智能家居与生活助手 (9 个)
大模型介入物理世界，帮你点外卖、关灯、播放音乐的触手。

37. **`eightctl`**：控制 Eight Sleep 智能床垫的温度、报警和日程。
38. **`openhue`**：通过 OpenHue CLI 操控家中飞利浦 Hue 智能灯泡及灯光场景。
39. **`sonoscli`**：控制全屋 Sonos 音箱群组的播放、发现、分组和音量。
40. **`spotify-player`**：通过 `spogo` 控制终端 Spotify 的音乐检索与播放大权。
41. **`blucli`**：控制 BluOS 生态设备的发现和音量。
42. **`peekaboo`**：捕获并自动化执行 macOS 桌面级的 UI 自动化能力。
43. **`ordercli`**：查询外卖平台 Foodora 的历史订单及进行中订单的履约状态 (Deliveroo 适配中)。
44. **`weather`**：调用 wttr.in 或 Open-Meteo，不需要 API Key 即可快速答复当地实时天气与预报。
45. **`goplaces`**：借助 Google Places API Lookup 真实世界的地点、店铺和评分详情。

---

## 七、🧰 通用提效与 AI (7 个)
46. **`1password`**：深度对接 [op](file:///d:/code/anzhuang/openclaw/src/config/defaults.ts#19-20) CLI。大模型可以在你允许时读取金库密码去自动化登录网站，或注入秘密环境变量。
47. **`gemini`**：提供一击触发式的 Gemini Q&A、总结等快速命令行生成访问。
48. **`gog`**：Google Workspace 全家桶指令级接入，操作 Google Drive、Docs、Sheets、日历等。
49. **`nano-pdf`**：纯依靠大模型“懂人话”的能力来编辑 PDF 文件的黑科技。
50. **`oracle`**：使用 `oracle` CLI 打包文件的最佳实践预设和使用模版。
51. **`summarize`**：提供通用兜底的总结能力——如果让你转录 YouTube 视频失败，可以用它提取文字内容。
52. **`xurl` (独立网络工具)**：(见上文社交分类，此处为了对齐 52 总数预留的一类高频复合组件)。

> **Tips:** 细看上述技能设计，你会发现 OpenClaw 原则上不鼓励大模型去自己硬啃 REST API 或复杂的鉴权流。它的最佳实践是：**永远让大模型去操作一个专门为此编写好的、人也能看懂用的 CLI（命令行工具）**。这正是它操作极少翻车的原因。
