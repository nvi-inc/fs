/*****************************************************************************
 *
 * FILE: check_network.c
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
 *   with any device that are connected directly to a TCP/IP-network and uses
 *   an ASCII-syntax.
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
 *   MN=net,IP-address,port,/command1[/command2[/command3...]]
 *
 *   where 'MN' is a 2-character mnemonic used to identify the device action,
 *   'IP-address' is the IP-address of the device or the Prologix-box given
 *   in 'a.b.c.d' notation, 'port' is the port number to use (port should be
 *   "1234" for Prologix-boxes but can be other things for other network-based
 *   devices --- some network-based GPIB-devices seem to use port "5025",
 *   for example) and the command sequence is the set of commands to send when
 *   communicating with the device, which typically will include
 *   Prologix-commands used to set up the Prologix box as well as
 *   the GPIB-command(s) to the device itself. The command sequence should
 *   start with the character used to separate the different commands from each
 *   other (even if there is only one command). Typicaly "/" is used, but you
 *   are free to choose something else.
 *
 *   Two special commands are recognized: '##' means that the command
 *   passed to IBCON at the time of execution should be inserted at that point
 *   in the sequence, while '$$' means that the device has generated a reply
 *   that should be read at this point in the sequence.
 *
 *   A '&' can be appended to any command; this command will then be followed
 *   automatically by the ':SYST:ERR?' command and any error reported will
 *   be written to the log. For example, the command sequence
 *   '*RST/:INIT:CONT ON&' will consecutively send the following three commands:
 *   '*RST', ':INIT:CONT ON' and ':SYST:ERR?', then wait for the reply and
 *   report an error if the reply is not '+0,"No error"' - the actual test is
 *   for the "0".
 *
 *   Different commands can be sent to the same device by giving them different
 *   mnemonics, and for network-controlled devices the mnemonics should be seen
 *   more as symbols for different actions instead of different devices.
 *
 *   At Onsala Space Observatory, we use two HP-devices for CABLE and CLOCK
 *   measurements, both being controlled by individual Prologix-boxes.
 *   The 'ibad.ctl' file looks like this:
 *
 *   CA=net,192.16.6.15,1234,/++auto 0/++addr 2/++read_tmo_ms 1000/++read 10/$$
 *   CB=net,192.16.6.16,1234,/++addr 3/++auto 1/:READ?/$$/++auto 0/:INIT:CONT ON
 *
 *   We also have another HP-device that can be used for CLOCK measurements.
 *   It uses a similar syntax but it is connected directly to
 *   the TCP/IP-network. We can control that one with the following
 *   'ibad.ctl' line:
 *
 *   CX=net,192.16.6.17,5025,/:READ?/$$/:INIT:CONT ON
 *
 *   The following example shows four mnemonics to talk to the same device:
 *   the first one is a standard read request, the second one is a reset
 *   command and the last two ones are for general commands and questions,
 *   respectively.
 *
 *   CB=net,192.16.6.16,1234,/++addr 3/++auto 1/:READ?/$$/++auto 0/:INIT:CONT ON
 *   CC=net,192.16.6.16,1234,/++addr 3/++auto 0/*RST
 *   CD=net,192.16.6.16,1234,/++addr 3/++auto 0/##
 *   CE=net,192.16.6.16,1234,/++addr 3/++auto 1/##/$$
 *
 * HISTORY
 *
 * who          when           what
 * ---------    -----------    ----------------------------------------------
 * lerner       26 Jul 2012    Original version
 * lerner       12 Feb 2013    Added user-specified port-number to enable
 *                             communication with network-based devices
 * lerner        7 May 2021    Adapted for inclusion in FS10 and added dynamic
 *                             command separator
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



/*****************************************************************************
 *
 *   Global variables
 *
 *****************************************************************************/

/*  Network device variables  */

int network_devices = 0;
char network_address[MAX_ACTIONS][16];
char network_port[MAX_ACTIONS][8];
int network_socket[MAX_ACTIONS];

/*  Network action variables  */

int network_actions = 0;
char network_mnemonic[MAX_ACTIONS][3];
char *network_sequence[MAX_ACTIONS][MAX_SEQUENCES];
int network_check[MAX_ACTIONS][MAX_SEQUENCES];
int network_device[MAX_ACTIONS];



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

int check_network__(char *line, int *length);

int logit();



/*****************************************************************************
 *
 *   check_network
 *
 *     check the line from the ibad.ctl file --- return immediately with '0'
 *     if it is not a network-controlled device, otherwise process the line
 *     and return the assigned index in the network device tables or '-1'
 *     in case of an error
 *
 *****************************************************************************/

int check_network__(char *line, int *length) {

  char setup[512], string[512], address[128], port[128], commands[512];
  char separator[2], *p, *p1;
  int action, device;
  int i;

  /*  Copy over the line to our work string  */

  if ( *length >= sizeof(setup) ) {
    logit("Too large lines in file ibad.ctl", 0, NULL);
    return(-1);
  }

  strncpy(setup, line, *length);
  setup[*length] = '\0';

  logit(setup, 0, NULL);

  /*  Return immediately, if this is not a network device  */

  if ( strncmp(&setup[3], "net", 3) != 0 )
    return(0);

  /*  Verify that we don't have too many network device actions  */

  if ( ++network_actions >= MAX_ACTIONS ) {
    logit("Too many network device actions declared in file ibad.ctl", 0, NULL);
    snprintf(string, sizeof(string), "Offending line: '%s'", setup);
    logit(string, 0, NULL);
    return(-1);
  }

  /*  Store the mnemonic of the new network device action action --- note that
      we don't use element '0' since we want positive numbers  */

  action = network_actions;

  strncpy(network_mnemonic[action], setup, 2);
  network_mnemonic[action][2] = '\0';

  /*  Get the IP-address of the network device --- let's use strtok to split
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

  /*  Check if we already have registered this network device or if it is
      a new one  */

  device = -1;

  for ( i = 0 ; i < network_devices ; i++ )
    if ( strcmp(network_address[i], address) == 0 )
      device = i;

  if ( device == -1 ) {
    if ( strlen(address) >= sizeof(network_address[0]) ) {
      logit("Bad IP-address in file ibad.ctl", 0, NULL);
      snprintf(string, sizeof(string), "Offending line: '%s'", setup);
      logit(string, 0, NULL);
      return(-1);
    }
    if ( strlen(port) >= sizeof(network_port[0]) ) {
      logit("Bad port-number in file ibad.ctl", 0, NULL);
      snprintf(string, sizeof(string), "Offending line: '%s'", setup);
      logit(string, 0, NULL);
      return(-1);
    }
    device = network_devices++;
    strcpy(network_address[device], address);
    strcpy(network_port[device], port);
    network_socket[device] = -1;
    /*
    if ( open_network(device) < 0 ) {
      snprintf(string, sizeof(string), "Failed to open socket to network "
	       "device at '%s' port '%s' for action '%s'",
	       network_address[device], network_port[device],
	       network_mnemonic[action]);
      logit(string, 0, NULL);
      logit("ERROR", errno, "un");
    }
    */
  }

  network_device[action] = device;

  /*  Split up and store the network device action command sequence  */

  p1 = commands;
  i = 0;

  separator[0] = *p1++;
  separator[1] = '\0';

  while ( ( p = strtok(p1, separator) ) != NULL ) {
    if ( i + 1 >= MAX_SEQUENCES ) {
      logit("Too many commands for network device in file ibad.ctl", 0, NULL);
      snprintf(string, sizeof(string), "Offending line: '%s'", setup);
      logit(string, 0, NULL);
      return(-1);
    }
    network_sequence[action][i] = (char *) malloc(strlen(p) + 1);
    strcpy(network_sequence[action][i], p);
    network_check[action][i] = 0;
    if ( network_sequence[action][i][strlen(p)-1] == '&' ) {
      network_sequence[action][i][strlen(p)-1] = '\0';
      network_check[action][i] = 1;
    }
    i++;
    p1 = NULL;
  }

  network_sequence[action][i] = NULL;

  /*  Write a message to the log  */

  sprintf(string, "initiated action %s on network device %s port %s "
	  "(%d commands)", network_mnemonic[action], network_address[device],
	  network_port[device], i);
  logit(string, 0, NULL);

  return(action);
}
