# 纯 Windows 原生避坑清单（按你当前安装流程）

更新时间：2026-03-05
适用目标：不使用 WSL2，只在 Windows 原生 PowerShell 跑 OpenClaw。

## 0. 你现在这一步（正在安装 CLI）

1. 先等当前安装命令完全结束，不要并发再开一个 `npm install -g openclaw`。
2. 安装结束后立刻检查：

```powershell
openclaw --version
node --version
npm --version
```

3. 如果提示 `openclaw 不是内部或外部命令`，先重开 PowerShell 再试一次。

## 1. PATH 和全局 npm 目录（Windows 最常见坑）

1. 查看全局安装前缀：

```powershell
npm config get prefix
```

2. 确保该目录在用户 PATH 中（Windows 下通常加前缀目录本身，不是 `\\bin`）。
3. 改完 PATH 后必须重开终端。

## 2. 首次跑通：先前台，不要先折腾后台服务

1. 跑向导：

```powershell
openclaw onboard
```

2. 先用前台方式启动网关，便于看报错：

```powershell
openclaw gateway --port 18789 --verbose
```

3. 新开一个 PowerShell，打开控制台：

```powershell
openclaw dashboard
```

4. 浏览器打不开时手动访问：`http://127.0.0.1:18789/`

## 3. 基础健康检查（每次异常先做这个）

```powershell
openclaw status
openclaw gateway status
openclaw logs --follow
```

可选（配好渠道后再用）：

```powershell
openclaw channels status --probe
```

## 4. 中文乱码/输出异常（Windows 控制台常见）

在当前 PowerShell 会话执行：

```powershell
chcp 65001 > $null
[Console]::OutputEncoding = [System.Text.UTF8Encoding]::UTF8
$OutputEncoding = [Console]::OutputEncoding
```

然后重跑刚才失败的命令。

## 5. 端口冲突（18789 被占用）

```powershell
Get-NetTCPConnection -LocalPort 18789 -State Listen
```

如果被其他进程占用，可改端口先跑通：

```powershell
openclaw gateway --port 18790 --verbose
openclaw dashboard --url http://127.0.0.1:18790/
```

## 6. 常见安装损坏修复（缺模块 ENOENT / form-data 等）

出现类似 `ENOENT ... node_modules ...` 时：

```powershell
npm uninstall -g openclaw
npm cache verify
npm install -g openclaw@latest
openclaw --version
```

如果报 `spawn git ENOENT`，安装 Git for Windows 后重开终端再装。

## 7. 确认稳定后，再安装后台服务

1. 先保证你前台跑至少 10-20 分钟稳定。
2. 再执行：

```powershell
openclaw gateway install
openclaw gateway status
```

3. 若你更偏好手动可控，也可以不装服务，直接前台运行。

## 8. 建议的数据目录备份（防止重装丢配置）

优先备份：

- `%USERPROFILE%\\.openclaw\\openclaw.json`
- `%USERPROFILE%\\.openclaw\\workspace\\`
- `%USERPROFILE%\\.openclaw\\credentials\\`

## 9. 原生 Windows 仍建议的工作习惯

1. 用 PowerShell 7（不是 CMD）。
2. 每次升级后先跑：

```powershell
openclaw --version
openclaw doctor
```

3. 先让 Dashboard 跑通，再接 WhatsApp/Telegram 等渠道。
4. 只要出现“同一问题重复两次以上”，先清理并重装 CLI，不要继续叠加尝试。

## 10. 什么时候再考虑 WSL2（可选，不强制）

只有在以下情况再考虑：

- 你需要大量依赖 Linux 工具链的 skills；
- 你频繁遇到 Windows 子进程/编码/脚本兼容问题；
- 你要做更重度的自动化和长期守护。

你当前目标是“先在 Windows 原生跑通”，按上面 0→7 的顺序执行就行。
