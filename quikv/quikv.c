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
	  case 33:
	    trkfrm(&command,itask,ip);
	    break;
	  case 34:
	    tracks(&command,itask,ip);
	    break;
 	  case 35:
	    bit_density(&command,itask,ip);
	    break;
 	  case 36:
	    systracks(&command,itask,ip);
	    break;
      case 37:
	rcl(&command,itask,ip);
	break;
      case 38:
	user_info(&command,itask,ip);
	break;
      case 39:
	s2st(&command,itask,ip);
	break;
      case 40:
	s2et(&command,itask,ip);
	break;
      case 41:
	s2tape(&command,itask,ip);
	break;
      case 42:
	rec_mode(&command,itask,ip);
	break;
      case 43:
	data_valid(&command,itask,ip);
	break;
      case 44:
	s2label(&command,itask,ip);
	break;
      case 45:
	s2rec(&command,itask,ip);
	break;
      case 46:
	form4(&command,itask,ip);
	break;
      case 47:
	tracks4(&command,itask,ip);
	break;
      case 48:
	trkfrm4(&command,itask,ip);
	break;
      case 49:
	rvac(&command,itask,ip);
	break;
      case 50:
	wvolt(&command,itask,ip);
	break;
      case 51:
	lo(&command,itask,ip);
	break;
      case 52:
	pcalform(&command,itask,ip);
	break;
      case 53:
	pcald(&command,itask,ip);
	break;
      case 54:
	pcalports(&command,itask,ip);
	break;
      case 55:
	k4ib(&command,itask,ip);
        break;
      case 56:
        k4et(&command,itask,ip);
        break;
      case 57:
        k4st(&command,itask,ip);
        break;
      case 58:
        k4tape(&command,itask,ip);
        break;
      case 59:
        k4rec(&command,itask,ip);
        break;
      case 60:
	k4vclo(&command,itask,ip);
        break;
      case 61:
	k4vc(&command,itask,ip);
        break;
      case 62:
	k4vcif(&command,itask,ip);
        break;
      case 63:
	k4vcbw(&command,itask,ip);
        break;
      case 64:
	k3fm(&command,itask,ip);
        break;
      case 65:
	k4newtp(&command,itask,ip);
        break;
      case 66:
	k4label(&command,itask,ip);
        break;
      case 67:
	k4oldtp(&command,itask,ip);
        break;
      case 68:
	k4rec_mode(&command,itask,ip);
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
