#AutoIt3Wrapper_AU3Check_Parameters=-d -w 1 -w 2 -w 3 -w 4 -w 5 -w 6

#Include <WinHttp.au3>

Opt('MustDeclareVars ', 1)

; 初始化并获取会话句柄
Global $hOpen = _WinHttpOpen()
If @error Then
	msgbox(48, "Error ", "Error initializing the usage of WinHTTP functions." & @CRLF & " Error number is" & @error)
	Exit 1
EndIf

; 关闭句柄
_WinHttpCloseHandle($hOpen)

