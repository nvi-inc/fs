%{
#include <string.h>
#include <stdio.h>
#include <ctype.h>
#include <malloc.h>

#include "vex.h"
#include "y.tab.h"

#define  ALLOC_SIZE 32

#define NEWSTR(ptr,from)	{ if (NULL == (ptr = strdup(from)) ) { \
 					fprintf(stderr,"out of memory\n");\
					exit(1);} }

#define isodigit(x) ((x) >= '0' && (x) <= '7')
#define hextoint(x) (isdigit((x)) ? (x) - '0'\
                                  : ((x) - 'A') + 10)

static struct llist *lit();
static char *find_end(char *buffer, char *text);
static char *quote();

static int ref=0;
static trailing=0;
int lines=1;
%}

%x DOUBLE VERSION DEF LINE REF

NAME		[^ \t\n;:=&*$"]{1,32}
MANTISSA        [+-]?([0-9]+"."[0-9]+|[0-9]+|[0-9]+"."[0-9]*|[0-9]*"."[0-9]+)
EXPONENT	[eE][+-]?[0-9]+
DOUBLE		{MANTISSA}{EXPONENT}?
FREQ_UNITS	mHz|Hz|kHz|MHz|GHz
SAMPLE_RATE_UNITS	ks\/sec|Ms\/sec
TIME_UNITS      psec|nsec|usec|msec|sec|min|hr|yr
LENGTH_UNITS	um|mm|cm|m|km|in|ft
VELOCITY_UNITS 	{LENGTH_UNITS}\/{TIME_UNITS}
ANGLE_UNITS     mdeg|deg|amin|asec|rad
ANGLE_RATE_UNITS {ANGLE_UNITS}\/{TIME_UNITS}
FLUX_UNITS	mJy|Jy
WHITE		[ \t]
YEAR		([0-9][0-9]){1,2}
DOY		[0-9]{1,3}
HOUR            [0-9]{1,2}
MINUTE		[0-9]{1,2}
SEC		[0-9]{1,2}|{DOUBLE}
DATE		{YEAR}y{DOY}d({HOUR}h({MINUTE}m({SEC}s)?)?)?
TIME		{HOUR}h{MINUTE}m{SEC}s
ANGLE		[+-]?([0-9]{1,2})d([0-9]{1,2})\'{SEC}\"
%%
		{ static int version=1;if(version)BEGIN(VERSION);version=0;}

<VERSION>"*"     	{yyerror("Comment not allowed before end of VEX_REV statement\n");}
<VERSION>{DOUBLE}	{NEWSTR(yylval.sval,yytext); return T_DOUBLE;}
<VERSION>{WHITE}*		/* skip white space */
<VERSION>;              {trailing=1;BEGIN(LINE); return yytext[0];}
<VERSION>VEX_rev	{return T_VEX_REV;}
<VERSION>.		{return(yytext[0]);}

<DOUBLE>{FREQ_UNITS}	{ BEGIN(INITIAL);
			NEWSTR(yylval.sval,yytext); return T_FREQ_UNITS; }
<DOUBLE>{SAMPLE_RATE_UNITS}	{ BEGIN(INITIAL);
				NEWSTR(yylval.sval,yytext);
				return T_SAMPLE_RATE_UNITS; }
<DOUBLE>{TIME_UNITS}	{ BEGIN(INITIAL);
			NEWSTR(yylval.sval,yytext); return T_TIME_UNITS; }
<DOUBLE>{LENGTH_UNITS}	{ BEGIN(INITIAL);
			NEWSTR(yylval.sval,yytext); return T_LENGTH_UNITS; }
<DOUBLE>{VELOCITY_UNITS}	{ BEGIN(INITIAL);
			NEWSTR(yylval.sval,yytext); return T_VELOCITY_UNITS; }
<DOUBLE>{ANGLE_UNITS}	{ BEGIN(INITIAL);
			NEWSTR(yylval.sval,yytext); return T_ANGLE_UNITS; }
<DOUBLE>{ANGLE_RATE_UNITS}	{ BEGIN(INITIAL);
			NEWSTR(yylval.sval,yytext); return T_ANGLE_RATE_UNITS;}
<DOUBLE>{FLUX_UNITS}	{ BEGIN(INITIAL);
			NEWSTR(yylval.sval,yytext); return T_FLUX_UNITS; }
<DOUBLE>\n		{lines++;}
<DOUBLE>{WHITE}*	/* skip white space */
<DOUBLE>;		{trailing=1;BEGIN(LINE); return yytext[0];}
<DOUBLE>.		{BEGIN(INITIAL);return(yytext[0]);}

<DEF>\n			{lines++;}
<DEF>{WHITE}*		/* skip white space */
<DEF>;			{trailing=1;BEGIN(LINE); return yytext[0];}
<DEF>{NAME}*		{NEWSTR(yylval.sval,yytext); return T_NAME;}
<DEF>\"			{ yylval.sval=quote(); return T_NAME;}
<DEF>.			{return(yytext[0]);}

<LINE>"*"[^\n]*		{NEWSTR(yylval.sval,yytext);	 /* comment */
			if(trailing)
				return T_COMMENT_TRAILING;
			else
				return T_COMMENT;}

<LINE>"$"GLOBAL	{BEGIN(INITIAL);return B_GLOBAL;}
<LINE>"$"STATION	{BEGIN(INITIAL);return B_STATION;}
<LINE,REF>"$"EXPER	{BEGIN(INITIAL);return B_EXPER;}
<LINE,REF>"$"SCHEDULING_PARMS	{BEGIN(INITIAL);return B_SCHEDULING_PARMS;}
<LINE,REF>"$"PROC_TIMING	{BEGIN(INITIAL);return B_PROC_TIMING;}
<LINE,REF>"$"EOP		{BEGIN(INITIAL);return B_EOP;}
<LINE>"$"MODE		{BEGIN(INITIAL);return B_MODE;}
<LINE,REF>"$"FREQ		{BEGIN(INITIAL);return B_FREQ;}
<LINE,REF>"$"CLOCK	{BEGIN(INITIAL);return B_CLOCK;}
<LINE,REF>"$"ANTENNA	{BEGIN(INITIAL);return B_ANTENNA;}
<LINE,REF>"$"BBC		{BEGIN(INITIAL);return B_BBC;}
<LINE,REF>"$"CORR		{BEGIN(INITIAL);return B_CORR;}
<LINE,REF>"$"DAS		{BEGIN(INITIAL);return B_DAS;}
<LINE,REF>"$"HEAD_POS	{BEGIN(INITIAL);return B_HEAD_POS;}
<LINE,REF>"$"PASS_ORDER	{BEGIN(INITIAL);return B_PASS_ORDER;}
<LINE,REF>"$"PHASE_CAL	{BEGIN(INITIAL);return B_PHASE_CAL;}
<LINE,REF>"$"ROLL		{BEGIN(INITIAL);return B_ROLL;}
<LINE,REF>"$"IF		{BEGIN(INITIAL);return B_IF;}
<LINE,REF>"$"SEFD		{BEGIN(INITIAL);return B_SEFD;}
<LINE,REF>"$"SITE		{BEGIN(INITIAL);return B_SITE;}
<LINE,REF>"$"SOURCE	{BEGIN(INITIAL);return B_SOURCE;}
<LINE,REF>"$"TAPELOG_OBS	{BEGIN(INITIAL);return B_TAPELOG_OBS;}
<LINE,REF>"$"TRACKS	{BEGIN(INITIAL);return B_TRACKS;}
<LINE>"$"SCHED	{BEGIN(INITIAL);return B_SCHED;}

<REF,INITIAL>=		{if(ref == 1) {ref=0;BEGIN(DEF);} return(yytext[0]);}
<LINE>ref		{BEGIN(REF);ref=1;return T_REF;}
<LINE>def		{BEGIN(DEF);return T_DEF;}
<LINE>enddef		{BEGIN(INITIAL);return T_ENDDEF;}

<LINE>chan_def	{BEGIN(INITIAL);return T_CHAN_DEF;}
<LINE>sample_rate	{BEGIN(INITIAL);return T_SAMPLE_RATE;}
<LINE>bits_per_sample	{BEGIN(INITIAL);return T_BITS_PER_SAMPLE;}
<LINE>switching_cycle	{BEGIN(INITIAL);return T_SWITCHING_CYCLE;}

<LINE>start		{BEGIN(INITIAL);return T_START;}
<LINE>source		{BEGIN(INITIAL);return T_SOURCE;}
<LINE>mode		{BEGIN(INITIAL);return T_MODE;}
<LINE>station		{BEGIN(INITIAL);return T_STATION;}

<LINE>ant_diam	{BEGIN(INITIAL);return T_ANT_DIAM;}
<LINE>axis_type	{BEGIN(INITIAL);return T_AXIS_TYPE;}
<LINE>axis_offset	{BEGIN(INITIAL);return T_AXIS_OFFSET;}
<LINE>ant_motion	{BEGIN(INITIAL);return T_ANT_MOTION;}
<LINE>pointing_sector	{BEGIN(INITIAL);return T_POINTING_SECTOR;}

<LINE>BBC_assign	{BEGIN(INITIAL);return T_BBC_ASSIGN;}

<LINE>clock_early	{BEGIN(INITIAL);return T_CLOCK_EARLY;}
<LINE>clock_early_epoch	{BEGIN(INITIAL);return T_CLOCK_EARLY_EPOCH;}
<LINE>clock_rate	{BEGIN(INITIAL);return T_CLOCK_RATE;}

<LINE>record_transport	{BEGIN(INITIAL);return T_RECORD_TRANSPORT;}
<LINE>electronics_rack	{BEGIN(INITIAL);return T_ELECTRONICS_RACK;}
<LINE>number_drives		{BEGIN(INITIAL);return T_NUMBER_DRIVES;}
<LINE>headstack		{BEGIN(INITIAL);return T_HEADSTACK;}
<LINE>data_source		{BEGIN(INITIAL);return T_DATA_SOURCE;}
<LINE>record_density		{BEGIN(INITIAL);return T_RECORD_DENSITY;}
<LINE>tape_length		{BEGIN(INITIAL);return T_TAPE_LENGTH;}
<LINE>recording_system_ID	{BEGIN(INITIAL);return T_RECORDING_SYSTEM_ID;}
<LINE>tape_motion		{BEGIN(INITIAL);return T_TAPE_MOTION;}
<LINE>tape_control		{BEGIN(INITIAL);return T_TAPE_CONTROL;}

<LINE>TAI-UTC			{BEGIN(INITIAL);return T_TAI_UTC;}
<LINE>A1-TAI			{BEGIN(INITIAL);return T_A1_TAI;}
<LINE>eop_ref_epoch		{BEGIN(INITIAL);return T_EOP_REF_EPOCH;}
<LINE>num_eop_points		{BEGIN(INITIAL);return T_NUM_EOP_POINTS;}
<LINE>eop_interval		{BEGIN(INITIAL);return T_EOP_INTERVAL;}
<LINE>ut1-utc			{BEGIN(INITIAL);return T_UT1_UTC;}
<LINE>x_wobble		{BEGIN(INITIAL);return T_X_WOBBLE;}
<LINE>y_wobble		{BEGIN(INITIAL);return T_Y_WOBBLE;}

<LINE>exper_num		{BEGIN(INITIAL);return T_EXPER_NUM;}
<LINE>exper_name		{BEGIN(INITIAL);return T_EXPER_NAME;}
<LINE>exper_nominal_start	{BEGIN(INITIAL);return T_EXPER_NOMINAL_START;}
<LINE>exper_nominal_stop	{BEGIN(INITIAL);return T_EXPER_NOMINAL_STOP;}
<LINE>pi_name			{BEGIN(INITIAL);return T_PI_NAME;}
<LINE>pi_email		{BEGIN(INITIAL);return T_PI_EMAIL;}
<LINE>contact_name		{BEGIN(INITIAL);return T_CONTACT_NAME;}
<LINE>contact_email		{BEGIN(INITIAL);return T_CONTACT_EMAIL;}
<LINE>scheduler_name		{BEGIN(INITIAL);return T_SCHEDULER_NAME;}
<LINE>scheduler_email		{BEGIN(INITIAL);return T_SCHEDULER_EMAIL;}
<LINE>target_correlator	{BEGIN(INITIAL);return T_TARGET_CORRELATOR;}

<LINE>headstack_pos		{BEGIN(INITIAL);return T_HEADSTACK_POS;}

<LINE>if_def			{BEGIN(INITIAL);return T_IF_DEF;}

<LINE>pass_order		{BEGIN(INITIAL);return T_PASS_ORDER;}
<LINE>S2_group_order		{BEGIN(INITIAL);return T_S2_GROUP_ORDER;}

<LINE>pcal_freq		{BEGIN(INITIAL);return T_PCAL_FREQ;}

<LINE>tape_change		{BEGIN(INITIAL);return T_TAPE_CHANGE;}
<LINE>headstk_motion		{BEGIN(INITIAL);return T_HEADSTK_MOTION;}
<LINE>new_source_command	{BEGIN(INITIAL);return T_NEW_SOURCE_COMMAND;}
<LINE>new_tape_setup		{BEGIN(INITIAL);return T_NEW_TAPE_SETUP;}
<LINE>setup_always		{BEGIN(INITIAL);return T_SETUP_ALWAYS;}
<LINE>parity_check		{BEGIN(INITIAL);return T_PARITY_CHECK;}
<LINE>tape_prepass		{BEGIN(INITIAL);return T_TAPE_PREPASS;}
<LINE>preob_cal		{BEGIN(INITIAL);return T_PREOB_CAL;}
<LINE>midob_cal		{BEGIN(INITIAL);return T_MIDOB_CAL;}
<LINE>postob_cal		{BEGIN(INITIAL);return T_POSTOB_CAL;}

<LINE>reinit_period		{BEGIN(INITIAL);return T_REINIT_PERIOD;}
<LINE>inc_period		{BEGIN(INITIAL);return T_INC_PERIOD;}
<LINE>roll			{BEGIN(INITIAL);return T_ROLL;}

<LINE>sefd_model		{BEGIN(INITIAL);return T_SEFD_MODEL;}
<LINE>sefd			{BEGIN(INITIAL);return T_SEFD;}

<LINE>site_type		{BEGIN(INITIAL);return T_SITE_TYPE;}
<LINE>site_name		{BEGIN(INITIAL);return T_SITE_NAME;}
<LINE>site_ID			{BEGIN(INITIAL);return T_SITE_ID;}
<LINE>site_position		{BEGIN(INITIAL);return T_SITE_POSITION;}
<LINE>horizon_map_az		{BEGIN(INITIAL);return T_HORIZON_MAP_AZ;}
<LINE>horizon_map_el		{BEGIN(INITIAL);return T_HORIZON_MAP_EL;}
<LINE>zen_atmos		{BEGIN(INITIAL);return T_ZEN_ATMOS;}
<LINE>ocean_load_vert		{BEGIN(INITIAL);return T_OCEAN_LOAD_VERT;}
<LINE>ocean_load_horiz	{BEGIN(INITIAL);return T_OCEAN_LOAD_HORIZ;}
<LINE>occupation_code		{BEGIN(INITIAL);return T_OCCUPATION_CODE;}
<LINE>inclination		{BEGIN(INITIAL);return T_INCLINATION;}
<LINE>eccentricity		{BEGIN(INITIAL);return T_ECCENTRICITY;}
<LINE>arg_perigee		{BEGIN(INITIAL);return T_ARG_PERIGEE;}
<LINE>ascending_node		{BEGIN(INITIAL);return T_ASCENDING_NODE;}
<LINE>mean_anomaly		{BEGIN(INITIAL);return T_MEAN_ANOMALY;}
<LINE>semi-major_axis		{BEGIN(INITIAL);return T_SEMI_MAJOR_AXIS;}
<LINE>mean_motion		{BEGIN(INITIAL);return T_MEAN_MOTION;}
<LINE>orbit_epoch		{BEGIN(INITIAL);return T_ORBIT_EPOCH;}

<LINE>source_type		{BEGIN(INITIAL);return T_SOURCE_TYPE;}
<LINE>source_name		{BEGIN(INITIAL);return T_SOURCE_NAME;}
<LINE>IAU_name		{BEGIN(INITIAL);return T_IAU_NAME;}
<LINE>ra			{BEGIN(INITIAL);return T_RA;}
<LINE>dec			{BEGIN(INITIAL);return T_DEC;}
<LINE>epoch			{BEGIN(INITIAL);return T_EPOCH;}
<LINE>source_pos_ref		{BEGIN(INITIAL);return T_SOURCE_POS_REF;}
<LINE>ra_rate			{BEGIN(INITIAL);return T_RA_RATE;}
<LINE>dec_rate		{BEGIN(INITIAL);return T_DEC_RATE;}
<LINE>velocity_wrt_LSR	{BEGIN(INITIAL);return T_VELOCITY_WRT_LSR;}
<LINE>source_model		{BEGIN(INITIAL);return T_SOURCE_MODEL;}

<LINE>VSN			{BEGIN(INITIAL);return T_VSN;}

<LINE>fanin_def		{BEGIN(INITIAL);return T_FANIN_DEF;}
<LINE>fanout_def		{BEGIN(INITIAL);return T_FANOUT_DEF;}
<LINE>track_frame_format	{BEGIN(INITIAL);return T_TRACK_FRAME_FORMAT;}
<LINE>data_modulate		{BEGIN(INITIAL);return T_DATA_MODULATE;}
<LINE>VLBA_frmtr_sys_trk	{BEGIN(INITIAL);return T_VLBA_FRMTR_SYS_TRK;}
<LINE>VLBA_trnsprt_sys_trak	{BEGIN(INITIAL);return T_VLBA_TRNSPRT_SYS_TRAK;}
<LINE>S2_data_def		{BEGIN(INITIAL);return T_S2_DATA_DEF;}
<LINE>S2_record_mode		{BEGIN(INITIAL);return T_S2_RECORD_MODE;}
<LINE>S2_data_source		{BEGIN(INITIAL);return T_S2_DATA_SOURCE;}

<LINE>start_literal\(		{BEGIN(INITIAL); yylval.llptr=lit(); return T_LITERAL;}
	
<LINE,REF>\n		{trailing=0;lines++;}
<LINE,REF>{WHITE}*	/* skip white space */
<REF>{NAME}		{ NEWSTR(yylval.sval,yytext); return T_NAME; }
<REF>.			{return(yytext[0]);}

{DATE}		{ NEWSTR(yylval.sval,yytext); return T_DATE; }
{TIME}		{ NEWSTR(yylval.sval,yytext); return T_TIME; }
{ANGLE}		{ NEWSTR(yylval.sval,yytext); return T_ANGLE; }

{DOUBLE}	{ BEGIN(DOUBLE);
		  NEWSTR(yylval.sval,yytext); return T_DOUBLE;}
\"		{ yylval.sval=quote(); return T_NAME;}
{NAME}		{ NEWSTR(yylval.sval,yytext); return T_NAME; }
\&{NAME}	{ NEWSTR(yylval.sval,yytext+1); return T_LINK; }
\&\"		{ yylval.sval=quote(); return T_LINK;}

\n		{trailing=0;lines++;}
{WHITE}*	/* skip white space */

;		{trailing=1;BEGIN(LINE);return(yytext[0]);}
.		{return(yytext[0]);}

%%
static struct llist *lit()
{
  int inch, count, max_size;
  char *buffer, *last, *text;
  struct llist *llist;

  buffer = malloc(ALLOC_SIZE);
  if(buffer == NULL) {
    fprintf(stderr,"out of memory in literal 1\n");
    exit(1);
  }

/* find text inside start_literal() */

  max_size = ALLOC_SIZE;
  count=0;
  inch= input();
  while(inch !=EOF && inch != ')' && inch != 0 && inch != '\n') {
    buffer[count++]=inch;
    if(count >= max_size) {
      buffer=realloc(buffer,max_size+ALLOC_SIZE);
      if(buffer == NULL) {
	fprintf(stderr,"out of memory in literal 2\n");
	exit(1);
      }
      max_size += ALLOC_SIZE;
    }
    inch=input();
  }
  if(inch == EOF)
    yyerror("End of file in literal block delimiting text\n");
  else if (inch == 0)
    yyerror("Illegal character (\\0) in literal delimiting text\n");
  else if (inch == '\n')
    yyerror("Illegal character (\\n) in literal delimiting text\n");

  buffer[count++]='\0';
  buffer=realloc(buffer,count);
  if(buffer == NULL) {
    fprintf(stderr,"out of memory in literal 3\n");
	exit(1);
      }

  text=buffer;
  llist=add_list(NULL,buffer);

/* skip to ';' */

  inch=input();
  while(inch !=EOF & inch != ';' && inch != '\0') {
    if(inch == '\n')
      lines++;
    else if(NULL == strchr(" \t",inch))
      yyerror("Illegal character after start_literal()");
    inch=input();
  }
  if(inch == EOF)
    yyerror("End of file in literal block");
  else if (inch == 0)
    yyerror("Illegal character (\\0) after start_literal()");

  /* skip to '\n' */

  inch=input();
  while(inch !=EOF && inch != '\n' && inch != '\0') {
    if(NULL == strchr(" \t",inch))
      yyerror("Illegal character after start_literal();");
    inch=input();
  }
  if(inch == EOF)
    yyerror("End of file in literal block");
  else if (inch == 0)
    yyerror("Illegal character (\\0) after start_literal();");
  else if(inch == '\n')
    lines++;

  /* read lines */
  
  buffer = malloc(ALLOC_SIZE);
  if(buffer == NULL) {
    fprintf(stderr,"out of memory in literal 4\n");
    exit(1);
  }

  max_size = ALLOC_SIZE;
  count=0;
  inch= input();
  while(inch !=EOF && inch != 0) {
    if(inch != '\n') {
      buffer[count++]=inch;
      if(count >= max_size) {
	buffer=realloc(buffer,max_size+ALLOC_SIZE);
	if(buffer == NULL) {
	  fprintf(stderr,"out of memory in literal 8\n");
	  exit(1);
	}
	max_size += ALLOC_SIZE;
      }
    } else {
      buffer[count++]='\0';
      last=find_end(buffer,text);
      if(last != NULL)
	goto done;
      lines++;
      buffer=realloc(buffer,count);
      if(buffer == NULL) {
	fprintf(stderr,"out of memory in literal 6\n");
	exit(1);
      }
      llist=add_list(llist,buffer);
      buffer = malloc(ALLOC_SIZE);
      if(buffer == NULL) {
	fprintf(stderr,"out of memory in literal 7\n");
	exit(1);
      }
      max_size = ALLOC_SIZE;
      count=0;
    }
    inch=input();
  }
  if(inch == EOF)
    yyerror("End of file in literal block\n");
  else if (inch == 0)
    yyerror("Illegal character (\\0) in literal block\n");

 done:
  {
    int i=strlen(last)-1;

    unput('\n');
    while ( i >= 0) {
      unput(last[i]);
      i--;
    }
  }
  free(buffer);

  return llist;
}
static char *find_end(char *buffer, char *text)
{
  char *ptr, *start;
  char end[]="end_literal(";
  int textlen=strlen(text);

  start=buffer;
  while(NULL != (ptr=strchr(buffer++,end[0])))
    if(0==strncmp(ptr,end,sizeof(end)-1))
      if(0==strncmp(ptr+sizeof(end)-1,text,textlen))
	if(0==strncmp(ptr+sizeof(end)-1+textlen,")",1)) {
	  *ptr='\0';
	  for(;*start!=0;start++)
	    if(NULL == strchr(" \t",*start))
	      yyerror("Illegal character between '\\n' and end_literal(...)");
	  return ptr+sizeof(end)+textlen;
	}

  return NULL;
}
static char *quote()
{
  int inch, count, max_size;
  char *buffer;
  int temp, ch;
 
  buffer = malloc(ALLOC_SIZE);
  max_size = ALLOC_SIZE;
  inch=input();
  count=0;
  while(inch != EOF && inch != '"' && inch != '\n') {
    if(inch=='\\') {
      inch=input();
      ch=0;
      switch (inch) {
      case '\n':
	lines++;
	inch=input();
	break;
      case 'b':
	inch='\b';
	break;
      case 't':
	inch='\t';
	break;
      case 'n':
	inch='\n';
	break;
      case 'v':
	inch='\v';
	break;
      case 'f':
	inch='\f';
	break;
      case 'r':
	inch='\r';
	break;
      case 'X':
	ch='X';
      case 'x':
	inch=input();
	if(isxdigit(inch)){
	  temp=hextoint(toupper(inch));
	  inch=input();
	  if(isxdigit(inch)){
	    temp=(temp <<4) + hextoint(toupper(inch));
	  } else {
	    unput(inch);
	  }
	  inch=temp;
	} else {
	  unput(inch);
	  if (ch=='X') {
	    inch='X';
	  } else {
	    inch='x';
	  }
	}
	break;
      default:
	if(isodigit(inch)) {
	  temp=inch-'0';
	  inch=input();
	  if(isodigit(inch)){
	    temp = (temp << 3) + (inch - '0');
	    inch=input();
	    if(isodigit(inch)){
	      temp = (temp << 3) + (inch - '0');
	    } else {
	      unput(inch);
	    }
	  } else {
	    unput(inch);
	  }
	  inch=temp;
	}
      }
    }
    if(inch == 0) {
      yyerror("Null byte specified at line %d\n",lines);
    }
    buffer[count++] = inch;
    if(count >= max_size) {
      buffer = realloc(buffer,max_size + ALLOC_SIZE);
      max_size += ALLOC_SIZE;
    }
    inch = input();
  }
  if(inch == EOF || inch == '\n') {
    yyerror("Unterminated string at line %d\n",lines);
  }
  buffer[count]='\0';
  return buffer;
}

