# 第十章：OpenClaw 通过飞书可落地的 12 个实操场景与配置清单

## 1. 这一章解决什么问题

如果前面几章解决的是“能不能跑起来”，这一章解决的就是：

1. OpenClaw 接上飞书后，到底能做哪些真的能落地的事。
2. 每种场景至少要开哪些配置。
3. 你在飞书里应该怎么跟它交互。

这份清单只保留“可实操”的场景，不写空泛想象。  
而且我特意把范围收紧到“通过飞书交互”这一条线上，方便你直接拿去写书。

## 2. 结论先说

基于 OpenClaw 官方飞书文档、官方在线文档，以及当前仓库里的 `../sources/official/openclaw/extensions/feishu` 插件源码，当前最值得写进书里的飞书实操场景，至少有下面 12 个：

### ⭐ 必做（基线场景）

1. 飞书私聊里的个人 AI 助手
2. 飞书私聊里读取本地工作区并输出日报/摘要
3. 飞书群里的项目答疑机器人
4. 飞书群里按话题或按成员隔离上下文

### ⭐⭐ 推荐做（效率提升场景）

5. 飞书里按任务切换模型
6. 飞书里记住你的偏好，并把会话沉淀为 Memory
7. 飞书里直接创建和改写飞书文档
8. 飞书里生成带表格、图片、附件的发布说明/周报

### ⭐⭐⭐ 进阶选做（团队与自动化场景）

9. 飞书里读取和维护 Wiki/知识库
10. 飞书里整理 Drive 文件夹和交付物归档
11. 飞书里直接给文档/文件分配协作者权限
12. 飞书里把多维表格当工单台账或业务台账来维护

如果你要再往进阶写，还有第 13 个特别适合团队化使用的场景：

13. 给每个飞书私聊用户自动分配独立 Agent 与独立工作区

> [!TIP]
> 如果你是第一次做飞书场景，建议先只做 1-4。等基线场景稳定后，再逐步做 5-8，最后再考虑 9-12。

## 3. 写书前必须统一的准备动作

### 3.1 先安装飞书插件

```bash
openclaw plugins install @openclaw/feishu
```

如果你在源码仓库里跑，也可以：

```bash
openclaw plugins install ./extensions/feishu
```

### 3.2 飞书开放平台的最小接入流程

最稳顺序是：

1. 在飞书开放平台创建企业自建应用
2. 开启机器人能力
3. 选择长连接接收事件，也就是 WebSocket 模式
4. 添加事件 `im.message.receive_v1`
5. 发布应用
6. 回到本机执行 `openclaw channels add`
7. 启动 Gateway
8. 在飞书里私聊机器人，走完 pairing

### 3.3 推荐的基线配置

下面这份配置不是“唯一正确答案”，但很适合作为书里的基线配置。  
它的思路是：先把私聊跑稳，再逐步放开群组、文档、知识库、云盘这些能力。

```json5
{
  agents: {
    defaults: {
      workspace: "D:/openclaw-workspace",
      model: {
        primary: "openai/gpt-5.2"
      },
      models: {
        "openai/gpt-5.2": { alias: "gpt" },
        "anthropic/claude-sonnet-4-5": { alias: "sonnet" }
      },
      memorySearch: {
        provider: "openai",
        model: "text-embedding-3-small",
        remote: {
          apiKey: "YOUR_OPENAI_API_KEY"
        }
      }
    }
  },
  commands: {
    text: true,
    config: false
  },
  channels: {
    feishu: {
      enabled: true,
      connectionMode: "websocket",
      dmPolicy: "pairing",
      groupPolicy: "allowlist",
      requireMention: true,
      historyLimit: 30,
      typingIndicator: true,
      resolveSenderNames: true,
      tools: {
        doc: true,
        chat: true,
        wiki: true,
        drive: true,
        perm: false,
        scopes: true
      },
      accounts: {
        main: {
          appId: "cli_xxx",
          appSecret: "xxx"
        }
      }
    }
  }
}
```

这份基线配置有 5 个重点：

1. 私聊默认走 `pairing`，这样陌生人不能直接进来。
2. 群组默认走 `allowlist`，避免一上来在所有群里暴露。
3. `requireMention: true` 让群里必须 @机器人，噪音更低。
4. 文档、Wiki、Drive、Chat、Scopes 默认打开，权限管理 `perm` 默认关闭。
5. 提前把 `memorySearch` 配好，后面“记住偏好”和“知识检索”场景才好写。

### 3.4 建议一起执行的命令

```bash
openclaw channels add
openclaw gateway restart
openclaw hooks enable session-memory
openclaw gateway status
openclaw logs --follow
```

这里的 `session-memory` 很关键。它会在你发出 `/new` 时，把会话摘要保存到工作区的 `memory/` 目录里。

### 3.5 在飞书里如何交互

你可以把飞书交互分成两类：

- 自然语言任务：直接发普通消息
- 控制指令：单独发一条以 `/` 开头的消息

最常用的控制指令是：

```text
/status
/model
/model list
/model status
/new
/reset
/compact
```

对书里的描述建议统一成下面这句话：

> 普通任务用自然语言；状态查看、会话重置、模型切换、上下文压缩用单独一条斜杠命令。

### 3.6 如何拿到飞书里的 `chat_id` 和 `open_id`

这是后面很多场景都会反复用到的动作。

获取群 `chat_id`：

1. 把机器人拉进群
2. 在群里 @机器人发一句话
3. 执行 `openclaw logs --follow`
4. 在日志里记下 `oc_xxx`

获取用户 `open_id`：

1. 给机器人私聊发消息
2. 查看 `openclaw logs --follow`
3. 在日志里记下 `ou_xxx`

如果私聊是 pairing 模式，也可以直接：

```bash
openclaw pairing list feishu
```

### 3.7 额外权限怎么处理

按场景大致分 4 档：

1. 纯聊天场景：消息接收、发消息、群成员读取、长连接事件
2. 文档/Wiki/Drive 场景：飞书文档、知识库、云盘相关权限
3. 权限分配场景：额外打开 `drive:permission`
4. 多维表格场景：额外勾选多维表格相关读写权限

这里要强调一个现实问题：

飞书开放平台的权限项名称可能随着时间调整。  
所以书里最稳的写法不是把每一个权限名字写死，而是加一句：

> 如果你怀疑权限不够，先让机器人执行一次应用权限自检，再回飞书后台补授权。

OpenClaw 当前飞书插件里有一个很实用的诊断工具：`feishu_app_scopes`。  
这意味着你完全可以写出“先自检权限，再补配置”的排错流程。

## 4. 12 个可实操场景

## 场景 1：飞书私聊里的个人 AI 助手

### 适合写进书里的定位

这是所有飞书场景的起点。  
如果这一项没跑通，后面的群聊、文档、知识库都没有意义。

### 最小配置

```json5
{
  channels: {
    feishu: {
      dmPolicy: "pairing"
    }
  }
}
```

### 在飞书里怎么用

你直接私聊机器人：

```text
帮我把今天要做的 3 件事列成待办，控制在 120 字以内。
```

第一次通常会收到 pairing code。然后在本机批准：

```bash
openclaw pairing approve feishu <CODE>
```

### 适合的书写要点

这一节重点不是“它会聊天”，而是“它已经进入飞书这个真实入口，并且只有经你批准的人能聊”。

### 验收标准

1. 飞书私聊能收到回复
2. `/status` 能正常返回状态
3. 重发同类问题时，会话上下文能延续

## 场景 2：飞书私聊里读取本地工作区并输出日报/摘要

### 这个场景为什么实用

这是 OpenClaw 和普通飞书机器人最不一样的地方之一。  
它不是只会聊，而是能从飞书里被唤起，然后去读你的本地工作区。

### 最小配置

```json5
{
  agents: {
    defaults: {
      workspace: "D:/openclaw-workspace"
    }
  }
}
```

如果你给它的工具权限很保守，还要确认没有把文件工具锁死。

### 在飞书里怎么用

```text
读取当前工作区里今天修改过的 Markdown 和日志文件，帮我整理成一份 3 段式日报：已完成、风险、下一步。
```

也可以写得更像书里的“闭环场景”：

```text
读一下 workspace 里的 release-notes 草稿和 logs 目录，把今天的变更整理成日报，先回我正文，不要直接发群。
```

### 验收标准

1. 机器人确实引用了本地工作区内容，而不是空想
2. 输出结构稳定
3. 你在飞书里一句话就能触发，不需要切到 Dashboard

## 场景 3：飞书群里的项目答疑机器人

### 这个场景最适合团队演示

很多人真正想要的，不是私聊，而是“把它放进项目群里，只在被叫到时回答”。

### 最小配置

```json5
{
  channels: {
    feishu: {
      groupPolicy: "allowlist",
      groupAllowFrom: ["oc_project_group"],
      groups: {
        "oc_project_group": {
          requireMention: true
        }
      }
    }
  }
}
```

### 在飞书里怎么用

在项目群里发：

```text
@机器人 读一下当前工作区的 README、docs 和 changelog，告诉新人这个项目先看哪三份材料。
```

### 这个场景的关键解释

1. 群组先过 allowlist
2. 再判断是否需要 @
3. 只有触发条件满足才真正回复

这三个判断拆开写，读者就不会再把“群里不回我”当成一个黑箱问题。

### 验收标准

1. 没有被加入白名单的群不回复
2. 在允许群里，不 @ 默认不回复
3. @ 后可以正常答疑

## 场景 4：飞书群里按话题或按成员隔离上下文

### 这个场景为什么比普通群聊更高级

团队群最怕的是上下文串台。  
今天聊发布，明天聊 Bug，后天聊采购，如果全挤在一个会话里，回答会越来越乱。

### 推荐配置

```json5
{
  channels: {
    feishu: {
      groupPolicy: "allowlist",
      groupAllowFrom: ["oc_project_group"],
      groups: {
        "oc_project_group": {
          requireMention: true,
          replyInThread: "enabled",
          groupSessionScope: "group_topic_sender"
        }
      }
    }
  }
}
```

### 这套配置意味着什么

- `replyInThread: "enabled"`：机器人在飞书里尽量沿着话题回复
- `groupSessionScope: "group_topic_sender"`：同一群里，不同话题、不同成员尽量分开记上下文

### 在飞书里怎么用

适合下面这种群聊：

1. 一条话题讨论发布
2. 另一条话题讨论故障
3. 不同人分别在各自话题里 @机器人

### 验收标准

1. 发布话题里的上下文不污染故障话题
2. 同群不同人各聊各的时，不容易串话
3. 读者能明显感受到“会话隔离”带来的稳定性

## 场景 5：飞书里按任务切换模型

### 这个场景适合写成“效率技巧”

同一个飞书机器人，不同任务可以临时切模型。  
比如写作用一个模型，代码分析用另一个模型。

### 建议配置

```json5
{
  agents: {
    defaults: {
      model: {
        primary: "openai/gpt-5.2"
      },
      models: {
        "openai/gpt-5.2": { alias: "gpt" },
        "anthropic/claude-sonnet-4-5": { alias: "sonnet" }
      }
    }
  }
}
```

### 在飞书里怎么用

先发：

```text
/model
```

或者：

```text
/model sonnet
```

然后再发具体任务：

```text
帮我把这段需求文档改写成适合给老板看的版本。
```

### 这一节最好顺手讲清楚的一个坑

如果你配置了 `agents.defaults.models` 白名单，那么飞书里 `/model` 只能切到白名单内的模型。  
否则会出现：

```text
Model "provider/model" is not allowed. Use /model to list available models.
```

### 验收标准

1. `/model list` 能返回可选模型
2. 切换后同一会话确实使用新模型
3. 读者理解“默认模型”和“会话级覆盖”不是一回事

## 场景 6：飞书里记住你的偏好，并把会话沉淀为 Memory

### 为什么这是长期使用的分水岭

如果每次都要重新告诉它“我喜欢简洁风格、我日报分三段、我常发这个群”，那它只是个会话机器人。  
当它能在飞书里被你要求“记住这个”，并且会话切换时还能沉淀到 Memory，它才开始像长期助手。

### 推荐配置

```json5
{
  agents: {
    defaults: {
      workspace: "D:/openclaw-workspace",
      memorySearch: {
        provider: "openai",
        model: "text-embedding-3-small",
        remote: {
          apiKey: "YOUR_OPENAI_API_KEY"
        }
      }
    }
  }
}
```

然后执行：

```bash
openclaw hooks enable session-memory
```

### 在飞书里怎么用

你可以直接说：

```text
记住：我喜欢日报用“已完成 / 风险 / 下一步”三段式，默认写简洁版。
```

聊完一个话题后，再发：

```text
/new
```

这样会话摘要会沉淀到工作区 `memory/` 下。

### 这一节必须提醒的边界

`MEMORY.md` 这种长期记忆，只会在主要私密会话中加载，不会直接暴露在群聊上下文中。  
所以“个人偏好放私聊、公共答疑放群聊”是很合理的分工。

### 验收标准

1. 机器人能按要求写入长期偏好
2. `/new` 后会话切换，但偏好没有完全丢失
3. `openclaw memory search "日报 风格"` 能搜到相应记忆

## 场景 7：飞书里直接创建和改写飞书文档

### 这是最值得写的飞书原生能力之一

OpenClaw 当前飞书插件不只是收消息，它还带有 `feishu_doc` 能力。  
这意味着你可以在飞书里直接让它创建文档、改写文档、追加文档。

### 推荐配置

```json5
{
  channels: {
    feishu: {
      tools: {
        doc: true
      }
    }
  }
}
```

### 在飞书里怎么用

两种用法都很适合写书：

第一种，给它一个飞书文档链接：

```text
把这份飞书文档改写成适合新人 onboarding 的版本，保留原结构但语气更清楚。
```

第二种，让它新建文档：

```text
根据今天工作区里的更新内容，帮我新建一篇飞书文档，标题叫《3 月 8 日项目日报》，先写成正式版。
```

### 适合顺手解释的一个实现细节

飞书文档工具在创建文档时，会尽量把当前发起对话的用户设为文档拥有高权限的协作者。  
所以“由谁在飞书里发起这条消息”是有意义的。

### 验收标准

1. 机器人能读 docx 链接内容
2. 能把 Markdown 风格内容正确写回文档
3. 新建文档后，发起人默认有权限继续查看和编辑

## 场景 8：飞书里生成带表格、图片、附件的发布说明/周报

### 为什么它值得单独成节

很多人写周报、发布说明时，不只是纯文本。  
还需要表格、流程图、截图、附件。

### 推荐配置

```json5
{
  channels: {
    feishu: {
      tools: {
        doc: true
      }
    }
  }
}
```

### 在飞书里怎么用

```text
根据当前工作区里的 changelog、截图和 release 包，生成一篇飞书发布说明。
要求：
1. 标题明确
2. 风险项用表格展示
3. 把 release-notes.png 插进去
4. 把安装包作为附件挂到文档末尾
```

### 这节最重要的一个坑

飞书文档工具支持 Markdown 写入，但 Markdown 表格不是它的强项。  
如果你要写得专业，最好明确要求：

```text
不要用 Markdown 表格，直接创建飞书表格块。
```

### 验收标准

1. 文档正文可读
2. 表格不是乱掉的纯文本
3. 图片和附件都能在文档中正常看到

## 场景 9：飞书里读取和维护 Wiki/知识库

### 这个场景适合写成“团队知识管理”

如果团队已经在飞书里用 Wiki 管知识，那么最自然的需求就是：

- 在飞书里问知识库问题
- 让 OpenClaw 帮你补写某个 Wiki 页面

### 推荐配置

```json5
{
  channels: {
    feishu: {
      tools: {
        wiki: true,
        doc: true
      }
    }
  }
}
```

### 在飞书里怎么用

```text
读一下这个 Wiki 页面，帮我总结它的流程和注意事项。
```

或者：

```text
把这个 Wiki 页面改写成 SOP 版本，结构调整成：目标、前置条件、操作步骤、回滚方案。
```

### 这个场景的底层逻辑

`feishu_wiki` 负责找 Wiki 节点。  
真正的页面正文读写，最终还是走 `feishu_doc`。

这条关系写进书里很有价值，因为它能帮助读者理解：

> Wiki 是导航层，Doc 是内容层。

### 验收标准

1. 机器人能识别 Wiki 链接
2. 能正确读取页面正文
3. 能把改写后的内容写回页面

## 场景 10：飞书里整理 Drive 文件夹和交付物归档

### 这个场景最适合“资料整理”章节

很多团队最终想要的不是聊天，而是“把交付物、周报、说明文档都归好档”。

### 推荐配置

```json5
{
  channels: {
    feishu: {
      tools: {
        drive: true
      }
    }
  }
}
```

### 在飞书里怎么用

```text
把本周新生成的交付文档整理到飞书云盘的“项目A/2026-03-08”目录下。
如果目录不存在就先创建，再把对应文档移进去。
```

### 这一节必须写明的现实限制

飞书 Bot 没有普通用户那种“我的空间根目录”。  
所以如果你要让它创建子目录，最稳的做法是：

1. 先由人工创建一个共享给机器人的父目录
2. 再让机器人在这个父目录下面建子目录、移动文件

### 验收标准

1. 它能列目录
2. 能在共享父目录下创建子目录
3. 能把文档移动到目标目录

## 场景 11：飞书里直接给文档或文件分配协作者权限

### 这个场景非常适合“从生成到分发”的闭环

很多时候真正的最后一步不是“写完文档”，而是：

- 给老板只读
- 给同事编辑
- 给群聊查看

### 推荐配置

```json5
{
  channels: {
    feishu: {
      tools: {
        perm: true
      }
    }
  }
}
```

### 在飞书里怎么用

```text
把这份飞书文档共享给测试群，只给查看权限；再给 alice@company.com 编辑权限。
```

### 这节为什么必须强调风险

权限管理是敏感操作，所以 OpenClaw 当前飞书插件里 `perm` 默认是关闭的。  
这非常合理，你在书里最好明确写成：

> 权限分配不是默认能力，而是需要显式开启的敏感能力。

### 验收标准

1. 机器人能列出当前协作者
2. 能新增协作者
3. 能区分 `view`、`edit`、`full_access`

## 场景 12：飞书里把多维表格当工单台账或业务台账来维护

### 这是飞书场景里最容易被低估的一项

当前仓库里的飞书插件源码已经注册了多维表格相关工具，包括：

- 读取表元信息
- 列字段
- 列记录
- 读单条记录
- 新增记录
- 更新记录
- 新建多维表格
- 新建字段

这意味着你完全可以把它写成“用飞书聊天来驱动业务台账”的场景。

### 配置建议

这一块在插件里不走单独的 `tools.bitable` 开关。  
只要飞书账号可用、插件加载成功，相关工具就会注册。  
但飞书开放平台侧需要给足多维表格相关权限。

最稳的书写方式是：

> 如果你计划使用多维表格，请在飞书后台额外勾选多维表格应用、表、字段、记录的读写权限；若不确定是否已经授权，先做一次应用权限自检。

### 在飞书里怎么用

```text
这是我们的多维表格链接。请先识别表结构，然后把今天新增的 3 个 Bug 录进去，字段包括标题、优先级、负责人、状态。
```

或者：

```text
把状态为“待验证”的记录全部列出来，再把其中负责人的字段统一更新成张三。
```

### 这个场景特别适合写的两个方向

1. 工单台账
2. 销售线索/客户跟进表

### 验收标准

1. 机器人能从 `/base/` 或 `/wiki/` 链接里识别出表对象
2. 能读字段结构
3. 能新增和更新记录

## 5. 一个额外的进阶场景：每个飞书私聊用户自动分配独立 Agent

这个场景不一定要放在正文主线，但非常适合放在“进阶专题”。

### 它解决的问题

如果一个团队里很多人都私聊同一个机器人，你可能不想让他们共用一个工作区和一套长期记忆。  
更稳的做法是：每个用户第一次私聊时，自动给他创建一个独立 Agent、独立 workspace。

### 参考配置

```json5
{
  channels: {
    feishu: {
      dynamicAgentCreation: {
        enabled: true,
        workspaceTemplate: "~/.openclaw/workspace-{agentId}",
        agentDirTemplate: "~/.openclaw/agents/{agentId}/agent",
        maxAgents: 20
      }
    }
  }
}
```

### 这意味着什么

当新的飞书私聊用户第一次进来时，OpenClaw 会按 `feishu-<open_id>` 生成一个独立 Agent，并写入绑定关系。  
这非常适合：

- 部门内部一人一个助手
- 顾问/乙方给多个客户开隔离助手
- 培训或教练型场景

## 6. 这 12 个场景里，最值得优先写进书的顺序

如果你后面要排章节，建议按这个顺序写：

1. 场景 1：飞书私聊个人助手
2. 场景 3：飞书群答疑机器人
3. 场景 2：飞书私聊读本地工作区
4. 场景 6：记忆与长期偏好
5. 场景 7：飞书文档生成
6. 场景 9：Wiki/知识库
7. 场景 10：Drive 归档
8. 场景 11：权限分发
9. 场景 12：多维表格台账
10. 场景 4：按话题/按成员隔离上下文
11. 场景 5：模型切换
12. 进阶：动态 Agent

这样排的好处是：

1. 先从“能用”进入
2. 再从“聊天”走到“做事”
3. 最后再进入“多人、多资产、多会话隔离”的高级能力

## 7. 写成书时最值得强调的 8 个提醒

1. 飞书不是另一个聊天壳子，它是 OpenClaw 的真实工作入口。
2. 当前飞书插件已经不止支持收发消息，还能操作文档、知识库、云盘、多维表格和权限。
3. 私聊建议保留 `pairing`，群聊建议先用 `allowlist`。
4. 群里默认最好保留 `requireMention: true`。
5. 斜杠命令要单独发一条消息，别和普通文本混写。
6. 长期偏好和 Memory 更适合在私聊里建立，不适合直接依赖群聊。
7. 文档和知识库场景很适合写成“从飞书里下达指令，再把结果写回飞书”的闭环。
8. 多维表格和权限管理是很强的能力，但也是最该强调安全边界的部分。

## 8. 本章资料来源

这份清单不是拍脑袋整理的，主要基于下面几类资料：

### 官方在线文档

- [OpenClaw Feishu 文档](https://docs.openclaw.ai/channels/feishu)
- [OpenClaw Groups 文档](https://docs.openclaw.ai/channels/groups)
- [OpenClaw Hooks 文档](https://docs.openclaw.ai/automation/hooks)
- [OpenClaw Memory 文档](https://docs.openclaw.ai/concepts/memory)
- [OpenClaw Models 文档](https://docs.openclaw.ai/concepts/models)
- [飞书开放平台](https://open.feishu.cn/app)

### 当前仓库中的官方源码与文档镜像

- `../sources/official/openclaw/docs/zh-CN/channels/feishu.md`
- `../sources/official/openclaw/docs/zh-CN/channels/groups.md`
- `../sources/official/openclaw/docs/zh-CN/automation/hooks.md`
- `../sources/official/openclaw/docs/zh-CN/concepts/memory.md`
- `../sources/official/openclaw/extensions/feishu/src/config-schema.ts`
- `../sources/official/openclaw/extensions/feishu/src/tools-config.ts`
- `../sources/official/openclaw/extensions/feishu/skills/feishu-doc/SKILL.md`
- `../sources/official/openclaw/extensions/feishu/skills/feishu-drive/SKILL.md`
- `../sources/official/openclaw/extensions/feishu/skills/feishu-wiki/SKILL.md`
- `../sources/official/openclaw/extensions/feishu/skills/feishu-perm/SKILL.md`
- `../sources/official/openclaw/extensions/feishu/src/bitable.ts`
- `../sources/official/openclaw/extensions/feishu/src/dynamic-agent.ts`

## 9. 一句话总结

如果只用一句话概括这一章，那就是：

> OpenClaw 接入飞书之后，不只是“在飞书里聊天”，而是可以通过飞书把本地工作区、长期记忆、飞书文档、Wiki、云盘、多维表格和权限分发串成一条真正可落地的工作流。


