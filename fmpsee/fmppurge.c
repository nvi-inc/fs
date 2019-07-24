#include <stdio.h>

int fmppurge_(filename, len)

  char filename[];
  int *len;
{
  int err;

  filename[*len] = '\0';
  err = remove(filename);

  return err;
}
