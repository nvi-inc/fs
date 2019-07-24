#include <string.h>
#include <sys/types.h>

#include "../include/params.h"
#include "../include/cmd_ds.h"

#define MAX_BUF   257

extern struct fscom *shm_addr;

main()
{
    long ip[5];
    struct cmd_ds command;
    int isub,itask,idum,ierr,nchars,i;
    char buf[MAX_BUF];

    int cls_rcv(), cmd_parse();
    void setup_ids(),skd_wait();
    void dist();
    int iold,rte_prior();

    setup_ids();
    iold=rte_prior(FS_PRIOR);

loop:
      skd_wait("quikv",ip,(unsigned) 0);
      if(ip[0]==0) {
        ierr=-1;
        goto error;
      }

      nchars=cls_rcv(ip[0],buf,MAX_BUF,&idum,&idum,0,0);
      if(nchars==MAX_BUF && buf[nchars-1] != '\0' ) { /*does it fit?*/
        ierr=-2;
        goto error;
      }
                                       /* null terminate to be sure */

      if(nchars < MAX_BUF && buf[nchars-1] != '\0') buf[nchars]='\0';

      if(0 != (ierr = cmd_parse(buf,&command))) { /* parse it */
        ierr=-3;
        goto error;
      } 
  
      isub = ip[1]/100;
      itask = ip[1] - 100*isub;

      switch (isub) {
         case 22:
            dist(&command,itask,ip);
            break;
         case 23:
            vrepro(&command,itask,ip);
            break;
         case 24:
            bbc(&command,itask,ip);
            break;
         case 25:
            vform(&command,itask,ip);
            break;
         case 26:
            venable(&command,itask,ip);
            break;
         case 27:
            capture(&command,itask,ip);
            break;
         case 28:
            dqa(&command,itask,ip);
            break;
         case 29:
            tape(&command,itask,ip);
            break;
         case 30:
            vst(&command,itask,ip);
            break;
         case 31:
            rec(&command,itask,ip);
            break;
         case 32:
            mcb(&command,itask,ip);
            break;
         default:
            ierr=-4;
            goto error;
      }
      goto loop;

error:
      for (i=0;i<5;i++) ip[i]=0;
      ip[2]=ierr;
      memcpy(ip+3,"v@",2);
      goto loop;
}
