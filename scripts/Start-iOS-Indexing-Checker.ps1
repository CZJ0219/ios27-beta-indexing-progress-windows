<# 
.SYNOPSIS
One-click launcher for the Windows iOS indexing checker.

.DESCRIPTION
This launcher keeps setup local to this folder:
- lets the user choose English or Chinese
- verifies the Apple Mobile Device service
- runs the bundled no-Python executable when available
- can fall back to a local Python runtime for maintainers
#>

[CmdletBinding()]
param(
    [int]$DurationSeconds = 300,
    [string]$DeviceId,
    [switch]$Raw,
    [switch]$AllowPythonFallback,
    [switch]$NoPrompt,
    [ValidateSet("en", "zh")]
    [string]$Language
)

Set-StrictMode -Version 2.0
$ErrorActionPreference = "Stop"
try {
    $utf8 = New-Object System.Text.UTF8Encoding($false)
    [Console]::OutputEncoding = $utf8
    $OutputEncoding = $utf8
}
catch {
    # Console encoding is best-effort only.
}

function Select-UiLanguage {
    Clear-Host
    Write-Host "iOS Indexing Checker for Windows" -ForegroundColor Green
    Write-Host ""
    Write-Host "Choose language / 选择语言"
    Write-Host "1. English"
    Write-Host "2. 中文"
    Write-Host ""

    while ($true) {
        $choice = Read-Host "Enter 1 or 2 / 请输入 1 或 2"
        $trimmedChoice = ""
        if ($null -ne $choice) {
            $trimmedChoice = $choice.Trim()
        }
        switch ($trimmedChoice) {
            "1" { return "en" }
            "2" { return "zh" }
            default {
                Write-Host "Please enter 1 or 2. / 请输入 1 或 2。" -ForegroundColor Yellow
            }
        }
    }
}

if ([string]::IsNullOrWhiteSpace($Language)) {
    if ($NoPrompt) {
        $Language = "en"
    }
    else {
        $Language = Select-UiLanguage
    }
}
$script:Language = $Language

$script:Text = @{
    en = @{
        title = "iOS Indexing Checker for Windows"
        continue = "Press Enter to continue"
        close = "Press Enter to close"
        logFile = "Log file: {0}"
        beforeStart = "Before you start:"
        prep1 = "1. Connect the iPhone by USB"
        prep2 = "2. Unlock the iPhone and tap `"Trust This Computer`""
        prep3 = "3. Open Settings on the iPhone"
        ready = "Press Enter when ready"
        checkingService = "Checking Apple Mobile Device Service..."
        noService = "Apple Mobile Device Service was not detected."
        noServiceDetail1 = "This usually means Apple Devices or iTunes is not installed."
        noServiceDetail2 = "Install Apple Devices or iTunes so Windows can recognize the iPhone, then run this tool again."
        startingService = "Starting Apple Mobile Device Service..."
        serviceRunning = "Apple Mobile Device Service is running."
        missingPythonNoWinget = "Python 3.9+ was not found, and winget was not found either. Install Python 3.9 or newer, then run this tool again."
        installPython = "Python was not found. The fallback path will install Python 3.12 with winget."
        installPythonDetail = "This step needs an internet connection. Windows may ask you to confirm the installation."
        pythonInstallFailed = "Python was not installed successfully. Install Python 3.9 or newer, then run this tool again."
        stillNoPython = "Python 3.9+ still was not found. Reopen PowerShell, or restart Windows and try again."
        createRuntime = "Creating local Python runtime {0}..."
        createRuntimeFailed = "Could not create the local runtime."
        installComponent = "Installing the iPhone log reader component..."
        installComponentFailed = "The iPhone log reader component could not be installed. Check the network, or put offline wheels in the wheels folder and try again."
        startExe = "Starting the offline core..."
        firstRun = "The first run may take 10-30 seconds while Windows prepares or scans the program. Please keep this window open."
        heartbeat = "Core is still running: waited {0} seconds, {1} seconds since last output."
        missingCoreScript = "Core script was not found: {0}"
        incompletePackage = "This offline package is incomplete: IosIndexingProgress.exe is missing. Extract the full ZIP again."
        fallbackRuntime = "The no-install core was not found. Switching to the maintainer fallback runtime."
        success = "Done: iOS indexing progress was found."
        noProgress = "No indexing progress was found this time. Keep the iPhone unlocked, keep Settings open, and run the tool again."
        finishedWithCode = "The tool finished with exit code: {0}"
    }
    zh = @{
        title = "iOS 索引进度查询工具（Windows）"
        continue = "按 Enter 继续"
        close = "按 Enter 关闭"
        logFile = "日志文件：{0}"
        beforeStart = "准备好之后："
        prep1 = "1. 用 USB 插上 iPhone"
        prep2 = "2. 解锁 iPhone，并点 信任此电脑"
        prep3 = "3. 在 iPhone 上打开 设置"
        ready = "准备好后按 Enter 开始"
        checkingService = "正在检查 Apple Mobile Device Service..."
        noService = "没有检测到 Apple Mobile Device Service。"
        noServiceDetail1 = "这通常表示还没安装 Apple Devices 或 iTunes 的 Windows 驱动。"
        noServiceDetail2 = "请先安装 Apple Devices 或 iTunes，让 Windows 能识别 iPhone，然后重新运行这个工具。"
        startingService = "正在启动 Apple Mobile Device Service..."
        serviceRunning = "Apple Mobile Device Service 正在运行。"
        missingPythonNoWinget = "没有找到 Python 3.9+，也没有找到 winget。请先安装 Python 3.9 或更新版本，然后重新打开本工具。"
        installPython = "没有找到可用的 Python。备用流程会用 winget 安装 Python 3.12。"
        installPythonDetail = "这个步骤需要联网，Windows 可能会弹出安装确认。"
        pythonInstallFailed = "Python 安装没有成功。请安装 Python 3.9+ 后再运行本工具。"
        stillNoPython = "仍然没有找到 Python 3.9+。请重新打开 PowerShell，或重启 Windows 后再试。"
        createRuntime = "正在创建本地运行环境 Python {0}..."
        createRuntimeFailed = "创建本地运行环境失败。"
        installComponent = "正在安装 iPhone 日志读取组件..."
        installComponentFailed = "iPhone 日志读取组件安装失败。请检查网络，或把离线 wheels 放到本目录的 wheels 文件夹后再试。"
        startExe = "正在启动离线核心程序..."
        firstRun = "第一次运行可能需要 10-30 秒解压运行时或被安全软件扫描；这期间请不要关闭窗口。"
        heartbeat = "核心程序仍在运行：已等待 {0} 秒，距上次输出 {1} 秒。"
        missingCoreScript = "找不到核心脚本：{0}"
        incompletePackage = "这个离线包不完整：缺少 IosIndexingProgress.exe。请重新解压完整 ZIP。"
        fallbackRuntime = "没有找到免安装核心程序，转入维护者备用运行环境准备流程。"
        success = "完成：已经读到 iOS 索引进度。"
        noProgress = "这次没有读到索引进度日志。保持 iPhone 解锁并打开 设置，可以再运行一次。"
        finishedWithCode = "工具结束，退出码：{0}"
    }
}

function T {
    param(
        [Parameter(Mandatory = $true)][string]$Key,
        [Parameter(ValueFromRemainingArguments = $true)][object[]]$FormatArgs
    )

    $value = $script:Text[$script:Language][$Key]
    if ($null -eq $value) {
        $value = $script:Text["en"][$Key]
    }

    if ($null -ne $FormatArgs -and $FormatArgs.Count -gt 0) {
        return ($value -f $FormatArgs)
    }

    return $value
}

$script:Root = Split-Path -Parent $MyInvocation.MyCommand.Path
$script:RuntimeRoot = Join-Path $script:Root ".ios-indexing-runtime"
$script:VenvPath = Join-Path $script:RuntimeRoot "venv"
$script:VenvPython = Join-Path $script:VenvPath "Scripts\python.exe"
$script:CheckerScript = Join-Path $script:Root "ios-indexing-progress-windows.ps1"
$script:BundledExe = Join-Path $script:Root "IosIndexingProgress.exe"
$script:LogPath = Join-Path $script:Root "ios-indexing-checker.log"

function Write-Log {
    param([Parameter(Mandatory = $true)][string]$Message)
    $line = "[{0}] {1}" -f (Get-Date -Format "yyyy-MM-dd HH:mm:ss"), $Message
    Add-Content -LiteralPath $script:LogPath -Encoding UTF8 -Value $line
}

function Write-Step {
    param([Parameter(Mandatory = $true)][string]$Message)
    Write-Host ""
    Write-Host $Message -ForegroundColor Cyan
    Write-Log $Message
}

function Wait-User {
    param([string]$Message)
    if ([string]::IsNullOrWhiteSpace($Message)) {
        $Message = T "continue"
    }
    [void](Read-Host $Message)
}

function Test-PythonVersion {
    param(
        [Parameter(Mandatory = $true)][string]$Command,
        [string[]]$Arguments = @()
    )

    $probe = @"
import sys
major, minor = sys.version_info[:2]
print(f"{major}.{minor}")
sys.exit(0 if (major, minor) >= (3, 9) else 1)
"@

    try {
        $output = & $Command @Arguments -c $probe 2>$null
        if ($LASTEXITCODE -eq 0) {
            return [pscustomobject]@{
                Command = $Command
                Arguments = $Arguments
                Version = [string]$output
            }
        }
    }
    catch {
        return $null
    }

    return $null
}

function Find-Python {
    $candidates = @(
        @{ Command = "py"; Args = @("-3") },
        @{ Command = "python"; Args = @() },
        @{ Command = "python3"; Args = @() }
    )

    foreach ($candidate in $candidates) {
        $found = Get-Command $candidate.Command -ErrorAction SilentlyContinue
        if ($null -eq $found) {
            continue
        }

        $result = Test-PythonVersion -Command $candidate.Command -Arguments $candidate.Args
        if ($null -ne $result) {
            return $result
        }
    }

    return $null
}

function Install-PythonWithWinget {
    $winget = Get-Command "winget.exe" -ErrorAction SilentlyContinue
    if ($null -eq $winget) {
        throw (T "missingPythonNoWinget")
    }

    Write-Step (T "installPython")
    Write-Host (T "installPythonDetail")
    Wait-User

    & $winget.Source install -e --id Python.Python.3.12 --accept-package-agreements --accept-source-agreements
    if ($LASTEXITCODE -ne 0) {
        throw (T "pythonInstallFailed")
    }
}

function Ensure-AppleMobileDevice {
    Write-Step (T "checkingService")
    $service = Get-Service -Name "Apple Mobile Device Service" -ErrorAction SilentlyContinue
    if ($null -eq $service) {
        Write-Step (T "noService")
        Write-Host (T "noServiceDetail1")
        Write-Host (T "noServiceDetail2")
        throw (T "noService")
    }

    if ($service.Status -ne "Running") {
        Write-Step (T "startingService")
        Start-Service -Name "Apple Mobile Device Service"
        Start-Sleep -Seconds 2
    }

    Write-Step (T "serviceRunning")
}

function Test-Pymobiledevice3 {
    param([Parameter(Mandatory = $true)][string]$PythonExe)

    & $PythonExe -c "import importlib.util, sys; sys.exit(0 if importlib.util.find_spec('pymobiledevice3') else 1)" *> $null
    return ($LASTEXITCODE -eq 0)
}

function Ensure-Runtime {
    if (Test-Path -LiteralPath $script:VenvPython) {
        if (Test-Pymobiledevice3 -PythonExe $script:VenvPython) {
            return
        }
    }

    $hostPython = Find-Python
    if ($null -eq $hostPython) {
        Install-PythonWithWinget
        $hostPython = Find-Python
    }

    if ($null -eq $hostPython) {
        throw (T "stillNoPython")
    }

    if (-not (Test-Path -LiteralPath $script:RuntimeRoot)) {
        New-Item -ItemType Directory -Force -Path $script:RuntimeRoot | Out-Null
    }

    if (-not (Test-Path -LiteralPath $script:VenvPython)) {
        Write-Step (T "createRuntime" $hostPython.Version)
        & $hostPython.Command @($hostPython.Arguments + @("-m", "venv", $script:VenvPath))
        if ($LASTEXITCODE -ne 0) {
            throw (T "createRuntimeFailed")
        }
    }

    Write-Step (T "installComponent")
    $wheels = Join-Path $script:Root "wheels"
    if (Test-Path -LiteralPath $wheels) {
        & $script:VenvPython -m pip install --no-index --find-links $wheels -U pymobiledevice3
    }
    else {
        & $script:VenvPython -m pip install -U pymobiledevice3
    }

    if ($LASTEXITCODE -ne 0) {
        throw (T "installComponentFailed")
    }
}

function Start-Checker {
    if (Test-Path -LiteralPath $script:BundledExe) {
        Write-Step (T "startExe")
        Write-Host (T "firstRun")

        $exeArgs = @("--duration", $DurationSeconds, "--language", $script:Language)
        if (-not [string]::IsNullOrWhiteSpace($DeviceId)) {
            $exeArgs += @("--udid", $DeviceId)
        }
        if ($Raw) {
            $exeArgs += "--raw"
        }

        Write-Log ("Core command: {0} {1}" -f $script:BundledExe, ($exeArgs -join " "))
        $job = Start-Job -ScriptBlock {
            param($Executable, $Arguments, $Root)
            Set-Location -LiteralPath $Root
            $runtimeTmp = Join-Path $Root "runtime-tmp"
            New-Item -ItemType Directory -Force -Path $runtimeTmp | Out-Null
            $env:TEMP = $runtimeTmp
            $env:TMP = $runtimeTmp
            & $Executable @Arguments 2>&1
            [pscustomobject]@{ __IosIndexingCheckerExitCode = $LASTEXITCODE }
        } -ArgumentList $script:BundledExe, $exeArgs, $script:Root

        $started = Get-Date
        $lastOutput = Get-Date
        $lastHeartbeat = Get-Date
        $exitCode = $null

        try {
            while ($job.State -eq "Running") {
                $items = Receive-Job -Job $job
                foreach ($item in $items) {
                    if ($item.PSObject.Properties.Name -contains "__IosIndexingCheckerExitCode") {
                        $exitCode = [int]$item.__IosIndexingCheckerExitCode
                        continue
                    }
                    $text = [string]$item
                    if (-not [string]::IsNullOrWhiteSpace($text)) {
                        Write-Host $text
                        Write-Log $text
                        $lastOutput = Get-Date
                    }
                }

                $now = Get-Date
                if (($now - $lastHeartbeat).TotalSeconds -ge 5) {
                    $elapsed = [int](($now - $started).TotalSeconds)
                    $silent = [int](($now - $lastOutput).TotalSeconds)
                    Write-Host (T "heartbeat" $elapsed $silent) -ForegroundColor DarkGray
                    Write-Log ("Heartbeat: elapsed={0}s silent={1}s" -f $elapsed, $silent)
                    $lastHeartbeat = $now
                }

                Start-Sleep -Milliseconds 500
            }

            $items = Receive-Job -Job $job
            foreach ($item in $items) {
                if ($item.PSObject.Properties.Name -contains "__IosIndexingCheckerExitCode") {
                    $exitCode = [int]$item.__IosIndexingCheckerExitCode
                    continue
                }
                $text = [string]$item
                if (-not [string]::IsNullOrWhiteSpace($text)) {
                    Write-Host $text
                    Write-Log $text
                }
            }
        }
        finally {
            Remove-Job -Job $job -Force -ErrorAction SilentlyContinue
        }

        if ($null -eq $exitCode) {
            Write-Log "Core exited without an exit-code marker."
            return 99
        }

        Write-Log ("Core exit code: {0}" -f $exitCode)
        return $exitCode
    }

    if (-not (Test-Path -LiteralPath $script:CheckerScript)) {
        throw (T "missingCoreScript" $script:CheckerScript)
    }

    $args = @(
        "-NoProfile",
        "-ExecutionPolicy", "Bypass",
        "-File", $script:CheckerScript,
        "-Backend", "pymobiledevice3",
        "-Python", $script:VenvPython,
        "-DurationSeconds", $DurationSeconds,
        "-Language", $script:Language
    )

    if (-not [string]::IsNullOrWhiteSpace($DeviceId)) {
        $args += @("-DeviceId", $DeviceId)
    }

    if ($Raw) {
        $args += "-Raw"
    }

    & powershell.exe @args
    return $LASTEXITCODE
}

Clear-Host
Write-Log ("PowerShell launcher started. Language={0}" -f $script:Language)
Write-Host (T "title") -ForegroundColor Green
Write-Host ""
Write-Host (T "logFile" $script:LogPath) -ForegroundColor DarkGray
Write-Host ""
Write-Host (T "beforeStart")
Write-Host (T "prep1")
Write-Host (T "prep2")
Write-Host (T "prep3")
Write-Host ""
if (-not $NoPrompt) {
    Wait-User (T "ready")
}

try {
    Ensure-AppleMobileDevice
    if (-not (Test-Path -LiteralPath $script:BundledExe)) {
        if (-not $AllowPythonFallback) {
            throw (T "incompletePackage")
        }
        Write-Step (T "fallbackRuntime")
        Ensure-Runtime
    }
    $code = Start-Checker

    Write-Host ""
    if ($code -eq 0) {
        Write-Host (T "success") -ForegroundColor Green
    }
    elseif ($code -eq 3) {
        Write-Host (T "noProgress") -ForegroundColor Yellow
    }
    else {
        Write-Host (T "finishedWithCode" $code) -ForegroundColor Yellow
    }
}
catch {
    Write-Host ""
    Write-Host $_.Exception.Message -ForegroundColor Red
}

Write-Host ""
if (-not $NoPrompt) {
    Wait-User (T "close")
}
