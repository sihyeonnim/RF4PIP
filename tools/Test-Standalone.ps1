param([string]$Executable = "$PSScriptRoot/../artifacts/release-1.0-fixed/RF4PIP.exe")
$ErrorActionPreference = 'Stop'
# Test exactly the download experience: only the EXE, no neighboring native DLLs.
$directory = Join-Path ([IO.Path]::GetTempPath()) ("RF4PIP-smoke-" + [Guid]::NewGuid())
New-Item -ItemType Directory -Path $directory | Out-Null
$target = Join-Path $directory 'RF4PIP.exe'
Copy-Item -LiteralPath $Executable -Destination $target
$process = Start-Process -FilePath $target -WorkingDirectory $directory -WindowStyle Hidden -PassThru
try {
    $deadline = (Get-Date).AddSeconds(30)
    do {
        Start-Sleep -Milliseconds 250
        $process.Refresh()
        if ($process.HasExited) { throw "App exited before opening a window: $($process.ExitCode)" }
    } while ($process.MainWindowTitle -ne 'RF4 PIP' -and (Get-Date) -lt $deadline)
    if ($process.MainWindowTitle -ne 'RF4 PIP' -or -not $process.Responding) { throw 'No responsive RF4 PIP window.' }
    if (-not $process.CloseMainWindow()) { throw 'Window close request failed.' }
    if (-not $process.WaitForExit(10000)) { throw 'App did not exit after window close.' }
    if ($process.ExitCode -ne 0) { throw "Unexpected exit code: $($process.ExitCode)" }
    'PASS: isolated EXE opens a responsive RF4 PIP window and exits cleanly.'
}
finally {
    if (-not $process.HasExited) { $process.Kill(); $process.WaitForExit() }
    # Remove only the generated test file and its empty, uniquely named directory.
    Remove-Item -LiteralPath $target
    Remove-Item -LiteralPath $directory
}
