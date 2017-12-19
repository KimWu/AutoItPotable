; ***************************************************************
; 示例 1 - 创建一个新的工作表并打开, 然后关闭工作表
; *****************************************************************

#include <Excel.au3>

Local $oExcel = _ExcelBookNew() ;创建一个新的工作表并打开
_ExcelBookClose($oExcel) ;关闭工作表. (默认情况下,将自动保存在"我的文档"文件夹中)

; ***************************************************************
; 示例 2 - 创建一个新的工作表并打开, 然后用默认参数关闭工作表
; *****************************************************************

#include <Excel.au3>

$oExcel = _ExcelBookNew() ; 创建一个新的工作表并打开
_ExcelBookClose($oExcel, 0) ;关闭工作表, 可选参数:0 = 不保存，1 = 保存(默认值)

; ***************************************************************
; 示例 3 - 创建一个新的工作表并打开, 然后用默认参数关闭工作表
; *****************************************************************

#include <Excel.au3>
$oExcel = _ExcelBookNew() ; 创建一个新的工作表并打开
_ExcelBookClose($oExcel, 1, 0) ;在没有任何提示的情况下保存并关闭工作表, 可选参数:0 = 不提示(默认值), 1 = 提示
