If ( !(Test-Path ahk.zip -PathType Leaf)) {
    Invoke-WebRequest -Uri "https://www.autohotkey.com/download/1.1/AutoHotkey_1.1.26.01.zip" -OutFile "AutoHotkey_1.1.26.01.zip"
}

If ( !(Test-Path ahk\Compiler\Ahk2Exe.exe -PathType Leaf)) {
    Expand-Archive AutoHotkey_1.1.26.01.zip -DestinationPath ahk
}

mkdir -Force build

Write-Host "Compiling with Ahk2Exe..."
.\ahk\Compiler\Ahk2Exe.exe /in '.\KDE Mover-Sizer.ahk' /out '.\build\KDE Mover-Sizer.exe' /icon '.\KDE Mover-Sizer.ico' /bin "ahk\Compiler\Unicode 32-bit.bin" /cp 65001

