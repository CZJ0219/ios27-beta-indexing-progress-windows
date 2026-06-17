<p align="right">
  <strong>English</strong> |
  <a href="README.zh-CN.md">中文</a>
</p>

# iOS 27 Beta Indexing Progress Checker for Windows

A simple Windows tool for people whose iPhone says "Indexing in Progress" but does not show a percentage.

Connect your iPhone over USB, run the tool, and it will show the latest indexing percentage reported by the phone.

## Download

[Download the Windows ZIP](https://github.com/CZJ0219/ios27-beta-indexing-progress-windows/releases/latest/download/iOS_Indexing_Checker_Windows_NoPython.zip)

You do not need Python, Git, or any command-line setup.

## How To Use

1. Download and unzip `iOS_Indexing_Checker_Windows_NoPython.zip`.
2. Connect your iPhone with a USB cable.
3. Unlock the iPhone.
4. Tap "Trust This Computer" if the iPhone asks.
5. Open the Settings app on the iPhone.
6. Double-click `Start-iOS-Indexing-Checker.cmd`.
7. Press Enter in the tool window when prompted.

When it works, you will see a line like this:

```text
iOS indexing progress: 85%
```

If a percentage does not appear immediately, leave the iPhone unlocked and wait a little longer. The phone does not report indexing progress every second.

## Requirements

- Windows 10 or Windows 11.
- An iPhone running iOS 27 beta.
- A USB cable that supports data transfer.
- Apple Devices or iTunes installed if this PC has never connected to an iPhone before.

If Windows cannot see the iPhone in File Explorer, Apple Devices, or iTunes, this tool will not be able to see it either.

## If It Seems Stuck

- Keep the iPhone unlocked.
- Keep the Settings app open on the iPhone.
- Confirm that you tapped "Trust This Computer".
- Unplug and reconnect the USB cable.
- Try another USB port or another cable.

More help: [Troubleshooting](docs/TROUBLESHOOTING.md)

## Privacy

The tool runs locally on your PC. It does not upload logs, collect telemetry, or connect to a server run by this project.

A local troubleshooting log may be created next to the tool. If you share that log publicly, remove device names, device IDs, Apple IDs, phone numbers, emails, and anything else you do not want to publish.

<details>
<summary>For developers and contributors</summary>

Most people only need the ZIP above. If you want to inspect the source code or build the package yourself, read:

- [Developer notes](docs/DEVELOPER.md)
- [Privacy notes](docs/PRIVACY.md)
- [Changelog](CHANGELOG.md)

</details>

## Disclaimer

This is not an Apple tool and is not affiliated with Apple. Use it only with an iPhone you own or have permission to inspect.

## License

MIT License. See [LICENSE](LICENSE).
