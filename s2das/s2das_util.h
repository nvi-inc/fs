#ifndef _S2_UTIL
#define _S2_UTIL

/* --------------------------------------------------------------------------*/
#define MAX_OUT_BUF 90

#define DAS  "da"
#define EDAS "DA"
#define QDAS "DQ"

#define ERR_NONE 0

void ini2_output( int *ip, char *buffer , char *title );
void add_output(  int *ip, char *buffer, char *title, char *new );
void end_output(  int *ip, char *buffer );

void s2err( int err , int *ip , char *code );

int valids2detector( char *name );
void check_s2dev__( char *dev , int *ierr );
void get_s2_tpi__( char *dev , double *tpi , int *ierr );


char *agc2str( int code );
int   str2agc( char *string , char *code );

char *attn2str( char attn );
int   str2attn( char *string , char *attn , char *old );

char *bw2str( char code , char *buffer );
int   str2bw( char *string , char *code );

char *encode2str( int code );
int   str2encode( char *string , char *code );

char *ifsrc2str( int code );
int   str2ifsrc( char *string , char *code , char *src );

char *lock2str( int code );

char *lofreq2str( unsigned int lofreq );
int   str2lofreq( char *string , unsigned int *lofreq );

char *src2str( int code );
int   str2src( char *string , char *code );

char *tpiavg2str( unsigned short avg );
int   str2tpiavg( char *string , unsigned short *avg );

int   str2bbc( char *string , char *bbc );
int   str2state( char *string , char *state );
int   str2tone( char *string , char *bbc );
int str2period( char *string , unsigned short *period );


/* --------------------------------------------------------------------------*/
#endif
