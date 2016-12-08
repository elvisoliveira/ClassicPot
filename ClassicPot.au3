#include "SecurityConstants.au3"
#include "GDIPlus.au3"
#include "Inet.au3"
#include "File.au3"
#include "Misc.au3"
#include "String.au3"
#include "WindowsConstants.au3"
#include "GUIConstantsEx.au3"
#include "EditConstants.au3"
#include "StaticConstants.au3"
#include "ButtonConstants.au3"
#include "NomadMemory.au3"

Opt("SendKeyDownDelay", 0)
Opt("SendKeyDelay", 0)

$hppercent = IniRead("config.ini", "Percents", "HpPercent", "80")
$sppercent = IniRead("config.ini", "Percents", "SpPercent", "50")
$yggpercent = IniRead("config.ini", "Percents", "YggPercent", "20")
$deathdelay = IniRead("config.ini", "Options", "DeathDelay", "10000")
$potdelay = "5"
$window = IniRead("config.ini", "Misc", "WindowTitle", "Ragnarok")
$exe = IniRead("config.ini", "Misc", "Executable", "clragexe.exe")
$program = "[CLASS:" & $window & "]"
$hpon = IniRead("config.ini", "Misc", "HpOn", "1")
$spon = IniRead("config.ini", "Misc", "SpOn", "1")
$yggon = IniRead("config.ini", "Misc", "YggOn", "1")
$curseon = IniRead("config.ini", "Misc", "CurseOn", "1")
$deathdelayon = IniRead("config.ini", "Misc", "DeathDelayOn", "1")
$pausekeys = "`|[|]|;|'|,|.|/|\|=|-|PAUSE|HOME|END|INSERT|DELETE|PGUP|PGDN|UP|DOWN|LEFT|RIGHT"
$keybinds = "F2|F3|F4|F5|F6|F7|F8|F9"
$pausekey = IniRead("config.ini", "HotKeys", "Pause", "PAUSE")
$enterkey = "ENTER"
$hpkey = IniRead("config.ini", "HotKeys", "HpKey", "")
$spkey = IniRead("config.ini", "HotKeys", "SpKey", "")
$yggkey = IniRead("config.ini", "HotKeys", "YggKey", "F3")
$cursekey = IniRead("config.ini", "HotKeys", "CurseKey", "F4")
$hpmem = 9140448
$hpcurmem = 9140444
$spmem = 9140456
$spcurmem = 9140452
$memluk = 9410400
$firsttime = 0;

Global $paused

Func autopot()
	While WinActive($program)
		Call("ReadPause")
		Call("ReadMemory")
		Call("HpBarLabel")
		Call("Dead")
		Call("Ygg")
		Call("Curse")
		Call("Hp")
		Call("GFist")
		Call("Sp")
		Sleep($potdelay)
	WEnd
EndFunc

Func gfist()
	If $cursp = 0 Then
		Send("{" & GUICtrlRead($spkeycombo) & "}")
		Sleep(10)
		If $cursp = 0 Then
			$ibegin = TimerInit()
			While TimerDiff($ibegin) < 2000
				If $cursp > 0 Then
					Call("AutoPot")
				EndIf
				Call("ReadPause")
				Call("ReadMemory")
				Call("HpBarLabel")
				Call("Dead")
				Call("Ygg")
				Call("Curse")
				Call("Hp")
				Sleep($potdelay)
			WEnd
		EndIf
	EndIf
EndFunc

Func readpause()
	HotKeySet("{" & GUICtrlRead($pausekeycombo) & "}", "TogglePause")
EndFunc

Func dead()
	If GUICtrlRead($deathswitchon) = $gui_checked Then
		If $curhp = 1 Then
			Sleep($deathdelay)
		EndIf
	EndIf
EndFunc

Func hp()
	If GUICtrlRead($hpswitchon) = $gui_checked Then
		If ($firsttime < 1) Then
			Sleep(900)
			$firsttime = 1
		EndIf
		If (GUICtrlRead($hppercentinput) * $maxhp / 100) > $curhp Then
			Send("{" & GUICtrlRead($hpkeycombo) & "}")
		Else
			$firsttime = 0
		EndIf
	EndIf
EndFunc

Func sp()
	If GUICtrlRead($spswitchon) = $gui_checked Then
		If (GUICtrlRead($sppercentinput) * $maxsp / 100) > $cursp Then
			Send("{" & GUICtrlRead($spkeycombo) & "}")
		EndIf
	EndIf
EndFunc

Func ygg()
	If GUICtrlRead($yggswitchon) = $gui_checked Then
		If (GUICtrlRead($yggpercentinput) * $maxhp / 100) > $curhp Then
			Send("{" & GUICtrlRead($yggkeycombo) & "}")
			Sleep(50)
		EndIf
	EndIf
EndFunc

Func curse()
	If GUICtrlRead($curseswitchon) = $gui_checked Then
		If $luk > 1000 Then
			Send("{" & GUICtrlRead($cursekeycombo) & "}")
			Sleep(50)
		EndIf
	EndIf
EndFunc

Func readmemory()
	$maxhp = _memoryread($maxhpmem, $memoryopen)
	$maxsp = _memoryread($maxspmem, $memoryopen)
	$curhp = _memoryread($curhpmem, $memoryopen)
	$cursp = _memoryread($curspmem, $memoryopen)
	$luk = _memoryread($lukmem, $memoryopen)
EndFunc

Func togglepause()
	$paused = NOT $paused
	GUICtrlSetData($statuslabel, "PAUSED")
	GUICtrlSetFont($statuslabel, 12, 800, 1)
	GUICtrlSetColor($statuslabel, 16711680)
	While $paused
		Call("ReadMemory")
		Call("HpBarLabel")
		Call("ReadPause")
		Sleep(100)
	WEnd
	GUICtrlSetData($statuslabel, "RUNNING")
	GUICtrlSetFont($statuslabel, 12, 800, 1)
	GUICtrlSetColor($statuslabel, 3768320)
EndFunc

Func hpbarlabel()
	If GUICtrlRead($hpbar) <> $curhp / $maxhp * 100 Then
		GUICtrlSetData($hpbar, $curhp / $maxhp * 100)
	EndIf
	If GUICtrlRead($spbar) <> $cursp / $maxsp * 100 Then
		GUICtrlSetData($spbar, $cursp / $maxsp * 100)
	EndIf
	If GUICtrlRead($hplabel) <> $curhp & " / " & $maxhp Then
		GUICtrlSetData($hplabel, $curhp & " / " & $maxhp)
	EndIf
	If GUICtrlRead($splabel) <> $cursp & " / " & $maxsp Then
		GUICtrlSetData($splabel, $cursp & " / " & $maxsp)
	EndIf
EndFunc

Func reload()
	Run(@ScriptFullPath & " /restart")
	Exit 
EndFunc

Func terminate()
	IniWrite("config.ini", "Percents", "HpPercent", GUICtrlRead($hppercentinput))
	IniWrite("config.ini", "HotKeys", "HpKey", GUICtrlRead($hpkeycombo))
	IniWrite("config.ini", "Percents", "SpPercent", GUICtrlRead($sppercentinput))
	IniWrite("config.ini", "HotKeys", "SpKey", GUICtrlRead($spkeycombo))
	IniWrite("config.ini", "Percents", "YggPercent", GUICtrlRead($yggpercentinput))
	IniWrite("config.ini", "HotKeys", "YggKey", GUICtrlRead($yggkeycombo))
	IniWrite("config.ini", "HotKeys", "CurseKey", GUICtrlRead($cursekeycombo))
	IniWrite("config.ini", "Options", "DeathDelay", GUICtrlRead($deathinput) * 1000)
	IniWrite("config.ini", "HotKeys", "PauseKey", GUICtrlRead($pausekeycombo))
	IniWrite("config.ini", "Misc", "HpOn", GUICtrlRead($hpswitchon))
	IniWrite("config.ini", "Misc", "SpOn", GUICtrlRead($spswitchon))
	IniWrite("config.ini", "Misc", "YggOn", GUICtrlRead($yggswitchon))
	IniWrite("config.ini", "Misc", "CurseOn", GUICtrlRead($curseswitchon))
	IniWrite("config.ini", "Misc", "DeathDelayOn", GUICtrlRead($deathswitchon))
	FileDelete(@TempDir & "\Blue.bmp")
	FileDelete(@TempDir & "\White.bmp")
	FileDelete(@TempDir & "\Ygg.bmp")
	FileDelete(@TempDir & "\Water.bmp")
	FileDelete(@TempDir & "\Mainhand.bmp")
	FileDelete(@TempDir & "\Offhand.bmp")
	FileDelete(@TempDir & "\Headgear.bmp")
	FileDelete(@TempDir & "\Armor.bmp")
	Exit 
EndFunc

While 1
	If NOT ProcessExists($exe) Then
		$iv_pid = ProcessExists($exe)
		$memoryopen = "*"
		$maxhp = "*"
		$maxsp = "*"
		$curhp = "*"
		$cursp = "*"
		$luk = "*"
	Else
		$maxhpmem = $hpmem
		$maxspmem = $spmem
		$curhpmem = $hpcurmem
		$curspmem = $spcurmem
		$lukmem = $memluk
		$iv_pid = ProcessExists($exe)
		$memoryopen = _memoryopen($iv_pid)
		$maxhp = _memoryread($maxhpmem, $memoryopen)
		$maxsp = _memoryread($maxspmem, $memoryopen)
		$curhp = _memoryread($curhpmem, $memoryopen)
		$cursp = _memoryread($curspmem, $memoryopen)
		$luk = _memoryread($lukmem, $memoryopen)
	EndIf
	Opt("GUIOnEventMode", 1)
	FileInstall("images\White.bmp", @TempDir & "\White.bmp")
	FileInstall("images\Blue.bmp", @TempDir & "\Blue.bmp")
	FileInstall("images\Ygg.bmp", @TempDir & "\Ygg.bmp")
	FileInstall("images\Water.bmp", @TempDir & "\Water.bmp")
	$mainwindow = GUICreate("ClassicPot", 195, 370, -1, -1, BitXOR($gui_ss_default_gui, $ws_minimizebox))
	GUISetBkColor(16777215)
	GUISetOnEvent($gui_event_close, "Terminate")
	GUISetState()
	GUICtrlCreatePic(@TempDir & "\White.bmp", 15, 152, 24, 24)
	GUICtrlCreatePic(@TempDir & "\Blue.bmp", 15, 182, 24, 24)
	GUICtrlCreatePic(@TempDir & "\Ygg.bmp", 15, 212, 24, 24)
	GUICtrlCreatePic(@TempDir & "\Water.bmp", 15, 242, 24, 24)
	GUICtrlCreateGroup("State", 10, 5, 175, 45)
	GUICtrlCreateGroup("Status", 10, 50, 175, 80)
	GUICtrlCreateGroup("Potions", 10, 130, 175, 150)
	GUICtrlCreateGroup("Options", 10, 280, 175, 80)
	$hptxt = GUICtrlCreateLabel("HP", 15, 68)
	GUICtrlSetBkColor(-1, $gui_bkcolor_transparent)
	$sptxt = GUICtrlCreateLabel("SP", 15, 98)
	GUICtrlSetBkColor(-1, $gui_bkcolor_transparent)
	$hplabel = GUICtrlCreateLabel($curhp & " / " & $maxhp, 35, 80, 100, 20)
	GUICtrlSetBkColor(-1, $gui_bkcolor_transparent)
	$splabel = GUICtrlCreateLabel($cursp & " / " & $maxsp, 35, 110, 100, 20)
	GUICtrlSetBkColor(-1, $gui_bkcolor_transparent)
	$hpbar = GUICtrlCreateProgress(35, 70, 135, 9)
	GUICtrlSetData($hpbar, $curhp / $maxhp * 100)
	$spbar = GUICtrlCreateProgress(35, 100, 135, 9)
	GUICtrlSetData($spbar, $cursp / $maxsp * 100)
	$hpkeycombo = GUICtrlCreateCombo("F1", 45, 155, 35)
	GUICtrlSetData(-1, $keybinds, $hpkey)
	$hppercentinput = GUICtrlCreateInput($hppercent, 90, 155, 20, 21)
	$hppercentlabel = GUICtrlCreateLabel("%", 113, 158)
	$hpswitchon = GUICtrlCreateCheckbox("On", 130, 155)
	GUICtrlSetState(-1, $hpon)
	$spkeycombo = GUICtrlCreateCombo("F1", 45, 185, 35)
	GUICtrlSetData(-1, $keybinds, $spkey)
	$sppercentinput = GUICtrlCreateInput($sppercent, 90, 185, 20)
	$sppercentlabel = GUICtrlCreateLabel("%", 113, 188)
	$spswitchon = GUICtrlCreateCheckbox("On", 130, 185)
	GUICtrlSetState(-1, $spon)
	$yggkeycombo = GUICtrlCreateCombo("F1", 45, 215, 35)
	GUICtrlSetData(-1, $keybinds, $yggkey)
	$yggpercentinput = GUICtrlCreateInput($yggpercent, 90, 215, 20)
	$yggpercentlabel = GUICtrlCreateLabel("%", 113, 218)
	$yggswitchon = GUICtrlCreateCheckbox("On", 130, 215)
	GUICtrlSetState(-1, $yggon)
	$cursekeycombo = GUICtrlCreateCombo("F1", 45, 245, 35)
	GUICtrlSetData(-1, $keybinds, $cursekey)
	$cursepercentlabel = GUICtrlCreateLabel("Curse (Broken)", 90, 248)
	$curseswitchon = GUICtrlCreateCheckbox("On", 130, 245)
	GUICtrlSetState(-1, $curseon)
	$statuslabel = GUICtrlCreateLabel("", 15, 20, 160, 20)
	$deathlabel = GUICtrlCreateLabel("Death Delay", 22, 300)
	$deathinput = GUICtrlCreateInput($deathdelay / 1000, 90, 297, 20)
	$deathsecondlabel = GUICtrlCreateLabel("s", 113, 300)
	$deathswitchon = GUICtrlCreateCheckbox("On", 130, 297)
	GUICtrlSetState(-1, $deathdelayon)
	$pausekeylabel = GUICtrlCreateLabel("Pause Key", 22, 330)
	$pausekeycombo = GUICtrlCreateCombo("PAUSE", 90, 327, 60)
	GUICtrlSetData(-1, $pausekeys, $pausekey)
	While 1
		$guimsg = WinGetProcess($program)
		Switch $guimsg
			Case  - 1
				$iv_pid = ProcessExists($exe)
				$memoryopen = "*"
				$maxhp = "*"
				$maxsp = "*"
				$curhp = "*"
				$cursp = "*"
				$luk = "*"
				Call("HpBarLabel")
				If GUICtrlRead($statuslabel) <> "Waiting For Client" Then
					GUICtrlSetData($statuslabel, "Waiting For Client")
					GUICtrlSetColor($statuslabel, 16711680)
					GUICtrlSetFont($statuslabel, 12, 800, 1)
				EndIf
			Case WinGetProcess($program)
				$maxhpmem = $hpmem
				$maxspmem = $spmem
				$curhpmem = $hpcurmem
				$curspmem = $spcurmem
				$lukmem = $memluk
				$iv_pid = ProcessExists($exe)
				$memoryopen = _memoryopen($iv_pid)
				$maxhp = _memoryread($maxhpmem, $memoryopen)
				$maxsp = _memoryread($maxspmem, $memoryopen)
				$curhp = _memoryread($curhpmem, $memoryopen)
				$cursp = _memoryread($curspmem, $memoryopen)
				$luk = _memoryread($lukmem, $memoryopen)
				Call("ReadPause")
				Call("ReadMemory")
				Call("HpBarLabel")
				If GUICtrlRead($statuslabel) <> "RUNNING" Then
					GUICtrlSetData($statuslabel, "RUNNING")
					GUICtrlSetFont($statuslabel, 12, 800, 1)
					GUICtrlSetColor($statuslabel, 3768320)
				EndIf
				Call("AutoPot")
		EndSwitch
		Sleep(500)
	WEnd
	ExitLoop 
WEnd
