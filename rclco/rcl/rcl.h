/*
 * rcl.h
 *
 * Copyright (c)1992 by ISTS Space Geodynamics Laboratory.
 * Written by Georg Feil.
 * Redistribution and use in source and binary forms is allowed provided
 * that prior permission is obtained and this copyright notice is not removed.
 */

#ifndef RCL_DEFD
#define RCL_DEFD

/* System-independent constant (macro) and type definitions for the Recorder
     Control Link (RCL). Always update the protocol document rcl_prot.txt
     when making changes to this file. */


#define RCL_PKT_MAX        2054       /* largest allowed packet, not including
                                           SOT and EOT, before adding fudge
                                           factor. This is an artificial limit
                                           based on reasonable transfer times
                                           and buffer sizes. The actual hard 
                                           limit is 65023 characters. */
#define RCL_PKT_MIN        7          /* smallest allowed packet, not including
                                           SOT and EOT, before adding fudge
                                           factor */
#define RCL_PKT_FUDGE      505        /* fudge factor added to the packet length
                                           field. This is to ensure that the
                                           MSB never matches SOT (0x01). */

#define RCL_ERRCODE_MAX   -127        /* most negative numeric error code */
#define RCL_STATCODE_MAX   127        /* maximum possible numeric status code
                                           in RCL_RESP_STATUS, 
                                           RCL_RESP_STATUS_DETAIL, and
                                           RCL_CMD_STATUS_DECODE packets. */
#define RCL_STATUS_MAX     32         /* maximum number of status entries to
                                           report in RCL_RESP_STATUS and
                                           RCL_RESP_STATUS_DETAIL packets */
#define RCL_STATUS_DETAIL_MAXLEN 2000 /* maximum length of data portion of
                                           RESP_STATUS_DETAIL packet.
                                           Should be less than RCL_PKT_MAX. */
#define RCL_TAPEINFO_LEN   416        /* exact length of data portion of
                                           RCL_RESP_TAPEINFO packet */ 

#define RCL_STATBIT_ERROR  0x01       /* bit mask for error flag in status 
                                           type code & summary byte */
#define RCL_STATBIT_FATAL  0x02       /* bit mask for fatal flag in status 
                                           type code & summary byte */
#define RCL_STATBIT_CLEAR  0x04       /* bit mask for clear-on-read flag in
                                           status type code & summary byte */

#define RCL_SOT            0x01       /* start-of-transmission character,
                                           marks beginning of packet */
#define RCL_EOT            0x04       /* end-of-transmission character,
                                           marks end of packet */

#define RCL_ADDR_BROADCAST 0xFF       /* broadcast address, all RCL slave
                                           devices respond */
#define RCL_ADDR_MASTER    0xFE       /* master's address (external computer) */

#define RCL_POS_UNKNOWN (-0x80000000L)/* "unknown" tape position, should 
                                           match TCP_POS_UNKNOWN in tcp.h */
#define RCL_POS_UNSEL   (0x7FFFFFFFL) /* position filler value for unselected
                                           transports */
#define RCL_POS_MAX        43199      /* maximum position value in seconds,
                                           one second less than 12 hours */


/* Command codes. Commands are numbered in the range 0 to 99 decimal. They
     are always sent from the RCL master (e.g. control computer) to an RCL
     slave device (e.g. S2 recorder). */

#define RCL_CMD_STOP                     0
#define RCL_CMD_PLAY                     1
#define RCL_CMD_RECORD                   2
#define RCL_CMD_REWIND                   3
#define RCL_CMD_FF                       4
#define RCL_CMD_PAUSE                    5
#define RCL_CMD_UNPAUSE                  6
#define RCL_CMD_EJECT                    7
#define RCL_CMD_STATE_READ               8
#define RCL_CMD_SPEED_SET                9
#define RCL_CMD_SPEED_READ              10
#define RCL_CMD_SPEED_READ_PB           11
#define RCL_CMD_TIME_SET                12
#define RCL_CMD_TIME_READ               13
#define RCL_CMD_TIME_READ_PB            14
#define RCL_CMD_MODE_SET                15
#define RCL_CMD_MODE_READ               16
#define RCL_CMD_TAPEID_SET              17
#define RCL_CMD_TAPEID_READ             18
#define RCL_CMD_TAPEID_READ_PB          19
#define RCL_CMD_USER_INFO_SET           20
#define RCL_CMD_USER_INFO_READ          21
#define RCL_CMD_USER_INFO_READ_PB       22
#define RCL_CMD_USER_DV_SET             23
#define RCL_CMD_USER_DV_READ            24
#define RCL_CMD_USER_DV_READ_PB         25
#define RCL_CMD_GROUP_SET               26
#define RCL_CMD_GROUP_READ              27
#define RCL_CMD_TAPEINFO_READ_PB        28
#define RCL_CMD_DELAY_SET               29
#define RCL_CMD_DELAY_READ              30
#define RCL_CMD_DELAYM_READ             31
#define RCL_CMD_ALIGN                   34
#define RCL_CMD_POSITION_SET            35
#define RCL_CMD_POSITION_READ           36
#define RCL_CMD_ERRMES                  37
#define RCL_CMD_ESTERR_READ             38
#define RCL_CMD_PDV_READ                39
#define RCL_CMD_SCPLL_MODE_SET          42
#define RCL_CMD_SCPLL_MODE_READ         43
#define RCL_CMD_TAPETYPE_SET            44
#define RCL_CMD_TAPETYPE_READ           45
#define RCL_CMD_MK3_FORM_SET            50   /** not implemented, use CONSOLECMD **/
#define RCL_CMD_MK3_FORM_READ           51   /** not implemented **/
#define RCL_CMD_TRANSPORT_TIMES         55   /** not implemented **/
#define RCL_CMD_STATION_INFO_READ       60
#define RCL_CMD_CONSOLECMD              70
#define RCL_CMD_POSTIME_READ            71  /*for positioning diagnostics only*/
#define RCL_CMD_STATUS                  80
#define RCL_CMD_STATUS_DETAIL           81
#define RCL_CMD_STATUS_DECODE           82
#define RCL_CMD_ERROR_DECODE            83
#define RCL_CMD_DIAG                    90   /** not implemented **/
#define RCL_CMD_IDENT                   97   /** not implemented **/
#define RCL_CMD_PING                    98
#define RCL_CMD_VERSION                 99


/* Response codes. Responses are numbered from 100 to 199 decimal, and are
     usually derived by adding 100 to the request command code. */

#define RCL_RESP_ERR                    100
#define RCL_RESP_STATE                  108
#define RCL_RESP_SPEED                  110
#define RCL_RESP_TIME                   113
#define RCL_RESP_MODE                   116
#define RCL_RESP_TAPEID                 118
#define RCL_RESP_USER_INFO              121
#define RCL_RESP_USER_DV                124
#define RCL_RESP_GROUP                  127
#define RCL_RESP_TAPEINFO               128
#define RCL_RESP_DELAY                  130
#define RCL_RESP_POSITION               136
#define RCL_RESP_ESTERR                 138
#define RCL_RESP_PDV                    139
#define RCL_RESP_SCPLL_MODE             143
#define RCL_RESP_TAPETYPE               145
#define RCL_RESP_MK3_FORM               151
#define RCL_RESP_TRANSPORT_TIMES        155
#define RCL_RESP_STATION_INFO           160
#define RCL_RESP_POSTIME                171 /*for positioning diagnostics only*/
#define RCL_RESP_STATUS                 180
#define RCL_RESP_STATUS_DETAIL          181
#define RCL_RESP_STATUS_DECODE          182
#define RCL_RESP_ERROR_DECODE           183
#define RCL_RESP_IDENT                  197
#define RCL_RESP_VERSION                199


/* Recorder state codes, as obtained from rcl_state_read(). Must match
     definitions RSTATE_* in rstate.h of ROS. */

#define RCL_RSTATE_PLAY        1
#define RCL_RSTATE_RECORD      2
#define RCL_RSTATE_REWIND      3
#define RCL_RSTATE_FF          4
#define RCL_RSTATE_STOP        5
#define RCL_RSTATE_PPAUSE      6
#define RCL_RSTATE_RPAUSE      7
#define RCL_RSTATE_CUE         8
#define RCL_RSTATE_REVIEW      9
#define RCL_RSTATE_NOTAPE     10
#define RCL_RSTATE_POSITION   11


/* Tape speed codes, for rcl_speed_set(), rcl_speed_read(), and
     rcl_speed_read_pb(). Must match TCP_SPEED_* definitions in tcp.h of ROS. */

#define RCL_SPEED_UNKNOWN  -1     /* speed of transports is inconsistent or
                                       unknown (playback only) */
#define RCL_SPEED_SP        0     /* short play (not used for recording!) */
#define RCL_SPEED_LP        1     /* long play */
#define RCL_SPEED_SLP       2     /* super-long play */


/* System-clock PLL mode codes, for rcl_scpll_set() and rcl_scpll_read().
     Must match definitions SCPLL_MODE_* in scpll.h of ROS. */

#define RCL_SCPLL_MODE_XTAL   0       /* SC PLL locked by hardware to on-board
                                           32 MHz crystal) */
#define RCL_SCPLL_MODE_MANUAL 1       /* manual mode (VCO freq set manually) */
#define RCL_SCPLL_MODE_REFCLK 2       /* SC PLL locked by hardware to external
                                           high-rate reference clock */
#define RCL_SCPLL_MODE_1HZ    3       /* SC PLL locked by software to external
                                           1 Hz sync */
#define RCL_SCPLL_MODE_ERRMES 4       /* SC PLL locked by software to external
                                           error measurement, communicated
                                           using RCL 'errmes' command */


/* String length limits for packets which contain string data (includes
     terminating NULL). */

#define RCL_MAXSTRLEN_MODE               21
#define RCL_MAXSTRLEN_TAPEID             21    /* must == AUX_TAPEID_L+1 */
#define RCL_MAXSTRLEN_USER_INFO          49    /* must == AUX_MAX_USR+1 */
#define RCL_MAXSTRLEN_ESTERR             12    /* up to 8 of these, tot 96 */
#define RCL_MAXSTRLEN_PDV                12    /* up to 8 of these, tot 96 */
#define RCL_MAXSTRLEN_TAPETYPE            7
#define RCL_MAXSTRLEN_NICKNAME            9    /* must == MAX_NICKNAME_LEN+1 */
#define RCL_MAXSTRLEN_CONSOLECMD        256
#define RCL_MAXSTRLEN_ERROR_DECODE      101
#define RCL_MAXSTRLEN_STATUS_DECODE     400    /* must == STAT_MAX_LEN */
#define RCL_MAXSTRLEN_VERSION            61

#endif /* not RCL_DEFD */
