#include <stdio.h>

put_stderr__(string)
     char *string;
{
  fprintf(stderr,string);
}
