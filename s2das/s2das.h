#ifndef _S2DAS
#define _S2DAS

/* --------------------------------------------------------------------------*/

typedef struct s2_status_info
       {
        char code;
        char type;
        char report[400];
       } S2_STATUS;

#ifdef MAX_ARGS
char *arg_next( struct cmd_ds *command, int *last );
#endif

/* --------------------------------------------------------------------------*/

int bbc_set( char *s2dev, char index, unsigned long lofreq, char ifsrc
           , char *bw, unsigned short tpiavg, char agcctl );
int bbc_read( char *s2dev, char index, char *state, unsigned long *lofreq
            , char *ifsrc, char *bw, unsigned short *tpiavg, char *agcmode
            , short *gain, char *lolock, char *agclock, unsigned long *tpi );
int ifx_set( char *s2dev, char *attn , char *src , unsigned short tpiavg );
int ifx_read( char *s2dev, char *state, char *attn, char *src
            , unsigned short *tpiavg , unsigned long *tpi );
int encode_set( char *s2dev, char scheme );
int encode_read( char *s2dev, char *scheme );
int agc_set( char *s2dev, char mode );
int agc_read( char *s2dev, char *mode );
int powermon_read( char *s2dev, char module , unsigned short *voltage );
int time_set( char *s2dev, int year, int day, int hour, int min , int sec );
int time_read( char *s2dev, int *year, int *day, int *hour, int *min
             , int *sec , char *validated );
int mode_set( char *s2dev, char *mode , char setbw );
int mode_read( char *s2dev, char *mode );
int fs_read( char *s2dev, char *status, char *curstate, char *numstates
           , unsigned short *period , char *name );
int fs_start( char *s2dev, char *name );
int fs_stop( char *s2dev );
int fs_halt( char *s2dev );
int fs_state( char *s2dev , char state , char copyflag );
int fs_load( char *s2dev, char *name );
int fs_save( char *s2dev, char *name );
int fs_init( char *s2dev, char numstates , unsigned short period );
int source_set( char *s2dev, char *name , char *ra , char *dec , char *epoch );
int source_read( char *s2dev, char *name, char *ra, char *dec, char *epoch );
int delay_set( char *s2dev, char setting , long delay );
int delay_read( char *s2dev, char type , long *delay );
int tonedet_set( char *s2dev, unsigned long *freq, char *sb
               , unsigned short avep );
int tonedet_read( char *s2dev, unsigned long *freq, char *sb
                , unsigned short *avep);
int tonedet_meas( char *s2dev, char bbc, char state, unsigned long *amplitude
                , long *phase, char *timestamp );
int tpi_read( char *s2dev, char state, unsigned short tpiavg, char type
            , char *input , char *swt , unsigned long *tpi );
int station_info_read( char *s2dev, char *nbr , unsigned short *serial
                   , char *nickname , char *wlon , char *lat , char *height );
int status_read( char *s2dev, char id, char type, char reread, char *summary
               , char *nbr, S2_STATUS *list );
int status_decode( char *s2dev, char code , char type , char *message );
int error_decode( char *s2dev, char code , char *message );
int diag( char *s2dev, char selftest );
int ident( char *s2dev, char *type );
int ping( char *s2dev );
int version( char *s2dev, char *sw );

/* --------------------------------------------------------------------------*/

#define BBC_BAD_STATE        -1
#define BBC_BAD_LOFREQ       -2
#define BBC_BAD_IFSRC        -3
#define BBC_BAD_BW           -4
#define BBC_BAD_TPIAVG       -5
#define BBC_BAD_AGCMODE      -6

#define IFX_BAD_STATE       -10
#define IFX_BAD_ATTN        -11
#define IFX_BAD_SRC         -12
#define IFX_BAD_TPIAVG      -13      

#define ENCODE_BAD_SCHEME   -20
#define AGC_BAD_MODE        -21
#define PWR_BAD_VALUE       -22
#define MODE_BAD_VALUE      -23
#define STATUS_BAD_PARAM    -24
#define MSG_BAD_PARAM       -25

#define FS_BAD_OPTION       -30
#define FS_BAD_NUM_STATES   -31
#define FS_BAD_PERIOD       -32
#define FS_BAD_STATE        -33
#define FS_BAD_BBC          -34
#define FS_BAD_LOFREQ       -35
#define FS_BAD_IFSRC        -36

#define INFO_BAD_PARM       -40
#define DIAG_BAD_PARM       -41

#define DELAY_BAD_PARM      -45

#define TONE_MEAS_PARM      -50
#define TONE_MEAS_BAD_BBC   -51
#define TONE_MEAS_BAD_STATE -52
#define TONE_DIFF_PARM      -53
#define TONE_DIFF_BBC       -54
#define TONE_DIFF_TONE      -55
#define TONE_STAT_PARM      -56

#define TPI_BAD_DETECTOR    -60
#define TSYS_BAD_DETECTOR   -61

#define PING_BAD_PARM       -70

#endif
/* --------------------------------------------------------------------------*/








