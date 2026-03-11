# main 升级为总入口与 archive-search 实验记录

这份记录不是纯概念说明，而是一次已经在真实环境里做过的架构调整记录。

这次调整要解决的核心问题是：

- `main` 到底要不要继续当默认主入口
- `weekly-assistant`、调研助手和其他专用 agent 之间怎么分工
- 某个实验 agent 退役后，聊天记录和工作文件怎么保留
- 能不能专门做一个“全局历史搜索器”

## 1. 这次调整前的实际问题

在这轮实验前，已经有多个 agent 并存：

- `main`
- `weekly-assistant`
- `industry-research-assistant`
- `personal-ceo`

实际使用下来，最明显的问题有 4 个：

1. `personal-ceo` 的日常价值边界不够清楚，和 `weekly-assistant` 有部分重叠。
2. 多个 agent 各自有自己的会话和工作区，但缺少一个清晰的“共享知识层”。
3. 退役 agent 的内容如果直接删掉，会丢掉以后可能还要复用的判断和草稿。
4. 需要一个专门负责“搜旧记录、搜跨 agent 历史”的入口，但不希望污染 `main`。

## 2. 这轮调整最终采用的结构

最后采用的是下面这套结构：

### `main`

定位：

- 默认主入口
- 总工作台
- 跨主题综合使用

这次做了两个关键调整：

1. 保留默认主 Agent 的整体思路，不重做人设。
2. 把工具面放开为 `full`，让它更适合承接日常综合任务。

### `weekly-assistant`

定位不变：

- daily / weekly 记录
- 进展跟踪
- 明天第一步
- 周计划滚动

### `industry-research-assistant`

定位不变：

- 专题研究
- 搜索验证
- 研究输出

### `archive-search`

新增加的角色：

- 全局历史搜索器
- 专门负责搜 live agent + archive + shared knowledge
- 只负责搜索和回引，不负责日常经营判断

### `personal-ceo`

处理方式：

- 不再作为活跃 agent 使用
- 先提炼有效内容
- 再归档原始 workspace 和 sessions

## 3. 这次为什么没有直接删除 `personal-ceo`

因为直接删 agent，最容易把下面这些东西一起删掉：

- 训练出来的判断口径
- 起草过的材料
- 原始会话里的细节

更稳的顺序是：

1. 先提炼共享知识
2. 再归档原始材料
3. 最后再从活跃配置里移除

这次提炼出的内容，已经进入：

- `~/.openclaw/workspace/knowledge/work/current-context.md`
- `~/.openclaw/workspace/knowledge/archive/retired-agent-summaries/personal-ceo-2026-03.md`

## 4. 共享知识层最后放在哪里

这轮确定的共享知识层位置是：

```text
~/.openclaw/workspace/knowledge/
```

这么放的原因很简单：

- `main` 本来就是默认主入口
- 共享知识更适合挂在长期存在的主 workspace 下面
- 后面其他 agent 如果需要，也容易约定去读这一层

当前已经建出的结构是：

```text
~/.openclaw/workspace/knowledge/
  README.md
  work/
  book/
  research/
  decisions/
  archive/retired-agent-summaries/
```

## 5. `archive-search` 的搜索范围是怎么定义的

这轮没有把“全部”理解成“什么文件都搜”，而是理解成：

**全部有价值的文本历史。**

当前纳入范围的是：

- `main` workspace 里的 markdown 文件
- `main` 的会话转存文本
- `weekly-assistant` 的 workspace 和会话转存文本
- `industry-search-eval` 的 workspace 和会话转存文本
- `industry-research-assistant` 的 workspace 和会话转存文本
- `~/.openclaw/workspace/knowledge/**/*.md`
- 已归档 agent 的 workspace markdown
- 已归档 agent 的 raw session 导出文本

当前明确不纳入的是：

- 凭据和密钥
- qmd 自己的缓存和 sqlite 索引
- 二进制和纯噪音文件

这套边界记录在：

- `~/.openclaw/workspace-archive-search/SCOPE.md`

## 6. 为什么要单独做 `archive-search`，而不是把一切都塞给 `main`

因为这两种需求其实不是一回事。

### `main` 更适合

- 日常问答
- 综合处理
- 起草和执行
- 跨主题协调

### `archive-search` 更适合

- 搜以前有没有聊过这个主题
- 找某个判断最早来自哪里
- 查退役 agent 留下了什么
- 跨多个 agent 找旧资料

如果把所有 raw history 都塞进 `main`，最容易出现的问题是：

- 噪音变大
- 旧判断污染新判断
- 日常聊天也被全局历史拖慢

所以更稳的是：

- `main` 继续做主入口
- `archive-search` 专门做全局历史搜索

## 7. `main` 为什么不需要重新配对

这轮还有一个很容易让人误会的点：

- 原来 `ceo` 飞书账号绑定给 `personal-ceo`
- 后来改成绑定给 `main`
- 但实际在飞书里继续聊天时，不需要重新 pairing

原因不是“它自动认出是同一个 agent”，而是：

- pairing 本质上是**谁可以和这个渠道账号说话**的审批
- routing binding 解决的是**这条消息应该进哪个 agent**

也就是说：

- pairing 更偏渠道 / 账号层
- binding 更偏 agent 路由层

这次换的是 agent 路由，不是换了一个新的飞书机器人账号，所以不需要重新 pairing。

## 8. `archive-search` 现在怎么聊天和验证

这轮实践里，`archive-search` 暂时没有单独接飞书。

原因是：

- 它是低频搜索入口
- 不值得先占一个独立机器人
- 先本地验证更稳

当前最稳的调用方式是：

```bash
openclaw agent --agent archive-search --message "请帮我搜索……"
```

为了少打一层命令，这轮还额外放了一个本地脚本：

```bash
~/.openclaw/workspace-archive-search/scripts/ask_archive_search.sh "你的问题"
```

例如：

```bash
openclaw agent --agent archive-search --message "请用中文告诉我：personal-ceo 退役后，沉淀出了哪些长期有效的判断？请区分事实和你的概括。" --json
```

这次实测已经可以返回：

- 共享知识里的总结
- 对应文件出处
- 事实和概括的区分

### 当前如果想继续验证，最推荐的 3 条问题

1. 搜退役 agent

```text
请告诉我：personal-ceo 对财务 OpenClaw 培训最核心的判断是什么？请给出处。
```

2. 跨 live agent 搜

```text
请帮我总结 weekly-assistant 和 research 这两条线最近分别在推进什么，并标注出处。
```

3. 搜共享知识层

```text
请告诉我当前 shared knowledge 里，和“当前工作主战场”相关的结论有哪些。
```

### 关于 WebUI / Dashboard 的当前结论

文档里提到：

- WebChat 会附着到 selected agent

但在这轮实际使用里，如果你当前界面里没有明显的 agent 切换入口，最稳的做法仍然是：

1. 先用 CLI 跑 `archive-search`
2. 如果后面高频使用，再考虑给它单独绑定一个渠道账号

也就是说，**当前更推荐把 `archive-search` 当成本地低频搜索工具，而不是主聊天入口。**

## 9. 以后新增或退役 agent，怎么把它纳入全局搜索

这轮没有做成一次性手工配置，而是做成了可重建方式。

当前脚本在：

- `~/.openclaw/workspace-archive-search/scripts/rebuild_global_history.py`

以后只要发生下面任一情况：

- 新增了 agent
- 退役了 agent
- 想让新的 archive 被搜到

就重跑：

```bash
python3 ~/.openclaw/workspace-archive-search/scripts/rebuild_global_history.py
openclaw gateway restart
```

## 10. 这轮实践对主线实验的意义

这轮最大的结论，不是“又多了一个 agent”，而是：

### 结论 1

默认主 Agent 依然应该是长期主入口。

### 结论 2

不是所有不满意的点都应该继续拆出新 agent。

有些需求其实更适合做成：

- 共享知识层
- 归档层
- 专门的搜索入口

### 结论 3

多 agent 体系里，真正该长期保留的通常只有少数几个：

- `main`
- `weekly-assistant`
- 1 到 2 个长期专题 agent
- 1 个低频全局搜索入口（如果需要）

## 11. 一句话总结

这轮架构调整真正想证明的是：

**默认主 Agent 可以继续做总入口；专用 agent 负责高频稳定场景；退役 agent 先进共享知识和归档层；全局历史搜索则交给单独的 `archive-search`。**
