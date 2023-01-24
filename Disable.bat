@ECHO OFF

SETLOCAL

SET "BACKUP_FILE=EventLog_Backup.reg"

GOTO CHECK_BACKUP

:CHECK_BACKUP
	IF EXIST "%~dp0\%BACKUP_FILE%" (
		ECHO.
		ECHO.
		ECHO.
		ECHO. =======================================================
		ECHO. ===                                                 ===
		ECHO. === Backup already exists! Delete previous backup   ===
		ECHO. === before continuing.                              ===
		ECHO. ===                                                 ===
		ECHO. =======================================================
		ECHO.
		ECHO.
		ECHO.
		PAUSE>NUL&EXIT
	)
	GOTO EXPORT_REG
	
:EXPORT_REG
	CALL :EXPORT_REG "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\EventLog" "EventLog_Backup.reg"
	GOTO ACTION
	
:ACTION
	REG DELETE "HKLM\SYSTEM\CurrentControlSet\Services\EventLog\System" /F
	REG DELETE "HKLM\SYSTEM\CurrentControlSet\Services\EventLog\Application" /F
	REG DELETE "HKLM\SYSTEM\CurrentControlSet\Services\EventLog\HardwareEvents" /F
	REG DELETE "HKLM\SYSTEM\CurrentControlSet\Services\EventLog\Key Management Service" /F
	REG DELETE "HKLM\SYSTEM\CurrentControlSet\Services\EventLog\Security" /F
	REG DELETE "HKLM\SYSTEM\CurrentControlSet\Services\EventLog\Windows PowerShell" /F
	REG ADD "HKLM\SYSTEM\CurrentControlSet\Services\NlaSvc" /T REG_MULTI_SZ /V "DependOnService" /D "NSI RpcSs TcpIp Dhcp" /F
	REG ADD "HKLM\SYSTEM\CurrentControlSet\Services\EventLog" /T REG_DWORD /V "Start" /D 4 /F
	CALL :STOP_SVC "EventLog"
	GOTO DONE

:DONE
	ECHO.
	ECHO.
	ECHO.
	ECHO. ==================================================
	ECHO. ===                                            ===
	ECHO. === Everything is done! Press any key to exit. ===
	ECHO. ===                                            ===
	ECHO. ==================================================
	ECHO.
	ECHO.
	ECHO.
	PAUSE > NUL & EXIT
	GOTO DONE

:EXPORT_REG
	IF "%~1" NEQ "" ( IF "%~2" NEQ "" ( 
		REG EXPORT "%~1" "%~dp0\%~2" > NUL
	))
	
:STOP_SVC
	IF "%~1" NEQ "" ( NET STOP "%~1" /Y )