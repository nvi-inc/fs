#include <sys/types.h>
#include <sys/times.h>
#include <time.h>

unsigned rte_sleep( centisec)
unsigned centisec;
{
    unsigned sleep();

     long times();
     struct tms buffer;
     long start, end, remain;

     start=times(&buffer);
     remain=100-((start-1)%100);
     if ( remain<=centisec) 
        sleep( ((centisec-remain)+99)/100);
     end=start+centisec;
     while (end>times(&buffer))
        ;

    return( (unsigned) 0);
}
