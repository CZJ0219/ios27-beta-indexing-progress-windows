# 故障排查

## 一直显示正在等待

请确认：

- iPhone 已经解锁。
- iPhone 已经点过“信任此电脑”。
- iPhone 上打开了“设置”。
- USB 线支持数据传输。
- Windows 可以在文件资源管理器或 Apple Devices/iTunes 中看到这台 iPhone。

## 显示 NoDeviceConnectedError

工具没有看到 iPhone。

处理方法：

1. 拔掉 USB 重新插入。
2. 解锁 iPhone。
3. 换一根数据线或 USB 口。
4. 打开 Apple Devices 或 iTunes，确认 Windows 能识别 iPhone。

## 提示缺少 Apple 连接组件

如果窗口里提到 `Apple Mobile Device Service`，说明这台 Windows 缺少 Apple 的 iPhone 连接组件。请安装 Apple Devices 或 iTunes，然后重新运行工具。

这个驱动来自 Apple，不能直接打包进本项目。

## 连接成功但没有百分比

可能原因：

- iPhone 当前没有索引任务。
- 没有打开“设置”，没有触发相关日志。
- 索引日志出现频率较低。

处理方法：

1. 保持 iPhone 解锁。
2. 在 iPhone 上打开“设置”。
3. 多等一会儿。
4. 重新运行工具。

## Windows 安全提示

第一次运行时，Windows Defender 或其他安全软件可能会扫描一会儿。只要窗口仍然在更新提示，就说明工具还在运行。

## 提交问题时请附带

- Windows 版本。
- iPhone 型号。
- iOS 版本。
- 是否能在 Apple Devices/iTunes 中看到 iPhone。
- `ios-indexing-checker.log` 中的相关片段。

请遮盖设备名、设备 ID（UDID）、Apple ID、手机号、邮箱等个人信息。
