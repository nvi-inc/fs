
/* Call me tstMark5A.  I connect to socket m5drive (c.f., /etc/services) 
 * on the Mark5A machine specified on my command line or defaulted below.  
 * The program Mark5A must be running on that machine, else this 
 * connection fails.  Then I read Mark5A commands (c.f., Mark5A.c) from 
 * stdin, send them through the socket to Mark5A, and print the responses 
 * to stdout.  I loop and try to read and send more commands until ^C. 
 * Revised:  2002 February 18, JAB */ 
#include <stdio.h> 
#include <string.h> /* For strrchr() */ 
#include <sys/types.h> /* For socket() and connect() */
#include <sys/socket.h> /* For socket() and connect() */
#include <netinet/in.h> /* For socket() with PF_INET */ 
#include <netdb.h> /* For getservbyname() and gethostbyname() */ 
#include <unistd.h> /* For close() */ 
#define MACHINE "mark5-04" /* Default machine name, default domain */ 
extern int h_errno; /* From gethostbyname() for herror() */ 
extern void herror(const char * s); /* Needed on HP-UX */ 
    /* Why (!) isn't this in one of these includes on HP-UX? */ 
char * me; /* My name */ 
int msglev = 0; /* Debug level */ 

int main(int argc, char * argv[]) { /* tstMark5A */ 
  char * machine; /* Mark5A machine name */ 
  int sock; /* Socket */ 
  FILE * fsock; /* Socket also as a stream */ 
  int i, len; /* Scratch */ 
  struct servent * set; /* From getservbyname() */ 
  struct sockaddr_in socaddin; /* For connect() info */ 
  struct hostent * hostinfo; /* From gethostbyname() */ 
  unsigned char * uc; /* To debug print IP address */ 
  char inLine[256]; /* Input from stdin to Mark5A socket */ 
  char outLine[1024]; /* Answer from Mark5A socket to stdout */ 

  /* ** Initialize ** */ 
  me = (me = strrchr(argv[0], '/')) == NULL ? argv[0] : me+1; /* My name */ 
  if (argc > 1) /* Machine name on command line? */ 
    machine = argv[1]; /* Yes */ 
  else /* Nope */ 
    machine = MACHINE; /* Use default */ 
  /* * Create a socket * */ 
  if ((sock = socket(PF_INET, SOCK_STREAM, 0)) < 0) { /* Errors? */ 
    (void) fprintf(stderr, /* Yes */ 
        "%s ERROR: \007 socket() returned %d ", me, sock); 
    perror("error"); 
    return(-1); /* Error */ } 
  if (msglev < 1) /* Debuggery? */ 
    (void) fprintf(stderr, "%s DEBUG:  sock is %d \n", me, sock); 
  socaddin.sin_family = PF_INET; /* To agree with socket() */ 
  /* * Get service number for socket m5drive * */ 
  if ((set = getservbyname("m5drive", "tcp")) == NULL) { /* Errors? */ 
    (void) fprintf(stderr, /* Yes */ 
        "%s ERROR: \007 m5drive tcp not found in /etc/services \n", me); 
    (void) close(sock); 
    return(-2); /* Error */ } 
  socaddin.sin_port = set->s_port; /* Port m5drive's number */
  if (msglev < 1) /* Debuggery? */
    (void) fprintf(stderr," port %d\n", set->s_port);
  if (msglev < 1) /* Debuggery? */
    (void) fprintf(stderr, "%s DEBUG:  m5drive port is %d \n", 
        me, ntohs(socaddin.sin_port)); 
  /* * Find IP address of machine to connect to * */ 
  if ((hostinfo = gethostbyname(machine)) == NULL) { /* Get IP, OK? */
    (void) fprintf(stderr, /* Nope */ 
        "%s ERROR: \007 gethostbyname() on %s returned NULL ", me, machine);
    herror("error"); /* Error */ 
    switch (h_errno) { /* Which error? */
      case HOST_NOT_FOUND :
        (void) fprintf(stderr, "%s ERROR:  host %s not found \n", me, machine);
        break;
      case TRY_AGAIN :
        (void) fprintf(stderr,
            "%s ERROR:  no response, try again later \n", me);
        break;
      case NO_RECOVERY :
        (void) fprintf(stderr,
            "%s ERROR:  unknown error, not recoverable \n", me);
        break;
      case NO_ADDRESS : /* = NO_DATA */
        (void) fprintf(stderr, "%s:  No Internet address available \n", me);
      } /* End of switch */ 
    (void) close(sock); 
    return(-3); /* Error */
    } /* End of if hostinfo NULL */ 
  if (hostinfo->h_addr_list[0] == NULL) { /* First IP address OK? */ 
    (void) fprintf(stderr, /* Nope */ 
        "%s ERROR: \007 gethostbyname() on %s returned NULL IP address \n", 
        me, machine); 
    (void) close(sock); 
    return(-4); /* Error */ } 
  if (msglev < 1) { /* Debuggery? */ 
    uc = (unsigned char *) hostinfo->h_addr_list[0]; /* Yes */ 
    (void) fprintf(stderr, /* Yes */ 
        "%s DEBUG:  IP address of %s is [", me, machine); 
    for (i = 0; i < hostinfo->h_length; i++) { 
      if (i > 0) 
        (void) printf("."); 
      (void) printf("%u", uc[i]); } 
    (void) printf("] \n"); } 
  socaddin.sin_addr.s_addr = *((unsigned long *) hostinfo->h_addr_list[0]); 
      /* Use first address */ 
  /* * Connect this socket to Mark5A on machine * */ 
  if (msglev < 1) /* Debuggery? */ 
    (void) fprintf(stderr, "%s DEBUG:  Trying to connect() \n", me); /* Yes */ 
  if (connect(sock, (const struct sockaddr *) &socaddin, 
      sizeof(struct sockaddr_in)) < 0) { /* Connect, errors? */ 
    (void) fprintf(stderr, /* Yes */
        "%s ERROR: \007 connect() returned ", me);
    perror("error"); 
    (void) close(sock); 
    return(-3); /* Error */ } 
  if (msglev < 1) /* Debuggery? */ 
    (void) fprintf(stderr, /* Yes */ 
        "%s DEBUG:  Got a connect() on sock %d \n", me, sock); 
  /* * Open socket also to read as a stream * */ 
  if ((fsock = fdopen(sock, "r")) == NULL) { /* OK? */
    (void) fprintf(stderr, /* Nope */
        "%s ERROR: \007 fdopen() on sock %d returned ", me, sock);
    perror("error");
    (void) close(sock); /* Error */ 
    return(-4); /* Error */ } 
  if (msglev < 1) /* Debuggery? */ 
    (void) fprintf(stderr, /* Yes */ 
        "%s DEBUG:  Socket %d open also as a stream \n", me, sock); 
  /* End of initialization */ 
  (void) printf("%s Ready (end with ^C) \n", me); 
  /* ** Main working loop ** */ 
  while (1) { /* Loop forever */ 
    /* * Prompt and read a command * */ 
    (void) printf("> "); 
    (void) fgets(inLine, sizeof(inLine), stdin); /* Read from stdin */ 
    if (msglev < 1) /* Debuggery? */ 
      (void) fprintf(stderr, /* Yes */ 
          "%s DEBUG:  Got inLine[] = %s", me, inLine); 
    if ((len = strlen(inLine)) < 5) { /* OK? */ 
      (void) fprintf(stderr, /* Nope */ 
          "%s ERROR: \007 Illegal command, try again \n", me); 
      continue; /* Next while loop */ } 
    /* * Send command * */ 
    if (send(sock, inLine, len, 0) < len) { /* Send to socket, OK? */ 
      (void) fprintf(stderr, /* Nope */ 
          "%s ERROR: \007 send() on socket returned ", me); 
      perror("error"); 
      (void) close(sock); 
      return(-5); /* Error */ } 
    if (msglev < 1) /* Debuggery? */ 
      (void) fprintf(stderr, /* Yes */ 
          "%s DEBUG:  Sent inLine[] to socket %d \n", me, sock); 
    /* * Read reply * */ 
    if (fgets(outLine, sizeof(outLine), fsock) == NULL) { /* OK? */ 
      (void) fprintf(stderr, /* Nope */ 
          "%s ERROR: \007 fgets() on socket returned ", me); 
      perror("error"); 
      (void) fclose(fsock); 
      return(-6); /* Error */ } 
    /* * Print reply * */ 
    (void) fputs(outLine, stdout); /* Print to stdout */ 
    } /* End of while loop forever */ 
  return(0); /* Not used */ 
  } /* End of main = tstMark5A */ 

