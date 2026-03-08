# 第二章：安装、部署与第一次跑通

## 1. 本章目标

这一章不追求“把所有功能都配完”，只解决一个问题：

如何用最少的步骤，把 OpenClaw 真正跑起来，并完成第一次可用对话。

对小白来说，第一次成功的标准不是“命令装上了”，而是：

1. `openclaw` 命令可用
2. Gateway 正常运行
3. Dashboard 能打开
4. 你能完成一次本地对话

### 1.1 本章实操场景

这一章不是“把安装文档看懂”，而是让你完成一个具体场景：

在你自己的机器上，把 OpenClaw 从 0 装好，打开 Dashboard，并把第一章那份“首个任务单”整理成一份真正可交付的行动清单文件。

### 1.2 本章产物

读完这一章，你手里至少应该有下面这 3 样东西：

- 一个能正常执行的 `openclaw` CLI
- 一个能打开的 Dashboard
- 一份 `ch02-first-run/first-plan.md`

### 1.2.1 本章实战任务卡

如果你想先抓住这一章到底“要做成什么”，直接看这 4 步：

1. 装好 WSL2 / Ubuntu（Windows 用户）或确认本机环境可用（macOS / Linux 用户）
2. 装好 OpenClaw，并完成第一次 onboarding
3. 打开 Dashboard，确认本地对话能正常工作
4. 让 OpenClaw 读取第一章写好的任务单，生成 `ch02-first-run/first-plan.md`

也就是说，这一章的真正实战不是“把命令装上”，而是：

把一份模糊目标，变成第一份真的落到工作区里的行动清单文件。

如果你在读的过程中一时看不出实战在哪，就记住本章最终要交付的就是这个文件：

```text
~/.openclaw/workspace/ch02-first-run/first-plan.md
```

### 1.3 开始前先准备什么

开始前，先确认你手里有这几样：

- 第一章写好的“首个任务单”
- 一台能联网的电脑
- 如果你是 Windows 用户，能以管理员身份打开 PowerShell

### 1.4 关于是否要借助 coding agent

这一章建议区分两个阶段：

第一阶段，首次安装：

- WSL2
- Ubuntu
- Node
- OpenClaw CLI

这部分建议尽量自己按步骤完成，不要一开始就完全依赖 coding agent。

原因很简单：首次安装是认识自己环境的过程。只有自己走过一遍，后面遇到问题时，才知道故障到底是在：

- Windows
- WSL2
- Ubuntu
- Node
- OpenClaw

第二阶段，安装完成以后：

- 手动改配置
- 接入飞书等渠道
- 写 Skills
- 跑实战场景
- 做排错和优化

这些阶段就很适合引入 coding agent 作为辅助工具。

你可以把本书的推荐原则记成一句话：

先自己把系统装起来，再让 Agent 帮你把系统用起来。

## 2. 先选路线：Windows、macOS、Linux 到底怎么选

### macOS / Linux

这两类环境基本按官方主路线直接走即可。安装器、Node 环境、守护进程模型都比较直接。

### Windows

Windows 是最容易让小白走偏的地方，因为它实际有两条路。

#### 路线 A：WSL2（官方推荐）

官方 Windows 文档明确推荐 Windows 用户通过 WSL2 使用 OpenClaw，并且推荐 Ubuntu。

这条路的优点很现实：

- Linux 运行时更统一
- Node、pnpm、shell 工具、Linux 二进制和 Skills 兼容性更好
- 后面接插件、自动化和更多工具时更省心

如果你的目标是“稳定跑通并长期使用”，建议优先走这条路。

#### 路线 B：原生 Windows

原生 Windows 不是完全不能用，但它属于：

- 可以用
- 也有人这么用
- 但更容易遇到编码、PATH、子进程、依赖和脚本兼容问题

如果你只是短时间试跑，或者你非常明确自己要坚持纯 Windows，可以试。但如果你反复遇到环境问题，最务实的做法通常不是继续硬扛，而是回到 WSL2。

## 3. WSL2 到底是什么

这是很多 Windows 用户第一次遇到 OpenClaw 时最困惑的地方，所以这里必须讲白。

微软官方对 WSL 的定义，可以用大白话概括成：

WSL2 就是在 Windows 里直接运行一个真正可用的 Linux 环境，而且不需要你单独装一台完整虚拟机，也不需要做双系统。

你可以先把它理解成：

- 你的电脑还是 Windows
- 但你在 Windows 里面又有了一个独立可用的 Ubuntu
- 你可以在里面使用 Linux 命令、Bash、apt、Node、pnpm 等开发工具

对 OpenClaw 来说，这件事非常关键，因为 OpenClaw 的很多运行时前提，本来就更接近 Linux 生态，而不是原生 Windows 生态。

如果你以前从没接触过 WSL2，不要被名字吓到。对你来说，它最重要的意义只有一句话：

你以后在 Windows 上装 OpenClaw，推荐不是在 PowerShell 里把所有东西硬装一遍，而是先装一个 Ubuntu，然后在 Ubuntu 里面按 Linux 方式装 OpenClaw。

## 4. 为什么 OpenClaw 官方推荐 WSL2

官方 Windows 文档其实已经把理由说得很清楚了：WSL2 会让运行时更一致，工具兼容性显著更高。

换成更容易理解的话，大概就是下面四点。

### 第一，OpenClaw 更像 Linux 世界里的原生公民

不管是 Node 运行时、pnpm、shell 工具，还是后面你会遇到的某些 Skills、脚本和自动化，Linux 环境通常更顺。

### 第二，少踩“只有 Windows 才有”的坑

例如：

- PATH 没刷新
- 编码问题
- 某些命令行工具缺失
- 子进程行为和 Linux 不一致

这些坑在 WSL2 路线里通常会少很多。

### 第三，后面扩展能力时更轻松

你现在也许只想把 Dashboard 打开，但后面一旦接插件、接渠道、跑更多工具，WSL2 带来的兼容性优势会越来越明显。

### 第四，和官方文档主路线一致

对小白来说，最稳的学习方法不是自己发明第三条路，而是先站在官方推荐路线之上。这样你出问题时，更容易找到对应的文档和社区经验。

## 5. Windows 小白完整路线：从零安装 WSL2 + Ubuntu

下面这部分，你可以当成“第一次用 WSL2 的极简教程”。

### 5.1 你需要什么前提

微软官方安装文档给出的前提是：

- Windows 10 2004 及以上，且 Build `19041` 及以上
- 或 Windows 11
- 能以管理员身份打开 PowerShell

如果你不确定自己的 Windows 版本，先在 PowerShell 里执行：

```powershell
winver
```

### 5.2 用一条命令安装 WSL2

以管理员身份打开 PowerShell，然后执行：

```powershell
wsl --install
```

微软官方说明，这条命令会一次性完成两件事：

- 启用运行 WSL 所需的系统功能
- 默认安装 Ubuntu 发行版

如果你是第一次装 WSL2，最简单的做法就是不要分心，直接按下面顺序做：

1. 右键开始菜单，打开“终端（管理员）”或“PowerShell（管理员）”。
2. 执行 `wsl --install`。
3. 等待系统完成启用功能和下载发行版。
4. 如果提示重启，就先重启电脑。
5. 重启后，从开始菜单打开 Ubuntu。

对小白来说，这里最重要的不是理解所有原理，而是记住一个判断标准：

- 只要 Ubuntu 还没有第一次成功打开，这一轮安装就还没真正结束。

如果你想明确指定发行版，可以先看可选列表：

```powershell
wsl --list --online
```

然后安装指定版本，例如：

```powershell
wsl --install -d Ubuntu-24.04
```

如果你的列表里显示的是 `Ubuntu` 而不是 `Ubuntu-24.04`，就按你的机器实际显示的名字来。

你可以这样选：

- 想最快开始，直接用 `wsl --install`
- 想指定版本，再用 `wsl --install -d <发行版名>`

### 5.3 如果安装卡住或提示帮助信息怎么办

这一节不要死背。你只要按“看到什么现象，就做什么处理”的方式来就行。

情况一，如果你运行 `wsl --install` 后看到的是帮助信息，而不是安装过程，通常说明 WSL 本体已经装过了，但发行版还没装。这时执行：

```powershell
wsl --list --online
wsl --install -d Ubuntu-24.04
```

情况二，如果安装过程卡在 `0.0%`，微软建议尝试：

```powershell
wsl --install --web-download -d Ubuntu-24.04
```

情况三，如果你已经能在开始菜单里看到 Ubuntu，或者执行 `wsl -l -v` 已经能看到发行版，就不要反复重装，直接继续看后面的“第一次打开 Ubuntu”和“确认是 WSL2”。

你可以把这里记成一个很朴素的排错顺序：

1. 先判断是不是没装发行版
2. 再判断是不是下载阶段卡住
3. 已经装好的环境，不要反复重来

### 5.4 重启后第一次打开 Ubuntu，会看到什么

如果系统要求重启，就先重启电脑。

重启后，你有两种进入 Ubuntu 的方式：

1. 在开始菜单里搜索 `Ubuntu`
2. 在 PowerShell 里执行 `wsl`

第一次打开时，系统会先解压 Linux 文件，然后提示你创建一个 Linux 用户名和密码。

这里要注意三件事：

- 这个用户名和密码是给 Ubuntu 用的，不是你的 Windows 账号
- 输入密码时屏幕通常不会显示字符，这是正常的
- 以后你在 Ubuntu 里执行 `sudo` 时，会用到这个密码

### 5.5 确认你现在真的是 WSL2，而不是 WSL1

回到 PowerShell，执行：

```powershell
wsl --list --verbose
```

或者：

```powershell
wsl -l -v
```

你应该能看到你的 Ubuntu 对应的 `VERSION` 是 `2`。

如果不是，就执行：

```powershell
wsl --set-default-version 2
wsl --set-version Ubuntu-24.04 2
```

如果你的发行版名字不是 `Ubuntu-24.04`，就把命令里的名字换成你实际看到的名字。

### 5.6 为什么还要启用 systemd

这是 OpenClaw 新手最容易忽略的一步。

官方 Windows 文档明确写了，WSL2 里如果要更顺地安装 Gateway 服务，应该启用 `systemd`。因为 `openclaw onboard --install-daemon` 这类后台服务安装，会用到这一层能力。

微软当前的 WSL 文档也提到，新装的 Ubuntu 发行版里，`systemd` 往往已经是默认开启的。但对新手来说，不要靠猜，最稳妥的做法仍然是手动检查一次。

直接按下面顺序做就行。

第一步，在 Ubuntu 里写入配置：

在 Ubuntu 终端里执行：

```bash
sudo tee /etc/wsl.conf >/dev/null <<'EOF'
[boot]
systemd=true
EOF
```

第二步，确认文件内容：

```bash
cat /etc/wsl.conf
```

如果你看到的是下面这两行，就说明配置已经写进去了：

```text
[boot]
systemd=true
```

第三步，回到 PowerShell，彻底关闭 WSL：

```powershell
wsl --shutdown
```

第四步，重新打开 Ubuntu。

第五步，在 Ubuntu 里确认 1 号进程是否为 `systemd`：

```bash
ps -p 1 -o comm=
```

如果输出是：

```text
systemd
```

通常就说明这一层已经真的启用了。

如果你还想再做一层确认，再执行：

```bash
systemctl --user status
```

如果没有明显报错，通常就说明 `systemd` 已经启用成功。

### 5.7 OpenClaw 应该装在哪儿，文件该放哪儿

这一节一定要讲清楚，因为很多 Windows 新手第一次接触 WSL2 时，最容易混乱的就是这三个问题：

- OpenClaw 程序装在哪儿
- OpenClaw 的配置和数据放在哪儿
- 你自己的项目目录又该放在哪儿

不要把这三件事混成一件事。

### 5.7.1 一句话先记住

如果你走的是官方推荐路线，也就是“Windows + WSL2 + Ubuntu”，那你应该这样理解：

- `OpenClaw 程序` 装在 Ubuntu 里
- `OpenClaw 的配置/数据` 也在 Ubuntu 里
- `你的工作目录` 最好也放在 Ubuntu 里的 `/home/...` 下面

换句话说，虽然你的电脑是 Windows，但 OpenClaw 实际上是在 WSL2 里的 Linux 环境中运行。

### 5.7.2 这三个“位置”分别在哪里

第一，`OpenClaw 程序`。

你后面安装 `node`、`pnpm`、`openclaw`，默认都是在 Ubuntu 终端里执行的。所以这套程序是装在 WSL2 的 Ubuntu 里的，不是装在 Windows 的 PowerShell 里。

第二，`OpenClaw 的配置和运行数据`。

这类内容通常会写到你的 Linux 用户家目录下，例如：

```text
~/.openclaw/
```

这里的 `~` 指的是 Ubuntu 里的家目录，不是 Windows 的 `C:\Users\你的用户名`。

第三，`你的项目和练习目录`。

官方和微软都更推荐：如果你主要在 WSL/Linux 终端里工作，就把项目放在 Linux 文件系统里，也就是：

```text
/home/<你的Linux用户名>/...
```

不建议你一开始就把主要工作目录放在：

```text
/mnt/c/...
```

如果你是第一次看到这个写法，先不要慌。这里的 `/mnt/c/...` 指的是：

- 你在 WSL2 的 Ubuntu 里
- 去访问 Windows 的 `C:` 盘
- 于是 Windows 的 `C:` 盘会被挂载成 Linux 路径 `/mnt/c`

你可以把它简单理解成下面这组对应关系：

```text
Windows 里的 C:\Users\你的名字\Desktop
≈
WSL2 里的 /mnt/c/Users/你的名字/Desktop
```

也就是说，`/mnt/c/...` 不是一个新硬盘，也不是 OpenClaw 自己的特殊目录，它只是：

“你在 Linux 里看到的 Windows C 盘路径”

为什么这里特意提醒你不要一开始就把主要工作目录放在 `/mnt/c/...`？

原因很简单：文件访问、权限行为、工具兼容性、性能表现，通常都是 Linux 文件系统里更省心。

对小白来说，你现在真正需要记住的只有一句话：

- `/home/...` 更像“Ubuntu 自己家里的目录”
- `/mnt/c/...` 更像“从 Ubuntu 里去用 Windows 的 C 盘”

所以如果你主要是在 Ubuntu 里跑 OpenClaw，通常更推荐把 OpenClaw 相关练习、项目和工作区放在 `/home/...`，而不是放在 `/mnt/c/...`。

### 5.7.3 这里到底要不要现在建目录

你这个疑问是对的，我这里直接说结论：

- 如果你只是想继续照着本书做后面的练习，这一步现在**不是必做**
- 因为后面真正反复复用的主练习位置，其实主要是 `~/.openclaw/workspace`
- 所以你现在不建 `~/projects/openclaw-work`，也完全不影响后面继续学

这一段真正想表达的重点，其实只有一个：

如果你是 WSL2 用户，后面无论是源码、笔记，还是你自己的项目，优先放在 Linux 家目录 `/home/...` 下面，不要优先放到 `/mnt/c/...`。

### 5.7.4 如果你以后想单独放源码和笔记，可以这样做

这一步现在改成“可选建议”，不是主线必做。

如果你后面准备：

- 克隆 OpenClaw 官方源码
- 单独放学习笔记
- 在 `~/.openclaw/workspace` 之外，再建一个自己的项目区

那你可以在 Ubuntu 里先建一个普通项目目录，例如：

```bash
mkdir -p ~/projects
cd ~/projects
pwd
```

如果你看到的是：

```text
/home/你的Linux用户名/projects
```

就说明你现在在 Linux 家目录下的普通项目区里了。

但请记住：

- 这一章后面的 OpenClaw 安装和初始化，不依赖这个 `~/projects`
- 本书后面多数练习，默认还是写在 `~/.openclaw/workspace` 里

### 5.7.5 一个最容易踩的坑

不要一会儿在 PowerShell 里装一份，一会儿又在 Ubuntu 里装一份，除非你很清楚自己在做什么。

否则你会很容易出现下面这些现象：

- Ubuntu 里能执行 `openclaw`，PowerShell 里却提示命令不存在
- 你以为改的是同一份配置，实际上改的是两个不同环境
- 文档里写的路径和你电脑里看到的路径对不上

对新手来说，最稳妥的做法就是：

- 只在 Ubuntu 里安装和运行 OpenClaw
- Windows 主要负责打开浏览器、看文件、访问图形界面

### 5.7.6 如果我想用 Windows 资源管理器查看这些文件怎么办

完全可以，而且这是 WSL2 很实用的一点。

最稳妥的做法，不是先依赖命令，而是直接在 Windows 资源管理器地址栏里输入 `\\wsl$`。

例如：

```text
\\wsl$\Ubuntu-24.04\home\<你的Linux用户名>\
```

如果你的发行版名字不是 `Ubuntu-24.04`，那就换成你自己的发行版名称。

如果你的 WSL 和 Windows 互操作正常，也可以在 Ubuntu 里尝试下面这些快捷方式：

```bash
explorer.exe .
```

或者：

```bash
powershell.exe /c start .
```

在互操作正常时，这两条命令通常都会直接弹出 Windows 资源管理器，并定位到你当前所在的 WSL 目录。

但这里一定不要把它理解成“任何机器都必然成功”。如果你看到类似下面的错误：

```text
-bash: /mnt/c/WINDOWS/explorer.exe: cannot execute binary file: Exec format error
```

这通常说明你的 WSL Windows 互操作没有正常工作。根据微软文档，常见检查点有三个：

1. 先看 `echo $PATH` 里有没有 Windows 路径，例如 `/mnt/c/Windows/System32`
2. 再看 `/etc/wsl.conf` 里有没有把互操作关掉，例如 `[interop] enabled=false`
3. 再看 `/etc/wsl.conf` 里有没有 `appendWindowsPath=false`

你可以直接这样检查：

```bash
echo $PATH
cat /etc/wsl.conf
```

如果你改过 `/etc/wsl.conf`，记得回到 PowerShell 执行：

```powershell
wsl --shutdown
```

然后重新打开 Ubuntu 再试。

所以这一节最稳的结论是：

- `\\wsl$` 是最不依赖互操作细节的主方法
- `explorer.exe .` 和 `powershell.exe /c start .` 是互操作正常时的快捷方式

### 5.7.7 小结：这一节你应该怎么记

这一节你只需要记住下面这套最小原则：

- 在 Windows 上使用 OpenClaw 时，推荐通过 WSL2 里的 Ubuntu 来安装和运行
- OpenClaw 程序和配置都在 Ubuntu 里
- 你的练习项目也优先放在 `/home/<你的Linux用户名>/...`
- Windows 负责浏览器、资源管理器和日常可视化操作

如果你现在还是不确定自己在哪个环境里，只要在终端里执行一次：

```bash
pwd
```

看到的是 `/home/...`，通常就说明你正在正确的 WSL2/Linux 工作流里。

## 6. 当前 OpenClaw 前置要求

当前官方源码中，Node 版本要求是：

```text
>=22.12.0
```

官方入门和安装文档写的是 `Node >=22`，源码里的 `package.json` 更具体，是 `>=22.12.0`。对你来说，最稳妥的理解就是：

只要你在 WSL2 的 Ubuntu 里装的是 Node 22 或 24，且版本不低于 `22.12.0`，就没问题。

但这里有一个很重要的区分：这些前置要求，并不代表你每一项都要先手动装好。

要不要你自己提前安装，取决于你选的是哪一种安装方式。

### 6.1 如果你走的是推荐路线：官方安装脚本

也就是这一种：

```bash
curl -fsSL https://openclaw.ai/install.sh | bash
```

或者原生 Windows PowerShell 这一种：

```powershell
iwr -useb https://openclaw.ai/install.ps1 | iex
```

那结论是：

- **Node 通常会由安装器自动检查，并在缺失或版本不够时自动安装 / 升级**
- Linux / macOS 的安装器脚本里，确实有自动安装 Node 22 的逻辑
- Windows PowerShell 安装器里，也有自动安装 Node 的逻辑

所以如果你走的是“官方安装器脚本”路线，通常**不需要先手动把 Node 装好再开始**。

### 6.2 为什么这里还要写 Node 要求

因为即使安装器会自动处理，读者仍然需要知道两件事：

1. OpenClaw 依赖的底层运行时到底是什么
2. 如果安装失败、PATH 异常、版本冲突，应该优先检查什么

所以这里写 Node 要求，主要是为了：

- 帮你理解系统依赖
- 帮你在出问题时有排查方向

不是为了让每个小白都先自己手动装一遍。

### 6.3 哪些情况才需要你自己先确认或手动安装

下面这些情况，才更需要你主动确认：

#### 情况一：你不用安装器，而是手动全局安装

例如：

```bash
npm install -g openclaw@latest
```

这时就意味着：

- 你得自己已经有可用的 Node 和 npm

#### 情况二：你要从源码构建

这时除了 Node，还通常需要：

- `pnpm`
- 如果走 git 方式，还需要 `git`

也就是说，`pnpm` **不是**普通小白推荐安装路线的硬前置；它主要是“从源码构建时需要”。

### 6.4 对小白最实用的判断规则

你可以直接这样记：

- 如果你走 **官方安装器脚本**：先直接装，Node 通常会自动处理
- 如果你走 **npm / pnpm 手动安装**：你要自己先有 Node
- 如果你走 **源码构建**：你要自己准备 Node、pnpm，通常还要有 git

### 6.5 真要检查时，看这几条就够了

如果你想确认当前环境，或者安装失败后要排查，再看下面这些命令：

```bash
node --version
npm --version
```

如果你打算从源码构建，再额外确认：

```bash
pnpm --version
git --version
```

你现在可以直接用下面这个标准判断自己能不能继续往下走：

- 走官方安装器：可以先继续装，不必卡在这里手动补齐
- 走手动 `npm install -g`：`node` 和 `npm` 都要可用
- 走源码构建：`node`、`pnpm`，通常还要 `git` 可用

## 7. 安装 OpenClaw：推荐怎么选

OpenClaw 常见有三种安装方式。

### 方式一：官方安装脚本

这是最推荐的小白路线。

在 macOS、Linux 或 WSL2 里执行：

```bash
curl -fsSL https://openclaw.ai/install.sh | bash
```

如果你坚持原生 Windows PowerShell，则用：

```powershell
iwr -useb https://openclaw.ai/install.ps1 | iex
```

但如果你已经走了 WSL2 路线，就不要再回 PowerShell 里装 OpenClaw。请记住一句话：

WSL2 路线下，OpenClaw 应该装在 Ubuntu 里，不是装在 Windows 的 PowerShell 里。

如果你是第一次安装，我建议你就按下面这 5 步做，不要自己发散：

1. 打开 Ubuntu。
2. 先确认你当前在 Ubuntu 里，而不是 PowerShell 里。
3. 执行 `node --version` 和 `npm --version`。
4. 执行 `curl -fsSL https://openclaw.ai/install.sh | bash`。
5. 安装结束后执行 `openclaw --version`，确认命令已经可用。

### 方式二：直接全局安装

如果你已经有稳定的 Node 环境，也可以直接：

```bash
npm install -g openclaw@latest
```

或：

```bash
pnpm add -g openclaw@latest
```

### 方式三：从源码构建

适合以下情况：

- 你要研究源码
- 你要跟踪最新开发分支
- 你要自己改 OpenClaw

典型流程是：

```bash
git clone https://github.com/openclaw/openclaw.git
cd openclaw
pnpm install
pnpm ui:build
pnpm build
openclaw onboard --install-daemon
```

如果你现在只是为了学会使用，不建议一开始就选源码构建。

## 8. 第一次安装后，最关键的命令是什么

答案几乎总是：

```bash
openclaw onboard --install-daemon
```

但这里必须讲清楚一件事：你**不一定每次都需要手动再敲这一条**。

### 8.1 如果你走的是官方安装脚本，它会不会直接进入 onboarding

分两种情况看。

#### 情况一：macOS / Linux / WSL2 里的 `install.sh`

也就是这条：

```bash
curl -fsSL https://openclaw.ai/install.sh | bash
```

官方文档写得很明确：安装器会设置 CLI，并运行新手引导。

结合当前安装脚本逻辑，更准确的说法是：

- **通常会自动进入 onboarding**
- 但如果你显式加了 `--no-onboard`，就会跳过
- 如果系统已经检测到现有配置，也可能跳过重复 onboarding
- 如果当前没有可交互终端，也可能只提示你稍后手动运行

也就是说，对你现在这条推荐主线来说：

- 如果你是在 **WSL2 的 Ubuntu** 里走官方安装脚本，很多时候安装结束后就会直接带你进入 onboarding

#### 情况二：原生 Windows PowerShell 里的 `install.ps1`

也就是这条：

```powershell
iwr -useb https://openclaw.ai/install.ps1 | iex
```

当前 PowerShell 安装脚本的行为更接近：

- 先把 OpenClaw 装好
- 然后提示你运行 `openclaw onboard` 完成设置

所以原生 Windows PowerShell 这条线里，安装和 onboarding 更像是两步。

### 8.2 这一节真正想告诉你什么

这里其实只想说明一件很具体的事：

**安装完成，不等于已经能用。**

很多小白会把“OpenClaw 已经装到电脑里了”和“OpenClaw 已经配好、可以聊天了”当成一回事，但这两件事不是一回事。

对你来说，可以这样理解：

- `install.sh` / `install.ps1` 主要负责把程序装上
- `openclaw onboard --install-daemon` 主要负责把系统第一次配好

也就是说，这条命令的作用不是“再装一遍”，而是：

- 选模型认证
- 生成或确认配置
- 配好 Gateway
- 准备默认工作区
- 按需要安装后台服务

如果没有这一步，你经常会遇到的情况是：

- 命令已经存在
- 但还没有模型认证
- 还没有完整配置
- Gateway 也不一定已经按你的环境配好
- 所以系统还不能算真的跑通

你现在最实用的判断方法就是：

- 如果安装脚本跑完后，已经自动带你进入设置流程，那你继续跟着走就行，不用再手动敲
- 如果安装脚本只是装好了程序，没有带你进入设置流程，那你下一步就手动敲：

```bash
openclaw onboard --install-daemon
```

所以这一节不是在“强调一个概念”，而是在告诉你：

**这条命令是“第一次把 OpenClaw 从装好推进到能用”的那一步。**

### 8.3 第一次做 onboarding 前，你至少要准备什么

第一次不需要什么都准备齐，只要先准备最小必要项就够了。

最少建议你先准备这几样：

1. 你已经决定这次先走 **本地模式**
2. 你已经决定这次先用 **Dashboard** 跑通，而不是一上来就接很多渠道
3. 你手里至少有一种可用的模型认证方式

第三点最关键。也就是说，你至少要准备下面这类东西中的一种：

- 一种 API Key
- 或一种 OAuth / 现成 CLI 凭证可供复用

如果这一项完全没准备，onboarding 还是会卡住，因为它不知道最后拿什么模型来工作。

### 8.4 第一次 onboarding，哪些先做完，哪些可以后面再补

对小白来说，第一次最小必要项其实不多。

#### 先做完的

- 选 **本地模式**
- 选一个能工作的 **模型认证**
- 让向导生成或确认 **默认工作区**
- 让向导完成 **Gateway 基础配置**
- 如果你打算长期使用，就安装 **daemon / 后台服务**

#### 这次可以先不做或后面再补的

- 飞书、Telegram、Discord 之类渠道接入
- 多 Agent
- 复杂路由
- 高级安全策略细调
- 远程模式

也就是说，第一次 onboarding 你真正要拿到的结果只有一句话：

“本地 Gateway 能起来，Dashboard 能打开，系统已经有一个可工作的模型认证。”

### 8.5 如果你不知道怎么选，第一次就按这个最小策略走

第一次 onboarding 时，优先按下面这个顺序选：

1. 模式：选 **本地**
2. 认证：选你当前最容易拿到、最稳定的一种
3. 工作区：先接受默认值
4. Gateway：先接受默认 loopback 和默认端口
5. 服务：如果你准备长期用，就选安装 daemon
6. 渠道：第一次可以先跳过

如果你不知道该选什么，优先按向导默认建议来。

### 8.6 `--install-daemon` 到底是什么意思

这串参数里，真正容易让小白困惑的是后半段：

```bash
--install-daemon
```

它的意思不是“装第二个 OpenClaw”，而是：

**在 onboarding 过程中，把 Gateway 安装成后台常驻服务。**

对你来说，可以把它理解成：

- 不加这个参数：你先把 OpenClaw 配好，但 Gateway 不一定被装成开机或登录后可管理的后台服务
- 加这个参数：onboarding 会把“安装后台服务”这一步也一起做掉

官方文档当前对这一步的说明是：

- macOS：安装成 LaunchAgent
- Linux / WSL2：安装成 systemd 用户服务

所以 `daemon` 在这里，基本就等于：

- 后台服务
- 常驻运行方式
- 以后可以用 `openclaw daemon status`、`openclaw daemon restart` 这类命令管理的那一层

### 8.7 小白第一次到底要不要加 `--install-daemon`

最实用的判断方法是：

- 如果你准备长期用，而且你不想每次都手动前台启动 Gateway，就加
- 如果你只是今天先试跑一下，也可以先不加，后面再补

但对这本书的主线来说，我仍然推荐第一次就按：

```bash
openclaw onboard --install-daemon
```

原因很现实：

- 后面你会反复用 Dashboard
- 还会接飞书
- 还会跑真实场景

如果 Gateway 已经被装成后台服务，后面整条学习链会更稳。

### 8.8 官方安装脚本执行的是不是同样的东西

结论要分开说。

#### `install.sh`

Linux / macOS / WSL2 的官方安装脚本，当前会在合适条件下自动执行：

```bash
openclaw onboard
```

也就是说：

- 它会尝试自动进入 onboarding
- 但**不是明确执行 `openclaw onboard --install-daemon` 这一整条**

所以严格来说，它和你手动敲的：

```bash
openclaw onboard --install-daemon
```

不是完全同一条命令。

更准确的理解是：

- 官方 `install.sh` 会尽量把你带进 onboarding
- 但你手动加上 `--install-daemon`，是在明确告诉系统：这次把后台服务安装也一起做掉

#### `install.ps1`

原生 Windows 的 PowerShell 安装脚本更不是同一条。

它当前的行为是：

- 先安装 OpenClaw
- 然后提示你自己运行 `openclaw onboard` 完成设置

所以 `install.ps1` 本身并不会替你自动执行 `openclaw onboard --install-daemon`。

## 9. onboarding 时你到底在选什么

### 9.1 本地模式还是远程模式

对大多数第一次安装的人，先选本地模式。

原因很简单：

- 变量最少
- 容易排错
- 最快看到结果

远程模式适合已经有固定远程 Gateway 主机、VPN、SSH 隧道或 Tailscale 方案的人。

### 9.2 认证方式

这一步决定 OpenClaw 用什么模型和凭证去工作。

你可以简单理解为：

- OpenAI / Anthropic / 其他提供商 = 大脑来源
- onboarding = 帮你把大脑接到系统上

第一次不要追求“最佳模型策略”，先追求“有一个稳定可用的认证路径”。

### 9.3 是否安装 daemon

对长期使用来说，安装后台服务通常更合理。

原因是 Gateway 本身就是一个长期运行的中枢，安装 daemon 后：

- 不需要每次都手动前台启动
- 状态更稳定
- 更接近 OpenClaw 的实际设计方式

### 9.4 是否现在就接渠道

如果你是第一次安装，我建议：

- 渠道先只接一个，或者先不接
- 先跑 Dashboard
- 先在本地确认整套系统能工作

这是非常重要的节奏控制。

## 10. 第一次真正跑通的标准流程

下面是我最推荐的小白流程。

### 第一步：完成安装

先装好 CLI，并确认：

```bash
openclaw --version
```

只要这条命令能输出版本号，才说明 CLI 已经真正可用。

### 第二步：运行 onboarding

```bash
openclaw onboard --install-daemon
```

第一次跑这一步时，决策原则很简单：

- 优先按默认建议走
- 优先安装 daemon
- 先做本地可用配置
- 不要第一次就接很多渠道

### 第三步：检查 Gateway 状态

```bash
openclaw gateway status
```

如果状态正常，继续下一步；如果状态不正常，就先处理 Gateway，不要急着去接渠道。

#### 10.0.1 怎么确认“已经装成后台服务”

如果你在 onboarding 时用了：

```bash
openclaw onboard --install-daemon
```

那你下一步最该确认的，不是“我记得刚才好像装了”，而是“后台服务现在到底在不在、是不是正在跑”。

对小白来说，先看这一条就够了：

```bash
openclaw gateway status
```

这条命令会同时帮你看两层信息：

- Gateway 服务有没有安装
- Gateway 当前是不是能连通

对小白来说，不用把整屏输出全看懂，只要先抓下面这 4 行：

1. `Service: ...`
2. `Service file: ...`
3. `Runtime: ...`
4. `RPC probe: ...`

可以按下面这个标准判断：

#### 可以认为“已经装成后台服务”时，通常会看到

- `Service: systemd (enabled)` 或类似的已启用状态
- `Service file: ~/.config/systemd/user/openclaw-gateway.service`

这两行说明的意思是：

- 后台服务已经安装到了 WSL2 的 `systemd` 用户服务里
- 而且当前是启用状态，不是一次性的临时运行

#### 可以认为“后台服务正在正常工作”时，通常还会同时看到

- `Runtime: running`
- `RPC probe: ok`

这两行说明的意思是：

- 后台 Gateway 进程现在确实在跑
- CLI 也确实能连上它

#### 如果像你现在这类输出，应该怎么理解

像下面这种组合：

- `Service: systemd (enabled)`
- `Service file: ~/.config/systemd/user/openclaw-gateway.service`
- `Runtime: running (...)`
- `RPC probe: ok`

就已经可以判断为：

- 后台服务已经安装成功
- 后台服务当前正在运行
- Dashboard 这条链路通常也已经具备基础条件

也就是说，就你给出的这份结果来看，**“有没有装成后台服务”这个问题，答案是有，而且现在就在跑。**

#### 那为什么还会出现黄色提醒

如果你还看到这类提示：

- `Service config looks out of date or non-standard.`
- `Recommendation: run "openclaw doctor"`

这通常不是说“后台服务没装上”，而是说：

- 服务虽然已经装上了
- 也已经在运行了
- 但服务配置里有一些环境路径不够新，或者和当前 CLI 环境不完全一致

这类情况下，对小白最稳的处理方式是：

```bash
openclaw doctor
```

如果 `doctor` 明确提示可以自动修，再执行：

```bash
openclaw doctor --repair
```

所以要把两件事分开看：

- `Service: systemd (enabled)` + `Runtime: running` + `RPC probe: ok`
  这说明“后台服务已经装好并且正在工作”
- `Service config looks out of date...`
  这说明“建议顺手修一下服务配置”，但不等于服务没装上

更准确地说，这类黄色提醒很多时候是在做 **服务 PATH 审计**：

- 它会把后台服务文件里的 `PATH`
- 和源码里定义的一套“推荐最小 PATH 模板”
- 做一次对比

这套模板在 Linux / WSL2 下，通常会把下面这些目录视为“推荐候选”：

- `~/.local/bin`
- `~/.npm-global/bin`
- `~/bin`
- `~/.volta/bin`
- `~/.asdf/shims`
- `~/.bun/bin`
- `~/.nvm/current/bin`
- `~/.fnm/current/bin`
- `~/.local/share/pnpm`

如果发现服务文件里没包含其中一些“常见用户目录”或“常见 Node 管理器目录”，就会给出建议级提醒。

这不一定代表你真的在使用这些目录，也不一定代表当前运行已经出错。

也就是说，它的比较标准更像：

- “一套通用、偏保守、考虑未来扩展的 Linux 服务 PATH 模板”

而不是：

- “你这台机器此刻真实正在使用的最小必需目录清单”

#### 这些路径分别是干什么的

下面这张表，可以把这类提醒看得更直白一点。

| 路径 | 常见对应工具 | 后面可能用到的场景 | 现在要不要管 |
| --- | --- | --- | --- |
| `~/.npm-global/bin` | `npm -g` 装出来的 CLI | `openclaw` 本身、其他全局 npm 工具 | 要关心，你现在已经在用 |
| `~/.local/bin` | 用户级 CLI、小脚本、`pipx` 一类工具 | 以后安装别的个人命令行工具 | 现在通常不用专门处理 |
| `~/bin` | 自己写的脚本 | 以后把常用脚本做成命令 | 现在通常不用管 |
| `~/.nvm/current/bin` | `nvm` | 以后如果改用 `nvm` 管 Node | 只有真的用了 `nvm` 才关心 |
| `~/.fnm/current/bin` | `fnm` | 以后如果改用 `fnm` 管 Node | 只有真的用了 `fnm` 才关心 |
| `~/.volta/bin` | `volta` | 以后如果用 `volta` 管 Node / pnpm | 只有真的用了 `volta` 才关心 |
| `~/.asdf/shims` | `asdf` | 以后如果同时管理 Node、Python 等多语言版本 | 只有真的用了 `asdf` 才关心 |
| `~/.bun/bin` | `bun` | 以后如果用 `bun` 跑某些工具或脚本 | 只有真的装了 `bun` 才关心 |
| `~/.local/share/pnpm` | `pnpm` 全局命令 | 以后如果用 `pnpm add -g` 装工具 | 只有真的用了 `pnpm` 全局安装才关心 |

这里最重要的一点是：

- 这些路径不是“必须预装清单”
- 更不是让你现在去创建一堆空文件夹

它们只是“如果以后装了对应工具，这些工具通常会出现在这里”。

#### 对小白最实用的判断规则

你现在只需要记住下面这条：

- 没装对应工具，就不用因为 PATH 提醒去手动补这个目录

真正该处理的情况是：

- 你已经装了某个工具
- 你在当前终端里能用
- 但后台 Gateway 重启后找不到它

这时才说明“服务 PATH 和你的实际使用环境不一致”，值得再修。

#### 什么时候这条黄色提醒可以先不当成故障

如果同时满足下面这几条：

1. `Service: systemd (enabled)`
2. `Runtime: running`
3. `RPC probe: ok`
4. `openclaw dashboard` 能打开
5. 你已经能正常完成本地对话

那这类黄色提醒通常可以先理解为：

- “服务建议维护”
- 不是“系统已经坏了”

#### 什么时候需要认真处理

如果你后面又同时遇到下面这些情况，就值得处理：

- `openclaw gateway restart` 失败
- 改完配置后服务起不来
- `openclaw`、`node`、`npm` 实际装在某个用户目录里，但后台服务找不到
- 你确实在使用 `nvm`、`fnm`、`pnpm`、`bun` 这类管理器，并且后台服务需要用到它们

这时再执行：

```bash
openclaw doctor
```

必要时再按提示修复即可。

如果你想在 WSL2 里再确认一次 `systemd` 用户服务状态，可以再执行：

```bash
systemctl --user is-enabled openclaw-gateway
systemctl --user status openclaw-gateway --no-pager
```

可以这样理解这两条命令：

- `is-enabled`：看它是不是已经被设置成自动管理
- `status`：看它现在是不是正在运行

#### 10.0.2 正常情况下，它会不会在你打开 Ubuntu 后自动起来

如果满足下面这两个条件：

1. WSL2 里的 `systemd` 已经启用
2. Gateway 服务已经正确安装并启用

那么在大多数日常使用场景里，当这次 Ubuntu 启动后，Gateway 通常会随用户服务一起起来。

对小白来说，最实用的判断方式不是研究太多原理，而是：

每次打开 Ubuntu 后，先执行一次：

```bash
openclaw gateway status
```

如果状态正常，就说明这次后台服务已经起来了。

需要注意一件事：

- “打开 Ubuntu 后自动起来”
- 和“Windows 还没登录，Gateway 就提前自动起来”

不是一回事。

前者是小白日常最常见的使用场景；后者属于更偏长期托管的进阶玩法，通常还要额外配置 `linger` 和 Windows 计划任务，这一章先不作为硬要求。

#### 10.0.2.1 关掉 Ubuntu 终端窗口，不等于真的把 OpenClaw 关掉

这也是 Windows + WSL2 用户最容易误解的一点。

如果你只是把 Ubuntu 的终端窗口点叉关掉，通常只代表：

- 这一个 Bash 交互窗口关了
- 不是整个 WSL2 一定停了
- 也不是 OpenClaw 的后台 Gateway 一定停了

如果你之前已经把 Gateway 装成了后台服务，那么很常见的情况就是：

- Ubuntu 终端窗口已经关了
- 浏览器里的 WebUI 仍然还能打开

这时通常说明两件事：

- WSL2 发行版这次还在运行
- `openclaw-gateway.service` 也还在后台跑

对小白来说，最容易记住的判断方法就是：

- 关掉终端窗口，只是“我不看命令行了”
- 浏览器还能访问 `http://127.0.0.1:18789/`，通常就说明 Gateway 还活着

如果你想再确认一次，可以在 PowerShell 里执行：

```powershell
wsl -l -v
```

如果看到你的 Ubuntu 发行版状态是 `Running`，就说明这次 WSL 还没真正停掉。

再回到 Ubuntu 里执行：

```bash
openclaw gateway status
```

如果还能看到：

- `Service: systemd (enabled)`
- `Runtime: running`
- `RPC probe: ok`

那就可以理解成：

- 后台 Gateway 还在
- WebUI 还能打开是正常现象

#### 10.0.2.2 小白日常到底怎么用，最省心

如果你已经完成了 `openclaw onboard --install-daemon`，最省心的日常习惯通常是下面这套：

1. 平时把 Gateway 当后台服务使用。
2. 不用命令行时，直接关掉 Ubuntu 终端窗口就行。
3. 要继续使用时，直接打开浏览器里的 Dashboard，或者去飞书里找机器人。
4. 如果怀疑它没起来，再回 Ubuntu 里执行一次 `openclaw gateway status`。

也就是说，对大多数小白来说：

- **平时不需要每次手动启动 Gateway**
- **也不需要每次用完都手动关整个 WSL**

你可以把它理解成：

- 终端窗口：只是操作入口
- Gateway 后台服务：才是真正在提供 WebUI 和飞书能力的东西

### 一个更实用的日常场景

比如你今天只是想在浏览器里看 Dashboard，或者在飞书里继续和助手聊天，那么：

1. 你可以不打开 Ubuntu 终端也先试着用。
2. 如果能正常访问，就说明后台服务大概率还在。
3. 如果访问不了，再去 Ubuntu 里检查 `openclaw gateway status`。

这样做比“每次先打开终端、再想自己该不该手动启动”更省心。

#### 10.0.2.3 为什么刚才还能打开，过一会儿又不行

这也是 WSL2 路线里很常见的现象。

你可能会遇到这样一种情况：

1. 刚把 Ubuntu 终端窗口关掉
2. 浏览器里的 WebUI 还能继续打开一会儿
3. 过了一阵子，再访问就不行了

这通常不是你“操作错了”，而是因为：

- 终端窗口关掉后，WSL2 不一定立刻停
- 但如果后面整套 WSL2 环境进入空闲状态，它有可能被系统收起来
- 一旦 WSL2 这一层停掉，跑在里面的 Gateway 也会一起停掉

所以对小白来说，最容易理解的现实规则是：

- **关窗口后立刻还能用一会儿：正常**
- **空闲一段时间后又打不开了：也正常**

这不是 OpenClaw 特有的问题，而是 WSL2 本身和“长期常驻 Linux 服务器”不完全一样。

如果你在 Windows 里的 **“适用于 Linux 设置的 Windows 子系统”** 界面里，看到类似下面这种设置：

- `VM 空闲超时`
- 当前值是 `60000 毫秒`

那它的意思基本可以直接理解成：

- 这台 WSL2 的虚拟机如果空闲了大约 60 秒
- 系统就可能把它自动收起来

换成更直白的话就是：

- 你刚关掉 Ubuntu 窗口时，可能还来得及继续访问一会儿 WebUI
- 但如果后面整套 WSL2 没再继续工作，1 分钟左右后被自动停掉，也完全正常

所以如果你机器上正好开着这个选项，而且时间又比较短，那它通常就是“为什么隔一会儿 Gateway 也没了”的最直接解释。

#### 10.0.2.4 小白怎么应对最省心

你可以把日常使用分成两种情况：

第一种，你只是自己电脑上偶尔打开用：

- 这是最常见的情况
- WSL2 偶尔空闲后自动停掉，不用太紧张
- 下次要用时，重新打开 Ubuntu，然后执行一次 `openclaw gateway status`
- 如果没起来，再执行 `openclaw gateway start`

第二种，你希望它像 24 小时常驻的小服务器一样一直在线：

- 这已经属于进阶玩法
- 这时光靠“装成后台服务”还不一定够
- 往往还要进一步处理 WSL 的常驻策略，例如 `linger`、Windows 计划任务或其他保活方式

如果你只是想先把体验变得稳定一点，而不是马上折腾完整保活，可以先从最简单的办法开始：

- 把 `VM 空闲超时` 调长一些
- 让 WSL 不要在 1 分钟这种很短的空闲时间后就被收掉

这一步的作用不是“让它永远不关”，而是：

- 让本地 WebUI
- 飞书机器人
- 你的短时间连续使用

更不容易因为 WSL 太快休眠而中断。

本书前面默认按第一种来教，因为这更符合小白第一次上手的真实场景。

也就是说，第二章里你最应该记住的，不是“它为什么有时会停”，而是：

- 想继续用：先看 WebUI / 飞书能不能直接用
- 不行：打开 Ubuntu，执行 `openclaw gateway status`
- 还没起来：执行 `openclaw gateway start`

这样就够了。

#### 10.0.3 如果没有自动起来，怎么补救

如果你打开 Ubuntu 后执行 `openclaw gateway status`，发现服务没起来，就按下面顺序处理：

第一步，先试官方推荐的服务安装命令：

```bash
openclaw gateway install
openclaw gateway start
```

如果你本来就是第一次安装，也可以重新执行：

```bash
openclaw onboard --install-daemon
```

第二步，再检查一次：

```bash
openclaw gateway status
```

第三步，如果你要手动确认 `systemd` 侧是否已经启用：

```bash
systemctl --user enable --now openclaw-gateway.service
systemctl --user status openclaw-gateway --no-pager
```

如果你执行到这一步，通常说明你已经不只是“安装 OpenClaw”，而是在修后台服务状态了。

### 第四步：必要时前台启动 Gateway

如果你希望直接看日志和错误：

```bash
openclaw gateway --port 18789 --verbose
```

这一步主要用于调试。只要你想直接看到报错、日志和启动过程，就用前台模式。

#### 10.0.4 改完配置后，应该怎么重启

后面你在第三章开始改 `openclaw.json` 以后，经常会遇到一个很实际的场景：

- 配置已经改了
- 但 Gateway 还在用旧配置

这时最推荐的动作是：

```bash
openclaw gateway restart
```

这条命令的意义很明确：

- 如果你现在跑的是后台服务，就重启后台服务
- 比自己手动杀进程更稳

如果你只是想临时停掉后台服务，也可以用：

```bash
openclaw gateway stop
```

需要重新拉起来时：

```bash
openclaw gateway start
```

对小白来说，最值得记住的规则只有一条：

- 改完配置，优先 `openclaw gateway restart`

#### 10.0.4.1 如果我真想把它停掉，应该停哪一层

这里一定要把三种“停掉”区分开：

第一种，只是关掉 Ubuntu 终端窗口：

- 这通常只是把当前命令行窗口关了
- 不等于后台 Gateway 已停止
- 不等于 WSL2 已停止

第二种，只停 OpenClaw 的后台 Gateway：

```bash
openclaw gateway stop
```

这种情况下：

- WebUI 通常就不能访问了
- 飞书机器人也通常不会继续正常响应
- 但 WSL2 发行版本身不一定停

第三种，把整个 WSL2 都停掉：

```powershell
wsl --shutdown
```

这条命令是在 Windows 侧执行的。它的含义是：

- 把当前所有 WSL 发行版都停掉
- 同时也会让这次跑在 WSL 里的 OpenClaw Gateway 跟着停掉

对小白来说，更推荐这样记：

- 平时只是不用命令行：直接关 Ubuntu 窗口
- 改配置后想重新加载：`openclaw gateway restart`
- 想临时停掉 OpenClaw：`openclaw gateway stop`
- 排错、释放资源、或者你明确想把整个 WSL 都关掉：`wsl --shutdown`

#### 10.0.5 后台和前台怎么选

这是很多新手第一次装好后都会卡住的地方。

可以直接这样理解：

后台模式：

- 适合日常使用
- 适合长期开着 Dashboard
- 终端里看不到持续滚动的日志
- 更省心

前台模式：

- 适合调试
- 适合刚改完配置，想立刻看报错
- 终端窗口会一直被占着
- 关掉这个前台进程，当前这次前台运行也就结束了

对小白来说，默认建议是：

1. 平时用后台服务
2. 只有在排错时，才切到前台模式

#### 10.0.5 如果后面你主要在飞书里用，怎么临时打开调试过程

很多小白后面并不是一直盯着 Ubuntu 终端，而是在飞书里和机器人交互。这时更适合用 OpenClaw 原生聊天命令临时打开调试可见性。

建议先记住这 3 条：

```text
/think low
/reasoning on
/verbose full
```

它们分别在做：

- `/think low`
  - 先把思考强度开到较低可见，避免一上来太重。
- `/reasoning on`
  - 打开 reasoning 可见输出。
- `/verbose full`
  - 打开更完整的工具和过程可见性。

调试完后，建议及时关掉：

```text
/reasoning off
/verbose off
```

这套方式更适合学习和排错，因为它是 OpenClaw 的原生能力，不需要你再额外在提示词里要求“执行简报”。

#### 10.0.6 如果想看日志，但又不想盯着黑终端怎么办

有三种从易到难的方式。

第一种，最适合小白：

- 继续用后台服务
- 打开浏览器里的控制界面
- 看里面的 **Logs** 标签

这一层官方文档里叫 **Control UI**。它会显示和 Gateway 日志同源的内容，比盯着黑终端友好很多。

第二种，终端里看实时日志，但不自己前台跑 Gateway：

```bash
openclaw logs --follow
```

这条命令适合下面这种场景：

- Gateway 已经在后台跑着
- 你想一边发测试消息，一边看日志

第三种，最直接但也最“黑终端”的方式：

```bash
openclaw gateway --port 18789 --verbose
```

这适合你怀疑“Gateway 根本起不来”或者“启动瞬间就报错”的时候。

#### 10.0.7 一个最实用的日常场景

如果你后面改了配置，只想按最稳的方式验证一次，可以照这个顺序做：

1. 改完配置文件
2. 执行：

```bash
openclaw gateway restart
openclaw gateway status
```

3. 打开：

```bash
openclaw dashboard
```

4. 如果页面能打开，但你还想确认内部有没有报错，再开一个终端执行：

```bash
openclaw logs --follow
```

对小白来说，这通常已经够用了，不必一开始就盯前台黑屏日志。

### 第五步：打开 Dashboard

```bash
openclaw dashboard
```

浏览器一般会打开：

```text
http://127.0.0.1:18789/
```

如果浏览器没有自动打开，就手动访问这个地址。

### 第六步：做健康检查

```bash
openclaw status
openclaw health
openclaw doctor
```

对新手来说，这三条命令可以这样记：

- `status` 看整体状态
- `health` 看健康探测
- `doctor` 看诊断建议

只要这里有明显报错，就先处理报错，不要急着继续加功能。

### 第七步：完成第一次本地对话

只要这一步能完成，你就已经从“安装成功”迈到了“系统可用”。

你可以用下面这个最小验收标准判断自己是不是真的跑通了：

1. `openclaw --version` 正常
2. `openclaw gateway status` 正常
3. `openclaw dashboard` 能打开页面
4. Dashboard 里能发出第一条消息并收到回复

这四条都成立，才叫“第一次跑通”。

### 10.1 本章真正的实战：不要只说“你好”，直接产出第一份行动清单

很多安装文档都会把第一次成功写成“能聊一句你好”。这对调试可以，但对学习没什么价值。

更值得你现在立刻做的是：把第一章那份任务单，整理成一份未来 7 天真的能执行的行动清单。

第一步，在工作区里准备一个练习目录：

```bash
mkdir -p ~/.openclaw/workspace/ch02-first-run
nano ~/.openclaw/workspace/ch02-first-run/raw-goal.md
```

把你在第一章写好的“我的 OpenClaw 首个任务单”贴进去；如果你还没写，就先用第一章给出的模板。

第二步，打开 Dashboard，把下面这段话直接发给 OpenClaw：

```text
请读取工作区里的 ch02-first-run/raw-goal.md，把它整理成一份未来 7 天可执行的行动清单。

要求：
1. 用中文。
2. 输出成 Markdown。
3. 分成“本周目标”“第一步先做什么”“本周不要做什么”三部分。
4. 保存为 ch02-first-run/first-plan.md。
5. 最后告诉我你保存到了哪里。
```

第三步，回到终端确认文件已经存在：

```bash
ls ~/.openclaw/workspace/ch02-first-run
```

如果你看到了 `first-plan.md`，那这一章就不只是“装好了”，而是真正产出了第一份对你有用的结果。

## 11. 为什么第一次先跑 Dashboard，而不是先接 WhatsApp / Telegram / Feishu

因为 Dashboard 是最少变量的验证方式。

如果你一上来就接消息渠道，你其实会同时引入：

- Gateway 是否正常
- 模型认证是否正常
- 渠道配置是否正常
- 平台权限是否正常
- 群聊和配对策略是否正常

这样一旦出错，你根本分不清是哪一层的问题。

先跑 Dashboard 的好处是：

- 你先验证本体
- 再验证渠道
- 排错路径更短

## 12. Windows 用户的实践建议

### 如果你走 WSL2 路线

建议你记住一句最重要的话：

先在 PowerShell 里装 WSL2 和 Ubuntu，再进入 Ubuntu，用 Linux 方式安装 OpenClaw。

也就是这条主线：

1. 管理员 PowerShell 执行 `wsl --install`
2. 第一次打开 Ubuntu，创建 Linux 用户
3. 用 `wsl -l -v` 确认版本是 2
4. 在 Ubuntu 里启用 systemd
5. 在 Ubuntu 里装 Node
6. 在 Ubuntu 里装 OpenClaw
7. 在 Ubuntu 里运行 `openclaw onboard --install-daemon`

如果你只是本机自己使用，不需要一开始就研究端口代理、LAN 暴露、Windows 防火墙映射这些高级内容。

### 如果你走原生 Windows 路线

建议你一开始只做这几件事：

1. 安装 OpenClaw
2. 跑 onboarding
3. 用 `gateway status` 看状态
4. 用 `dashboard` 验证
5. 用 `doctor` 和 `logs` 排错

不要一上来就叠很多额外变量，比如：

- 多个渠道
- 多个模型后端
- 太复杂的 Tool Access 策略
- 远程 Gateway

## 13. 安装过程里最常见的坑

### PATH 没刷新

表现：

- `openclaw` 命令找不到

处理：

- 关闭并重新打开 PowerShell
- 检查全局 npm prefix

### WSL2 里提示“Node.js v22 已安装，但当前 shell 还是旧 Node”

如果你在 Ubuntu 里安装时看到类似下面这种报错：

- 安装器说已经安装了 Node.js v22
- 但下面又提示当前 `node` 还是 `v18.x`
- 甚至 `node` 和 `npm` 还来自两个不同位置

这类报错的意思不是“OpenClaw 装坏了”，而是：

- 安装器已经尝试把 Node 22 装上了
- 但你当前这个终端会话，仍然优先使用旧的 `node`
- 或者 WSL2 里的 Ubuntu 误用了 Windows 那边的 `npm`

这一点在官方安装脚本源码里也能看到：脚本安装完 Node 后，还会再做一次 `ensure_node22_active_shell` 检查；如果当前 shell 里的 `node` 仍然低于要求版本，就会直接退出。

最常见的异常组合是：

- `node` 来自 `/usr/bin/node`
- `npm` 却来自 `/mnt/c/...` 或 `/mnt/d/...`

这说明你的 WSL2 终端把 Linux 工具和 Windows 工具混到一起了。对 OpenClaw 来说，这种环境很不稳。

#### 先按这个顺序检查

第一步，先在 Ubuntu 里执行：

```bash
command -v node
node -v
command -v npm
npm -v
type -a node
type -a npm
```

如果你看到下面这种情况，就说明确实是 PATH 混乱：

- `node -v` 还是 `v18.x`
- `npm` 路径落在 `/mnt/c/...` 或 `/mnt/d/...`

第二步，先刷新当前 shell：

```bash
hash -r
exit
```

把当前 Ubuntu 窗口彻底关掉，再重新打开 Ubuntu，重新执行刚才那 6 条检查命令。

很多时候，到这一步就已经恢复正常了。

#### 如果重开终端后还是不对，按这个办法修

先检查你的 shell 配置里有没有手动塞过 Windows 版 Node / npm 路径：

```bash
grep -nE 'node|npm' ~/.bashrc ~/.profile ~/.bash_profile 2>/dev/null
```

如果你看到了类似下面这种路径，就先删掉相关那一行：

- `/mnt/c/.../nodejs`
- `/mnt/d/.../nodejs`
- Windows 版 nvm 的路径

删完后保存文件，再执行：

```bash
hash -r
exit
```

重新打开 Ubuntu，再检查一次：

```bash
command -v node
node -v
command -v npm
npm -v
```

#### 场景 A：`~/.bashrc` 写坏了，或者把 Windows 版 Node 路径塞进了 WSL2

典型表现：

- 一打开 Ubuntu 就提示 `~/.bashrc` 某一行有 `syntax error`
- `node -v` 还是旧版本，例如 `v18.x`
- `npm` 路径落在 `/mnt/c/...` 或 `/mnt/d/...`

这通常说明 shell 配置文件里存在两类问题之一：

- `export PATH=...` 这一行语法写坏了
- 手动把 Windows 版 `node` / `npm` 路径加进了 WSL2 的 `PATH`

最常见的错误写法类似：

```bash
export PATH="/mnt/d/Env/nodejs:...
```

这种写法会同时带来两个问题：

1. 让 Ubuntu 优先看到 Windows 盘里的 Node 工具
2. 如果引号不完整，直接导致 `.bashrc` 语法错误

处理顺序：

1. 先备份配置：

```bash
cp ~/.bashrc ~/.bashrc.bak
```

2. 打开 `~/.bashrc`，删除所有手动加入的 Windows Node 路径，例如：
   - `/mnt/c/.../nodejs`
   - `/mnt/d/.../nodejs`
   - Windows 版 `nvm`

3. 重新加载 shell：

```bash
source ~/.bashrc
```

4. 再检查一次：

```bash
command -v node
node -v
command -v npm
npm -v
```

如果不想用命令行编辑器，也可以在 Windows 资源管理器里通过 `\\wsl$` 打开 WSL 文件系统，直接修改用户目录下的 `.bashrc`。

#### 场景 B：NodeSource 下载失败，日志出现 `Could not resolve host: deb.nodesource.com`

这类报错说明安装器尝试下载 Node 22 时，Ubuntu 当前网络或 DNS 没有打通。结果就是：

- 安装器本来想装 Node 22
- 但下载步骤没成功
- 当前 shell 只能继续使用旧的 Node 环境

先执行：

```bash
ping -c 1 deb.nodesource.com
ping -c 1 github.com
```

如果这里报：

- `Could not resolve host`
- `Temporary failure in name resolution`

那就先不要继续重跑安装器，先修 WSL2 网络。

这类问题在 Windows 上经常和代理软件一起出现，尤其是：

- Clash 开了 TUN
- Clash 开了全局代理
- VPN 刚切换过节点

因为这些工具会接管 Windows 的网络和 DNS，WSL2 有时不会立刻同步这个变化。

推荐顺序：

1. 在 Windows PowerShell 执行：

```powershell
wsl --shutdown
```

2. 如果正在使用 Clash 或 VPN，先临时关闭：
   - Clash TUN
   - Clash 全局代理
   - 当前 VPN

3. 重新打开 Ubuntu，再测试：

```bash
ping -c 1 deb.nodesource.com
```

4. 如果仍然不通，再临时改 DNS：

```bash
sudo rm -f /etc/resolv.conf
echo "nameserver 1.1.1.1" | sudo tee /etc/resolv.conf
echo "nameserver 8.8.8.8" | sudo tee -a /etc/resolv.conf
```

5. 只有 `ping` 能通后，再重新运行安装器。

#### 场景 C：国内网络下，优先用 `nvm` 装 Node 22，再安装 OpenClaw

在国内网络环境里，更稳的做法通常不是先改 OpenClaw 安装脚本，而是先把 Node 22 独立装好。

如果系统已经启用了 `nvm`，可以直接走这条路：

```bash
source ~/.bashrc
command -v nvm
```

如果 `nvm` 已可用，再执行：

```bash
export NVM_NODEJS_ORG_MIRROR=https://npmmirror.com/mirrors/node
export NVM_NPM_MIRROR=https://npmmirror.com/mirrors/npm
nvm install 22
nvm use 22
nvm alias default 22
```

随后检查：

```bash
command -v node
node -v
command -v npm
npm -v
```

只有在下面这些条件都成立后，再继续安装 OpenClaw：

1. `node -v` 是 `v22.12.0` 或更高
2. `npm -v` 正常
3. `command -v npm` 不再落到 `/mnt/c/...` 或 `/mnt/d/...`
4. `ping -c 1 deb.nodesource.com` 已经能通，或者你已经通过 `nvm` 成功装好了 Node 22

对小白来说，最重要的原则只有一条：

- 先把 WSL2 里的 Node 环境修成一套干净、统一的 Linux 环境，再安装 OpenClaw

#### 还不行时，最稳的处理方式

如果你在 WSL2 里本来就装过旧版 Node，或者装过多套 Node 管理器，最稳的做法通常是：

1. 先把 Ubuntu 里旧的系统级 Node 移掉。
2. 确认当前终端不再引用 Windows 那边的 `node` / `npm`。
3. 再重新跑官方安装脚本。

可以按下面顺序操作：

```bash
sudo apt remove -y nodejs npm
hash -r
exit
```

重新打开 Ubuntu 后，先确认旧版本已经不在前面了：

```bash
command -v node
command -v npm
```

然后重新执行官方安装：

```bash
curl -fsSL https://openclaw.ai/install.sh | bash
```

#### 什么时候算修好了

至少要同时满足这 4 条：

1. `node -v` 是 `v22.12.0` 或更高
2. `npm -v` 能正常输出版本号
3. `node` 和 `npm` 都不要落在 `/mnt/c/...` 或 `/mnt/d/...`
4. 重新运行安装器时，不再出现 “could not be activated on PATH” 这类报错

#### 这一类问题最该记住的一句话

如果你走的是 `Windows + WSL2 + Ubuntu` 路线，就尽量保证：

- `node`
- `npm`
- `openclaw`

都来自 Ubuntu 自己这边，而不是来自 Windows 盘里的可执行文件。

### `spawn git ENOENT`

表现：

- 安装或插件步骤提示找不到 git

处理：

- 安装 Git for Windows
- 重新打开终端

### 端口冲突

表现：

- `18789` 被占用

处理：

```powershell
Get-NetTCPConnection -LocalPort 18789 -State Listen
```

必要时先换端口前台运行。

### 编码或控制台乱码

原生 Windows 的 PowerShell 和控制台编码问题比较常见。如果你遇到日志乱码，可以先把当前会话切到 UTF-8。

## 14. 第一次成功后你还要做什么

### 做一次最小备份

建议至少知道下面这些位置：

- `~/.openclaw/openclaw.json`
- `~/.openclaw/workspace/`
- `~/.openclaw/credentials/`

### 先别急着大改配置

你现在更需要的是：

- 确认系统稳定
- 熟悉最常用命令
- 形成日常检查习惯

## 15. 安装之后最不该做的事

### 不要本地都没通，就先研究远程访问

SSH 隧道、Tailscale、反向代理都留到后面。

### 不要第一次就接多个渠道

先一个，甚至先零个。

### 不要先手写一大坨配置

先相信 onboarding。

### 不要把“命令装上了”当成成功

真正的成功标准是“已经能用”。

## 16. 本章小结

第一次安装 OpenClaw，最重要的不是“懂得很多”，而是“顺序正确”。

尤其对 Windows 用户来说，最值得记住的主线是：

1. 先装 WSL2
2. 在 WSL2 里装 Ubuntu
3. 在 Ubuntu 里装 Node 和 OpenClaw
4. 跑 `openclaw onboard --install-daemon`
5. 检查 Gateway
6. 打开 Dashboard
7. 完成第一次对话

这条主线通了，后面的章节才会顺。

### 16.1 本章验收标准

做到下面这 5 条，第二章才算真正完成：

1. `openclaw --version` 正常
2. `openclaw gateway status` 正常
3. `openclaw dashboard` 能打开
4. 你已经在 Dashboard 里完成过至少一次真实对话
5. 工作区里已经生成 `ch02-first-run/first-plan.md`

## 17. 下一章

- [03-OpenClaw-配置命令与日常维护.md](03-OpenClaw-配置命令与日常维护.md)

## 本章核验依据（官方文档 / 源码）

- `../sources/official/openclaw/docs/zh-CN/platforms/windows.md`
- `../sources/official/openclaw/docs/zh-CN/start/getting-started.md`
- `../sources/official/openclaw/docs/zh-CN/install/index.md`
- `../sources/official/openclaw/package.json`
- Microsoft Learn: [Install WSL](https://learn.microsoft.com/en-us/windows/wsl/install)
- Microsoft Learn: [Working across Windows and Linux file systems](https://learn.microsoft.com/en-us/windows/wsl/filesystems)

## 本章合并来源

这一章主要吸收并改写了以下归档文档中的主题：

- `README.md`
- `openclaw-windows-native-install.md`
- `OpenClaw-小白部署安装指南-Windows版.md`
- `OpenClaw-配置实战完整手册-Windows版.md`
- `openclaw_newbie_guide.md`
- `openclaw_user_guide.md`
- `openclaw_webui_setup_guide.md`
- `openclaw_newbie_best_practice.md`

