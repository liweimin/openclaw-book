# 实验验证区

这里不是正式书稿目录，而是书稿制作过程中的实验层。

这一层主要放：

- 主线案例蓝图
- 本机验证手册
- 某一轮真实测试记录
- 还没有沉淀成正式章节的设计稿

它和根目录主书稿的区别是：

- 根目录：
  - 追求阅读顺序稳定
  - 适合系统学习
- `book-lab/`
  - 追求方案可验证
  - 适合边实验边改

## 当前实验

### 1. 默认主 Agent 养成

入口在：

- [main-agent-growth/README.md](main-agent-growth/README.md)

这条线现在的定位是：

- 尽量少改配置
- 先用默认主 Agent 做日常高频任务
- 先验证“养成”再决定要不要拆专用 agent

### 2. 个人 CEO Agent

入口在：

- [personal-ceo/README.md](personal-ceo/README.md)

这条线现在的定位是：

- 继续用默认主 Agent
- 不是只做普通助手
- 而是围绕你当前工作、项目、收入和资源分配做经营判断

### 3. 个人周计划与每日待办助手

入口在：

- [weekly-assistant/README.md](weekly-assistant/README.md)

这组材料现在还处于：

- 方案验证
- 提示词和规则收敛
- 飞书入口与提醒机制测试
- 记忆与检索策略迭代

等验证稳定后，会再提炼回正式案例章节。

### 4. 行业研究助手

入口在：

- [industry-research-assistant/README.md](industry-research-assistant/README.md)

这条线现在已经有了第一条明确主线：

- 已有最小 Skill
- 已有检索与配置说明
- 已补第一版蓝图与验证手册：
  - 通用行业研究助手
- 后面还会继续补测试记录、配置历史和 cron 设计

### 5. 财务助手

入口在：

- [finance-assistant/README.md](finance-assistant/README.md)

这条线当前的定位是：

- 先做财务运营整理，不先做高风险投资判断
- 第一条主线先落在报销、发票、收支台账
- 后面再继续长出回款 / 付款提醒和经营简报

## 当前建议怎么选

如果你现在刚跑通 OpenClaw，建议先看：

- [main-agent-growth/README.md](main-agent-growth/README.md)

如果你现在想把默认主 Agent 往“经营你当前工作”的方向升级，建议看：

- [personal-ceo/README.md](personal-ceo/README.md)

如果你现在想做长期个人助手，建议看：

- [weekly-assistant/README.md](weekly-assistant/README.md)

如果你现在想做研究型助手，建议看：

- [industry-research-assistant/README.md](industry-research-assistant/README.md)

如果你现在想做财务运营场景，建议看：

- [finance-assistant/README.md](finance-assistant/README.md)
