#include <ctype.h>
#include <string.h>

char lower(char *buff)
{
  int i, n;
  
  n=strlen(buff);
     
  for (i=0; i < n; i++)
    buff[i] = tolower(buff[i]);
}
