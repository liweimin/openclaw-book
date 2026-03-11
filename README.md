# OpenClaw 写书工程（制作中）

副标题：以官方源码与既有笔记为基础，持续产出主书稿、专题章与实验案例

这个仓库现在不是“最终出版版电子书”，而是一个**正在制作中的写书工程**。

它的目标不是只整理一堆 Markdown，而是逐步产出：

- 一本系统、可售卖、可继续扩写的 OpenClaw 中文书
- 一套可复现的实验案例
- 一组可持续维护的专题章
- 一份可回溯的参考资料与核验体系

## 现在的目录怎么理解

当前仓库分成 4 层：

### 1. `book/`：正式主书稿

这里放已经进入正式章节体系的内容。

包括：

- 入门与安装
- 飞书接入与实操场景
- 架构与源码导读
- 记忆检索、工作区根文件等关键专题

入口在：

- [book/README.md](book/README.md)

### 2. `book-lab/`：实验案例与验证区

这里放还在边验证边改的实验材料，例如：

- 主线案例蓝图
- 完整实现与验证手册
- 某一轮真实测试记录
- 未来要发展成正式案例章的实验项目

入口在：

- [book-lab/README.md](book-lab/README.md)

### 3. `sources/`：参考资料与既有笔记

这里放写书用的参考来源，不直接等于正式书稿。

包括：

- 官方源码快照
- 你之前写过的原始笔记
- 由原始笔记整理出来的衍生笔记

入口在：

- [sources/README.md](sources/README.md)

### 4. `scratch/`：零散学习与单点研究

这里放实验过程中针对具体问题的研究记录。  
它的作用是：

- 帮你保存推导过程
- 为后面专题章或实验优化积累素材

入口在：

- [scratch/README.md](scratch/README.md)

## 一个很重要的原则

现在这套结构不是按“历史上文件怎么来的”组织，而是按“后续怎么持续写书”组织：

- 正式章节进 `book/`
- 完整实验进 `book-lab/`
- 参考来源进 `sources/`
- 临时研究进 `scratch/`

这样你后面再补章节、补案例、补 PDF / EPUB 产出时，目录不会越来越乱。

## 先从哪里开始

### 如果你现在要审书稿

先看：

- [book/README.md](book/README.md)

### 如果你现在要做实验

先看：

- [book-lab/README.md](book-lab/README.md)

### 如果你现在要核事实、查源码、翻旧笔记

先看：

- [sources/README.md](sources/README.md)

## Git 与版本管理

这个项目现在已经纳入 Git 管理，并同步到了：

- [liweimin/openclaw-book](https://github.com/liweimin/openclaw-book)

这意味着后面可以稳定做：

- 章节级回退
- 大改版前后对比
- 实验方案演进记录
- 后续 PDF / EPUB 出版准备

## 关于官方源码目录

需要注意：

- `sources/official/openclaw/` 本身是一个独立 Git 仓库
- 它不跟随当前写书工程一起做内容版本管理
- 它的职责是充当“官方源码参考快照”
- 如果你要持续核对最新源码，需要定期进入这个目录执行 `git pull`

## 当前最值得优先看的内容

### 主书稿

- [book/00-前言与阅读说明.md](book/00-前言与阅读说明.md)
- [book/01-OpenClaw-总览与学习路线.md](book/01-OpenClaw-总览与学习路线.md)
- [book/02-OpenClaw-安装部署与首次跑通.md](book/02-OpenClaw-安装部署与首次跑通.md)
- [book/03-OpenClaw-配置命令与日常维护.md](book/03-OpenClaw-配置命令与日常维护.md)
- [book/11-OpenClaw-多Agent实战.md](book/11-OpenClaw-多Agent实战.md)
- [book/12-OpenClaw-工具与Skill实战.md](book/12-OpenClaw-工具与Skill实战.md)

### 实验案例

- [book-lab/main-agent-growth/README.md](book-lab/main-agent-growth/README.md)
- [book-lab/personal-ceo/README.md](book-lab/personal-ceo/README.md)
- [book-lab/weekly-assistant/README.md](book-lab/weekly-assistant/README.md)
- [book-lab/industry-research-assistant/README.md](book-lab/industry-research-assistant/README.md)
- [book-lab/finance-assistant/README.md](book-lab/finance-assistant/README.md)

### 关键专题

- [book/13-OpenClaw-记忆与检索.md](book/13-OpenClaw-记忆与检索.md)
- [book/14-OpenClaw-工作区根文件指南.md](book/14-OpenClaw-工作区根文件指南.md)
