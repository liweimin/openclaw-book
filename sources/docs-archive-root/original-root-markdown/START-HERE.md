# OpenClaw 文档整合入口

这份目录现在分成三层：

- 原始文档：仍然保留在仓库根目录，不删除、不覆盖。
- 小白合并包：新增在 `sources/docs-beginner-pack/`，用于直接阅读。
- 整合导航：新增在 `sources/docs-curated/`，用于更细的分类、核验和原文档映射。

建议从这里开始：

- [小白合并手册包](../../docs-beginner-pack/README.md)
- [整合学习导航](../../docs-curated/README.md)
- [源码与官网核验清单](../../docs-curated/VERIFIED-FACTS.md)
- [原文档总索引](../../docs-curated/ORIGINAL-DOC-MAP.md)

本次核验还拉取了官方 GitHub 源码到：

- [sources/official/openclaw](../../official/openclaw)

使用规则：

1. 如果本地旧文档和官方文档冲突，优先以官网和官方源码为准。
2. 如果是安装、命令、端口、平台支持这类“容易过时”的信息，先看核验清单。
3. 如果你是第一次接触 OpenClaw，优先读 `sources/docs-beginner-pack/`，不要直接从历史归档里挑。
4. 如果你是 Windows 用户，先理解官方推荐的 WSL2 路线，再决定是否参考根目录中的原生 Windows 经验文档。
