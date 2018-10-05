/*****************************************************************************
 *
 * FILE: handle_prologix.c
 *
 *   Handle communication with a Prologix-controlled device.
 *
 *   This procedure is part of the 'ibcon' program.
 *
 *   The use of Prologix-controlled devices is described in
 *   the 'check_prologix.c' routine.
 *
 * HISTORY
 *
 * who          when           what
 * ---------    -----------    ----------------------------------------------
 * lerner       26 Jul 2012    Original version
 * lerner        7 Feb 2013    Added user-specified port-number to enable
 *                             communication with network-based devices
 *
 *****************************************************************************/

#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <errno.h>



/*****************************************************************************
 *
 *   Macros
 *
 *****************************************************************************/

#define MAX_PROLOGIX                   50
#define MAX_SEQUENCES                  20

#define SEND_TIMEOUT                    2
#define READ_TIMEOUT                    3
#define MAX_READ_LENGTH                80



/*****************************************************************************
 *
 *   Global variables
 *
 *****************************************************************************/

/*  Prologix box variables --- set up by 'check_prologix.c'  */

extern char prologix_address[MAX_PROLOGIX][16];
extern char prologix_port[MAX_PROLOGIX][8];
extern int prologix_socket[MAX_PROLOGIX];

/*  Prologix device variables --- set up by 'check_prologix.c'  */

extern char prologix_mnemonic[MAX_PROLOGIX][3];
extern char *prologix_sequence[MAX_PROLOGIX][MAX_SEQUENCES];
extern int prologix_check[MAX_PROLOGIX][MAX_SEQUENCES];
extern int prologix_box[MAX_PROLOGIX];



/*****************************************************************************
 *
 *   Subroutine declarations
 *
 *****************************************************************************/

int open_prologix(int box);
int close_prologix(int box);
int send_prologix(int device, char *buf, unsigned int timeout);
int read_prologix(int device, char *buf, size_t buf_len, unsigned int timeout);
int prologix_connected(int device);

int handle_prologix__(char *line, int *length, int *device, int *ierr,
		      long *ipcode);



/*****************************************************************************
 *
 *   handle_prologix
 *
 *     handle the communication with a Prologix-controlled device using
 *     the sequence of commands specified in 'ibad.ctl'
 *
 *****************************************************************************/

int handle_prologix__(char *line, int *length, int *device, int *ierr,
		      long *ipcode) {

  char command[256], dynamic_command[256], string[512], error[256];
  int answer = 0, failed = 0;
  int i, j;

  strncpy(dynamic_command, &line[4], *length-4);
  dynamic_command[*length-4] = '\0';

  /*  Loop once or twice if we have a communication problem  */

  for ( i = 0 ; i == 0 || i == 1 && failed ; i++ ) {

    /*  Open the connection with the Prologix box, if we are not
	connected --- bomb out if it fails  */

    if ( ! prologix_connected(*device) ) {
      //logit("Trying to open Prologix connection", 0, "un");
      if ( open_prologix(prologix_box[*device]) < 0 ) {
	logit("ERROR", errno, "un");
	*ierr = -601;
	memcpy((char *) ipcode, "PO", 2);
	return(-1);
      }
    }

    /*  Send the sequence of commands --- if we encounter a problem, then stop
	and repeat the outer loop once --- if this is already the second
	loop and we still have problems, then bomb out  */

    for ( j = 0 ; prologix_sequence[*device][j] != NULL ; j++ ) {
      strcpy(command, prologix_sequence[*device][j]);

      /*  Read a reply from the Prologix box, if we are expecting a reply  */

      if ( strcmp(command, "$$") == 0 ) {
	if ( read_prologix(*device, line, MAX_READ_LENGTH,
			   READ_TIMEOUT) < 0 ) {
	  if ( failed ) {
	    logit("ERROR failed to read via Prologix", 0, "un");
	    *ierr = -603;
	    memcpy((char *) ipcode, "PR", 2);
	    close_prologix(prologix_box[*device]);
	    return(-1);
	  }
	  logit("Will try to reopen Prologix communication", 0, "un");
	  failed = 1;
	  break;
	} else {
	  *length = strlen(line);
	  answer = 1;
	}
      } else {

	/*  Insert the command we have been called with into the command
	    sequence, if we have been told to do that  */

	if ( strcmp(command, "##") == 0 ) {
	  if ( strlen(dynamic_command) == 0 ) {
	    logit("ERROR no command provided to Prologix", 0, "un");
	    *ierr = -604;
	    memcpy((char *) ipcode, "PN", 2);
	    close_prologix(prologix_box[*device]);
	    return(-1);
	  }
	  strcpy(command, dynamic_command);
	}

	/*  Send the command to the Prologix box  */

	if ( send_prologix(*device, command, SEND_TIMEOUT) < 0 ) {
	  if ( failed ) {
	    logit("ERROR failed to send command via Prologix", 0, "un");
	    *ierr = -602;
	    memcpy((char *) ipcode, "PW", 2);
	    close_prologix(prologix_box[*device]);
	    return(-1);
	  }
	  logit("Will try to reopen Prologix communication", 0, "un");
	  failed = 1;
	  break;
	}
      }

      /*  Send the error checking command, if we are supposed to do that  */

      if ( prologix_check[*device][j] ) {
	if ( send_prologix(*device, ":SYST:ERR?", SEND_TIMEOUT) < 0 ) {
	  snprintf(string, sizeof(string), "WARNING failed when sending an "
		   "error checking command after command '%s'!", command);
	  logit(string, 0, NULL);
	  if ( failed ) {
	    logit("ERROR failed to send command via Prologix", 0, "un");
	    *ierr = -602;
	    memcpy((char *) ipcode, "PW", 2);
	    close_prologix(prologix_box[*device]);
	    return(-1);
	  }
	  logit("Will try to reopen Prologix communication", 0, "un");
	  failed = 1;
	  break;
	} else {
	  if ( read_prologix(*device, error, sizeof(error) - 1,
			     READ_TIMEOUT) < 0 ) {
	    snprintf(string, sizeof(string), "WARNING failed reading out the "
		     "result from the error checking command sent after "
		     "command '%s'!", command);
	    logit(string, 0, NULL);
	    if ( failed ) {
	      logit("ERROR failed to read via Prologix", 0, "un");
	      *ierr = -603;
	      memcpy((char *) ipcode, "PR", 2);
	      close_prologix(prologix_box[*device]);
	      return(-1);
	    }
	    logit("Will try to reopen Prologix communication", 0, "un");
	    failed = 1;
	    break;
	  } else if ( strncmp(error, "+0", 2) != 0 ) {
	    snprintf(string, sizeof(string), "WARNING received error message "
		     "'%s' after sending command '%s'!", error, command);
	    logit(string, 0, NULL);
	  }
	}
      }

    }

  }

  logit("Closing Prologix connection after successful communication", 0, "un");

  close_prologix(prologix_box[*device]);

  return(answer);
}
