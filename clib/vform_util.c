/* ifd vlba formatter buffer parsing utilities */

#include <stdio.h>
#include <limits.h>
#include <string.h>
#include <sys/types.h>
#include "../include/params.h"
#include "../include/macro.h"
#include "../include/fs_types.h"
#include "../include/fscom.h"
#include "../include/shm_addr.h"
                                             /* parameter keywords */
static char *key_mode[ ]={ "prn", "a"  , "b"  , "c"  ,
                           "d1" , "d2" , "d3" , "d4" , "d5" , "d6" , "d7" ,
                           "d8" , "d9" , "d10", "d11", "d12", "d13", "d14",
                           "d15", "d16", "d17", "d18", "d19", "d20", "d21",
                           "d22", "d23", "d24", "d25", "d26", "d27", "d28" };
static int mode_trk[ ][32]={
{ -1,  2,  0, 18, 16, 10, 27, 25,  6,  4, 22, 20, 14, 31, 29, -1,
  -1,  3,  1, 19, 17, 11,  9, 26,  7,  5, 23, 21, 15, 13, 30, -1},
{ -1,  3,  1, 19, 17, 11,  9, 26,  7,  5, 23, 21, 15, 13, 30, -1,
  -1,  3,  1, 19, 17, 11,  9, 26,  7,  5, 23, 21, 15, 13, 30, -1},
{ -1,  2,  0, 18, 16, 10, 27, 25,  3,  1, 19, 17, 11,  9, 26, -1,
  -1,  2,  0, 18, 16, 10, 27, 25,  3,  1, 19, 17, 11,  9, 26, -1}
};

static char *key_rate[ ]={ "0.25", "0.5", "1", "2", "4", "8"};
static char *key_chan[ ]={ "at1","at2","at3","aaux","bt1","bt2","bt3","baux"};

                                            /* number of elem. keyword arrays */
#define NKEY_MODE sizeof(key_mode)/sizeof( char *)
#define NKEY_RATE sizeof(key_rate)/sizeof( char *)
#define NKEY_CHAN sizeof(key_chan)/sizeof( char *)

int vform_dec(lcl,count,ptr)
struct vform_cmd *lcl;
int *count;
char *ptr;
{
    int ierr, ind, arg_key(),len,i,j,ivalue,ish;
    unsigned mode, datain;

    ierr=0;
    if(ptr == NULL) ptr="";

    switch (*count) {
      case 1:
        ierr=arg_key(ptr,key_mode,NKEY_MODE,&lcl->mode,2,TRUE);
        if(lcl->mode == 0){
          lcl->format=0x0003;
          lcl->enable.low   =0xFFFF;     /* enable all tracks */
          lcl->enable.high  =0xFFFF;
          lcl->enable.system=0x000F;
        } else {
/* hex version prior to 2.90 */
          if (shm_addr->form_version < 656) 
            lcl->format=0x7000; 
          else
            lcl->format=0x0002;
          lcl->enable.low   =0x7FFE;     /* enable M3 tracks only */
          lcl->enable.high  =0x7FFE;
          lcl->enable.system=0x0000;
        }
        break;
      case 2:
        ierr=arg_key_flt(ptr,key_rate,NKEY_RATE,&lcl->rate,4,TRUE);
        if(ierr==0) lcl->tape_clock=0xA+lcl->rate;
        break;
      case 3:
        len=strlen(ptr);
        if(len>12) len=12;
        for (i=0;i<len;i++) {       /* get the hex values without disturbing */
          sscanf(ptr+i,"%1x",&ivalue);  /* trailing bits */
          ish=4*(3-i%4);
          lcl->aux[0][i/4]=lcl->aux[0][i/4] & ~(0xF<<ish) | ivalue << ish;
        }

        mode=0;                          /* emulate last 16 bits for M3 */
        if(lcl->mode>0 && lcl->mode<4)
          mode=lcl->mode-1;
        else if(lcl->mode>3 && lcl->mode<=3+28)
          mode=3;
        datain=0;
        if(lcl->mode == 0) datain=1;
        lcl->aux[0][3]=(0x3 & mode)<<8|(0x3 & datain)<<10|0xFF & shm_addr->hwid;

        for (i=1;i<28; i++)        /* copy to the rest of the tracks */
          for (j=0;j<4;j++)
            lcl->aux[i][j]=lcl->aux[0][j];
        break;
      case 4:
        ierr=arg_key(ptr,key_chan,NKEY_CHAN,&lcl->qa.chan,3,TRUE);
        lcl->qa.drive=1;
        break;
      default:
       *count=-1;
   }
   if(ierr!=0) ierr-=*count;
   if(*count>0) (*count)++;
   return ierr;
}

void vform_enc(output,count,lcl)
char *output;
int *count;
struct vform_cmd *lcl;
{
    int ind, ivalue, iokay, i, j;
    unsigned int iversion;

    output=output+strlen(output);

    switch (*count) {
      case 1:
        ivalue=lcl->mode;
/* formatter versions prior to version 2.90  in hex */
        if (shm_addr->form_version < 656) iversion = 0x7000;
        else iversion = 0x0002;
        if(ivalue<=0 && lcl->format == 0x0003 &&
              lcl->enable.low    == 0xFFFF &&
              lcl->enable.high   == 0xFFFF &&
              lcl->enable.system == 0x000F)
          strcpy(output,key_mode[0]);
        else if (ivalue  > 0 && lcl->format == iversion &&
              lcl->enable.low    == 0x7FFE &&
              lcl->enable.high   == 0x7FFE &&
              lcl->enable.system == 0x0000 )
          strcpy(output,key_mode[ivalue]);
        else
          strcpy(output,BAD_VALUE);
        break;
      case 2:
        ivalue=lcl->rate;
        if(ivalue>=0 && ivalue <NKEY_RATE && lcl->tape_clock == 0xA+ivalue)
          strcpy(output,key_rate[ivalue]);
        else
          strcpy(output,BAD_VALUE);
        break;
      case 3:
        break;
        iokay=1;
        for (i=1;i<28;i++)     {    /* all 28 tracks must agree */
           for (j=0;j<4;j++) {
              iokay=iokay &&
               ((0xFFFF & lcl->aux[i][j])==(0xFFFF & lcl->aux[0][j]));
           }
        }
        if(iokay )
          sprintf(output,"%04.4x%04.4x%04.4x%04.4x",0xFFFF & lcl->aux[0][0],
                                                    0xFFFF & lcl->aux[0][1],
                                                    0xFFFF & lcl->aux[0][2],
                                                    0xFFFF & lcl->aux[0][3]);
        else if(lcl->mode == 3)
          strcpy(output,BAD_VALUE);
        break;
      case 4:
        ivalue=lcl->qa.chan;
        if((ivalue>=0 && ivalue <NKEY_CHAN) && (lcl->qa.drive == 1))
          strcpy(output,key_chan[ivalue]);
        else
          strcpy(output,BAD_VALUE);
        break;
      default:
       *count=-1;
   }
   if(*count>0) *count++;
   return;
}

void vform_mon(output,count,lcl)
char *output;
int *count;
struct vform_mon *lcl;
{
    int ind;

    output=output+strlen(output);

    switch (*count) {
      case 1:
        sprintf(output,"%x.%02.2x",0xFF&(lcl->version >> 8),0xFF&lcl->version);
        break;
      case 2:
        if(lcl->sys_st==0)
          strcpy(output,"ok");
        else
          sprintf(output,"%04.4x",lcl->sys_st);
        break;
      case 3:
        if(lcl->mcb_st==0)
          strcpy(output,"ok");
        else
          sprintf(output,"%04.4x",lcl->mcb_st);
        break;
      case 4:
        if(lcl->hdw_st==0)
          strcpy(output,"ok");
        else
          sprintf(output,"%04.4x",lcl->hdw_st);
        break;
      case 5:
        if(lcl->sfw_st==0)
          strcpy(output,"ok");
        else
          sprintf(output,"%04.4x",lcl->sfw_st);
        break;
      case 6:
        if(lcl->int_st==0)
          strcpy(output,"ok");
        else
          sprintf(output,"%04.4x",lcl->int_st);
        break;
      default:
        *count=-1;
   }
   if(*count > 0) *count++;
   return;
}

void vform8Dmc(data, lcl)
unsigned *data;
struct vform_cmd *lcl;
{
    *data=lcl->enable.low;
}

void vform8Emc(data, lcl)
unsigned *data;
struct vform_cmd *lcl;
{
    *data=lcl->enable.high;
}

void vform8Fmc(data, lcl)
unsigned *data;
struct vform_cmd *lcl;
{
    *data= 0x8000 | (bits16on(4) & lcl->enable.system);
}

void vform90mc(data, lcl)
unsigned *data;
struct vform_cmd *lcl;
{
    *data=0x8000 | (bits16on(15) & lcl->format); 
}

void vform91mc(data, lcl) 
unsigned *data;
struct vform_cmd *lcl;
{
    *data=0x8000 | (bits16on(3) & lcl->rate);
}

void vform99mc(data, lcl)
unsigned *data;
struct vform_cmd *lcl;
{
    *data= 0x8000 | (bits16on(2) & lcl->qa.drive);
}

void vform9Amc(data, lcl) 
unsigned *data;
struct vform_cmd *lcl;
{
    *data=0x8000 | (bits16on(3) & lcl->qa.chan);
}

void vform9Dmc(data, lcl) 
unsigned *data;
struct vform_cmd *lcl;
{
    *data=0x8032;
}

void vformA6mc(data, hwid) 
unsigned *data;
unsigned char hwid;
{
    *data=0x000 | hwid;
}

void vformADmc(data, lcl) 
unsigned *data;
struct vform_cmd *lcl;
{
    *data=bits16on(4) &lcl->tape_clock;
}

void vformD2mc(itracks, lcl)
int itracks[32];
struct vform_cmd *lcl;
{
     int i, ivalue;

     switch(lcl->mode) {
        case 0:
          for (i=0;i<32;i++)
             itracks[ i]=0;
          break;
        case 1:
        case 2:
        case 3:
          for (i=0;i<32;i++) {
             ivalue=mode_trk[ lcl->mode-1][ i];
             if( ivalue <0 )
               itracks[ i]=0;
             else
               itracks[ i]=0x8000 | (bits16on(5) & ivalue);
          }
          break;
        default:
          for (i=0;i<32;i++)
             itracks[ i]=0;
          i=lcl->mode-3;       /* M3 track number for mode d */
          if(i>=1 || i<=28){
            i=17*(i%2)+i/2;      /* formatter track number */
            itracks[ i]=0x8003;
          }
        break;
     }

     return;
}

void vformD6mc(aux_data,lclc)
unsigned aux_data[28][4];
struct vform_cmd *lclc;
{
    int i, j;

    for (i=0;i<28;i++)
       for (j=0;j<4;j++)
          aux_data[i][j]=lclc->aux[i][j];

    return;
}

void mc20vform(lclm,data)
struct vform_mon *lclm;
unsigned data;
{
      lclm->sys_st=0xF80F & data;
}

void mc21vform(lclm,data)
struct vform_mon *lclm;
unsigned data;
{
      lclm->mcb_st=0xEC3F & data;
}

void mc22vform(lclm,data)
struct vform_mon *lclm;
unsigned data;
{
      lclm->hdw_st=0xFE00 & data;
}

void mc23vform(lclm,data)
struct vform_mon *lclm;
unsigned data;
{
      lclm->sfw_st=0xFE3F & data;
}

void mc24vform(lclm,data)
struct vform_mon *lclm;
unsigned data;
{
      lclm->int_st=0x9FFF & data;
}

void mc60vform(lclm,data)
struct vform_mon *lclm;
unsigned data;
{
      lclm->version=data;
}

void mc8Dvform(lclc,data)
struct vform_cmd *lclc;
unsigned data;
{
      lclc->enable.low= data;
}

void mc8Evform(lclc,data)
struct vform_cmd *lclc;
unsigned data;
{
      lclc->enable.high= data;
}

void mc8Fvform(lclc,data)
struct vform_cmd *lclc;
unsigned data;
{
      lclc->enable.system=bits16on(4) & data;
      if((data & 0x8000)==0) lclc->enable.system=-1;
}

void mc90vform(lclc,data)
struct vform_cmd *lclc;
unsigned data;
{
      lclc->format= bits16on(15) & data;
      if((data & 0x8000)==0) lclc->format=-1;
}

void mc99vform(lclc,data)
struct vform_cmd *lclc;
unsigned data;
{
      lclc->qa.drive=bits16on(2) & data;
      if((data & 0x8000)==0) lclc->qa.drive=-1;
}

void mc9Avform(lclc,data)
struct vform_cmd *lclc;
unsigned data;
{
      lclc->qa.chan=bits16on(3) & data;
      if((data & 0x8000)==0) lclc->qa.chan=-1;
}

void mc91vform(lclc,data)
struct vform_cmd *lclc;
unsigned data;
{
      lclc->rate=bits16on(3) & data;
      if((data & 0x8000)==0) lclc->rate=-1;
}

void mcA6vform(hwid,data)
unsigned data;
unsigned char *hwid;
{
      *hwid=data;
      return;
}

void mcADvform(lclc,data)
struct vform_cmd *lclc;
unsigned data;
{
      lclc->tape_clock=bits16on(4) & data;
      return;
}

void mcD2vform(lclc,itracks)
struct vform_cmd *lclc;
int itracks[ ];
{
       int i,j,irate,imatch, ivalue, im3;

       for (irate=0;irate<3;irate++) {         /* check for modes a, b, & c */
         imatch=TRUE;
         for (i=0;i<32;i++) {                  /* we need an exact match */
           ivalue=mode_trk[ irate][i];
           if(ivalue < 0 )
             imatch=imatch && (itracks[ i]==0);
           else
             imatch=imatch && ((0x8000 | (bits16on(5) & ivalue))==itracks[ i]);
         }
         if(imatch) {
           lclc->mode=irate+1;
           return;
         }
       }
                           /* mode d: exactly 1 track (0-27) set to 0x8003 */
       lclc->mode=-1;                     /* assume bad, so we can return */
       for (i=0;i<32;i++)
          if(itracks[ i] != 0) {
             if((i>30)||(itracks[ i]!=0x8003)) return;
             for (j=i+1;j<32;j++)
                if(itracks[ j]!=0)
                    return;  /* 2 nonzero */
             im3=(i-(i/17)*17)*2+(i/17);    /* m3 track number */
             lclc->mode=im3+3;
             return;
          }
       return;                               /* no non-zero */
}

void mcD6vform(lclc,aux_data)
struct vform_cmd *lclc;
unsigned aux_data[28][4];
{
    int i, j;

    for (i=0;i<28;i++)
       for (j=0;j<4;j++)
          lclc->aux[i][j]=aux_data[i][j];

    return;
}
void aux_config(lcl,ip)
struct vform_cmd *lcl;
long ip[5];
{
    struct req_buf buffer;
    struct req_rec request;
    int i,j, iptr, aux_track;
    unsigned aux_data[28][4];

    ini_req(&buffer);  /* select B so we can set A  */
    memcpy(request.device,DEV_VFM,2);
    request.type=0;
    request.addr=0x84;
    request.data=0x8002; add_req(&buffer, &request);
    end_req(ip,&buffer);
    skd_run("mcbcn",'w',ip);
    skd_par(ip);
    if(ip[2]<0) return;
    cls_clr(ip[0]);
    ip[0]=0;
    rte_sleep( 110);   /* sleep 1.1 seconds to allow B to engage */

/* now set-up a */

    ini_req(&buffer);

    memcpy(request.device,DEV_VFM,2);

    vformD6mc(aux_data, &lcl);

    for (i=0;i<28;i++) {                   /* 28 tracks of aux data */
      aux_track=i+1+(i/14)*2; /* calculate formatter track number */

      iptr=aux_track*16;                   /* indirect address */

      request.type=0;                      /* set aux buffer address */
      request.data=0xFFFF & (iptr>>16);    /* msw */
      request.addr=0xD4; add_req(&buffer,&request);

      request.data=0xFFFF & iptr;          /* lsw */
      request.addr=0xD5; add_req(&buffer,&request);

      request.type=0;                      /* fetch aux data */
      request.addr=0xD6;
      for (j=0;j<4;j++) {
        request.data=lcl->aux[i][j];
        add_req(&buffer,&request);  /* 4 words per track */
      }
    }
    request.addr=0x83;                               /* configure aux */
    request.data=0x8002; add_req(&buffer, &request);

    end_req(ip,&buffer);
    skd_run("mcbcn",'w',ip);
    skd_par(ip);
    if(ip[2]<0) return;
    cls_clr(ip[0]);

    rte_sleep( 40);    /* wait 400 milliseconds for aux-configuration */

    ini_req(&buffer);  /* now select the new aux buffer */
    memcpy(request.device,DEV_VFM,2);
    request.type=0;
    request.addr=0x84;
    request.data=0x8001; add_req(&buffer, &request);
    end_req(ip,&buffer);
    skd_run("mcbcn",'w',ip);
    skd_par(ip);
    if(ip[2]<0) return;
    cls_clr(ip[0]);
    ip[0]=0;

    return;
}
int need_config(new,aux,ip)   /* true if we need to reconfigure */
struct vform_cmd *new;    /* requested new configuration */
int *aux;                 /* aux in use */
long ip[5];               /* ipc array */
{
      struct req_rec request;        /* mcbcn request record */
      struct req_buf buffer;         /* mcbcn request buffer */
      struct res_rec response;
      struct res_buf buff_out;
      struct vform_cmd lclc;
      unsigned itracks[ 32];
      int i,aux_active();
      unsigned high, low, system;

                                     /* get all 'reconfig' parameters */
      ini_req(&buffer);

      memcpy(request.device,DEV_VFM,2);    /* device mnemonic */

                                        /* set indirect track address */
      request.type=0;
      request.data=0;
      request.addr=0xD0; add_req(&buffer,&request);
      request.addr=0xD1; add_req(&buffer,&request);

      request.type=1; request.addr=0xD2;   /* get 32 track assignements */
      for (i=0;i<32;i++)
         add_req(&buffer,&request);

      request.addr=0x84; add_req(&buffer,&request); /* aux in use */
      request.addr=0x8D; add_req(&buffer,&request); /* low track enables */
      request.addr=0x8E; add_req(&buffer,&request); /* high track enables */
      request.addr=0x8F; add_req(&buffer,&request); /* system track enables */
      request.addr=0x90; add_req(&buffer,&request); /* data */
      request.addr=0x91; add_req(&buffer,&request); /* rate */
      request.addr=0x99; add_req(&buffer,&request); /* DQA recorder  */
      request.addr=0x9A; add_req(&buffer,&request); /* DQA mode */
      request.addr=0xAD; add_req(&buffer,&request); /* tape clock */

      end_req(ip,&buffer);
      skd_run("mcbcn",'w',ip);
      skd_par(ip);

      if(ip[2]<0) return FALSE;

      opn_res(&buff_out,ip);
      get_res(&response,&buff_out);
      get_res(&response,&buff_out);

      for(i=0;i<32;i++) {                  /* get the track assignments */
          get_res(&response,&buff_out);
          itracks[i]=response.data;
      }
      mcD2vform(&lclc,itracks);

      get_res(&response,&buff_out); *aux=1-(1 & response.data);
      get_res(&response,&buff_out); mc8Dvform(&lclc,response.data);
      get_res(&response,&buff_out); mc8Evform(&lclc,response.data);
      get_res(&response,&buff_out); mc8Fvform(&lclc,response.data);

      get_res(&response,&buff_out); mc90vform(&lclc,response.data);
      get_res(&response,&buff_out); mc91vform(&lclc,response.data);

      get_res(&response,&buff_out); mc99vform(&lclc,response.data);
      get_res(&response,&buff_out); mc9Avform(&lclc,response.data);
      get_res(&response,&buff_out); mcADvform(&lclc,response.data);

      if(response.state == -1) {
        clr_res(&buff_out);
        ip[2]=-402;
        memcpy(ip+3,"vf",2);
        return FALSE;
      }

      clr_res(&buff_out);

      return
              ( lclc.mode != new->mode) ||
              ( lclc.mode != 0 && lclc.format != new->format) ||
              ( lclc.enable.low    != new->enable.low   ) ||
              ( lclc.enable.high   != new->enable.high  ) ||
              ( lclc.enable.system != new->enable.system) ||
              ( lclc.qa.drive      != new->qa.drive     ) ||
              ( lclc.qa.chan       != new->qa.chan      ) ||
              ( lclc.tape_clock    != new->tape_clock   ) ||
              ( lclc.rate != new->rate);
}

int aux_active(ip)        /* 0=A, 1=B */
long ip[5];               /* ipc array */
{
      struct req_rec request;        /* mcbcn request record */
      struct req_buf buffer;         /* mcbcn request buffer */
      struct res_rec response;
      struct res_buf buff_out;

      ini_req(&buffer);

      memcpy(request.device,DEV_VFM,2);    /* device mnemonic */

      request.type=1;
      request.addr=0x84; add_req(&buffer,&request); /* aux in use */

      end_req(ip,&buffer);
      skd_run("mcbcn",'w',ip);
      skd_par(ip);
      if(ip[2]<0) return;

      opn_res(&buff_out,ip);
      get_res(&response,&buff_out);

      if(response.state == -1) {
        clr_res(&buff_out);
        ip[2]=-403;
        memcpy(ip+3,"vf",2);
        return FALSE;
      }

      clr_res(&buff_out);

      return 1-(1 & response.data);
}
