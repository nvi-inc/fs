/*
 * Copyright (c) 2020-2022, 2024 NVI, Inc.
 *
 * This file is part of VLBI Field System
 * (see http://github.com/nvi-inc/fs).
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program. If not, see <http://www.gnu.org/licenses/>.
 */
#include <string.h>
#include <sys/types.h>

#include "../include/params.h"
#include "../include/cmd_ds.h"

#define MAX_BUF   257

extern struct fscom *shm_addr;

char unit_letters[ ] = {" abcdefghijklm"}; /* mk6/rdbe unit letters */

main()
{
    int ip[5];
    struct cmd_ds command;
    int isub,itask,idum,ierr,nchars,i;
    char buf[MAX_BUF];

    int cls_rcv(), cmd_parse();
    void setup_ids(),skd_wait();
    void dist();
    int iold,rte_prior();

    setup_ids();
    iold=rte_prior(FS_PRIOR);
    putpname("     ");

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
	switch(itask) {
	case 1:
	  form4(&command,itask,ip);
	  break;
	case 2:
	  vsi4(&command,itask,ip);
	  break;
	default:
	  ierr=-4;
	  break;
	}
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
	switch(itask) {
	case 1:
	  lo(&command,itask,ip);
	  break;
	case 2:
	  user_device(&command,itask,ip);
	  break;
	case 3:
	  lo_config(&command,itask,ip);
	  break;
	default:
	  ierr=-4;
	  break;
	}
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
        save_file(&command,itask,ip);
        break;
      case 56:
	k4ib(&command,itask,ip);
        break;
      case 57:
        k4et(&command,itask,ip);
        break;
      case 58:
        k4st(&command,itask,ip);
        break;
      case 59:
        k4tape(&command,itask,ip);
        break;
      case 60:
        k4rec(&command,itask,ip);
        break;
      case 61:
	k4vclo(&command,itask,ip);
        break;
      case 62:
	k4vc(&command,itask,ip);
        break;
      case 63:
	k4vcif(&command,itask,ip);
        break;
      case 64:
	k4vcbw(&command,itask,ip);
        break;
      case 65:
	k3fm(&command,itask,ip);
        break;
      case 66:
	k4newtp(&command,itask,ip);
        break;
      case 67:
	k4label(&command,itask,ip);
        break;
      case 68:
	k4oldtp(&command,itask,ip);
        break;
      case 69:
	k4rec_mode(&command,itask,ip);
        break;
      case 70:
	k4recpatch(&command,itask,ip);
        break;
      case 71:
	k4pcalports(&command,itask,ip);
        break;
      case 72:
	selectcmd(&command,itask,ip);
	break;
      case 73:
	scan_name(&command,itask,ip);
	break;
      case 74:
        ifadjust(&command,itask,ip);
        break;
      case 75:
        tacd(&command,itask,ip);
        break;
      case 77:
        cablediff(&command,itask,ip);
        break;
      case 78:
	switch (itask) {
	case 0:
	  mk5(&command,itask,ip);
	  break;
	case 1:
	  disk_record(&command,itask,ip);
	  break;
	case 2:
	  disk_pos(&command,itask,ip);
	  break;
	case 3:
	  disk_serial(&command,itask,ip);
	  break;
	case 4:
	  data_check(&command,itask,ip);
	  break;
	case 5:
	case 27:
	  mk5relink(&command,itask,ip);
	  break;
	case 6:
	case 28:
	case 16:
	  mk5close(&command,itask,ip);
	  break;
	case 7:
	case 8:
	  bank_check(&command,itask,ip);
	  break;
	case 9:
	  disk2file(&command,itask,ip);
	  break;
	case 10:
	  in2net(&command,itask,ip);
	  break;
	case 11:
	  scan_check(&command,itask,ip);
	  break;
	case 12:
	  last_check(&command,itask,ip);
	  break;
	case 13:
	case 14:
	case 15:
	  mk5b_mode(&command,itask,ip);
	  break;
	case 20:
	case 22:
	case 23:
	case 24:
	case 25:
        case 30:
	  dbbc(&command,itask,ip);
	  break;
    case 21:
      mk5_status(&command, itask, ip);
      break;
	case 26:
	  fila10g_mode(&command, itask, ip);
	  break;
	case 29:
	  dbbc3_core3h_modex(&command, itask, ip);
	  break;
	default:
	  ierr=-4;
	  goto error;
	}
	break;
      case 79:
        rollform(&command,itask,ip);
        break;
      case 80:
	tpicd(&command,itask,ip);
	break;
      case 81:
	switch (itask) {
	case  1: onoff(&command,itask,ip); break;
	case  2: holog(&command,itask,ip); break;
	case  3: satellite(&command,itask,ip); break;
	case  4: satoff(&command,itask,ip); break;
	case  5: tle(&command,itask,ip); break;
        default:
	  ierr=-4;
	  goto error;
        }
	break;
      case 82:
        switch (itask) {
	case 0: dbbc_cont_cal(&command,ip); break;
	case 1: dbbc3_cont_cal(&command,ip); break;
        default:
	  ierr=-4;
	  goto error;
        }
        break;
      case 83:
        ds(&command,itask,ip);
        break;
      case 84:
        lba_ifp(&command,itask,ip);
        break;
      case 85:
        lba_cor(&command,itask,ip);
        break;
      case 86:
        lba_mon(&command,itask,ip);
        break;
      case 87:
        lba_ft(&command,itask,ip);
        break;
      case 88:
        lba_trkfrm(&command,itask,ip);
        break;
/* Modified mb */
      case 90:
	s2bbc( &command,itask,ip);
        break;
      case 91:
	switch (itask) {
	case  0: s2agc( &command,itask,ip); break;
	case  1: s2diag(&command,itask,ip); break;
	case  2: s2encode(&command,itask,ip); break;
	case  3: s2fs(&command,itask,ip); break;
	case  4: s2ifx(&command,itask,ip); break;
	case  5: s2version(&command,itask,ip); break;
	case  6: s2mode(&command,itask,ip); break;
	case  7: s2ping(&command,itask,ip); break;
        case  8: s2pwrmon(&command,itask,ip); break;
	case  9: s2status( &command,itask,ip); break;
        case 10: s2chkr( &command,itask,ip); break;
        case 11: s2delay(&command,itask,ip); break;

        default:
	ierr=-4;
	goto error;
        }
        break;
      case 92:
	s2decode(&command,itask,ip); break;
        break;
      case 93:
	switch (itask) {
	case  0: s2tonedet( &command,itask,ip); break;
	case  1: s2tonedetmeas( &command,itask,ip); break;
        default:
	ierr=-4;
	goto error;
        }
        break;
      case 94:
	dbbcnn(&command,itask,ip);
	break;
      case 95:
	switch (itask) {
	case 0:
	  dbbcform(&command,ip);
	  break;
	case 1: case 2: case 3: case 4:
	  dbbcifx(&command,itask,ip);
	  break;
	default:
	  ierr=-4;
	  goto error;
	}
	break;
      case 96:
	dbbcgain(&command,itask,ip);
	break;
      case 97:
	switch (itask) {
	case 1: case 2: case 3: case 4: case 5: case 6: case 7: case 8:
	  dbbc3_ifx(&command,itask,ip);
	  break;
	case 11: case 12: case 13: case 14: case 15: case 16: case 17: case 18:
	  dbbc3_iftpx(&command,itask,ip);
	  break;
	default:
	  ierr=-4;
	  goto error;
	}
	break;
      case 99:
	itask+=60;
      case 98:
	dbbc3_bbcnn(&command,itask,ip);
	break;
      case 100:
	mk6(&command,itask,ip);
	break;
	//      case 101:
	//mk6_record(&command,itask,ip);
	//break;
//      case 102:
//	mk6_disk_pos(&command,itask,ip);
//	break;
//    case 111:
//	mk6_scan_check(&command,itask,ip);
//	break;
      case 112:
	mk6_active(&command,itask,ip);
	break;
      case 120:
	rdbe(&command,itask,ip);
	break;
      case 121:
	active_rdbes(&command,itask,ip);
	break;
      case 122:
	rdbe_atten(&command,itask,ip);
	break;
      case 123:
	rdbe_data_send(&command,itask,ip);
	break;
      case 124:
	rdbe_channels(&command,itask,ip);
	break;
      case 125:
	rdbe_pc_offset(&command,itask,ip);
	break;
      case 126:
	rdbe_quantize(&command,itask,ip);
	break;
      case 127:
	rdbe_bstate(&command,itask,ip);
	break;
      case 128:
	rdbe_dot2Xps(&command,itask,ip);
	break;
      case 129:
	rdbe_dot(&command,itask,ip);
	break;
      case 130:
	dbbc_vsix(&command,itask,ip);
	break;
      case 131:
	dbbc_pfbx(&command,itask,ip);
	break;
      case 132:
	switch (itask) {
	case  1: dbbc3_mcast_time(&command,itask,ip); break;
        default:
	  ierr=-4;
	  goto error;
        }
    break;
      case 140:
	rdbe_status(&command,itask,ip);
	break;
      case 141:
	rdbe_version(&command,itask,ip);
	break;
      case 142:
	rdbe_connect(&command,itask,ip);
	break;
      case 143:
	rdbe_personality(&command,itask,ip);
	break;
/* end modified mb */
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
