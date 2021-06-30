/*****************************************************************************
 *
 * FILE: handle_network.c
 *
 *   Handle communication with a network-controlled device.
 *
 *   This procedure is part of the 'ibcon' program.
 *
 *   The use of network-controlled devices is described in
 *   the 'check_network.c' routine.
 *
 * HISTORY
 *
 * who          when           what
 * ---------    -----------    ----------------------------------------------
 * lerner       26 Jul 2012    Original version
 * lerner        7 Feb 2013    Added user-specified port-number to enable
 *                             communication with network-based devices
 * lerner       27 Apr 2021    Adapted for inclusion in FS10
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

#define MAX_ACTIONS                    50
#define MAX_SEQUENCES                  20

#define SEND_TIMEOUT                    2
#define READ_TIMEOUT                    3
#define MAX_READ_LENGTH                80



/*****************************************************************************
 *
 *   Global variables
 *
 *****************************************************************************/

/*  Network device variables --- set up by 'check_network.c'  */

extern char network_address[MAX_ACTIONS][16];
extern char network_port[MAX_ACTIONS][8];
extern int network_socket[MAX_ACTIONS];

/*  Network action variables --- set up by 'check_network.c'  */

extern char network_mnemonic[MAX_ACTIONS][3];
extern char *network_sequence[MAX_ACTIONS][MAX_SEQUENCES];
extern int network_check[MAX_ACTIONS][MAX_SEQUENCES];
extern int network_device[MAX_ACTIONS];



/*****************************************************************************
 *
 *   Subroutine declarations
 *
 *****************************************************************************/

int open_network(int box);
int close_network(int box);
int send_network(int device, char *buf, unsigned int timeout);
int read_network(int device, char *buf, size_t buf_len, unsigned int timeout);
int network_connected(int device);

int handle_network__(char *line, int *length, int *device, int *ierr,
		     long *ipcode);

int logit();



/*****************************************************************************
 *
 *   handle_network
 *
 *     handle the communication with a network-controlled device using
 *     the sequence of commands specified in 'ibad.ctl'
 *
 *****************************************************************************/

int handle_network__(char *line, int *length, int *device, int *ierr,
		     long *ipcode) {

  char command[256], dynamic_command[256], string[512], error[256];
  int answer = 0, failed = 0;
  int i, j;

  strncpy(dynamic_command, &line[4], *length-4);
  dynamic_command[*length-4] = '\0';

  /*  Loop once or twice if we have a communication problem  */

  for ( i = 0 ; i == 0 || i == 1 && failed ; i++ ) {

    /*  Open the connection with the network device, if we are not
	connected --- bomb out if it fails  */

    if ( ! network_connected(*device) ) {
      //logit("Trying to open network connection", 0, "un");
      if ( open_network(network_device[*device]) < 0 ) {
	logit("ERROR", errno, "un");
	*ierr = -601;
	memcpy((char *) ipcode, "PO", 2);
	return(-1);
      }
    }

    /*  Send the sequence of commands --- if we encounter a problem, then stop
	and repeat the outer loop once --- if this is already the second
	loop and we still have problems, then bomb out  */

    for ( j = 0 ; network_sequence[*device][j] != NULL ; j++ ) {
      strcpy(command, network_sequence[*device][j]);

      /*  Read a reply from the network device, if we are expecting a reply  */

      if ( strcmp(command, "$$") == 0 ) {
	if ( read_network(*device, line, MAX_READ_LENGTH,
			  READ_TIMEOUT) < 0 ) {
	  if ( failed ) {
	    logit("ERROR failed to read from network device", 0, "un");
	    *ierr = -603;
	    memcpy((char *) ipcode, "PR", 2);
	    close_network(network_device[*device]);
	    return(-1);
	  }
	  logit("Will try to reopen network communication", 0, "un");
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
	    logit("ERROR no command provided to network device", 0, "un");
	    *ierr = -604;
	    memcpy((char *) ipcode, "PN", 2);
	    close_network(network_device[*device]);
	    return(-1);
	  }
	  strcpy(command, dynamic_command);
	}

	/*  Send the command to the network device  */

	if ( send_network(*device, command, SEND_TIMEOUT) < 0 ) {
	  if ( failed ) {
	    logit("ERROR failed to send command to network device", 0, "un");
	    *ierr = -602;
	    memcpy((char *) ipcode, "PW", 2);
	    close_network(network_device[*device]);
	    return(-1);
	  }
	  logit("Will try to reopen network communication", 0, "un");
	  failed = 1;
	  break;
	}
      }

      /*  Send the error checking command, if we are supposed to do that  */

      if ( network_check[*device][j] ) {
	if ( send_network(*device, ":SYST:ERR?", SEND_TIMEOUT) < 0 ) {
	  snprintf(string, sizeof(string), "WARNING failed when sending an "
		   "error checking command after command '%s'!", command);
	  logit(string, 0, NULL);
	  if ( failed ) {
	    logit("ERROR failed to send command to network device", 0, "un");
	    *ierr = -602;
	    memcpy((char *) ipcode, "PW", 2);
	    close_network(network_device[*device]);
	    return(-1);
	  }
	  logit("Will try to reopen network communication", 0, "un");
	  failed = 1;
	  break;
	} else {
	  if ( read_network(*device, error, sizeof(error) - 1,
			    READ_TIMEOUT) < 0 ) {
	    snprintf(string, sizeof(string), "WARNING failed reading out the "
		     "result from the error checking command sent after "
		     "command '%s'!", command);
	    logit(string, 0, NULL);
	    if ( failed ) {
	      logit("ERROR failed to read from network device", 0, "un");
	      *ierr = -603;
	      memcpy((char *) ipcode, "PR", 2);
	      close_network(network_device[*device]);
	      return(-1);
	    }
	    logit("Will try to reopen network communication", 0, "un");
	    failed = 1;
	    break;
	  } else if ( strncmp(error, "+0", 2) != 0 &&
		      strncmp(error, "0", 1) != 0 ) {
	    snprintf(string, sizeof(string), "WARNING received error message "
		     "'%s' after sending command '%s'!", error, command);
	    logit(string, 0, NULL);
	  }
	}
      }

    }

  }

  logit("Closing network connection after successful communication", 0, "un");

  close_network(network_device[*device]);

  return(answer);
}
