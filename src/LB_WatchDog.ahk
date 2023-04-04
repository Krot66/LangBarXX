SetWorkingDir %A_ScriptDir%
#NoTrayIcon

If !(run_file:=A_Args[1]) || !FileExist(run_file)
	ExitApp

Loop {
	Sleep 500
	Process Exist, % run_file
	If ErrorLevel
		Continue
	If (A_OSVersion="WIN_XP")
		Run % run_file, % A_ScriptDir
	Else
		Run % "*RunAs " run_file, % A_ScriptDir
}

