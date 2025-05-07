/*****************************************************************************
 *
 * FILE: util_network.c
 *
 *   Utility routines used when communicating with a network-controlled
 *   device.
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
 * lerner       26 Jul 2012    Original version (including a set of procedures
 *                             written by Lars Pettersson)
 * lerner        7 Feb 2013    Added user-specified port-number to enable
 *                             communication with network-based devices
 * lerner       27 Apr 2021    Adapted for inclusion in FS10
 *
 *****************************************************************************/

#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <unistd.h>
#include <errno.h>
#include <fcntl.h>
#include <netdb.h>
#include <sys/ioctl.h>



/*****************************************************************************
 *
 *   Macros
 *
 *****************************************************************************/

#define MAX_ACTIONS                    50
#define MAX_SEQUENCES                  20

#define CONNECT_TIMEOUT                 5



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

/*  Internal subroutines  */

int connect_timeout(int sock, struct sockaddr *addr, socklen_t addrlen,
		    int seconds);
int open_connection(int *fd, char *host, char *host_port);
int recvtimeout(int socket, char *buf, size_t buf_len, unsigned int timeout);
int sendtimeout(int socket, char *buf, size_t buf_len, unsigned int timeout);

/*  Public subroutines  */

int open_network(int box);
int close_network(int box);
int send_network(int device, char *buf, unsigned int timeout);
int read_network(int device, char *buf, size_t buf_len, unsigned int timeout);
int network_connected(int device);

/*  External subroutines  */

int logit();
int logita();



/*****************************************************************************
 *
 *   connect_timeout
 *
 *     this is an alternative 'connect' routine which allows you to set
 *     a time-out instead of having to wait many minutes on non-existing
 *     addresses as with the standard 'connect'
 *
 *****************************************************************************/

int connect_timeout(int sock, struct sockaddr *addr, socklen_t addrlen,
		    int seconds) {

  fd_set write_fd;
  struct timeval timeout;
  char string[512];
  unsigned long mode;
  int status;

  /*  Set up a non-blocking socket  */

  mode = 1;

  status = ioctl(sock, FIONBIO, &mode);

  if ( status != 0 ) {
    snprintf(string, sizeof(string), "ioctl failed with error: %ld   errno "
	     "= %d", status, errno);
    logit(string, 0, NULL);
    return(-1);
  }

  /*  Try the connect and return immediately if we get an error that is not
      EINPROGRESS  */

  status = connect(sock, addr, addrlen);

  if ( status == -1 && errno != EINPROGRESS )
    return(-1);

  /*  Reset the socket to blocking mode  */

  mode = 0;

  status = ioctl(sock, FIONBIO, &mode);

  if ( status != 0 ) {
    snprintf(string, sizeof(string), "ioctl failed with error: %ld   errno "
	     "= %d", status, errno);
    logit(string, 0, NULL);
    return(-1);
  }

  /*  Set up the time-out and the file descriptor list  */

  timeout.tv_sec = seconds;
  timeout.tv_usec = 0;

  FD_ZERO(&write_fd);
  FD_SET(sock, &write_fd);


  /*  Check if the socket is ready  */

  status = select(FD_SETSIZE, NULL, &write_fd, NULL, &timeout);

  if ( FD_ISSET(sock, &write_fd) )
    return(0);

  return(-1);
}



/*****************************************************************************
 *
 *   open_connection
 *
 *     open the socket connection to a network device --- code written by
 *     Lars Pettersson with slight modifications
 *
 *****************************************************************************/

int open_connection(int *fd, char *host, char *host_port)
{
    struct addrinfo hints;
    struct addrinfo *result, *rp;
    char string[512];
    int opts, s;

    memset(&hints, 0, sizeof(struct addrinfo));
    hints.ai_family = AF_UNSPEC;	/* Allow IPv4 or IPv6 */
    hints.ai_socktype = SOCK_STREAM;	/* Stream (TCP) socket */
    hints.ai_flags = 0;
    hints.ai_protocol = 0;	/* Any protocol */

    if ((s = getaddrinfo(host, host_port, &hints, &result))) {
        snprintf(string, sizeof(string), "getaddrinfo() => %s",
		 gai_strerror(s));
	logit(string, 0, NULL);
	return -1;
    }

    /* getaddrinfo() returns a list of address structures. Try each
     * address until we successfully connect(2). If socket(2) (or
     * connect(2)) fails, we (close the socket and) try the next
     * address.
     */
    for (rp = result; rp != NULL; rp = rp->ai_next) {

	*fd = socket(rp->ai_family, rp->ai_socktype, rp->ai_protocol);

	if (*fd == -1) {
	    snprintf(string, sizeof(string), "socket() => %s",
		     strerror(errno));
	    logit(string, 0, NULL);
	    continue;
	}

	if (connect_timeout(*fd, rp->ai_addr, rp->ai_addrlen,
			    CONNECT_TIMEOUT) != -1) {
	    break;		/* Success */
	}

	snprintf(string, sizeof(string), "connect() => %s", strerror(errno));
	logit(string, 0, NULL);

	close(*fd);
    }

    freeaddrinfo(result);	/* No longer needed */

    if (rp == NULL) {		/* No address succeeded */
	snprintf(string, sizeof(string), "open_connection() => could not "
		 "connect, no address succeeded");
	logit(string, 0, NULL);
	*fd = -1;
	return -1;
    }

    if ((opts = fcntl(*fd, F_GETFL)) < 0) {
	snprintf(string, sizeof(string), "fcntl(serv_sock, F_GETFL) => %s",
		 strerror(errno));
	logit(string, 0, NULL);
	(void) close(*fd);
	return -1;
    }
    opts |= O_NONBLOCK;
    if (fcntl(*fd, F_SETFL, opts) < 0) {
	snprintf(string, sizeof(string), "fcntl(serv_sock, F_SETFL, opts) => "
		 "%s", strerror(errno));
	logit(string, 0, NULL);
	(void) close(*fd);
	return -1;
    }

    return 0;
}



/*****************************************************************************
 *
 *   recvtimeout
 *
 *     receive a message from a network device with a time-out --- code written
 *     by Lars Pettersson with slight modifications
 *
 *****************************************************************************/

/* --- receive characters, but do not wait forever ---
 *
 * Returns:
 *  number of bytes received on success
 *  0 if remote side has closed the connection
 *  -1 on error
 *  -2 on timeout
 *  -3 on select error
 */

int recvtimeout(int socket, char *buf, size_t buf_len, unsigned int timeout)
{
    fd_set fds;
    struct timeval tv;

    /* set up the file descriptor set */
    FD_ZERO(&fds);
    FD_SET(socket, &fds);

    /* set up the timeval struct for the timeout */
    tv.tv_sec = timeout;
    tv.tv_usec = 0;

    /* wait until timeout or data received */
    switch (select(socket + 1, &fds, NULL, NULL, &tv)) {
    case 0:
	/* timeout */
	return -2;
    case -1:
	/* error */
	return -3;
    default:
	/* data available */
	break;
    }
    return recv(socket, buf, buf_len, 0);
}



/*****************************************************************************
 *
 *   sendtimeout
 *
 *     send a message to a network device with a time-out --- code written
 *     by Lars Pettersson with slight modifications
 *
 *****************************************************************************/

/* --- send characters, but do not wait forever ---
 *
 * Returns:
 *  number of bytes received on success
 *  0 if remote side has closed the connection
 *  -1 on error
 *  -2 on timeout
 *  -3 on select error
 */

int sendtimeout(int socket, char *buf, size_t buf_len, unsigned int timeout)
{
    fd_set fds;
    struct timeval tv;

    /* set up the file descriptor set */
    FD_ZERO(&fds);
    FD_SET(socket, &fds);

    /* set up the timeval struct for the timeout */
    tv.tv_sec = timeout;
    tv.tv_usec = 0;

    /* wait until timeout or data received */
    switch (select(socket + 1, NULL, &fds, NULL, &tv)) {
    case 0:
	/* timeout */
	return -2;
    case -1:
	/* error */
	return -3;
    default:
	/* data available */
	break;
    }
    return send(socket, buf, buf_len, 0);
}



/*  Wrappers to Lars Pettersson's procedures  */

/*****************************************************************************
 *
 *   open_network
 *
 *     open a socket for communication with a network device --- return status
 *     is either '0' or '-1'
 *
 *****************************************************************************/

int open_network(int box) {

  char string[512];
  int status;

  snprintf(string, sizeof(string), "Opening socket to network device at %s "
	   "port %s ...", network_address[box], network_port[box]);
  logit(string, 0, NULL);

  status = open_connection(&network_socket[box], network_address[box],
			   network_port[box]);

  if ( status < 0 ) {
    logit("Failed opening socket!", 0, NULL);
    network_socket[box] = -1;
  }
//  } else
//    logit("Socket successfully opened", 0, NULL);

  return(status);
}



/*****************************************************************************
 *
 *   close_network
 *
 *     close the socket used for communication with a network device, if it is
 *     open --- return status is always '0'
 *
 *****************************************************************************/

int close_network(int box) {

  if ( network_socket[box] > -1 )
    close(network_socket[box]);

  network_socket[box] = -1;

  return(0);
}



/*****************************************************************************
 *
 *   send_network
 *
 *     send a message to the network device --- the message should be given
 *     in 'buf' --- 'timeout' is specified in integer seconds --- return
 *     status is either '0' or '-1' --- in case of any error, this procedure
 *     will send an error message to the log and close the socket
 *     communication
 *
 *****************************************************************************/

int send_network(int device, char *buf, unsigned int timeout) {

  char string[512];
  int box, status, length;

  box = network_device[device];

/*  Verify that we are connected --- if we are not then there should be
    a programming error, so we just bomb out of here  */

  if ( network_socket[box] == -1 ) {
    logita("ERROR network device send called without previous connect", 0, "ib",
	   "P0");
    return(-1);
  }

/*  Send the message to the network device  */

  length = snprintf(string, sizeof(string), "%s\n", buf);

  status = sendtimeout(network_socket[box], string, length, timeout);

/*  Return immediately if everything went fine  */

  if ( status == length )
    return(0);

/*  Report the error  */

  if ( status == -2 ) {
    logita("WARNING time-out on network device send", 0, "ib", "P1");
  } else if ( status == -3 ) {
    logita("WARNING select error on network device send", 0, "ib", "P2");
    logita(NULL, errno, "ib", "P2");
  } else if ( status == -1 ) {
    logita("WARNING send error on network device send", 0, "ib", "P3");
    logita(NULL, errno, "ib", "P3");
  } else if ( status == 0 ) {
    logita("WARNING connection closed on network device send", 0, "ib", "P4");
  } else if ( status < length ) {
    snprintf(string, sizeof(string), "WARNING only %d bytes of %d sent to "
	     "network device", status, length);
    logita(string, 0, "ib", "P5");
  } else {
    logita("ERROR weird error on network device send", 0, "ib", "P6");
  }

/*  Close the socket to the network device  */

  close_network(box);

  return(-1);
}



/*****************************************************************************
 *
 *   read_network
 *
 *     read a message from the network device --- the message will be stored
 *     in 'buf' and the length of 'buf' should be specified in 'buf_len' ---
 *     'timeout' is specified in integer seconds --- return status is either
 *     '0' or '-1' --- in case of any error, this procedure will send
 *     an error message to the log and close the socket communication
 *
 *****************************************************************************/

int read_network(int device, char *buf, size_t buf_len, unsigned int timeout) {

  char string[256];
  int box, status;

  box = network_device[device];

/*  Verify that we are connected --- if we are not then there should be
    a programming error, so we just bomb out of here  */

  if ( network_socket[box] == -1 ) {
    logita("ERROR network device read called without previous connect", 0, "ib",
	   "P0");
    return(-1);
  }

/*  Read the message from the network device  */

  status = recvtimeout(network_socket[box], buf, buf_len, timeout);

/*  Process the message and return if we managed to read something ---
    the processing consists of stripping any trailing new-line character
    and adding a string termination character  */

  if ( status > 0 ) {
    if ( buf[status-1] == '\n' )
      buf[--status] = '\0';
    if ( buf[status-1] == '\r' )
      buf[--status] = '\0';
    if ( status < buf_len )
      buf[status] = '\0';
    return(0);
  }

/*  Report the error  */

  if ( status == -2 ) {
    logita("WARNING time-out on network device read", 0, "ib", "P1");
  } else if ( status == -3 ) {
    logita("WARNING select error on network device read", 0, "ib", "P2");
    logita(NULL, errno, "ib", "P2");
  } else if ( status == -1 ) {
    logita("WARNING read error on network device read", 0, "ib", "P3");
    logita(NULL, errno, "ib", "P3");
  } else if ( status == 0 ) {
    logita("WARNING connection closed on network device read", 0, "ib", "P4");
  } else {
    logita("ERROR weird error on network device read", 0, "ib", "P6");
  }

/*  Close the socket to the network device  */

  close_network(box);

  return(-1);
}



/*****************************************************************************
 *
 *   network_connected
 *
 *     returns a '1' if the socket for communication with the network device is
 *     open and '0' otherwise
 *
 *****************************************************************************/

int network_connected(int device) {

  int box;

  box = network_device[device];

  if ( network_socket[box] == -1 )
    return(0);

  return(1);
}
