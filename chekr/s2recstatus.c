/* chekr s2 rec status routine */

#include <stdio.h> 
#include <string.h> 
#include <sys/types.h>

#include "../include/params.h"
#include "../include/fs_types.h"
#include "../include/fscom.h"         /* shared memory definition */
#include "../include/shm_addr.h"      /* shared memory pointer */

#include "../rclco/rcl/rcl.h"

static int stat_count[RCL_STATCODE_MAX];

void s2recstatus_(lwho)
char *lwho;
{
  long ip[5];                          /* ipc parameters */
  struct rclcn_req_buf req_buf;        /* rclcn request buffer */
  struct rclcn_req_buf res_buf;        /* rclcn respnse buffer */
  int ierr=0;
  char device[]= "rc";
  int icount=0;
  static int stat_now[RCL_STATCODE_MAX];
  char outbuf[512];

  /*rclcn request utilities */

  void ini_rclcn_req(), add_rclcn_status(), end_rclcn_req();

  void skd_run(), skd_par();      /* program scheduling utilities */
  int summary, num_entries;
  unsigned char status_list[RCL_STATUS_MAX*2];
  int i, target;

  target=1&(shm_addr->actual.s2rec_inuse+1);
  shm_addr->actual.s2rec[target].rstate_valid=FALSE;
  shm_addr->actual.s2rec[target].position_valid=FALSE;

  ini_rclcn_req(&req_buf);
  add_rclcn_state_read(&req_buf,device);
  {
    int code=0;
    add_rclcn_position_read(&req_buf,device, code);
  }
  end_rclcn_req(ip,&req_buf);

  nsem_take("fsctl",0);
  skd_run("rclcn",'w',ip);
  nsem_put("fsctl");

  skd_par(ip);
  if(ip[2]!=0) {
    cls_clr(ip[0]);
    logita(NULL,ip[2],ip+3,ip+4);
    goto end_update;
  }

  opn_rclcn_res(&res_buf,ip);

  ierr=get_rclcn_state_read(&res_buf,&shm_addr->actual.s2rec[target].rstate);
  if(ierr!=0)
    goto end_update;
  else
    shm_addr->actual.s2rec[target].rstate_valid=TRUE;
    
  {
    int code;
    union pos_union position;
    
    ierr=get_rclcn_position_read(&res_buf, &code, &position);
    if(ierr!=0)
      goto end_update;

    if(code!=0) {
      logita(NULL,-517,lwho,"rc");
      goto end_update;
    } else {
      shm_addr->actual.s2rec[target].position=position.overall.position;
      shm_addr->actual.s2rec[target].posvar  =position.overall.posvar;
      shm_addr->actual.s2rec[target].position_valid=TRUE;
    }
  }
  
end_update:
  if(ierr!=0)
    logita(NULL,ierr-20,lwho,"rc");

  shm_addr->actual.s2rec_inuse=target;

  /* now do status */

  for (i=0;i<RCL_STATCODE_MAX;i++)
    stat_now[i]=0;

  clr_rclcn_res(&res_buf);
  ini_rclcn_req(&req_buf);
  add_rclcn_status(&req_buf,device);
  end_rclcn_req(ip,&req_buf);

  nsem_take("fsctl",0);
  skd_run("rclcn",'w',ip);
  nsem_put("fsctl");

  skd_par(ip);
  if(ip[2]!=0) {
    cls_clr(ip[0]);
    logita(NULL,ip[2],ip+3,ip+4);
    return;
  }

  opn_rclcn_res(&res_buf,ip);

  ierr=get_rclcn_status(&res_buf,&summary,&num_entries,status_list);
  
  if(ierr!=0) {
    clr_rclcn_res(&res_buf);
    logita(NULL,ierr,lwho,lwho);
    return;
  }
  
  clr_rclcn_res(&res_buf);

  if(num_entries> 0 ) {
    int summary_detail, num_entries_detail;
    unsigned char status_det_list[RCL_STATUS_DETAIL_MAXLEN];
    int i,j,k;

    for(i=0;i<num_entries;i++) {
      int istat=status_list[i*2];
      int itype=status_list[i*2+1];

      if(0==(itype&0x4))
	stat_now[istat]++;
      if(itype&0x4 || 0==stat_count[istat]++%20) {
	if(icount++==0)
	  ini_rclcn_req(&req_buf);
	add_rclcn_status_detail(&req_buf,"rc",istat,FALSE,FALSE);
      }
    }
    if(icount == 0)
      goto clean_up;

    end_rclcn_req(ip,&req_buf);

    nsem_take("fsctl",0);
    skd_run("rclcn",'w',ip);
    nsem_put("fsctl");

    skd_par(ip);
    if(ip[2]!=0) {
      cls_clr(ip[0]);
      logita(NULL,ip[2],ip+3,ip+4);
      return;
    }

    opn_rclcn_res(&res_buf,ip);

    for(i=0;i<icount;i++) {
      ierr=get_rclcn_status_detail(&res_buf,&summary_detail,
				   &num_entries_detail, status_det_list);
      if(ierr!=0) {
	clr_rclcn_res(&res_buf);
	logita(NULL,ierr,0,lwho);
	return;
      }

      j=0;

      for (k=0;k<num_entries_detail;k++) {      
	char *newln;
	char st[11];
	
	if(((~0x7)&status_det_list[j+1]) == 0) {
	  strcpy(st,"---");
	  if(0x1&status_det_list[j+1])
	    st[0]='E';
	  if(0x2&status_det_list[j+1])
	    st[1]='F';
	  if(0x4&status_det_list[j+1])
	    st[2]='C';
	} else
	  sprintf(st,"0x%x",status_det_list[j+1]);

	ierr=-status_det_list[j];
	sprintf(outbuf,"%s ",st);
	j+=2;
	while(status_det_list[j]!=0) {
	  newln=strchr(status_det_list+j,'\n');
	  if(newln!=NULL)
	    *newln=0;
	  strcat(outbuf,status_det_list+j);
	  j+=strlen(status_det_list+j);
	  if(newln!=NULL) {
	    j++;
	    strcat(outbuf,"\\n");
	  }
	}
	logite(outbuf,ierr,"rz");
      }
    }
    
  }
clean_up:
  for (i=0;i<RCL_STATCODE_MAX;i++)
    if(stat_count[i]>0 && stat_now[i]==0) {
      sprintf(outbuf,"occurred a total of %d times, but has now stopped",
	      stat_count[i]);
      logite(outbuf,-i,"rz");
      stat_count[i]=0;
    }
  
  return;
}




