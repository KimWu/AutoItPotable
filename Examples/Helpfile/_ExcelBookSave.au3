; ***************************************************************
; 示例1 打开一个新的工作表并返回其对象标识符, 然后在没有任何提示的情况下保存该文件.
; *****************************************************************

#include <Excel.au3>

Local $oExcel = _ExcelBookNew()

_ExcelBookSave($oExcel) ;没有任何提示的情况下保存
If Not @error Then MsgBox(4096, "成功", "文件已保存!", 3)