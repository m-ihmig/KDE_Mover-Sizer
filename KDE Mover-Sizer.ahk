;   Internationally known as "KDE Mover-Sizer"                               Version 2.12
;
;   http://corz.org/windows/software/accessories/KDE-resizing-moving-for-Windows.php

;   Which is essentially..

;   Easy Window Dragging -- KDE style (requires XP/2k/NT) -- by Jonny
;   ..with nobs on. See http://www.autohotkey.com and their forum.
;
;   This script makes it much easier to move or resize a window:
;   1) Hold down the ALT key and LEFT-click anywhere inside a window to drag it to a new location
;   2) Hold down ALT and RIGHT-click-drag anywhere inside a window to easily resize it
;   3) Press ALT twice, but before releasing it the second time,
;      left-click to minimize the window under the mouse cursor,
;      right-click to maximize it, or middle-click to close it.
;
;   This script was inspired by and built on many like it in the forum. Thanks 
;   go out to ck, thinkstorm, Chris, and aurelian for a job well done.

; Known issues:
; - MButton Drag Scrolling is not working on new windows applications based on ApplicationFrameHost.exe (such Calculator or certain setting pages)
;   For some reason, they only react on SendEvent{Wheel}, but not on PostMessage WM_MOUSEVWHEEL
; - Dragging SYSTEM_AWARE windows across monitors with different DPIs wrongly moves the window origin (causing even fluttering in a certain area) while the window is on both screens.
;   Reason is that having the Mouse Cursor on a different screen than the Window Center causes inconsistent Win/AHK-internal DPI-scaling

; ToDo:
; - Test for different (DoubleAlt-)hotkeys if Send {Blind} is really no longer necessary
; - Add option to disable Horizontal dragging
; - add fullpath to MenuHideIcon for kms ini File
; - add comment to version check about the brittleness of Alt/DiubleAlt and Menu handling
;   Itstory:
;   Feb  25, 2026:      Added: Correct scaling for moving PER_MONITOR_AWARE between monitors with different DPI.
;                              Hint if "Showing window contents while dragging" is disabled: press Control (WindowToFront) hotkey to force window update on current position
;                       Clean: Removed FocuslessScroll_Modifier. Never tested, never used
;   Feb  27, 2025:      Added: Horizontal drag-scrolling (Change DragScrollIntervalDirectionChange_us to change how easy vertical and horizontal drag-scrolling can be switched)
;                       Added: Finer grid for QuickPosition-to-grid (16x16->24x24)
;                       Added: Press "Control" during Move/Resize to bring currently dragged Window to foreground
;                       Fixed: For MButton Drag Scroll: have separate Ignore-Window list and another list for applications that only support full-step scrolls (multiples of 120)
;                              Use this to fix issue that each first wheel up/down event is ignored once MButton scrolling was used
;                              Also, in case of delayed or stuttering scroll, try increasing DragScrollMinUpdateInterval_us
;                       Added: DPI-aware Borderless snapping (consider invisible frame border around a window) during Snap-to-Border or QuickPosition-to-grid
;                       Added: Option to Run as administrator with elevated permissions
;                       Added: Create and remove shortcut link in startup folder for autostart
;                       Added: Drag scrolling when holding middle mouse button. Don't move to generate middle click
;                       Fixed: Make IgnoreWindows work for apps from Windows' apps framework that don't have a unique processname (e.g Calculator), includes class name (e.g. for Desktop)
;                       Fixed: Mask menu for Alt and LWin Hotkey when using QuickPosition
;                       Fixed: Allow click with active Alt+Tab task switcher for Win10 and Win11

;   Sep  10, 2014:      Added option to hide tray icon - a message will appear first, warning you that you have no easy way to shutdown KMS
;   Aug  10, 2013:      Added: Option to use 3x3 grid for resizing as to lock resizing horizontally or vertically depending on mouse position
;                       Fixed: Resizing wrong window after resizing a restored maximized window
;   July 28, 2013:      Moved options into "Options" submenu and merged with "Resize Options"
;                       Changed WheelUp/Down: SendMessage replaced with PostMessage for extended application support for Focusless scrolling
;   July 25, 2013:      removed "SendMode Input" and added a static m-hook button (~^!+MButton) for testing compatibility with MacroExpress
;   July 22, 2013:      Added focusless scrolling: sends WheelUP/Down to Window under mousecursor, even if not active (mih, shimanov, scoox)
;   June  7, 2013:      Changed Hotkey handling back to use RegisterHotkey() instead of keyboard hook (no $)
;                       Updated Tooltips and About box to show actual hotkeys instead of the default ones
;                       Added more grid lines for QuickPositioning: Now at 1/4, 1/3, 0.382 and 1/2 plus 3 center grids (mih)
;   June  5, 2013:      Improved handling of horizontal/vertical locking during resizing
;   May  14, 2013:      Added LockHorizontalVertical: Press LockHorizVert_Hotkey2 (default: Shift) during Moving or Resizing
;                       to constrain mouse to either horizontal or vertical movements (mih)
;                       Added Hide Windows content while moving and resizing
;   Aug   8, 2012:      Added QuickPositionWindow: Press QuickPosition_Hotkey2 during Moving or Resizing to quickly position window on screen edge (mih)
;   Aug   6, 2012:      Added special feature: Insert Special Character with hotkey (mih)
;                         Can be used to define shortcuts (e.g. AltGr+c) to insert special characters (e.g. cedille) from foreign languages
;                         Example: Press AltGr + c to enter French cedille .  Add new
;                         Configuration: Edit .INI File, Section [SpecialCharacters]
;                           Add new SpecialCharactersTrig_# and SpecialCharactersChar_# and Increment SpecialCharacters_Num
;                           See here for trigger key symbols: http://www.autohotkey.com/docs/Hotkeys.htm
;                         Known Limitations:
;                           If Mover-Sizer hotkey is Ctrg+Alt, it collides with SpecialCharacter Hotkey AltGr
;                           only works for ASCII/ANSII character set. No Unicode (UTF-8/UTF-16/...)!
;   Aug   1, 2012:      Changed default for LWin hotkey, ShowMeasuresAsTooltip=1, DrawGridShowDistance=1
;                       Changed default for AltGr: DrawGridOverlay_Hotkey=<^>!+
;   July 27, 2012:      Fixed: send DoubleKey_hotkey2 after execution of hotkey action
;   July 22, 2012:      Added option to disable Double-Alt shortcuts
;                       Fixed loop performance issues and window redraw for DrawGrid
;   July 19, 2012:      Added option to show grid measurements as a ToolTip (for folk with balloon tips disabled)
;                       This also prevents the Taskbar from popping into view when measuring (if you have it hidden) ~ Cor
;   July 17, 2012:      Added special feature "Draw Grid" to overlay golden ratio/3x3 & 4x4 grid to analyze images (mih)
;                       Added colour sampler
;                       Added Escape button to abort moving & resizing
;                       Added script reload after closing INI editor
;                       Added configurable hotkeys (based on jlr's version)
;   May 17, 2011:       Added "Ignore Window" list to pass-through hotkeys (e.g. for Remote Desktop or Adobe Photoshop) (mih)
;   October 31, 2009:   Added special feature "Always On Top". Click with the cross cursor on a window you want to toggle AlwaysOnTop (mih)
;   October 12, 2009:   V3 icon! (the last one produced even more mails!). This one rocks. No complaints please!
;                       You can now get straight to the KDE Mover-Sizer page from the About dialog.
;                       Removed superfluous default AutoHotKey tray menu items.
;                       Added an "Enable HotKeys" tray menu item, which toggles the HotKeys (it un/checks) 
;                       Added an Exit menu item and simple exit function.
;                       Added a menu option to get to the ini file, to hack at the things there's no menu item for.
;                       All current prefs get written to the ini file so the user can see/set what's available.
;                       Cleaned up documentation and web page, some. More to come. Maybe even comments!
;                       Added about box text, some default prefs, tray, gui + menu fixes, other minor stuff.    ~ Cor
;   October 10, 2009:   Added new algorithm for Snapping on Resize (mih)
;                       Added option for Restoring Window on Resize
;   October 4, 2009:    Added full support for multi screens (incl. snapping) (mih)
;                       Fixed Snapping on WorkArea (excluding task bar)
;                       Added INI option for Snapping Distance and WinDelay
;                       Added About box
;   October 3, 2009:    Added configuration file and option to enable&disable snapping (mih)
;                       Added snapping for (Alt-Left-Click) Moving Windows
;   June 16, 2009:      Added Vista Alt-Tab fix (by jordoex)
;                       Added an information tip for the tray hover. Updated Icon (I noticed it 
;                       clashed with a portable Linux I recently tried, so I created an original 
;                       icon for KDE Mover-Sizer. ~ Cor
;   March    10, 2009:  Moving a maximized windows is now possible (First WinRestore to orig. size, then move)
;                       Added: Alt+Middle Button maximizes/restores a window (mih)
;   December 04, 2007:  Window snap-to-edge - just like KDE, but with extra fun!
;                       Added Tray ToolTip help. ~ Cor
;   November 07, 2006:  Optimized resizing code in !RButton, courtesy of bluedawn.
;   February 05, 2006:  Fixed double-alt (the ~Alt hotkey) to work with latest versions of AHK.


;   Snap-To Edges ..
;
;   If their edge comes within ten pixels of your desktop edge, the window snaps to it. 
;   Very neat;  it's what KDE does. But there's more..
;
;   If you keep mousing after the window snaps, you get a beautiful resizing control which
;   keeps on going. Also you can Alt-right-click any oversized windows and pop them straight back 
;   into the desktop. Note: If you are quick enough, you can break the snap when needed. 
;   Have fun! NOTE: You can now disable the right-click-to-snap behaviour, if preferred.
;
;   ;o) Cor
;
;   June 16, 2009:
;
;       Since giving this a page of its own, it's become insanely popular, 
;       and keeps finding its way onto those "five wee apps you can't live
;       without" type lists, which says a lot for the kind of software you
;       can have for yourself if you only rake about in the AutoIt and 
;       AutoHotKey forums once in a while.

;   NOTE: If your application wants the Alt key for hotkey modifiers, use Alt+Win+Key for that.
;   It's quite easy once you do it a few times, simply roll your thumb and finger on and off.


;***********************
; Prepare Default configuration and do basic version checks
;

#SingleInstance Force
#NoEnv                     ; Recommended for performance and compatibility with future AutoHotkey releases. (jlr)
#MaxHotkeysPerInterval 200 ; Avoid warning when mouse wheel turned very fast

; for speedup and privacy
;#KeyHistory 0
;ListLines Off
; for debugging
;#KeyHistory 300

DefaultBatchLines := A_BatchLines
SetBatchLines, -1 ; speed-up startup. set to default during normal operation

MinVersion := "1.1.20.00"
MaxVersion := "1.1.26.01"
; Min Version is required for DragScroll to work.
; Max Version: For later versions I could not get that nested DoubleAlt/Alt+MButton/Alt-Up to work correctly with masking Menu focus.
;              Didn't find a single solution for later versions, that worked for e.g. Notepad++, Firefox, Console and Calc at the same time.
;
;              Test these event sequences: (D=down, U=up, Mb=Mousebutton event)
;              - AltD + MbD + AltU + MbU
;              - AltD + MbD + MbU  + AltU
;              - AltD + MbD + AltU + AltD + MbU
;              - AltD + MbD + AltU + AltD + MbU + AltU
;              Watch Menu bar for shading/underlined key during and after key&mouse events
;              Try each sequences fast (no autorepeat) and slow with additional delay between each event (to check potential autorepeats)

;              This is the (unwanted) behaviour I got for AHK versions > 1.1.26.01:
;              When releasing LButton on Firefox during Quick-Position, the Menu is still selected,
;              (because scripted LControl down+up was always sent _after Alt+up with *Alt Up:: hotkey).
;              I didn't find a way to reverse this without destroying the Double-Alt stuff.
;              But for Firefox to work correctly, LControl down+up needs to be sent _immediately before_ Alt+Up to mask menu,
;              which only works if I release Alt quickly after the mouse button. If I keep it pressed, Alt-Autorepeat will reactive the Firefox menu.
;              - Send {Blind}{LControl} directly after releasing mouse button for QuickPosition did not work,
;                as additional LAlt+down keep coming in afterwards)
;              - Menu masking with Send {Blind}{vkE8} works for Firefox, but inserts ^@ characters into Console terminal windows without stdin -> cannot use this either
;              Helpful tool for debugging: https://w3c.github.io/uievents/tools/key-event-viewer.html
;              1.1.26.01 was the last version that sent LControl down+up correctly before the last Alt+Up event
;              If someone finds an elegant single solution with later AHK versions for Notepad, Firefox, cmd/conhost and Calc (e.g. masking menu with LControl), please let me know! (mih)
;
; For Unicode AHK Version, use UTF-8-BOM coding for .ahk file
;
; 32bit vs 64bit: At the moment, I don't see an advantage of the 64bit version. I've always used the 32bit version without issues on 64bit Windows up to Win11 without any issue.
;                 So for now, I suggest to just stay with a single 32bit version, for backwards compatibility and because it makes all that DllCall stuff a little simpler
;                 -> DllCall parameters are implemented as 32bit -> requires 32bit version of Autohotkey (which of course still runs as well on 64bit machines)

If (A_AhkVersion < MinVersion OR A_AhkVersion > MaxVersion OR A_PtrSize != 4)
{
    MsgBox, 0x34,,This script may not work properly with your version of AutoHotkey. Requirement:`n- 32bit AHK Version`n- Minimum AHK Version: %MinVersion%`n- Maximum AHK Version: %MaxVersion%`n`nContinue?
    IfMsgBox, No
        ExitApp
}

DefaultEnableFocuslessScroll    := 0   ; This is usually no longer required for Win10+..except when running very old SW, such as Office 2010, which still requires this option. So we don't hide it, just disable it by default.
DefaultBorderlessSnappingAndDPI := 0   ; Supports (and thus requires) DPI-awareness support -> only available on later Windows 10 versions
DefaultWindowIgnoreList         := ""

If (SubStr(A_OSVersion,1,3) != "WIN")
{
    ; For >= Win10
    If (A_OSVersion >= "10.0.14393")        ; for Windows 10 build 14393, aka version 1607 and greater
        DefaultBorderlessSnappingAndDPI := 1

    ; Hint: Put here everything that also need to be potentially ignored while the window in inactive/does not have focus.
    ; Comma-separated list of applications/processes, including terminating comma!
    DefaultWindowIgnoreList := ""
      . "explorer.exe/Progman," ; desktop
      . "explorer.exe/WorkerW," ; desktop (wallwaper)
      ;. "ShellExperienceHost.exe/Windows.UI.Core.CoreWindow," ; notifications
      . "explorer.exe/Shell_TrayWnd,explorer.exe/Shell_SecondaryTrayWnd," ; taskbar (Main and side screens)
      ;. "explorer.exe/Windows.UI.Core.CoreWindow,"  ; dashboard of active applications/multiple desktops
      ;. "SearchApp.exe," ; start menu and search menu
      ;. "StartMenuExperienceHost.exe,"

    ; Hint: Use GroupAdd, IgnoreActiveWindowsList only for windows that are always active(have focus/are in foreground) when it comes to ignoring KMS events (currently only Alt+Tab task switcher)
    ;       For all others, use (Default)WindowIgnoreList, which takes the windows under the current mouse position
    If (A_OSVersion >= "10.0.22000")           ; For >= "Win 11 21H2"
        GroupAdd, IgnoreActiveWindowsList, ahk_class XamlExplorerHostIslandWindow  ; Ignore Win 11 Alt+Tab
    else     ; For Win10
        GroupAdd, IgnoreActiveWindowsList, ahk_class MultitaskingViewFrame         ; Ignore Win 10 Alt+Tab

} else {
    ; For legacy Windows versions (< Win10)
    DefaultEnableFocuslessScroll := 1
    GroupAdd, IgnoreActiveWindowsList, ahk_class TaskSwitcherWnd               ; Ignore Win 7, 8.1, Vista Alt+Tab
}

Gosub, ReadIniFile


; ***********************************
; Global settings and variables
; ***********************************

; Global Constants
global WHEEL_DELTA    := 120 ; This is a windows constant, which is the equivalent for 1 Wheel Up/Down event
global WM_MOUSEWHEEL  := 0x20A  ; Window message used for vertical scrolling, typ.multiples of 4
global WM_MOUSEHWHEEL := 0x20E  ; Window message used for horizontal scrolling, typ.mulitiples of 16

global MSGICON_HAND              := 0x10
global MSGICON_QUESTION_OKCANCEL := 0x21
global MSGICON_EXCLAMATION       := 0x30
global MSGICON_INFO              := 0x40
global TRAYICON_INFO    :=  0x1
global TRAYICON_WARNING :=  0x2
global TRAYICON_ERROR   :=  0x3
global TRAYICON_NOSOUND := 0x10

global DPI_AWARENESS_CONTEXT_UNAWARE              := -1
global DPI_AWARENESS_CONTEXT_SYSTEM_AWARE         := -2
global DPI_AWARENESS_CONTEXT_PER_MONITOR_AWARE    := -3
global DPI_AWARENESS_CONTEXT_PER_MONITOR_AWARE_V2 := -4
global DPI_AWARENESS_CONTEXT_UNAWARE_GDISCALED    := -5
global DPI_AWARENESS_INVALID           := -1
global DPI_AWARENESS_UNAWARE           := 0
global DPI_AWARENESS_SYSTEM_AWARE      := 1
global DPI_AWARENESS_PER_MONITOR_AWARE := 2


;SendMode Input  ; Recommended for new scripts due to its superior speed and reliability. (jlr)
                 ; But SendMode Input also causess "Mouse Key Up" events being lost sometimes (even to GetKeyState),
                 ; resulting in a stuck DragScroll mode despite no button is pressed
                 ; -> don't use this in combination with enabled DragScroll

SetWinDelay, %WinDelay%

CoordMode, Mouse,Screen
CoordMode, Pixel,Screen
CoordMode, ToolTip,Screen

MayToggleMaximizeRestore := 1


startupLinkFile := A_Startup . "\KDE Mover-Sizer.lnk"

if (RunAsAdministrator = 1 AND A_IsAdmin = 1)
    IniRead,   startupLinkFile,  KDE_Mover-Sizer.ini, Settings, startupLinkFile, %startupLinkFile%
Else
    IniWrite, %startupLinkFile%, KDE_Mover-Sizer.ini, Settings, startupLinkFile

if (RunAsAdministrator = 1 AND A_IsAdmin = 0)
{
    Run, % "*RunAs " (A_IsCompiled ? "" : A_AhkPath " ") Chr(34) A_ScriptFullPath Chr(34),,UseErrorLevel
    If ErrorLevel
    {
        MsgBox, % MSGICON_EXCLAMATION, Run as Administrator failed, % "Failed to run with Administrator permissions.`r`nWill continue running as normal user...`r`n"

        RunAsAdministrator := 0
        IniWrite, %RunAsAdministrator%, KDE_Mover-Sizer.ini, Settings, RunAsAdministrator
        reload
    }
}

For i,s in ["WindowIgnoreList", "DragScrollWindowIgnoreList", "DragScrollFullScrollStepWindowList"]
If (SubStr(%s%, 0) != ",")
{
    newlist := %s% . ","
    IniWrite, %newlist%,   KDE_Mover-Sizer.ini, Settings, %s%
}

If BorderlessSnappingAndDPI
    SetDefaultDpiAwarenessContext()

Gosub, InitHotkeyHandler

Gosub, PrepareMenu

SetBatchLines, %DefaultBatchLines% ; we need sufficient idle time for windows repainting, so restore default

return



; ***************************************************************
; ********* INIT: Read (and write default) INI file *************
; ***************************************************************
;
ReadIniFile:
    IniRead,   SnapOnSizeEnabled,        KDE_Mover-Sizer.ini, Settings, SnapOnSizeEnabled, 1          ; default: true
    IniWrite, %SnapOnSizeEnabled%,       KDE_Mover-Sizer.ini, Settings, SnapOnSizeEnabled
    IniRead,   SnapOnMoveEnabled,        KDE_Mover-Sizer.ini, Settings, SnapOnMoveEnabled, 1          ; default: true
    IniWrite, %SnapOnMoveEnabled%,       KDE_Mover-Sizer.ini, Settings, SnapOnMoveEnabled
    IniRead,   BorderlessSnappingAndDPI, KDE_Mover-Sizer.ini, Settings, BorderlessSnappingAndDPI, %DefaultBorderlessSnappingAndDPI%
    IniWrite, %BorderlessSnappingAndDPI%,KDE_Mover-Sizer.ini, Settings, BorderlessSnappingAndDPI
    IniRead,   SnapOnResizeMagnetic,     KDE_Mover-Sizer.ini, Settings, SnapOnResizeMagnetic, 0       ; default: false
    IniWrite, %SnapOnResizeMagnetic%,    KDE_Mover-Sizer.ini, Settings, SnapOnResizeMagnetic
    IniRead,   DoRestoreOnResize,        KDE_Mover-Sizer.ini, Settings, DoRestoreOnResize,  1         ; default: true
    IniWrite, %DoRestoreOnResize%,       KDE_Mover-Sizer.ini, Settings, DoRestoreOnResize
    IniRead,   Use3x3ResizeGrid,         KDE_Mover-Sizer.ini, Settings, Use3x3ResizeGrid,  0          ; default: false (use 2x2 grid)
    IniWrite, %Use3x3ResizeGrid%,        KDE_Mover-Sizer.ini, Settings, Use3x3ResizeGrid
    IniRead,   DoubleAltShortcuts,       KDE_Mover-Sizer.ini, Settings, DoubleAltShortcuts,  1        ; default: true
    IniWrite, %DoubleAltShortcuts%,      KDE_Mover-Sizer.ini, Settings, DoubleAltShortcuts
    IniRead,   BringWindowToFront,       KDE_Mover-Sizer.ini, Settings, BringWindowToFront,  0        ; default: false (true: automatically brings window to front on drag)
    IniWrite, %BringWindowToFront%,      KDE_Mover-Sizer.ini, Settings, BringWindowToFront
    IniRead,   ShowWindowWhenDragging,   KDE_Mover-Sizer.ini, Settings, ShowWindowWhenDragging,  1    ; default: true
    IniWrite, %ShowWindowWhenDragging%,  KDE_Mover-Sizer.ini, Settings, ShowWindowWhenDragging
    IniRead,   SnappingDistance,         KDE_Mover-Sizer.ini, Settings, SnappingDistance, 10          ; default: 10 pixels
    IniWrite, %SnappingDistance%,        KDE_Mover-Sizer.ini, Settings, SnappingDistance
    ; This is the setting that runs smoothest on my system. Depending on your video card and cpu power, 
    ; you may want to raise or lower this value.. System default: 100
    IniRead,   WinDelay,                KDE_Mover-Sizer.ini, Settings, WinDelay, 2
    IniWrite, %WinDelay%,               KDE_Mover-Sizer.ini, Settings, WinDelay

    IniRead,   DoubleModifierKey_MaxDelay_ms,      KDE_Mover-Sizer.ini, Settings, DoubleModifierKey_MaxDelay_ms, 400
    IniWrite, %DoubleModifierKey_MaxDelay_ms%,     KDE_Mover-Sizer.ini, Settings, DoubleModifierKey_MaxDelay_ms
    IniRead,   WindowIgnoreList,        KDE_Mover-Sizer.ini, Settings, WindowIgnoreList, %DefaultWindowIgnoreList%mstsc.exe,Citrix.DesktopViewer.App.exe,    ; Windows excluded for dragging (default: Windows Desktop tools)
    IniWrite, %WindowIgnoreList%,       KDE_Mover-Sizer.ini, Settings, WindowIgnoreList
    IniRead,   RunAsAdministrator,      KDE_Mover-Sizer.ini, Settings, RunAsAdministrator, 0           ; default: run as normal user
    IniWrite, %RunAsAdministrator%,     KDE_Mover-Sizer.ini, Settings, RunAsAdministrator
    IniRead,   HideTrayIcon,            KDE_Mover-Sizer.ini, Settings, HideTrayIcon, 0                 ; default is to show the icon
    IniWrite, %HideTrayIcon%,           KDE_Mover-Sizer.ini, Settings, HideTrayIcon

    ; Settings for hotkeys
    ;
    s := "Alt=!, Ctrl=^, Shift=+, LWin=#, AltGr=<^>!"
    IniWrite,  %s%, KDE_Mover-Sizer.ini, Hotkeys, Hints_Hotkeys                                        ; quick hotkey reference
    IniRead,   MovingWindow_Hotkey,     KDE_Mover-Sizer.ini, Hotkeys, MovingWindow_Hotkey, !           ; default: ! (Alt)
    IniWrite,'%MovingWindow_Hotkey%',   KDE_Mover-Sizer.ini, Hotkeys, MovingWindow_Hotkey
    IniRead,   MovingWindow_Mouse,      KDE_Mover-Sizer.ini, Hotkeys, MovingWindow_Mouse, LButton      ; default: LButton
    IniWrite, %MovingWindow_Mouse%,     KDE_Mover-Sizer.ini, Hotkeys, MovingWindow_Mouse

    IniRead,   ResizingWindow_Hotkey,   KDE_Mover-Sizer.ini, Hotkeys, ResizingWindow_Hotkey, !         ; default: ! (Alt)
    IniWrite,'%ResizingWindow_Hotkey%', KDE_Mover-Sizer.ini, Hotkeys, ResizingWindow_Hotkey
    IniRead,   ResizingWindow_Mouse,    KDE_Mover-Sizer.ini, Hotkeys, ResizingWindow_Mouse, RButton    ; default: RButton
    IniWrite, %ResizingWindow_Mouse%,   KDE_Mover-Sizer.ini, Hotkeys, ResizingWindow_Mouse

    IniRead,   ToggleMaximize_Hotkey,   KDE_Mover-Sizer.ini, Hotkeys, ToggleMaximize_Hotkey, !         ; default: ! (Alt)
    IniWrite,'%ToggleMaximize_Hotkey%', KDE_Mover-Sizer.ini, Hotkeys, ToggleMaximize_Hotkey
    IniRead,   ToggleMaximize_Mouse,    KDE_Mover-Sizer.ini, Hotkeys, ToggleMaximize_Mouse, MButton    ; default: MButton
    IniWrite, %ToggleMaximize_Mouse%,   KDE_Mover-Sizer.ini, Hotkeys, ToggleMaximize_Mouse

    IniRead,   DoubleKey_Hotkey2,       KDE_Mover-Sizer.ini, Hotkeys, DoubleKey_Hotkey2, Alt           ; default: Alt
    IniWrite, %DoubleKey_Hotkey2%,      KDE_Mover-Sizer.ini, Hotkeys, DoubleKey_Hotkey2
    IniRead,   QuickPosition_Hotkey2,   KDE_Mover-Sizer.ini, Hotkeys, QuickPosition_Hotkey2, Alt       ; default: Alt
    IniWrite, %QuickPosition_Hotkey2%,  KDE_Mover-Sizer.ini, Hotkeys, QuickPosition_Hotkey2
    IniRead,   LockHorizVert_Hotkey2,   KDE_Mover-Sizer.ini, Hotkeys, LockHorizVert_Hotkey2, Shift     ; default: Shift
    IniWrite, %LockHorizVert_Hotkey2%,  KDE_Mover-Sizer.ini, Hotkeys, LockHorizVert_Hotkey2
    IniRead,   WindowToFront_Hotkey2,   KDE_Mover-Sizer.ini, Hotkeys, WindowToFront_Hotkey2, Control   ; default: Control (during move/resize, activate window to bring to front)
    IniWrite, %WindowToFront_Hotkey2%,  KDE_Mover-Sizer.ini, Hotkeys, WindowToFront_Hotkey2

    IniRead,   DrawGridOverlay_Hotkey,  KDE_Mover-Sizer.ini, Hotkeys, DrawGridOverlay_Hotkey, !^       ; default: !^ (Ctrl+Alt)
    IniWrite,'%DrawGridOverlay_Hotkey%',KDE_Mover-Sizer.ini, Hotkeys, DrawGridOverlay_Hotkey
    IniRead,   DrawGridOverlay_Mouse,   KDE_Mover-Sizer.ini, Hotkeys, DrawGridOverlay_Mouse, RButton   ; default: RButton, also used as OK for Colour Sampler
    IniWrite, %DrawGridOverlay_Mouse%,  KDE_Mover-Sizer.ini, Hotkeys, DrawGridOverlay_Mouse
    IniRead,   FreezeSampler_Mouse,     KDE_Mover-Sizer.ini, Hotkeys, FreezeSampler_Mouse, LButton     ; default: LButton, pins location of Colour Sampler
    IniWrite, %FreezeSampler_Mouse%,    KDE_Mover-Sizer.ini, Hotkeys, FreezeSampler_Mouse
    
    IniRead,   DragScroll_Hotkey,       KDE_Mover-Sizer.ini, Hotkeys, DragScroll_Hotkey, %A_Space%     ; %A_Space%:none, *:all, ^:Ctrl, +:Shift, ...
    IniWrite,'%DragScroll_Hotkey%',     KDE_Mover-Sizer.ini, Hotkeys, DragScroll_Hotkey
    IniRead,   DragScroll_Mouse,        KDE_Mover-Sizer.ini, Hotkeys, DragScroll_Mouse, MButton        ; MButton, LControl, ...
    IniWrite, %DragScroll_Mouse%,       KDE_Mover-Sizer.ini, Hotkeys, DragScroll_Mouse
    IniRead,   DragScroll_HorizKey,     KDE_Mover-Sizer.ini, Hotkeys, DragScroll_HorizKey, LButton     ; key used during MButton vertical scroll to switch to horizontal scroll, default: Left Mouse Button
    IniWrite, %DragScroll_HorizKey%,    KDE_Mover-Sizer.ini, Hotkeys, DragScroll_HorizKey

    ; Settings for Draw Grid and colour sampler
    ;
    IniRead,   EnableDrawGrid,          KDE_Mover-Sizer.ini, Special, EnableDrawGrid, 0                ; default: disabled
    IniWrite, %EnableDrawGrid%,         KDE_Mover-Sizer.ini, Special, EnableDrawGrid
    IniRead,   DrawGridShowDistance,    KDE_Mover-Sizer.ini, Special, DrawGridShowDistance, 1          ; default: no info box
    IniWrite, %DrawGridShowDistance%,   KDE_Mover-Sizer.ini, Special, DrawGridShowDistance
    IniRead,   DrawGridColour,          KDE_Mover-Sizer.ini, Special, DrawGridColour, White            ; default: White
    IniWrite, %DrawGridColour%,         KDE_Mover-Sizer.ini, Special, DrawGridColour
    IniRead,   DrawGridGUIOptions,      KDE_Mover-Sizer.ini, Special, DrawGridGUIOptions, +Border      ; default: +Border
    IniWrite, %DrawGridGUIOptions%,     KDE_Mover-Sizer.ini, Special, DrawGridGUIOptions
    IniRead,   DrawGridMouseAutoHold,   KDE_Mover-Sizer.ini, Special, DrawGridMouseAutoHold, 1         ; default: true, release grid with another click
    IniWrite, %DrawGridMouseAutoHold%,  KDE_Mover-Sizer.ini, Special, DrawGridMouseAutoHold
    IniRead,   DrawGridWidth,           KDE_Mover-Sizer.ini, Special, DrawGridWidth, 1                 ; default: 1px, make bigger if no border
    IniWrite, %DrawGridWidth%,          KDE_Mover-Sizer.ini, Special, DrawGridWidth
    IniRead,   ShowMeasuresAsToolTip,   KDE_Mover-Sizer.ini, Special, ShowMeasuresAsToolTip, 1         ; default: true
    IniWrite, %ShowMeasuresAsToolTip%,  KDE_Mover-Sizer.ini, Special, ShowMeasuresAsToolTip
    IniRead,   ShowMeasuresToolTip_X,   KDE_Mover-Sizer.ini, Special, ShowMeasuresToolTip_X, 3         ; default: top-left
    IniWrite, %ShowMeasuresTooltip_X%,  KDE_Mover-Sizer.ini, Special, ShowMeasuresToolTip_X
    IniRead,   ShowMeasuresToolTip_Y,   KDE_Mover-Sizer.ini, Special, ShowMeasuresToolTip_Y, 3         ; default: top-left
    IniWrite, %ShowMeasuresTooltip_Y%,  KDE_Mover-Sizer.ini, Special, ShowMeasuresToolTip_Y

    ; Settings for (focusless) wheel scrolling
    ;
    IniRead,   EnableFocuslessScroll,   KDE_Mover-Sizer.ini, Special, EnableFocuslessScroll, %DefaultEnableFocuslessScroll%  ; default: disabled for >=Win10 (still helpful for old apps, such as Office 2010)
    IniWrite, %EnableFocuslessScroll%,  KDE_Mover-Sizer.ini, Special, EnableFocuslessScroll

    ; Settings for special mouse features (mouse button clicks and scrolling with holding middle button (use with pointing sticks))
    IniRead,   EnableDragScroll,        KDE_Mover-Sizer.ini, Special, EnableDragScroll, 1              ; default: enabled
    IniWrite, %EnableDragScroll%,       KDE_Mover-Sizer.ini, Special, EnableDragScroll

    IniRead,   DragScrollMinMousespeedForFastAccel,  KDE_Mover-Sizer.ini, Special, DragScrollMinMousespeedForFastAccel, 40  ; if mouse is moved fast (i.e. pixel distance is larger than this value), increase scroll step
    IniWrite, %DragScrollMinMousespeedForFastAccel%, KDE_Mover-Sizer.ini, Special, DragScrollMinMousespeedForFastAccel
    IniRead,   DragScrollFastAccelMultiplier,        KDE_Mover-Sizer.ini, Special, DragScrollFastAccelMultiplier, 2.3       ; for fast mouse movements, increase scroll step by this factor
    IniWrite, %DragScrollFastAccelMultiplier%,       KDE_Mover-Sizer.ini, Special, DragScrollFastAccelMultiplier
    IniRead,   DragScrollSpeedDivider,               KDE_Mover-Sizer.ini, Special, DragScrollSpeedDivider, 8                ; this many pixels are required for one full wheel scrollstep of 120
    IniWrite, %DragScrollSpeedDivider%,              KDE_Mover-Sizer.ini, Special, DragScrollSpeedDivider
    IniRead,   DragScrollMinUpdateInterval_us,       KDE_Mover-Sizer.ini, Special, DragScrollMinUpdateInterval_us, 5000     ; at maximum 1 wheel scroll event is send during this period (unit microseconds)
    IniWrite, %DragScrollMinUpdateInterval_us%,      KDE_Mover-Sizer.ini, Special, DragScrollMinUpdateInterval_us
    IniRead,   DragScrollIntervalDirectionChange_us, KDE_Mover-Sizer.ini, Special, DragScrollIntervalDirectionChange_us, 100000  ; allow change of horizontal/vertical movement only after this mouse-idle time (unit microseconds)
    IniWrite, %DragScrollIntervalDirectionChange_us%,KDE_Mover-Sizer.ini, Special, DragScrollIntervalDirectionChange_us
    IniRead,   DragScrollInvertScrollDirection,      KDE_Mover-Sizer.ini, Special, DragScrollInvertScrollDirection, 0       ; 0:scroll like dragging wheel, 1:scroll like dragging window content
    IniWrite, %DragScrollInvertScrollDirection%,     KDE_Mover-Sizer.ini, Special, DragScrollInvertScrollDirection
    
    IniRead,   DragScrollWindowIgnoreList,           KDE_Mover-Sizer.ini, Settings,DragScrollWindowIgnoreList, %A_Space%    ; apps that want MButton events instead Wheel events (e.g. when they have their own MButton Scroller)
    IniWrite, %DragScrollWindowIgnoreList%,          KDE_Mover-Sizer.ini, Settings,DragScrollWindowIgnoreList
    IniRead,   DragScrollFullScrollStepWindowList,   KDE_Mover-Sizer.ini, Settings,DragScrollFullScrollStepWindowList, notepad.exe,notepad++.exe,    ; apps which expect scroll steps in multiples of 120
    IniWrite, %DragScrollFullScrollStepWindowList%,  KDE_Mover-Sizer.ini, Settings,DragScrollFullScrollStepWindowList

    ; Mappings and status for key shortcuts to special characters
    ;
    IniRead,   EnableSpecialCharacters,  KDE_Mover-Sizer.ini, SpecialCharacters, EnableSpecialCharacters, 0          ; default: disabled
    IniWrite, %EnableSpecialCharacters%, KDE_Mover-Sizer.ini, SpecialCharacters, EnableSpecialCharacters
    IniRead,   SpecialCharactersTrig_1,  KDE_Mover-Sizer.ini, SpecialCharacters, SpecialCharactersTrig_1, <^>!c      ; default: AltGr+c
    IniWrite, %SpecialCharactersTrig_1%, KDE_Mover-Sizer.ini, SpecialCharacters, SpecialCharactersTrig_1
    IniRead,   SpecialCharactersChar_1,  KDE_Mover-Sizer.ini, SpecialCharacters, SpecialCharactersChar_1, ç
    IniWrite, %SpecialCharactersChar_1%, KDE_Mover-Sizer.ini, SpecialCharacters, SpecialCharactersChar_1
    IniRead,   SpecialCharactersTrig_2,  KDE_Mover-Sizer.ini, SpecialCharacters, SpecialCharactersTrig_2, <^>!+c     ; default: AltGr+C
    IniWrite, %SpecialCharactersTrig_2%, KDE_Mover-Sizer.ini, SpecialCharacters, SpecialCharactersTrig_2
    IniRead,   SpecialCharactersChar_2,  KDE_Mover-Sizer.ini, SpecialCharacters, SpecialCharactersChar_2, Ç
    IniWrite, %SpecialCharactersChar_2%, KDE_Mover-Sizer.ini, SpecialCharacters, SpecialCharactersChar_2
    
    ; enable(=1)/disable(=0) a special feature. If they are disabled here, they are also hidden in the AddOn menu.
    ;
    s := "If the AddOns are disabled here, they are not shown in the Special Features menu."
    IniWrite,  %s%, KDE_Mover-Sizer.ini, AddOns, Hints_AddOns
    IniRead,   AddOnEnable_SpecialCharacters,  KDE_Mover-Sizer.ini, AddOns, AddOnEnable_SpecialCharacters, 0
    IniWrite, %AddOnEnable_SpecialCharacters%, KDE_Mover-Sizer.ini, AddOns, AddOnEnable_SpecialCharacters
    IniRead,   AddOnEnable_ColourSampler,      KDE_Mover-Sizer.ini, AddOns, AddOnEnable_ColourSampler, 0
    IniWrite, %AddOnEnable_ColourSampler%,     KDE_Mover-Sizer.ini, AddOns, AddOnEnable_ColourSampler
    IniRead,   AddOnEnable_DrawGrid,           KDE_Mover-Sizer.ini, AddOns, AddOnEnable_DrawGrid, 0
    IniWrite, %AddOnEnable_DrawGrid%,          KDE_Mover-Sizer.ini, AddOns, AddOnEnable_DrawGrid

    ; Check if INI file was written successfully
    If NOT FileExist("KDE_Mover-Sizer.ini")
    {
        MsgBox, % MSGICON_EXCLAMATION, Config file not found, % "Could not create " A_WorkingDir
        . "\KDE_Mover-Sizer.ini.`n`nTry to start KDE Mover-Size from a directory with write permissions.`n`n"
        . "Otherwise, most features and settings will remain in default state`n`n"
        . "and cannot be enabled or changed."
    }
    return

; ***************************************************************
; ********* INIT: Install MOUSE & KEY EVENT handler *************
; ***************************************************************
;
; Set hotkeys for event handlers dynamically
; Details on http://www.autohotkey.com/docs/Hotkeys.htm
;     and on http://www.autohotkey.com/docs/commands/Hotkey.htm
;
InitHotkeyHandler:

    ; Init Catch hotkeys, used to hinder windows to pass them to underlying window
    Hotkey, !Escape, DoNothing, On
    Hotkey, Escape, DoNothing, On
    DisableEscapeHotkey()

    ; DoubleAlt requires special handling for AltGr (a different KeyWait in OnDoubleKey)
    if DoubleKey_Hotkey2 = AltGr
    {
        DoubleKey_isAltGr := 1
        DoubleKey_Hotkey2 := "LControl & ~RAlt"
    }

    ; Init actual Mover-Sizer hotkeys, exlude windows from static ignore list, e.g. Alt+Tab switcher
    Hotkey,IfWinNotActive, ahk_group IgnoreActiveWindowsList
        Hotkey, %MovingWindow_Hotkey%%MovingWindow_Mouse%, DoMovingWindowMinimize, On
        Hotkey, %ResizingWindow_Hotkey%%ResizingWindow_Mouse%, DoResizingWindowMaximize, On
        Hotkey, %ToggleMaximize_Hotkey%%ToggleMaximize_Mouse%, DoToggleMaximize, On
        Hotkey, %ToggleMaximize_Hotkey%%ToggleMaximize_Mouse% Up, DoToggleMaximize_Up, On
        if EnableFocuslessScroll
        {
            Hotkey, WheelUp,   DoFocuslessScrollUp, On
            HotKey, WheelDown, DoFocuslessScrollDown, On
        }
    Hotkey, IfWinNotActive

    Gosub, OnDoubleKey_Enable

    if (AddOnEnable_DrawGrid = 1 AND EnableDrawGrid = 1)
        Hotkey, %DrawGridOverlay_Hotkey%%DrawGridOverlay_Mouse%, DoDrawGridOverlay, On

    ; Set Special Characters hotkey handler
    if (AddOnEnable_SpecialCharacters = 1 AND EnableSpecialCharacters = 1)
    {
        SpecialCharacters_NumberOfActiveHotkeys := 0
        Loop, 100 {
            IniRead, SpecialCharactersTrig_%A_Index%,  KDE_Mover-Sizer.ini, SpecialCharacters, SpecialCharactersTrig_%A_Index%, %A_Space%
            IniRead, SpecialCharactersChar_%A_Index%,  KDE_Mover-Sizer.ini, SpecialCharacters, SpecialCharactersChar_%A_Index%, %A_Space%
            key := SpecialCharactersTrig_%A_Index%
            if !key
                break
            SpecialCharacters_NumberOfActiveHotkeys++
            Hotkey, %key%, SpecialCharactersLbl, On
        }
    }
    
    if EnableDragScroll
    {
        ; Prepare callback address for MiddleButton Scroll
        DragScrollMouseHookAddr := RegisterCallback("DragScrollMouseHook")

        Hotkey, %DragScroll_Hotkey%%DragScroll_Mouse%, DoDragScroll, On
        Hotkey, %DragScroll_Hotkey%%DragScroll_Mouse% Up, DoDragScrollUp, On
    }
    return

;*********************************************
;******** INIT: Prepare Menu *****************
;*********************************************
PrepareMenu:
    ; If compiled, hide standard menu options
    If A_IsCompiled
        Menu, tray, NoStandard

    ; Useful info on tray mouse hover.. ;o)
    Menu, Tray,Tip, % "KDE Mover-Sizer.. `n" . strname(MovingWindow_Hotkey) . "-" . strname(MovingWindow_Mouse) . "-Click Windows to Move`n"
                      . strname(ResizingWindow_Hotkey) . "-" . strname(ResizingWindow_Mouse) . "-Click Windows to Resize`n[right-click here for a menu]"

    ; Create Special menu
    ;
    Menu, MySpecialMenu, add, Toggle Window-Always-On-Top.., MenuToggleAlwaysOnTop
    Menu, MySpecialMenu, add

    if AddOnEnable_SpecialCharacters {
        Menu, MySpecialMenu, add, Enable Hotkeys to insert Special Characters, MenuEnableSpecialCharacters
        Menu, MySpecialMenu, add
    }
    
    ; Create options menu for DragScrolling
    Menu, MySpecialMenuDragScrolling, add, Invert Scroll Direction, MenuDragScrollInvertScrollDirection
    Menu, MySpecialMenuDragScrolling, add
    Menu, MySpecialMenuDragScrolling, add, Add Window to Drag Scroll Ignore list..,      MenuAddWindowToDragScrollWindowIgnoreList
    Menu, MySpecialMenuDragScrolling, add, Remove Window from Drag Scroll Ignore list.., MenuRemoveWindowFromDragScrollWindowIgnoreList
    Menu, MySpecialMenuDragScrolling, add
    Menu, MySpecialMenuDragScrolling, add, Add Window to Full Step Scroll list..,      MenuAddWindowToDragScrollFullScrollStepWindowList
    Menu, MySpecialMenuDragScrolling, add, Remove Window from Full Step Scroll list.., MenuRemoveWindowFromDragScrollFullScrollStepWindowList
    Menu, MySpecialMenuDragScrolling, add
    Menu, MySpecialMenuDragScrolling, add, Show Drag Scroll Window Lists, MenuShowDragScrollWindowLists

    Menu, MySpecialMenu, add, Enable Wheel Scrolling on inactive Windows, MenuEnableFocuslessScroll
    Menu, MySpecialMenu, add
    Menu, MySpecialMenu, add, Enable Drag Scrolling by holding Mouse Button, MenuEnableDragScroll
    Menu, MySpecialMenu, add, Options for Drag Scrolling.., :MySpecialMenuDragScrolling

    if ( (AddOnEnable_SpecialCharacters) AND ( AddOnEnable_DrawGrid OR AddOnEnable_ColourSampler ) )
        Menu, MySpecialMenu, add

    if AddOnEnable_ColourSampler {
        Menu, MySpecialMenu, add, Colour sampler.., MenuColourSampler
        Menu, MySpecialMenu, add
    }
    if AddOnEnable_DrawGrid {
        Menu, MySpecialMenu, add, Enable Draw grid, MenuDrawGrid
        Menu, MySpecialMenu, add, Auto-hold grid, MenuDrawGridMouseAutoHold
        Menu, MySpecialMenu, add, Show Grid Measures, MenuDrawGridShowDistance
        Menu, MySpecialMenu, add
    }
    if (AddOnEnable_ColourSampler = 1 OR AddOnEnable_DrawGrid = 1)
        Menu, MySpecialMenu, add, Show Measures as ToolTip, MenuShowMeasuresAsToolTip

    ; Create Options-, Ignore- and Hotkey Menu
    ;
    Menu, MyOptionsMenu, add, Snap on Move, MenuSnapOnMoveHandler
    Menu, MyOptionsMenu, add, Snap on Resize, MenuSnapOnSizeHandler
    Menu, MyOptionsMenu, add, Borderless snapping, MenuBorderlessSnappingAndDPI
    Menu, MyOptionsMenu, add
    Menu, MyOptionsMenu, add, Magnetic Resizing, MenuSnapOnResizeMagnetic
    Menu, MyOptionsMenu, add, Resize restores Maximized Window, MenuDoRestoreOnResize
    Menu, MyOptionsMenu, add, Use 3x3 grid for Resize direction, MenuUse3x3ResizeGrid
    Menu, MyOptionsMenu, add
    Menu, MyOptionsMenu, add, Bring Windows to Front on dragging, MenuBringWindowToFront
    Menu, MyOptionsMenu, add, Show Window Contents while dragging, MenuShowWindowWhenDragging
    Menu, MyIgnoreMenu, add, Add Window to Ignore List.., MenuAddWindowToWindowIgnoreList
    Menu, MyIgnoreMenu, add, Remove Window from Ignore List.., MenuRemoveWindowFromWindowIgnoreList
    Menu, MyIgnoreMenu, add
    Menu, MyIgnoreMenu, add, Show currently ignored Windows, MenuShowIgnoreList
    Menu, MyHotkeyMenu, add, Reset all Hotkeys to Default, MenuHotkey_Default
    Menu, MyHotkeyMenu, add
    Menu, MyHotkeyMenu, add, Swap Left<->Right Mouse buttons, MenuHotkey_MouseSwap
    Menu, MyHotkeyMenu, add
    Menu, MyHotkeyMenu, add, Use Alt as key, MenuHotkey_Alt
    Menu, MyHotkeyMenu, add, Use Control+Shift as key, MenuHotkey_ControlShift
    Menu, MyHotkeyMenu, add, Use Control+Alt as key, MenuHotkey_ControlAlt
    Menu, MyHotkeyMenu, add, Use Left Windows as key, MenuHotkey_LWin
    Menu, MyHotkeyMenu, add, Use AltGr as key, MenuHotkey_AltGr
    Menu, MyHotkeyMenu, add, Use Middle Mouse Button as key, MenuHotkey_MButton
    Menu, MyHotkeyMenu, add
    Menu, MyHotkeyMenu, add, Use Extra Mouse Buttons 4+5 without key, MenuHotkey_XButtons
    Menu, MyHotkeyMenu, add, Use Ctrl/Win with Space key, MenuHotkey_Space

    ; Create main tray menu
    ;
    Menu, tray, add, About.., MenuAbout
    Menu, tray, add
    Menu, tray, add, Enable Double-Alt Shortcuts, MenuDoubleAltShortcuts
    Menu, tray, add, Options, :MyOptionsMenu
    Menu, tray, add
    Menu, tray, add, Ignore Windows, :MyIgnoreMenu
    Menu, tray, add, Change Hotkeys, :MyHotkeyMenu
    Menu, tray, add
    Menu, tray, add, Special Features, :MySpecialMenu
    Menu, tray, add
    Menu, tray, add, Edit My Ini File, MenuEditMyIni
    Menu, tray, add, Enable HotKeys, MenuHotKeysToggle
    Menu, tray, add, Run as administrator, MenuRunAsAdmin
    Menu, tray, add, Automatically run on startup, MenuStartupShortcut
    Menu, tray, add
    Menu, tray, add, Hide Tray Icon, MenuHideIcon
    Menu, tray, add
    Menu, tray, add, Exit, MenuExit

    ; Set initial "enable" Checks in menu according to configuration variables
    ;
    if AddOnEnable_DrawGrid
    {
        if EnableDrawGrid
            Menu, MySpecialMenu, Check, Enable Draw grid
        if DrawGridMouseAutoHold
            Menu, MySpecialMenu, Check, Auto-hold grid
        if DrawGridShowDistance
            Menu, MySpecialMenu, Check, Show Grid Measures
    }
    if (AddOnEnable_DrawGrid = 1 OR AddOnEnable_ColourSampler = 1)
        if ShowMeasuresAsToolTip
            Menu, MySpecialMenu, Check, Show Measures as ToolTip

    if AddOnEnable_SpecialCharacters
        if EnableSpecialCharacters
            Menu, MySpecialMenu, Check, Enable Hotkeys to insert Special Characters

    if EnableFocuslessScroll
        Menu, MySpecialMenu, Check, Enable Wheel Scrolling on inactive Windows

    if EnableDragScroll
        Menu, MySpecialMenu, Check, Enable Drag Scrolling by holding Mouse Button

    if DragScrollInvertScrollDirection
        Menu, MySpecialMenuDragScrolling, Check, Invert Scroll Direction

    Menu, tray, Check, Enable HotKeys
    
    if SnapOnMoveEnabled
        Menu, MyOptionsMenu, Check, Snap on Move
    if SnapOnSizeEnabled
        Menu, MyOptionsMenu, Check, Snap on Resize
    if BorderlessSnappingAndDPI
        Menu, MyOptionsMenu, Check, Borderless snapping
    if BringWindowToFront
        Menu, MyOptionsMenu, Check, Bring Windows to Front on dragging
    if ShowWindowWhenDragging
        Menu, MyOptionsMenu, Check, Show Window Contents while dragging
    if SnapOnResizeMagnetic
        Menu, MyOptionsMenu, Check, Magnetic Resizing
    if DoRestoreOnResize
        Menu, MyOptionsMenu, Check, Resize restores Maximized Window
    if DoubleAltShortcuts
        Menu, tray, Check, Enable Double-Alt Shortcuts
    if Use3x3ResizeGrid
        Menu, MyOptionsMenu, Check, Use 3x3 grid for Resize direction
    
    if A_IsAdmin
    {
        Menu, tray, Check, Run as administrator
        RunAsAdministrator := 1
    }

    if FileExist(startupLinkFile)
        Menu, tray, Check, Automatically run on startup

    ; look for .ico in script directory and use it if found
    if ( A_IsCompiled = "" )
    {
        SplitPath, A_ScriptFullPath, , dir,, name_no_ext
        KMSIconFile := dir "\" name_no_ext ".ico"
        if FileExist(KMSIconFile)
            Menu, Tray, Icon, %KMSIconFile%
    }
    if HideTrayIcon
        Menu,Tray,NoIcon

    return


; **************************************
; ********* MENU handler ***************
; **************************************

; *** MENU: Configure Moving & Resizing ***
;
MenuSnapOnMoveHandler:
    Menu, MyOptionsMenu, ToggleCheck, Snap on Move
    SnapOnMoveEnabled := NOT SnapOnMoveEnabled
    ; save option to INI file in working directory
    IniWrite, %SnapOnMoveEnabled%, KDE_Mover-Sizer.ini, Settings, SnapOnMoveEnabled
    return

MenuSnapOnSizeHandler:
    Menu, MyOptionsMenu, ToggleCheck, Snap on Resize
    SnapOnSizeEnabled := NOT SnapOnSizeEnabled
    IniWrite, %SnapOnSizeEnabled%, KDE_Mover-Sizer.ini, Settings, SnapOnSizeEnabled
    if (SnapOnSizeEnabled = 0 AND SnapOnResizeMagnetic = 1)
        Gosub, MenuSnapOnResizeMagnetic
    return

MenuBorderlessSnappingAndDPI:
    if (BorderlessSnappingAndDPI = 0 && (SubStr(A_OSVersion,1,3) = "WIN" || A_OSVersion < "10.0.14393"))
    {
        MsgBox, 0x30, Windows version too old!, % "DPI-aware Borderless snapping is not supported for Windows 10 Builds earlier than 14393 (v1607)"
        return
    }
    Menu, MyOptionsMenu, ToggleCheck, Borderless snapping
    BorderlessSnappingAndDPI := NOT BorderlessSnappingAndDPI
    IniWrite, %BorderlessSnappingAndDPI%, KDE_Mover-Sizer.ini, Settings, BorderlessSnappingAndDPI
    Reload
    return

MenuDoubleAltShortcuts:
    Menu, tray, ToggleCheck, Enable Double-Alt Shortcuts
    DoubleAltShortcuts := NOT DoubleAltShortcuts
    IniWrite, %DoubleAltShortcuts%, KDE_Mover-Sizer.ini, Settings, DoubleAltShortcuts
    Reload
    return

MenuBringWindowToFront:
    Menu, MyOptionsMenu, ToggleCheck, Bring Windows to Front on dragging
    BringWindowToFront := NOT BringWindowToFront
    If BringWindowToFront
        Traytip, Bring Window to Front enabled, Automatically brings up window to foreground on Resizing and Moving.,20,%TRAYICON_NOSOUND%
    Else
        Traytip, Bring Window to Front disabled, Press %WindowToFront_Hotkey2% to bring window to foreground during Moving or Resizing,20
    IniWrite, %BringWindowToFront%, KDE_Mover-Sizer.ini, Settings, BringWindowToFront
    return

MenuShowWindowWhenDragging:
    Menu, MyOptionsMenu, ToggleCheck, Show Window Contents while dragging
    ShowWindowWhenDragging := NOT ShowWindowWhenDragging
    If ShowWindowWhenDragging
        Traytip, Show window contents while moving or resizing, When Enabled`, the window is immediately being moved or resized while dragging,20,%TRAYICON_NOSOUND%
    Else
        Traytip, Show frame while moving or resizing, When Disabled`, only a frame around window is shown to reduce UI redrawing on slow or remote machines.,20,%TRAYICON_NOSOUND%
    IniWrite, %ShowWindowWhenDragging%, KDE_Mover-Sizer.ini, Settings, ShowWindowWhenDragging
    return

MenuSnapOnResizeMagnetic:
    Menu, MyOptionsMenu, ToggleCheck, Magnetic Resizing
    SnapOnResizeMagnetic := NOT SnapOnResizeMagnetic
    If SnapOnResizeMagnetic
        Traytip, Magnetic Resizing, Allows to keep the window snapped when resizing slowly`. Resize a window to screen border until it snaps`, then drag it slowly to see how it works`.,20,%TRAYICON_NOSOUND%
    IniWrite, %SnapOnResizeMagnetic%, KDE_Mover-Sizer.ini, Settings, SnapOnResizeMagnetic
    if (SnapOnResizeMagnetic = 1 AND SnapOnSizeEnabled = 0)
        Gosub, MenuSnapOnSizeHandler
    return

MenuDoRestoreOnResize:
    Menu, MyOptionsMenu, ToggleCheck, Resize restores Maximized Window
    DoRestoreOnResize := NOT DoRestoreOnResize
    Traytip, Resize restores Maximized Window, % "When enabled, a maximized window is restored to its original size before resizing.`r`nWhen disabled, a maximized window starts resizing from the maximized width and height.`r`nYou'll only notice the difference when you resize a maximized window.", 20,%TRAYICON_NOSOUND%
    IniWrite, %DoRestoreOnResize%, KDE_Mover-Sizer.ini, Settings, DoRestoreOnResize
    return

MenuUse3x3ResizeGrid:
    Menu, MyOptionsMenu, ToggleCheck, Use 3x3 grid for Resize direction
    Use3x3ResizeGrid := NOT Use3x3ResizeGrid
    If Use3x3ResizeGrid
        Traytip, Use 3x3 grid for Resize direction, Window is divided into 9 areas`. If the mouse is not on the corner fields`, direction of resizing is restricted`.,20,%TRAYICON_NOSOUND%
    else
        Traytip, Use 2x2 grid for Resize direction, % "Window is divided into 4 areas.`nDirection of resizing can be restricted with " . strname(LockHorizVert_Hotkey2) . ".",20,%TRAYICON_NOSOUND%
    IniWrite, %Use3x3ResizeGrid%, KDE_Mover-Sizer.ini, Settings, Use3x3ResizeGrid
    return


; *** MENU: Edit Windows Ignore List ***
;
MenuAddWindowToWindowIgnoreList:
MenuAddWindowToDragScrollWindowIgnoreList:
MenuAddWindowToDragScrollFullScrollStepWindowList:
    listName := SubStr(A_ThisLabel, StrLen("MenuAddWindowTo")+1)
    if (listName = "WindowIgnoreList")
        Traytip, Add window to Ignore list, % "Left-Click the window you want to restore the original application-specific hotkey behaviour. "
                 . "Alternatively, try using hotkey together with another modifier key, such as Win or AltGr`.", 20,%TRAYICON_NOSOUND%

    if (listName = "DragScrollWindowIgnoreList")
        Traytip, Add window to Drag Scrolling Ignore list, % "Left-Click the window you want to exclude from drag scrolling and get the original button instead of wheel up/down.`r`n", 20,%TRAYICON_NOSOUND%

    if (listName = "DragScrollFullScrollStepWindowList")
        Traytip, Add window to Full Step Scrolling list, % "Left-Click the window if each first Wheel Up/Down action is ignored after using drag scrolling.`r`nRemember to restart the selected application to reset any existing scroll offsets.", 20,%TRAYICON_NOSOUND%

    SetMouseCursorCross()
    KeyWait, LButton, D            ; Wait for left button to be pressed down
    SetMouseCursorDefault()
    
    if (CheckIsWindowInList(%listName%, WindowMatchStr))
    {
        if (listName = "DragScrollFullScrollStepWindowList")
            MsgBox,48, Add window to list, % "Application is already on list.`r`nRestart it to reset any wheel scroll offsets."
        else
            MsgBox,48, Add window to list, Application is already on list
        return
    }
    WindowList := %listName% . WindowMatchStr
    IniWrite, %WindowList%,   KDE_Mover-Sizer.ini, Settings, %listName%
    Traytip, Add window to list, Applications now on list:`r`n %WindowList%, 20,%TRAYICON_NOSOUND%
    Sleep,100
    Reload
    return

MenuRemoveWindowFromWindowIgnoreList:
MenuRemoveWindowFromDragScrollWindowIgnoreList:
MenuRemoveWindowFromDragScrollFullScrollStepWindowList:
    listName := SubStr(A_ThisLabel, StrLen("MenuRemoveWindowFrom")+1)

    if (listName = "WindowIgnoreList")
        Traytip, Remove window from Ignore list, Left-Click the window which you want to control again with KDE Mover-Sizer`r`n, 20,%TRAYICON_NOSOUND%

    if (listName = "DragScrollWindowIgnoreList")
        Traytip, Remove window from Drag Scrolling Ignore list, % "Left-Click the window you want to scroll with " . strname(DragScroll_Mouse) . " Mouse Button`.`r`n", 20,%TRAYICON_NOSOUND%

    if (listName = "DragScrollFullScrollStepWindowList")
        Traytip, Remove window from Full Step Scrolling list, % "Left-Click the window to allow smaller scroller steps during Drag Scrolling`.`r`n", 20,%TRAYICON_NOSOUND%

    SetMouseCursorCross()
    KeyWait, LButton, D            ; Wait for left button to be pressed down
    SetMouseCursorDefault()

    if (CheckIsWindowInList(%listName%, WindowMatchStr))
    {
        WindowList := %listName%
        StringReplace, WindowList, WindowList, %WindowMatchStr%
        IniWrite, %WindowList%,   KDE_Mover-Sizer.ini, Settings, %listName%
        Traytip, Remove window from list, Application removed from list:`r`n%WindowMatchStr%, 20,%TRAYICON_NOSOUND%
        Sleep,100
    } else
        MsgBox,48, Remove window from list, % "Could not remove from list:`r`n" . WindowMatchStr . "`r`n`r`nApplications now on list:`r`n" . %listName%
    Reload
    return

MenuShowIgnoreList:
    MsgBox 64, KDE Mover-Sizer Ignore Windows, Applications currently on Ignore Window list for dragging:`r`n%WindowIgnoreList%
    return

MenuDragScrollInvertScrollDirection:
    Menu, MySpecialMenuDragScrolling, ToggleCheck, Invert Scroll Direction
    DragScrollInvertScrollDirection := NOT DragScrollInvertScrollDirection
    IniWrite, %DragScrollInvertScrollDirection%, KDE_Mover-Sizer.ini, Special, DragScrollInvertScrollDirection
    return

MenuShowDragScrollWindowLists:
    MsgBox 64, Drag Scrolling, % "Applications not controlled by Mouse Button Drag Scroll:`r`n" . DragScrollWindowIgnoreList . "`r`n`r`nApplications getting complete scroll steps (use this if first wheel event is skipped):`r`n" . DragScrollFullScrollStepWindowList
    return
    
; *** MENU: Change Hotkey settings
;
MenuHotkey_Default:
    IniWrite, !,       KDE_Mover-Sizer.ini, Hotkeys, MovingWindow_Hotkey
    IniWrite, LButton, KDE_Mover-Sizer.ini, Hotkeys, MovingWindow_Mouse
    IniWrite, !,       KDE_Mover-Sizer.ini, Hotkeys, ResizingWindow_Hotkey
    IniWrite, RButton, KDE_Mover-Sizer.ini, Hotkeys, ResizingWindow_Mouse
    IniWrite, !,       KDE_Mover-Sizer.ini, Hotkeys, ToggleMaximize_Hotkey
    IniWrite, MButton, KDE_Mover-Sizer.ini, Hotkeys, ToggleMaximize_Mouse
    IniWrite, Alt,     KDE_Mover-Sizer.ini, Hotkeys, DoubleKey_Hotkey2
    IniWrite, Alt,     KDE_Mover-Sizer.ini, Hotkeys, QuickPosition_Hotkey2
    IniWrite, Shift,   KDE_Mover-Sizer.ini, Hotkeys, LockHorizVert_Hotkey2
    IniWrite, !^,      KDE_Mover-Sizer.ini, Hotkeys, DrawGridOverlay_Hotkey
    IniWrite, RButton, KDE_Mover-Sizer.ini, Hotkeys, DrawGridOverlay_Mouse
    IniWrite, LButton, KDE_Mover-Sizer.ini, Hotkeys, FreezeSampler_Mouse
    IniWrite, Control, KDE_Mover-Sizer.ini, Hotkeys, WindowToFront_Hotkey2
    IniWrite, '',      KDE_Mover-Sizer.ini, Hotkeys, DragScroll_Hotkey
    IniWrite, MButton, KDE_Mover-Sizer.ini, Hotkeys, DragScroll_Mouse
    IniWrite, LButton, KDE_Mover-Sizer.ini, Hotkeys, DragScroll_HorizKey
    Reload
    return

MenuHotkey_MouseSwap:
    IniWrite, %ResizingWindow_Mouse%,  KDE_Mover-Sizer.ini, Hotkeys, MovingWindow_Mouse
    IniWrite, %MovingWindow_Mouse%,    KDE_Mover-Sizer.ini, Hotkeys, ResizingWindow_Mouse
    IniWrite, %FreezeSampler_Mouse%,   KDE_Mover-Sizer.ini, Hotkeys, DrawGridOverlay_Mouse
    IniWrite, %DrawGridOverlay_Mouse%, KDE_Mover-Sizer.ini, Hotkeys, FreezeSampler_Mouse
    Reload
    return

MenuHotkey_Alt:
    IniWrite, !,        KDE_Mover-Sizer.ini, Hotkeys, MovingWindow_Hotkey
    IniWrite, !,        KDE_Mover-Sizer.ini, Hotkeys, ResizingWindow_Hotkey
    IniWrite, !,        KDE_Mover-Sizer.ini, Hotkeys, ToggleMaximize_Hotkey
    IniWrite, !^,       KDE_Mover-Sizer.ini, Hotkeys, DrawGridOverlay_Hotkey
    IniWrite, Alt,      KDE_Mover-Sizer.ini, Hotkeys, DoubleKey_Hotkey2
    IniWrite, Alt,      KDE_Mover-Sizer.ini, Hotkeys, QuickPosition_Hotkey2
    Reload
    return

MenuHotkey_ControlShift:
    IniWrite, ^+,       KDE_Mover-Sizer.ini, Hotkeys, MovingWindow_Hotkey
    IniWrite, ^+,       KDE_Mover-Sizer.ini, Hotkeys, ResizingWindow_Hotkey
    IniWrite, ^+,       KDE_Mover-Sizer.ini, Hotkeys, ToggleMaximize_Hotkey
    IniWrite, !^+,      KDE_Mover-Sizer.ini, Hotkeys, DrawGridOverlay_Hotkey
    IniWrite, LControl, KDE_Mover-Sizer.ini, Hotkeys, DoubleKey_Hotkey2
    IniWrite, Control,  KDE_Mover-Sizer.ini, Hotkeys, QuickPosition_Hotkey2
    Reload
    return

MenuHotkey_ControlAlt:
    IniWrite, ^!,       KDE_Mover-Sizer.ini, Hotkeys, MovingWindow_Hotkey
    IniWrite, ^!,       KDE_Mover-Sizer.ini, Hotkeys, ResizingWindow_Hotkey
    IniWrite, ^!,       KDE_Mover-Sizer.ini, Hotkeys, ToggleMaximize_Hotkey
    IniWrite, ^!+,      KDE_Mover-Sizer.ini, Hotkeys, DrawGridOverlay_Hotkey
    IniWrite, LControl, KDE_Mover-Sizer.ini, Hotkeys, DoubleKey_Hotkey2
    IniWrite, Alt,      KDE_Mover-Sizer.ini, Hotkeys, QuickPosition_Hotkey2
    Reload
    return

MenuHotkey_LWin:
    IniWrite, #,        KDE_Mover-Sizer.ini, Hotkeys, MovingWindow_Hotkey
    IniWrite, #,        KDE_Mover-Sizer.ini, Hotkeys, ResizingWindow_Hotkey
    IniWrite, #,        KDE_Mover-Sizer.ini, Hotkeys, ToggleMaximize_Hotkey
    IniWrite, ^#,       KDE_Mover-Sizer.ini, Hotkeys, DrawGridOverlay_Hotkey
    IniWrite, LWin,     KDE_Mover-Sizer.ini, Hotkeys, DoubleKey_Hotkey2
    IniWrite, LWin,     KDE_Mover-Sizer.ini, Hotkeys, QuickPosition_Hotkey2
    Reload
    return

MenuHotkey_AltGr:
    IniWrite, <^>!,     KDE_Mover-Sizer.ini, Hotkeys, MovingWindow_Hotkey
    IniWrite, <^>!,     KDE_Mover-Sizer.ini, Hotkeys, ResizingWindow_Hotkey
    IniWrite, <^>!,     KDE_Mover-Sizer.ini, Hotkeys, ToggleMaximize_Hotkey
    IniWrite, <^>!+,    KDE_Mover-Sizer.ini, Hotkeys, DrawGridOverlay_Hotkey
    IniWrite, AltGr,    KDE_Mover-Sizer.ini, Hotkeys, DoubleKey_Hotkey2
    IniWrite, RAlt,     KDE_Mover-Sizer.ini, Hotkeys, QuickPosition_Hotkey2           ; Use RAlt. "Alt" triggers SendEvent LControl (used for Alt-Hotkey), which blocks Menu
    Reload
    return

; These are somewhat experimental and not thoroughly tested. Some additional/special features may not work as expected
MenuHotkey_MButton:
    IniWrite, 'MButton & ', KDE_Mover-Sizer.ini, Hotkeys, MovingWindow_Hotkey
    IniWrite, 'MButton & ', KDE_Mover-Sizer.ini, Hotkeys, ResizingWindow_Hotkey
    IniWrite, 0,        KDE_Mover-Sizer.ini, Settings, DoubleAltShortcuts
    IniWrite, 0,        KDE_Mover-Sizer.ini, Special, EnableDragScroll
    IniWrite, MButton,  KDE_Mover-Sizer.ini, Hotkeys, QuickPosition_Hotkey2
    Traytip, EXPERIMENTAL! Middle Mouse button hotkey, Hold the middle mouse button and drag window with left and right button. NOTE: Double-Hotkeys and MButton Scrolling are not supported in this configuration! Also not heavily tested,15,%TRAYICON_NOSOUND%
    Reload
    return

MenuHotkey_XButtons:
    IniWrite, %A_Space%,KDE_Mover-Sizer.ini, Hotkeys, MovingWindow_Hotkey
    IniWrite, %A_Space%,KDE_Mover-Sizer.ini, Hotkeys, ResizingWindow_Hotkey
    IniWrite, XButton1, KDE_Mover-Sizer.ini, Hotkeys, MovingWindow_Mouse
    IniWrite, XButton2, KDE_Mover-Sizer.ini, Hotkeys, ResizingWindow_Mouse
    IniWrite, XButton2, KDE_Mover-Sizer.ini, Hotkeys, DrawGridOverlay_Mouse
    IniWrite, XButton1, KDE_Mover-Sizer.ini, Hotkeys, FreezeSampler_Mouse
    Traytip, Extra Mouse buttons hotkey, % "Hold extra mouse button (XButton1&2) for move/resize NOTE: Double-Hotkeys may not work as expected!.",15,%TRAYICON_NOSOUND%
    MsgBox, % MSGICON_INFO, Extra Mouse buttons hotkey, % "Hold extra mouse button (XButton1&2) for move/resize.`r`nNo additional modifier key is set by default.`r`n`r`n"
      . "NOTE: Double-Hotkey works differently here if there is no modifier defined :`r`n"
      . "In this configuration, the Double-Hotkey must be released before clicking mouse button for Double-Hotkey action"
    Reload
    return
MenuHotkey_Space:
    IniWrite, #,        KDE_Mover-Sizer.ini, Hotkeys, MovingWindow_Hotkey
    IniWrite, Space,    KDE_Mover-Sizer.ini, Hotkeys, MovingWindow_Mouse
    IniWrite, ^#,       KDE_Mover-Sizer.ini, Hotkeys, ResizingWindow_Hotkey
    IniWrite, Space,    KDE_Mover-Sizer.ini, Hotkeys, ResizingWindow_Mouse
    IniWrite, ^#!,      KDE_Mover-Sizer.ini, Hotkeys, ToggleMaximize_Hotkey
    IniWrite, Space,    KDE_Mover-Sizer.ini, Hotkeys, ToggleMaximize_Mouse
    IniWrite, 0,        KDE_Mover-Sizer.ini, Settings, DoubleAltShortcuts
    IniWrite, 0,        KDE_Mover-Sizer.ini, Special, EnableDragScroll
    IniWrite, LWin,     KDE_Mover-Sizer.ini, Hotkeys, QuickPosition_Hotkey2
    Traytip, Space hotkey, Hold Win(move) or Ctrl+Win(resize) and drag by pressing Space key. NOTE: Double-Hotkeys are not supported in this configuration!,15,%TRAYICON_NOSOUND%
    Reload
    return

; *** MENU: Special features ***
;
MenuToggleAlwaysOnTop:
    SetMouseCursorCross()
    Traytip, Toggle Always-on-Top, Left-Click the window you want to keep in the foreground. Redo to restore normal behaviour.,15,,%TRAYICON_NOSOUND%
    KeyWait, LButton, D         ; Wait for left button to be pressed down
    SetMouseCursorDefault()
    MouseGetPos, ,,curwin_id
    WinSet AlwaysOnTop, Toggle, ahk_id %curwin_id%
    TrayTip
    return

MenuEnableSpecialCharacters:
    Menu, MySpecialMenu, ToggleCheck, Enable Hotkeys to insert Special Characters
    EnableSpecialCharacters := NOT EnableSpecialCharacters
    IniWrite, %EnableSpecialCharacters%, KDE_Mover-Sizer.ini, SpecialCharacters, EnableSpecialCharacters
    Gosub, InitHotkeyHandler
    If EnableSpecialCharacters
        Traytip, Key Shortcuts for Special Characters enabled, % "Use this to create up to 15 key shortcuts to insert special characters, e.g. for foreign languages. Configure hotkeys and characters in Ini file. Example (default): Press AltGr+c for ç.",30,%TRAYICON_NOSOUND%
    Else
        Reload
    return

MenuEnableFocuslessScroll:
    Menu, MySpecialMenu, ToggleCheck, Enable Wheel Scrolling on inactive Windows
    EnableFocuslessScroll := NOT EnableFocuslessScroll
    IniWrite, %EnableFocuslessScroll%, KDE_Mover-Sizer.ini, Special, EnableFocuslessScroll
    Gosub, InitHotkeyHandler
    If EnableFocuslessScroll
        Traytip, Focusless Scrolling enabled, % "Mouse wheel vertically scrolls window under mouse cursor, even if it has no focus.",30,%TRAYICON_NOSOUND%
    Else
        Reload
    return

MenuEnableDragScroll:
    Menu, MySpecialMenu, ToggleCheck, Enable Drag Scrolling by holding Mouse Button

    EnableDragScroll := NOT EnableDragScroll
    IniWrite, %EnableDragScroll%, KDE_Mover-Sizer.ini, Special, EnableDragScroll
    Gosub, InitHotkeyHandler
    If EnableDragScroll
        Traytip % "Drag Scrolling enabled", % "Click and hold " . strname(DragScroll_Mouse) . " button and move up and down to scroll window under mouse cursor.",30,%TRAYICON_NOSOUND%
        ;Traytip % "Drag Scrolling enabled", % "Click and hold " . strname(DragScroll_Mouse) . " button and move up and down to scroll window under mouse cursor. Hold " . strname(DragScroll_HorizKey)" button for scrollbar control. May not work on all windows.",30,%TRAYICON_NOSOUND%
    Else
        Reload
    return

MenuColourSampler:
    Traytip Colour Sampler, % "Click " . strname(DrawGridOverlay_Mouse) . " to save colour to clipboard. Click " . strname(FreezeSampler_Mouse) . " to freeze sampler position. Press Control and/or Shift to average colour of surrounding pixels.`r`nCancel with ESC", 30,%TRAYICON_NOSOUND%
    DoColourSampler()
    return

MenuDrawGrid:
    Menu, MySpecialMenu, ToggleCheck, Enable Draw grid
    EnableDrawGrid := NOT EnableDrawGrid
    if EnableDrawGrid
        Traytip Drawing Grid Enabled, % "Use " . strname(DrawGridOverlay_Hotkey) . "+" . strname(DrawGridOverlay_Mouse) . "-click to draw grid.`r`nTo change ratio`, press Control (1/4 grid) or Shift (1/3 grid)`r`nor none (golden ratio grid).`r`nClick " . strname(DrawGridOverlay_Mouse) . " to hide it.", 30,%TRAYICON_NOSOUND%
    IniWrite, %EnableDrawGrid%, KDE_Mover-Sizer.ini, Special, EnableDrawGrid
    Reload
    return

MenuDrawGridMouseAutoHold:
    Menu, MySpecialMenu, ToggleCheck, Auto-hold grid
    DrawGridMouseAutoHold := NOT DrawGridMouseAutoHold
    if DrawGridMouseAutoHold
        Traytip Drawing Grid Auto Hold, Grid remains after releasing button. Click again or press ESC to remove grid`., 20,%TRAYICON_NOSOUND%
    IniWrite, %DrawGridMouseAutoHold%, KDE_Mover-Sizer.ini, Special, DrawGridMouseAutoHold
    return

MenuDrawGridShowDistance:
    Menu, MySpecialMenu, ToggleCheck, Show Grid Measures
    DrawGridShowDistance := NOT DrawGridShowDistance
    IniWrite, %DrawGridShowDistance%, KDE_Mover-Sizer.ini, Special, DrawGridShowDistance
    return

MenuShowMeasuresAsToolTip:
    Menu, MySpecialMenu, ToggleCheck, Show Measures as ToolTip
    ShowMeasuresAsToolTip := NOT ShowMeasuresAsToolTip
    IniWrite, %ShowMeasuresAsToolTip%, KDE_Mover-Sizer.ini, Special, ShowMeasuresAsToolTip
    return

; *** MENU: General functions
;
MenuEditMyIni:
    If FileExist("KDE_Mover-Sizer.ini")
        RunWait, KDE_Mover-Sizer.ini
    Else
        MsgBox, % MSGICON_EXCLAMATION, Config file not found, % "Could not find`n" A_WorkingDir "\KDE_Mover-Sizer.ini.`n`nTry to start KDE Mover-Size from a directory with write permissions."
    Reload
    return

MenuHotKeysToggle:
    Menu,Tray,Icon,,,1
    menu, tray, ToggleCheck,Enable HotKeys
    Suspend
    return

MenuExit:
    ExitApp
    return

MenuRunAsAdmin:
    RunAsAdministrator := NOT RunAsAdministrator
    IniWrite, %RunAsAdministrator%, KDE_Mover-Sizer.ini, Settings, RunAsAdministrator
    if RunAsAdministrator
    {
        If ( A_IsAdmin = 0 )
            reload
        else
            Menu, tray, ToggleCheck, Run as administrator
    }
    Else
    {
        MsgBox, % MSGICON_INFO, KDE Mover-Sizer, % "Manual restart is required to return to normal user permissions.."
        If FileExist(startupLinkFile)
        {
            SplitPath, startupLinkFile,, startupLinkFile_Dir
            Run, % "explorer.exe " . startupLinkFile_Dir
        }
        Else
            Run, % "explorer.exe " . A_ScriptDir
        ExitApp
    }
    return

MenuStartupShortcut:
    If FileExist(startupLinkFile)
    {
        MsgBox, % MSGICON_QUESTION_OKCANCEL,Remove from Autostart?, % "Link exists in startup folder:`r`n" . startupLinkFile . "`r`n`r`n"
                     . "Do you want to remove KDE Mover-Sizer from Autostart?"
        IfMsgBox OK
            FileDelete, %startupLinkFile%
    }
    Else {
        MsgBox, % MSGICON_QUESTION_OKCANCEL,Enable Autostart?, % "Do you want to run KDE Mover-Sizer automatically on startup?`r`n`r`n"
           . "Click OK to create a lnk file:`r`n" . startupLinkFile . "`r`n"
        IfMsgBox OK
        {
            Args   := ""
            If A_IsCompiled {
                target := Chr(34) A_ScriptFullPath Chr(34)
                KMSIconFile := target
            }
            Else {
                target := A_AhkPath
                Args   := Chr(34) A_ScriptFullPath Chr(34)
            }
            If FileExist(KMSIconFile)
                FileCreateShortcut, %target%, %startupLinkFile%, %A_ScriptDir%, %Args%, KDE Mover-Sizer, %KMSIconFile%
            Else
                FileCreateShortcut, %target%, %startupLinkFile%, %A_ScriptDir%, %Args%, KDE Mover-Sizer
        }
    }
    
    If FileExist(startupLinkFile)
        Menu, tray, Check, Automatically run on startup
    Else
        Menu, tray, Uncheck, Automatically run on startup
    return
    
MenuHideIcon:
    MsgBox, 0x34,Be Careful!, % "If you disable the tray icon will have no way to shutdown`r`n"
                              . "KDE-Mover-Sizer!`r`n`r`n"
                              . "To revert to the normal behaviour, you will need to delete or set:`r`n`r`n"
                              . "    HideTrayIcon=0`r`n`r`n"
                              . "..in your KDE_Mover-Sizer.ini.`r`n`r`n"
                              . "Are you sure you wish to continue disabling the icon?"
    IfMsgBox No
        return
    HideTrayIcon = 1
    IniWrite, %HideTrayIcon%, KDE_Mover-Sizer.ini, Settings, HideTrayIcon
    Menu,Tray,NoIcon
    return

MenuAbout:
    DoubleAltShortcutsHelptext := ""
    If DoubleAltShortcuts
        DoubleAltShortcutsHelptext := ""
        . "    Double-" . strname(MovingWindow_Hotkey) . " + " . strname(MovingWindow_Mouse) . " Button   -> Minimize a window.`r`n"
        . "    Double-" . strname(ResizingWindow_Hotkey) . " + " . strname(ResizingWindow_Mouse) . " Button  -> Maximize/Restore a window.  `r`n"
        . "    Double-" . strname(ToggleMaximize_Hotkey) . " + " . strname(ToggleMaximize_Mouse) . " Button -> Close a window.`r`n"
        . "`r`n"

    MsgBox,4,About KDE Mover-Sizer.., % "KDE Mover-Sizer..                                                Version 2.11 (March, 2025)`r`n"
        . "`r`n"
        . "KDE Mover-Sizer (created with AHKv1, autohotkey.com)`r`n"
        . "makes it easy to move and resize windows without having`r`n"
        . "to position your mouse cursor accurately.`r`n"
        . "Simply hold down the " . strname(MovingWindow_Hotkey) . " key, and click or drag anywhere on the window.`r`n"
        . "`r`n"
        . "* During move or resize: use " . strname(LockHorizVert_Hotkey2) . " to lock movements horizontally`r`n"
        . "   or vertically. Or press " . strname(WindowToFront_Hotkey2) . " to bring window to foreground.`r`n"
        . "* For Snap-Window-to-Grid: During move or resize`r`n"
        . "   release " . strname(QuickPosition_Hotkey2) . " (while keeping mousebutton pressed), then`r`n"
        . "   push&hold " . strname(QuickPosition_Hotkey2) . " again, and`r`n"
        . "   move mouse around with buttons still pressed.`r`n"
        . "* To temporarily bypass KDE Mover-Sizer, e.g. for " . strname(MovingWindow_Hotkey) . "+Mouse,`r`n"
        . "   try hotkey with an additional modifier key, such as Win.`r`n"
        . "`r`n"
        . "The shortcuts:`r`n"
        . "`r`n"
        . "   " . strname(MovingWindow_Hotkey)   . " + " . strname(MovingWindow_Mouse) . " Button  -> Drag to move a window.`r`n"
        . "   " . strname(ResizingWindow_Hotkey) . " + " . strname(ResizingWindow_Mouse) . " Button -> Drag to resize a window.`r`n"
        . "   " . strname(ToggleMaximize_Hotkey) . " + " . strname(ToggleMaximize_Mouse) . " Button -> Maximize/Restore a window.`r`n"
        . "`r`n"
        . DoubleAltShortcutsHelptext
        . "     The Double-" . strname(DoubleKey_Hotkey2) . " modifier is activated by pressing the`r`n"
        . "     " . strname(DoubleKey_Hotkey2) . " key twice, much like a double-click. Hold the second`r`n"
        . "     hotkey(s) press down until you click the mouse button. Tada!`r`n"
        . "`r`n"
        . "For more, see menu and tray info balloons when enabling options.`r`n"
        . "For even more, edit the INI file and the [AddOns] section.`r`n"
        . "`r`n"
        . "Known authors (in alphabetical order)..`r`n"
        . "`r`n"
        . "   aurelian`r`n"
        . "   Chris`r`n"
        . "   ck`r`n"
        . "   Cor`r`n"
        . "   Jonny`r`n"
        . "   jordoex`r`n"
        . "   Matthias Ihmig`r`n"
        . "   scoox`r`n"
        . "   shimanov`r`n"
        . "   thinkstorm`r`n"
        . "`r`n"
        . "Do you wish to visit the KDE Mover-Sizer web page?`r`n"
    
    IfMsgBox No
        return
    else IfMsgBox Yes
            Run, https://corz.org/windows/software/accessories/KDE-resizing-moving-for-Windows.php
    
    return



; *********************************************
; *********** ACTION: MOVING WINDOW ***********
; *********************************************
;
DoMovingWindowMinimize:

    If CheckIsWindowInList(WindowIgnoreList, WindowMatchStr)
    {
        SendEvent {Blind}{%MovingWindow_Mouse% down}
        KeyWait %MovingWindow_Mouse%, U
        SendEvent {Blind}{%MovingWindow_Mouse% up}
        return
    }
    ; There is sometimes a slight delay when initially grabbing window during moving the mouse, which results in the wrong window being dragged
    ; -> identify target window earlier and then stick with it
    MouseGetPos,,,KDE_id

    If DoubleAlt
    {
        ; Workaround in case an Mouse-XButton is our hotkey (MenuHotkey_XButtons) to avoid accidentally minimizing windows
        ; -> When there is no (modifier) hotkey, only do DoubleAlt-Action within 5secs of the DoubleAlt
        if ( MovingWindow_Hotkey != "" OR A_TimeSincePriorHotkey < 5000 )  ; ignore DoubleAlt when there is no modifier hotkey for and it has occurred more than 5sec ago
            PostMessage, 0x112,0xf020,,,ahk_id %KDE_id%
            ; This message is mostly equivalent to WinMinimize, but it avoids a bug with PSPad.
        DoubleAlt := 0
        ;Send {Blind}{%DoubleKey_hotkey2%}   ; TODO: Check for different hotkeys if this is really no longer necessary
        return
    }

    ; ********************************************
    ; Init-stuff /before/ switching DPI context

    ; stop the double-key and QuickPosition hotkey from interfering
    Gosub, OnDoubleKey_Disable
    if DoubleAltShortcuts = 0
        Hotkey, ~%QuickPosition_Hotkey2%, DoNothing, On

    ; WinRestore 1st part
    WinGet, KDE_WinMaximized,MinMax,ahk_id %KDE_id%
    If KDE_WinMaximized
        WinRestore,ahk_id %KDE_id%     ; restore window size

    ; Get the initial window offset for borderless snapping. Because of a Windows bug, this only works in DPI_AWARENESS_CONTEXT_PER_MONITOR_AWARE mode,
    ; so we need to get it /before/ we switch to the target window mode.
    ; If we can't (old Windows) or don't care, just set all offsets to zero.
    If BorderlessSnappingAndDPI
    {
        WinGetOffset(KDE_WinOffX,KDE_WinOffY,KDE_WinOffW,KDE_WinOffH, KDE_id)
        wndDpiAwareness := GetWindowDpiAwareness(KDE_id)
        wndDpiOriginal  := wndDpiCurrent := GetWindowDpi(KDE_id)
        SetWindowSpecificDpiAwarenessContext(wndDpiAwareness)
    }
    Else
        KDE_WinOffX := KDE_WinOffY := KDE_WinOffW := KDE_WinOffH := 0
    
    ; *******************************************
    ; Init-stuff /after/ switching DPI context

    ; Get the initial mouse position (potentially in the new DPI coordinate system context),
    MouseGetPos, KDE_X1,KDE_Y1

    If ShowWindowWhenDragging = 0
    {
        ; our rect frame includes the invisible border -> only use offset in final WinMove
        KDE_WinOffFrameX := KDE_WinOffX
        KDE_WinOffFrameY := KDE_WinOffY
        KDE_WinOffFrameW := KDE_WinOffW
        KDE_WinOffFrameH := KDE_WinOffH
        KDE_WinOffX := KDE_WinOffY := KDE_WinOffW := KDE_WinOffH := 0
        
        DrawRectFrame_Prepare()
    }

    SaveOriginalWindowState()     ; and enable ESC keys

    ; Get the initial window position.
    WinGetPos, KDE_WinX1, KDE_WinY1, KDE_WinW, KDE_WinH, ahk_id %KDE_id%

    ; WinRestore 2nd part after DPI switch (move window center to cursor)
    If KDE_WinMaximized
    {
        KDE_WinX1 := KDE_X1 - KDE_WinW/2
        KDE_WinY1 := KDE_Y1 - KDE_WinH/2
        WinMove ahk_id %KDE_id%,, KDE_WinX1, KDE_WinY1, KDE_WinW, KDE_WinH
    }

    If BringWindowToFront
        WinActivate, ahk_id %KDE_id% 

    QuickPosition_Button_wasUp := 0     ; used for checking if Alt   button was released once before window is QuickPositioned.
    LockHorizVert_Button_wasUp := 0     ; used for checking if Shift button was released once before movement is locked.
    QuickPosition_wasActive := 0
    
    If (BorderlessSnappingAndDPI = 1 AND ShowWindowWhenDragging = 0)
    {
        ; we want to draw a frame matching the window (without invisible borders), so shrink it
        KDE_WinX1 := KDE_WinX1 - KDE_WinOffFrameX
        KDE_WinY1 := KDE_WinY1 - KDE_WinOffFrameY
        KDE_WinW  := KDE_WinW  - KDE_WinOffFrameW
        KDE_WinH  := KDE_WinH  - KDE_WinOffFrameH
    }
    
    Loop
    {
        GetKeyState,KDE_Button,%MovingWindow_Mouse%,P ; Break if button has been released.
        If KDE_Button = U
            break

        GetKeyState,Esc_Button,Escape,P ; Break if escape button was pressed.
        If Esc_Button = D
        {
            If ShowWindowWhenDragging
                RestoreOriginalWindowState()
            break
        }
        

        if (QuickPosition_Button_wasUp = 0 AND GetKeyState( QuickPosition_Hotkey2, "P" ) = 0)
            QuickPosition_Button_wasUp := 1
        if (LockHorizVert_Button_wasUp = 0 AND GetKeyState( LockHorizVert_Hotkey2, "P" ) = 0)
            LockHorizVert_Button_wasUp := 1

        MouseGetPos,MouseX,MouseY ; Get the current mouse position.

        ; When moving a window to a monitor with a different DPI, scale the window size accordingly,
        ; so that the window content stays the same (e.g. line breaks in editor)
        ; -> assumes default scaling (e.g. notepad). Special scaling (e.g. conhost.exe) is ignored.
        ; This is again a window thing: SYSTEM_AWARE apps scale automatically, MONITOR_AWARE apps take size in actual screen pixels
        If (BorderlessSnappingAndDPI AND wndDpiAwareness = DPI_AWARENESS_PER_MONITOR_AWARE)
        {
            if ShowWindowWhenDragging
                wndDpiNew := GetWindowDpi(KDE_id)
            Else
                wndDpiNew := GetMonitorDpiFromRect(KDE_WinX2,KDE_WinY2, KDE_WinW,KDE_WinH)
                
            ; Tooltip, % "wndDpiCurrent: " wndDpiCurrent ", wndDpiNew: " wndDpiNew
            if (wndDpiNew != wndDpiCurrent)
            {
                wndScale := wndDpiNew / wndDpiCurrent
                wndDpiCurrent := wndDpiNew
                KDE_WinW := ceil(KDE_WinW * wndScale)
                KDE_WinH := ceil(KDE_WinH * wndScale)
            }
        }



        if (QuickPosition_Button_wasUp AND GetKeyState( QuickPosition_Hotkey2 , "P" ))   ; no regular moving, but quickly snap and resize window to screen edge/corner
        {
            ; Mask menu. May otherwise temporarily freeze WinMove/WinResize/Quick-Position after KDE Mover-Sizer option change, even if in background
            if QuickPosition_wasActive = 0
            {
                If (QuickPosition_Hotkey2 = "LWin" OR QuickPosition_Hotkey2 = "Alt")
                    SendEvent {Blind}{LControl}  ; Do this for LWin and Alt hotkeys
                QuickPosition_wasActive := 1
            }
            QuickPositionWindowOnEdge(MouseX,MouseY, KDE_WinX2, KDE_WinY2, KDE_WinW2, KDE_WinH2,  KDE_WinOffX, KDE_WinOffY, KDE_WinOffW, KDE_WinOffH )
        }
        else
        {
            ; Mask menu. May otherwise temporarily freeze WinMove/WinResize/Quick-Position after changing option through KDE Mover-Sizer icon, even if in background
            if QuickPosition_wasActive
            {
                If (QuickPosition_Hotkey2 = "LWin" OR QuickPosition_Hotkey2 = "Alt")
                    SendEvent {Blind}{LControl}  ; Do this for LWin and Alt hotkeys
                QuickPosition_wasActive := 0
            }
            KDE_X2 := MouseX
            KDE_Y2 := MouseY
            KDE_X2 -= KDE_X1    ; Obtain an offset from the initial mouse position.
            KDE_Y2 -= KDE_Y1
            
            if ( LockHorizVert_Button_wasUp AND GetKeyState( LockHorizVert_Hotkey2 , "P" ) )     ; lock mouse to horizontal or vertical movements
            {
                if ( abs(KDE_X2) - abs(KDE_Y2) > 0 )
                    KDE_Y2 := 0 ; lock Y
                else
                    KDE_X2 := 0 ; lock X
            }
            KDE_WinX2 := (KDE_WinX1 + KDE_X2) ; Apply this offset to the window position.
            KDE_WinY2 := (KDE_WinY1 + KDE_Y2)
    
            ; get current screen boarders for snapping, do this within the loop to allow snapping an all monitors without releasing button
            GetCurrentScreenBorders(MouseX,MouseY, CurrentScreenLeft, CurrentScreenRight, CurrentScreenTop, CurrentScreenBottom)

            if SnapOnMoveEnabled
            {
                if (     KDE_WinX2 - KDE_WinOffX < CurrentScreenLeft + SnappingDistance)
                    AND (KDE_WinX2 - KDE_WinOffX > CurrentScreenLeft - SnappingDistance)
                        KDE_WinX2 := CurrentScreenLeft + KDE_WinOffX

                if (     KDE_WinY2 - KDE_WinOffY < CurrentScreenTop + SnappingDistance)
                    AND (KDE_WinY2 - KDE_WinOffY > CurrentScreenTop - SnappingDistance)
                        KDE_WinY2 := CurrentScreenTop + KDE_WinOffY

                if (     KDE_WinX2 - KDE_WinOffX  + KDE_WinW - KDE_WinOffW > CurrentScreenRight - SnappingDistance)
                    AND (KDE_WinX2 - KDE_WinOffX  + KDE_WinW - KDE_WinOffW < CurrentScreenRight + SnappingDistance)
                        KDE_WinX2 := CurrentScreenRight  - KDE_WinW + KDE_WinOffW + KDE_WinOffX

                if (     KDE_WinY2 + KDE_WinH - KDE_WinOffH > CurrentScreenBottom - SnappingDistance)
                    AND (KDE_WinY2 + KDE_WinH - KDE_WinOffH < CurrentScreenBottom + SnappingDistance)
                        KDE_WinY2 := CurrentScreenBottom - KDE_WinH + KDE_WinOffH + KDE_WinOffY
            }
            KDE_WinW2 := KDE_WinW
            KDE_WinH2 := KDE_WinH
        }

        If ShowWindowWhenDragging
            WinMove, ahk_id %KDE_id%,, %KDE_WinX2%, %KDE_WinY2%, %KDE_WinW2%, %KDE_WinH2%  ; Move the window to the new position.
        Else
            DrawRectFrame_Show( KDE_WinX2, KDE_WinY2, KDE_WinW2, KDE_WinH2 )

        if GetKeyState(WindowToFront_Hotkey2) = 1
        {
            WinActivate, ahk_id %KDE_id%
            if ShowWindowWhenDragging = 0
                WinMove, ahk_id %KDE_id%,, (KDE_WinX2 + KDE_WinOffFrameX), (KDE_WinY2 + KDE_WinOffFrameY), (KDE_WinW2 + KDE_WinOffFrameW), (KDE_WinH2 + KDE_WinOffFrameH) ; Move the window to the new position.
        }
    } ; END OF MOVING LOOP

    ; ************************
    ; * Cleanup after Moving

    If ShowWindowWhenDragging = 0
    {
        ; If we move a MONITOR_AWARE window to a different screen for the first time, Windows will scale automatically _after_ our move command,
        ; so our (already scaled) width and height will no longer match.
        ; -> for this case, pre-(un)scale width and height and let windows do the scaling
        if ( wndDpiAwareness = DPI_AWARENESS_PER_MONITOR_AWARE )
        {
            wndDpiNew := GetMonitorDpiFromRect(KDE_WinX2,KDE_WinY2, KDE_WinW2,KDE_WinH2)
            if (wndDpiNew != wndDpiOriginal)
            {
                wndScale := wndDpiOriginal / wndDpiNew
                KDE_WinW2 := ceil(KDE_WinW2 * wndScale)
                KDE_WinH2 := ceil(KDE_WinH2 * wndScale)
            }
        }
        DrawRectFrame_Cancel()
        If Esc_Button = U
            WinMove, ahk_id %KDE_id%,, (KDE_WinX2 + KDE_WinOffFrameX), (KDE_WinY2 + KDE_WinOffFrameY), (KDE_WinW2 + KDE_WinOffFrameW), (KDE_WinH2 + KDE_WinOffFrameH) ; Move the window to the new position.
    }

    If BorderlessSnappingAndDPI
        RestoreWindowSpecificDpiAwarenessContext(wndDpiAwareness)

    DisableEscapeHotkey()

    ; reenable DoubleKey_Hotkey
    Gosub, OnDoubleKey_Enable
    if DoubleAltShortcuts = 0
        Hotkey, ~%QuickPosition_Hotkey2%, Off

    return


; ***********************************************
; *********** ACTION: RESIZING WINDOW ***********
; ***********************************************
;
DoResizingWindowMaximize:

    If CheckIsWindowInList(WindowIgnoreList, WindowMatchStr)
    {
        SendEvent {Blind}{%ResizingWindow_Mouse% down}
        KeyWait %ResizingWindow_Mouse%, U
        SendEvent {Blind}{%ResizingWindow_Mouse% up}
        return
    }
    ; There is a slight delay when grabbing window during moving the mouse, which sometimes results in the wrong window being dragged
    ; -> identify target window earlier (here)
    MouseGetPos, KDE_X1,KDE_Y1,KDE_id

    If DoubleAlt
    {
        ; Workaround in case an Mouse-XButton is our hotkey (MenuHotkey_XButtons) to avoid accidentally minimizing windows
        ; ignore DoubleAlt when there is no modifier hotkey for and it has occurred more than 5sec ago
        ; -> When there is no (modifier) hotkey, only do DoubleAlt-Action within 5secs of the DoubleAlt
        if ( ResizingWindow_Hotkey != "" OR A_TimeSincePriorHotkey < 5000 ) {

            If BringWindowToFront
                WinActivate, ahk_id %KDE_id%

            ; Toggle between maximized and restored state.
            WinGet, KDE_Win,MinMax,ahk_id %KDE_id%
            If KDE_Win
                WinRestore, ahk_id %KDE_id%
            Else
                WinMaximize, ahk_id %KDE_id%
        }
        DoubleAlt := 0
        ;Send {Blind}{%DoubleKey_hotkey2%}

        return
    }

    ; ********************************************
    ; Init-stuff /before/ switching DPI context

    ; stop the double-key from interfering
    Gosub, OnDoubleKey_Disable
    if DoubleAltShortcuts = 0
        Hotkey, ~%QuickPosition_Hotkey2%, DoNothing, On


    ; Get the initial mouse position and window id, and
    ; do WinRestore if the window is maximized.

    WinGet, KDE_Win,MinMax,ahk_id %KDE_id%

    If KDE_Win
    {
        if DoRestoreOnResize
            WinRestore, ahk_id %KDE_id%
        else
        {
            WinGetPos, KDE_WinX1, KDE_WinY1, KDE_WinW, KDE_WinH, ahk_id %KDE_id%
            GetCurrentScreenBorders(KDE_X1,KDE_Y1, CurrentScreenLeft, CurrentScreenRight, CurrentScreenTop, CurrentScreenBottom)

            KDE_WinX1 := CurrentScreenLeft + KDE_WinOffX
            KDE_WinY1 := CurrentScreenTop  + KDE_WinOffY
            KDE_WinW  := CurrentScreenRight  - CurrentScreenLeft + KDE_WinOffW
            KDE_WinH  := CurrentScreenBottom - CurrentScreenTop  + KDE_WinOffH

            WinRestore, ahk_id %KDE_id%
            WinMove, ahk_id %KDE_id%,, KDE_WinX1, KDE_WinY1, KDE_WinW, KDE_WinH
        }
        Sleep,5
    }

    ; Get the initial window offset for borderless snapping. Because of a Windows bug, this only works in DPI_AWARENESS_CONTEXT_PER_MONITOR_AWARE mode,
    ; so we need to get it before we switch to the target window mode
    ; if we can't (old Windows) or don't care, just set all offsets to zero
    If BorderlessSnappingAndDPI
    {
        WinGetOffset(KDE_WinOffX,KDE_WinOffY,KDE_WinOffW,KDE_WinOffH, KDE_id)
        wndDpiAwareness := GetWindowDpiAwareness(KDE_id)
        SetWindowSpecificDpiAwarenessContext(wndDpiAwareness)
    }
    Else
        KDE_WinOffX := KDE_WinOffY := KDE_WinOffW := KDE_WinOffH := 0
    
    
    ; *******************************************
    ; Init-stuff /after/ switching DPI context

    If ShowWindowWhenDragging = 0
    {
        ; our rect frame includes the invisible border -> only use offset in final WinMove
        KDE_WinOffFrameX := KDE_WinOffX
        KDE_WinOffFrameY := KDE_WinOffY
        KDE_WinOffFrameW := KDE_WinOffW
        KDE_WinOffFrameH := KDE_WinOffH
        KDE_WinOffX := KDE_WinOffY := KDE_WinOffW := KDE_WinOffH := 0
        
        DrawRectFrame_Prepare()
    }

    SaveOriginalWindowState()     ; and enable ESC keys

    MouseGetPos, KDE_X1, KDE_Y1

    If BringWindowToFront
        WinActivate, ahk_id %KDE_id% 

    ; Get the initial window position and size.
    WinGetPos, KDE_WinX1, KDE_WinY1, KDE_WinW, KDE_WinH, ahk_id %KDE_id%
    
    If (ShowWindowWhenDragging = 0 AND BorderlessSnappingAndDPI = 1)
    {
        ; we want to draw a frame matching the window (without invisible borders), so we shrink it
        KDE_WinX1 := KDE_WinX1 - KDE_WinOffFrameX
        KDE_WinY1 := KDE_WinY1 - KDE_WinOffFrameY
        KDE_WinW  := KDE_WinW  - KDE_WinOffFrameW
        KDE_WinH  := KDE_WinH  - KDE_WinOffFrameH
    }
    
    KDE_WinX2 := KDE_WinX1
    KDE_WinY2 := KDE_WinY1
    KDE_WinW2 := KDE_WinW
    KDE_WinH2 := KDE_WinH

    ; save original position to use for locked magnetic resizing
    MouseGetPos, Lock_saveKDE_X1, Lock_saveKDE_Y1
    
    WinGetPos, Lock_saveKDE_WinX2, Lock_saveKDE_WinY2, Lock_saveKDE_WinW2, Lock_saveKDE_WinH2, ahk_id %KDE_id%
    If (ShowWindowWhenDragging = 0 AND BorderlessSnappingAndDPI = 1)
    {
        ; we want to draw a frame matching the window (without invisible borders), so we shrink it
        Lock_saveKDE_WinX2 := Lock_saveKDE_WinX2 - KDE_WinOffFrameX
        Lock_saveKDE_WinY2 := Lock_saveKDE_WinY2 - KDE_WinOffFrameY
        Lock_saveKDE_WinW2 := Lock_saveKDE_WinW2 - KDE_WinOffFrameW
        Lock_saveKDE_WinH2 := Lock_saveKDE_WinH2 - KDE_WinOffFrameH
    }
    ; Define the window region the mouse is currently in.
    ;
    if NOT Use3x3ResizeGrid      ; use 2x2 grid
    {
        ; The four regions are Up and Left, Up and Right, Down and Left, Down and Right
        ; WinLeft = [-1;1], WinUp = [-1;1]
    
        If (KDE_X1 < KDE_WinX1 + KDE_WinW / 2)
            KDE_WinLeft := 1
        Else
            KDE_WinLeft := -1
        If (KDE_Y1 < KDE_WinY1 + KDE_WinH / 2)
            KDE_WinUp := 1
        Else
            KDE_WinUp := -1
    }
    else                         ; use 3x3 grid
    {
        ; WinLeft = [-1;0;1], WinUp = [-1;0;1]

        KDE_WinLeft := 0
        KDE_WinUp   := 0
        If (KDE_X1 < KDE_WinX1 + KDE_WinW / 3)
            KDE_WinLeft := 1
        If (KDE_X1 > KDE_WinX1 + KDE_WinW *2/3)
            KDE_WinLeft := -1
        If (KDE_Y1 < KDE_WinY1 + KDE_WinH / 3)
            KDE_WinUp := 1
        If (KDE_Y1 > KDE_WinY1 + KDE_WinH *2/3)
            KDE_WinUp := -1
    }

    QuickPosition_Button_wasUp := NOT GetKeyState( QuickPosition_Hotkey2, "P" )
    LockHorizVert_Button_wasUp := NOT GetKeyState( LockHorizVert_Hotkey2, "P" )
    QuickPosition_wasActive    := 0
    
    locked := 0

    Loop
    {
        GetKeyState, KDE_Button,%ResizingWindow_Mouse%,P ; Break if button has been released / pressed twice
        If KDE_Button = U
            break

        GetKeyState, Esc_Button,Escape,P ; Break if escape button was pressed.
        If Esc_Button = D
        {
            If ShowWindowWhenDragging
                RestoreOriginalWindowState()
            break
        }

        MouseGetPos,MouseX,MouseY ; Get the current mouse position.
        KDE_X2 := MouseX - KDE_X1 ; Obtain an offset from the initial mouse position.
        KDE_Y2 := MouseY - KDE_Y1

        if (LockHorizVert_Button_wasUp = 1 AND GetKeyState( LockHorizVert_Hotkey2 , "P" ) = 1)      ; lock mouse to horizontal or vertical movements
        {
            ; ***** Lock Hotkey is pressed -> lock mouse to horizontal or vertical movements *****
            ;
            if (SnapOnSizeEnabled = 1 AND SnapOnResizeMagnetic = 1)   ; locking during Magnetic Resizing needs special handling because of the way it's updated
            {
                if locked = 0
                {
                    MouseMove Lock_saveKDE_X1, Lock_saveKDE_Y1
                    MouseX := Lock_saveKDE_X1
                    MouseY := Lock_saveKDE_Y1
                    KDE_WinX2 := Lock_saveKDE_WinX2
                    KDE_WinY2 := Lock_saveKDE_WinY2
                    KDE_WinW2 := Lock_saveKDE_WinW2
                    KDE_WinH2 := Lock_saveKDE_WinH2
                    KDE_X1 := Lock_saveKDE_X1
                    KDE_Y1 := Lock_saveKDE_Y1
                    KDE_X2 := 0
                    KDE_Y2 := 0
                    If ShowWindowWhenDragging
                    {
                        If BorderlessSnappingAndDPI
                            SetWindowSpecificDpiAwarenessContext(wndDpiAwareness)

                        WinMove, ahk_id %KDE_id%,, %KDE_WinX2%, %KDE_WinY2%, %KDE_WinW2%, %KDE_WinH2%
                        
                        If BorderlessSnappingAndDPI
                            RestoreWindowSpecificDpiAwarenessContext(wndDpiAwareness)
                    }
                    Else
                        DrawRectFrame_Show( KDE_WinX2, KDE_WinY2, KDE_WinW2, KDE_WinH2 )
            
                    Loop        ; wait until mouse moved to determine locked direction
                    {
                        MouseGetPos,MX,MY
                        if ( abs(MouseX-MX)>4 or abs(MouseY-MY)>4 or NOT GetKeyState(LockHorizVert_Hotkey2,"P") or GetKeyState("Escape","P") )
                            break
                        Sleep, 20
                    }
                    if ( abs(MX - MouseX) - abs(MY - MouseY) > 0)
                        locked := 1 ; lock Y
                    else
                        locked := 2 ; lock X
                }
                if locked = 1
                    KDE_Y2 := 0
                if locked = 2
                    KDE_X2 := 0
            } else              ; locking for default Resizing
            {
                if ( abs(KDE_X2) - abs(KDE_Y2) > 0 )
                    KDE_Y2 := 0 ; lock Y
                else
                    KDE_X2 := 0 ; lock X
            }
        }
        if ( LockHorizVert_Button_wasUp = 1 AND locked != 0 AND GetKeyState( LockHorizVert_Hotkey2 , "P" ) = 0 )
        {
            ; ***** Lock key was released
            locked := 0
        }

        ; snap the window to the edge of the screen if closer than 10 pixels to border
        ; first, get current screen boarders for snapping, do this within the loop to allow snapping an all monitors without releasing button
        ; get current screen boarders for snapping, do this within the loop to allow snapping an all monitors without releasing button
        GetCurrentScreenBorders(MouseX,MouseY, CurrentScreenLeft, CurrentScreenRight, CurrentScreenTop, CurrentScreenBottom)

        if QuickPosition_Button_wasUp = 0
            QuickPosition_Button_wasUp := NOT GetKeyState( QuickPosition_Hotkey2, "P" )
        if LockHorizVert_Button_wasUp = 0
            LockHorizVert_Button_wasUp := NOT GetKeyState( LockHorizVert_Hotkey2, "P" )


        if ( QuickPosition_Button_wasUp = 1 AND GetKeyState( QuickPosition_Hotkey2, "P") = 1 )      ; for "quick positioning", hotkey must be released once before window is QuickPositioned
        {
            ; ***** Resize Mode "Quick Positioning" *****
            ;
            if QuickPosition_wasActive = 0   ; save mouse and window position to allow clean switch between magnetic resizing and QuickPositioning
            {
                QuickPosition_wasActive := 1
                
                QuickPos_saveMouseX := MouseX
                QuickPos_saveMouseY := MouseY
                QuickPos_saveKDE_WinX2 := KDE_WinX2
                QuickPos_saveKDE_WinY2 := KDE_WinY2
                QuickPos_saveKDE_WinW2 := KDE_WinW2
                QuickPos_saveKDE_WinH2 := KDE_WinH2
                
                ; Mask menu. May otherwise temporarily freeze WinMove/WinResize/Quick-Position after KDE Mover-Sizer option change, even if in background
                If (QuickPosition_Hotkey2 = "LWin" OR QuickPosition_Hotkey2 = "Alt")
                    SendEvent {Blind}{LControl}
            }
            QuickPositionWindowOnEdge(MouseX,MouseY, KDE_WinX2, KDE_WinY2, KDE_WinW2, KDE_WinH2,  KDE_WinOffX, KDE_WinOffY, KDE_WinOffW, KDE_WinOffH )
        }
        else if (SnapOnSizeEnabled = 1 AND SnapOnResizeMagnetic = 0)
        {
            ; ***** Resize Mode "normal resizing" *****
            ;
            if QuickPosition_wasActive
            {
                If (QuickPosition_Hotkey2 = "LWin" OR QuickPosition_Hotkey2 = "Alt")
                    SendEvent {Blind}{LControl}  ; mask menu
                QuickPosition_wasActive := 0
            }

            KDE_WinX2 := (KDE_WinX1 + (KDE_WinLeft =1 ? 1 : 0)*KDE_X2) ; X of resized windows
            KDE_WinY2 := (KDE_WinY1 + (KDE_WinUp   =1 ? 1 : 0)*KDE_Y2) ; Y of resized windows
            KDE_WinW2 := (KDE_WinW  -  KDE_WinLeft *KDE_X2) ; W of resized windows
            KDE_WinH2 := (KDE_WinH  -  KDE_WinUp   *KDE_Y2) ; H of resized windows

            if (     KDE_WinX2 - KDE_WinOffX < CurrentScreenLeft + SnappingDistance)
                AND (KDE_WinX2 - KDE_WinOffX > CurrentScreenLeft - SnappingDistance)
                AND (KDE_WinLeft > 0)
            {
                KDE_WinX2 := CurrentScreenLeft + KDE_WinOffX
                KDE_WinW2 := KDE_WinW + KDE_WinX1 - CurrentScreenLeft  - KDE_WinOffX
            }
            if (     KDE_WinY2 - KDE_WinOffY < CurrentScreenTop + SnappingDistance)
                AND (KDE_WinY2 - KDE_WinOffY > CurrentScreenTop - SnappingDistance)
                AND (KDE_WinUp > 0)
            {
                KDE_WinY2 := CurrentScreenTop + KDE_WinOffY
                KDE_WinH2 := KDE_WinH + KDE_WinY1 - CurrentScreenTop  - KDE_WinOffY
            }
            if (     KDE_WinX2 - KDE_WinOffX + KDE_WinW2 - KDE_WinOffW > CurrentScreenRight - SnappingDistance)
                AND (KDE_WinX2 - KDE_WinOffX + KDE_WinW2 - KDE_WinOffW < CurrentScreenRight + SnappingDistance)
                AND (KDE_WinLeft < 0)
            {
                KDE_WinW2 := - KDE_WinX1 + CurrentScreenRight  + (KDE_WinOffW+KDE_WinOffX)
            }
            if (     KDE_WinY2 + KDE_WinH2 - KDE_WinOffH > CurrentScreenBottom - SnappingDistance)
                AND (KDE_WinY2 + KDE_WinH2 - KDE_WinOffH < CurrentScreenBottom + SnappingDistance)
                AND (KDE_WinUp < 0)
            {
                KDE_WinH2 := - KDE_WinY1 + CurrentScreenBottom + (KDE_WinOffH+KDE_WinOffY)
            }
        }
        else if (SnapOnSizeEnabled = 1 AND SnapOnResizeMagnetic = 1)    ;  Magnetic Edges resize the window but keep the edge "locked"
        {
            ; ***** Resize Mode "Magnetic Edges Resizing" *****
            ;
            if QuickPosition_wasActive                            ;  restore previous mouse and window position to ensure clean switch between Magnetic resizing and QuickPositioning
            {
                MouseMove QuickPos_saveMouseX, QuickPos_saveMouseY
                MouseX := QuickPos_saveMouseX
                MouseY := QuickPos_saveMouseY
                KDE_WinX2 := QuickPos_saveKDE_WinX2
                KDE_WinY2 := QuickPos_saveKDE_WinY2
                KDE_WinW2 := QuickPos_saveKDE_WinW2
                KDE_WinH2 := QuickPos_saveKDE_WinH2
                KDE_X2 := QuickPos_saveMouseX - KDE_X1
                KDE_Y2 := QuickPos_saveMouseY - KDE_Y1

                If (QuickPosition_Hotkey2 = "LWin" OR QuickPosition_Hotkey2 = "Alt")
                    SendEvent {Blind}{LControl}  ; mask menu
                QuickPosition_wasActive := 0
            }
            
            ; Get the current window position and size.
            KDE_WinX1 := KDE_WinX2
            KDE_WinY1 := KDE_WinY2
            KDE_WinW  := KDE_WinW2
            KDE_WinH  := KDE_WinH2

            if (KDE_WinX1 - KDE_WinOffX < CurrentScreenLeft + SnappingDistance) ;AND (KDE_WinX1 - KDE_WinOffX > CurrentScreenLeft - SnappingDistance)
                KDE_WinX1 := CurrentScreenLeft + KDE_WinOffX

            if (KDE_WinY1 - KDE_WinOffY < CurrentScreenTop + SnappingDistance) ;AND (KDE_WinY1 - KDE_WinOffY> CurrentScreenTop - SnappingDistance)
                KDE_WinY1 := CurrentScreenTop + KDE_WinOffY

            if (KDE_WinX1 - KDE_WinOffX + KDE_WinW - KDE_WinOffW > CurrentScreenRight - SnappingDistance) ;AND (KDE_WinX1-KDE_WinOffX + KDE_WinW-KDE_WinOffW < CurrentScreenRight + SnappingDistance)
                KDE_WinX1 := CurrentScreenRight - KDE_WinW + (KDE_WinOffW+KDE_WinOffX)

            if (KDE_WinY1 - KDE_WinOffY + KDE_WinH - KDE_WinOffH > CurrentScreenBottom - SnappingDistance) ;AND (KDE_WinY1-KDE_WinOffY + KDE_WinH-KDE_WinOffH < CurrentScreenBottom + SnappingDistance)
                KDE_WinY1 := CurrentScreenBottom - KDE_WinH + (KDE_WinOffH+KDE_WinOffY)

            KDE_WinX2 := (KDE_WinX1 + (KDE_WinLeft =1 ? 1 : 0)*KDE_X2) ; X of resized windows
            KDE_WinY2 := (KDE_WinY1 + (KDE_WinUp   =1 ? 1 : 0)*KDE_Y2) ; Y of resized windows
            KDE_WinW2 := (KDE_WinW  -  KDE_WinLeft *KDE_X2) ; W of resized windows
            KDE_WinH2 := (KDE_WinH  -  KDE_WinUp   *KDE_Y2) ; H of resized windows
     
            KDE_X1 := MouseX ; Reset the initial position for the next iteration.
            KDE_Y1 := MouseY
        }
        else
        {
            ; ***** Plain Resizing (no snapping at all) *****
            ;
            if QuickPosition_wasActive
            {
                If (QuickPosition_Hotkey2 = "LWin" OR QuickPosition_Hotkey2 = "Alt")
                    SendEvent {Blind}{LControl}  ; mask menu
                QuickPosition_wasActive := 0
            }            
            KDE_WinX2 := (KDE_WinX1 + (KDE_WinLeft =1 ? 1 : 0)*KDE_X2) ; X of resized windows
            KDE_WinY2 := (KDE_WinY1 + (KDE_WinUp   =1 ? 1 : 0)*KDE_Y2) ; Y of resized windows
            KDE_WinW2 := (KDE_WinW  -     KDE_WinLeft  *KDE_X2) ; W of resized windows
            KDE_WinH2 := (KDE_WinH  -       KDE_WinUp  *KDE_Y2) ; H of resized windows
        }

        if GetKeyState(WindowToFront_Hotkey2) = 1
        {
            WinActivate, ahk_id %KDE_id%
            if ShowWindowWhenDragging = 0
                WinMove, ahk_id %KDE_id%,, (KDE_WinX2 + KDE_WinOffFrameX), (KDE_WinY2 + KDE_WinOffFrameY), (KDE_WinW2 + KDE_WinOffFrameW), (KDE_WinH2 + KDE_WinOffFrameH) ; Move the window to the new position.
        }

        ; Then, act according to the defined region.
        If ShowWindowWhenDragging
            WinMove, ahk_id %KDE_id%,, %KDE_WinX2%, %KDE_WinY2%, %KDE_WinW2%, %KDE_WinH2%
        Else
            DrawRectFrame_Show( KDE_WinX2, KDE_WinY2, KDE_WinW2, KDE_WinH2 )
    }  ; END OF RESIZING LOOP
    
    ; **************************
    ; * Cleanup after Resizing
    
    If ShowWindowWhenDragging = 0
    {
        DrawRectFrame_Cancel()

        If Esc_Button = U
            WinMove, ahk_id %KDE_id%,, (KDE_WinX2 + KDE_WinOffFrameX), (KDE_WinY2 + KDE_WinOffFrameY), (KDE_WinW2 + KDE_WinOffFrameW), (KDE_WinH2 + KDE_WinOffFrameH) ; Move the window to the new position.
    }

    If BorderlessSnappingAndDPI
        RestoreWindowSpecificDpiAwarenessContext(wndDpiAwareness)
    
    DisableEscapeHotkey()

    ; reenable DoubleKey_Hotkey
    Gosub, OnDoubleKey_Enable
    if DoubleAltShortcuts = 0
        Hotkey, ~%QuickPosition_Hotkey2%, Off
    
    return


; *************************************************************
; *********** ACTION: TOGGLE Maximize/Original size ***********
; *************************************************************

DoToggleMaximize:

    If CheckIsWindowInList(WindowIgnoreList, WindowMatchStr)
    {
        SendEvent {Blind}{%ToggleMaximize_Mouse% down}
        KeyWait %ToggleMaximize_Mouse%, U
        SendEvent {Blind}{%ToggleMaximize_Mouse% up}
        return
    }

    ; For Double-Alt + middle Button: Close Window
    ;
    If DoubleAlt
    {
        ; Workaround in case an Mouse-XButton is our hotkey (MenuHotkey_XButtons) to avoid accidentally minimizing windows
        ; -> When there is no (modifier) hotkey, only do DoubleAlt-Action within 5secs of the DoubleAlt
        if ( ToggleMaximize_Hotkey != "" OR A_TimeSincePriorHotkey < 5000 )  ; ignore DoubleAlt when there is no modifier hotkey for and it has occurred more than 5sec ago
        {
            MouseGetPos, ,,KDE_id
            WinClose, ahk_id %KDE_id%
        }
        DoubleAlt := 0
        return
    }

    ; Toggle window Maximize/Original size with Alt+Middle mouse button
    ;
    If MayToggleMaximizeRestore
    {
        ; Toggle between maximized and restored state of window under mouse cursor
        MouseGetPos, ,,KDE_id
        WinGet, KDE_Win,MinMax,ahk_id %KDE_id%
        If KDE_Win
            WinRestore, ahk_id %KDE_id%
        Else
            WinMaximize, ahk_id %KDE_id%

        MayToggleMaximizeRestore := 0
        return
    }
    return

DoToggleMaximize_Up:
    MayToggleMaximizeRestore := 1
    return



; ********************************************************************************
; ******* This detects "double-clicks" of the alt/DoubleKey_hotkey2 key.   *******
; ********************************************************************************

OnDoubleKey:
    if DoubleAltShortcuts
        DoubleAlt := A_PriorHotKey = "~"DoubleKey_hotkey2 AND A_TimeSincePriorHotkey < DoubleModifierKey_MaxDelay_ms
   
    Sleep, 1  ; give (start) menu time to open, so we can close it
    if (DoubleAlt AND (DoubleKey_hotkey2 = "LWin" OR DoubleKey_hotkey2 = "RWin"))
        SendEvent {Esc}  ; we are on the 2nd call of double-win hotkey -> close start menu
    
    if DoubleKey_isAltGr
        KeyWait RAlt
    else
        KeyWait %DoubleKey_hotkey2%  ; This prevents the keyboard's auto-repeat feature from interfering.
    return

OnDoubleKey_Enable:
    if DoubleAltShortcuts {
        Hotkey,IfWinNotActive, ahk_group IgnoreActiveWindowsList
            Hotkey, ~%DoubleKey_Hotkey2%, OnDoubleKey, On
        Hotkey, IfWinNotActive
    }
    return

OnDoubleKey_Disable:
    if DoubleAltShortcuts
        Hotkey, ~%DoubleKey_Hotkey2%, DoNothing, On
    return

; *******************************************************************************
; ************* ACTION: DRAW GRID OVERLAY, e.g. to analyze images ***************
; *******************************************************************************
;
; Default Trigger: Control+Alt+Right + mousebutton
; - overlay a golden ratio, 3x3 or 4x4 grid, to find out why those other images always looks so great.
; - Position, Size, length of diagonal and ratio of grid is shown in Tooltip or balloon (configurable)
; - HINT: Move the tooltip with Alt+Left(default moving hotkey) mouse button to new destination and confirm with Right click.
;         This position will be used the next time . Edit INI to change how grid looks, e.g. for a thinner 2px black grid, set:
;         DrawGridColour=Black and DrawGridGUIOptions=-Border and DrawGridWidth=2
; Keys:
; - Use Ctrl, Shift or both to toggle grid ratio
; - Use Right click or ESC to abort

DoDrawGridOverlay:

    CatchGridButtonHotkey()   ; Catch %DrawGridOverlay_Mouse% mouse button and don't pass it to underlying app
    SetMouseCursorCross()
    MouseGetPos,Mouse_X1,Mouse_Y1,curwin_id ; Get the current mouse position and windowID under mouse

    Loop, 12
    {
        Gui, %A_Index%: -Caption +ToolWindow +AlwaysOnTOp +OwnDialogs -DPIScale %DrawGridGUIOptions%
        Gui, %A_Index%: Color, %DrawGridColour%
    }

    ButtonOnce := 0
    KeyLast    := 0
    KeyToggle  := 0
    Hotkey, Escape, DoNothing, On                ; Catch ESC to stop underlying app to handle it

    Loop
    {
        If GetKeyState("Escape","P")    ; Break if escape button was pressed.
            break

        GetKeyState, KDE_Button,%DrawGridOverlay_Mouse%,P ; Break if button has been released (and AutoHold is off). Otherwise, freeze grid
        If KDE_Button = U
            If DrawGridMouseAutoHold
            {
                If ButtonOnce = 0
                    ButtonOnce := 1
            }
            Else
                break

        If ButtonOnce
            If KDE_Button = D
                break

        GetKeyState, KDE_Ctrl,Control,P ; Toggle 3x3 and 4x4 grid with Control key
        GetKeyState, KDE_Shift,Shift,P  ; Toggle golden cut and 1/3 grid with Shift key

        If ButtonOnce = 0
        {
            Loop        ; wait with graphics update until mouse moved or keys were pressed/released
            {
                GetKeyState, KDE_Ctrl_new, Control,P
                GetKeyState, KDE_Shift_new,Shift,P
                
                MouseGetPos, MX,MY ; Get the current mouse position.
                if ( MX != Mouse_X2 OR MY != Mouse_Y2 OR (GetKeyState(DrawGridOverlay_Mouse,"P") = 0) OR GetKeyState("Escape","P") )
                    break
                if ( KDE_Ctrl_new != KDE_Ctrl OR KDE_Shift_new != KDE_Shift )
                {
                    KDE_Ctrl  := KDE_Ctrl_new
                    KDE_Shift := KDE_Shift_new
                    break
                }
                Sleep, 20
            }
            Mouse_X2 = %MX%
            Mouse_Y2 = %MY%
            WinX := min( Mouse_X1, Mouse_X2 )
            WinY := min( Mouse_Y1, Mouse_Y2 )
            WinW := abs( Mouse_X1 - Mouse_X2 )
            WinH := abs( Mouse_Y1 - Mouse_Y2 )
        }

        If ( KDE_Ctrl = "D" AND KDE_Shift = "U" ) {   ; draw 1/4 grid
            WX1 := WinX
            WX2 := WinX + 1/4 * WinW
            WX3 := WinX + 2/4 * WinW
            WX4 := WinX + 3/4 * WinW
            WX5 := WinX + 4/4 * WinW
            WX6 := WinX + 4/4 * WinW
            WY1 := WinY
            WY2 := WinY + 1/4 * WinH
            WY3 := WinY + 2/4 * WinH
            WY4 := WinY + 3/4 * WinH
            WY5 := WinY + 4/4 * WinH
            WY6 := WinY + 4/4 * WinH
            If (KeyLast != 1)
                KeyToggle = 1
            KeyLast = 1
        }
        If ( KDE_Ctrl = "U" AND KDE_Shift = "D" ) {   ; draw 1/3 grid
            WX1 := WinX
            WX2 := WinX + 1/3 * WinW
            WX3 := WinX + 2/3 * WinW
            WX4 := WinX + 3/3 * WinW
            WX5 := WinX + 3/3 * WinW
            WX6 := WinX + 3/3 * WinW
            WY1 := WinY
            WY2 := WinY + 1/3 * WinH
            WY3 := WinY + 2/3 * WinH
            WY4 := WinY + 3/3 * WinH
            WY5 := WinY + 3/3 * WinH
            WY6 := WinY + 3/3 * WinH
            If (KeyLast != 2)
                KeyToggle = 1
            KeyLast = 2
        }
        If ( KDE_Shift = "D" AND KDE_Ctrl = "D" ) {   ; draw complex golden rule grid
            WX1 := WinX + 0.382 * WinW
            WX2 := WinX + 0.382*0.382 * WinW
            WX3 := WinX + 0.382*0.618 * WinW
            WX4 := WinX + (0.618 + 0.382*0.382) * WinW
            WX5 := WinX + (0.618 + 0.382*0.618) * WinW
            WX6 := WinX + 0.618 * WinW
            WY1 := WinY + 0.382 * WinH
            WY2 := WinY + 0.382*0.382 * WinH
            WY3 := WinY + 0.382*0.618 * WinH
            WY4 := WinY + (0.618 + 0.382*0.382) * WinH
            WY5 := WinY + (0.618 + 0.382*0.618) * WinH
            WY6 := WinY + 0.618 * WinH
            If (KeyLast != 3)
                KeyToggle = 1
            KeyLast = 3
        }
        If ( KDE_Ctrl = "U" AND KDE_Shift = "U" ) {   ; draw simple golden rule grid
            WX1 := WinX
            WX2 := WinX + 0.382 * WinW
            WX3 := WinX + 0.618 * WinW
            WX4 := WinX + 3/3 * WinW
            WX5 := WinX + 3/3 * WinW
            WX6 := WinX + 3/3 * WinW
            WY1 := WinY
            WY2 := WinY + 0.382 * WinH ; 1/3 * WinH
            WY3 := WinY + 0.618 * WinH ; 2/3 * WinH
            WY4 := WinY + 3/3 * WinH
            WY5 := WinY + 3/3 * WinH
            WY6 := WinY + 3/3 * WinH
            If (KeyLast != 4)
                KeyToggle = 1
            KeyLast = 4
        }

        Gui, 1: Show, % "x" WX1 " y" WinY " w" DrawGridWidth " h" WinH " NoActivate"
        Gui, 2: Show, % "x" WX2 " y" WinY " w" DrawGridWidth " h" WinH " NoActivate"
        Gui, 3: Show, % "x" WX3 " y" WinY " w" DrawGridWidth " h" WinH " NoActivate"
        Gui, 4: Show, % "x" WX4 " y" WinY " w" DrawGridWidth " h" WinH " NoActivate"
        Gui, 5: Show, % "x" WX5 " y" WinY " w" DrawGridWidth " h" WinH " NoActivate"
        Gui, 6: Show, % "x" WX6 " y" WinY " w" DrawGridWidth " h" WinH " NoActivate"
        Gui, 7: Show, % "x" WinX " y" WY1 " h" DrawGridWidth " w" WinW " NoActivate"
        Gui, 8: Show, % "x" WinX " y" WY2 " h" DrawGridWidth " w" WinW " NoActivate"
        Gui, 9: Show, % "x" WinX " y" WY3 " h" DrawGridWidth " w" WinW " NoActivate"
        Gui,10: Show, % "x" WinX " y" WY4 " h" DrawGridWidth " w" WinW " NoActivate"
        Gui,11: Show, % "x" WinX " y" WY5 " h" DrawGridWidth " w" WinW " NoActivate"
        Gui,12: Show, % "x" WinX " y" WY6 " h" DrawGridWidth " w" WinW " NoActivate"
        
        If ( (DrawGridShowDistance AND NOT ButtonOnce) OR (DrawGridShowDistance AND KeyToggle) )
        {
            dist := Round( sqrt( WinH * WinH + WinW * WinW ), 2)
            ratio := WinW / WinH
            if (ratio < 1)
                ratio := WinH / WinW
            ratio1_1  := Round(ratio,   3)
            ratio3_2  := Round(2*ratio, 3)
            ratio4_3  := Round(3*ratio, 3)
            ratio16_9 := Round(9*ratio, 3)
            
            if (ShowMeasuresAsToolTip) {
                ToolTip, Grid Measures:`r`nX: %WinX%`, Y: %WinY% `r`nW: %WinW%`, H: %WinH% `r`nDiagonal: %dist%`r`nRatio: %ratio1_1%:1`, %ratio3_2%:2`, %ratio4_3%:3`, %ratio16_9%:9, %ShowMeasuresToolTip_X%, %ShowMeasuresToolTip_Y%
            } else
                Traytip Grid Measures, X: %WinX%`, Y: %WinY% `r`nW: %WinW%`, H: %WinH% `r`nDiagonal: %dist%`r`nRatio: %ratio1_1%:1`, %ratio3_2%:2`, %ratio4_3%:3`, %ratio16_9%:9, 100,%TRAYICON_NOSOUND%

            Sleep, 10
            
            ; Refresh window under grid (required for GIMP). Workaround for WinSet, Redraw,, ahk_id %curwin_id% (which didn't work)
            DllCall("RedrawWindow", "Uint",curwin_id , "Uint",0, "Uint",0, "Uint",0x81)    ; Workaround for WinSet, Redraw,, ahk_id %curwin_id% (didn't work for Gimp)

            KeyToggle = 0
        }
        Sleep, 20
    }

    ; remove grid lines
    Loop, 12
        Gui, %A_Index%: Cancel

    DllCall("RedrawWindow", "Uint",curwin_id , "Uint",0, "Uint",0, "Uint",0x81)    ; Workaround for WinSet, Redraw,, ahk_id %curwin_id% (didn't work for Gimp)

    ; save (new) tooltip position
    ; there seems no way to filter for our own tooltip, so we recognize it by height. Ours has 68 or 80 pixels.
    WinGetPos, WX, WY, WW, WH, ahk_class tooltips_class32
    ;MsgBox,%WH%
    if (DrawGridShowDistance AND ShowMeasuresAsToolTip AND (WH = 68 OR WH = 80))
    {
        WinGetPos, WX, WY, WW, WH, ahk_class tooltips_class32
        ShowMeasuresToolTip_X = %WX%
        ShowMeasuresToolTip_Y = %WY%
        IniWrite, %ShowMeasuresTooltip_X%,     KDE_Mover-Sizer.ini, Special, ShowMeasuresToolTip_X
        IniWrite, %ShowMeasuresTooltip_Y%,     KDE_Mover-Sizer.ini, Special, ShowMeasuresToolTip_Y
    }

    DisableGridButtonHotkey()    ; Disable catcher for %DrawGridOverlay_Mouse%

    Hotkey, Escape,  Off
    Traytip 
    ToolTip

    SetMouseCursorDefault()
    return


; ***************************************************************************************
; *************  ACTION: Do colour sampler, end with DrawGridButton or ESC **************
; ***************************************************************************************
; Colour Sampler: shows RGB+HSV colour of pixel(s) under cursor as tooltip or balloon (configurable)
;
; Keys:
; - Right mousebutton: copies colour to clipboard
; - ESC: abort
; - Control/Shift: change size of averaging area: get colour average of 3x3, 5x5 and 7x7 pixels around cursor

DoColourSampler()
{
    global ShowMeasuresAsToolTip, DrawGridOverlay_Mouse, FreezeSampler_Mouse

    SetMouseCursorCross()
    CatchGridButtonHotkey()   ; Catch %DrawGridOverlay_Mouse% mouse button and don't pass it to underlying app
    FreezeSamplerPosition := GetKeyState( FreezeSampler_Mouse ,"P")

    Loop
    {
        MouseGetPos, MXl, MYl
        KCtrl_last  := GetKeyState("Control","P")
        KShift_last := GetKeyState("Shift","P")

        Loop        ; wait until mouse moved or keys were pressed/released
        {
            MouseGetPos,MX,MY
            if ( MXl != MX or MYl != MY or GetKeyState(DrawGridOverlay_Mouse,"P") or GetKeyState("Escape","P") )
                break
            if ( GetKeyState("Control","P") != KCtrl_last or GetKeyState("Shift","P") != KShift_last or GetKeyState(FreezeSampler_Mouse,"P"))
                break
            Sleep, 20
        }
        if ( GetKeyState(DrawGridOverlay_Mouse,"P") or GetKeyState("Escape","P") )
            break

        AvgSize := 0
        if ( GetKeyState("Control","P") )
            AvgSize += 1
        if ( GetKeyState("Shift","P") )
            AvgSize += 2
            
        FreezeSamplerPosition := FreezeSamplerPosition OR GetKeyState(FreezeSampler_Mouse,"P")

        if ( NOT FreezeSamplerPosition )
           MouseGetPos, PosX, PosY
        
        mycolour := getAvgPixelGetColor( PosX, PosY, AvgSize )
        
        ; split color to RGB and convert RGB to HSV
        ;
        cR := (mycolour>>16) & 255
        cG := (mycolour>>8) & 255
        cB := mycolour & 255
        cH := 0
        cS := 0
        cMin := min(min(cR, cG), cB)
        cMax := max(max(cR, cG), cB)
        cChr := cMax - cMin

        if (cChr != 0) {
            if (cR = cMax) {
                cH := (cG - cB) / cChr
                if (cH < 0)
                    cH := cH + 6
            } else if (cG = cMax)
                cH := ((cB - cR) / cChr) + 2
            else
                cH := ((cR - cG) / cChr) + 4
            cH := cH * 60
            cS := cChr / cMax
        }
        cV := cMax / 2.55

        SetFormat, Integer, hex
        mycolour += 0
        mycolourhex := mycolour . ""
        SetFormat, Integer, d
        StringRight, mycolourhex, mycolourhex, StrLen(mycolourhex)-2
        mycolourhex := "00000000" . mycolourhex
        StringRight, mycolourhex, mycolourhex, 6

        str := "RGB: #" . mycolourhex . "`r`nR: " cR " G: " cG " B: " cB "`r`nH: " Round(cH) " S: " Round(cS*100) " V: " Round(cV)
        w := AvgSize*2 +1
        if ( ShowMeasuresAsToolTip ) {
            ToolTip Colour Sampler: (%w%x%w% pixel)`r`n%str%, % (PosX+1), % (PosY+1)
        } else
            Traytip Colour Sampler (%w%x%w% pixel), %str%, 100,%TRAYICON_NOSOUND%
        Sleep, 20
    }

    if GetKeyState(DrawGridOverlay_Mouse,"P")
        clipboard := "#" . mycolourhex

    DisableGridButtonHotkey()    ; Disable catcher for GridButton 

    TrayTip
    ToolTip
    SetMouseCursorDefault()
    return
}

; helper function for DoColourSampler: gets the average pixel colour around MX/MY
; avg=0: 1x1 (single pixel), avg=1: 3x3 (9px), avg=2: 5x5 (25px), avg=3: 7x7 (49px), ...
getAvgPixelGetColor( MX, MY, avg )
{
    cR := 0
    cG := 0
    cB := 0

    Loop % (avg*2+1)
    {
        l = %A_Index%
        Loop % (avg*2+1)
        {
            m = %A_Index%
            PixelGetColor, mycolour, MX-avg+m-1, MY-avg+l-1, Slow|RGB
            cR := cR + ((mycolour>>16) & 255)
            cG := cG + ((mycolour>>8) & 255)
            cB := cB + (mycolour & 255)
        }
    }
    n := ( avg*2+1 ) * ( avg*2+1 )
    r := ((cR/n)<<16 | (cG/n)<<8 | (cB/n))
    return r
}

; *******************************************************************************************************************************
; *************  ACTION: Send scroll events to window under mouse cursor, even if window is not active (shimanov, scoox) ********
; *******************************************************************************************************************************
DoFocuslessScrollUp:
    If CheckIsWindowInList(WindowIgnoreList, WindowMatchStr) {
        SendEvent {Blind}{WheelUp}
        return
    }
    MouseGetPos, m_x, m_y, WinID, CtrlHnd, 3
    If (CtrlHnd = "")
        CtrlHnd := WinID

    FocuslessScroll( WM_MOUSEWHEEL, m_x, m_y, CtrlHnd, WHEEL_DELTA )
    return
DoFocuslessScrollDown:
    If CheckIsWindowInList(WindowIgnoreList, WindowMatchStr) {
        SendEvent {Blind}{WheelDown}
        return
    }
    MouseGetPos, m_x, m_y, WinID, CtrlHnd, 3
    If (CtrlHnd = "")
        CtrlHnd := WinID

    FocuslessScroll( WM_MOUSEWHEEL, m_x, m_y, CtrlHnd, -WHEEL_DELTA )
    return

; https://learn.microsoft.com/windows/win32/inputdev/wm-mousewheel
; https://learn.microsoft.com/windows/win32/inputdev/wm-mousehwheel
FocuslessScroll(WMid, MouseX, MouseY, CtrlHnd, Scrollstep)
{
    ; limit to multiple of WHEEL_DELTA(120)
    if Scrollstep > 32760
        Scrollstep := 32760
    if Scrollstep < -32760
        Scrollstep := -32760
    wParam := Scrollstep << 16
    If(GetKeyState("Shift","P"))
        wParam |= 0x4
    If(GetKeyState("Ctrl","P"))
        wParam |= 0x8
    PostMessage, WMid, wParam, ((MouseY << 16) | (MouseX &0xFFFF)),, ahk_id %CtrlHnd%
}


; ********************************************************************
; *********** ACTION: Drag Scroll with Middle Mouse button ***********
; ********************************************************************
; We use WM_MOUSEWHEEL for scrolling, which allows finer steps than sending WheelUp/Down.
; However, some applications (notepad, notepad++, ...) only react on full increments/multiples of 120;
; if they get anything else, mouse wheel will not react immediately anymore.
; And when scrolling, they have the same spacing as a normal Send,WheelUp/Down events.
; -> use DragScrollFullScrollStepWindowList to define which windows want that
;
; Also, there are some applications (mostly Windows' new ApplicationFramework-Apps) which don't listen to WM_MOUSEWHEEL at all
; For all of those, we could use Send WheelUp/Down instead of PostMessage WM_MOUSEWHEEL, but for now we stay with WM_MOUSEWHEEL:
; - For heavy screen refreshes, WM_MOUSEWHEEL did feel faster than SendEvent{WheelUp/Down}. Didn't measure it though.
; - SendEvent{} requires the Window to be active (especially important for early Windows versions<=7)

DoDragScroll:
    If CheckIsWindowInList(DragScrollWindowIgnoreList, WindowMatchStr)
    {
        SendEvent {Blind}{%DragScroll_Mouse% Down}
        KeyWait %DragScroll_Mouse%, U
        SendEvent {Blind}{%DragScroll_Mouse% Up}
        return
    }

    Gosub, OnDoubleKey_Disable

    Hotkey, *%DragScroll_HorizKey%, DoNothing, On
    
    MouseGetPos,,, MBWinID, MBCtrlHnd, 3
    If ( MBCtrlHnd = "" )
        MBCtrlHnd := MBWinID

    If BringWindowToFront
        WinActivate, ahk_id %MBWinID%

    DragScrollWindowWantsFullStepIncrement := CheckIsWindowInList(DragScrollFullScrollStepWindowList, WindowMatchStr)
    
    DragScrollXDelta         := 0   ; X distance of mouse movement since last call to DragScrollHandler (only used inside hook, but reset on each round)
    DragScrollYDelta         := 0   ; Y distance of mouse movement since last call to DragScrollHandler (only used inside hook, but reset on each round)
    DragScrollYDeltaIncr     := DragScrollWindowWantsFullStepIncrement ? DragScrollSpeedDivider : 1   ; Minimum pixel distance before DragScrollHandler is called after drag scrolling has started
    DragScrollXDeltaIncr     := DragScrollWindowWantsFullStepIncrement ? DragScrollSpeedDivider : 4   ; minimum >1: increase the chance of starting a Y-Scroll 
    DragScrollMouseHasMoved  := 0   ; True once a wheel message was sent
    DragScrollIsRunning      := 0   ; True while single-shot timer function "DragScroll" is active. Prevents calling concurrently
    DragScrollState          := 0   ; 0:initial state to determine direction, 1:scroll vertical (y-axis), 2:scroll horizontal (x-axis)
    DragScrollQPCus(1) ; reset timer
    ;MButtonHistory := ""

    MouseGetPos, DragScrollX, DragScrollY    ; If hook is fast, reference mouse cursor position needs to be initialized before enabling hook
    
    Hook := DllCall("SetWindowsHookEx", "Int",14, "Ptr",DragScrollMouseHookAddr
                   ,"Ptr",DllCall("GetModuleHandle", "Ptr",0, "Ptr"), "UInt",0, "Ptr") ; Hook on WH_MOUSE_LL (tnx to Rohwedder for the Hook idea&stuff)

    Sleep,3 ; mouse cursor was sometimes off by 1 pixel, so wait until any potential pending MOVE messages are handled
    MouseGetPos, DragScrollX, DragScrollY

    KeyWait %DragScroll_Mouse%, U

    DllCall("UnhookWindowsHookEx", "Uint",Hook)
    Sleep,2  ; Allow handler thread to finish before we cleanup here

    ;MButtonHistory := MButtonHistory . " Done:HasMoved=" DragScrollMouseHasMoved
    ; If WM_MOVEd (and turned it into WHEEL), do nothing. If mouse was not moved, send simple click (Down+Up) for application's default behaviour
    if ( DragScrollMouseHasMoved = 0 )
        SendEvent {Blind}{%DragScroll_Mouse%}

    Gosub, OnDoubleKey_Enable
    ;Tooltip, % MButtonHistory
    Hotkey, *%DragScroll_HorizKey%, Off
    
    return

; We don't want automatic DragScroll Up events. We create all related Up events (if required) in DoDragScroll using KeyWait
; -> AHK's behaviour changes after 1.1.26, so these newer versions would require a different solution (which I haven't figured out yet)
DoDragScrollUp:
    return

; This is the hook/callback, registered at DragScrollMouseHookAddr
; Calls DragScrollHandler if mouse moved for at least DragScrollYDelta and at max every DragScrollMinUpdateInterval_us
;   https://learn.microsoft.com/windows/win32/winmsg/lowlevelmouseproc
;   https://learn.microsoft.com/windows/win32/api/winuser/ns-winuser-msllhookstruct
;   https://learn.microsoft.com/windows/win32/inputdev/wm-mousemove
DragScrollMouseHook(nCode, wParam, lParam) {
    Global DragScrollMouseMove, DragScrollX,DragScrollY, DragScrollIsRunning, DragScrollXDelta,DragScrollYDelta, DragScrollXDeltaIncr,DragScrollYDeltaIncr
         , DragScrollMinUpdateInterval_us, DragScrollIntervalDirectionChange_us, DragScrollMouseHasMoved, MBwmID, DragScrollState  ; , MButtonHistory

    If (nCode >= 0 AND wParam = 0x0200)
    { ; WM_MOUSEMOVE = 0x0200
        xdelta := -NumGet(lParam+0,0, "Int") + DragScrollX ; reverse direction for x-scroll
        ydelta := NumGet(lParam+0,4, "Int") - DragScrollY
        DragScrollXDelta += xdelta    ; MouseX movement in per-monitor-aware screen coordinates
        DragScrollYDelta += ydelta    ; MouseY movement in per-monitor-aware screen coordinates

        ;Tooltip, % "X/Y:" DragScrollX "/" DragScrollY " delta:" xdelta "/" ydelta " DsXyDelta:" DragScrollXDelta "/" DragScrollYDelta " State:" DragScrollState
        ;           . " DSMouseMove:" DragScrollMouseMove "  MBwmID:" MBwmID ; "`n" MButtonHistory

        If (DragScrollState != 0 AND DragScrollQPCus() > DragScrollIntervalDirectionChange_us)       ; allow change of direction when mouse was resting in place
            DragScrollState = 0

        If (DragScrollState = 0 AND (ydelta != 0 OR xdelta != 0)) {
            If ((abs(DragScrollXDelta) >= DragScrollXDeltaIncr OR abs(DragScrollYDelta) >= DragScrollYDeltaIncr) AND DragScrollQPCus() > DragScrollMinUpdateInterval_us)
            {
                ;if DragScrollMouseHasMoved = 0  ; switch from initial to normal minimum distance
                ;    DragScrollYDeltaIncr := DragScrollYDeltaIncr2
                if (4* abs(DragScrollYDelta) >= abs(DragScrollXDelta))  ; increase the chance of starting a Y-Scroll 
                    DragScrollState = 1
                else
                    DragScrollState = 2
            }
        }
        if (DragScrollIsRunning = 0 AND DragScrollState = 1 AND ydelta != 0 AND abs(DragScrollYDelta) >= DragScrollYDeltaIncr AND DragScrollQPCus() > DragScrollMinUpdateInterval_us) {
            DragScrollIsRunning := 1
            DragScrollMouseMove := DragScrollYDelta //DragScrollYDeltaIncr *DragScrollYDeltaIncr  ; "floor" to multiples of delta increment
            , DragScrollYDelta  -= DragScrollMouseMove
            , DragScrollXDelta  := 0
            , DragScrollQPCus(1)
            , MBwmID := WM_MOUSEWHEEL
            SetTimer, DragScrollHandler, -1
        }
        if (DragScrollIsRunning = 0 AND DragScrollState = 2 AND xdelta != 0 AND abs(DragScrollXDelta) >= DragScrollXDeltaIncr AND DragScrollQPCus() > DragScrollMinUpdateInterval_us) {
            DragScrollIsRunning := 1
            DragScrollMouseMove := DragScrollXDelta //DragScrollXDeltaIncr *DragScrollXDeltaIncr  ; "floor" to multiples of delta increment
            , DragScrollXDelta  -= DragScrollMouseMove
            , DragScrollYDelta  := 0
            , DragScrollQPCus(1)
            , MBwmID := WM_MOUSEHWHEEL
            SetTimer, DragScrollHandler, -1
        }
        Return, 1
    }
    Return, DllCall("CallNextHookEx", "UInt",0, "Int",nCode, "UInt",wParam, "UInt",lParam)
}

; Scroll-Handler called by Hook as separate thread
; Using MouseClick resulted in occasional MButtons getting stuck. Thought this would only happen for SendMode Input,
; but this also happened a few times on SendMode Event -> stay with PostMessage
; FastAccel: a(x-50+1/(2a))^2+50-1/(4a)  (for b=MinMouseSpeed = 50)  -> not good. jumps if called in irregular intervals
; a(x-b)+b
DragScrollHandler:
    ;MBwmID := WM_MOUSEWHEEL
    ;If GetKeyState(DragScroll_HorizKey, "P")
    ;{
    ;    MBwmID := WM_MOUSEHWHEEL
    ;    DragScrollMouseMove *= -1
    ;}
    If DragScrollInvertScrollDirection
        DragScrollMouseMove *= -1
    If ( abs( DragScrollMouseMove ) < DragScrollMinMousespeedForFastAccel )
        scrollOffset := -WHEEL_DELTA * DragScrollMouseMove //DragScrollSpeedDivider
    Else {
        a := DragScrollFastAccelMultiplier
      , b := DragScrollMinMousespeedForFastAccel
        dsDelta := a*(abs(DragScrollMouseMove) - b) +b
        If DragScrollMouseMove > 0
            dsDelta *= -1
        ;Tooltip, % "a:" a " b:" b " dsDelta:" dsDelta " scrollOffset:" scrollOffset
        scrollOffset := DragScrollWindowWantsFullStepIncrement ? WHEEL_DELTA * round(dsDelta //DragScrollSpeedDivider) 
                                                        :  round(WHEEL_DELTA *       dsDelta //DragScrollSpeedDivider)
    }
    ;Tooltip, % "X/Y:" DragScrollX "/" DragScrollY " MBwmID:" MBwmID " DragScrollMouseMove:" DragScrollMouseMove " scrollOffset:" scrollOffset ; "`n" MButtonHistory
    FocuslessScroll( MBwmID, DragScrollX, DragScrollY, MBCtrlHnd, scrollOffset )

    DragScrollMouseHasMoved := 1
    DragScrollIsRunning := 0
    Return

; qpc(1): start counter. qpc() -> returns delta to last qpc(1)-call in microseconds
DragScrollQPCus(R := 0) {
    static P := 0, F2 := 0, Q := DllCall("QueryPerformanceFrequency", "Int64P",F2), F := F2 // 1000000
    return !DllCall("QueryPerformanceCounter", "Int64P",Q) + (R ? (P := Q) // F : (Q - P) // F) 
}


; ****************************************************************************************************************
; *************  ACTION Helper: Quickly position and resize window on edge/grid during Move/Resize ***************
; ****************************************************************************************************************

QuickPositionWindowOnEdge(MouseX,MouseY, ByRef X2, ByRef Y2, ByRef W2, ByRef H2, WinOffX, WinOffY, WinOffW, WinOffH)
{
    ; Resize&Snapping Areas:
    ; Off   X,Y  W,H  QkSize X,Y    W,H  Off_l
    ;  0    0     1/8   =[1]  [0]     [1]   1
    ;  1/20 0     1/4   =[2]  [0]     [2]   2
    ;  2/20 0     1/3   =[3]  [0]     [3]   3
    ;  3/20 0     0.382 =[4]  [0]     [4]   4
    ;  4/20 0     1/2   =[5]  [0]     [5]   5
    ;  5/20 0     0.618       [0]   1-[4]   6
    ;  6/20 0     2/3         [0]   1-[3]   7
    ;  7/20 0     3/4         [0]   1-[2]   8
    ;  8/20 0     7/8         [0]   1-[1]   9
    ;  9/20 0     1           [0]   1-[0]  10
    ; 10/20 0     1         1-W,H   1-[0]  10
    ; 11/20 1/8   7/8       1-W,H   1-[1]   9
    ; 12/20 1/4   3/4       1-W,H   1-[2]   8
    ; 13/20 1/3   2/3       1-W,H   1-[3]   7
    ; 14/20 0.382 0.618     1-W,H   1-[4]   6
    ; 15/20 1/2   1/2       1-W,H     [5]   5
    ; 16/20 0.618 0.382     1-W,H     [4]   4
    ; 17/20 2/3   1/3       1-W,H     [3]   3
    ; 18/20 3/4   1/4       1-W,H     [2]   2
    ; 19/20 7/8   1/8       1-W,H     [1]   1

    static QuickSize0 := 0
    , QuickSize1 := 1/8
    , QuickSize2 := 1/4
    , QuickSize3 := 1/3
    , QuickSize4 := 0.382
    , QuickSize5 := 1/2

    ; Center: (at 7/16 <= .. < 9/16)
    ; Off X+Y  X=Y, W=H
    ;  outer:       1
    ;  middle:      0.66
    ;  inner:       0.333

    GetCurrentScreenBorders(MouseX, MouseY, scrLeft, scrRight, scrTop, scrBottom)
    
    ; Mouse must be inside borders -> skip taskbar, DPI errors, ...
    if (MouseX < scrLeft)
        MouseX := scrLeft
    if (MouseX >= scrRight)
        MouseX := scrRight -1
    if (MouseY < scrTop)
        MouseY := scrTop
    if (MouseY >= scrBottom)
        MouseY := scrBottom -1
    
    scrWidth  := scrRight - scrLeft
    scrHeight := scrBottom - scrTop

    WinCenterX := MouseX - scrLeft
    WinCenterY := MouseY - scrTop
    
    OffX := Floor( (20 * WinCenterX) / scrWidth)  ; floor divide to obtain OffX 0..19
    OffY := Floor( (20 * WinCenterY) / scrHeight) ; floor divide to obtain OffY 0..19
    
    OffX_l := OffX + 1
    OffY_l := OffY + 1
    if ( OffX >= 10 )
        OffX_l := 20 - OffX
    if ( OffY >= 10 )
        OffY_l := 20 - OffY

    M8mOffX_l := 10 - OffX_l
    M8mOffY_l := 10 - OffY_l
    
    if (     abs(WinCenterX - scrWidth /2) < scrWidth /16*0.33  
         AND abs(WinCenterY - scrHeight/2) < scrHeight/16*0.33  )            ; is the inner center
    { 
        X2 := scrLeft + 0.33 * scrWidth
        Y2 := scrTop  + 0.33 * scrHeight
        W2 := scrWidth  * 0.33
        H2 := scrHeight * 0.33
    }
    else if (     abs(WinCenterX - scrWidth /2) < scrWidth /16*0.66  
              AND abs(WinCenterY - scrHeight/2) < scrHeight/16*0.66  )       ; is the middle center
    {
        X2 := scrLeft + 0.25 * scrWidth
        Y2 := scrTop  + 0.25 * scrHeight
        W2 := scrWidth  * 0.5
        H2 := scrHeight * 0.5
    }
    else if (     abs(WinCenterX - scrWidth /2) < scrWidth /16*1 
              AND abs(WinCenterY - scrHeight/2) < scrHeight/16*1  )       ; is the outer center
    {
        X2 := scrLeft + 0.382*0.382 * scrWidth
        Y2 := scrTop  + 0.382*0.382 * scrHeight
        W2 := scrWidth  * ( 1 - 2*0.382*0.382)
        H2 := scrHeight * ( 1 - 2*0.382*0.382)
    }
    else                                                                 ; is one of the outer squares
    {
        if ( OffX_l <= 5 )
            W2 := scrWidth * QuickSize%OffX_l%
        else
            W2 := scrWidth * (1 - QuickSize%M8mOffX_l%)
            
        if ( OffX < 10)
            X2 := scrLeft
        else
            X2 := scrLeft +  scrWidth - W2

        if ( OffY_l <= 5 )
            H2 := scrHeight * QuickSize%OffY_l%
        else
            H2 := scrHeight * (1 - QuickSize%M8mOffY_l%)
            
        if ( OffY < 10)
            Y2 := scrTop
        else
            Y2 := scrTop +  scrHeight - H2
    }
    
    ; extend coordinates to return the extended window position and size
    X2 := X2 + WinOffX
    Y2 := Y2 + WinOffY
    W2 := W2 + WinOffW
    H2 := H2 + WinOffH
}


; *******************************************************
; *************  General Helper Functions ***************
; *******************************************************

; get current screen boarders for monitor where mouse cursor is
GetCurrentScreenBorders(Mouse_X, Mouse_Y, ByRef CurrentScreenLeft, ByRef CurrentScreenRight, ByRef CurrentScreenTop, ByRef CurrentScreenBottom)
{
    ; AHK or (more probably) Windows has a bug that there might be a pixel offset of Mouse vs Monitor when using multimonitor setup with different DPI settings
    ; Also, when moving a SYSTEM_AWARE window across monitor, mouse pointer may still return once in old DPI coordinates (which also results in an impossible position)
    ; -> return previous screen borders instead to avoid misplaced windows
    static LastScreenLeft   := 0, LastScreenRight  := 0, LastScreenTop    := 0,  LastScreenBottom := 0
    
    found := 0
    ; get current screen boarders for snapping, do this within the loop to allow snapping on all monitors without releasing button
    SysGet, MonitorCount, MonitorCount
    Loop,  %MonitorCount%
    {
        SysGet, MonitorWorkArea, MonitorWorkArea, %A_Index%

        if (Mouse_X >= MonitorWorkAreaLeft) AND (Mouse_X <= MonitorWorkAreaRight) AND (Mouse_Y >= MonitorWorkAreaTop) AND (Mouse_Y <= MonitorWorkAreaBottom)
        {
            CurrentScreenLeft   := LastScreenLeft   := MonitorWorkAreaLeft
            CurrentScreenRight  := LastScreenRight  := MonitorWorkAreaRight
            CurrentScreenTop    := LastScreenTop    := MonitorWorkAreaTop
            CurrentScreenBottom := LastScreenBottom := MonitorWorkAreaBottom
            found := 1
        }
    }
    if found = 0
    {
        CurrentScreenLeft   := LastScreenLeft
        CurrentScreenRight  := LastScreenRight
        CurrentScreenTop    := LastScreenTop
        CurrentScreenBottom := LastScreenBottom
    }
}

; **********************************************************
; *** DPI Awareness stuff (required for borderless snapping)
; **********************************************************
;
; In short: some functions require Autohotkey to use a per-monitor-aware DPI context to work correctly.
; Then again, we need to match Autohotkey's DPI Awareness Context to the context of the window we want to control. What a mess..
;
;   ThreadDpiAwarenessContext = -3 (DPI_AWARENESS_CONTEXT_PER_MONITOR_AWARE):
;      + required for Snap to use correct screenborder on screens with DPI != 96 DPI
;      + correct window size spanning two monitors with different DPIs, but only for apps that support per-monitor-dpi-awareness
;      - wrong window size spanning two monitors with different DPIs for apps that /don't/ support per-monitor-dpi-awareness
;   Default ThreadDpiAwarenessContext = -2 (DPI_AWARENESS_CONTEXT_SYSTEM_AWARE):
;      - screenborders, are completely off (wrong offset, as DwmGetWindowAttribute returns physical coordinates for system-aware apps)
;      - wrong window size spanning two monitors with different DPIs, but only for apps that /do/ use per-monitor-dpi-awareness
;      + correct window size spanning two monitors with different DPIs for apps that /don't/ use per-monitor-dpi-awareness
;
; -> (-3) is only required when using borderless snapping. when snapping with borders, we don't care.
;    (-3) is only available starting from Win 10.0.14393 (Windows 10 build 14393, aka version 1607)
;
;  Test examples: UNAWARE: tightvnc, SYSTEM_AWARE: notepad++, PER_MONITOR_AWARE: Totalcommander, conhost, notepad
;
;  https://www.autohotkey.com/boards/viewtopic.php?f=82&t=118228
;  https://learn.microsoft.com/en-us/windows/win32/hidpi/dpi-awareness-context
;  Idea and some code from KaFu, just_me, jballi and Descolada for DPI Scaling stuff (https://www.autohotkey.com/boards/viewtopic.php?t=121040)
;
; DPI_AWARENESS_CONTEXT_UNAWARE := -1
; DPI_AWARENESS_CONTEXT_SYSTEM_AWARE := -2
; DPI_AWARENESS_CONTEXT_PER_MONITOR_AWARE := -3
; DPI_AWARENESS_CONTEXT_PER_MONITOR_AWARE_V2 := -4
; DPI_AWARENESS_CONTEXT_UNAWARE_GDISCALED := -5
;  https://learn.microsoft.com/en-us/windows/win32/api/windef/ne-windef-dpi_awareness
; DPI_AWARENESS_INVALID := -1
; DPI_AWARENESS_UNAWARE := 0
; DPI_AWARENESS_SYSTEM_AWARE := 1
; DPI_AWARENESS_PER_MONITOR_AWARE := 2

; AHK default is DPI_AWARENESS_CONTEXT_SYSTEM_AWARE (-2), but for most stuff, we need it to be MONITOR_AWARE by default
; set KDE Mover-Sizer's default DPI awareness to PER_MONITOR
; [return] old DPI awareness context
SetDefaultDpiAwarenessContext()
{
    return, DllCall("SetThreadDpiAwarenessContext", "Int",DPI_AWARENESS_CONTEXT_PER_MONITOR_AWARE, "Int")
}
; gets actual DPI awareness of specific window
GetWindowDpiAwareness(hWindow)
{
    wndDpiAwarenessCtx := DllCall("GetWindowDpiAwarenessContext", "Ptr",hWindow, "Int")
    return, DllCall("GetAwarenessFromDpiAwarenessContext", "Int",wndDpiAwarenessCtx, "Int")
}
; Gets the (current) DPI for the specified window
; Only useful for DPI_AWARENESS_PER_MONITOR_AWARE windows.
; All others just return 96 (they don't return A_ScreeDPI!)
; (For us, that's OK, as adaptive scaling of the window size is only required for MONITOR_AWARE windows anyway
;  SYSTEM_AWARE windows scale automatically as part of WinMove)
; [return] DPI of window
GetWindowDpi(hWindow)
{
    return, DllCall("GetDpiForWindow", "ptr",hWindow, "uint")
}
; set DPI awareness context of AHK to match DPI awareness of target window
SetWindowSpecificDpiAwarenessContext(wndDpiAwareness)
{
    If (wndDpiAwareness = DPI_AWARENESS_SYSTEM_AWARE || wndDpiAwareness = DPI_AWARENESS_UNAWARE)
        DllCall("SetThreadDpiAwarenessContext", "Int",DPI_AWARENESS_CONTEXT_SYSTEM_AWARE, "Int")
}
; restore DPI awareness context of AHK (only if it was changed before to match DPI awareness of target window)
RestoreWindowSpecificDpiAwarenessContext(wndDpiAwareness)
{
    If (wndDpiAwareness = DPI_AWARENESS_SYSTEM_AWARE || wndDpiAwareness = DPI_AWARENESS_UNAWARE)
        DllCall("SetThreadDpiAwarenessContext", "Int",DPI_AWARENESS_CONTEXT_PER_MONITOR_AWARE, "Int")
}
; For ShowWindowWhenDragging = 0, we can't use GetWindowDpi as we didn't move the window yet.
; For some reason, user32.dll\MonitorFromRect does not find the correct monitor when the window spans two monitors with different DPIs
; -> We use User32.dll\MonitorFromRect with the window center instead.
; Note: MDT_EFFECTIVE_DPI only returns useful values if we are PER_MONITOR_AWARE. Otherwise, we always get 96dpi (or ScreeDPI?)
;       And MDT_RAW_DPI returns 94dpi/126dpi instead of 96/120, so can't use that either
GetMonitorDpiFromRect(X, Y, W, H) {
    static MONITOR_DEFAULTTONEAREST := 2
    static MDT_EFFECTIVE_DPI := 0
    hMon :=DllCall("User32.dll\MonitorFromPoint", "Int64",((ceil(X+W/2) & 0xFFFFFFFF) | (ceil(Y+H/2) << 32)), "UInt",MONITOR_DEFAULTTONEAREST, "Ptr")

    dpiX := dpiY := 0
    DllCall("SHcore\GetDpiForMonitor", "Ptr",hMon, "Int",MDT_EFFECTIVE_DPI, "UInt*",dpiX, "UInt*",dpiY)
    ;Tooltip, % "X Y W H: " X " " Y " " W " " H " , hMon: " hMon ", dpiX,dpiY: " dpiX "," dpiY

    ; assert(dpiX = dpiY)
    return dpiX
}

; Calculate offset to for invisible frame around window
; Unlike the Window Rect, the DWM Extended Frame Bounds are not adjusted for DPI when we are in DPI_AWARENESS_CONTEXT_SYSTEM_AWARE
;
;    Note:
;    There are some MS Windows quirks when using a multi-monitor setup with different per-monitor DPI settings:
;    Windows' MoveWin wrongly increases the window size if a window spans two screens with different DPI settings
;    and AHK's DPI Awareness context setting does not match the client window DPI awareness setting.
;    This mixup already happens when even just the invisible part of the window frame is on the other screen.
;    So we need to set the appropriate mode in AHK depending on the target window prior to using WinGetPos/WinMove/...
;    More: https://mariusbancila.ro/blog/2021/05/19/how-to-build-high-dpi-aware-native-desktop-applications/
;    
;    Then again, DWMWA_EXTENDED_FRAME_BOUNDS always returns (unscaled) screen coordinates,
;    so we get invalid offsets for DPI_AWARENESS_CONTEXT_SYSTEM_AWARE and DPI_AWARENESS_SYSTEM_AWARE client windows
;    It works however for DPI_AWARENESS_SYSTEM_AWARE client windows when AHK is in DPI_AWARENESS_CONTEXT_PER_MONITOR_AWARE mode
;
;    --> so we have to get offsets before adjusting the DPI context inside the Move or Resize actions
;
; In Windows Vista and later, the resize border around windows got mostly invisible (left/right/bottom).
; But Window Rect (WinGetPos) still includes the area occupied by the (now invisible) resize frame, leaving some strange space.
; The offset values by WinGetOffset contain the difference between the outside of the frame to the actually shown window.
;
; X/Y/W/H + OffX/Y/W/H = the coordinates that must be set e.g. in WinMove to enlarge the window correctly
; X/Y/W/H - OffX/Y/W/H = the visible part of the (smaller) currently shown window (without the extended frame border)
;
WinGetOffset(ByRef OffX, ByRef OffY, ByRef OffW, ByRef OffH, hWindow)
{
    static DWMWA_EXTENDED_FRAME_BOUNDS := 9
    static S_OK := 0
    OffX := OffY := OffW := OffH := 0
    VarSetCapacity( rect, 24, 0 )
    dwmrc := DllCall("dwmapi\DwmGetWindowAttribute", "Ptr",hWindow, "UInt",DWMWA_EXTENDED_FRAME_BOUNDS, "Ptr",&rect, "UInt",16, "UInt")

    if (dwmrc = S_OK)
    {
        x1 := left := NumGet( rect, 0, "Int" ) 
        y1 := top  := NumGet( rect, 4, "Int" )
        right      := NumGet( rect, 8, "Int" )
        bottom     := NumGet( rect, 12, "Int" )
        w1 := right  - left
        h1 := bottom - top
        
        WinGetPos, X, Y, W, H, ahk_id %hWindow%

        OffX := X - x1
        OffY := Y - y1
        OffW := W - w1
        OffH := H - h1
    }
    return
}

; Draw rectangular frame on screen - set attributes
DrawRectFrame_Prepare()
{
    global DrawGridColour,DrawGridGUIOptions
    Loop, 4 {
        Gui, %A_Index%: -Caption +ToolWindow +AlwaysOnTOp +OwnDialogs -DPIScale %DrawGridGUIOptions%
        Gui, %A_Index%: Color, %DrawGridColour%
    }
}
; Draw rectangular frame on screen - do the actual drawing
DrawRectFrame_Show( X, Y, W, H )
{
    global DrawGridWidth
    X3 := X -2  ; +KDE_WinOffFrameX
    Y3 := Y -2  ; +KDE_WinOffFrameY
    W3 := W     ; +KDE_WinOffFrameW
    H3 := H     ; +KDE_WinOffFrameH
    
    Gui, 1: Show, % "x" X3    " y" Y3    " w" DrawGridWidth+1 " h" H3     " NoActivate"
    Gui, 2: Show, % "x" X3    " y" Y3    " w" W3              " h" DrawGridWidth+1 " NoActivate"
    Gui, 3: Show, % "x" X3+W3 " y" Y3    " w" DrawGridWidth+1 " h" H3     " NoActivate"
    Gui, 4: Show, % "x" X3    " y" Y3+H3 " w" W3              " h" DrawGridWidth+1 " NoActivate"
}
; Draw rectangular frame on screen - hide frame
DrawRectFrame_Cancel()
{
    Loop, 4
        Gui, %A_Index%: Cancel
    ;DllCall("RedrawWindow", "Uint",curwin_id , "Uint",0, "Uint",0, "Uint",0x81)    ; Gimp-Workaround for WinSet, Redraw,, ahk_id %curwin_id% (but takes time, so don't do it here by default)
}

; WindowList[in]: a comma-separated list of windows used for lookup
; WindowMatchStr[out]: the current window match string used during lookup
; returns 1 if Window at current Mouse position is in WindowList, else 0
CheckIsWindowInList(ByRef WindowList, ByRef WindowMatchStr)
{
    MouseGetPos,,,curwin_id
    WinGet currentwinname, ProcessName, ahk_id %curwin_id%
    
    ; If running as admin, WinGet sometimes returns an empty ProcessName. Class name is ok though.
    ; To keep lookup fast, we only lookup class name for the following process names
    if (currentwinname = "" || currentwinname = "explorer.exe" || currentwinname = "ApplicationFrameHost.exe" || currentwinname = "ShellExperienceHost.exe")
    {
        WinGetClass currentwinclass, ahk_id %curwin_id%
        currentwinname := currentwinname . "/" . currentwinclass
        
        ; if we have these new windows apps, we also need the title to identify the app
        if (currentwinclass = "ApplicationFrameWindow")
        {
            WinGetTitle currentwintitle, ahk_id %curwin_id%
            currentwinname := currentwinname . "/" . currentwintitle
        }
    }
    WindowMatchStr := currentwinname . ","
    
    return InStr( WindowList, WindowMatchStr, CaseSensitive = 0 ) ? 1 : 0
}

; returns the smaller of two values
min( a, b ) {
    return (b < a) ? b : a
}
; returns the greater of two values
max( a, b ) {
    return (b > a) ? b : a
}

; functions to change the mouse cursor to cross and restore it
SetMouseCursorCross()
{
    CursorHandle := DllCall( "LoadCursor", Uint,0, Int,32515 )    ; load new cursor (32515:IDC_CROSS)
    DllCall( "SetSystemCursor", Uint,CursorHandle, Int,32512 )    ; swap IDC_ARROW with IDC_CROSS cursor
}
SetMouseCursorDefault()
{
    DllCall( "SystemParametersInfo", UInt,0x57, UInt,0, UInt,0, UInt,0 ) ; restore systems cursors
}


; save current window state to allow restore on Escape
SaveOriginalWindowState()
{
    global orig_WinID,orig_isMax, orig_WinX,orig_WinY,orig_WinW,orig_WinH

    MouseGetPos, ,,orig_WinID
    WinGet,    orig_isMax,MinMax,ahk_id %orig_WinID%
    WinGetPos, orig_WinX,orig_WinY,orig_WinW,orig_WinH,ahk_id %orig_WinID%

    ; catch Escape hotkey to block client apps taking it
    Hotkey, !Escape, On
    Hotkey, Escape,  On
}
; restore saved window state on Escape
RestoreOriginalWindowState()
{
    global orig_WinID,orig_isMax, orig_WinX,orig_WinY,orig_WinW,orig_WinH

    WinMove ahk_id %orig_WinID%,, orig_WinX,orig_WinY,orig_WinW,orig_WinH
    WinGet, current_isMax,MinMax,ahk_id %orig_WinID%
    if (current_isMax AND NOT orig_isMax)
        WinRestore, ahk_id %orig_WinID%
    if (! current_isMax AND orig_isMax)
        WinMaximize, ahk_id %orig_WinID%
}

; returns readable name for hotkey
strname( key )
{
    if (key = "!" )
        return "Alt"
    if (key = "!^" or key = "^!")
        return "Ctrl+Alt"
    if (key = "^" )
        return "Ctrl"
    if (key = "^+" )
        return "Ctrl+Shift"
    if (key = "^+" )
        return "Ctrl+Shift"
    if (key = "^#")
        return "Ctrl+LeftWin"
    if (key = "^#!")
        return "Ctrl+LWin+Alt"
    if (key = "^!+" or key = "!^+")
        return "Ctrl+Shift+Alt"
    if (key = "#")
        return "LeftWin"
    if (key = "<^>!")
        return "AltGr"
    if (key = "<^>!+")
        return "AltGr+Shift"
    if (key = "LControl & ~RAlt")
        return "AltGr"
    if (key = "LButton")
        return "Left"
    if (key = "RButton")
        return "Right"
    if (key = "MButton")
        return "Middle"
    return key
}

DisableEscapeHotkey()
{
    Hotkey, !Escape, Off
    Hotkey, Escape, Off
}

DoNothing:
    return

CatchGridButtonHotkey()
{
    global DoubleKey_Hotkey2, DrawGridOverlay_Mouse
    Hotkey, %DoubleKey_Hotkey2%, DoNothing, On
    Hotkey, %DrawGridOverlay_Mouse%, DoNothing, On
    Hotkey, ^%DrawGridOverlay_Mouse%, DoNothing, On
    Hotkey, +%DrawGridOverlay_Mouse%, DoNothing, On
    Hotkey, ^+%DrawGridOverlay_Mouse%, DoNothing, On
}
DisableGridButtonHotkey()
{
    global DrawGridOverlay_Mouse
    Hotkey, %DrawGridOverlay_Mouse%, Off
    Hotkey, ^%DrawGridOverlay_Mouse%, Off
    Hotkey, +%DrawGridOverlay_Mouse%, Off
    Hotkey, ^+%DrawGridOverlay_Mouse%, Off
    
    Gosub, InitHotkeyHandler
}

; Generic label to handle SpecialCharacters key remapping
;
SpecialCharactersLbl:
    Loop, %SpecialCharacters_NumberOfActiveHotkeys% {
        key := SpecialCharactersTrig_%A_Index%
        if (A_ThisHotkey = key) {
            char := SpecialCharactersChar_%A_Index%
            Send %char%
            return
        }
    }
    return

; NOTE: For the currently required AHK versions, there is something broken using SendEvent {Blind}:
;
;       The following hotkey does not send F9Down, only 2x F9Up:
;       (check with https://w3c.github.io/uievents/tools/key-event-viewer.html)
;^!+F9::
;    SendEvent {Blind}{F9 down}
;    KeyWait F9, U
;    SendEvent {Blind}{F9 up}
;    return
;
;       The following hotkey (with ~) sends F9 down&up alright, but sens an additional CtrlDown+CtrlUp if the Alt-key is release AFTER Control-key was released?!
;~^!+F9::
;    return


; One (static) hotkey must always be enabled - otherwise, (dynamic) hotkeys won't work for some reason
; This hotkey Ctrl+Shift+Alt+F9 does nothing and is passed on, just makes sure dynamic mouse hotkeys don't disappear
; Or remove the semicolons and use it for debugging
~^!+F9::
    ;SendEvent {Blind}{F9 down}
    ;KeyWait F9, U
    ;SendEvent {Blind}{F9 up}
    ;actWin := WinExist("A")
    ;curWin := actWin
    ;ControlGetFocus, curCtrl
    
    ;WinGetTitle, t1
    ;WinGetClass, t2
    ;WinGet, t3, ProcessName
    
    ;MsgBox, % "Title:" t1 "`r`n ahk_class:" t2 ", ahk_exe:" t3 "`r`n ClassNN:" curCtrl
    ;Clipboard := t2 " " t3 " " curCtrl

    ;KeyHistory
    ;ListVars
    ;ListLines
    return


;ProductName := "KDE Mover-Sizer"
;ProductVersion := 2.12
;ProductPublisher := "corz.org"
;ProductWebsite := "http://corz.org/windows/software/accessories/KDE-resizing-moving-for-Windows.php"
