# OpenClaw Windows 原生安装配置指南（小白版）

> 日期：2026-03-05
> 说明：官方更推荐 WSL2。本文是你明确要求的 Windows 原生路径。

## 1. 你会得到什么

完成后你可以：
- 在 Windows 原生环境安装 OpenClaw
- 完成首次向导配置
- 让 Gateway 作为后台服务常驻运行
- 知道“服务”和“前台运行”区别
- 遇到常见报错可自行排查

## 2. 前置准备

要求：
- Windows 10/11
- PowerShell 5+
- 可联网

先检查 PowerShell 版本：

```powershell
$PSVersionTable.PSVersion
```

## 3. 安装 OpenClaw

在 PowerShell 里执行：

```powershell
iwr -useb https://openclaw.ai/install.ps1 | iex
```

如果你只想安装，不立刻进入向导：

```powershell
& ([scriptblock]::Create((iwr -useb https://openclaw.ai/install.ps1))) -NoOnboard
```

## 4. 验证安装

```powershell
node -v
npm -v
openclaw --version
```

如果 `openclaw` 不可识别，先看第 9 节“PATH 问题”。

## 5. 首次配置 + 安装后台服务（重点）

```powershell
openclaw onboard --install-daemon
```

这条命令会做两件事：
- 启动首次向导（模型、网关、认证、渠道等）
- 安装后台服务（daemon/service）

## 6. 小白必懂：什么叫“服务”

- 服务（service/daemon）：后台常驻，不依赖当前 PowerShell 窗口。
- 前台运行：程序绑在当前窗口，关窗口或 `Ctrl + C` 就会停。

所以：
- 你执行了 `openclaw onboard --install-daemon`，通常就是服务模式。
- 没安装服务时，只能前台临时跑：

```powershell
openclaw gateway run
```

## 7. 安装后检查

```powershell
openclaw gateway status
openclaw doctor
openclaw dashboard
```

说明：
- `gateway status`：看服务是否在跑
- `doctor`：检查并修复常见问题
- `dashboard`：打开本地控制台（通常 `http://127.0.0.1:18789/`）

## 8. 日常管理命令

```powershell
openclaw gateway start
openclaw gateway stop
openclaw gateway restart
openclaw gateway uninstall
```

临时调试可用前台模式：

```powershell
openclaw gateway run
```

## 9. 常见报错排查

### 9.1 `openclaw` 不是内部或外部命令

检查 npm 前缀：

```powershell
npm config get prefix
```

把该目录加入用户 PATH（常见是 `%AppData%\npm`），重开 PowerShell。

### 9.2 `npm error spawn git ENOENT`

没有 Git。安装 Git for Windows 后重开 PowerShell，再重试安装。

### 9.3 服务没有安装成功/没有启动

先看状态：

```powershell
openclaw gateway status
```

再尝试重装与重启：

```powershell
openclaw gateway install
openclaw gateway restart
```

### 9.4 端口冲突（18789 被占用）

临时改端口前台运行：

```powershell
openclaw gateway run --port 18889
```

或重新跑向导改端口：

```powershell
openclaw onboard
```

## 10. 升级与卸载

升级：

```powershell
iwr -useb https://openclaw.ai/install.ps1 | iex
openclaw doctor
openclaw gateway restart
```

卸载：

```powershell
openclaw uninstall
```

## 11. 官方参考

- 安装总览：https://docs.openclaw.ai/install/index
- 安装器内部机制：https://docs.openclaw.ai/install/installer
- Gateway CLI：https://docs.openclaw.ai/cli/gateway
- Windows（WSL2，官方推荐路径）：https://docs.openclaw.ai/platforms/windows
