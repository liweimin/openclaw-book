# docs-curated 说明

这个目录现在不再承担“主入口”角色。

主入口已经回到根目录：

- [../../README.md](../../README.md)
- [../../book/00-前言与阅读说明.md](../../book/00-前言与阅读说明.md)
- [../../book/01-OpenClaw-总览与学习路线.md](../../book/01-OpenClaw-总览与学习路线.md)
- [../../book/02-OpenClaw-安装部署与首次跑通.md](../../book/02-OpenClaw-安装部署与首次跑通.md)
- [../../book/03-OpenClaw-配置命令与日常维护.md](../../book/03-OpenClaw-配置命令与日常维护.md)
- [../../book/04-OpenClaw-Channels-Feishu-多入口接入实战.md](../../book/04-OpenClaw-Channels-Feishu-多入口接入实战.md)
- [../../book/05-OpenClaw-五个从本地到飞书的实战场景.md](../../book/05-OpenClaw-五个从本地到飞书的实战场景.md)
- [../../book/06-OpenClaw-稳定使用-排错与安全.md](../../book/06-OpenClaw-稳定使用-排错与安全.md)
- [../../book/07-OpenClaw-结合实操理解架构原理与源码.md](../../book/07-OpenClaw-结合实操理解架构原理与源码.md)
- [../../book/08-原文档归档与章节映射.md](../../book/08-原文档归档与章节映射.md)
- [../../book/09-术语表与核验说明.md](../../book/09-术语表与核验说明.md)

## 这个目录现在保留什么

### 1. 核验清单

- [VERIFIED-FACTS.md](VERIFIED-FACTS.md)

用于记录已经结合官方源码和官网核过的关键事实，比如：

- Windows 官方推荐 WSL2
- Node 版本要求
- onboarding / dashboard / gateway 的真实入口
- 当前源码链路对应的位置

### 2. 原文档地图

- [ORIGINAL-DOC-MAP.md](ORIGINAL-DOC-MAP.md)

用于说明根目录原始文档已经搬到哪里，以及它们大致属于什么主题。

## 原文档现在在哪里

原来根目录的 Markdown 统一归档到了：

```text
../docs-archive-root/original-root-markdown/
```

如果你只是想学 OpenClaw，请优先读 `../../book/` 里的主书稿，不要从归档区开始。
