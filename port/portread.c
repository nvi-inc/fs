#include <termios.h>
#include <stdio.h>
#include <sys/types.h>
#include <sys/times.h>

static unsigned int ticks_off;
static void ticks0()
{
  struct tms buf;
  time_t t;

  ticks_off= (unsigned int) times(&buf);
}

static int ticks(struct tms *buf)
{
  return (int) ((unsigned int) times(buf) - ticks_off);
}

int portread_(port, buff, count, maxc, termch, to)
int *port, *count, *maxc, *to;
int *termch;
unsigned char *buff;   /* hollerith */
/* portread will read from a port until either *maxc count characters are read
                                            or *termch character is encountered
                                            or *to centisecs elapse
  if any of *termch < 0 or *to <= 0, the corresponding condition is ignored
  the return value is 0 for no error, other errors documented below
  on return buff contains the count characters read so far regardless of error

  port must be set-up with ICANON off and MIN=1 and TIME=1, see TERMIO(7)
  and portopen for details
*/
{
  unsigned int unsl;
  unsigned char inch;
  struct tms tms_buff;
  int end;
  int iret;

  ticks0();

  if( *maxc<=0)                /* no buffer extent */
    return -1;

  end= *to >0 ? ticks(&tms_buff)+*to+1 : -1;  /* calculate ending time */
  *count=-1;
  inch=-1;

  portdelay(*port,0,(*to+9)/10);

/* loop on count and terminating charcater */

  while( ++*count <*maxc && (*termch<0 || *termch != inch)) {

    iret=0;
    while (iret == 0 ) {
      iret=read(*port,&inch,1);
      if (iret == 1)
        break;
      else if (end > 0 && end-ticks(&tms_buff) <= 0)
        return -2;                    /* time-out */
      else if(iret == -1)
        return -3;                    /* read error */
    }
    *(buff)++=inch;
  }
/*   printf(" to %d actual %d\n",*to,ticks(&tms_buff)-(end-*to-1));*/
  return 0;

}
