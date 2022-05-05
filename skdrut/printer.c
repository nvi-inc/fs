/*
 * Copyright (c) 2020 NVI, Inc.
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
/* AEM 20041125 add string.h */
#include <string.h>

int
#ifdef F2C
printer_
#else
printer
#endif
(fname,labels,orien)
char   *fname, *labels, *orien;

/*
    Pat Ryan 1.9.88
        This routine constructs a command line to pass to the
    printer.  'fname' contains the name of a file.
    'orien' holds the command that will print the file, if blank
      then "lpr" is used.

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
   960226 nrv Add separate argument for labels.

*/

{
      char    command[80];
      int     iret;

/* Form the command by attaching the file name to the command */

      if (strncmp(labels,"l",1) == 0) { /* label mode */
        if (strncmp(orien," ",1) == 0) {    /* no script, use lpr */
          strcpy(command,"lpr ");
          strcat(command,fname);
        }
        else {
          strcpy(command,orien); /* use script provided */
          strcat(command," ");
          strcat(command,fname);
        }
      }
      else { /* text mode */
        if (strncmp(orien," ",1) == 0) { /* no script use recode */
          strcpy(command,"recode latin1:ibmpc < ");
          strcat(command,fname);
          strcat(command," | lpr");
        }
        else { /* use script provided */
          strcpy(command,orien);
          strcat(command," ");
          strcat(command,fname);
        }
      }

/* call system with command line */

      printf("printer command string: %s\n",command); 
      return(system(command));

}
