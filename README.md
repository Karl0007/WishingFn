# WishingFn

[English](README.en.md) · [Agent Notes](AGENTS.md)

一个轻量、可打包发布的 CapsLock 功能层工具。WishingFn 用 Kanata 提供跨平台键盘层，用 Python 提供收藏夹、路径/网页打开和命令启动能力。

> Windows 发布包内置 Kanata；用户不需要单独安装 Kanata。

## 特性

- CapsLock 功能层：方向键、Home/End、Delete、F1-F12、鼠标移动和点击。
- 选中文字优先：收藏/打开时优先使用当前选中文字，没有选中时回退到剪贴板。
- 智能收藏：自动识别路径、网页 URL 和命令。
- 收藏夹面板：支持打开、重命名别名、删除收藏。
- Windows 一条命令安装：安装、更新、卸载都可通过远程脚本完成。
- GitHub Releases：推送 tag 后自动构建 Windows/macOS/Linux 发布包。

## 安装

### Windows

安装、写入用户启动文件夹自启动并立即启动：

```powershell
irm https://raw.githubusercontent.com/Karl0007/WishingFn/main/scripts/install/install.ps1 | iex
```

更新：

```powershell
irm https://raw.githubusercontent.com/Karl0007/WishingFn/main/scripts/install/update.ps1 | iex
```

卸载并移除自启动（保留收藏数据）：

```powershell
irm https://raw.githubusercontent.com/Karl0007/WishingFn/main/scripts/install/uninstall.ps1 | iex
```

彻底卸载（同时删除收藏数据）：

```powershell
$env:WISHINGFN_PURGE_DATA="1"; irm https://raw.githubusercontent.com/Karl0007/WishingFn/main/scripts/install/uninstall.ps1 | iex
```

默认安装位置：

```text
%LOCALAPPDATA%\WishingFn
```

### macOS / Linux

安装命令入口已实现；平台权限仍需要在真机验证：

```bash
curl -fsSL https://raw.githubusercontent.com/Karl0007/WishingFn/main/scripts/install/install.sh | bash
curl -fsSL https://raw.githubusercontent.com/Karl0007/WishingFn/main/scripts/install/install.sh | bash -s -- update
curl -fsSL https://raw.githubusercontent.com/Karl0007/WishingFn/main/scripts/install/install.sh | bash -s -- uninstall
```

## 快捷键

| 快捷键 | 功能 |
| --- | --- |
| 单击 `CapsLock` | 切换大小写 |
| `CapsLock + w/a/s/d` | 上 / 左 / 下 / 右 |
| `CapsLock + q/e` | Home / End |
| `CapsLock + f` | Delete |
| `CapsLock + Backspace` | Delete |
| `CapsLock + 1..0,-,=` | F1..F12 |
| `CapsLock + u/Space/o` | 左键 / 左键 / 右键 |
| `CapsLock + i/j/k/l` | 鼠标移动 |
| `CapsLock + c` | 收藏选中文字；无选中时收藏剪贴板 |
| `CapsLock + v` | 打开选中文字；无选中时打开剪贴板 |
| `CapsLock + x` | 打开收藏夹 |

## 收藏夹

WishingFn 会把内容识别为：

- 路径：文件或文件夹
- 网页：`http://` 或 `https://`
- 命令：其他文本

收藏时会要求输入别名。收藏夹面板支持：

- 双击 / `Enter`：打开
- `F2`：重命名别名
- `Delete`：删除

> 命令会通过系统 shell 执行，只收藏你信任的命令。

## 开发与维护

实现细节、打包流程、发布流程和 Agent 工作说明见 [AGENTS.md](AGENTS.md)。
