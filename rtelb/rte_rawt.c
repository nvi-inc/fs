/* rte_rawt.c - return raw system time in clock HZ */

#include <sys/types.h>
#include <sys/times.h>
#include <sys/time.h>
#include <unistd.h>

#include "../include/params.h"
#include "../include/fs_types.h"
#include "../include/fscom.h"
#include "../include/shm_addr.h"

void rte_rawt(lRawTime)
long *lRawTime;
{
     long times();
     struct tms buffer;
     struct timeval tv;
     int index;

     index=01 & shm_addr->time.index;
     if(shm_addr->time.model!='c'
	&& shm_addr->time.epoch[index]!=0
	&& shm_addr->time.icomputer[index]==0 ) {
       *lRawTime=times(&buffer);
     } else {
       if(0!= gettimeofday(&tv, NULL)) {
	 perror("getting timeofday, fatal\n");
	 exit(-1);
       }
       *lRawTime=(tv.tv_sec-shm_addr->time.secs_off)*100
	 +(tv.tv_usec+5000)/10000;
     }

     return;
}
