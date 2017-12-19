#cs

	 ����һ����ȫ�ֱ���
	
	_ProcResume($vProcess)  �ָ� $vProcess �ڵ������߳�(PID ������)
	_ProcessGetWinList($vProcess, $sTitle = Default, $iOption = 0) ö�ٽ��̴���
	_CoProcReciver([$sFunction = ""]) ע��/ע��  Reciver(����)����
	_ConsoleForward($iPid1, [$iPid2], [$iPid3], [$iPidn])
	_ProcessEmptyWorkingSet($vPid = @AutoItPID,[$hDll_psapi],[$hDll_kernel32]) �ӹ�����ָ���Ľ���ɾ�������ܶ��ҳ��.
	_DuplicateHandle($dwSourcePid, $hSourceHandle, $dwTargetPid = @AutoItPID, $fCloseSource = False) ����һ���ظ��ľ��
	_CloseHandle($hAny) �رվ��
	$gs_SuperGlobalRegistryBase
	$gi_CoProcParent
#ce
Global $gs_SuperGlobalRegistryBase = "HKEY_CURRENT_USER\Software\AutoIt v3\CoProc"
Global $gi_CoProcParent = 0
Global $gs_CoProcReciverFunction = ""
Global $gv_CoProcReviverParameter = 0
;===============================================================================
; ����: _CoProc([$sFunction],[$vParameter])
; ����: ������һ������
; ����: $sFunction  - ��ѡ, ��ʼ�½��̵�����
; 		$vParameter - ��ѡ, ���ݵĲ���
; ��Ҫ: 3.2.4.9
; ����: �ɹ� - �����½��̵� PID
; 		ʧ�� - @error ����Ϊ 1
; ����: Florian 'Piccaso' Fida
; ע��: �½����ڲ� $gi_CoProcParent �����˸����̵� PID.
; 		$vParameter �����Ƕ�����, ����� DllStruct(DLL�ṹ).
; 		��� $sFunction ֻ�Ǻ�������, ���� _CoProc("MyFunc","MyParameter") ��
; 		Call() �����ú���,�����ݿ�ѡ���� (ֻ��һ��).
; 		��� $sFunction �Ǳ��ʽ, ���� _CoProc("MyFunc('MyParameter')") ��
; 		Execute() ������������ñ��ʽ����ʹ�ö������.
; 		����'Execute()' ��ʽ, ������ $vParameter ����.
; 		����������¶�������, ����ϸ�ڼ� Execute() �� Call() .
; 		��� $sFunction Ϊ�� ("" �� Default) $vParameter ������ Reciver(����)������.
;===============================================================================
Func _CoProc($sFunction = Default, $vParameter = Default)
	Local $iPid
	If IsKeyword($sFunction) Or $sFunction = "" Then $sFunction = "__CoProcDummy"
	EnvSet("CoProc", "0x" & Hex(StringToBinary($sFunction)))
	EnvSet("CoProcParent", @AutoItPID)
	If Not IsKeyword($vParameter) Then
		EnvSet("CoProcParameterPresent", "True")
		EnvSet("CoProcParameter", StringToBinary($vParameter))
	Else
		EnvSet("CoProcParameterPresent", "False")
	EndIf
	If @Compiled Then
		$iPid = Run(FileGetShortName(@AutoItExe), @WorkingDir, @SW_HIDE, 1 + 2 + 4)
	Else
		$iPid = Run(FileGetShortName(@AutoItExe) & ' "' & @ScriptFullPath & '"', @WorkingDir, @SW_HIDE, 1 + 2 + 4)
	EndIf
	If @error Then SetError(1)
	Return $iPid
EndFunc   ;==>_CoProc
;===============================================================================
; ����:  _SuperGlobalSet($sName,[$vValue],[$sRegistryBase])
; ����: ����һ����ȫ�ֱ���
; ����: $sName - ��ȫ�ֱ�����ʶ��
; 		$vValue - ���洢��ֵ (��ѡ)
; 		$sRegistryBase - ע�������� (��ѡ)
; ��Ҫ: 3.2.4.9
; ����: �ɹ� - ���� True
; 		ʧ�� - ���� ���� False ����:
; 				@error Ϊ:	1 - �����ֵ����
; 							2 - ע�������
; ����: Florian 'Piccaso' Fida
; ע��: $vValue ��������һ�������ṹ.
; 		���ʡ�� $vValue ��ȫ�ֱ�������ɾ��.
;		��ȫ�ֱ����洢��ע�����.
; 		$gs_SuperGlobalRegistryBase ռ��Ĭ�ϻ�����
;===============================================================================
Func _SuperGlobalSet($sName, $vValue = Default, $sRegistryBase = Default)
	Local $vTmp
	If $sRegistryBase = Default Then $sRegistryBase = $gs_SuperGlobalRegistryBase
	If $vValue = "" Or $vValue = Default Then
		RegDelete($sRegistryBase, $sName)
		If @error Then Return SetError(2, 0, False) ; Registry Problem
	Else
		RegWrite($sRegistryBase, $sName, "REG_BINARY", StringToBinary($vValue))
		If @error Then Return SetError(2, 0, False) ; Registry Problem
	EndIf
	Return True
EndFunc   ;==>_SuperGlobalSet
;===============================================================================
; ����: _SuperGlobalGet($sName,[$fOption],[$sRegistryBase])
; ����: ��ȡ��ȫ�ֱ���
; ����: $sName - ��ȫ�ֱ�����ʶ��
; 		$fOption - ��ѡ, �����Ϊ True, ��ȫ�ɹ��������,��ȫ�ֱ�������ɾ����
; 		$sRegistryBase - ע������ (��ѡ)
; ��Ҫ: 3.2.4.9
; ����: �ɹ� - ���س�ȫ�ֱ���ֵ
; 		ʧ�� - ���� @error : 1 - û���ҵ�/ע�������
; 							 2 - ����ɾ��
; ����: Florian 'Piccaso' Fida
; ע��: $vValue ������һ�������ṹ.
; 		��ȫ�ֱ����洢��ע�����.
; 		$gs_SuperGlobalRegistryBase ռ��Ĭ�ϻ�����
;===============================================================================
Func _SuperGlobalGet($sName, $fOption = Default, $sRegistryBase = Default)
	Local $vTmp
	If $fOption = "" Or $fOption = Default Then $fOption = False

	If $sRegistryBase = Default Then $sRegistryBase = $gs_SuperGlobalRegistryBase
	$vTmp = RegRead($sRegistryBase, $sName)
	If @error Then Return SetError(1, 0, "") ; Registry Problem
	If $fOption Then
		_SuperGlobalSet($sName)
		If @error Then SetError(2)
	EndIf
	Return BinaryToString("0x" & $vTmp)
EndFunc   ;==>_SuperGlobalGet
;===============================================================================
; ���� _ProcSuspend($vProcess) ��ͣ $vProcess �ڵ������߳�(PID ������)
; ����: ������̵������߳�
; ����: $vProcess - �������� PID
; ��Ҫ: 3.1.1.130, Win ME/2k/XP
; ����: �ɹ� - ���� Nr. ���̹���,������ @extended Ϊ������̵� Nr. 
; 		ʧ�� - ���� False ������
; 			   @error to: 1 - δ���ֽ���
;						  2 - ������� 'CreateToolhelp32Snapshot'
;						  3 - ������� 'Thread32First'
;						  4 - ������� 'Thread32Next'
;						  5 - �������е��̴߳���
; ����: Florian 'Piccaso' Fida
; ע��: ��ֲ��: http://www.codeproject.com/threads/pausep.asp
; �������ʹ����,���õ��Ķ� (�;���!) �� (IMG:http://www.autoitscript.com/forum/style_emoticons/autoit/smile.gif)
;===============================================================================
Func _ProcSuspend($vProcess, $iReserved = 0)
	Local $iPid, $vTmp, $hThreadSnap, $ThreadEntry32, $iThreadID, $hThread, $iThreadCnt, $iThreadCntSuccess, $sFunction
	Local $TH32CS_SNAPTHREAD = 0x00000004
	Local $INVALID_HANDLE_VALUE = 0xFFFFFFFF
	Local $THREAD_SUSPEND_RESUME = 0x0002
	Local $THREADENTRY32_StructDef = "int;" _; 1 -> dwSize
			 & "int;" _; 2 -> cntUsage
			 & "int;" _; 3 -> th32ThreadID
			 & "int;" _; 4 -> th32OwnerProcessID
			 & "int;" _; 5 -> tpBasePri
			 & "int;" _; 6 -> tpDeltaPri
			 & "int" ; 7 -> dwFlags

	$iPid = ProcessExists($vProcess)
	If Not $iPid Then Return SetError(1, 0, False) ; Process not found.
	$vTmp = DllCall("kernel32.dll", "ptr", "CreateToolhelp32Snapshot", "int", $TH32CS_SNAPTHREAD, "int", 0)
	If @error Then Return SetError(2, 0, False) ; CreateToolhelp32Snapshot Failed
	If $vTmp[0] = $INVALID_HANDLE_VALUE Then Return SetError(2, 0, False) ; CreateToolhelp32Snapshot Failed
	$hThreadSnap = $vTmp[0]
	$ThreadEntry32 = DllStructCreate($THREADENTRY32_StructDef)
	DllStructSetData($ThreadEntry32, 1, DllStructGetSize($ThreadEntry32))
	$vTmp = DllCall("kernel32.dll", "int", "Thread32First", "ptr", $hThreadSnap, "long", DllStructGetPtr($ThreadEntry32))
	If @error Then Return SetError(3, 0, False) ; Thread32First Failed
	If Not $vTmp[0] Then
		DllCall("kernel32.dll", "int", "CloseHandle", "ptr", $hThreadSnap)
		Return SetError(3, 0, False) ; Thread32First Failed
	EndIf

	While 1
		If DllStructGetData($ThreadEntry32, 4) = $iPid Then
			$iThreadID = DllStructGetData($ThreadEntry32, 3)
			$vTmp = DllCall("kernel32.dll", "ptr", "OpenThread", "int", $THREAD_SUSPEND_RESUME, "int", False, "int", $iThreadID)
			If Not @error Then
				$hThread = $vTmp[0]
				If $hThread Then
					If $iReserved Then
						$sFunction = "ResumeThread"
					Else
						$sFunction = "SuspendThread"
					EndIf
					$vTmp = DllCall("kernel32.dll", "int", $sFunction, "ptr", $hThread)
					If $vTmp[0] <> -1 Then $iThreadCntSuccess += 1
					DllCall("kernel32.dll", "int", "CloseHandle", "ptr", $hThread)
				EndIf
			EndIf
			$iThreadCnt += 1
		EndIf
		$vTmp = DllCall("kernel32", "int", "Thread32Next", "ptr", $hThreadSnap, "long", DllStructGetPtr($ThreadEntry32))
		If @error Then Return SetError(4, 0, False) ; Thread32Next Failed
		If Not $vTmp[0] Then ExitLoop

	WEnd

	DllCall("kernel32.dll", "int", "CloseToolhelp32Snapshot", "ptr", $hThreadSnap) ; CloseHandle
	If Not $iThreadCntSuccess Or $iThreadCnt > $iThreadCntSuccess Then Return SetError(5, $iThreadCnt, $iThreadCntSuccess)
	Return SetError(0, $iThreadCnt, $iThreadCntSuccess)
EndFunc   ;==>_ProcSuspend
;===============================================================================
;
; ����: Resume all Threads in a Process
; ����: $vProcess - Name or PID of Process
; ��Ҫ: 3.1.1.130, Win ME/2k/XP
; ����: �ɹ� - ����Returns Nr. of Threads Resumed and Set @extended to Nr. of Threads Processed
; 		ʧ�� - ���� Returns False and Set
; @error to: 1 - δ���ֽ���
; 2 - ������� 'CreateToolhelp32Snapshot'
; 3 - ������� 'Thread32First'
; 4 - ������� 'Thread32Next'
; 5 - �������е��̴߳���
; ����: Florian 'Piccaso' Fida
; ע��: Ported from: http://www.codeproject.com/threads/pausep.asp
; Better read the article (and the warnings!) if you want to use it (IMG:http://www.autoitscript.com/forum/style_emoticons/autoit/smile.gif)
;===============================================================================
Func _ProcResume($vProcess)
	Local $fRval = _ProcSuspend($vProcess, True)
	Return SetError(@error, @extended, $fRval)
EndFunc   ;==>_ProcResume
;===============================================================================
;
; ����: ö�ٽ��̴���
; ����: $vProcess - Name or PID of Process
; $sTitle - Optional Title of window to Find
; $iOption - ��ѡ, Can be added together
; 0 - Matches any Window (Default)
; 2 - Matches any Window Created by GuiCreate() (ClassName: AutoIt v3 GUI)
; 4 - Matches AutoIt Main Window (ClassName: AutoIt v3)
; 6 - Matches Any AutoIt Window
; 16 - Return the first Window Handle found (No Array)
; ��Ҫ: 3.1.1.130
; ����: �ɹ� - ����Retuns an Array/Handle of Windows found
; 		ʧ�� - ���� Set @ERROR to: 1 - δ���ֽ���
; 2 - Window(s) not Found
; 3 - GetClassName Failed
; ����: Florian 'Piccaso' Fida
; ע��:
;
;===============================================================================
Func _ProcessGetWinList($vProcess, $sTitle = Default, $iOption = 0)
	Local $aWinList, $iCnt, $aTmp, $iPid
	Local $aResult[1]
	Local $fMatch, $sClassname, $hWnd

	$iPid = ProcessExists($vProcess)
	If Not $iPid Then Return SetError(1) ; δ���ֽ���
	If $sTitle = "" Or IsKeyword($sTitle) Then
		$aWinList = WinList()
	Else
		$aWinList = WinList($sTitle)
	EndIf

	For $iCnt = 1 To $aWinList[0][0]
		$hWnd = $aWinList[$iCnt][1]
		Global $iProcessId = WinGetProcess($hWnd)
		If $iProcessId = $iPid Then
			If $iOption = 0 Or IsKeyword($iOption) Or $iOption = 16 Then
				$fMatch = True
			Else
				$fMatch = False
				$sClassname = DllCall("user32.dll", "int", "GetClassName", "hwnd", $hWnd, "str", "", "int", 1024)
				If @error Then Return SetError(3) ; GetClassName
				If $sClassname[0] = 0 Then Return SetError(3) ; GetClassName
				$sClassname = $sClassname[2]
				If BitAND($iOption, 2) Then
					If $sClassname = "AutoIt v3 GUI" Then $fMatch = True
				EndIf
				If BitAND($iOption, 4) Then
					If $sClassname = "AutoIt v3" Then $fMatch = True
				EndIf
			EndIf
			If $fMatch Then
				If BitAND($iOption, 16) Then Return $hWnd
				ReDim $aResult[UBound($aResult) + 1]
				$aResult[UBound($aResult) - 1] = $hWnd
			EndIf
		EndIf
	Next

	$aResult[0] = UBound($aResult) - 1
	If $aResult[0] < 1 Then Return SetError(2, 0, 0) ; No Window(s) Found
	Return $aResult
EndFunc   ;==>_ProcessGetWinList

;===============================================================================
;
; ����: Register Reciver Function
; ����: $sFunction - ��ѡ, Function name to Register.
; Omit to Disable/Unregister
; ��Ҫ: 3.2.4.9
; ����: �ɹ� - ����Returns True
; 		ʧ�� - ���� Returns False and Set
; @error to: 1 - Unable to create Reciver Window
; 2 - Unable to (Un)Register WM_COPYDATA or WM_USER+0x64
; ����: Florian 'Piccaso' Fida
; ע��: If the process doesent have a Window it will be created
; The Reciver Function must accept 1 Parameter
;
;===============================================================================
Func _CoProcReciver($sFunction = Default)
	Local $sHandlerFuction = "__CoProcReciverHandler", $hWnd, $aTmp
	If IsKeyword($sFunction) Then $sFunction = ""
	$hWnd = _ProcessGetWinList(@AutoItPID, "", 16 + 2)
	If Not IsHWnd($hWnd) Then
		$hWnd = GUICreate("CoProcEventReciver")
		If @error Then Return SetError(1, 0, False)
	EndIf
	If $sFunction = "" Or IsKeyword($sFunction) Then $sHandlerFuction = ""
	If Not GUIRegisterMsg(0x4A, $sHandlerFuction) Then Return SetError(2, 0, False) ; WM_COPYDATA
	If Not GUIRegisterMsg(0x400 + 0x64, $sHandlerFuction) Then Return SetError(2, 0, False) ; WM_USER+0x64
	$gs_CoProcReciverFunction = $sFunction
	Return True
EndFunc   ;==>_CoProcReciver
Func __CoProcReciverHandler($hWnd, $iMsg, $WParam, $LParam)
	If $iMsg = 0x4A Then ; WM_COPYDATA
		Local $COPYDATA, $MyData
		$COPYDATA = DllStructCreate("ptr;dword;ptr", $LParam)
		$MyData = DllStructCreate("char[" & DllStructGetData($COPYDATA, 2) & "]", DllStructGetData($COPYDATA, 3))
		$gv_CoProcReviverParameter = DllStructGetData($MyData, 1)
		Return 256
	ElseIf $iMsg = 0x400 + 0x64 Then ; WM_USER+0x64
		If $gv_CoProcReviverParameter Then
			Call($gs_CoProcReciverFunction, $gv_CoProcReviverParameter)
			If @error And @Compiled = 0 Then MsgBox(16, "CoProc Error", "Unable to Call: " & $gs_CoProcReciverFunction)
			$gv_CoProcReviverParameter = 0
			Return 0
		EndIf
	EndIf
EndFunc   ;==>__CoProcReciverHandler

;===============================================================================
; ����: ������Ϣ������
; ����: $vProcess     - �������� PID
; 		$vParameter   - ���ݵĲ���
; 		$iTimeout 	  - ��ѡ, Ĭ�� 500 (����)
; 		$fAbortIfHung - ��ѡ, Ĭ�� True
; ��Ҫ: 3.2.4.9
; ����: �ɹ� - ���� True
; 		ʧ�� - ���� False ����
; 				@error Ϊ: 1 - δ���ֽ���
;						   2 - δ���ִ���
;						   3 - ��ʱ/æ/����
;						   4 - ������Ϣʧ��
;==========================================================================
Func _CoProcSend($vProcess, $vParameter, $iTimeout = 500, $fAbortIfHung = True)
	Local $iPid, $hWndTarget, $MyData, $aTmp, $COPYDATA, $iFuFlags
	$iPid = ProcessExists($vProcess)
	If Not $iPid Then Return SetError(1, 0, False) ; δ���ֽ���
	$hWndTarget = _ProcessGetWinList($vProcess, "", 16 + 2)
	If @error Or (Not $hWndTarget) Then Return SetError(2, 0, False) ; Window not found
	$MyData = DllStructCreate("char[" & StringLen($vParameter) + 1 & "]")
	$COPYDATA = DllStructCreate("ptr;dword;ptr")
	DllStructSetData($MyData, 1, $vParameter)
	DllStructSetData($COPYDATA, 1, 1)
	DllStructSetData($COPYDATA, 2, DllStructGetSize($MyData))
	DllStructSetData($COPYDATA, 3, DllStructGetPtr($MyData))
	If $fAbortIfHung Then
		$iFuFlags = 0x2 ; SMTO_ABORTIFHUNG
	Else
		$iFuFlags = 0x0 ; SMTO_NORMAL
	EndIf
	$aTmp = DllCall("user32.dll", "int", "SendMessageTimeout", "hwnd", $hWndTarget, "int", 0x4A _; WM_COPYDATA
			, "int", 0, "ptr", DllStructGetPtr($COPYDATA), "int", $iFuFlags, "int", $iTimeout, "long*", 0)
	If @error Then Return SetError(3, 0, False) ; SendMessageTimeout Failed
	If Not $aTmp[0] Then Return SetError(3, 0, False) ; SendMessageTimeout Failed
	If $aTmp[7] <> 256 Then Return SetError(3, 0, False)
	$aTmp = DllCall("user32.dll", "int", "PostMessage", "hwnd", $hWndTarget, "int", 0x400 + 0x64, "int", 0, "int", 0)
	If @error Then Return SetError(4, 0, False)
	If Not $aTmp[0] Then Return SetError(4, 0, False)
	Return True
EndFunc   ;==>_CoProcSend

;===============================================================================
;
; ����: Forwards StdOut and StdErr from specified Processes to Calling process
; ����: $iPid1 - Pid of Procces
; $iPidn - ��ѡ, Up to 16 Processes
; ��Ҫ: 3.1.1.131
; ����: None
; ����: Florian 'Piccaso' Fida
; ע��: Processes must provide StdErr and StdOut Streams (See Run())
;
;==========================================================================
Func _ConsoleForward($iPid1, $iPid2 = Default, $iPid3 = Default, $iPid4 = Default, $iPid5 = Default, $iPid6 = Default, $iPid7 = Default, $iPid8 = Default, $iPid9 = Default, $iPid10 = Default, $iPid11 = Default, $iPid12 = Default, $iPid13 = Default, $iPid14 = Default, $iPid15 = Default, $iPid16 = Default)
	Local $iPid, $i, $iPeek
	For $i = 1 To 16
		$iPid = Eval("iPid" & $i)
		If $iPid = Default Or Not $iPid Then ContinueLoop
		If ProcessExists($iPid) Then
			$iPeek = StdoutRead($iPid, True, True)
			If Not @error And $iPeek > 0 Then
				ConsoleWrite(StdoutRead($iPid))
			EndIf
			$iPeek = StderrRead($iPid, True, True)
			If Not @error And $iPeek > 0 Then
				ConsoleWriteError(StderrRead($iPid))
			EndIf
		EndIf
	Next
EndFunc   ;==>_ConsoleForward
;===============================================================================
;
; ����: �ӹ�����ָ���Ľ���ɾ�������ܶ��ҳ��.
; ����: $vPid - ��ѡ, Pid or Process Name
; $hDll_psapi - ��ѡ, Handle to psapi.dll
; $hDll_kernel32 - ��ѡ, Handle to kernel32.dll
; ��Ҫ: 3.2.1.12
; ����: �ɹ� - ����nonzero
; 		ʧ�� - ���� 0 and sets error to
; @error to: 1 - Process Doesent exist
; 2 - OpenProcess Failed
; 3 - EmptyWorkingSet Failed
; ����: Florian 'Piccaso' Fida
; ע��: $vPid can be the -1 Pseudo Handle
;
;===============================================================================
Func _ProcessEmptyWorkingSet($vPid = @AutoItPID, $hDll_psapi = "psapi.dll", $hDll_kernel32 = "kernel32.dll")
	Local $av_EWS, $av_OP, $iRval
	If $vPid = -1 Then ; Pseudo Handle
		$av_EWS = DllCall($hDll_psapi, "int", "EmptyWorkingSet", "ptr", -1)
	Else
		$vPid = ProcessExists($vPid)
		If Not $vPid Then Return SetError(1, 0, 0) ; Process Doesent exist
		$av_OP = DllCall($hDll_kernel32, "int", "OpenProcess", "dword", 0x1F0FFF, "int", 0, "dword", $vPid)
		If $av_OP[0] = 0 Then Return SetError(2, 0, 0) ; OpenProcess Failed
		$av_EWS = DllCall($hDll_psapi, "int", "EmptyWorkingSet", "ptr", $av_OP[0])
		DllCall($hDll_kernel32, "int", "CloseHandle", "int", $av_OP[0])
	EndIf
	If $av_EWS[0] Then
		Return $av_EWS[0]
	Else
		Return SetError(3, 0, 0) ; EmptyWorkingSet Failed
	EndIf
EndFunc   ;==>_ProcessEmptyWorkingSet


;===============================================================================
;
; ����: Duplicates a Handle from or for another process
; ����: $dwSourcePid - Pid from Source Process
; $hSourceHandle - The Handle to duplicate
; $dwTargetPid - ��ѡ, Pid from Target Procces - Defaults to current process
; $fCloseSource - ��ѡ, Close the source handle - Defaults to False
; ��Ҫ: 3.2.4.9
; ����: �ɹ� - ����Duplicated Handle
; 		ʧ�� - ���� 0 and sets error to
; @error to: 1 - Api OpenProcess Failed
; 2 - Api DuplicateHandle Falied
; ����: Florian 'Piccaso' Fida
; ע��:
;
;===============================================================================
Func _DuplicateHandle($dwSourcePid, $hSourceHandle, $dwTargetPid = @AutoItPID, $fCloseSource = False)
	Local $hTargetHandle, $hPrSource, $hPrTarget, $dwOptions
	$hPrSource = __dh_OpenProcess($dwSourcePid)
	$hPrTarget = __dh_OpenProcess($dwTargetPid)
	If $hPrSource = 0 Or $hPrTarget = 0 Then
		_CloseHandle($hPrSource)
		_CloseHandle($hPrTarget)
		Return SetError(1, 0, 0)
	EndIf
	; DUPLICATE_CLOSE_SOURCE = 0x00000001
	; DUPLICATE_SAME_ACCESS = 0x00000002
	If $fCloseSource <> False Then
		$dwOptions = 0x01 + 0x02
	Else
		$dwOptions = 0x02
	EndIf
	$hTargetHandle = DllCall("kernel32.dll", "int", "DuplicateHandle", "ptr", $hPrSource, "ptr", $hSourceHandle, "ptr", $hPrTarget, "long*", 0, "dword", 0, "int", 1, "dword", $dwOptions)
	If @error Then Return SetError(2, 0, 0)
	If $hTargetHandle[0] = 0 Or $hTargetHandle[4] = 0 Then
		_CloseHandle($hPrSource)
		_CloseHandle($hPrTarget)
		Return SetError(2, 0, 0)
	EndIf
	Return $hTargetHandle[4]
EndFunc   ;==>_DuplicateHandle
Func __dh_OpenProcess($dwProcessId)
	; PROCESS_DUP_HANDLE = 0x40
	Local $hPr = DllCall("kernel32.dll", "ptr", "OpenProcess", "dword", 0x40, "int", 0, "dword", $dwProcessId)
	If @error Then Return SetError(1, 0, 0)
	Return $hPr[0]
EndFunc   ;==>__dh_OpenProcess
Func _CloseHandle($hAny)
	If $hAny = 0 Then Return SetError(1, 0, 0)
	Local $fch = DllCall("kernel32.dll", "int", "CloseHandle", "ptr", $hAny)
	If @error Then Return SetError(1, 0, 0)
	Return $fch[0]
EndFunc   ;==>_CloseHandle



#Region Internal Functions
Func __CoProcStartup()
	Local $sCmd = EnvGet("CoProc")
	If StringLeft($sCmd, 2) = "0x" Then
		$sCmd = BinaryToString($sCmd)
		$gi_CoProcParent = Number(EnvGet("CoProcParent"))
		If StringInStr($sCmd, "(") And StringInStr($sCmd, ")") Then
			Execute($sCmd)
			If @error And Not @Compiled Then MsgBox(16, "CoProc Error", "Unable to Execute: " & $sCmd)
			Exit
		EndIf
		If EnvGet("CoProcParameterPresent") = "True" Then
			Call($sCmd, BinaryToString(EnvGet("CoProcParameter")))
			If @error And Not @Compiled Then MsgBox(16, "CoProc Error", "Unable to Call: " & $sCmd & @LF & "Parameter: " & BinaryToString(EnvGet("CoProcParameter")))
		Else
			Call($sCmd)
			If @error And Not @Compiled Then MsgBox(16, "CoProc Error", "Unable to Call: " & $sCmd)
		EndIf
		Exit
	EndIf
EndFunc   ;==>__CoProcStartup
Func __CoProcDummy($vPar = Default)
	If Not IsKeyword($vPar) Then _CoProcReciver($vPar)
	While ProcessExists($gi_CoProcParent)
		Sleep(500)
	WEnd
EndFunc   ;==>__CoProcDummy
__CoProcStartup()
#EndRegion Internal Functions
