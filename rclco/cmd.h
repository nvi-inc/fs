#ifndef CMD_DEFD
#define CMD_DEFD

#include "ext_init.h"

/* Parameter delimiters */
#define PARM_DELIM        " ,"
#define PARM_DELIM_PLUS   " ,+-"
#define COMMENT_DELIM     '#'

typedef struct {                /* type of entry in a command list */
   char* name;
   char* syntax;
   int num;
} cmd_t;

#include "softkey.h"            /* must follow 'cmd_t' type def */

enum cmd_codes { CMD_PING, CMD_STOP, CMD_PLAY, CMD_RECORD, CMD_REWIND,
                 CMD_FF, CMD_PAUSE, CMD_UNPAUSE, CMD_EJECT, CMD_STATE_READ,
                 CMD_SPEED_SET, CMD_SPEED_READ, CMD_SPEED_READ_PB,
                 CMD_TIME_SET, CMD_TIME_READ, CMD_TIME_READ_PB,
                 CMD_MODE_SET, CMD_MODE_READ,
                 CMD_TAPEID_SET, CMD_TAPEID_READ, CMD_TAPEID_READ_PB,
                 CMD_USER_INFO_SET, CMD_USER_INFO_READ, CMD_USER_INFO_READ_PB,
                 CMD_USER_DV_SET, CMD_USER_DV_READ, CMD_USER_DV_READ_PB,
                 CMD_GROUP_SET, CMD_GROUP_READ, CMD_TAPEINFO_READ_PB,
                 CMD_DELAY_SET, CMD_DELAY_READ, CMD_DELAYM_READ, 
                 CMD_BARRELROLL_SET, CMD_BARRELROLL_READ, CMD_ERRMES,
                 CMD_ALIGN, CMD_POSITION_SET, CMD_POSITION_READ,
                 CMD_ESTERR_READ, CMD_PDV_READ,
                 CMD_SCPLL_MODE_SET, CMD_SCPLL_MODE_READ, 
                 CMD_TAPETYPE_SET, CMD_TAPETYPE_READ, 
                 CMD_MK3_FORM_SET, CMD_MK3_FORM_READ, CMD_TRANSPORT_TIMES,
                 CMD_STATION_INFO_READ,
                 CMD_CONSOLECMD, CMD_POSTIME_READ,
                 CMD_STATUS, CMD_STATUS_DETAIL, CMD_STATUS_DECODE,
                 CMD_ERROR_DECODE, CMD_DIAG, CMD_BERDCB, CMD_IDENT, CMD_VERSION,
                 CMD_ADDR, CMD_BAUD, CMD_PORT, 
                 CMD_OPEN, CMD_CLOSE, 
                 CMD_DEBUG, CMD_VERSIONL, CMD_HELP, CMD_END};

/* The following array of strings gives the syntax descriptions (user and
   machine) and code numbers of RCLCO commands. Commands take the form of a 
   word followed by parameters. */

EXTERN cmd_t Commands[]
#ifdef MAIN
= {
   {"help [CMD|all]  -- Obtain help on one or all commands",
    "help [STR<cmd>|all]",
        CMD_HELP},
   {"ping            -- Dummy command to test if S2 is alive",
    "ping",
        CMD_PING},
   {"stop            -- Stop the transports and/or associated system operation",
    "stop",
        CMD_STOP},
   {"play            -- Start playback (use 'status' to monitor progress)",
    "play",
        CMD_PLAY},
   {"record          -- Start recording (use 'status' to monitor progress)",
    "record",
        CMD_RECORD},
   {"rewind          -- Rewind tapes (use 'state_read' to test completion)",
    "rewind",
        CMD_REWIND},
   {"ff              -- Fast-forward tapes (use 'state_read' to test completion)",
    "ff",
        CMD_FF},
   {"pause           -- Temporarily pause recording or playback",
    "pause",
        CMD_PAUSE},
   {"unpause         -- Resume recording or playback after pause",
    "unpause",
        CMD_UNPAUSE},
   {"eject           -- Eject tapes",
    "eject",
        CMD_EJECT},
   {"state_read      -- Read current recorder state (stop, record, play, etc.)",
    "state_read",
        CMD_STATE_READ},
   {"speed_set {lp|slp}  -- Set the record tape speed",
    "speed_set {lp|slp}",
        CMD_SPEED_SET},
   {"speed_read      -- Read the record tape speed",
    "speed_read",
        CMD_SPEED_READ},
   {"speed_read_pb   -- Read the playback tape speed",
    "speed_read_pb",
        CMD_SPEED_READ_PB},
   {"time_set YYYY DDD-HH:MM:SS  -- Set the S2 system time (recorded on tape)",
    "time_set NNNN<year> NNN<day>-NN<hour>:NN<min>:NN<sec>",
        CMD_TIME_SET},
   {"time_read       -- Read the S2 system time",
    "time_read",
        CMD_TIME_READ},
   {"time_read_pb    -- Read the S2 playback tape time",
    "time_read_pb",
        CMD_TIME_READ_PB},
   {"mode_set MODE   -- Set the S2 recorder mode",
    "mode_set {32x4-1|32x4-2|32x2-1|32x2-2|32x1-1|16x8-1|16x8-2|16x4-1|16x4-2|16x2-1|16x2-2|16x1-1|8x16-1|8x16-2|8x8-1|8x8-2|8x4-1|8x4-2|8x2-1|8x2-2|4x16-1|4x16-2|4x8-1|4x8-2|4x4-1|4x4-2|16i8-1|16i4-1|16p8-2|8i8-1|8i4-1|8p8-2|4i8-1|4p8-2|II-8-1|II-8-2|I-8-1|I-8-2|IV-4-1|IV-4-2|II-4-1|II-4-2|I-4-1|I-4-2|IV-2-1|IV-2-2|II-2-1|II-2-2|I-2-2|c1test32|c1test16|c1test8|c1test4|c2test32|c2test16|c2test8|c2test4|diag32|diag16|diag8|diag4|STR<mode>}",
        CMD_MODE_SET},
   {"mode_read       -- Read the S2 recorder mode",
    "mode_read",
        CMD_MODE_READ},
   {"tapeid_set STR  -- Set the tape ID to be recorded",
    "tapeid_set STRA<text>",
        CMD_TAPEID_SET},
   {"tapeid_read     -- Read the record tape ID",
    "tapeid_read",
        CMD_TAPEID_READ},
   {"tapeid_read_pb  -- Read the playback tape ID",
    "tapeid_read_pb",
        CMD_TAPEID_READ_PB},
   {"user_info_set ...  -- Set record user-info field or label",
    "user_info_set NUM<field> [label] STRA<text>",
        CMD_USER_INFO_SET},
   {"user_info_read ...  -- Read record user-info field or label",
    "user_info_read [NUM<field> [label]]",
        CMD_USER_INFO_READ},
   {"user_info_read_pb ... -- Read playback user-info field or label",
    "user_info_read_pb [NUM<field> [label]]",
        CMD_USER_INFO_READ_PB},
   {"user_dv_set ...  -- Set the record user data-valid and playback DV-enable flags",
    "user_dv_set {true|false} {pb_enable|pb_disable}",
        CMD_USER_DV_SET},
   {"user_dv_read    -- Read the record user data-valid and playback DV-enable flags",
    "user_dv_read",
        CMD_USER_DV_READ},
   {"user_dv_read_pb  -- Read the playback user data-valid flag",
    "user_dv_read_pb",
        CMD_USER_DV_READ_PB},
   {"group_set NUM  -- Set the transport group number",
    "group_set NUM<group>",
        CMD_GROUP_SET},
   {"group_read    -- Read the current transport group number and number of groups",
    "group_read",
        CMD_GROUP_READ},
   {"tapeinfo_read_pb    -- Read tape-related info for all 8 transports",
    "tapeinfo_read_pb",
        CMD_TAPEINFO_READ_PB},
   {"delay_set NUM [relative] -- Set the station delay",
    "delay_set NUMS<ns> [relative]",
        CMD_DELAY_SET},
   {"delay_read    -- Read the current station delay setting",
    "delay_read",
        CMD_DELAY_READ},
   {"delaym_read    -- Read the current station delay measurement",
    "delaym_read",
        CMD_DELAYM_READ},
   {"barrelroll_set {on|off}  -- Turn barrel-roll on or off",
    "barrelroll_set {on|off}",
        CMD_BARRELROLL_SET},
   {"barrelroll_read    -- Read the current barrel-roll setting",
    "barrelroll_read",
        CMD_BARRELROLL_READ},
   {"errmes {NUM|auto ..}  -- Report a FIFO error measurement (SC PLL 'errmes' mode)",
    "errmes {NUMS<bits>|auto {4|8|16|32} [async] [NUMF<secs>]}",
        CMD_ERRMES},
   {"align ...  -- Playback tape alignment",
    "align {abs NNNN<year> NNN<day>-NN<hour>:NN<min>:NN<sec>[.NUM<fracsec>]|rel [+|-]NN<hour>:NN<min>:NN<sec>[.NUM<fracsec>]|realign|selfalign}",
        CMD_ALIGN},
   {"position_set ...    -- Initiate tape positioning",
    "position_set {[+|-|preset]{NUM<hours>:NN<mins>:NN<secs>|unknown} [indtest]|reestablish}",
        CMD_POSITION_SET},
   {"position_read [individual]    -- Read current tape position",
    "position_read [individual]",
        CMD_POSITION_READ},
   {"esterr_read [bychan]  -- Read the list of estimated error rates",
    "esterr_read [bychan]",
        CMD_ESTERR_READ},
   {"pdv_read [bychan]  -- Read the list of percent data valid values",
    "pdv_read [bychan]",
        CMD_PDV_READ},
   {"scpll_mode_set ...  -- Set the System Clock PLL mode",
    "scpll_mode_set {refclk|1hz|errmes|xtal|manual}",
        CMD_SCPLL_MODE_SET},
   {"scpll_mode_read     -- Read the System Clock PLL mode",
    "scpll_mode_read",
        CMD_SCPLL_MODE_READ},
   {"tapetype_set STR    -- Set the tape type",
    "tapetype_set STR<type>",
        CMD_TAPETYPE_SET},
   {"tapetype_read       -- Read the current tape type setting",
    "tapetype_read",
        CMD_TAPETYPE_READ},
   {"mk3_form_set {on|off}  -- Turn Mark-III formatter on or off",
    "mk3_form_set {on|off}",
        CMD_MK3_FORM_SET},
   {"mk3_form_read    -- Read the current Mark-III formatter enable setting",
    "mk3_form_read",
        CMD_MK3_FORM_READ},
   {"transport_times    -- Read transport head-use and service times",
    "transport_times",
        CMD_TRANSPORT_TIMES},
   {"station_info_read  -- Read the station number, S2 serial number, and nickname",
    "station_info_read",
        CMD_STATION_INFO_READ},

   {"consolecmd STR  -- Execute arbitrary console command (caution!)",
    "consolecmd STRA<cmd>",
        CMD_CONSOLECMD},

   {"postime_read NUM  -- Read a transport's playback tape time and position",
    "postime_read NUM<tran>",
        CMD_POSTIME_READ},

   {"status  -- Read S2 brief status report",
    "status",
        CMD_STATUS},
   {"status_detail ... -- Read S2 detailed status report",
    "status_detail [NUM<statcode>] [reread] [short]",
        CMD_STATUS_DETAIL},
   {"status_decode NUM   -- Decode an S2 numeric status code",
    "status_decode NUM<statcode> [short]",
        CMD_STATUS_DECODE},

   {"error_decode NUM   -- Decode an S2 numeric error return code",
    "error_decode NUMS<errcode>",
        CMD_ERROR_DECODE},

   {"diag self1        -- Run diagnostic self-test 1",
    "diag self1",
        CMD_DIAG},
   {"berdcb ...        -- Measure BER or DC-bias",
    "berdcb {formber|uiber|dcbias} NUM<chan> NUM<seconds>",
        CMD_BERDCB},

   {"ident        -- Report RCL device type",
    "ident",
        CMD_IDENT},
   {"version        -- Report ROS software version number running in S2",
    "version",
        CMD_VERSION},

#ifdef UNIX
   {"addr [NUM|broadcast]  -- Set reference address of S2 system to talk to (0-253)",
#else
   {"addr [NUM|broadcast]  -- Set RCL address of S2 system to talk to (0-253)",
#endif
    "addr [NUM|broadcast]",
        CMD_ADDR},
#ifdef DOS
   {"baud [RATE]     -- Set baud rate of local communications port",
    "baud [1200|2400|4800|9600|19200|38400|57600]",
        CMD_BAUD},
   {"port [1|2]      -- Select local communications port to use for RCL",
    "port [1|2]",
        CMD_PORT},
#endif DOS
#ifdef UNIX
   {"open [STR]       -- Open an RCL network connection, or show open connections",
    "open [STR<hostname>]",
        CMD_OPEN},
   {"close NUM       -- Close an RCL network connection",
    "close NUM<addr>",
        CMD_CLOSE},
#endif UNIX
   {"debug [0|1|2]   -- Set local debug level (higher means more output)",
    "debug [0|1|2]",
        CMD_DEBUG},
   {"versionl        -- Report local RCLCO software version number",
    "versionl",
        CMD_VERSIONL},
   {"end             -- End the RCLCO program",
    "end",
        CMD_END},
   {"quit            -- End the RCLCO program",
    "quit",
        CMD_END},
}
#endif
   ;                   /* INIT macro won't work here! */

EXTERN const int NumCmds INIT((sizeof Commands)/(sizeof (cmd_t)));

EXTERN stree_ent* CmdStree;    /* head of syntax tree */


/*
 * Command control routines
 */

int cmd_parse_init(void);

int control(char* command);

int execute(const char* command);

void printerr(int err);


#endif not CMD_DEFD
