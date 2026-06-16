<p align="right">
  <a href="README.md">English</a> |
  <strong>中文</strong>
</p>

# iOS 27 Beta 版索引进度查询 Windows 版

一个给 Windows 用户使用的小工具，用来查看 iPhone 上“Indexing in Progress / 正在索引”的实际进度百分比。

它复现的是 macOS Console 里的思路：读取 iPhone 实时系统日志，过滤 Spotlight / Settings 里写出的 `PipelineCompleteness`，然后显示真实百分比。

## 普通用户下载

不需要 clone，不需要懂 GitHub。

普通用户只需要点这里下载 Windows 离线包：

[下载 iOS_Indexing_Checker_Windows_NoPython.zip](https://github.com/CZJ0219/ios27-beta-indexing-progress-windows/releases/latest/download/iOS_Indexing_Checker_Windows_NoPython.zip)

备用下载位置：

[仓库内 dist/iOS_Indexing_Checker_Windows_NoPython.zip](dist/iOS_Indexing_Checker_Windows_NoPython.zip)

这个包不需要用户安装 Python，也不需要联网下载依赖。

## 开发者查看源码

只有想研究源码、自己构建或提交改进的人才需要 clone 仓库。

## 使用方法

1. 解压 `iOS_Indexing_Checker_Windows_NoPython.zip`。
2. 用 USB 连接 iPhone。
3. 解锁 iPhone，如果弹出提示，点“信任此电脑”。
4. 在 iPhone 上打开“设置”。
5. 双击 `Start-iOS-Indexing-Checker.cmd`。
6. 按窗口提示操作，等待结果。

正常情况下会看到类似：

```text
Connected. Waiting for Spotlight indexing logs...
[19:48:27] iOS indexing progress: 85%
Latest iOS indexing progress seen: 85%
完成：已经读到 iOS 索引进度。
```

## 必要条件

- Windows 10 或 Windows 11。
- iPhone 通过 USB 连接。
- Windows 能识别 iPhone。
- 已安装 Apple Devices 或 iTunes，使系统中存在 `Apple Mobile Device Service`。

注意：Apple 的 iPhone USB 通道/驱动不包含在这个工具里。如果一台电脑从来没装过 Apple Devices 或 iTunes，需要先安装它们。

## 这个工具会上传数据吗？

不会。工具只在本机读取 iPhone 的实时日志，并只显示匹配到的索引进度。不会把日志上传到任何服务器。

如果出现问题，同目录会生成：

```text
ios-indexing-checker.log
```

向别人求助时，建议先删除或遮盖设备名、UDID 等个人信息。

## 已验证

本工具已在 Windows 上连接 iOS 27.0 beta 设备实测，成功读取到：

```text
PipelineCompleteness: 85%
```

## 文档

- [使用说明](docs/USER_GUIDE.md)
- [故障排查](docs/TROUBLESHOOTING.md)
- [隐私说明](docs/PRIVACY.md)
- [开发者构建说明](docs/DEVELOPER.md)
- [更新日志](CHANGELOG.md)

## 免责声明

本项目不是 Apple 官方工具，也不隶属于 Apple。它依赖 Windows 上已有的 Apple Mobile Device 通道读取你自己连接的 iPhone 日志。请只在你拥有或获授权的设备上使用。

## License

MIT License. See [LICENSE](LICENSE).
