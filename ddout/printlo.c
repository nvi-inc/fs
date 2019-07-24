/* printlo.c - print to standard output and log out devices */

#include <stdio.h>
#include <sys/types.h>

#include "../include/params.h"
#include "../include/fs_types.h"
#include "../include/fscom.h"
#include "../include/shm_addr.h

extern FILE *stream[];

printlo(sFormat, sString)
char *sFormat, *sString;
{
     int i;

     if( 0 > printf(sFormat,sString))
        perror("Error writing stdout in ddout");

     for (i=0; i< shm_addr->ndevlog; i++)
	if( 0 > fprintf(stream[i],sFormat,sString)) {
          fprintf(stderr,"Error writing to log out file %d\n",i);
          perror("ddout");
        }
}
