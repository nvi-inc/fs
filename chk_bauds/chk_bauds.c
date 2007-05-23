#include <stdio.h>

#include <memory.h>
#include <stdio.h>
#include <fcntl.h>
#include <termio.h>
#include <linux/serial.h>
#include <sys/errno.h>

#define MAXLEN 4095
int portopen_();
int portwrite_();
int portread_();

/*
 * This will test the Field System ports.
 */
main(int argc, char *argv[])
{
  /* Passed arguments */
  int ttynum;       /* write to com port: 1-2 or Vikom: 16-23 */
  int ttynum2;      /* read from com port: 1-2 or Vikom: 16-23 */
  int baud_rate;    /* baudrate in Kbaud */
  int parity;       /* parity bit */
  int bits;         /* bits */
  int stop;         /* stop bits */
  int buffsize;     /* read and write buffer size. */
  
  /* Local variables. */
  char terminal[40];    /* name of terminal device. */
  char terminal2[40];   /* name of terminal device. */
  char string[5];       /* place holder for int to char */
  int open_err;         /* terminal error on open. */
  int open2_err;        /* terminal2 error on open.  */
  char buff[MAXLEN];
  char buff2[MAXLEN];
  int len;
  int termch, err, count, to;
  int i;
  int read_errors=0;
  int write_errors=0;

  /* presenting a time stamp */
  char *ctime(), *time_only, *today;
  long thetime, time();

  if ( argc <= 1)
    {
      printf("This function reads and/or writes to a COM(0 or 1) ports or\n");
      printf("VIKOM 16-23 ports.\n");
      printf("Cable connect port A to port B and run the test.\n");
      printf("Any port COM or VIKOM can be port A, and the same hold true\n");
      printf("for port B\n");
      printf("example: chk_bauds A\n");
      printf("example: chk_bauds A B\n");
      printf("example: chk_bauds A B baud\n");
      printf("example: chk_bauds A B baud parity\n");
      printf("example: chk_bauds A B baud parity bits\n");
      printf("example: chk_bauds A B baud parity bits stop\n");
      printf("example: chk_bauds A B baud parity bits stop buffsize\n");
      printf("\n");
      printf("example: chk_bauds 0 16 57600 0 8 2 255\n");
      printf("Port A is COM0 and Port B is VIKOM16\n");
      printf("baud rate: 57600\n");
      printf("parity: 0\n");
      printf("bits: 8\n");
      printf("stop bit: 2\n");
      printf("buffer size: 255\n");
      printf("These are also defaults, except for Port A\n");
      return;
    }
  else if(argc <= 2)
    {
      ttynum = atoi(argv[1]);
      ttynum2 = 1;
      baud_rate = 57600;
      parity = 0;
      bits = 8;
      stop = 1;
      buffsize = 256;
    }
  else if(argc <= 3)
    {
      ttynum = atoi(argv[1]);
      ttynum2 = atoi(argv[2]);
      baud_rate = 57600;
      parity = 0;
      bits = 8;
      stop = 1;
      buffsize = 256;
    }
  else if(argc <= 4)
    {
      ttynum = atoi(argv[1]);
      ttynum2 = atoi(argv[2]);
      baud_rate = atoi(argv[3]);
      parity = 0;
      bits = 8;
      stop = 1;
      buffsize = 256;
    }
  else if(argc <= 5)
    {
      ttynum = atoi(argv[1]);
      ttynum2 = atoi(argv[2]);
      baud_rate = atoi(argv[3]);
      parity = atoi(argv[4]);
      bits = 8;
      stop = 1;
      buffsize = 256;
    }
  else if(argc <= 6)
    {
      ttynum = atoi(argv[1]);
      ttynum2 = atoi(argv[2]);
      baud_rate = atoi(argv[3]);
      parity = atoi(argv[4]);
      bits = atoi(argv[5]);
      stop = 1;
      buffsize = 256;
    }
  else if(argc <= 7)
    {
      ttynum = atoi(argv[1]);
      ttynum2 = atoi(argv[2]);
      baud_rate = atoi(argv[3]);
      parity = atoi(argv[4]);
      bits = atoi(argv[5]);
      stop = atoi(argv[6]);
      buffsize = 256;
    }
  else
    {
      ttynum = atoi(argv[1]);
      ttynum2 = atoi(argv[2]);
      baud_rate = atoi(argv[3]);
      parity = atoi(argv[4]);
      bits = atoi(argv[5]);
      stop = atoi(argv[6]);
      buffsize = atoi(argv[7]);
    }

  /* Check for legal tty number. */
  if ( (ttynum < 0) || (ttynum > 1) )
    {
      if( (ttynum < 4) || (ttynum > 23)) 
	{    
	  /* Illegal tty number. */
	  printf("VIKOM - ERROR %d\n", ttynum);
	  return -1;
	}
    }
  /* Check for legal tty number. */
  if ( (ttynum2 < 0) || (ttynum2 > 1) )
    {
      if( (ttynum2 < 4) || (ttynum2 > 23)) 
	{    
	  /* Illegal tty number. */
	  printf("VIKOM - ERROR %d\n", ttynum2);
	  return -1;
	}
    }
  /* Create device name. */
  sprintf (terminal, "/dev/ttyS%d", ttynum);
  sprintf (terminal2, "/dev/ttyS%d", ttynum2);

  /* position on the screen. */
  printf("%c[%d;%dH",27,0,0);
  printf("%c[2J",27);

  /* OPEN devices terminal and terminal2. */
  len = strlen(terminal);
  open_err = portopen_(&ttynum, terminal, &len,
		   &baud_rate, &parity, &bits, &stop);
  len = strlen(terminal2);
  open2_err = portopen_(&ttynum2, terminal2, &len,
		   &baud_rate, &parity, &bits, &stop);

  /* Display parameters on the screen. */
  printf("terminal_1:%s\nterminal_2:%s\nbaud_rate:%d\nparity:%d\nbits:%d\nstop_bit:%d\n",terminal,terminal2,baud_rate, parity, bits, stop);
  printf("** open errors one:%d-and two:%d **\n",open_err,open2_err);

  termch=0x0a;
  /* Get start time. */
  thetime = time(0);
  today = ctime(&thetime);
  time_only = &today[11];
  time_only[9] = '\0';
  printf("Starting at %s\n",time_only);
  buff[0]='\0';
  for(i=1; i<buffsize; i++)
    {
      /*
       * setup the by converting the i integer to ascii and adding it to
       * buff.
       */
      itoa(i,string);
      string[strlen(string)] = '\0';
      strcat(buff,string);
      strcat(buff," ");
      buff[strlen(buff)] = '\0';
      len = strlen(buff);

      /* write to a port */
      printf("%c[%d;%dH",27,9,0);
      err = portwrite_(&ttynum, buff, &i);
      printf("->write (errors:%d) - (buffer_size:%d)\n", err, i);
      if(err<0) write_errors++;

      /* get the time and display it. */
      to=100;
      thetime = time(0);
      today = ctime(&thetime);
      time_only = &today[11];
      time_only[9] = '\0';
      printf(" TIME: %s\n",time_only);

      /* read from a port */
      err = portread_(&ttynum2, buff2, &count, &i, &termch, &to);
      buff2[count] = '\0';
      printf("->read (errors:%d) - (buffer_size:%d)\n", err, strlen(buff2));
      if(err<0) read_errors++;
    }
  /* Return. */
  portclose_(&ttynum);
  portclose_(&ttynum2);
  printf("READ ERRORS: %d - WRITE ERRORS: %d\n",read_errors,write_errors);
  return 0;
}
/* ******************************* */
/* convert integer to ascii string */
/* ******************************* */
int 
itoa(int n, char s[])
{
  int k=n;
  int i, j, c;
  int sign;
  /* this has to be done in reverse order */
  if(((sign=n) < 0)) n = -n; 
  i = 0;
  do {    
      s[i++] = n % 10 + '0'; 
  }
  while ((n /= 10) > 0);
  if(sign<0)  s[i++]='-';
  s[i]='\0';

  /* correct for reverse order */
  for(i=0, j=strlen(s)-1; i<j; i++, j--)
    { c=s[i];
      s[i]=s[j];
      s[j]=c; }
}







