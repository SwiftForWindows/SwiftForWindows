// Copyright (c) 2017 Han Sangjin
// Licensed under Apache License v2.0 with Runtime Library Exception
//
// See https://swift.org/LICENSE.txt for license information

// This is a ld-invoker that behaves like clang++.
// This program was written to replace the large clang++ used only when calling the linker 'ld'.
// This is not a C++ compiler but is compiled as clang++.
// Compile: clang -o clang++.exe -Wall ld-invoker.c 
//          strip clang++.exe

#include <stdio.h>
#include <unistd.h>
#include <windows.h>

#define MAX_OBJS 100
#define MAX_CMD_LINE 8000
#define MAX_LARGE_L_OPT 50
#define MAX_INPUT_OPT 200 

void RemoveFileName(char *path)
{
	int len = strlen(path);
	for (int i = len - 1; i >= 0; i--)
	{
		if (path[i] == '\\')
		{
			path[i] = '\0';
			break;
		}
	}
}

int HavingSpace(const char *str)
{
  while (1)
  {
    if (*str == ' ')
      return 1;
    if (*str == '\0')
      return 0;
    str++;    
  }
}

int HavingRevSlash(const char *str)
{
  while (1)
  {
    if (*str == '\\')
      return 1;
    if (*str == '\0')
      return 0;
    str++;    
  }
}

void StrCatInQuote(char *dest, const char *src)
{
  while (*dest)
    dest++;
  
  while (*src)
  {
    *dest = *src;
    if (*src == '\\')
    {
      dest++;
      *dest = *src;
    }
    dest++;
    src++;
  }
  
  *dest = '\0';
}

int PrintCmdLine(const char *executable_path, char *const argv[])
{
	char cmd_line[MAX_CMD_LINE];
	strcpy(cmd_line, "");
	for (int i = 0; argv[i] != NULL; i++)
	{
    if (i != 0)
		  strcat(cmd_line, " ");
    
    int should_quote = HavingSpace(argv[i]) || HavingRevSlash(argv[i]);
    if (should_quote)
      strcat(cmd_line, "\"");
    
    if (should_quote)
    {
  		StrCatInQuote(cmd_line, argv[i]);
    }
    else
    {
  		strcat(cmd_line, argv[i]);
    }
    
    if (should_quote)
  		strcat(cmd_line, "\"");
	}

  printf(" %s\n", cmd_line);
  fflush(stdout);
  return 0;
}

int ExecV(const char *executable_path, char *const argv[])
{
	char cmd_line[MAX_CMD_LINE];
	strcpy(cmd_line, "");
	for (int i = 0; argv[i] != NULL; i++)
	{
    if (i != 0)
  		strcat(cmd_line, " ");
    int should_quote = HavingSpace(argv[i]);
    if (should_quote)
      strcat(cmd_line, "\"");
    
		strcat(cmd_line, argv[i]);
    
    if (should_quote)
  		strcat(cmd_line, "\"");
	}

	STARTUPINFO si;
	PROCESS_INFORMATION pi;
	ZeroMemory(&si, sizeof(si));
	si.cb = sizeof(si);
	ZeroMemory(&pi, sizeof(pi));
	if (!CreateProcessA(executable_path, cmd_line, 0, 0, 0, 0, 0, 0, &si, &pi))
	{
		// Could not start process;
    printf("Could not start process (%lu)\n", GetLastError());
		return -1;
	}

	// Now 'pi.hProcess' contains the process HANDLE, which you can use to wait for it like this:
	WaitForSingleObject(pi.hProcess, INFINITE);
	return 0;
}

void PrintProgramName()
{
  printf("LD Invoker v1.0\n");
}

int main(int argc, char **argv)
{
  if (argc == 1)
  {
    PrintProgramName();
    return 0;    
  }
  
  // Get mingw64 directory and suppose this program is running as 
  // '[Install Dir]\Swift\mingw64\bin\clang++.exe'
	char mingw64_dir[MAX_PATH];
	GetModuleFileName(NULL, mingw64_dir, MAX_PATH);
	RemoveFileName(mingw64_dir);
	RemoveFileName(mingw64_dir);

	char path_ld[MAX_PATH];
  char path_ld_exe[MAX_PATH];
	char hard_crt2[MAX_PATH];
	char hard_crtbegin[MAX_PATH];
	char hard_crtend[MAX_PATH];
  char hard_L_option1[MAX_PATH];
  char hard_L_option2[MAX_PATH];
  char hard_L_option3[MAX_PATH];
  char hard_L_option4[MAX_PATH];
  char proc_L_option[MAX_LARGE_L_OPT][MAX_PATH];
  int  proc_L_option_cnt = 0;
  char proc_input_option[MAX_INPUT_OPT][MAX_PATH];
  int  proc_input_option_cnt = 0;

	sprintf(path_ld, "%s\\bin\\ld", mingw64_dir);
	sprintf(path_ld_exe, "%s\\bin\\ld.exe", mingw64_dir);

	char *path_output;
  int verbose_mode = 0;

	for (int i = 1; i < argc; i++)
	{
		if (argv[i][0] == '@')
    {
			FILE *fp = fopen(argv[i]+1, "r");
      if (fp != NULL)
      {
        while(1)
        {
          char *ret = fgets(proc_input_option[proc_input_option_cnt], MAX_PATH, fp);
          if (ret == NULL)
            break;
          int len = strlen(proc_input_option[proc_input_option_cnt]);
          // remove last '\n'
          proc_input_option[proc_input_option_cnt][len-1] = '\0';
          proc_input_option_cnt++;
        }
        
        fclose(fp);
      }
    }

    // parse -o option
		else if (argv[i][0] == '-' && argv[i][1] == 'o' && i + 1 < argc)
    {
			path_output = argv[i + 1];
      i++;
    }
    
    // parse -L option
    else if (argv[i][0] == '-' && argv[i][1] == 'L')
    {
      if (argv[i][2] == '\0' && i + 1 < argc)
      {
        strcpy(proc_L_option[proc_L_option_cnt], "-L");
        strcat(proc_L_option[proc_L_option_cnt], argv[i + 1]);
        proc_L_option_cnt++;
        i++;
      }
      else if (argv[i][2] != '\0')
      {
        strcpy(proc_L_option[proc_L_option_cnt], argv[i]);
        proc_L_option_cnt++;
      }
    }
    
    // parse -l option
    else if (argv[i][0] == '-' && argv[i][1] == 'l')
    {
      if (argv[i][2] == '\0' && i + 1 < argc)
      {
        strcpy(proc_input_option[proc_input_option_cnt], "-l");
        strcat(proc_input_option[proc_input_option_cnt], argv[i + 1]);
        proc_input_option_cnt++;
        i++;
      }
      else if (argv[i][2] != '\0')
      {
        strcpy(proc_input_option[proc_input_option_cnt], argv[i]);
        proc_input_option_cnt++;
      }
    }
    
    // parse -Xlinker option
    else if (strcmp(argv[i], "-Xlinker") == 0 && i + 1 < argc)
    {
        strcpy(proc_input_option[proc_input_option_cnt], argv[i + 1]);
        proc_input_option_cnt++;
        i++;
    }
          
    // parse -v option
    else if (argv[i][0] == '-' && argv[i][1] == 'v')
    {
      verbose_mode = 1;
    }
    
    else if (argv[i][0] == '-' && strncmp(argv[i], "--target=", 9) == 0)
    {
      if (strcmp(argv[i], "--target=x86_64-w64-windows-gnu") != 0)
      {
        printf("Unknown target '%s'. Supporting target is 'x86_64-w64-windows-gnu'\n", argv[i]+9);
        return -1;
      }
    }
    
    // parse not an option
    else if (argv[i][0] != '-')
    {
      // it may be an input file of *.o, *.obj or lib*.a
      strcpy(proc_input_option[proc_input_option_cnt++], argv[i]);
    }
	}

	char *ld_argv[MAX_OBJS];

  /*
  HARD: -m i386pep -Bdynamic 
  PASS: -o <output>
  HARD: "mingw64\\x86_64-w64-mingw32\\lib\\crt2.o" 
  HARD: "mingw64\\lib\\gcc\\x86_64-w64-mingw32\\6.3.0\\crtbegin.o" 
  PROC: -L<user -L options> 
  HARD: "-Lmingw64\\lib\\gcc\\x86_64-w64-mingw32\\6.3.0" 
  HARD: "-Lmingw64\\x86_64-w64-mingw32\\lib" 
  HARD: "-Lmingw64\\lib" 
  HARD: "-Lmingw64\\x86_64-w64-mingw32/sys-root/mingw/lib" 
  PROC: object file, -l options, @ options, -Xlinker options are passed sequencially.
  HARD: -lstdc++ -lmingw32 -lgcc_s -lgcc -lmoldname -lmingwex -lmsvcrt -lpthread -ladvapi32 -lshell32 -luser32 -lkernel32 -lmingw32 -lgcc_s -lgcc -lmoldname -lmingwex -lmsvcrt 
  HARD: "mingw64\\lib\\gcc\\x86_64-w64-mingw32\\6.3.0\\crtend.o"
  */  
	int t = 0;
	ld_argv[t++] = path_ld;
	ld_argv[t++] = "-m";
	ld_argv[t++] = "i386pep";
	ld_argv[t++] = "-Bdynamic";
	ld_argv[t++] = "-o";
  
  // User added output option
	ld_argv[t++] = path_output;
  
	sprintf(hard_crt2, "%s\\x86_64-w64-mingw32\\lib\\crt2.o", mingw64_dir);
	ld_argv[t++] = hard_crt2;
	sprintf(hard_crtbegin, "%s\\lib\\gcc\\x86_64-w64-mingw32\\6.3.0\\crtbegin.o", mingw64_dir);
	ld_argv[t++] = hard_crtbegin;
  
  // User added -L options
  for (int i=0; i<proc_L_option_cnt; i++)
  {
    ld_argv[t++] = proc_L_option[i];
  }
  
  sprintf(hard_L_option1, "-L%s\\lib\\gcc\\x86_64-w64-mingw32\\6.3.0", mingw64_dir);
  ld_argv[t++] = hard_L_option1;
  sprintf(hard_L_option2, "-L%s\\x86_64-w64-mingw32\\lib", mingw64_dir);
  ld_argv[t++] = hard_L_option2;
  sprintf(hard_L_option3, "-L%s\\lib", mingw64_dir);
  ld_argv[t++] = hard_L_option3;
  sprintf(hard_L_option4, "-L%s\\x86_64-w64-mingw32/sys-root/mingw/lib", mingw64_dir);
  ld_argv[t++] = hard_L_option4;
  
  // User added object file, -l options, @ options, -Xlinker options
  for (int i=0; i<proc_input_option_cnt; i++)
  {
    ld_argv[t++] = proc_input_option[i];
  }
    
	ld_argv[t++] = "-lstdc++";
	ld_argv[t++] = "-lmingw32";
	ld_argv[t++] = "-lgcc_s";
	ld_argv[t++] = "-lgcc";
	ld_argv[t++] = "-lmoldname";
	ld_argv[t++] = "-lmingwex";
	ld_argv[t++] = "-lmsvcrt";
	ld_argv[t++] = "-lpthread";
	ld_argv[t++] = "-ladvapi32";
	ld_argv[t++] = "-lshell32";
	ld_argv[t++] = "-luser32";
	ld_argv[t++] = "-lkernel32";

	ld_argv[t++] = "-lmingw32";
	ld_argv[t++] = "-lgcc_s";
	ld_argv[t++] = "-lgcc";
	ld_argv[t++] = "-lmoldname";
	ld_argv[t++] = "-lmingwex";
	ld_argv[t++] = "-lmsvcrt";

	sprintf(hard_crtend, "%s\\lib\\gcc\\x86_64-w64-mingw32\\6.3.0\\crtend.o", mingw64_dir);
	ld_argv[t++] = hard_crtend;

	ld_argv[t] = NULL;

  if (verbose_mode)
  {
    PrintProgramName();
    PrintCmdLine(path_ld_exe, ld_argv);
  }
  
	ExecV(path_ld_exe, ld_argv);

	return 0;
}
