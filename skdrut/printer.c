int printer_(fname,orien)
char   *fname, *orien;

/*
    Pat Ryan 1.9.88
        This routine constructs a command line to pass to the
    printer.  'fname' contains the name of a file.
    'orien' holds the command that will print the file

   880801 PMR created
   890817 PMR changed system dependent ifdef's
   900104 PMR added raw printer option
   900221 gag changed the lj and ljp
   900413 NRV Removed extraneous code for constructing the
              command line.  String "orien" is command as
              specified in control file.  Removed printer
              name from calling parameters.
   910312 NRV Added "-obar" to lp command for raw mode.  This is
              to make bar code file printer OK on HPUX machines.
   951002 nrv Use "recode latin1:ibmpc < file | lpr" for the Linux magic filter.
   951016 nrv If "orien" is non-blank, use the scripts, otherwise use
              the recode command.

*/

{
      char    command[80];
      int     iret;

/* Form the command by attaching the file name to the command */

      if (strncmp(orien,"r",1) == 0) {    /* 'raw' mode      */
        strcpy(command,"lpr ");
        strcat(command,fname);
      } 
      else if (strncmp(orien," ",1) == 0) { /* 'no script provided */
	/* PC commands */
        strcpy(command,"recode latin1:ibmpc < ");
        strcat(command,fname);
        strcat(command," | lpr");
      }
      else {
	/* HP commands */
        strcpy(command,orien);
        strcat(command," ");
        strcat(command,fname);
      }

/* call system with command line */

/*      printf("printer command string: %s\n",command); */
      return(system(command)); 

}
