#include <unistd.h>
#include <windows.h>

#define MAX_CMD_LINE 8000

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

#ifndef NO_WAIT_CREATED_PROCESS_TERM
	// Now 'pi.hProcess' contains the process HANDLE, which you can use to wait for it like this:
	WaitForSingleObject(pi.hProcess, INFINITE);
#endif
	return 0;
}
