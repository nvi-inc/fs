#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "rcl_def.h"

#include "rcl_util.h"

/*
 * Recorder Control Link utility routines, mostly for parameter display.
 */


const char* rcl_rstate_to_str(int rstate)
{
   switch (rstate)  {
   case RCL_RSTATE_PLAY  :   return("play");
   case RCL_RSTATE_RECORD:   return("record");
   case RCL_RSTATE_STOP  :   return("stop");
   case RCL_RSTATE_REWIND:   return("rewind");
   case RCL_RSTATE_FF    :   return("fast-forward");
   case RCL_RSTATE_PPAUSE:   return("play-pause");
   case RCL_RSTATE_RPAUSE:   return("record-pause");
   case RCL_RSTATE_CUE   :   return("cue");
   case RCL_RSTATE_REVIEW:   return("review");
   case RCL_RSTATE_NOTAPE:   return("no tape");
   case RCL_RSTATE_POSITION: return("positioning");
   default               :   return("illegal!?");    /* should never appear */
   }
}

const char* rcl_speed_to_str(int speed)
{
   switch (speed)  {
   case RCL_SPEED_SP     :   return("sp");
   case RCL_SPEED_LP     :   return("lp");
   case RCL_SPEED_SLP    :   return("slp");
   case RCL_SPEED_UNKNOWN:   return("unknown");
   default               :   return("illegal!?");    /* should never appear */
   }
}

const char* rcl_scpll_mode_to_str(int scpll_mode)
{
   switch (scpll_mode)  {
   case RCL_SCPLL_MODE_XTAL   :   return("xtal");
   case RCL_SCPLL_MODE_MANUAL :   return("manual");
   case RCL_SCPLL_MODE_REFCLK :   return("refclk");
   case RCL_SCPLL_MODE_1HZ    :   return("1hz");
   case RCL_SCPLL_MODE_ERRMES :   return("errmes");
   default               :   return("illegal!?");    /* should never appear */
   }
}

