#include <termio.h>
#include <stdio.h>
#include <sys/types.h>
#include <sys/times.h>

long times();

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
  unsigned char inch;
  struct tms tms_buff;
  long end;

  if( *maxc<=0)                /* no buffer extent */
    return -1;

  end= *to >0 ? times(&tms_buff)+*to+1 : -1;  /* calculate ending time */
  *count=-1;
  inch=-1;

/* loop on count and terminating charcater */

  while( ++*count <*maxc && (*termch<0 || *termch != inch) ) {

/* check for time-outs */

    if(end>0) {                                 
      while( end-times(&tms_buff)>0 && ioctl(*port,FIORDCHK,NULL) == 0) 
         rte_sleep( (unsigned) 1);

/* if we timed-out, but there are still characters on the input queue */
/* it might not be the device's fault it timed-out, we might have been */
/* delayed by a busy system, so we won't give-up until the queue is empty */

      if( end-times(&tms_buff)<=0  && ioctl(*port,FIORDCHK,NULL) == 0)
         return -2;                 /* that's it: time-out */
    }
    if(read(*port,&inch,1)!=1)
      return -3;                    /* read error */
    *(buff)++=inch;
  }
/*
  *to=times(&tms_buff)-(end-*to-1);
*/
  return 0;

}
