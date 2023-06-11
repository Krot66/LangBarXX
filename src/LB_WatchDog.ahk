SetWorkingDir % RegExReplace(A_ScriptDir, "\\[^\\]+$")
#NoTrayIcon

EnvSet __COMPAT_LAYER, RUNASINVOKER

If !(run_file:=A_Args[1]) || !FileExist(run_file)
	ExitApp

Loop {
	Sleep 500
	Process Exist, % run_file
	If ErrorLevel
		Continue
	Run % run_file
}

