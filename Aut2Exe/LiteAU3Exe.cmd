@echo off
title AutoIt���EXEһ��������
color 27
pushd %~dp0
echo ��ʼ����ļ�%1
upx.exe  -d -q %1
echo ��ʼɾ�������ַ���
..\Extras\OtherEXE\ResHacker.exe  -delete "%1", "%1", StringTable,, 
echo ��ʼɾ�����öԻ���
..\Extras\OtherEXE\ResHacker.exe   -delete "%1", "%1", Dialog,, 
echo ��ʼɾ�����ò˵�
..\Extras\OtherEXE\ResHacker.exe   -delete "%1", "%1", Menu,, 
del/s/f/q ..\Extras\OtherEXE\ResHacker.log
del/s/f/q ..\Extras\OtherEXE\ResHacker.ini
upx.exe -9 -q %1
echo �������..��������˳�>nul 2>nul && pause
