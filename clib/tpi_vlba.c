/* tpi support utilities for VLBA rack */
/* tpi_vlba formats the buffers and runs mcbcn to get data */
/* tpput_vlba stores the result in fscom and formats the output */
/* tsys_vlba does tsys calculations for tsysX commands */

#include <math.h>
#include <string.h>
#include <sys/types.h>

#include "../include/params.h"
#include "../include/fs_types.h"
#include "../include/fscom.h"
#include "../include/shm_addr.h"

static char ch[ ]={"123456789abcde"};

void tpi_vlba(ip,itpis_vlba)                    /* sample tpi(s) */
long ip[5];                                     /* ipc array */
int itpis_vlba[MAX_DET]; /* detector selection array */
                      /* in order: bbc1(U), bbc1(L), ..., bbc14(U), bbc14(L), */
                      /*           ia, ib, ic, id; value: 0=don't use, 1=use */
{
    struct req_buf buffer;
    struct req_rec request;
    int i;

    ini_req(&buffer);
    request.type=1;

    for (i=0;i<MAX_DET;i++) {
     if(1==itpis_vlba[i]) {
       if(i<(2*MAX_BBC)) {                   /* bbc(s): */
         request.device[0]='b';
         request.device[1]=ch[i%MAX_BBC];                /* '1'-'e' */
       } else {                              /* ifd(s): */
         request.device[0]='i';
         request.device[1]=ch[((i-2*MAX_BBC)/2)*2+9];   /* 'a' or 'c' */
       }
#if 0
       if(0==(i%2)) request.addr=0x06;        /* USB or ia or ic */
       else request.addr=0x07;                /* LSB or ib or id */
#endif
       if (i<MAX_BBC || (i>=2*MAX_BBC && 1==(i%2)))
         request.addr=0x07;
       else
         request.addr=0x06;

       add_req(&buffer,&request);
     }
    }
    end_req(ip,&buffer);                /* end request buffer and do it */
    skd_run("mcbcn",'w',ip);
    skd_par(ip);

    return;
}
    
void tpput_vlba(ip,itpis_vlba,isub,ibuf,nch,ilen) /* put results of tpi */
long ip[5];                                    /* ipc array */
int itpis_vlba[MAX_DET]; /* device selection array, see tpi_vlba for details */
int isub;                /* which task: 3=tpi, 4=tpical, 7=tpzero */
char *ibuf;              /* out array, formatted results placed here */
int *nch;                /* next available char index in ibuf on entry */
                         /* the total count on exit, counts from 1 , not 0 */
int ilen;                /* number of characters ibuf can hold, ignored */
{
    struct res_buf buffer_out;
    struct res_rec response;
    unsigned *ptr;
    int i;

    opn_res(&buffer_out,ip);

    switch (isub) {                        /* set the pointer for the type */
       case 3: ptr=shm_addr->tpi; break;
       case 4: ptr=shm_addr->tpical; break;
       case 7: ptr=shm_addr->tpizero; break;
       default: ptr=shm_addr->tpi; break;    /* just being defensive */
    };

    ibuf[*nch-1]='\0';              /* NULL terminate to make STRING */

    for (i=0;i<MAX_DET;i++) {
       if(itpis_vlba[ i] == 1) {
         get_res(&response,&buffer_out);
         ptr[i]=response.data;
         if(response.data > 65534 ) {
           strcat(ibuf,"$$$$$,");
         } else {
           uns2str(ibuf,response.data,5);
           strcat(ibuf,",");
         }
       }
    }
    if(response.state == -1) {
       clr_res(&buffer_out);
       ip[2]=-401;
       memcpy(ip+3,"qk",2);
       return;
    }
    clr_res(&buffer_out);
    *nch=strlen(ibuf)-1;         /* update nch counting from 1 */
                                 /* but delete the last comma */
         
    ip[2]=0;
    return;
}

void tsys_vlba(itpis_vlba,ibuf,nch,caltmp)
int itpis_vlba[MAX_DET]; /* device selection array, see tpi_vlba for details */
char *ibuf;              /* out array, formatted results placed here */
int *nch;                /* next available char index in ibuf on entry */
                         /* the total count on exit, counts from 1 , not 0 */
float caltmp;
{
       int i;
       float tpi,tpic,tpiz;

       ibuf[*nch-1]='\0';                 /* null terminate so a STRING */
       for (i=0;i<MAX_DET;i++) {
         if(itpis_vlba[ i] == 1) {
           tpi=shm_addr->tpi[ i];             /* various pieces */
           tpic=shm_addr->tpical[ i];
           tpiz=shm_addr->tpizero[ i];        /* avoid overflow | div-by-0 */
           if(fabs((double)(tpic-tpi))<0.5 || tpic > 65534 || tpi > 65534
              || tpiz < 1 )
             shm_addr->systmp[ i]=1e9;
           else
             shm_addr->systmp[ i]=(tpi-tpiz)*caltmp/(tpic-tpi);
           flt2str(ibuf,shm_addr->systmp[ i],8,1);
           strcat(ibuf,",");
         }
       }

       *nch=strlen(ibuf)-1;                   /* delete final comma */
       return;
}
