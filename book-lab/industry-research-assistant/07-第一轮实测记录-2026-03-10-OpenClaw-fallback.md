# 第一轮实测记录：OpenClaw 题材（fallback 栈）

---

## 1. 基本信息

```text
组合名称：Tavily + Firecrawl + agent-browser
agentId：industry-search-eval
飞书机器人 accountId：eval
web_search provider：Tavily（skill fallback，不是内置 default provider）
测试题材：最近 7 天 OpenClaw 最值得关注的产品、文档或社区动态
时间（开始/结束）：2026-03-10 21:22 / 2026-03-10 21:40（Asia/Shanghai）
会话标识：本地 fallback 实测
是否 /new：否
```

---

## 2. Smoke Test 证据

```text
Gateway 状态：
- running (pid 4560, RPC probe: ok)

Channel 状态：
- Feishu ceo: works
- Feishu eval: works
- Feishu main: works

当前 provider 证据：
- 本轮不是内置 web_search provider 对照
- 实际 discovery 命令为：
  tavily_search "OpenClaw latest product docs community updates" -n 8 --topic news --days 7

Kimi baseUrl（如需切回 Kimi）：
- https://api.moonshot.cn/v1

DNS 解析是否正常：
- 本轮 fallback 记录未依赖内置 web_fetch，因此不把 fake-ip 作为主阻塞点

browser 状态（内置）：
- running = false
- cdpReady = false
- 最近错误 = Failed to start Chrome CDP on port 18800 for profile "openclaw"

browser 状态（fallback）：
- agent-browser 可用
- 已验证 open / get title / snapshot / close
```

---

## 3. 发现层原始证据

### 3.1 本轮提示词 / 查询

```text
OpenClaw latest product docs community updates
OpenClaw docs GitHub releases community March 2026
site:github.com/openclaw OR site:docs.openclaw.ai OR site:x.com OpenClaw March 2026
```

### 3.2 实际搜到的来源

```text
1.
- 标题：Google makes Gmail, Drive, and Docs ‘agent-ready’ for OpenClaw
- 链接：https://www.pcworld.com/article/3079523/google-makes-gmail-drive-and-docs-agent-ready-for-openclaw.html
- 来源类型：综合媒体
- 发布时间 / 搜索摘要里的时间：最近 7 天窗口内命中；正文为 2026-03 上旬报道
- 站点：PCWorld
- 为什么值得读：直接指向 OpenClaw 与 Google Workspace CLI 的集成趋势，属于产品/生态侧变化
- 这条信息来自哪里：
  - 已读正文

2.
- 标题：Google’s new command-line tool can plug OpenClaw into your Workspace data
- 链接：https://arstechnica.com/ai/2026/03/googles-new-command-line-tool-can-plug-openclaw-into-your-workspace-data/
- 来源类型：综合媒体
- 发布时间 / 搜索摘要里的时间：2026-03
- 站点：Ars Technica
- 为什么值得读：信息更完整，解释了 Google Workspace CLI、OpenClaw 接入方式和风险
- 这条信息来自哪里：
  - 已读正文

3.
- 标题：Five Things You Should Not Do With OpenClaw
- 链接：https://www.forbes.com/sites/johnwerner/2026/03/05/five-things-you-should-not-do-with-openclaw/
- 来源类型：综合媒体
- 发布时间 / 搜索摘要里的时间：2026-03-05
- 站点：Forbes
- 为什么值得读：不是产品发布，但代表近期围绕 OpenClaw 的风险讨论
- 这条信息来自哪里：
  - 仅搜索摘要

4.
- 标题：OpenClaw Raises Questions on AI Agents Acting as Trustees
- 链接：https://news.bloomberglaw.com/legal-ops-and-tech/openclaw-raises-questions-on-ai-agents-acting-as-trustees
- 来源类型：综合媒体
- 发布时间 / 搜索摘要里的时间：最近 7 天窗口内命中
- 站点：Bloomberg Law
- 为什么值得读：代表法律/治理侧讨论，说明社区热度已经外溢到合规话题
- 这条信息来自哪里：
  - 仅搜索摘要

5.
- 标题：China’s OpenClaw-Tied Stocks Rise on Policy Support, Adoption
- 链接：https://www.bloomberg.com/news/articles/2026-03-09/china-s-openclaw-tied-stocks-rise-on-policy-support-adoption
- 来源类型：综合媒体
- 发布时间 / 搜索摘要里的时间：2026-03-09
- 站点：Bloomberg
- 为什么值得读：代表 OpenClaw 已经从产品社区扩散到资本市场和政策话题
- 这条信息来自哪里：
  - 仅搜索摘要

6.
- 标题：The OpenClaw superfan meetup serves optimism and lobster
- 链接：https://www.theverge.com/ai-artificial-intelligence/890517/openclaw-clawcon-meetup-nyc-open-source-ai
- 来源类型：综合媒体
- 发布时间 / 搜索摘要里的时间：2026-03-07
- 站点：The Verge
- 为什么值得读：典型社区动态，说明 OpenClaw 已有线下聚会与强粉丝文化
- 这条信息来自哪里：
  - 已读正文（部分）

7.
- 标题：I went to ClawCon, where OpenClaw obsessives ate free lobster tails and debated about AI
- 链接：https://www.businessinsider.com/clawcon-nyc-meetup-openclaw-photos-2026-3
- 来源类型：综合媒体
- 发布时间 / 搜索摘要里的时间：2026-03
- 站点：Business Insider
- 为什么值得读：与 The Verge 互相印证 ClawCon 社区事件
- 这条信息来自哪里：
  - 仅搜索摘要

8.
- 标题：Devs looking for OpenClaw get served a GhostClaw RAT
- 链接：https://www.csoonline.com/article/4142922/devs-looking-for-openclaw-get-served-a-ghostclaw-rat.html
- 来源类型：综合媒体
- 发布时间 / 搜索摘要里的时间：最近 7 天窗口内命中
- 站点：CSO Online
- 为什么值得读：代表安全面向的新动态，属于近期围绕 OpenClaw 的风险信息
- 这条信息来自哪里：
  - 仅搜索摘要
```

### 3.3 干扰项与坏结果

```text
- 明显跑偏的结果：第三条查询把 Grok / X 帖子也带出来了，已剔除
- 重复域名：Forbes / Business Insider / Bloomberg 多条
- 旧结果：本轮刻意用 --topic news --days 7 收紧，旧结果相对少
- 垃圾聚合站：未作为保留来源纳入
```

---

## 4. 取证层原始证据

### 4.1 实际读取清单

```text
URL 1：
- 链接：https://arstechnica.com/ai/2026/03/googles-new-command-line-tool-can-plug-openclaw-into-your-workspace-data/
- 工具：Firecrawl
- 结果：成功
- extractor：firecrawl_scrape
- 是否真正读到正文：是
- 失败原文：无

URL 2：
- 链接：https://www.theverge.com/ai-artificial-intelligence/890517/openclaw-clawcon-meetup-nyc-open-source-ai
- 工具：Firecrawl
- 结果：部分成功
- extractor：firecrawl_scrape
- 是否真正读到正文：部分读到，拿到标题、导语、日期、作者
- 失败原文：无明确报错，但正文截取不完整

URL 3：
- 链接：https://www.pcworld.com/article/3079523/google-makes-gmail-drive-and-docs-agent-ready-for-openclaw.html
- 工具：Firecrawl
- 结果：部分成功
- extractor：firecrawl_scrape
- 是否真正读到正文：读到正文，但前部夹杂大量站点导航噪声
- 失败原文：无明确报错

URL 4：
- 链接：https://github.com/googleworkspace/cli
- 工具：Firecrawl + agent-browser
- 结果：成功
- extractor：firecrawl_scrape；agent-browser get title
- 是否真正读到正文：是
- 失败原文：无

URL 5（额外失败样例）：
- 链接：https://www.pcworld.com/article/3079523/google-makes-gmail-drive-and-docs-agent-ready-for-openclaw.html
- 工具：agent-browser
- 结果：失败
- extractor：agent-browser open
- 是否真正读到正文：否
- 失败原文：page.goto: Timeout 25000ms exceeded
```

### 4.2 实际读到的事实

```text
- Ars 文章确认：Google Workspace CLI 把现有 Workspace API 打包成更容易接入 AI 工具的 CLI，并明确提到可与 OpenClaw 集成。
- Ars 文章确认：该项目来自 Google 的 GitHub 项目，但并非“官方支持的 Google 产品”。
- Ars 文章确认：该工具覆盖 Gmail、Drive、Calendar 等 Workspace API，并强调结构化 JSON 输出与 agent 使用场景。
- PCWorld 文章确认：Google Workspace CLI 文档里包含针对 OpenClaw 集成的专门说明。
- GitHub 页面确认：googleworkspace/cli 的仓库描述是“one command-line tool for Drive, Gmail, Calendar, Sheets, Docs, Chat, Admin, and more”，且页面显示最近一次提交落在 2026-03-09。
- The Verge 页面确认：ClawCon / OpenClaw meetup 相关社区活动在 2026-03-07 发生，属于最近 7 天的社区动态。
```

### 4.3 明确没读到的部分

```text
- 没取到的字段：Bloomberg / Forbes 这类站点的完整正文
- 是否只有摘要，没有正文：有，一部分来源目前只有搜索摘要
- 是否需要 JS 渲染：有些媒体站点存在动态加载或强反爬
- 是否需要登录：部分媒体站点可能需要订阅或更干净的反爬处理
```

---

## 5. 评分

```text
来源发现能力（1-5）：4
结构化程度（1-5）：4
来源透明度（1-5）：5
中文资料友好度（1-5）：2
时间新鲜度控制（1-5）：4
域名 / 来源控制（1-5）：4
可解释性（1-5）：5
成本效率（1-5）：4
适合作为默认模式的程度（1-5）：4（仅限 fallback 栈）
```

---

## 6. 失败归因

```text
- 实验未完成

原因说明：
- 本组 fallback 栈已经能完成“发现 -> 取证”的最小闭环
- 但它还没有和 Brave / Kimi 的内置发现层做完完整横评
- 同时，内置 browser 仍然失败，第一轮默认栈的全量比较还没收口
```

---

## 7. 一句话结论

```text
这组更适合：
- 快速答案层
- 内置 web_fetch / browser 失效时的 fallback 默认栈
```

---

## 8. 后续动作

```text
下一步继续测什么：
- 用同样模板补一轮题材 A（调味品行业）
- 对照 Brave / Kimi 发现层，再接 Firecrawl / agent-browser 取证

默认配置建议：
- 发现层先保留 Brave / Kimi / Tavily 三选一
- 取证层默认改成 Firecrawl
- 复杂页面默认升级到 agent-browser

是否需要切换到 ClawHub fallback：
- 需要，至少在这台机器上需要
```
