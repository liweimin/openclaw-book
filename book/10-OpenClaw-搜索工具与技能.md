# OpenClaw 搜索工具与技能：从 `web_search` 到 ClawHub

副标题：把网页搜索、网页取证、浏览器自动化、记忆检索和 Skills 的分工一次讲清楚

## 1. 为什么这一章很重要

很多人第一次做 OpenClaw 场景，最容易把下面这些东西混成一件事：

- `web_search`
- `web_fetch`
- `browser`
- `memory_search`
- `skill`
- `ClawHub`

一旦混在一起，就很容易出现这些误区：

- 以为“能搜索”就等于“已经读过来源”
- 以为装一个 Skill 就等于自动具备了网页研究能力
- 以为 `browser` 比 `web_fetch` 高级，所以什么都该用浏览器
- 以为 `memory_search` 也能直接替代网页搜索
- 以为所有搜索 provider 都应该一股脑打开

这一章的目标很明确：

1. 先把内置工具分工讲清楚
2. 再把 Skills 和 ClawHub 的定位讲清楚
3. 最后告诉你：面对不同研究任务，应该怎么搭配

---

## 2. 先记住一个总原则：搜索不是一个动作，而是一条链路

在 OpenClaw 里，“搜索”更稳的理解不是一个单点能力，而是 4 段链路：

1. 发现来源
2. 读取原文
3. 处理动态页面或复杂页面
4. 把流程和偏好沉淀下来

把这 4 段分别映射到 OpenClaw，通常就是：

- 发现来源：`web_search`
- 读取原文：`web_fetch`
- 处理动态页面：`browser`
- 流程沉淀与扩展：`skills`

如果你还需要跨天回忆自己的资料和结论，再加上：

- 本地记忆检索：`memory_search`

一句话：

**`web_search` 负责找，`web_fetch` 负责读，`browser` 负责操作页面，`skills` 负责把流程固定下来。**

---

## 3. 先分清 4 类“搜索”

### 3.1 `web_search`：找候选来源

它是网页发现层，不是最终证据层。

它适合做：

- 找最近 7 天有哪些相关新闻、文章、官网页面
- 找候选来源列表
- 找应该优先读哪几篇

它不适合直接代替：

- 原文取证
- 长文章内容抽取
- 登录页或 JavaScript 重页面阅读

### 3.2 `web_fetch`：把网页真正读下来

它是网页读取层。

它适合做：

- 抓文章正文
- 读公司官网页面
- 读公告、新闻稿、普通资讯页
- 把页面转成 Markdown / 可读文本

它不适合：

- 强依赖 JavaScript 的页面
- 需要点击分页、展开全文、滚动触发加载的页面
- 登录后才能看的内容

### 3.3 `browser`：把页面当页面来操作

它是浏览器自动化层。

它适合做：

- 打开复杂页面
- 点击分页
- 展开详情
- 处理动态内容
- 截图留证

它不是网页搜索引擎。  
它更像一个“可操作的独立浏览器”。

### 3.4 `memory_search`：搜自己的资料，不是搜互联网

它是本地记忆层。

它适合做：

- 搜 `MEMORY.md`
- 搜 `memory/*.md`
- 在启用对应后端后，也可以搜会话转录索引

它不适合直接代替：

- 新闻搜索
- 行业资讯发现
- 公司官网动态发现

这一部分和第十五章关系最紧密，所以这章只讲分工，不重复展开。  
更详细的机制，请接着看：

- [15-OpenClaw-记忆与检索-从工作区文件到QMD.md](/D:/00容器/openclaw/book/15-OpenClaw-记忆与检索-从工作区文件到QMD.md)

---

## 4. OpenClaw 内置的网页搜索与取证工具

## 4.1 `web_search`

### 它的能力是什么

官方当前把 `web_search` 定义成“搜索网页”的轻量工具。  
它本身支持多种 provider：

- Brave
- Gemini
- Grok
- Kimi
- Perplexity

源码和文档里都已经把这些 provider 写死了，而且缺 key 时的报错也分别做了区分。

### 它的前置条件是什么

至少要满足：

- `tools.web.search.enabled` 不是 `false`
- 配好某个 provider 对应的 API key

最常见的 key 是：

- `BRAVE_API_KEY`
- `PERPLEXITY_API_KEY`
- `OPENROUTER_API_KEY`
- `GEMINI_API_KEY`
- `XAI_API_KEY`
- `KIMI_API_KEY`
- `MOONSHOT_API_KEY`

最简单的配置入口是：

```bash
openclaw configure --section web
```

### 它有哪些能力差异

可以先记成两大类：

#### 第一类：结构化结果型

- Brave
- 原生 Perplexity Search API

这类 provider 更像搜索引擎：

- 返回结果列表
- 有 `title`
- 有 `url`
- 有 `snippet`
- 更适合“先找来源，再自己读”

其中：

- Brave 的过滤能力比较完整，适合做基础发现层
- 原生 Perplexity Search API 还支持 `domain_filter`、`max_tokens`、`max_tokens_per_page`

#### 第二类：答案综合型

- Gemini
- Grok
- Kimi

这类 provider 更像“带网页依据的答案生成器”：

- 更容易直接给综合回答
- 通常会带 citation
- 适合先快速扫一遍

但它们的问题也很明显：

- 黑盒感更强
- 可控性通常不如结构化结果型
- 更不适合直接拿来当最终证据

### 它最适合什么场景

`web_search` 最适合这几类场景：

- 给行业研究助手先找一批候选来源
- 给日报/周报场景先找最近几天的新信号
- 给品牌/公司跟踪场景先找增量信息

### 它最不适合什么场景

最不适合这两种：

- 直接把搜索结果当最终研究结论
- 明明知道页面很复杂，还坚持只用 `web_search`

一句话：

**`web_search` 最擅长“先找到应该读什么”，不是“替你完成全部研究”。**

---

## 4.2 `web_fetch`

### 它的能力是什么

`web_fetch` 是 HTTP 抓取加可读提取。

它的核心特点是：

- 发起普通 HTTP GET
- 把 HTML 转成 Markdown / 文本
- 默认就能用
- 不执行 JavaScript

OpenClaw 文档里也特别强调了：

- 它不是浏览器自动化
- 它不是登录浏览器

### 它的前置条件是什么

最小前置条件反而很低：

- `tools.web.fetch.enabled` 没被关掉
- 目标页面是可直接抓取的

如果你希望抓取更强，可以额外配：

- `FIRECRAWL_API_KEY`

这样某些抓取路径可以走 Firecrawl fallback。  
但这不是最小闭环的必需条件。

### 它最适合什么场景

最适合：

- 读资讯正文
- 读公司新闻页
- 读普通文章页
- 读新闻稿、博客、帮助文档

### 它最不适合什么场景

不适合：

- JS 动态渲染页
- 必须点开才能看到内容的页面
- 强交互站点

一句话：

**如果页面本身就能直读，优先用 `web_fetch`，通常比 `browser` 更省资源、更稳定。**

---

## 4.3 `browser`

### 它的能力是什么

`browser` 是 OpenClaw 管理的独立浏览器控制能力。

它不是简单抓网页，而是能：

- 开标签页
- 点击
- 输入
- 快照
- 截图
- 处理动态页面

文档里把它明确描述成：

- 一个 agent 专用的独立浏览器
- 与你的个人浏览器隔离

### 它的前置条件是什么

最小前置条件通常是：

- `browser.enabled: true`
- 浏览器可执行文件可用
- 最好有一个独立 profile，例如 `openclaw`

在研究场景里，更推荐：

```json5
{
  browser: {
    enabled: true,
    defaultProfile: "openclaw"
  }
}
```

### 它最适合什么场景

最适合：

- 动态站点
- 需要点击分页或切换 tab
- 需要截图留证
- 需要真实页面验证

### 它最不适合什么场景

不适合拿来做：

- 所有网页的默认入口
- 大规模替代 `web_fetch`

因为这样会：

- 更慢
- 更重
- 更耗资源
- 更容易把简单问题复杂化

一句话：

**`browser` 是“页面操作工具”，不是“默认搜索工具”。**

---

## 4.4 `memory_search`

这一节只保留最关键的分工。

### 它的能力是什么

`memory_search` 搜的是本地资料层：

- `MEMORY.md`
- `memory/*.md`
- 如果配置了相应后端，也可以包括会话索引

### 它的前置条件是什么

至少需要：

- agent 拥有 `memory_search`
- 配好 memory backend

### 它适合什么场景

它适合：

- 回忆之前已经整理进工作区的结论
- 回忆长期偏好
- 跨天追踪自己的项目状态

### 它不适合什么场景

它不适合：

- 直接代替互联网搜索
- 代替行业新闻发现

这也是为什么：  
行业研究场景里，`memory_search` 是“历史资料补回忆”的能力，不是“先找新闻”的能力。

---

## 5. Skills：它不是搜索引擎，而是流程和扩展层

## 5.1 先讲清楚：Skill 解决什么

Skill 最擅长做的是：

- 固定流程
- 包装工具
- 扩展额外能力
- 把某类任务做成可复用模板

比如行业研究里，一个 Skill 很适合规定：

1. 先补齐研究简报
2. 再确认范围
3. 再开始搜
4. 再按固定结构输出

这也是为什么我们之前整理出的经验是：

**行业研究不是只写一个 `SKILL.md` 就够了。**  
真正的最小闭环更接近：

`飞书 + Skill + web_search/web_fetch/browser + memory + cron`

### 5.2 Skill 的前置条件是什么

Skill 真正能用，至少要满足：

- Skill 文件放在正确位置
- Skill 没被 config 禁用
- 它要求的 `env`、`bins`、`config` 满足
- 开一个新 session，让它进入新的 skills snapshot

OpenClaw 官方现在把 Skills 的加载位置分成 3 层：

1. bundled skills
2. `~/.openclaw/skills`
3. `<workspace>/skills`

而且同名时：

- workspace 技能优先级最高

### 5.3 Skill 最适合什么场景

最适合：

- 把研究助手做成“先问再做”的稳定流程
- 包装额外 provider
- 把外部工具做成可复用能力
- 把重复工作做成标准操作

### 5.4 Skill 最不适合什么场景

最不适合：

- 代替网页抓取能力
- 代替浏览器能力
- 代替记忆系统

一句话：

**Skill 是“编排层”，不是“搜索层”。**

---

## 6. ClawHub：找技能，不是找新闻

ClawHub 是 OpenClaw 的公共技能注册表。

它的作用是：

- 搜技能
- 装技能
- 更新技能
- 发布技能

它不是：

- 网页搜索引擎
- 行业资讯数据库
- 新闻聚合器

所以在研究场景里，ClawHub 的正确作用是：

- 帮你找“搜索增强 Skill”
- 帮你找“研究流程 Skill”
- 帮你找“抓取 / 提取 / RSS / 定时化 Skill”

而不是直接帮你研究行业。

### 它的前置条件是什么

最小前置条件是：

- 装好 `clawhub` CLI

例如：

```bash
npm i -g clawhub
```

然后你就可以：

```bash
clawhub search "research"
clawhub install <skill-slug>
```

### 它最适合什么场景

最适合：

- 官方内置能力不够时，补装一个外部 Skill
- 为某个垂直任务找现成能力
- 管理和更新自己的 Skills

---

## 7. 面对真实任务，应该怎么选

这一节最重要。

## 7.1 如果你只是要先找来源

推荐：

- `web_search`

典型场景：

- 最近 7 天中国调味品行业有哪些变化
- 最近一周 OpenClaw 有哪些新动态

## 7.2 如果你已经有网址，只是要读内容

推荐：

- `web_fetch`

典型场景：

- 读公司官网新闻
- 读一篇行业文章
- 读帮助文档

## 7.3 如果页面很复杂、必须点开、必须截图

推荐：

- `browser`

典型场景：

- 动态站点
- 报表页
- 多分页内容
- 需要截图给管理层看

## 7.4 如果你要跨天回忆自己做过的研究

推荐：

- `memory_search`
- `MEMORY.md`
- `memory/*.md`

## 7.5 如果你要把一套研究方法长期复用

推荐：

- `Skill`
- 必要时再通过 ClawHub 找增强能力

---

## 8. 给行业研究场景的推荐搭配

这里给一个最稳的起步组合。

### 第一层：最小可用版

- `web_search`
- `web_fetch`

适合：

- 先找来源
- 再读原文

### 第二层：研究增强版

- `web_search`
- `web_fetch`
- `browser`

适合：

- 来源里有复杂站点
- 需要截图或页面验证

### 第三层：长期助手版

- `web_search`
- `web_fetch`
- `browser`
- `Skill`
- `memory`
- `cron`

适合：

- 行业日报
- 周报
- 长期跟踪

这也是为什么在行业研究实验里，我们最终更看重的是：

**先把“搜索栈”讲清楚，再把它接进长期工作流。**

---

## 9. 新手最容易踩的坑

### 坑一：把搜索结果当结论

搜索结果只能说明“这里可能有线索”，不说明“结论已经成立”。

### 坑二：一上来就用 `browser`

简单页面应该先 `web_fetch`。  
不要把浏览器当默认抓取器。

### 坑三：以为 Skill 自己会搜网页

Skill 只会规定流程。  
真正搜网页的，还是 `web_search` / `web_fetch` / `browser`。

### 坑四：把 `memory_search` 当互联网搜索

它搜的是你自己的资料层，不是公网。

### 坑五：一开始就把所有 provider 全开

更稳的做法是：

1. 先选一个默认搜索 provider
2. 把 `web_fetch` 和 `browser` 配顺
3. 再按需加 Skills 或额外 provider

---

## 10. 本章最重要的结论

把这几句话记住，后面选型就不会乱：

- `web_search`：先找来源
- `web_fetch`：再读原文
- `browser`：处理复杂页面
- `memory_search`：回忆自己的资料
- `Skill`：把流程固定下来
- `ClawHub`：补装技能，不是直接搜行业

如果你要做行业研究、日报、周报、品牌监测，最稳的路线通常不是“只靠一个工具”，而是：

**先用 `web_search` 找，再用 `web_fetch` / `browser` 读，再用 Skill、Memory、Cron 把流程做成长期助手。**

