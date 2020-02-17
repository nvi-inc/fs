#include <stdio.h>	/* standard I/O header file */
#include <errno.h>	/* error number definitions */
#include <limits.h>
#include <signal.h>
#include <sys/types.h>	/* standard data types definitions */
#include <sys/ipc.h>	/* interprocess communications (IPC) header file */
#include <sys/msg.h>	/* message IPC header file */
#include <sys/shm.h>    /* shared memory IPC header file */
#include <memory.h>    /* shared memory IPC header file */
#include <ctype.h>
#include <stdlib.h>
#include <unistd.h>

#define  MAX_BUF       256

#define FS_SKD_WAIT (1 << 30)
#define FS_SKD_NAMED (1 << 29)

struct skd_buf {
	long	mtype;
        struct {
	    int    ip[5];
	    int    rtype;
	    int     dad;
	    int timed_out;
            int run_index;
	    char arg[MAX_BUF+1];
        } messg;

} ;

static int msqid;
static int rtype=0;
static int dad=0;
static int run_index=0;
static char prog_name[5];
static char return_name[5];
static int save_ip[5];
static char arg[MAX_BUF+1];
static char arg_buff[MAX_BUF+1];
static char *argv[(MAX_BUF+1)/2];
static int  argc = -1;
static int wait_rtype=0;
static int ipr[5] = { 0, 0, 0, 0, 0};

static int mtype();
static void nullfcn();
static void skd_end_to();
void skd_end();
static skd_run_arg_cls_to(char *name, char w, int ip[5], char *arg,
			  char nsem[6],unsigned to, int *run_index);

int skd_get( key, size)
key_t key;
int size;
{
struct msqid_ds	str_msqid;  /* message queue id struct */

/* create a message queue */
msqid = msgget( key, ( IPC_CREAT | 0666 ));
if ( msqid == -1 ) {
    perror("skd_get: getting queue");
    return( -1);
}

/* set the queue size */
if (-1== msgctl( msqid, IPC_STAT, &str_msqid )) {
    perror("skd_get: getting status");
    return( -1);
}

str_msqid.msg_qbytes = size;
if(-1 == msgctl( msqid, IPC_SET, &str_msqid )) {
    perror("skd_get: setting size");
    return( -1);
}
fprintf( stdout,"skd_get: id %d\n",msqid);

return( 0);
}

void skd_ini( key)
key_t key;
{
struct skd_buf sched;
int status;

msqid = msgget( key, 0);

if ( msqid == -1 ) {
    perror("skd_ini: translating key");
    exit( -1);
}

waitr:
status = msgrcv( msqid, (struct msgbuf *) &sched, sizeof( sched.messg),
                -LONG_MAX,IPC_NOWAIT|MSG_NOERROR);

if (status != -1)
  goto waitr;
else {
  if (errno == EINTR)
    goto waitr;
  else if (errno != ENOMSG) {
    perror("skd_ini: error cleaning skd queue\n");
    exit( -1);
  }
}
}

void skd_att( key)
key_t key;
{
    msqid = msgget( key, 0);
    if ( msqid == -1 ) {
        perror("skd_att: translating key");
        exit( -1);
    }
}

void skd_boss_inject_w(iclass, buffer, length)
int    *iclass;
char	*buffer;	/* contains message for process */
int	length;	/* length of buffer in bytes */
{
  char insnp[]="insnp";

  if(*iclass==0)
    return;

  nsem_take(insnp,0);

  /* Execute this SNAP command via "boss". */
  
  cls_snd( iclass, buffer, length, 0, 1);
  skd_run_arg_cls_to("boss ",'w',ipr,(char *) NULL,insnp,
		     (unsigned) 0, (int *) NULL);


}
void skd_run( name, w, ip)
char    name[5], w;
int    ip[5];
{
  skd_run_arg_cls_to( name, w, ip, (char *) NULL, (char *) NULL,
		      (unsigned) 0, (int *) NULL);
}

void skd_run_p( name, w, ip, run_index)
     char    name[5], w;
int    ip[5];
int *run_index;
{
  skd_run_arg_cls_to( name, w, ip, (char *) NULL, (char *) NULL,
		      (unsigned) 0, run_index);
}

void skd_run_arg( name, w, ip, arg)
char	name[5], w, *arg;	
int	ip[5];
/* arg maximum length is 256 characters, longer values are truncated */
{
  skd_run_arg_cls_to( name, w, ip, arg, (char *) NULL,
		      (unsigned) 0, (int *) NULL);
}

int skd_run_to( name, w, ip, to)
char    name[5], w;
int    ip[5];
unsigned to;
{  
  return skd_run_arg_cls_to( name, w, ip, (char *) NULL, (char *) NULL,
			     to, (int *) NULL);
}

static skd_run_arg_cls_to( name, w, ip, arg, nsem,to, run_index)
char	name[5], w, *arg;	
int	ip[5];
char nsem[6];
unsigned to;
int *run_index;
{
int	status, i, n;
struct skd_buf sched;

  if (w == 'w' || w == 'p') {
      if (return_name[0]) {
          sched.messg.rtype =
              FS_SKD_WAIT | FS_SKD_NAMED | mtype(return_name);
      } else {
          sched.messg.rtype = FS_SKD_WAIT | getpid();
      }
  } else {
      sched.messg.rtype = 0;
  }

 if( run_index!=NULL)
   sched.messg.run_index=*run_index;
 else
   sched.messg.run_index=0;

 if(name!=NULL) {
   sched.mtype=mtype(name);
   
   for (i=0;i<5;i++) {
     sched.messg.ip[i]=ip[i];
   }
   
   sched.messg.dad=getpid();

   if(arg==NULL)
     arg="";

   n=strlen(arg)+1;
   n = n > MAX_BUF + 1 ? MAX_BUF + 1: n;
   strncpy(sched.messg.arg,arg,n);
   if(n == MAX_BUF+1)
     sched.messg.arg[n-1]=0;

 waits:
   status = msgsnd(msqid, (struct msgbuf *) &sched,
		   sizeof(sched.messg)+strlen(sched.messg.arg)+1-
		   sizeof(sched.messg.arg), 0 );

   if (status == -1) {
     if(errno == EINTR)
       goto waits;
     else {
       fprintf( stderr,"skd_run: msqid %d,",msqid);
       perror(" sending schedule message");
       exit( -1);
     }
   }
 }

if(nsem!=NULL && nsem[0]!=0)
  nsem_put(nsem);

if(w != 'w')
  return;

 if(to !=0) {
   if(signal(SIGALRM,nullfcn) == SIG_ERR){
     fprintf( stderr,"skd_run: setting up signals\n");
     exit(-1);
   }
   wait_rtype=sched.messg.rtype;
   rte_alarm( to);
 }

 waitr:
 status = msgrcv( msqid, (struct msgbuf *) &sched, sizeof(sched.messg),
		  sched.messg.rtype, 0);
 
 if(status == -1) {
   if(errno == EINTR)
     goto waitr;
   else {
     perror("skd_run: receiving return message");
     exit( -1);
   }
 }

 if (to !=0) {
   rte_alarm((unsigned) 0);
   if(signal(SIGALRM,SIG_DFL) == SIG_ERR){
     fprintf( stderr,"skd_run: setting default signals\n");
     exit(-1);
   }
   to=0;
 }

 if(run_index!=NULL)
   *run_index=sched.messg.run_index;

 for (i=0;i<5;i++)
   save_ip[i]=sched.messg.ip[i];

 return sched.messg.timed_out;
 
}
void skd_par( ip)
int ip[5];
{
int i;

for (i=0;i<5;i++)
    ip[i]=save_ip[i];

}
void skd_arg_buff(buff,len)
char *buff;
int len;
{
  /* return arg (arg_buff is a copy) as one unparsed buffer
  */

  int slen;

  if(len <= 0)   /* defensive */
    return;

  slen = strlen(arg_buff);
  slen = slen > len-1 ? len-1: slen;
  strncpy(buff,arg_buff,slen);
  buff[slen]='\0';

  return;
}
void skd_arg(n,buff,len)
char *buff;
int  n,len;
{
  /* return n-th arg from passed arg buffer
  */

  if(len <= 0)   /* defensive */
    return;

  if (argc < 0) {
    char *ptr;

    argc = 0;
    ptr = strtok(arg," ");
    while ( NULL != (argv[argc++] = ptr) ) {
      ptr = strtok(NULL," ");
    }
  }

  if (n < argc && argv[n] != NULL) {
    int slen;

    slen = strlen(argv[n]);
    slen = slen > len-1 ? len-1: slen;
    strncpy(buff,argv[n],slen);
    buff[slen]='\0';
  } else
    buff[0]='\0';

}

int skd_chk( name, ip)
char    name[ 5];
int	ip[5];
{
int	status,i;
struct skd_buf	sched;
int    type;
char *s1;


skd_end(ip);

type=mtype(name);
s1=memcpy(prog_name,name,5);

waitr:
status = msgrcv( msqid, (struct msgbuf *) &sched, sizeof( sched.messg),
		type, IPC_NOWAIT);

if(status == -1) {
  if(errno == EINTR)
    goto waitr;
  else if (errno == ENOMSG)
    return 0;
  else {
    perror("skd_chk: receiving message");
    exit( -1);
  }
}

for (i=0;i<5;i++)
    ip[i]=sched.messg.ip[i];

rtype=sched.messg.rtype;

if (getpid() == sched.messg.dad)
  dad=0;
else
  dad=sched.messg.dad;

strcpy(arg,sched.messg.arg);
argc=-1;
strcpy(arg_buff,arg);

 run_index=sched.messg.run_index;

return 1;
}
int skd_end_inject_snap( name, ip)
char    name[ 5];
int	ip[5];
{
int	status,i;
struct skd_buf	sched;
int    type;
char *s1;

 if(strncmp("boss ",name,5)==0) {
   type=mtype("bossx");

 waitrx:
   status = msgrcv( msqid, (struct msgbuf *) &sched, sizeof( sched.messg),
		type, IPC_NOWAIT);

   if(status == -1) {
     if(errno == EINTR)
       goto waitrx;
     else if (errno == ENOMSG) {
       goto next;
     } else {
       perror("skd_end_inject_snap: receiving message 1");
       exit( -1);
     }
   }

   goto process;
 }

 next:
type=mtype(name);
s1=memcpy(prog_name,name,5);

waitr:
status = msgrcv( msqid, (struct msgbuf *) &sched, sizeof( sched.messg),
		type, IPC_NOWAIT);

if(status == -1) {
  if(errno == EINTR)
    goto waitr;
  else if (errno == ENOMSG)
    return -1;
  else {
    perror("skd_end_inject_snap: receiving message 2");
    exit( -1);
  }
}

 process:
if(sched.messg.rtype == 0)
  goto waitr;

rtype=sched.messg.rtype;

if (getpid() == sched.messg.dad)
  dad=0;
else
  dad=sched.messg.dad;

strcpy(arg,sched.messg.arg);
argc=-1;
strcpy(arg_buff,arg);

  run_index=sched.messg.run_index;

  skd_end(ip);

  return 0;

}

void skd_wait( name, ip, centisec)
char    name[ 5];
unsigned centisec;
int	ip[5];
{
int	status,i;
struct skd_buf	sched;
int    type;
char *s1;


skd_end(ip);

type=mtype(name);
s1=memcpy(prog_name,name,5);

if(centisec !=0) {
  if(signal(SIGALRM,nullfcn) == SIG_ERR){
     fprintf( stderr,"skd_wait: setting up signals\n");
     exit(-1);
  }
  rte_alarm( centisec);
}

waitr:
status = msgrcv( msqid, (struct msgbuf *) &sched, sizeof( sched.messg),
		type, 0);

if (centisec !=0) {
   rte_alarm((unsigned) 0);
   if(signal(SIGALRM,SIG_DFL) == SIG_ERR){
     fprintf( stderr,"skd_wait: setting default signals\n");
     exit(-1);
   }
  centisec=0;
}

if (status == -1) {
  if(errno == EINTR)
    goto waitr;
  else {
    perror("skd_wait: receiving message");
    exit( -1);
  }
}

 if(strncmp("boss ",name,5)==0 &&sched.messg.rtype!=0) {
   sched.mtype=mtype("bossx");
 waits:
   status = msgsnd(msqid, (struct msgbuf *) &sched,
		   sizeof(sched.messg)+strlen(sched.messg.arg)+1-
		   sizeof(sched.messg.arg), 0 );
   
   if (status == -1) {
     if(errno == EINTR)
       goto waits;
     else {
       fprintf( stderr,"skd_run: msqid %d,",msqid);
       perror(" sending schedule message");
       exit( -1);
     }
   }
   sched.messg.rtype=0;
 }
   
for (i=0;i<5;i++)
    ip[i]=sched.messg.ip[i];

rtype=sched.messg.rtype;

if (getpid() == sched.messg.dad)
  dad=0;
else
  dad=sched.messg.dad;

strcpy(arg,sched.messg.arg);
argc=-1;
strcpy(arg_buff,arg);

 run_index=sched.messg.run_index;
}

void skd_end(ip)
int ip[5];
{
  skd_end_to(ip,&rtype,0,run_index);
}

static void skd_end_to(ip,rtype_in,timed_out,run_index)
int ip[5];
int *rtype_in;
int timed_out;
int run_index;
{
  int i, status;
  struct skd_buf sched;

  if( *rtype_in != 0) {
    for (i=0;i<5;i++) {
      sched.messg.ip[i]=ip[i];
    }
    sched.messg.timed_out=timed_out;
    sched.mtype=*rtype_in;
    sched.messg.run_index=run_index;
    sched.messg.arg[0]=0;
  waits:
    status = msgsnd( msqid, (struct msgbuf *) &sched,
		   sizeof(sched.messg)+strlen(sched.messg.arg)+1-
		   sizeof(sched.messg.arg), 0 );
    if (status == -1) {
      if(errno == EINTR)
	goto waits;
      else {
	perror("skd_end_to: sending termination message");
	exit( -1);
      }
    }
    *rtype_in = 0;
  }
}
void skd_clr( name)
char    name[ 5];
{
int	status;
struct skd_buf	sched;
int    type;
char *s1;

type=mtype(name);

waitr:
status = msgrcv( msqid, (struct msgbuf *) &sched, sizeof( sched.messg),
		type, IPC_NOWAIT);

if(status!=-1)
  goto waitr;
else if(errno == EINTR)
  goto waitr;
else if (errno != ENOMSG) {
  perror("skd_clr: receiving message");
  exit( -1);
}
}

int skd_rel( )
{
int status;
/* release specified shared memory segment */
if(-1==msgctl( msqid, IPC_RMID, 0 )) {
   perror("skd_rel: releasing skd id");
   return( -1);
}
return( 0);
}

/*
  mtype is a bijection to integers from strings of length 5 consiting
  of characters in [A-Za-z0-9] and ignoring case. Character in the string
  that are outside this set, including space, are ignored.

  It can be used as a replacement for a hash function when a collision
  cannot be handled easily. Largest number produced is (36^6-1)/(36-1)-1 =
  62193780

  Mapping is as follows:

       "": 0
      "a": 1
      "b": 2
        ...
      "9": 36
     "aa": 37
     "ab": 38
        ...
     "a9": 72
        ...
     "99": 1332
    "aaa": 1333
    "999": 47988
        ...
  "99999": 62193780

*/

static int mtype(char name[5]) {
	/*
      The algorithm treats the string as base b numbers. However, we can simply
      do this as, for eg, "aa" would then be treated as the same as "a". We
      instead list all numbers of a fixed length together, and calculate the
      offset based on how many strings came before this group.

	  If b == number of character, then there are

      -   b^0 strings of length 0
      -   b^1 strings of length 1
      -   b^2 strings of length 2
      -   et c.

      so

	     offset = 1 + base + base^2 + ... base^(i-1)

      For example, "aab" would represent 1 in base 36 as listed below, and there
      are 1 + 36 + 36^2 = 1333 strings of length less than 3, so it is mapped to
      1333 + 1 = 1334

      The number in base b and the offset are evaluated with Horner's scheme.

	 */
	int val    = 0;
	int offset = 0;
	int i;
	char *ptr;
	char symbols[] = "abcdefghijklmnopqrstuvwxyz0123456789";
	size_t base    = strlen(symbols);

	for (i = 0; i < 5; i++) {
		if (name[i] == '\0')
			break;

		ptr = strchr(symbols, tolower(name[i]));
		if (ptr == NULL)
			continue;

		val    = base * val + (ptr - symbols);
		offset = base * offset + 1;
	}

	return (val + offset);
}

//  skd_set_return_name sets return field of skd to that of the "name"
//  rather than PID.
void skd_set_return_name(char *name) {
	// TODO: check valid name?
    memcpy(return_name, name, sizeof(return_name));
}

// skd_clr_ret clears all elements of the skd queue with named return
// values set to the value specified with `skd_set_return_name`.
int skd_clr_ret(ip)
     int ip[5];
{
  struct skd_buf sched;
  int status, i;
  
  if (!return_name[0]) {
    fprintf(stderr, "skd_clr_ret: called without return_name set\n");
    exit(EXIT_FAILURE);
  }
  
  int rtype = FS_SKD_WAIT | FS_SKD_NAMED | mtype(return_name);
  
 waitr:
  status = msgrcv(msqid, (struct msgbuf *)&sched,
		      sizeof(sched.messg), rtype, IPC_NOWAIT);
  
  if (status < 0)
    if(errno == EINTR)
      goto waitr;
    else if (errno == ENOMSG)
      return 0;
    else {
      // Unknown error
      perror("skd_clr_ret: receiving message");
      exit(EXIT_FAILURE);
    }
  // goto it, return ip array
  for (i=0;i<5;i++)
    ip[i]=sched.messg.ip[i];
  return 1;
}


static void nullfcn(sig)
int sig;
{
    int i;
    void skd_run();

    if(signal(sig,SIG_IGN) == SIG_ERR ) {
      perror("nullfcn: error ignoring signal");
      exit(-1);
    }

    if(wait_rtype==0)
      skd_run(prog_name,'n',ipr);
    else
      skd_end_to(ipr,&wait_rtype,1,run_index);

    return;
}
int dad_pid()
{
return(dad);
}
