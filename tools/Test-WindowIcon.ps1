param([string]$Executable = "$PSScriptRoot/../artifacts/win-x64/RF4PIP.exe")
$ErrorActionPreference = 'Stop'
Add-Type -AssemblyName System.Drawing
if (-not ('RF4IconProbe' -as [type])) {
    Add-Type @"
using System;
using System.Runtime.InteropServices;
public static class RF4IconProbe {
 [DllImport("user32.dll")] public static extern IntPtr SendMessage(IntPtr h, uint m, IntPtr w, IntPtr l);
}
"@
}
$process = Start-Process -FilePath (Resolve-Path $Executable).Path -WindowStyle Hidden -PassThru
try {
    $deadline = (Get-Date).AddSeconds(30)
    do {
        Start-Sleep -Milliseconds 250
        $process.Refresh()
        if ($process.HasExited) { throw 'App exited before opening its window.' }
    } while ($process.MainWindowTitle -ne 'RF4 PIP' -and (Get-Date) -lt $deadline)
    if ($process.MainWindowTitle -ne 'RF4 PIP') { throw 'Window did not appear.' }
    foreach ($kind in @(0,1)) {
        $handle = [RF4IconProbe]::SendMessage($process.MainWindowHandle,0x7F,[IntPtr]$kind,[IntPtr]::Zero)
        if ($handle -eq [IntPtr]::Zero) { throw 'Missing window icon.' }
        $icon = [Drawing.Icon]::FromHandle($handle)
        $bitmap = $icon.ToBitmap()
        try {
            $minX=$bitmap.Width; $minY=$bitmap.Height; $maxX=-1; $maxY=-1
            for($y=0;$y -lt $bitmap.Height;$y++) {
                for($x=0;$x -lt $bitmap.Width;$x++) {
                    if($bitmap.GetPixel($x,$y).A -gt 30) {
                        $minX=[Math]::Min($minX,$x); $maxX=[Math]::Max($maxX,$x)
                        $minY=[Math]::Min($minY,$y); $maxY=[Math]::Max($maxY,$y)
                    }
                }
            }
            $width=$maxX-$minX+1; $height=$maxY-$minY+1
            if($height -lt $bitmap.Height*0.9 -or $width -lt $bitmap.Width*0.75) {
                throw "Icon $kind artwork too small: ${width}x${height} in $($bitmap.Width)x$($bitmap.Height)"
            }
            "PASS: icon $kind artwork ${width}x${height} in $($bitmap.Width)x$($bitmap.Height)"
        } finally { $bitmap.Dispose() }
    }
} finally {
    if(-not $process.HasExited) {
        $process.CloseMainWindow() | Out-Null
        if(-not $process.WaitForExit(10000)) { $process.Kill(); $process.WaitForExit() }
    }
}
