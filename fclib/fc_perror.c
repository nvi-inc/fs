#include <stdio.h>

int fc_perror__( string)
char *string;
{
  perror(string);

  return;
}
