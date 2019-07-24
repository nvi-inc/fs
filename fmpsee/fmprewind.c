#include <stdio.h>
#include <unistd.h>
#include <errno.h>

void fmprewind_(dcb,error)

FILE **dcb;
int *error;

{

 if (*error = fseek(*dcb,0L,SEEK_SET) == EOF); 

}
