---
name: healthcheck
description: 对 OpenClaw 部署主机做安全加固与风险等级配置。适用场景：用户要求安全审计、防火墙/SSH/更新策略加固、风险姿态评估、暴露面检查、定时安全巡检（cron）或版本状态检查。适用于运行 OpenClaw 的机器（笔记本、工作站、Pi、VPS）。
---

> 原始 `SKILL.md` 的 `description`（英文）  
> `Host security hardening and risk-tolerance configuration for OpenClaw deployments. Use when a user asks for security audits, firewall/SSH/update hardening, risk posture, exposure review, OpenClaw cron scheduling for periodic checks, or version status checks on a machine running OpenClaw (laptop, workstation, Pi, VPS).`
>
> 对应中文直译  
> `针对 OpenClaw 部署进行主机安全加固与风险容忍度配置。适用于用户请求：安全审计、防火墙/SSH/更新加固、风险姿态评估、暴露面检查、OpenClaw 的周期性 cron 检查调度，或对运行 OpenClaw 的机器（笔记本、工作站、Pi、VPS）进行版本状态检查。`

# OpenClaw 主机加固

## 概览

评估并加固运行 OpenClaw 的主机，再按用户定义的风险承受级别做配置，同时确保不断开访问。把 OpenClaw 的安全工具作为重要信号，但要明确：操作系统加固是独立步骤，需要显式执行。

## 核心规则

- 建议用高能力模型执行本 skill（如 Opus 4.5、GPT 5.2+）。如果模型较弱，要提示升级，但不要阻塞任务。
- 任何会改系统状态的操作，都必须先拿到明确批准。
- 未确认用户连接方式前，不要修改远程访问配置。
- 优先可回滚、分阶段的变更方案。
- 不要声称 OpenClaw 会自动改主机防火墙、SSH 或系统更新策略；它不会。
- 如果角色/身份不清晰，只给建议，不直接改。
- 所有让用户选择的选项必须编号，便于用户回一个数字。
- 建议检查系统级备份状态。

## 工作流（按顺序执行）

### 0）模型自检（不阻塞）

开始前先检查当前模型能力。如果低于推荐水平（如 Opus 4.5、GPT 5.2+），建议切换模型，但不要阻塞后续执行。

### 1）建立上下文（只读）

尽量先从环境推断信息，再提问。若必须提问，优先非技术语言。

按顺序确认：

1. 操作系统与版本（Linux/macOS/Windows，容器还是宿主机）
2. 权限级别（root/admin 还是普通用户）
3. 访问路径（本地控制台、SSH、RDP、tailnet）
4. 网络暴露（公网 IP、反向代理、隧道）
5. OpenClaw gateway 状态与绑定地址
6. 备份系统和状态（如 Time Machine、系统镜像、快照）
7. 部署形态（本地 mac 应用、无头 gateway 主机、远程 gateway、容器/CI）
8. 磁盘加密状态（FileVault/LUKS/BitLocker）
9. 系统自动安全更新状态
   说明：这些不是强阻塞项，但如果 OpenClaw 接触敏感数据，建议尽量满足。
10. 个人助手使用模式（本地工作站/无头远程/其他）

先只问一次：是否允许执行只读检查。若同意，默认直接执行检查，仅对无法推断项提问。不要重复问运行时或命令输出里已有的信息。

如果必须问，用非技术问题：

- “你现在是 Mac、Windows 还是 Linux？”
- “你是在这台机器上本地登录，还是从另一台机器远程连接？”
- “这台机器可被公网访问，还是只在家庭/办公内网？”
- “你是否开启了备份（如 Time Machine），并且最近可用？”
- “磁盘加密是否开启（FileVault/BitLocker/LUKS）？”
- “自动安全更新是否开启？”
- “你怎么使用这台机器？”
  例子：
  - 个人日常机器，和助手共享使用
  - 专门给助手使用的本地机器
  - 专门的远程服务器（常驻在线）
  - 其他

只有在系统上下文明确后，再问风险等级偏好。

若用户同意只读检查，按系统执行对应命令；若不同意，再提供编号选项。示例：

1. OS 信息：`uname -a`、`sw_vers`、`cat /etc/os-release`
2. 监听端口：
   - Linux：`ss -ltnup`（若不支持 `-u`，用 `ss -ltnp`）
   - macOS：`lsof -nP -iTCP -sTCP:LISTEN`
3. 防火墙状态：
   - Linux：`ufw status`、`firewall-cmd --state`、`nft list ruleset`（按可用项执行）
   - macOS：`/usr/libexec/ApplicationFirewall/socketfilterfw --getglobalstate` 与 `pfctl -s info`
4. 备份（macOS）：`tmutil status`

### 2）执行 OpenClaw 安全审计（只读）

默认只读检查里，执行 `openclaw security audit --deep`。仅当用户要求时再提供替代：

1. `openclaw security audit`（更快，不做探测）
2. `openclaw security audit --json`（结构化输出）

可选地询问是否应用 OpenClaw 安全默认值（编号）：

1. `openclaw security audit --fix`

必须明确说明：`--fix` 只会收紧 OpenClaw 默认项和文件权限，不会改主机防火墙、SSH 或系统更新策略。

如果浏览器控制已开启，建议关键账号开启 2FA，优先硬件密钥，短信不够稳妥。

### 3）检查 OpenClaw 版本/更新状态（只读）

只读检查中执行 `openclaw update status`。

输出当前频道，以及是否有可更新版本。

### 4）确定风险承受级别（在上下文后）

让用户选择或确认风险姿态和必须开放的服务/端口（编号）。
不要把用户硬塞进固定模板；若用户更偏自定义，记录约束即可。

可给推荐模板（编号，默认多数用户选 Home/Workstation Balanced）：

1. Home/Workstation Balanced：防火墙开启、规则适中，远程访问限制在 LAN 或 tailnet
2. VPS Hardened：入站默认拒绝、最小开放端口、SSH 仅密钥、不允许 root 登录、自动安全更新
3. Developer Convenience：允许更多本地服务，但必须明确暴露风险并保持审计
4. Custom：用户自定义服务、暴露方式、更新节奏、访问方式

### 5）产出修复方案

方案必须包含：

- 目标风险模板
- 当前姿态摘要
- 与目标差距
- 分步修复命令（精确到命令）
- 访问保持与回滚策略
- 潜在锁死风险
- 最小权限建议（如避免长期 admin、收紧权限）
- 凭据卫生建议（凭据位置、建议磁盘加密）

任何改动前都要先展示方案。

### 6）提供执行选项

给用户编号选项（便于单数字回复）：

1. 你直接代执行（逐步确认）
2. 只看方案
3. 只修关键问题
4. 导出命令，稍后执行

### 7）带确认执行

每一步都要：

- 先展示具体命令
- 解释影响和回滚方法
- 确认不会中断当前访问
- 遇到异常输出立即停下并询问

### 8）复核与报告

复检以下项目：

- 防火墙状态
- 监听端口
- 远程访问是否仍可用
- OpenClaw 安全审计（再次执行）

输出最终姿态报告，并标记延期项。

## 必须确认（始终）

以下动作必须拿到明确批准：

- 防火墙规则改动
- 开/关端口
- SSH/RDP 配置变更
- 安装/卸载软件包
- 启用/停用服务
- 用户/用户组变更
- 定时任务或开机常驻
- 更新策略变更
- 访问敏感文件或凭据

有疑问就先问。

## 周期性检查

完成初次安装或首次加固后，至少执行一次基线检查：

- `openclaw security audit`
- `openclaw security audit --deep`
- `openclaw update status`

建议持续监控。可通过 OpenClaw cron 工具/CLI 安排定期审计（Gateway 调度器）。未经明确批准，不要自动创建定时任务。输出落盘路径要让用户同意，日志里避免写入密钥。

对于无头 cron 任务，输出中应附一条提示，提醒用户调用 `healthcheck` 修复问题。

### 安排定时检查时必须问的一句（始终）

每次审计/加固后，都要明确问是否安排周期任务（编号）：

1. “是否需要我通过 `openclaw cron add` 安排周期审计（例如每天/每周）？”

若用户同意，再追问：

- 周期（每天/每周）、时间窗口、输出路径
- 是否同时安排 `openclaw update status`

cron 任务名要稳定，优先使用：

- `healthcheck:security-audit`
- `healthcheck:update-status`

创建前先 `openclaw cron list`，按 `name` 精确匹配。

- 已存在：`openclaw cron edit <id> ...`
- 不存在：`openclaw cron add --name <name> ...`

也要给版本检查选项（编号）：

1. `openclaw update status`（优先，适合源码检出和多频道）
2. `npm view openclaw version`（npm 最新发布版）

## OpenClaw 命令准确性

只使用受支持命令和参数：

- `openclaw security audit [--deep] [--fix] [--json]`
- `openclaw status` / `openclaw status --deep`
- `openclaw health --json`
- `openclaw update status`
- `openclaw cron add|list|runs|run`

不要捏造 CLI 参数，也不要暗示 OpenClaw 会自动执行主机防火墙/SSH 策略。

## 日志与审计轨迹

记录内容：

- Gateway 身份与角色
- 方案 ID 与时间戳
- 已批准步骤和精确命令
- 退出码和改动文件（尽力记录）

必须脱敏，不得记录 token 或完整凭据。

## Memory 写入（条件触发）

仅当用户明确同意，且会话属于私有/本地工作区时，才写 memory 文件
（遵循 `docs/reference/templates/AGENTS.md`）。
否则仅输出可粘贴的脱敏摘要，让用户自行决定是否保存。

使用 OpenClaw 压缩流程的持久化记忆格式：

- 长期记录写入 `memory/YYYY-MM-DD.md`

每次审计/加固后，若用户同意写入，则追加一段日期化摘要，包含：
检查内容、关键发现、执行动作、是否创建 cron、关键决策、执行命令。
只追加，不覆盖。敏感主机信息要脱敏（用户名、主机名、IP、序列号、服务名、token）。

如果有长期有效偏好/决策（风险姿态、开放端口、更新策略），也可更新 `MEMORY.md`。
（长期记忆仅在私有会话中可选使用。）

若当前会话无写入权限，应先请求授权，或提供可直接粘贴到 memory 文件的文本。
