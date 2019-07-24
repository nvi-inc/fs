#include <stdio.h>
#include <fcntl.h>
#include <termio.h>

static struct termio mcb;

main()

{
int fp;
int i;
unsigned char ch;
int ich;

if ( (fp = open("/dev/ttyi12",O_RDONLY | O_NDELAY)) == -1)
	{
	printf("cannot open terminal\n");
	exit(0);
	}

ioctl (fp,TCGETA,&mcb);   /* get terminal settings */

        /* 9600 baud, 8 char, no parity, read enabled,
   direct connection, disconnect on close. */

mcb.c_cflag = B9600 | CS8 | CREAD | CLOCAL | HUPCL;

mcb.c_lflag = 0;

        /* char functions are INTR, QUIT, ERASE, KILL,
   EOF(min), EOL(time), (reserved), SWTCH.  min=min # char, time = timeout
   value in 0.1 second units */

        mcb.c_cc[0] = 0; /* INTR */
        mcb.c_cc[1] = 0; /* QUIT */
        mcb.c_cc[2] = 0; /* ERASE */
        mcb.c_cc[3] = 0; /* KILL */
        mcb.c_cc[4] = 1;
        mcb.c_cc[5] = 10;    /* timeout value in 0.1 sec units */
        mcb.c_cc[7] = 0;     /* SWTCH */

ioctl (fp,TCSETA,&mcb);  /* set terminal settings */

while(1)
	{
	while (!ioctl(fp,FIORDCHK,NULL)) ;
        read(fp,&ch,1);   
	printf("[%2x]",ch);
	}
	
}
