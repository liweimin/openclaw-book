# OpenClaw 记忆系统：从原理到实践的深度解析

本文档整理了关于 OpenClaw 记忆后端（内置与 QMD）、存储逻辑、系统提示词以及运行机制的深入探讨。

## 1. 核心组件与依赖关系

在 OpenClaw 中，高性能记忆搜索（QMD 后端）依赖于以下三层结构：

- **Bun**：现代、极速的 JavaScript 运行时环境。QMD 是基于 Bun 构建的，因此它是 QMD 运行的基石。
- **SQLite3**：轻量级数据库。用于存储 QMD 生成的向量索引和关键词索引，确保检索的高效性。
- **QMD (Quick Markdown)**：OpenClaw 专用的高性能 Markdown 搜索引擎。

### QMD vs. 内置后端 (SQLite Core)
| 特性 | 内置后端 (Built-in) | QMD 后端 (Experimental) |
| :--- | :--- | :--- |
| **安装门槛** | 零依赖（随 Node.js 自然运行） | 需安装 Bun 和 QMD CLI |
| **性能极限** | 适合中小规模数据 | 极致优化，适合海量聊天记录 |
| **本地 Embedding** | 依赖 `node-llama-cpp`（安装较繁琐） | 通过 Bun 打包，本地化支持更顺滑 |
| **稳定性** | 非常稳定 | 实验性功能，WSL2/Linux 表现最佳 |

---

## 2. 存储与搜索逻辑

### `memory/` vs. `sessions/`
- **`memory/` (知识库)**：包含 `MEMORY.md`（长期记忆）和 `YYYY-MM-DD.md`（每日日志）。这是 Agent 的“图书馆”，由 Agent 主动写入或用户手动维护。
- **`sessions/` (历史记录)**：原始的对话转录。开启 QMD 的 `sessions` 索引后，Agent 可以跨会话搜索之前的“聊天细节”。

### 混合搜索 (Hybrid Search)
无论是内置还是 QMD，都支持**语义+关键词**混合搜索：
1. **关键词搜索 (BM25)**：处理精确匹配（如“项目代号 X-20”）。
2. **语义搜索 (Vector)**：理解意图（如搜索“关于水果的话题”，能搜到“苹果”、“香蕉”）。

---

## 3. 系统提示词 (System Prompts) 揭秘

Agent 为什么“有条理”？全靠内置的系统指令。

### 行为一：先翻书后回答 (Memory Recall)
系统在 `## Memory Recall` 章节插入强制指令：
> "在回答任何关于历史工作、决策、偏好或待办事项的问题前：请对 `MEMORY.md` 和 `memory/*.md` 运行 `memory_search`；执行 `memory_get` 提取必要行。如果搜索后信心不足，请告知用户已检查过。"

### 行为二：遗忘前归档 (Memory Flush)
当对话轮次即将超出窗口限制时，系统会触发“刷新轮次”：
- **提示词**：“对话即将压缩，请立即保存重要记忆（使用 `memory/YYYY-MM-DD.md`；若无 `memory/` 目录请创建）。如果是已有文件，请务必使用 **APPEND**（追加）内容。”

---

## 4. 自动化运行机制

### 目录与文件创建
OpenClaw 默认不创建 `memory/` 文件夹。只有当 Agent 决定记录重要信息并调用文件工具时，系统才会**按需自动创建**。

### WSL 环境优势
QMD 在 **WSL2** (Windows Subsystem for Linux) 环境下运行效率极高。对于高阶用户，推荐在 WSL 中补齐三键套（Bun, QMD, SQLite3）以开启极致记忆体验。

---
*本文档由用户与 Antigravity 在 2026-03-08 讨论后整理汇编。*
