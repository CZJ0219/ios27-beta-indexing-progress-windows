<p align="right">
  <strong>English</strong> |
  <a href="README.zh-CN.md">中文</a>
</p>

# iOS 27 Beta Indexing Progress Checker for Windows

A small Windows utility for checking the actual iPhone "Indexing in Progress" percentage.

It follows the same idea as the macOS Console method: stream live iPhone logs, look for Spotlight / Settings indexing messages, and extract `PipelineCompleteness`.

## Download for Regular Users

No clone needed. No GitHub experience needed.

Download the Windows offline package here:

[Download iOS_Indexing_Checker_Windows_NoPython.zip](https://github.com/CZJ0219/ios27-beta-indexing-progress-windows/releases/latest/download/iOS_Indexing_Checker_Windows_NoPython.zip)

Fallback:

[dist/iOS_Indexing_Checker_Windows_NoPython.zip](dist/iOS_Indexing_Checker_Windows_NoPython.zip)

End users do not need to install Python or download dependencies.

## Source Code

Only developers need to clone this repository.

## Quick Start

1. Extract `iOS_Indexing_Checker_Windows_NoPython.zip`.
2. Connect the iPhone over USB.
3. Unlock the iPhone and tap "Trust This Computer" if prompted.
4. Open Settings on the iPhone.
5. Double-click `Start-iOS-Indexing-Checker.cmd`.
6. Follow the window prompts.

Expected output:

```text
Connected. Waiting for Spotlight indexing logs...
[19:48:27] iOS indexing progress: 85%
Latest iOS indexing progress seen: 85%
```

## Requirements

- Windows 10 or Windows 11.
- iPhone connected over USB.
- Windows can recognize the iPhone.
- Apple Devices or iTunes is installed, so Windows has `Apple Mobile Device Service`.

Apple's iPhone USB/mobile-device driver is not bundled with this project. If a computer has never installed Apple Devices or iTunes, it must install one of them first.

## Privacy

The tool reads live logs locally and filters for indexing progress. It does not upload logs anywhere.

If something goes wrong, the launcher writes a local log file next to the tool:

```text
ios-indexing-checker.log
```

Before sharing logs publicly, remove or mask device names, UDIDs, and other personal information.

## Verified

This tool was tested on Windows with an iOS 27.0 beta device and successfully read:

```text
PipelineCompleteness: 85%
```

## Documentation

- [User guide](docs/USER_GUIDE.md)
- [Troubleshooting](docs/TROUBLESHOOTING.md)
- [Privacy notes](docs/PRIVACY.md)
- [Developer build guide](docs/DEVELOPER.md)
- [Changelog](CHANGELOG.md)

## Disclaimer

This is not an Apple tool and is not affiliated with Apple. It depends on the Apple Mobile Device channel already installed on Windows to read logs from an iPhone you own or are authorized to inspect.

## License

MIT License. See [LICENSE](LICENSE).
