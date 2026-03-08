# OpenClaw 小白合并手册包

这个文件夹是给“小白直接读”的，不是资料库。

说明：

- 现在 `book/` 里已经有一套更完整的主书稿。
- 这里保留的是更短、更轻的压缩版。
- 如果你想要“更完整但仍然不乱”的版本，先看 `../../README.md` 和 `../../book/`。

你可以把 `book/` 理解成“正式主书稿”，把这里理解成“压缩学习区”。

特点：

- 只保留少量核心文档。
- 优先使用官方官网和官方源码已经核验过的信息。
- 原始文档一份都没删，仍然保留在 `../docs-archive-root/`。

## 阅读顺序

1. [01-start-here.md](01-start-here.md)
2. [02-install-and-first-run.md](02-install-and-first-run.md)
3. [03-config-and-common-commands.md](03-config-and-common-commands.md)
4. [04-how-it-works-and-what-next.md](04-how-it-works-and-what-next.md)

## 这 4 份文档分别解决什么问题

- `01-start-here.md`
  先搞清楚 OpenClaw 是什么，适不适合你，不再被“它到底是聊天机器人、代码助手还是自动化平台”这种问题卡住。
- `02-install-and-first-run.md`
  直接告诉你怎么装、怎么跑、怎么确认自己已经成功。
- `03-config-and-common-commands.md`
  让你知道配置文件在哪、最常用命令有哪些、日常怎么排错。
- `04-how-it-works-and-what-next.md`
  用小白能接受的方式解释 Gateway、Agent、Tools、Skills、Memory 和源码链路，然后告诉你下一步学什么。

## 先记住 5 句话

- OpenClaw 官方定位是“personal AI assistant”，不是单纯的代码工具。
- Windows 官方推荐 WSL2，不是原生 Windows。
- 当前官方源码要求 Node `>=22.12.0`。
- 第一次跑通最重要的命令是 `openclaw onboard --install-daemon`。
- 最快的第一条聊天通常不是先接渠道，而是先跑 `openclaw dashboard`。

## 相关位置

- 官方源码快照：[../official/openclaw](../official/openclaw)
- 更细的核验清单：[../docs-curated/VERIFIED-FACTS.md](../docs-curated/VERIFIED-FACTS.md)
- 原文档整理地图：[../docs-curated/ORIGINAL-DOC-MAP.md](../docs-curated/ORIGINAL-DOC-MAP.md)
