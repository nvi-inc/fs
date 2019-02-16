#include <stdio.h>
#include <sys/times.h>
#include <sys/time.h>
#include <unistd.h>
#include <stdlib.h>

/*
 * Compare systems times to system time, this might detect steps in NTP
 */
main(int argc, char *argv[])
{

  struct tms buffer;
  struct timeval tv0, tv;

  clock_t ticks;
  unsigned int ticks0, ticks_diff, ticks0_save;
  int first=1;
  
  while(first || ticks0!=ticks0_save) {
    first=0;
    ticks=times(&buffer);
    if(ticks == (clock_t) -1) {
      perror("using times() initially");
      exit(-1);
    }
    ticks0_save=ticks0;
    ticks0=ticks;
    
    if(0!= gettimeofday(&tv0, NULL)) {
      perror("using getttimeofday() initially");
      exit(-1);
    }
  }

  for (;;) {
    ticks=times(&buffer);
    if(ticks == (clock_t) -1) {
      perror("using times()");
      exit(-1);
    }

    if(0!= gettimeofday(&tv, NULL)) {
      perror("using getttimeofday()");
      exit(-1);
    }

    if(0==
       (((tv.tv_sec-tv0.tv_sec)*1000000ll+(tv.tv_usec-tv0.tv_usec))/1000)%1000) {

    printf("%llu %lu %llu\n",
	   ((tv.tv_sec-tv0.tv_sec)*1000000ll+(tv.tv_usec-tv0.tv_usec))/1000,
	   (unsigned int)ticks-ticks0,
	   ((unsigned int)ticks-ticks0)-
	   (((tv.tv_sec-tv0.tv_sec)*1000000ll+(tv.tv_usec-tv0.tv_usec))/10000)
	   );
    fflush(stdout);
    }
    if(0!= usleep(1000)) {
      perror("using usleep");
      exit(-1);
    }
  }
}
