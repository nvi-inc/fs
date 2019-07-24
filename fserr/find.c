#include <memory.h>
#include <stdio.h>

#include "fserr.h"

void find(entry, hash)

  struct{
    char buf[2];
    int off;
  } *entry;

  long *hash;

{
  int i;
  int itemp;
  char dig[3];

/* hash section */

  *hash=((abs((*entry).buf[0])-65)/2)*100;
  *hash+=(abs((*entry).buf[1])-65)*10;
  *hash+= abs((*entry).off);
  if (*hash > MAXERRORS) *hash-=MAXERRORS;

}
