<# 
.SYNOPSIS
Shows iOS Spotlight indexing progress from Windows.

.DESCRIPTION
This script streams the connected iPhone's live syslog and extracts the
PipelineCompleteness percentage used by the iOS indexing banner.

It prefers pymobiledevice3 because it runs on Windows and can read iOS syslog
over the Apple Mobile Device / usbmux path. If idevicesyslog is installed, the
script can also use that as a fallback backend.
#>

[CmdletBinding()]
param(
    [ValidateSet("auto", "pymobiledevice3", "idevicesyslog")]
    [string]$Backend = "auto",

    [int]$DurationSeconds = 180,

    [string]$DeviceId,

    [string]$Python = "python",

    [switch]$Install,

    [string]$InputPath,

    [switch]$Raw,

    [ValidateSet("en", "zh")]
    [string]$Language = "en"
)

Set-StrictMode -Version 2.0
$ErrorActionPreference = "Stop"

$script:LastPercent = $null
$script:MatchCount = 0
$script:InterestingCount = 0
$script:StartedAt = Get-Date

function Get-PipelinePercent {
    param([Parameter(Mandatory = $true)][string]$Line)

    $patterns = @(
        'PipelineCompleteness\s*[:=]\s*(?<percent>\d+(?:\.\d+)?)\s*%',
        'Pipeline\s+Completeness\s*[:=]\s*(?<percent>\d+(?:\.\d+)?)\s*%',
        'PipelineCompleteness\s*[:=]\s*(?<percent>\d+(?:\.\d+)?)'
    )

    foreach ($pattern in $patterns) {
        $match = [regex]::Match($Line, $pattern, [System.Text.RegularExpressions.RegexOptions]::IgnoreCase)
        if ($match.Success) {
            return [double]::Parse($match.Groups["percent"].Value, [System.Globalization.CultureInfo]::InvariantCulture)
        }
    }

    return $null
}

function Test-IndexingLine {
    param([Parameter(Mandatory = $true)][string]$Line)

    $lower = $Line.ToLowerInvariant()
    if ($lower.Contains("pipelinecompleteness")) { return $true }
    if ($lower.Contains("spotlight indexing progress")) { return $true }
    if ($lower.Contains("spotlight") -and $lower.Contains("indexing") -and $lower.Contains("progress")) { return $true }

    return $false
}

function Write-ProgressLine {
    param([Parameter(Mandatory = $true)][string]$Line)

    if (-not (Test-IndexingLine -Line $Line)) {
        return
    }

    $script:InterestingCount++
    $percent = Get-PipelinePercent -Line $Line

    if ($Raw) {
        Write-Host $Line -ForegroundColor DarkGray
    }

    if ($null -ne $percent) {
        $script:MatchCount++
        $script:LastPercent = $percent
        $display = $percent.ToString("0.##", [System.Globalization.CultureInfo]::InvariantCulture)
        Write-Host ("[{0}] iOS indexing progress: {1}%" -f (Get-Date -Format "HH:mm:ss"), $display) -ForegroundColor Green
    }
    elseif (-not $Raw) {
        Write-Host ("[{0}] Saw an indexing log line, but it did not contain PipelineCompleteness. Add -Raw to inspect it." -f (Get-Date -Format "HH:mm:ss")) -ForegroundColor Yellow
    }
}

function Test-PythonModule {
    param([Parameter(Mandatory = $true)][string]$PythonExe)

    & $PythonExe -c "import importlib.util, sys; sys.exit(0 if importlib.util.find_spec('pymobiledevice3') else 1)" *> $null
    return ($LASTEXITCODE -eq 0)
}

function Install-Pymobiledevice3 {
    param([Parameter(Mandatory = $true)][string]$PythonExe)

    Write-Host "Installing or updating pymobiledevice3 for this Windows user..." -ForegroundColor Cyan
    & $PythonExe -m pip install --user -U pymobiledevice3
    if ($LASTEXITCODE -ne 0) {
        throw "pip could not install pymobiledevice3. Check your network and Python installation, then try again."
    }
}

function Resolve-Backend {
    $hasPmd3 = $false
    try {
        $hasPmd3 = Test-PythonModule -PythonExe $Python
    }
    catch {
        if ($Backend -eq "pymobiledevice3" -or $Install) {
            throw
        }
    }

    if ($Install -and -not $hasPmd3) {
        Install-Pymobiledevice3 -PythonExe $Python
        $hasPmd3 = Test-PythonModule -PythonExe $Python
    }

    $ideviceCommand = Get-Command "idevicesyslog.exe" -ErrorAction SilentlyContinue
    if ($null -eq $ideviceCommand) {
        $ideviceCommand = Get-Command "idevicesyslog" -ErrorAction SilentlyContinue
    }

    if ($Backend -eq "pymobiledevice3") {
        if (-not $hasPmd3) {
            throw "pymobiledevice3 is not installed. Re-run with -Install, or install it with: python -m pip install --user -U pymobiledevice3"
        }
        return @{ Name = "pymobiledevice3"; Command = $Python }
    }

    if ($Backend -eq "idevicesyslog") {
        if ($null -eq $ideviceCommand) {
            throw "idevicesyslog was not found on PATH."
        }
        return @{ Name = "idevicesyslog"; Command = $ideviceCommand.Source }
    }

    if ($hasPmd3) {
        return @{ Name = "pymobiledevice3"; Command = $Python }
    }

    if ($null -ne $ideviceCommand) {
        return @{ Name = "idevicesyslog"; Command = $ideviceCommand.Source }
    }

    throw "No supported iOS syslog backend is installed. Re-run this script with -Install to add pymobiledevice3."
}

function Start-Pymobiledevice3Job {
    param(
        [Parameter(Mandatory = $true)][string]$PythonExe,
        [string]$TargetDeviceId
    )

    return Start-Job -ScriptBlock {
        param($PythonExeInner, $TargetDeviceIdInner)
        if (-not [string]::IsNullOrWhiteSpace($TargetDeviceIdInner)) {
            $env:PYMOBILEDEVICE3_UDID = $TargetDeviceIdInner
        }
        & $PythonExeInner -m pymobiledevice3 --no-color --reconnect syslog live --match-insensitive "spotlight indexing progress" 2>&1
    } -ArgumentList $PythonExe, $TargetDeviceId
}

function Start-IdeviceSyslogJob {
    param(
        [Parameter(Mandatory = $true)][string]$Executable,
        [string]$TargetDeviceId
    )

    return Start-Job -ScriptBlock {
        param($ExecutableInner, $TargetDeviceIdInner)
        if (-not [string]::IsNullOrWhiteSpace($TargetDeviceIdInner)) {
            & $ExecutableInner -u $TargetDeviceIdInner 2>&1
        }
        else {
            & $ExecutableInner 2>&1
        }
    } -ArgumentList $Executable, $TargetDeviceId
}

function Receive-JobLines {
    param([Parameter(Mandatory = $true)]$Job)

    $items = Receive-Job -Job $Job
    foreach ($item in $items) {
        $line = [string]$item
        if ([string]::IsNullOrWhiteSpace($line)) {
            continue
        }

        if ($line -match "Device is not connected|Device is not paired|Waiting for user dialog approval|User refused|Failed to connect|NoDeviceConnected|NotPaired") {
            Write-Host $line -ForegroundColor Yellow
            continue
        }

        Write-ProgressLine -Line $line
    }
}

function Watch-Backend {
    param([Parameter(Mandatory = $true)][hashtable]$ResolvedBackend)

    if ($ResolvedBackend.Name -eq "pymobiledevice3") {
        $job = Start-Pymobiledevice3Job -PythonExe $ResolvedBackend.Command -TargetDeviceId $DeviceId
    }
    else {
        $job = Start-IdeviceSyslogJob -Executable $ResolvedBackend.Command -TargetDeviceId $DeviceId
    }

    try {
        while ($true) {
            Receive-JobLines -Job $job

            if ($job.State -ne "Running") {
                Receive-JobLines -Job $job
                break
            }

            if ($DurationSeconds -gt 0) {
                $elapsed = ((Get-Date) - $script:StartedAt).TotalSeconds
                if ($elapsed -ge $DurationSeconds) {
                    Stop-Job -Job $job -ErrorAction SilentlyContinue
                    break
                }
            }

            Start-Sleep -Milliseconds 500
        }
    }
    finally {
        if ($job.State -eq "Running") {
            Stop-Job -Job $job -ErrorAction SilentlyContinue
        }
        Remove-Job -Job $job -Force -ErrorAction SilentlyContinue
    }
}

if ($InputPath) {
    if (-not (Test-Path -LiteralPath $InputPath)) {
        throw "InputPath does not exist: $InputPath"
    }

    Get-Content -LiteralPath $InputPath | ForEach-Object {
        Write-ProgressLine -Line $_
    }
}
else {
    $resolved = Resolve-Backend
    Write-Host ("Backend: {0}" -f $resolved.Name) -ForegroundColor Cyan
    Write-Host "Connect the iPhone by USB, unlock it, tap Trust if asked, then open Settings on the iPhone." -ForegroundColor Cyan

    if ($DurationSeconds -gt 0) {
        Write-Host ("Watching for indexing logs for {0} seconds..." -f $DurationSeconds) -ForegroundColor Cyan
    }
    else {
        Write-Host "Watching until you press Ctrl+C..." -ForegroundColor Cyan
    }

    Watch-Backend -ResolvedBackend $resolved
}

if ($null -ne $script:LastPercent) {
    $final = $script:LastPercent.ToString("0.##", [System.Globalization.CultureInfo]::InvariantCulture)
    Write-Host ("Latest iOS indexing progress seen: {0}%" -f $final) -ForegroundColor Green
    exit 0
}

if ($script:InterestingCount -gt 0) {
    Write-Host "Indexing-related logs appeared, but no PipelineCompleteness percentage was found. Re-run with -Raw and compare the message text." -ForegroundColor Yellow
    exit 1
}

Write-Host "No indexing progress log was seen." -ForegroundColor Yellow
Write-Host "Checklist: keep the iPhone unlocked, trust this Windows PC, open Settings on the iPhone, leave it plugged in, and try a longer -DurationSeconds value." -ForegroundColor Yellow
exit 3
