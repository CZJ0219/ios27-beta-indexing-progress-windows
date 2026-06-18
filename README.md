<p align="right">
  <strong>English</strong> |
  <a href="README.zh-CN.md">中文</a>
</p>

# iOS 27 Beta Indexing Progress Checker for Windows

A simple Windows tool for iOS 27 devices with "Indexing in Progress" in Settings but does not show a percentage.

Connect your iPhone over USB, run the tool, and it will show the latest indexing percentage reported by the phone.

## Download

[Download ZIP (GitHub)](https://github.com/CZJ0219/ios27-beta-indexing-progress-windows/releases/latest/download/iOS_Indexing_Checker_Windows_NoPython.zip)

[Download ZIP (Tencent Weiyun)](https://share.weiyun.com/H5B7bCUz)

## How To Use

1. Download and unzip `iOS_Indexing_Checker_Windows_NoPython.zip`.
2. Connect your iPhone with a USB cable.
3. Unlock the iPhone.
4. Tap "Trust This Computer" if the iPhone asks.
5. Open the Settings app on the iPhone.
6. Double-click `Start-iOS-Indexing-Checker.cmd`.
7. Choose English or Chinese.
8. Press Enter in the tool window when prompted.

When it works, you will see a line like this:

```text
iOS indexing progress: 85%
```

If a percentage does not appear immediately, leave the iPhone unlocked and wait a little longer.

## Requirements

- Windows 10 or Windows 11.
- An iPhone/iPad running iOS 27 beta (iPadOS 27 Beta).
- A USB cable that supports data transfer.
- Apple Devices or iTunes installed if this PC has never connected to an iPhone before.

If you can't see your devices on File Explorer, Apple Devices, or iTunes, this tool will not be able to see it either.

## If It Seems Stuck

- Keep the iPhone unlocked.
- Keep the Settings app open on the iPhone.
- Confirm that you tapped "Trust This Computer".
- Unplug and reconnect the USB cable.
- Try another USB port or another cable.

## Privacy

The tool runs locally on your PC. It does not upload logs, collect telemetry, or connect to a server run by this project.

A local troubleshooting log may be created next to the tool. If you share that log publicly, remove device names, device IDs, Apple IDs, phone numbers, emails, and anything else you do not want to publish.

</details>

## Disclaimer

This is not an Apple tool and is not affiliated with Apple. Use it only with an iPhone you own or have permission to inspect.

## License

MIT License. See [LICENSE](LICENSE).
