#include-once

Global $aEN[1]

; #FUNCTION# =============================================================================================
; Name...........: _ExtractIconToFile
; ���� ...: ��ȡ��ͼ����Դ (32λ ģ��) ������ cpl, dll, exe, ocx �� *.ico �ļ�
; �﷨.........: _ExtractIconToFile($sInFile, $iIcon, $sOutIco[, $iPath = 0])
; ���� ....: $sInFile - ����ͼ����ļ�·��.
;            $iIcon   - ��ȡ��ͼ���ţ�����; -1 ����һ��ͼ�꿪ʼ-1 ��
;            $sOutIco - ��ȡ��ͼ�걣��·��, ����; "C:\My Icons\new.ico"
;            $iPath   - ����Ϊ 1 ͼ��·�������� �����Զ�����
;                      .����Ϊ0 �Ļ� ���·�������� ���ᱻ����
; ����ֵ .: �ɹ�  - ���� 1 , @error Ϊ 0
;                  ʧ��  - ���� 0 , @error Ϊ 1 ~ 8
;                             @error 1 = ���� $sInFile ��Ч
;                             @error 2 = ���� $iIcon ��Ч
;                             @error 3 = ����ͼ�� ʧ��
;                             @error 4 = $iIcon �������� $sInFile
;                             @error 5 = δ���ҵ� RT_GROUP_ICON ��Դ
;                             @error 6 = δ���ҵ����е� RT_ICONS �� RT_GROUP_ICON ��
;                             @error 7 = �ļ��޷���дͼ������.
;                             @error 8 = �޷�д�����ݣ���ͼ�꿪�ŵ���.
; ���� ........: smashly
; Modified.......: 11-Aug-08 Basic rewrite of the functions to kick a couple of bugs and tidy up code.
; Remarks .......: A big Thank You to Siao for the heads up on _ResourceEnumNames & ___EnumResNameProc
; Related .......:
; Link ..........;
; ���� .......; _ExtractIconToFile(@SystemDir & "\shell32.dll", -42, @HomeDrive & "\Extracted.ico")
; ========================================================================================================
Func _ExtractIconToFile($sInFile, $iIcon, $sOutIco, $iPath = 0)
	Local Const $LOAD_LIBRARY_AS_DATAFILE = 0x00000002
	Local Const $RT_ICON = 3
	Local Const $RT_GROUP_ICON = 14
	Local $hInst, $iGN = "", $sData, $sHdr, $aHdr, $iCnt, $Offset, $FO, $FW, $iCrt = 18
	If $iPath = 1 Then $iCrt = 26
	If Not FileExists($sInFile) Then Return SetError(1, 0, 0)	;����ļ�������, ���ش������ 0
	If Not IsInt($iIcon) Then Return SetError(2, 0, 0)			;��� $iIcon ��������, ���ش������ 0 
	$hInst = _LoadLibraryEx($sInFile, $LOAD_LIBRARY_AS_DATAFILE)
	If Not $hInst Then Return SetError(3, 0, 0)					;���û�� $hInst, ���ش������ 0 
	_ResourceEnumNames($hInst, $RT_GROUP_ICON)
	For $i = 1 To $aEN[0]
		If $i = StringReplace($iIcon, "-", "") Then
			$iGN = $aEN[$i]
			ExitLoop
		EndIf
	Next
	Dim $aEN[1]
	If $iGN = "" Then
		_FreeLibrary($hInst)
		Return SetError(4, 0, 0)
	EndIf
	$sData = _GetIconResource($hInst, $iGN, $RT_GROUP_ICON)
    If @error Then 
	    _FreeLibrary($hInst)
		Return SetError(5, 0, 0)
	EndIf
	$sHdr = BinaryMid($sData, 1, 6)
	$aHdr = StringRegExp(StringTrimLeft(BinaryMid($sData, 7), 2), "(.{28})", 3)
	$iCnt = UBound($aHdr)
	$Offset = ($iCnt * 16) + 6
	For $i = 0 To $iCnt -1
		Local $sDByte = Dec(_RB(StringMid($aHdr[$i], 17, 8)))
		$sHdr &= StringTrimRight($aHdr[$i], 4) & _RB(Hex($Offset))
		$Offset += $sDByte		
	Next
	For $i = 0 To $iCnt -1
		$sData = _GetIconResource($hInst, "#" & Dec(_RB(StringRight($aHdr[$i], 4))), $RT_ICON)
		If @error Then 
		    _FreeLibrary($hInst)
			Return SetError(6, 0, 0)
		EndIf
		$sHdr &= StringTrimLeft($sData, 2)
	Next	
	_FreeLibrary($hInst)
	$FO = FileOpen($sOutIco, $iCrt)
	If $FO = -1 Then Return SetError(7, 0, 0)
	$FW = FileWrite($FO, $sHdr)
	If $FW = 0 Then 
	    FileClose($FO)
		Return SetError(8, 0, 0)
	EndIf
	FileClose($FO)
	Return SetError(0, 0, 1)
EndFunc   ;==>_ExtractIconToFile

; ========================================================================================================
; Internal Helper Functions from this point on
; ========================================================================================================
Func _GetIconResource($hModule, $sResName, $iResType)
	Local $hFind, $aSize, $hLoad, $hLock, $tRes, $sRet
	$hFind = DllCall("kernel32.dll", "int", "FindResourceA", "int", $hModule, "str", $sResName, "long", $iResType)
	If @error Or Not $hFind[0] Then Return SetError(1, 0, 0)
	$aSize = DllCall("kernel32.dll", "dword", "SizeofResource", "int", $hModule, "int", $hFind[0])
	If @error Or Not $aSize[0] Then Return SetError(2, 0, 0)
	$hLoad = DllCall("kernel32.dll", "int", "LoadResource", "int", $hModule, "int", $hFind[0])
	If @error Or Not $hLoad[0] Then Return SetError(3, 0, 0)
	$hLock = DllCall("kernel32.dll", "int", "LockResource", "int", $hLoad[0])
	If @error Or Not $hLock[0] Then
		_FreeResource($hLoad[0])
		Return SetError(4, 0, 0)
	EndIf
	$tRes = DllStructCreate("byte[" & $aSize[0] & "]", $hLock[0])
	If Not IsDllStruct($tRes) Then
		_FreeResource($hLoad[0])
		Return SetError(5, 0, 0)
	EndIf
	$sRet = DllStructGetData($tRes, 1)
	If $sRet = "" Then
		_FreeResource($hLoad[0])
		Return SetError(6, 0, 0)
	EndIf
	_FreeResource($hLoad[0])
	Return $sRet
EndFunc	

; Just a Reverse string byte function (smashly style..lol)
Func _RB($sByte)
	Local $aX = StringRegExp($sByte, "(.{2})", 3), $sX = ''
	For $i = UBound($aX) - 1 To 0 Step -1
		$sX &= $aX[$i]
	Next
	Return $sX
EndFunc   ;==>_RB

Func _LoadLibraryEx($sFile, $iFlag)
	Local $aRet = DllCall("Kernel32.dll", "hwnd", "LoadLibraryExA", "str", $sFile, "hwnd", 0, "int", $iFlag)
	Return $aRet[0]
EndFunc   ;==>_LoadLibraryEx

Func _FreeLibrary($hModule)
	DllCall("Kernel32.dll", "hwnd", "FreeLibrary", "hwnd", $hModule)
EndFunc   ;==>_FreeLibrary	

Func _FreeResource($hglbResource)
	DllCall("kernel32.dll", "int", "FreeResource", "int", $hglbResource)
EndFunc   ;==>_FreeResource

Func _ResourceEnumNames($hModule, $iType)
	Local $aRet, $xCB
	If Not $hModule Then Return SetError(1, 0, 0)
	$xCB = DllCallbackRegister('___EnumResNameProc', 'int', 'int_ptr;int_ptr;int_ptr;int_ptr')
	$aRet = DllCall('kernel32.dll', 'int', 'EnumResourceNamesW', 'ptr', $hModule, 'int', $iType, 'ptr', DllCallbackGetPtr($xCB), 'ptr', 0)
	DllCallbackFree($xCB)
	If $aRet[0] <> 1 Then Return SetError(2, 0, 0)
	Return SetError(0, 0, 1)
EndFunc   ;==>_ResourceEnumNames

Func ___EnumResNameProc($hModule, $pType, $pName, $lParam)
	Local $aSize = DllCall('kernel32.dll', 'int', 'GlobalSize', 'ptr', $pName), $tBuf
	If $aSize[0] Then
		$tBuf = DllStructCreate('wchar[' & $aSize[0] & ']', $pName)
		ReDim $aEN[UBound($aEN) + 1]
		$aEN[0] += 1
		$aEN[UBound($aEN) - 1] = DllStructGetData($tBuf, 1)
	Else
		ReDim $aEN[UBound($aEN) + 1]
		$aEN[0] += 1
		$aEN[UBound($aEN) - 1] = "#" & $pName
	EndIf
	Return 1
EndFunc   ;==>___EnumResNameProc	


