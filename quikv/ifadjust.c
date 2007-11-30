/* mark III/IV ifadjust snap command */
/* This program will evaluate and recommend attenuator settings. */

#include <stdio.h> 
#include <string.h> 
#include <sys/types.h>
#include <time.h>
#include <math.h>

#include "../include/params.h"
#include "../include/fs_types.h"
#include "../include/fscom.h"         /* shared memory definition */
#include "../include/shm_addr.h"      /* shared memory pointer */

#define MAX_BUF 256
#define MAX_OUT 256

int get_att();
int get_itp();
int set_att();
int reset_vc();
int set_vc_sb();
void skd_run(), skd_par();      /* program scheduling utilities */

void ifadjust(command,itask,ip)
     struct cmd_ds *command;                /* parsed command structure */
     int itask;                            /* sub-task, ifd number +1  */
     long ip[5];                           /* ipc parameters */
{
  short int buff[MAX_BUF];
  int i, j, k, l, ierr=0, itry;
  int iat[4], iat_keeper[4]; /* save attenuator settings for all three IFs and
				the save ORs for the IF3 switches. */
  int nchar,idum;
  int nrec, itp, itpz[14], iuse[14];
  long iclass;
  int iact,imin[3],imax[3],imxv[3],imnv[3],icur[3],inew[3];
  int below[3], lu[2];
  int vcnum_l[14], vcnum_u[14], sb_flag;/* place holders */
  int *vcnum;                           /* LSB or USB pointers */
  int *vcnum_p;
  int saveatt[3], itp_ref, lu_conv[2]; 
  int patched_ifs[3],lp[3],up[3], patch_id[14];
  int kok[3];
  char *lu_msg;                    /* which is it USB or LSB message. */ 
  char isave[4];
  char which, *isave3;
  char *vc_parms_save[14][10];          /* save values for resetting */
  char array[7], array_save[7], line1[6], msg[40];
  char lvcn[] = {"v1v2v3v4v5v6v7v8v9vavbvcvdve"};
  char output[MAX_OUT];
  FILE *fp;
  
  /* initialize */
  patched_ifs[0]=patched_ifs[1]=patched_ifs[2]=0; /* patches */ 
  lp[0]=lp[1]=lp[2]=0;                            /* LSB patches */ 
  up[0]=up[1]=up[2]=0;                            /* USB patches */ 
  iat_keeper[0]=iat_keeper[1]=0;                  /*att. settings*/ 
  iat_keeper[2]=iat_keeper[3]=0; 
  lu_conv[0]=lu_conv[1]=0;                        /* converaged */ 
  sb_flag=0;                                      /* L or U sideband flag. */ 
  itp_ref=3300;                                   /* tpi ref. default. */ 
  lu[0]=lu[1]=0;                                  /* LSB or USB 
						     inuse=1, not-inuse=0 */ 
  brk_chk( "quikv"); /* BREAK INIT!! */ 

  /* 
   * First parameter could also be a settable target level for TPI counts
   * (default is 3300 counts). 
   */

  if(command->argv[0]!=0){
    sscanf(command->argv[0],"%s",line1);
    itp_ref=atoi(line1);
    /* This will be opened in Phase II of ifadjust. */
    if(!itp_ref) {
      itp_ref=3300;
    }
  }

  /* Initialize LSB and USB initial place holders*/
  for(i=0;i<14;i++) {
    vcnum_l[i]=vcnum_u[i]=-1;
  }

  /* check for if/video converter patch */
  iact=0;
  for(i=0;i<14;i++) {
    iuse[i]=abs(shm_addr->ifp2vc[i]) >0 && abs(shm_addr->ifp2vc[i]) <4;
    if(iuse[i]) {
      if(abs(shm_addr->ifp2vc[i])==1) {
	patched_ifs[0]=1;
	patch_id[i]=1;
      } else if(abs(shm_addr->ifp2vc[i])==2) {
	patched_ifs[1]=2;
	patch_id[i]=2;
      } else if(abs(shm_addr->ifp2vc[i])==3) {
	patched_ifs[2]=3;
	patch_id[i]=3;
      }
    }
    iact|=iuse[i];
  }

  /* If none are patch there is no reason to continue. */
  if(!iact) {
    ierr=-501;
    goto error;
  }

  if(shm_addr->equip.rack == MK4) {
    /* Get trackform information. vcnum=vc#, sb_ul=sideband */
    for(i=0,j=0,k=0;i<64;i++) {
      if(shm_addr->form4.codes[i]!=-1) {
        if(((1<<4)&shm_addr->form4.codes[i]) && 
           !(shm_addr->form4.codes[i]>>6 & 0x3)) {
	  int ivc,m;
	  ivc=shm_addr->form4.codes[i]&0xF;
	  for (m=0;m<j;m++)
	    if(vcnum_l[m]==ivc)    goto endl;
          vcnum_l[j]=shm_addr->form4.codes[i]&0xF;
          /* Look for the patch */
          if(!iuse[vcnum_l[j]]) {
            ierr=-511;
            goto error;
          }
          l=patch_id[vcnum_l[j]];
          lp[l-1]=l;
          /* */
          lu[0]=1;
          j++;
	endl: ;
	} else if(!((1<<4)&shm_addr->form4.codes[i]) && 
                  !(shm_addr->form4.codes[i]>>6 & 0x3)) {
	  int ivc,m;
	  ivc=shm_addr->form4.codes[i]&0xF;
	  for (m=0;m<k;m++)
	    if(vcnum_u[m]==ivc)
	      goto endu;
          vcnum_u[k]=shm_addr->form4.codes[i]&0xF;
          /* Look for the patch */
          if(!iuse[vcnum_u[k]]) {
            ierr=-511;
            goto error;
          }
          l=patch_id[vcnum_u[k]];
          up[l-1]=l;
          /* */
          lu[1]=1;
          k++;
	endu: ;
        }
      }
    }
  } else /* Mark III */ {
    if(shm_addr->imodfm == 0 ) { /* mode A */
      for(i=0;i<14;i++) {
        vcnum_l[i]=i;
        /* Look for the patch */
        if(!iuse[vcnum_l[i]]) {
          ierr=-511;
          goto error;
        }
        l=patch_id[vcnum_l[i]];
        lp[l-1]=l;
        /* */
        lu[0]=1;

        vcnum_u[i]=i;
        /* Look for the patch */
        if(!iuse[vcnum_u[i]]) {
          ierr=-511;
          goto error;
        }
        l=patch_id[vcnum_u[i]];
        up[l-1]=l;
        /* */
        lu[1]=1;
      }
    } else if(shm_addr->imodfm == 1 ) { /* mode B */
      for(i=0;i<7;i++) {
        vcnum_l[i]=2*i;
        /* Look for the patch */
        if(!iuse[vcnum_l[i]]) {
          ierr=-511;
          goto error;
        }
        l=patch_id[vcnum_l[i]];
        lp[l-1]=l;
        /* */
        lu[0]=1;

        vcnum_u[i]=2*i;
        /* Look for the patch */
        if(!iuse[vcnum_u[i]]) {
          ierr=-511;
          goto error;
        }
        l=patch_id[vcnum_u[i]];
        up[l-1]=l;
        /* */
        lu[1]=1;
      }
    } else if(shm_addr->imodfm == 2 ) { /* mode C */
      for(i=0;i<14;i++) {
        vcnum_u[i]=i;
        /* Look for the patch */
        if(!iuse[vcnum_u[i]]) {
          ierr=-511;
          goto error;
        }
        l=patch_id[vcnum_u[i]];
        up[l-1]=l;
        /* */
        lu[1]=1;
      }
    } else if(shm_addr->imodfm == 3 ) { /* mode D */
      for(i=0;i<1;i++) {
        vcnum_u[i]=i;
        /* Look for the patch */
        if(!iuse[vcnum_u[i]]) {
          ierr=-511;
          goto error;
        }
        l=patch_id[vcnum_u[i]];
        up[l-1]=l;
        /* */
        lu[1]=1;
      }
    }
  }

  if(!lu[0]) {
    /* if LSB wasn't specified. */
    sprintf(msg,"ifadjust/%d,00,00,00,LSB None Found",
	    itp_ref);
    logitf(msg);
  }

  if(!lu[1]) {
    /* if USB wasn't specified. */
    sprintf(msg,"ifadjust/%d,00,00,00,USB None Found",
	    itp_ref);
    logitf(msg);
  }


  /* 
   * Now we need to see what sideband the video converters are set to
   * and save it under vc_parms_save.
   */

  for(i=0; i<14; i++) {
    int j;
    for(j=0;j<14;j++) {
      if(vcnum_l[j]==i||vcnum_u[j]==i) {
	goto get;
      }
    }
    continue;
  get:
    iclass=0;
    nrec=0;
    memcpy(buff+1,lvcn+i*2,2);
    buff[0]=-1;
    cls_snd(&iclass,buff,4,0,0); nrec++;
    
    ip[0]=iclass;
    ip[1]=nrec;
    
    skd_run("matcn",'w',ip);
    skd_par(ip);
    
    if(ip[2]<0) return;
    iclass=ip[0];
      
    nchar=cls_rcv(iclass,buff,MAX_BUF,&idum,&idum,0,0); 
    memcpy(&vc_parms_save[i][0],(char *)buff,10);
  }

  /* get attenuator settings */
  if(ierr = get_att(patched_ifs,&iat_keeper,&isave,&isave3)) return; 

  /* Do LSB first */  
  which='l';

  /* pointer for processing the sample loop.*/
  vcnum=vcnum_l;
  vcnum_p=vcnum;
  
  itry=0;                         /* start from scatch */
  /* give me the patches for LSB */
  patched_ifs[0]=lp[0];
  patched_ifs[1]=lp[1];
  patched_ifs[2]=lp[2];
  lu_msg = "LSB Step\0";

  /* 
   * Check to see if the operator simply wants to save the attenuator,or
   * wants to take attenuator settings from the ifatt.ctl file, 
   * and use the value matching the mode.
   */

  /* Check for LSB first. */
  if(lu[0]) {
    goto set_it_up;
  } else {
    lu_conv[0]=1;
    goto uplow;
  } 

  /* sample loop */
sample:
  if(brk_chk( "quikv")) {
    ierr=-510;
    goto error;
  }
  /* Get Total Power reading */
  if(itry >= 8) {
    if(!sb_flag) {
      sprintf(msg,"ifadjust/%d,%02d,%02d,%02d,LSB Failed",
	      itp_ref,inew[0],inew[1],inew[2]);
      logitf(msg);
      lu_conv[0]=1;
      itry=0;
      goto uplow;
    } else {
      sprintf(msg,"ifadjust/%d,%02d,%02d,%02d,USB Failed",
	      itp_ref,inew[0],inew[1],inew[2]);
      logitf(msg);
      lu_conv[1]=1;
    }
    if(sb_flag && lu_conv[0] && lu_conv[1]) {
      for(i=0;i<3;i++)
	if(!kok[i])
	  logit(NULL,-506-i,"if");
      if(ierr=set_att(iat[0],iat[1],iat[2],
		      patched_ifs,&iat,isave,&isave3))
	return;
      if(ierr=reset_vc(vc_parms_save,vcnum_l,vcnum_u))
	return;
      ierr=-505;
      goto error;
    } else {
      goto sample2;
    }
  }
  
  iclass=0;
  nrec = 0;
  buff[0]=-2;
  
  vcnum=vcnum_p;
  for (i=0;*vcnum!=-1 && i<14;i++,*vcnum++) {
    if(iuse[*vcnum]) {
      memcpy(buff+1,lvcn+(*vcnum)*2,2);
      cls_snd(&iclass,buff,4,0,0); nrec++;
    }
  }

  ip[0]=iclass;
  ip[1]=nrec;
  
  skd_run("matcn",'w',ip);
  skd_par(ip);
  
  if(ip[2]<0) return;
  iclass=ip[0];
  
  if(nrec != ip[1]) {
    ierr=-503;
    cls_clr(ip[0]);
    goto error;
  }
  

  vcnum=vcnum_p;

  /* Initialize IF values. */
  below[0]=below[1]=below[2]=0;
  for (i=0;*vcnum!=-1 && i<14;i++,*vcnum++)
    if(iuse[*vcnum]) {
      nchar=cls_rcv(iclass,buff,MAX_BUF,&idum,&idum,0,0);
      ((char *) buff)[nchar]=0;
      if(1!=sscanf(((char *)buff)+6,"%4x",&itp)) {
	ierr=-504;
	ip[4]=i;
	goto error;
      }
      /* Start polling for Total Power 
      if(abs(shm_addr->ifp2vc[vcnum[i]])==1) {	
	below[0]|=(itp-itpz[i])<itp_ref;
      } else if(abs(shm_addr->ifp2vc[vcnum[i]])==2) {
	below[1]|=(itp-itpz[i])<itp_ref;
      } else if(abs(shm_addr->ifp2vc[vcnum[i]])==3) {
	below[2]|=(itp-itpz[i])<itp_ref;
      }
    }*/
      /* Start polling for Total Power */
      if(abs(shm_addr->ifp2vc[*vcnum])==1) {	
	below[0]|=(itp-itpz[i])<itp_ref;
      } else if(abs(shm_addr->ifp2vc[*vcnum])==2) {
	below[1]|=(itp-itpz[i])<itp_ref;
      } else if(abs(shm_addr->ifp2vc[*vcnum])==3) {
	below[2]|=(itp-itpz[i])<itp_ref;
      }
    }

  for(i=0;i<3;i++) {
    /* Check IFx  */
    if(patched_ifs[i]){
      if(below[i]) {
	imax[i]=icur[i];
	imxv[i]=1;
      } else {
	imin[i]=icur[i];
	imnv[i]=1;
      }
    }
  }

  for(i=0;i<3;i++) {
    /* Check IFx */
    if(patched_ifs[i]){
      if(imax[i]-imin[i] != 1) {
	inew[i]=abs(imin[i]+imax[i])>>1;
      } else if(imxv[i]==0) { 
	inew[i]=imax[i];
      } else {
	inew[i]=imin[i];
      }
    }
  }

  kok[0]=(!patched_ifs[0])||(imax[0]-imin[0]==1&&imxv[0]&&imnv[0]);
  kok[1]=(!patched_ifs[1])||(imax[1]-imin[1]==1&&imxv[1]&&imnv[1]);
  kok[2]=(!patched_ifs[2])||(imax[2]-imin[2]==1&&imxv[2]&&imnv[2]);

  if(!kok[0] || !kok[1] || !kok[2]) {
  /*
   * check to see if we need to change attenuator for IF1 and IF2.
   * then check to see if we need to change attenuator for IF3.
   */
    sprintf(msg,"ifadjust/%d,%02d,%02d,%02d,%s %d",
	    itp_ref,inew[0],inew[1],inew[2],&lu_msg[0],itry);
    logitf(msg);

    if(ierr=set_att(inew[0],inew[1],inew[2],patched_ifs,&iat, isave,&isave3))
      return; 

    rte_sleep(200);
    icur[0]=inew[0];
    icur[1]=inew[1];
    icur[2]=inew[2];
    itry++;
    goto sample;
  }
  if(patched_ifs[0])
    inew[0]=imin[0];
  if(patched_ifs[1])
    inew[1]=imin[1];
  if(patched_ifs[2])
    inew[2]=imin[2];
  if(!sb_flag) {
    sprintf(msg,"ifadjust/%d,%02d,%02d,%02d,LSB Converged",
	    itp_ref,inew[0],inew[1],inew[2]);
    logitf(msg);
  } else {
    sprintf(msg,"ifadjust/%d,%02d,%02d,%02d,USB Converged",
	    itp_ref,inew[0],inew[1],inew[2]);
    logitf(msg);
  }

  /* here to switch from to lower to upper sidebands */  
uplow:
  if(!sb_flag) {

    /* Save the attenuator settings if LSB was done. */
    if(lu[0]) {
      saveatt[0]=inew[0];
      saveatt[1]=inew[1];
      saveatt[2]=inew[2];
    }
    /* Initialize USB place holders */
    vcnum=vcnum_u;
    vcnum_p=vcnum;
    itry=0;                       /* start from scatch */
    which='u';                    /* Let's do USB */
    sb_flag=1;                    /* flag to USB */
    patched_ifs[0]=up[0];       /* give me the patches for USB */
    patched_ifs[1]=up[1];       
    patched_ifs[2]=up[2];       
    lu_msg = "USB Step\0";

    if(lu[1]) {
      goto set_it_up;
    } else {
      lu_conv[1]=1;
      goto sample2;
    }
  }
sample2:

    if(lu[0] && lu[1]){
      for(i=0;i<3;i++) {
	if(up[i] && lp[i])
	  if(saveatt[i]<inew[i]) inew[i]=saveatt[i];
      }
    }

    patched_ifs[0]=lp[0]||up[0];
    patched_ifs[1]=lp[1]||up[1];
    patched_ifs[2]=lp[2]||up[2];

    if(ierr=set_att(inew[0],inew[1],inew[2],patched_ifs,&iat,isave,&isave3))
      return;
    if(ierr=reset_vc(vc_parms_save,vcnum_l,vcnum_u)) return;

    if(lu[0] || lu[1]) {
      if(patched_ifs[0])
	shm_addr->iat1if=inew[0];
      if(patched_ifs[1])
	shm_addr->iat2if=inew[1];
      if(patched_ifs[2])
	shm_addr->iat3if=inew[2];
      
      strcpy(output,command->name);
      strcat(output,"/");
      
      sprintf(output+strlen(output),"%d,%d,%d,%d,Succeeded",
	      itp_ref,inew[0],inew[1],inew[2]);
      
      for (i=0;i<5;i++) ip[i]=0;
      cls_snd(&ip[0],output,strlen(output),0,0);
      ip[1]=1;
      return;
    } else {
      strcpy(output,command->name);
      strcat(output,"/");
      
      sprintf(output+strlen(output),
	      "%d,00,00,00,trackform NOT setup",
	      itp_ref);
      
      for (i=0;i<5;i++) ip[i]=0;
      cls_snd(&ip[0],output,strlen(output),0,0);
      ip[1]=1;
      return;
    }
    /* Here to setup L or U sideband. */
set_it_up:    
    iat[0]=inew[0]=icur[0]=iat_keeper[0];
    iat[1]=inew[1]=icur[1]=iat_keeper[1];
    iat[2]=inew[2]=icur[2]=iat_keeper[2];
    iat[3]=iat_keeper[3];

    imax[0]=imax[1]=imax[2]=63;
    imin[0]=imin[1]=imin[2]=0;
    imxv[0]=imxv[1]=imxv[2]=0;
    imnv[0]=imnv[1]=imnv[2]=0;
    /* setup video converters */
    if(ierr=set_vc_sb(vcnum, which, iuse, vc_parms_save)) return;
    /* setup for TPZERO */
    if(ierr=set_att(63,63,63,patched_ifs,&iat,isave,&isave3)) return;
    /* need 2sec's */
    rte_sleep(200);
    /* get TPZERO values*/
    if(ierr = get_itp(vcnum, &itpz, iuse)) return;
    /* RESET to original values. */
    sprintf(msg,"ifadjust/%d,%02d,%02d,%02d,%s %d",
	    itp_ref,inew[0],inew[1],inew[2],&lu_msg[0],itry++);
    logitf(msg);
    if(ierr=set_att(inew[0],inew[1],inew[2],patched_ifs,&iat,isave,&isave3))
      return;
    rte_sleep(200);
    goto sample;

error:
    ip[0]=0;
    ip[1]=0;
    ip[2]=ierr;
    memcpy(ip+3,"if",2);
    return;
}
