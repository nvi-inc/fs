/*****************************************************************************
 *
 * FILE: check_prologix.c
 *
 *   Check the provided line coming from 'ibad.tcl' to see if it contains
 *   a network-controlled device --- if so, process it here.
 *
 *   Network-controlled devices are GPIB-devices which are controlled either
 *   using TCP/IP communication with a Prologix GPIB-ethernet controller box or
 *   directly via a TCP/IP interface instead of via a dedicated GPIB-card in
 *   the FS computer.
 *
 *   Note that this procedure is very general and also allows you to talk
 *   with devices that are connected directly to a TCP/IP-network.
 *
 *   This version of IBCON allows you to mix and match between a GPIB-card,
 *   a Prologix-box controlling several devices on a common GPIB-bus,
 *   multiple GPIB-boxes each controlling a single GPIB-device or
 *   any combination of these options.
 *
 *   This procedure is part of the 'ibcon' program.
 *
 *   Network-controlled devices use the following syntax in the 'ibad.ctl'
 *   file:
 *
 *   MN=net,IP-address,port,command[/command[/command...]]
 *
 *   where 'MN' is the mnemonic used to identify the device, 'IP-address' is
 *   the IP-adress of the device or the Prologix-box given in 'a.b.c.d'
 *   notation, 'port' is the port number to use (port should be "1234" for
 *   Prologix-boxes but can be other things for other network-based
 *   devices --- network-based GPIB-devices seem to use port "5025",
 *   for example) and the command sequence is the set commands to send when
 *   communicating with the device, which typically will include
 *   Prologix-commands used to set up the Prologix box as well as
 *   the GPIB-command to the device itself.
 *
 *   Two special commands are recognized: '##' means that the GPIB-command
 *   passed to IBCON at the time of execution should be inserted at that point
 *   in the sequence, while '$$' means that the device has generated a reply
 *   that should be read at this point in the sequence.
 *
 *   A '&' can be appended to any command; this command will then be followed
 *   automatically by the ':SYST:ERR?' command and any error reported will
 *   be written to the log. For example, the command sequence
 *   '*RST/:INIT:CONT ON&' will consequtively send the following three commands:
 *   '*RST', ':INIT:CONT ON' and ':SYST:ERR?', then wait for the reply and
 *   report an error if the reply is not '+0,"No error"'.
 *
 *   Different commands can be sent to the same device by giving them different
 *   mnemonics, and for network-controlled devices the mnemonic should be seen
 *   more as symbols for different actions instead of different devices.
 *
 *   At Onsala Space Observatory, we use two HP-devices for CABLE and CLOCK
 *   measurements, both being controlled by an individual Prologix-box.
 *   The 'ibad.ctl' file looks like this:
 *
 *   CA=net,192.16.6.15,1234,++auto 0/++addr 2/++read_tmo_ms 1000/++read 10/$$
 *   CB=net,192.16.6.16,1234,++addr 3/++auto 1/:READ?/$$/++auto 0/:INIT:CONT ON
 *
 *   We also have another HP-devices that can be used for CLOCK measurements.
 *   It also uses GPIB-syntax but it is connected directly to
 *   the TCP/IP-network. We can control that one with the following
 *   'ibad.ctl' line:
 *
 *   CX=net,192.16.6.17,5025,:READ?/$$/:INIT:CONT ON
 *
 *   The following example shows four mnemonics to talk to the same device:
 *   the first one is a standard read request, the second one is a reset
 *   command and the last two ones are for general commands and questions,
 *   respectively.
 *
 *   CB=net,192.16.6.16,1234,++addr 3/++auto 1/:READ?/$$/++auto 0/:INIT:CONT ON
 *   CC=net,192.16.6.16,1234,++addr 3/++auto 0/*RST
 *   CD=net,192.16.6.16,1234,++addr 3/++auto 0/##
 *   CE=net,192.16.6.16,1234,++addr 3/++auto 1/##/$$
 *
 * HISTORY
 *
 * who          when           what
 * ---------    -----------    ----------------------------------------------
 * lerner       26 Jul 2012    Original version
 * lerner       12 Feb 2013    Added user-specified port-number to enable
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



/*****************************************************************************
 *
 *   Global variables
 *
 *****************************************************************************/

/*  Prologix box variables  */

int prologix_boxes = 0;
char prologix_address[MAX_PROLOGIX][16];
char prologix_port[MAX_PROLOGIX][8];
int prologix_socket[MAX_PROLOGIX];

/*  Prologix device variables  */

int prologix_devices = 0;
char prologix_mnemonic[MAX_PROLOGIX][3];
char *prologix_sequence[MAX_PROLOGIX][MAX_SEQUENCES];
int prologix_check[MAX_PROLOGIX][MAX_SEQUENCES];
int prologix_box[MAX_PROLOGIX];



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

int check_prologix__(char *line, int *length);



/*****************************************************************************
 *
 *   check_prologix
 *
 *     check the line from the ibad.ctl file --- return immediately with '0'
 *     if it is not a Prologix-controlled device, otherwise process the line
 *     and return the assigned index in the Prologix device tables or '-1'
 *     in case of an error
 *
 *****************************************************************************/

int check_prologix__(char *line, int *length) {

  char setup[512], string[512], address[128], port[128], commands[512];
  char *p, *p1;
  int device, box;
  int i;

  /*  Copy over the line to our work string  */

  if ( *length >= sizeof(setup) ) {
    logit("Too large lines in file ibad.ctl", 0, NULL);
    return(-1);
  }

  strncpy(setup, line, *length);
  setup[*length] = '\0';

  logit(setup, 0, NULL);

  /*  Return immediately, if this is not a Prologix-controlled device  */

  if ( strncmp(&setup[3], "net", 3) != 0 )
    return(0);

  /*  Verify that we don't have too many Prologix-controlled devices  */

  if ( ++prologix_devices >= MAX_PROLOGIX ) {
    logit("Too many Prologix-devices declared in file ibad.ctl", 0, NULL);
    snprintf(string, sizeof(string), "Offending line: '%s'", setup);
    logit(string, 0, NULL);
    return(-1);
  }

  /*  Store the mnemonic of the new Prologix-controlled device --- note that
      we don't use element '0' since we want positive numbers  */

  device = prologix_devices;

  strncpy(prologix_mnemonic[device], setup, 2);
  prologix_mnemonic[device][2] = '\0';

  /*  Get the IP-address of the Prologix-box --- let's use strtok to split
      the string  */

  strtok(setup, ",");

  if ( ( p = strtok(NULL, ",") ) == NULL ) {
    logit("No comma after word 'net' in file ibad.ctl", 0, NULL);
    snprintf(string, sizeof(string), "Offending line: '%s'", setup);
    logit(string, 0, NULL);
    return(-1);
  }

  strncpy(address, p, sizeof(address));

  /*  Now get the port number from the string  */

  if ( ( p = strtok(NULL, ",") ) == NULL ) {
    logit("No comma after IP-address in file ibad.ctl", 0, NULL);
    snprintf(string, sizeof(string), "Offending line: '%s'", setup);
    logit(string, 0, NULL);
    return(-1);
  }

  strncpy(port, p, sizeof(port));

  /*  Now get the command sequence from the string --- note that we change
      the delimiter since commands may contain commas  */

  if ( ( p = strtok(NULL, "\n") ) == NULL ) {
    logit("No comma after port-number in file ibad.ctl", 0, NULL);
    snprintf(string, sizeof(string), "Offending line: '%s'", setup);
    logit(string, 0, NULL);
    return(-1);
  }

  strncpy(commands, p, sizeof(commands));

  /*  Check if we already have registered this Prologix-box or if it is
      a new one  */

  box = -1;

  for ( i = 0 ; i < prologix_boxes ; i++ )
    if ( strcmp(prologix_address[i], address) == 0 )
      box = i;

  if ( box == -1 ) {
    if ( strlen(address) >= sizeof(prologix_address[0]) ) {
      logit("Bad IP-address in file ibad.ctl", 0, NULL);
      snprintf(string, sizeof(string), "Offending line: '%s'", setup);
      logit(string, 0, NULL);
      return(-1);
    }
    if ( strlen(port) >= sizeof(prologix_port[0]) ) {
      logit("Bad port-number in file ibad.ctl", 0, NULL);
      snprintf(string, sizeof(string), "Offending line: '%s'", setup);
      logit(string, 0, NULL);
      return(-1);
    }
    box = prologix_boxes++;
    strcpy(prologix_address[box], address);
    strcpy(prologix_port[box], port);
    prologix_socket[box] = -1;
    /*
    if ( open_prologix(box) < 0 ) {
      snprintf(string, sizeof(string), "Failed to open socket to Prologix-box "
	       "at '%s' port '%s' for device '%s'", prologix_address[box],
	       prologix_port[box], prologix_mnemonic[device]);
      logit(string, 0, NULL);
      logit("ERROR", errno, "un");
    }
    */
  }

  prologix_box[device] = box;

  /*  Split up and store the Prologix command sequence  */

  p1 = commands;
  i = 0;

  while ( ( p = strtok(p1, "/") ) != NULL ) {
    if ( i + 1 >= MAX_SEQUENCES ) {
      logit("Too many commands for device in file ibad.ctl", 0, NULL);
      snprintf(string, sizeof(string), "Offending line: '%s'", setup);
      logit(string, 0, NULL);
      return(-1);
    }
    prologix_sequence[device][i] = (char *) malloc(strlen(p) + 1);
    strcpy(prologix_sequence[device][i], p);
    prologix_check[device][i] = 0;
    if ( prologix_sequence[device][i][strlen(p)-1] == '&' ) {
      prologix_sequence[device][i][strlen(p)-1] = '\0';
      prologix_check[device][i] = 1;
    }
    i++;
    p1 = NULL;
  }

  prologix_sequence[device][i] = NULL;

  /*  Write a message to the log  */

  sprintf(string, "initiated GPIB-device %s on Prologix %s port %s "
	  "(%d commands)", prologix_mnemonic[device], prologix_address[box],
	  prologix_port[box], i);
  logit(string, 0, NULL);

  return(device);
}
