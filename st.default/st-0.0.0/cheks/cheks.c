/*
 * cheks.c - sample station dependent module checking program
 *
 * REMOVE all printf() calls from non-sample version, they are only for demo
 *
 * Input:
 *   ip[0] != 0 to suppress error reports
 *
 * Output: None
 */

#include <stdio.h>
#include <signal.h>
#include <math.h>
#include <sys/types.h>
#include <string.h>

#include "../../fs/include/dpi.h"
#include "../../fs/include/params.h"
#include "../../fs/include/fs_types.h"
#include "../../fs/include/shm_addr.h"
#include "../../fs/include/fscom.h"

#define MAX_ERR 10                /* this number can be larger */

struct fscom *fs;

void ini_req(), add_req(), end_req(); /*mcbcn request utilities       */
void skd_run(), skd_par();            /* program scheduling utilities */

main()
{
  long ip[5];
  int nreport, checks, i, j;
  int ierr[MAX_ERR];

/* "start" of error numbers for each module, make appropriate for your station
 */

  static int start[4]= {-110, -120, -130, -140};

/* setup IDs for shared memory     */
  setup_ids();
  fs = shm_addr;
  rte_prior(CH_PRIOR);   /* set real-time priority below command processing */

/* set module mnemonics in common, dummy s0 ... s3 */

  memcpy(fs->stcnm[0],"s0",2);
  memcpy(fs->stcnm[1],"s1",2);
  memcpy(fs->stcnm[2],"s2",2);
  memcpy(fs->stcnm[3],"s3",2);

Loop:
    skd_wait("cheks",ip,(unsigned) 0);
    printf(" cheks starting\n");

    nreport=ip[0];
    for (i=0;i<4;i++) {
      printf("loop for module %d\n",i);
      if(memcmp(fs->stcnm[i],"  ",2)==0) /* no module to check */
        continue;
      if(fs->stchk[i] <=0 )              /* not checking */
        continue;

      checks=fs->stchk[i];

/* if using mcbcn make the appropriate request buffers
 * or if using matcn make the appropriate class buffers
 * or for some other module do any preperation that is appropriate
 */

      nsem_take("fsctl",0);

/* get data from module, no more than 1 second (worst case) may elapse between
 * the nsem_take() and nsem_put() calls, this is acheived primarily ny
 * limiting the number of requests handled in one scheduling of the
 * communication program, break the requests down into multiple schedulings
 * and with additional _take and _put calls, for mcbcn schedule:
 *
 *    skd_run("mcbcn",'w',ip);
 *     
 */
      printf("getting data module %d\n",i);

      nsem_put("fsctl");

/*  more stuff for mcbcn:
 *  no check errors, nsem_take and _put cover the minimum amount of
 *  code involved in scheduling communication programs
 *
 *    if(ip[2] <0 ) {
 *       logit(NULL, ip[2], "st");  
 *       continue;
 *    }
 */

      if(nreport == 0) {  /* reporting has been requesting */
         printf("check for errors\n");
         for (j=0;j<MAX_ERR;j++)
            ierr[j]=0;

/* check data from module against expected values, set ierr accordingly
 * add statements to this for your equipment
 */
         printf("check errors for module %d\n",i);

/* skip reporting if stchk[i] has changed */

         if(checks != fs->stchk[i] || fs->stchk[i] <=0)
           continue;

/* report errors */

         printf("report errors for module %d\n",i);
         for (j=0; j<MAX_ERR;j++)
           if(ierr[j]!=0)
             logit(NULL,start[i]-j,"st");
      }
   }
   printf("done\n");
   goto Loop;

}
