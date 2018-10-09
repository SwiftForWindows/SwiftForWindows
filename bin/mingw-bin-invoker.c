// Copyright (c) 2017 Han Sangjin
// Licensed under Apache License v2.0 with Runtime Library Exception
//
// See https://swift.org/LICENSE.txt for license information

// This is a swift-invoker that behaves like symbolic linked to swift.
// This program was written to replace the large swiftc with a small file.
// This is not a Swift compiler but is compiled as swiftc.
// Compile: clang -o foo.exe -Wall mingw-bin-invoker.c
//          strip foo.exe
//
//   for Windows app:
//          clang -o winapp.exe -Wall -DNO_WAIT_CREATED_PROCESS_TERM  mingw-bin-invoker.c -Xlinker --subsystem -Xlinker windows Application.obj
//          strip winapp.exe
//

#include <stdio.h>
#include "invoker_lib.inc"

void GetLastFileName(char *path, char **file_name)
{
	int len = strlen(path);
	for (int i = len - 1; i >= 0; i--)
	{
		if (path[i] == '\\')
		{
			*file_name = &path[i+1];
			return ;
		}
	}
	*file_name = path;
}

int main(int argc, char **argv)
{
	char home_dir[MAX_PATH];
	GetModuleFileName(NULL, home_dir, MAX_PATH);
	char *file_name = NULL;
	GetLastFileName(home_dir, &file_name);
	RemoveFileName(home_dir);
	RemoveFileName(home_dir);

	char path_swift[MAX_PATH];

	sprintf(path_swift, "%s\\mingw64\\bin\\%s", home_dir, file_name);
	ExecV(path_swift, argv);
	
	return 0;
}
