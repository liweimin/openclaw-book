---
name: gemini
description: Gemini CLI，用于一次性问答、摘要和内容生成。
homepage: https://ai.google.dev/
metadata:
  {
    "openclaw":
      {
        "emoji": "♊️",
        "requires": { "bins": ["gemini"] },
        "install":
          [
            {
              "id": "brew",
              "kind": "brew",
              "formula": "gemini-cli",
              "bins": ["gemini"],
              "label": "安装 Gemini CLI（brew）",
            },
          ],
      },
  }
---

> 原始 `SKILL.md` 的 `description`（英文）  
> `Gemini CLI for one-shot Q&A, summaries, and generation.`
>
> 对应中文直译  
> `Gemini CLI，用于一次性问答、摘要与生成。`

# Gemini CLI

在一次性模式下使用 Gemini（把提示词直接作为位置参数传入，避免交互模式）。

快速开始

- `gemini "回答这个问题..."`
- `gemini --model <name> "提示词"`
- `gemini --output-format json "按 JSON 返回"`

扩展

- 列出扩展：`gemini --list-extensions`
- 管理扩展：`gemini extensions <command>`

说明

- 如果需要认证，先手动运行一次 `gemini`，按提示完成登录流程。
- 出于安全原因，避免使用 `--yolo`。
