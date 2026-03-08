# OpenClaw 学习书稿（制作中）

副标题：从第一次安装，到飞书接入、真实场景、记忆检索与工作区机制

这不是最终出版版，也不是已经定稿的目录。  
它现在是一套**正在制作、持续审阅、持续重写**的书稿工程。

你现在看到的内容，分成两层：

- 根目录：
  - 放主书稿和已经相对稳定的专题章
- `book-lab/`
  - 放仍在验证、仍在调方案、还没有升格为正式章节的实验材料

这样组织的目的很简单：

- 让主书稿目录尽量稳定
- 让实验验证继续推进，不污染正式阅读主线

## 当前项目怎么组织

### 1. 根目录：主书稿

根目录保留的是当前这版书的主要阅读路线，包括：

- 入门与安装
- 飞书接入与实操场景
- 架构与源码导读
- 记忆检索、工作区根文件这类关键专题

这些内容虽然也还在继续打磨，但已经属于“可以系统阅读”的层级。

说明一下当前编号：

- 根目录现在会从 `11` 直接跳到 `15`
- 这是因为原来 `12-14` 那组内容已经拆到 `book-lab/` 继续验证
- 等案例成熟后，再统一回收和整理编号

### 2. `book-lab/`：实验验证区

这里放的是仍在边验证边重写的材料，例如：

- 主线案例蓝图
- 完整实现与验证手册
- 某一轮测试记录与优化建议

它们对我们当前创作非常重要，但不适合直接当成正式正文章序。  
等某个案例验证稳定后，再从实验区提炼成正式章节。

入口在：

- [book-lab/README.md](book-lab/README.md)

### 3. `docs-archive-root/`：原始素材归档

原来的大量 Markdown 没有删，只是退出了主阅读路径。  
这部分主要用于：

- 回溯原始资料
- 核对旧写法
- 后续二次创作

### 4. `research/openclaw/`：官方源码快照

这部分是我们核对事实、看源码链路、校正书稿表述的重要依据。

需要注意：

- `research/openclaw/` 本身是一个独立 Git 仓库
- 它不跟随当前书稿仓库一起做版本管理
- 后面如果你要持续核对最新源码，需要定期进入这个目录执行 `git pull`

## 这套书稿现在的阅读方式

### 路线 A：第一次接触 OpenClaw

按这个顺序读最稳：

1. [00-前言与阅读说明.md](00-前言与阅读说明.md)
2. [01-OpenClaw-总览与学习路线.md](01-OpenClaw-总览与学习路线.md)
3. [02-OpenClaw-安装部署与首次跑通.md](02-OpenClaw-安装部署与首次跑通.md)
4. [03-OpenClaw-配置命令与日常维护.md](03-OpenClaw-配置命令与日常维护.md)
5. [04-OpenClaw-Channels-Feishu-多入口接入实战.md](04-OpenClaw-Channels-Feishu-多入口接入实战.md)
6. [05-OpenClaw-五个从本地到飞书的实战场景.md](05-OpenClaw-五个从本地到飞书的实战场景.md)
7. [06-OpenClaw-稳定使用-排错与安全.md](06-OpenClaw-稳定使用-排错与安全.md)
8. [07-OpenClaw-结合实操理解架构原理与源码.md](07-OpenClaw-结合实操理解架构原理与源码.md)

### 路线 B：我已经装好了，想先看场景和飞书

建议从这里开始：

1. [04-OpenClaw-Channels-Feishu-多入口接入实战.md](04-OpenClaw-Channels-Feishu-多入口接入实战.md)
2. [05-OpenClaw-五个从本地到飞书的实战场景.md](05-OpenClaw-五个从本地到飞书的实战场景.md)
3. [10-OpenClaw-飞书-12个可实操场景与配置清单.md](10-OpenClaw-飞书-12个可实操场景与配置清单.md)
4. [11-OpenClaw-飞书-行业研究助手场景.md](11-OpenClaw-飞书-行业研究助手场景.md)
5. [06-OpenClaw-稳定使用-排错与安全.md](06-OpenClaw-稳定使用-排错与安全.md)

### 路线 C：我更关心关键机制

建议优先看：

1. [07-OpenClaw-结合实操理解架构原理与源码.md](07-OpenClaw-结合实操理解架构原理与源码.md)
2. [15-OpenClaw-记忆与检索-从工作区文件到QMD.md](15-OpenClaw-记忆与检索-从工作区文件到QMD.md)
3. [16-OpenClaw-工作区根文件-AGENTS-SOUL-USER-IDENTITY-TOOLS-HEARTBEAT-BOOTSTRAP-MEMORY.md](16-OpenClaw-工作区根文件-AGENTS-SOUL-USER-IDENTITY-TOOLS-HEARTBEAT-BOOTSTRAP-MEMORY.md)

## 当前主书稿目录

### 第一部分：入门与安装

- [00-前言与阅读说明.md](00-前言与阅读说明.md)
- [01-OpenClaw-总览与学习路线.md](01-OpenClaw-总览与学习路线.md)
- [02-OpenClaw-安装部署与首次跑通.md](02-OpenClaw-安装部署与首次跑通.md)
- [03-OpenClaw-配置命令与日常维护.md](03-OpenClaw-配置命令与日常维护.md)

### 第二部分：先把它真正用起来

- [04-OpenClaw-Channels-Feishu-多入口接入实战.md](04-OpenClaw-Channels-Feishu-多入口接入实战.md)
- [05-OpenClaw-五个从本地到飞书的实战场景.md](05-OpenClaw-五个从本地到飞书的实战场景.md)
- [06-OpenClaw-稳定使用-排错与安全.md](06-OpenClaw-稳定使用-排错与安全.md)
- [07-OpenClaw-结合实操理解架构原理与源码.md](07-OpenClaw-结合实操理解架构原理与源码.md)

### 第三部分：场景深化

- [10-OpenClaw-飞书-12个可实操场景与配置清单.md](10-OpenClaw-飞书-12个可实操场景与配置清单.md)
- [11-OpenClaw-飞书-行业研究助手场景.md](11-OpenClaw-飞书-行业研究助手场景.md)

### 第四部分：关键机制专题

- [15-OpenClaw-记忆与检索-从工作区文件到QMD.md](15-OpenClaw-记忆与检索-从工作区文件到QMD.md)
- [16-OpenClaw-工作区根文件-AGENTS-SOUL-USER-IDENTITY-TOOLS-HEARTBEAT-BOOTSTRAP-MEMORY.md](16-OpenClaw-工作区根文件-AGENTS-SOUL-USER-IDENTITY-TOOLS-HEARTBEAT-BOOTSTRAP-MEMORY.md)

这部分后面还会继续补：

- 系统提示词与上下文注入
- session / dmScope / main / isolated
- cron 与 heartbeat 的正式专题章

### 附录

- [08-原文档归档与章节映射.md](08-原文档归档与章节映射.md)
- [09-术语表与核验说明.md](09-术语表与核验说明.md)

## 当前实验验证区

当前第一条主线案例已经从正式目录中拆出，进入实验区继续迭代：

- [book-lab/weekly-assistant/README.md](book-lab/weekly-assistant/README.md)

这里面现在包含：

- 主线案例蓝图
- 完整实现与验证手册
- 某一轮真实测试记录与优化建议

这些内容很重要，但目前更适合用于：

- 边实验边改
- 边审阅边重写
- 确认方案是否真能落地

等验证稳定后，再回收成正式案例章节。

## 这套书稿现在的写作原则

### 原则 1：这是制作过程，不是假装已经完稿

根目录和实验区都要清楚反映当前状态：

- 哪些是正式主线
- 哪些是实验验证
- 哪些还会继续改

### 原则 2：主书稿尽量稳定，实验稿尽量自由

主书稿负责：

- 阅读顺序
- 学习路径
- 关键机制讲清楚

实验稿负责：

- 验证一个案例是否真的能跑通
- 记录本机问题与优化过程
- 为后续正式章节沉淀材料

### 原则 3：关键事实优先参考官方源码和官网文档

尤其是这些最容易过时的内容：

- Node 版本要求
- Windows / WSL2 支持策略
- onboarding / dashboard / gateway 的真实入口
- 记忆、会话、工具和渠道的实际行为

## 接下来你可以怎么用这个仓库

如果你现在是在审阅书稿：

- 先看根目录主书稿是否顺
- 再看 `book-lab/` 里的实验材料是否值得升格成正式章节

如果你现在是在跟做验证：

- 先看 [book-lab/weekly-assistant/README.md](book-lab/weekly-assistant/README.md)

如果你现在只是想开始阅读：

- 从 [01-OpenClaw-总览与学习路线.md](01-OpenClaw-总览与学习路线.md) 开始
