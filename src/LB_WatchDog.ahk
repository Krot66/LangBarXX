SetWorkingDir % RegExReplace(A_ScriptDir, "\\[^\\]+$")
#NoTrayIcon
Process Priority,, L

EnvSet __COMPAT_LAYER, RUNASINVOKER

If !(run_file:=A_Args[1]) || !FileExist(run_file)
	ExitApp

Loop {
	Sleep 1000
	Process Exist, % run_file
	If ErrorLevel
		Continue
	Run % run_file
}

