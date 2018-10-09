// Copyright (c) 2017 Han Sangjin
// Licensed under Apache License v2.0 with Runtime Library Exception
//
// See https://swift.org/LICENSE.txt for license information

// This is a swift-invoker that behaves like symbolic linked to swift.
// This program was written to replace the large swiftc with a small file.
// This is not a Swift compiler but is compiled as swiftc.
// Compile: clang -o swiftc.exe -Wall swift-invoker.c
//          strip swiftc.exe

#include <stdio.h>
#include "invoker_lib.inc"

int main(int argc, char **argv)
{
	char home_dir[MAX_PATH];
	GetModuleFileName(NULL, home_dir, MAX_PATH);
	RemoveFileName(home_dir);
	RemoveFileName(home_dir);

	char path_swift[MAX_PATH];

	sprintf(path_swift, "%s\\bin\\swift.exe", home_dir);

	ExecV(path_swift, argv);
	
	return 0;
}
