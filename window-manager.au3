#include <AutoItConstants.au3>
#include <MsgBoxConstants.au3>
#include <Array.au3>
#include <Math.au3>
#include <Constants.au3>
#include <WinAPI.au3>
#include <GUIConstantsEx.au3>
#include <WindowsConstants.au3>
#include <StaticConstants.au3>

; 2019.11.09
; + changed firefox/chrome width from 1426 to 1420
; + changed vlc height from 500 to 334
; 2019.12.21
; + changed WinMove() from 1055 to 700 after connecting second monitor
; 2020.06.02
; + added mozilla thunderbird
; + added $VlcWidth, $VlcHeight
; + changed WinMove() from single to staged
; 2020.06.06
; + added center browser for @UserName
; 2020.07.09
; + added calcRes()
; 2020.08.11
; + added FileZilla
; 2020.12.18
; + added YouTube exemption
; 2021.03.24
; + commit to github

Global $iFullDesktopWidth = _WinAPI_GetSystemMetrics(78)
Global $iFullDesktopHeight = _WinAPI_GetSystemMetrics(79)

Global $VlcTop = 0
Global $VlcLeft = -10
Global $VlcWidth = 960; 522; 680
Global $VlcHeight = 780; 500

Global $WebLeft = 500
Global $WebTop = 0
Global $WebWidth = 1425
Global $WebHeight = 1055

Func calcRes()
	$iFullDesktopWidth = _WinAPI_GetSystemMetrics(78)
	$iFullDesktopHeight = _WinAPI_GetSystemMetrics(79)
	If $iFullDesktopWidth > 3000 Then
		$WebLeft = 970
	Else
		$WebLeft = 500
	EndIf
	$WebWidth = $iFullDesktopWidth - $WebLeft + 6
	$WebHeight = $iFullDesktopHeight - $WebTop - 25
	If StringInStr(@UserName, "kgood") Then
		$WebLeft = $WebLeft / 2
	EndIf
EndFunc

Func onPress()
	Opt("SendKeyDelay", 0)
	Opt("SendKeyDownDelay", 0)
	Send(@YEAR & "." & @MON & "." & @MDAY & " " & @HOUR & ":" & @MIN & ":" & @SEC)
EndFunc

HotKeySet("{F6}", "onPress");

While 1
	calcRes()

	; Firefox
	If True Then
		$aList = WinList("[REGEXPTITLE:(.*Nightly|.*Mozilla Firefox|.*Mozilla Thunderbird|.*Google Chrome|.*FileZilla)]")
		$c = 0
		For $i = 1 To $aList[0][0]
			; Exempt YouTube
			if StringInStr($aList[$i][0], "YouTube") Then
				$i = $i + 1
				ContinueLoop
			EndIf

			; Detect fullscreen
			If Not BitAND(_WinAPI_GetWindowLong($aList[$i][1], $GWL_STYLE), $WS_CAPTION) Then
				ContinueLoop
			EndIf

			; Detect window states
			$aState = WinGetState($aList[$i][1])
			If BitAND($aState, 16) Then ;$WIN_STATE_MINIMIZED
				ContinueLoop
			ElseIf BitAND($aState, 32) Then ;$WIN_STATE_MAXIMIZED
				ContinueLoop
			ElseIf BitAND($aState, 2) Then ;$WIN_STATE_VISIBLE
				WinMove($aList[$i][1], "", $WebLeft - (40*$c), $WebTop, $WebWidth, $WebHeight, 1)
				$c = $c + 1
			EndIf
		Next
	EndIf

	; VLC
	If True Then
		$aList = WinList("[REGEXPTITLE:(.*VLC media player)]")
		Local $hwnds[0] = []
		ReDim $hwnds[$aList[0][0]]
		For $i = 1 To $aList[0][0]
			_ArrayPush($hwnds, $aList[$i][1])
		Next
		_ArraySort($hwnds)

		$i = 0
		For $hwnd In $hwnds
			; Detect fullscreen
			If Not BitAND(_WinAPI_GetWindowLong($hwnd, $GWL_STYLE), $WS_CAPTION) Then
				ContinueLoop
			EndIf

			; Detect window states
			$aState = WinGetState($hwnd)
			If BitAND($aState, 16) Then ;$WIN_STATE_MINIMIZED
				ContinueLoop
			ElseIf BitAND($aState, 32) Then ;$WIN_STATE_MAXIMIZED
				ContinueLoop
			ElseIf BitAND($aState, 2) Then ;$WIN_STATE_VISIBLE
				$t = $VlcTop + ($i * $VlcHeight)
				$i = $i + 1
				WinMove($hwnd, "", $VlcLeft, $t, $VlcWidth, $VlcHeight, 1)
			EndIf
		Next
	EndIf

	Sleep(100)
WEnd
