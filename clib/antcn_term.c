#include <string.h>
#include <stdlib.h>
#include <stdio.h>

static int first=1;
static int value=-1;

antcn_term(out)
int *out;
{
  char *term;

  if(first) {
    term=getenv("FS_ANTCN_TERMINATION");
    if(term) {
      value=10;
      if(1!=sscanf(term,"%d%",&value))
	value=10;
      else if(value<0)
	value=10;
    }
    first=0;
  }

  *out=value;

  return 0;
}
