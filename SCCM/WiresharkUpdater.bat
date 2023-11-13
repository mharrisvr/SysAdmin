@ECHO OFF
SETLOCAL
:: WiresharkUpdater.bat
:: Author: Mike Harris
:: Last Updated: 10/18/2023

:: Installs Latest version of wireshark
.\Wireshark-win64-4.0.10.exe /S /norestart

:: Installs Latest Npcap
.\npcap-1.77.exe /norestart
