# WishingFn

WishingFn 是一个轻量的 CapsLock 增强工具：用 `CapsLock` 做功能层，快速移动光标/鼠标，并收藏、打开选中文字或剪贴板里的路径、网页和命令。

## 给人类用户

### 快捷键

| 快捷键 | 功能 |
| --- | --- |
| 单击 `CapsLock` | 切换大小写 |
| `CapsLock + w/a/s/d` | 上/左/下/右 |
| `CapsLock + q/e` | Home / End |
| `CapsLock + f` | Delete |
| `CapsLock + Backspace` | Delete |
| `CapsLock + 1..0,-,=` | F1..F12 |
| `CapsLock + u/Space/o` | 左键 / 左键 / 右键 |
| `CapsLock + i/j/k/l` | 鼠标移动 |
| `CapsLock + c` | 收藏当前选中文字；没有选中时收藏剪贴板 |
| `CapsLock + v` | 打开当前选中文字；没有选中时打开剪贴板 |
| `CapsLock + x` | 打开收藏夹 |

### 收藏夹

WishingFn 会自动识别三种收藏：

- 路径：文件或文件夹
- 网页：`http://` 或 `https://`
- 命令：其他文本会作为命令执行

收藏时会让你输入一个别名。收藏夹里可以：

- 双击 / `Enter`：打开
- `F2`：重命名别名
- `Delete`：删除

注意：命令会通过系统 shell 执行，只收藏你信任的命令。

### Windows 安装

一条命令安装、设置开机自启动并立即启动：

```powershell
irm https://raw.githubusercontent.com/Karl0007/WishingFn/main/install.ps1 | iex
```

更新到最新版：

```powershell
irm https://raw.githubusercontent.com/Karl0007/WishingFn/main/update.ps1 | iex
```

卸载并移除开机自启动：

```powershell
irm https://raw.githubusercontent.com/Karl0007/WishingFn/main/uninstall.ps1 | iex
```

安装位置：

```text
%LOCALAPPDATA%\WishingFn
```

### macOS / Linux

计划命令如下，但对应发布包还未启用：

```bash
curl -fsSL https://raw.githubusercontent.com/Karl0007/WishingFn/main/install.sh | bash
curl -fsSL https://raw.githubusercontent.com/Karl0007/WishingFn/main/install.sh | bash -s -- update
curl -fsSL https://raw.githubusercontent.com/Karl0007/WishingFn/main/install.sh | bash -s -- uninstall
```

目前 macOS/Linux 可先参考 `README-AGENT.md` 里的源码运行方式。

## For English Readers

See `README.en.md`.

## For Agents

Implementation, packaging, release, and source-run details live in `README-AGENT.md`.
