/* VLOGX - Generate a field log summary

940411 nrv Created using the Fortran version as a model.
940422 nrv More creation.
940503 nrv Finish writing first part of output file.
940722 nrv Generate run-ID to match schedule time, not tape
           start time
951003 nrv Handle FS9 format log files
970324 nrv New time format with centisec. 1-letter code is in log.
981021 nrv Expanded time format for Y2K. More diagnostic output.
990325 nrv Don't overwrite start time if already found.
990325 nrv Recognize "data_valid" command.
990519 nrv Add option to write VEX output blocks.
991208 nrv Add 'ft' after tape footage. Add 'endscan'.

*/
#include <stdio.h>
#include <string.h>

main (argc,argv)
int argc;
char *argv[];

{
  char *inname;           /* pointer to name of input log file entered on run line*/
  char *outname;          /* pointer to name of output summary file entered on run line*/
  char *append;           /* pointer to char "a" or "o" for append or overwrite */
  char vexout[2];           /* pointer to char "v" for VEX output or "x" for the old version */
  char *ptr,*ptr1,*ptr2;  /* general use pointer */
  FILE *fp_in;            /* file pointer for input control file */
  FILE *fp_out;           /* file pointer for blokq or solution input */
  char logname[64];
  char sumname[64];
  char inbuf[180];        /* buffer for reading */
  int inbuf_len = 180;    /* length of inbuf */
  char ans[2];
  int year;               /* year from first log line */
  int ic;
  char cyear[5];          /* year converted to char */
  char fstype[2];         /* FS type */
  char station_name[9];   /* station name from first log line */
  char station_id[2];     /* 1-letter station ID */
  char cversion[9];       /* full FS version, e.g. 9.3.7 */
  char version_msg[25];   /* screen message with version */
  char outbuf[180];
  int done_with_this_scan;  /* 1=found all the lines in the log for a scan,
                               0=keep reading lines in the log */
  int preob_flag,midob_flag,postob_flag,start_tape,end_tape,head_flag;
  char lasttime[24];
  char lasthead[12];
  int nc,nc_head;                 /* character counter */
  int i;
  int off;                        /* offset of control character */
  int toff;  /* offset for lasttime buffer */
  char cday[4],chr[3],cmin[3],csec[3]; /* day,hr,min,sec from time field */
  char scanid[9]; /* scan ID */
  char vsn[9];    /* tape VSN */
  char vhdpos[9];  /* head position */
  char vstart[19]; /* nnnnynnndnnhnnmnns */
  char vstop [19]; /* nnnnynnndnnhnnmnns */
  char vfstart [5]; /* starting footage */
  char vfstop  [5]; /* stoping footage */
  char vsource  [20]; /* source */


/* 1. Get the input log file name and the output file name, and open
      these files.
*/

  if (argc > 1)
    inname = argv[1];
  else
    inname = NULL;
  if (argc > 2)
    outname = argv[2];
  else
    outname = NULL;
  if (argc > 3)
    append = argv[3];
  else
    append = NULL;
  if (argc > 4)
    strcpy(vexout,argv[4]);
  else
    strcpy(vexout,NULL);

  strcpy(version_msg,"VLOGX version 000110 NRV");
  printf("%s\n",version_msg);

  getfiles(&fp_in,&fp_out,logname,sumname,inname,outname,append,vexout);


/* 2. Read first line of log file to get station name.
      Write header into output file.
*/

  parse_log1(fp_in,fstype,station_name,station_id,&year,cversion);
  sprintf (cyear,"%i",year);
  printf ("FS type is %s\n", fstype); 
  printf ("Output type is %s\n", vexout); 

/*  For FS8, the station ID is the last character before 
    the dot in the log file name, e.g.  
          rd9302a.log      ("a" is the station ID)
*/
  if (strcmp(fstype,"8")==0) {
/*        station ID is final character of file name */
    ptr = strchr(logname,'.');
    strncpy(station_id,ptr-1,1);
    station_id[0] = toupper(station_id[0]);
    upper(station_name);
    off=9;
  }
  else if (strcmp(fstype,"9")==0) {
/*        station ID is final character of file name */
    ptr = strchr(logname,'.');
    strncpy(station_id,ptr-1,1);
    station_id[0] = toupper(station_id[0]);
    upper(station_name);
    off=13;
  }
  else if (strcmp(fstype,"2")==0) {
/*    Got station ID from comments in log file, e.g.
          europ2wz.log     ("wz" is NOT the station ID) */
    station_id[0] = toupper(station_id[0]);
    off=13;
  }
  else if (strcmp(fstype,"y")==0) {
/*    Got station ID from comments in log file, e.g.
          europ2wz.log     ("wz" is NOT the station ID) */
    station_id[0] = toupper(station_id[0]);
    off=20;
  }
  else {
    if (strcmp(cversion,"0")==0) 
      printf("VLOGX98 - That's probably not a log file.\n");
    else
      printf("VLOGX99 - Don't know how to handle logs from FS version %s.\n",cversion);
    exit(1);
  }

  if (strcmp(vexout,"s") == 0) { 
    fprintf(fp_out,"*\n");
    fprintf(fp_out,"*Summary of %s for %s, using Field System version %s\n",logname,station_name,cversion);
    printf("*Summary of %s for %s. Station ID %s. FS version %s\n",logname,station_name,station_id,cversion);
    fprintf(fp_out,"*Generated by %s\n",version_msg);
    fprintf(fp_out,"*\n");
    fprintf(fp_out,"*$$%s [<rategen>],[<fwd bias>],[<rev bias>],[<peaking period(sec)>]\n",station_id);
    fprintf(fp_out,"*\n");
    fprintf(fp_out,"$$%s\n",station_id);
    fprintf(fp_out,"*Scan-Id   Source  ##Tape## Foot     Start      Stop  Foot Status Head\n");
  } 
  else { 
    fprintf(fp_out,"*Summary of %s for %s. Station ID %s. FS version %s\n",logname,station_name,station_id,cversion);
    printf("*LVEX summary of %s for %s. Station ID %s. FS version %s\n",logname,station_name,station_id,cversion);
    fprintf(fp_out,"*\n  def %s;   * %s\n",station_id,station_name);
    printf("  def %s   *%s\n",station_id,station_name);
  } 
 
/* 3. This is the main loop of the program. 
*/
/* Get the first line */
  ptr = fgets(inbuf,inbuf_len,fp_in);
  if (strncmp(inbuf+off,";\"",2)!=0 && strncmp(inbuf+off+9,":\"",2)!=0) 
    upper(inbuf); /* uppercase non-comments */
  memcpy(outbuf+20,"-  --   ",8);
  head_flag=0;
  while (ptr != NULL) {
    memcpy(outbuf,"   --        --     ",20);
    /* Leave tape label unchanged */
    memcpy(outbuf+28,"  --       --          --     --   ---  -     \0",48);
    done_with_this_scan = 0;
    while (ptr != NULL && !done_with_this_scan) {
      if (strncmp(inbuf+off,";\"",2)==0 || strncmp(inbuf+off,":\"",2)==0) {
/*      don't print out the data start/stop comments */
        if (strncmp(inbuf+off+2,"data start",10)!=0 && strncmp(inbuf+off+2,"data stop",9)!=0) {
          if (strcmp(vexout,"s") == 0) /* comments only for standard */
            fprintf(fp_out,"\"%s  %s",station_id,inbuf);
        }
      }
      if (strncmp(inbuf+off,":SOURCE",7)==0) { /* SOURCE command */
        lasttime[0]=NULL;
        preob_flag=0;
        midob_flag=0;
        postob_flag=0;
        start_tape=0;
        end_tape=0;
        ptr1=strchr(inbuf+1+off,'=')+1; 
        ptr2=strchr(inbuf+1+off,','); 
        if (ptr2 != NULL) { 
          nc = ptr2-ptr1;
          memcpy(outbuf+10,ptr1,nc);
          strncpy(vsource,ptr1,nc);
          ic=nc;
          while (ic < 20) {
            strcpy(vsource+ic,' ');
            ic++;
          }
        }
      }
      else if (strncmp(inbuf+off,"/LABEL",6)==0) { /* LABEL command */
        ptr1=strchr(inbuf+1+off,'/')+1;
        ptr2=strchr(ptr1,',');
        nc=ptr2-ptr1;
        memcpy(outbuf+20,ptr1,nc);
        strncpy(vsn,ptr1,nc);
      }
      else if (strncmp(inbuf+off,":!",2)==0) { /* save the ! time command */
          toff = off;
          if ( strchr(inbuf+off,'.') != NULL ) toff=20;
          /* The log time and the SNAP wait times may be different
             formats if the SNAP was not made with the same FS version. */
          memcpy(lasttime,inbuf+off,toff); /* keep the ! in the string */
      }
      else if (strncmp(inbuf+off,"/TAPE",5)==0) { /* TAPE command */
        ptr1=strchr(inbuf+1+off,',')+1;
        ptr2=strchr(ptr1,',');
        nc=ptr2-ptr1;
        if (nc >0 && nc <=8) { /* valid tape footage */
          if (!start_tape && !end_tape) {
            memcpy(outbuf+29,ptr1,nc); /* starting footage */
            strncpy(vfstart,ptr1,nc);
          }
          else if (end_tape || done_with_this_scan) {
            memcpy(outbuf+57,ptr1,nc); /* ending footage */
            strncpy(vfstop,ptr1,nc);
          }
        }
      }
      else if (strncmp(inbuf+off,":ST",3)==0 || strncmp(inbuf+off,":\"data start",12)==0 || strncmp(inbuf+off,":data_valid=on")==0 ) { /* ST, "data start", or data_valid */
        if (!start_tape) { /* no start time yet */
          start_tape=1;
          /* NOTE: Scan ID will get overwritten when MIDOB appears. */
          if (lasttime[0] != NULL) { /* Generate scan ID using ! time command */
            getydhms(lasttime,fstype,cyear,cday,chr,cmin,csec);
            memcpy(outbuf,cday,3);
            memcpy(outbuf+3,"-",1);
            memcpy(outbuf+4,chr,2);
            memcpy(outbuf+6,cmin,2);
            strncpy(scanid,outbuf,8);
          }
          else { /* Generate scan ID using actual tape start time */
            getydhms(inbuf,fstype,cyear,cday,chr,cmin,csec);
            memcpy(outbuf,cday,3); 
            memcpy(outbuf+3,"-",1);
            memcpy(outbuf+4,chr,2);
            memcpy(outbuf+6,cmin,2);
            strncpy(scanid,outbuf,8);
          }
/*        Put the start time into the output file. */
          getydhms(inbuf,fstype,cyear,cday,chr,cmin,csec);
          memcpy(outbuf+35,cday,3);
          memcpy(outbuf+38,"-",1);
          memcpy(outbuf+39,chr,2);
          memcpy(outbuf+41,":",1);
          memcpy(outbuf+42,cmin,2);
          memcpy(outbuf+44,":",1);
          memcpy(outbuf+45,csec,2);
          memcpy(vstart,cyear,4);
          memcpy(vstart+4,"y",1);
          memcpy(vstart+5,cday,3);
          memcpy(vstart+8,"d",1);
          memcpy(vstart+9,chr,2);
          memcpy(vstart+11,"h",1);
          memcpy(vstart+12,cmin,2);
          memcpy(vstart+14,"m",1);
          memcpy(vstart+15,csec,2);
          memcpy(vstart+17,"s",1);
          if (head_flag) {
            memcpy(outbuf+67,lasthead,nc_head);
            strncpy(vhdpos,lasthead,nc_head);
          }
        }
      }
      else if (strncmp(inbuf+off,":ET",3)==0 || strncmp(inbuf+off,":\"data stop",11)==0 ) { /* ET command or "data stop" */
        end_tape=1;
        getydhms(inbuf,fstype,cyear,cday,chr,cmin,csec);
        memcpy(outbuf+48,chr,2);
        memcpy(outbuf+50,":",1);
        memcpy(outbuf+51,cmin,2);
        memcpy(outbuf+53,":",1);
        memcpy(outbuf+54,csec,2);
        memcpy(vstop,cyear,4);
        memcpy(vstop+4,"y",1);
        memcpy(vstop+5,cday,3);
        memcpy(vstop+8,"d",1);
        memcpy(vstop+9,chr,2);
        memcpy(vstop+11,"h",1);
        memcpy(vstop+12,cmin,2);
        memcpy(vstop+14,"m",1);
        memcpy(vstop+15,csec,2);
        memcpy(vstop+17,"s",1);
      }
      else if (strncmp(inbuf+off,"/PASS",5)==0) { /* HEAD command */
        head_flag=1;
        ptr1=strchr(inbuf+1+off,',')+1;
        ptr1=strchr(ptr1,',')+1;
        ptr1=strchr(ptr1,',')+1;
        ptr2=strchr(ptr1,',');
        nc_head=ptr2-ptr1;
        memcpy(lasthead,ptr1,nc_head);
      }
      else if (strncmp(inbuf+off,":PREOB",6)==0) { /* PREOB command */
        preob_flag=1;
      }
      else if (strncmp(inbuf+off,":MIDOB",6)==0) { /* MIDOB command */
        midob_flag=1;
/*      Use the following 3 lines if you want to have the Run-ID generated
        for the good data time.  */
        getydhms(lasttime,fstype,cyear,cday,chr,cmin,csec);
        memcpy(outbuf,cday,3);
        memcpy(outbuf+3,"-",1);
        memcpy(outbuf+4,chr,2); 
        memcpy(outbuf+6,cmin,2); 
        strncpy(scanid,outbuf,8);
      }
      else if (strncmp(inbuf+off,":POSTOB",7)==0  ||
               strncmp(inbuf+off,":DSNPO",6)==0) { /* POSTOB command */
        postob_flag=1;
        done_with_this_scan=1;
      }
      ptr = fgets(inbuf,inbuf_len,fp_in); /* read next line */
      if (strncmp(inbuf+off,";\"",2)!=0 && strncmp(inbuf+off,":\"",2)!=0) 
        upper(inbuf);
    }
    /* Write out the output line. */
    if (done_with_this_scan) {
      if (strcmp(vexout,"s")==0) { 
        fprintf(fp_out,"%s\n",outbuf);
      }
      else { 
        scan_out(fp_out,scanid,vsn,vhdpos,vstart,vfstart,vstop,vfstop,vsource);
/*
        fprintf(fp_out,"    scan %8s;\n",scanid);
        fprintf(fp_out,"      VSN = %s;\n",vsn);
        fprintf(fp_out,"      head_pos = %s um;\n",vhdpos);
        fprintf(fp_out,"      start_tape = %s : %s ft : 0 in/sec;\n",vstart,vfstart);
        fprintf(fp_out,"      stop_tape =  %s : %s ft ;\n",vstop,vfstop);
        fprintf(fp_out,"      source = %s;\n",vsource);
        fprintf(fp_out,"    endscan;\n");
*/
      }
    }
    
  }

/* 4. Close files.
*/
  if (strcmp(vexout,"v")==0) { 
    fprintf(fp_out,"  enddef;\n*\n");
  }
  fclose(fp_in);
  fclose(fp_out);
  printf("Output file %s written.\n",sumname);
}
