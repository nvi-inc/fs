#include <stdio.h>	/* standard I/O header file */
#include <sys/types.h>	/* standard data types definitions */
#include <string.h>    /* shared memory IPC header file */
#include <stdlib.h>
#include <unistd.h>

void prog_exec( name)
char	name[5];
{
    int chpid,i;
    char string[6], *s1;

    s1=memcpy( string, name, 5);
    string[5]='\0';
    switch(chpid=fork()){
      case -1:
        fprintf( stderr,"fork failed for %s\n", string);
        exit( -1);
      case 0:
        i=execlp(string, string, (char *) 0);
        fprintf( stderr,"exec failed on %s\n", string);
        fflush( stderr);
        _exit(-2);
    }
    return;
}
