
int printer_ (fname,orien)
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

*/

{
      char    command[80];

/* Form the command by attaching the file name to the command */

      if (strncmp(orien,"r",1) == 0) {    /* 'raw' mode      */
          strcpy(command,"lpr ");
      } else {
          strcpy(command,orien);
          strcat(command," ");
      }
      strcat(command,fname);

/* call system with command line */

      return(system(command));

}
