# OpenClaw 双环境日常使用指南

这份指南将帮助你清晰地管理和使用你的两个 OpenClaw 环境：**全局正式版**（用于日常稳定使用）和 **源码研究版**（用于代码研究和二次开发）。

---

## 🌎 1. 全局正式版 (主力生产环境)

这是你主要的日常环境，建议平时都用这个版本。它极其稳定，且可以在电脑的任意位置启动。

### 📦 基本信息
- **WebUI 访问地址**: `http://127.0.0.1:18789`
- **数据与配置目录**: `C:\Users\levimin\.openclaw`
  > （你所有的聊天记录、配置文件 `openclaw.json`、插件和文件都在这个文件夹里。备份它就等于备份了你所有的工作。）

### 🚀 日常操作
- **启动服务**:
  打开任意一个终端 (CMD / PowerShell / Terminal)，直接运行：
  ```powershell
  openclaw gateway
  ```
- **如何升级到最新版**:
  当官方发布了新功能，你只需要在任意终端运行一行命令即可升级：
  ```powershell
  npm install -g openclaw@latest
  ```

---

## 🛠️ 2. 源码研究版 (安全隔离环境)

这是你克隆下来的本地代码版本。它的数据和端口与全局版完全隔离。无论你怎么修改代码、改坏配置，**都绝对不会破坏你的主力环境**。

### 📦 基本信息
- **源码所在位置**: `d:\code\anzhuang\openclaw`
- **数据隔离目录**: `d:\code\anzhuang\openclaw-data` （这个版本产生的所有数据只会在这个文件夹里）
- **WebUI 访问地址**: `http://127.0.0.1:18790`
  > （为什么被隔离了？因为我们在源码目录的 `.env` 中配置了 `OPENCLAW_STATE_DIR` 和 `OPENCLAW_GATEWAY_PORT` 变量。）

### 🚀 日常操作
- **启动服务**:
  **第一步，必须进入源码目录**（这样它才能读取我们配置好的 `.env` 隔离文件），然后再启动：
  ```powershell
  cd d:\code\anzhuang\openclaw
  pnpm openclaw gateway --allow-unconfigured
  ```
- **如何同步/更新最新源码**:
  当你想拉取作者最新的代码修改并进行研究时：
  ```powershell
  cd d:\code\anzhuang\openclaw
  git pull                # 1. 拉取最新代码
  pnpm install            # 2. 安装可能新增的依赖库
  pnpm build              # 3. 重新编译最新版代码
  ```
  > 💡 **Windows 报错提醒**: 如果你在 PowerShell 运行 `pnpm build` 时看到 `'bash' 不是内部或外部命令`，这是因为构建脚本需要 Linux 环境。
  > **解决方法**: 请使用 **Git Bash** (安装 Git 时自带的终端) 运行上述命令，或者在 Windows 中安装并配置好 Bash 环境。

  *(编译完成后，即可继续使用 `pnpm openclaw gateway` 启动最新编译的源码版本)*。

---

## 💡 常见问题 (FAQ)

**Q1: 这两个版本可以同时运行吗？**
**可以！** 我们使用了独立的端口 (`18789` 和 `18790`) 和相互独立的数据文件夹。只要你开两个终端窗口分别启动，就可以在浏览器里同时打开它们，两套身份并行工作。

**Q2: 我怎么知道当前终端运行的是哪个版本？**
看终端第一秒输出的日志：
- 全局版会显示：`listening on ws://127.0.0.1:18789`
- 源码版会显示：`listening on ws://127.0.0.1:18790`

**Q3: 如果我把源码版改报废了，或者数据目录乱了怎么办？**
直接删掉 `d:\code\anzhuang\openclaw-data` 这个文件夹。再次启动源码版时，它会像新安装的软件一样重新生成纯净的环境，完全零代价。

**Q4: 更新正式版时，我的配置和聊天记录会丢吗？**
**绝对不会。** OpenClaw 的程序（代码）和数据（配置/聊天记录）是彻底分开存储的：
- **程序**: 放在全局安装目录下。当你运行 `npm install` 时，更新的是这里。
- **数据**: 放在 `C:\Users\levimin\.openclaw`（正式版）或 `.../openclaw-data`（源码版）。更新程序**完全不会触碰**数据文件夹。你的 API Key、会话历史和设置都会原封不动地保留。

**Q5: `git pull` 更新代码会覆盖我的配置吗？**
**不会。** 因为你的 `.env` 和数据文件夹 (`openclaw-data`) 都是不归 Git 管的本地文件。无论作者更新了多少行代码，都不会动你的配置文件。

**Q6: 如何让源码环境的配置跟正式版保持一致？**
如果你在正式版里加了新插件或改了设置，想同步给源码版，只需在 PowerShell 运行：
```powershell
cp C:\Users\levimin\.openclaw\openclaw.json d:\code\anzhuang\openclaw-data\
```
这样源码版运行起来就和正式版一模一样了。
