#include <stdio.h>

void
#ifdef F2C
copen_
#else
copen
#endif
(fp,filename,len)
     FILE **fp;
     char *filename;
     int len;
/* copen opens the file specified by filename
 * the file is opened for reading and writing
 * the file is created if doesn't exist
 * if it already exists, it is truncated to zero length
 * the file pointer is positioned to the beginning of the file
 * on return, *fp is zero if there was an error, non-zero othewise
 */
{
  *fp=fopen(filename,"w+");
  return;
}

int
#ifdef F2C
cclose_
#else
cclose
#endif
(fp)
     FILE **fp;
/* cclose returns 0 if there was no error, non-zero otherwise */
{
  fprintf(*fp,"showpage\n%%%Trailer\n");
  return fclose(*fp);
}


