# 使用说明

这个工具适合在 iPhone 显示“正在索引 / Indexing in Progress”，但没有显示具体百分比时使用。

## 下载

请下载最新的 Windows ZIP 包：

[下载 iOS_Indexing_Checker_Windows_NoPython.zip](https://github.com/CZJ0219/ios27-beta-indexing-progress-windows/releases/latest/download/iOS_Indexing_Checker_Windows_NoPython.zip)

下载后请先解压，不要直接在 ZIP 预览窗口里运行。

## 一键使用

1. 解压 ZIP 包。
2. 用 USB 线连接 iPhone。
3. 解锁 iPhone。
4. 如果 iPhone 弹出提示，点“信任此电脑”。
5. 在 iPhone 上打开“设置”App。
6. 双击 `Start-iOS-Indexing-Checker.cmd`。
7. 选择 English 或中文。
8. 回到工具窗口，按 Enter 开始。

## 结果怎么看

看到类似这一行，就代表工具已经读到索引进度：

```text
iOS 索引进度：85%
```

如果多次看到同一个百分比，通常表示 iPhone 仍在报告同一个阶段，不一定是工具卡住。

## 需要等多久

第一次运行时，Windows 安全软件可能会扫描一会儿。只要窗口仍然在更新提示，就说明工具还在运行。

如果一直没有百分比，请保持 iPhone 解锁，打开“设置”App，多等一会儿再看。

## 日志文件

同目录下可能会生成：

```text
ios-indexing-checker.log
```

如果你要反馈问题，可以提供这份日志，但请先遮盖设备名、设备 ID（UDID）、Apple ID、手机号、邮箱等个人信息。
