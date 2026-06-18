<p align="right">
  <a href="README.md">English</a> |
  <strong>中文</strong>
</p>

# iOS 27 Beta 索引进度查询工具（Windows）

当 iPhone 显示“正在索引 / Indexing in Progress”，但界面没有告诉你百分比时，可以用这个 Windows 小工具看一下当前进度。

把 iPhone 用 USB 接到电脑上，运行工具，它会显示手机日志里最新出现的索引进度百分比。

## 下载

[下载 ZIP 包（GitHub）](https://github.com/CZJ0219/ios27-beta-indexing-progress-windows/releases/latest/download/iOS_Indexing_Checker_Windows_NoPython.zip)

[下载 ZIP 包（腾讯微云）](https://share.weiyun.com/H5B7bCUz)

## 使用方法

1. 下载并解压 `iOS_Indexing_Checker_Windows_NoPython.zip`。
2. 用 USB 线连接 iPhone。
3. 解锁 iPhone。
4. 如果 iPhone 弹出提示，点“信任此电脑”。
5. 在 iPhone 上打开“设置”App。
6. 双击 `Start-iOS-Indexing-Checker.cmd`。
7. 选择 English 或中文。
8. 按窗口提示按 Enter。

正常情况下会看到：

```text
iOS Indexing Progress：85%
```

如果没有马上出现百分比，不一定是卡住。请保持 iPhone 解锁，稍微多等一会儿

## 设备要求

- Windows 10 或 Windows 11。
- 一台运行 iOS 27 beta (iPadOS 27 Beta)的 iPhone (iPad)。
- 一根支持数据传输的 USB 线。
- 如果这台电脑以前从没连过 iPhone，请先安装 Apple Devices 或 iTunes。

如果 Windows 的文件资源管理器、Apple Devices 或 iTunes 都识别不到这台 iPhone，此软件也无法识别。

## 如果看起来没反应

- 保持 iPhone 解锁。
- 保持 iPhone 上的“设置”App 打开。
- 确认已经点过“信任此电脑”。
- 拔掉 USB 线再插一次。
- 换一个 USB 口，或者换一根线。

## 隐私

本工具只在本地运行，不会上传日志，不会收集遥测，也不会连接本项目的服务器。

同目录下可能会生成一份用于排查问题的本地日志。

## 免责声明

这不是 Apple 官方工具，也不隶属于 Apple。请只在你自己的 iPhone，或你被授权检查的 iPhone 上使用。

## 许可证

MIT License. See [LICENSE](LICENSE).
