# 默认主 Agent 养成实验区

这里放的是“先养 `main`，再按需拆专用 agent”这条实验线。

这条线要回答的不是：

- 怎么马上建很多 agent
- 怎么先写很多规则文件

而是：

- 默认主 Agent 在尽量少改配置的前提下，能不能先被养顺手
- 哪些能力可以靠日常对话慢慢适应
- 哪些长期偏好必须显式沉淀
- 到了什么边界，才值得拆成独立 agent

当前建议按这个顺序看：

1. [01-默认主Agent养成实验蓝图.md](01-默认主Agent养成实验蓝图.md)
2. [02-7天验证手册.md](02-7天验证手册.md)
3. [03-main升级为总入口与archive-search实验记录.md](03-main升级为总入口与archive-search实验记录.md)
4. [04-第二个飞书机器人接入archive-search实操.md](04-第二个飞书机器人接入archive-search实操.md)
5. [05-archive-search验证清单.md](05-archive-search验证清单.md)

## 这组材料适合什么时候用

适合：

- 你刚把 OpenClaw 跑通
- 你还不想一上来就做 agent 工程
- 你想先验证“默认主 Agent 能不能先用起来”

暂时不适合：

- 多人共享机器人
- 很重的定时任务
- 明确需要隔离工作区的长期专用助手

## 这条线和 `weekly-assistant` 的区别

- 这条线：
  - 先验证默认主 Agent 的日常养成
  - 尽量少改配置
- `weekly-assistant`：
  - 是专门为长期周计划场景设计的独立助手
  - 更适合后续做成单独 agent

最简单的理解是：

先看这条线，学会“怎么把默认主 Agent 用顺手”；  
再看 `weekly-assistant`，理解“什么时候该拆成专用助手”。

如果你已经开始进入“一个 `main` + 若干专用 agent + 共享知识 + 归档搜索”的阶段，建议接着看：

- [03-main升级为总入口与archive-search实验记录.md](03-main升级为总入口与archive-search实验记录.md)
- [04-第二个飞书机器人接入archive-search实操.md](04-第二个飞书机器人接入archive-search实操.md)
- [05-archive-search验证清单.md](05-archive-search验证清单.md)
