
#include <stdio.h>

#include "vex.h"
#include "y.tab.h"

#define NEWSTRUCT(PTR,TYPE)	struct TYPE *PTR;\
			PTR=(struct TYPE *) malloc(sizeof(struct TYPE));\
			if(PTR == NULL) {\
			fprintf(stderr,"out of memory allocating TYPE\n");\
			exit(1);}

static int
get_chan_def_field(Chan_def *chan_def,int n,int *link,int *name, 
		   char **value, char **units);
static int
get_switching_cycle_field(Switching_cycle *switching_cycle,int n,int *link,
			  int *name, char **value, char **units);
static int
get_station_field(Station *station,int n,int *link, int * name,
		  char **value, char **units);
static int
get_axis_type_field(Axis_type *axis_type,int n,int *link,
			  int *name, char **value, char **units);
static int
get_ant_motion_field(Ant_motion *ant_motion,int n,int *link,
			  int *name, char **value, char **units);
static int
get_pointing_sector_field(Pointing_sector *pointing_sector,int n,int *link,
			  int *name, char **value, char **units);
static int
get_bbc_assign_field(Bbc_assign *bbc_assign,int n,int *link,
			  int *name, char **value, char **units);
static int
get_headstack_field(Headstack *headstack,int n,int *link,
			  int *name, char **value, char **units);
static int
get_data_source_field(Data_Source *data_source,int n,int *link,
			  int *name, char **value, char **units);
static int
get_tape_length_field(Tape_Length *tape_length,int n,int *link,
			  int *name, char **value, char **units);
static int
get_tape_motion_field(Tape_Motion *tape_motion,int n,int *link,
			  int *name, char **value, char **units);
static int
get_headstack_pos_field(Headstack_pos *headstack_pos,int n,int *link,
			  int *name, char **value, char **units);
static int
get_if_def_field(If_def *if_def,int n,int *link,
		 int *name, char **value, char **units);
static int
get_pcal_freq_field(Pcal_freq *pcal_freq,int n,int *link,
		 int *name, char **value, char **units);
static int
get_setup_always_field(Setup_always *setup_always,int n,int *link,
		 int *name, char **value, char **units);
static int
get_parity_check_field(Parity_check *parity_check,int n,int *link,
		 int *name, char **value, char **units);
static int
get_tape_prepass_field(Tape_prepass *tape_prepass,int n,int *link,
		 int *name, char **value, char **units);
static int
get_preob_cal_field(Preob_cal *preob_cal,int n,int *link,
		 int *name, char **value, char **units);
static int
get_midob_cal_field(Midob_cal *midob_cal,int n,int *link,
		 int *name, char **value, char **units);
static int
get_postob_cal_field(Postob_cal *postob_cal,int n,int *link,
		 int *name, char **value, char **units);
static int
get_sefd_field(Sefd *sefd,int n,int *link,
		 int *name, char **value, char **units);
static int
get_site_position_field(Site_position *site_position,int n,int *link,
		 int *name, char **value, char **units);
static int
get_ocean_load_vert_field(Ocean_load_vert *ocean_load_vert,int n,int *link,
		 int *name, char **value, char **units);
static int
get_ocean_load_horiz_field(Ocean_load_horiz *ocean_load_horiz,int n,int *link,
		 int *name, char **value, char **units);
static int
get_source_model_field(Source_model *source_model,int n,int *link,
		 int *name, char **value, char **units);
static int
get_vsn_field(Vsn *vsn,int n,int *link,
	      int *name, char **value, char **units);
static int
get_fanin_def_field(Fanin_def *fanin_def,int n,int *link,
	      int *name, char **value, char **units);
static int
get_fanout_def_field(Fanout_def *fanout_def,int n,int *link,
	      int *name, char **value, char **units);
static int
get_bitstream_list_field(Llist *list,int n,int *link,int *name,
		      char **value, char **units);
static int
get_vlba_frmtr_sys_trk_field(Vlba_frmtr_sys_trk *vlba_frmtr_sys_trk,int n,
			     int *link, int *name, char **value, char **units);
static int
get_s2_data_def_field(S2_data_def *s2_data_def,int n,int *link,
	      int *name, char **value, char **units);

static int
get_s2_record_mode_field(S2_record_mode *s2_record_mode,int n,int *link,
	      int *name, char **value, char **units);

static int
get_dvalue_field(Dvalue *dvalue,int n,int *link,int *name, char **value,
		 char **units);
static int
get_dvalue_list_field(Llist *list,int n,int *link, int *name,
		      char **value, char **units);
static int
get_svalue_field(char *svalue,int n,int *link, int *name,
		 char **value, char **units);
static int
get_svalue_list_field(Llist *list,int n,int *link,int *name,
		      char **value, char **units);
static int
get_date_field(char *date,int n,int *link, int *name, char **value,
	       char **units);
static int
get_time_field(char *time,int n,int *link, int *name, char **value,
		   char **units);
static int
get_angle_field(char *angle,int n,int *link, int *name, char **value,
		   char **units);

static struct {
  char *str;
  int value;
} blocks[] = {
  {"GLOBAL", B_GLOBAL},
  {"STATION", B_STATION},
  {"MODE", B_MODE},
  {"SCHED", B_SCHED},
  {"EXPER", B_EXPER},
  {"SCHEDULING_PARMS", B_SCHEDULING_PARMS},
  {"PROC_TIMING", B_PROC_TIMING},
  {"EOP", B_EOP},
  {"FREQ", B_FREQ},
  {"CLOCK", B_CLOCK},
  {"ANTENNA", B_ANTENNA},
  {"BBC", B_BBC},
  {"CORR", B_CORR},
  {"DAS", B_DAS},
  {"HEAD_POS", B_HEAD_POS},
  {"PASS_ORDER", B_PASS_ORDER},
  {"PHASE_CAL", B_PHASE_CAL},
  {"ROLL", B_ROLL},
  {"IF", B_IF},
  {"SEFD", B_SEFD},
  {"SITE", B_SITE},
  {"SOURCE", B_SOURCE},
  {"TAPELOG_OBS", B_TAPELOG_OBS},
  {"TRACKS", B_TRACKS},
  {NULL, 0}
};
static  struct {
  char *str;
  int  value;
} lowls[]= {
  {"VEX_rev", T_VEX_REV},
  {"chan_def", T_CHAN_DEF},
  {"sample_rate", T_SAMPLE_RATE},
  
  {"bits_per_sample", T_BITS_PER_SAMPLE},
  {"switching_cycle", T_SWITCHING_CYCLE},
    
  {"start", T_START},
  {"source", T_SOURCE},
  {"mode", T_MODE},
  {"station", T_STATION},
    
  {"ant_diam", T_ANT_DIAM},
  {"axis_type", T_AXIS_TYPE},
  {"axis_offset", T_AXIS_OFFSET},
  {"ant_motion", T_ANT_MOTION},
  {"pointing_sector", T_POINTING_SECTOR},
  
  {"BBC_assign", T_BBC_ASSIGN},
  
  {"clock_early", T_CLOCK_EARLY},
  {"clock_early_epoch", T_CLOCK_EARLY_EPOCH},
  {"clock_rate", T_CLOCK_RATE},
    
  {"record_transport", T_RECORD_TRANSPORT},
  {"electronics_rack", T_ELECTRONICS_RACK},
  {"number_drives", T_NUMBER_DRIVES},
  {"headstack", T_HEADSTACK},
  {"data_source", T_DATA_SOURCE},
  {"record_density", T_RECORD_DENSITY},
  {"tape_length", T_TAPE_LENGTH},
  {"recording_system_ID", T_RECORDING_SYSTEM_ID},
  {"tape_motion", T_TAPE_MOTION},
  {"tape_control", T_TAPE_CONTROL},
  
  {"TAI-UTC", T_TAI_UTC},
  {"A1-TAI", T_A1_TAI},
  {"eop_ref_epoch", T_EOP_REF_EPOCH},
  {"num_eop_points", T_NUM_EOP_POINTS},
  {"eop_interval", T_EOP_INTERVAL},
  {"ut1-utc", T_UT1_UTC},
  {"x_wobble", T_X_WOBBLE},
  {"y_wobble", T_Y_WOBBLE},
  
  {"exper_num", T_EXPER_NUM},
  {"exper_name", T_EXPER_NAME},
  {"exper_nominal_start", T_EXPER_NOMINAL_START},
  {"exper_nominal_stop", T_EXPER_NOMINAL_STOP},
  {"pi_name", T_PI_NAME},
  {"pi_email", T_PI_EMAIL},
  {"contact_name", T_CONTACT_NAME},
  {"contact_email", T_CONTACT_EMAIL},
  {"scheduler_name", T_SCHEDULER_NAME},
  {"scheduler_email", T_SCHEDULER_EMAIL},
  {"target_correlator", T_TARGET_CORRELATOR},
    
  {"headstack_pos", T_HEADSTACK_POS},
  
  {"if_def", T_IF_DEF},
  
  {"pass_order", T_PASS_ORDER},
  {"S2_group_order", T_S2_GROUP_ORDER},
  
  {"pcal_freq", T_PCAL_FREQ},
  
  {"tape_change", T_TAPE_CHANGE},
  {"headstk_motion", T_HEADSTK_MOTION},
  {"new_source_command", T_NEW_SOURCE_COMMAND},
  {"new_tape_setup", T_NEW_TAPE_SETUP},
  {"setup_always", T_SETUP_ALWAYS},
  {"parity_check", T_PARITY_CHECK},
  {"tape_prepass", T_TAPE_PREPASS},
  {"preob_cal", T_PREOB_CAL},
  {"midob_cal", T_MIDOB_CAL},
  {"postob_cal", T_POSTOB_CAL},
    
  {"reinit_period", T_REINIT_PERIOD},
  {"inc_period", T_INC_PERIOD},
  {"roll", T_ROLL},
  
  {"sefd_model", T_SEFD_MODEL},
  {"sefd", T_SEFD},
  
  {"site_type", T_SITE_TYPE},
  {"site_name", T_SITE_NAME},
  {"site_ID", T_SITE_ID},
  {"site_position", T_SITE_POSITION},
  {"horizon_map_az", T_HORIZON_MAP_AZ},
  {"horizon_map_el", T_HORIZON_MAP_EL},
  {"zen_atmos", T_ZEN_ATMOS},
  {"ocean_load_vert", T_OCEAN_LOAD_VERT},
  {"ocean_load_horiz", T_OCEAN_LOAD_HORIZ},
  {"occupation_code", T_OCCUPATION_CODE},
  {"inclination", T_INCLINATION},
  {"eccentricity", T_ECCENTRICITY},
  {"arg_perigee", T_ARG_PERIGEE},
  {"ascending_node", T_ASCENDING_NODE},
  {"mean_anomaly", T_MEAN_ANOMALY},
  {"semi-major_axis", T_SEMI_MAJOR_AXIS},
  {"mean_motion", T_MEAN_MOTION},
  {"orbit_epoch", T_ORBIT_EPOCH},
  
  {"source_type", T_SOURCE_TYPE},
  {"source_name", T_SOURCE_NAME},
  {"IAU_name", T_IAU_NAME},
  {"ra", T_RA},
  {"dec", T_DEC},
  {"epoch", T_EPOCH},
  {"source_pos_ref", T_SOURCE_POS_REF},
  {"ra_rate", T_RA_RATE},
  {"dec_rate", T_DEC_RATE},
  {"velocity_wrt_LSR", T_VELOCITY_WRT_LSR},
  {"source_model", T_SOURCE_MODEL},
  
  {"VSN", T_VSN},
  
  {"fanin_def", T_FANIN_DEF},
  {"fanout_def", T_FANOUT_DEF},
  {"track_frame_format", T_TRACK_FRAME_FORMAT},
  {"data_modulate", T_DATA_MODULATE},
  {"VLBA_frmtr_sys_trk", T_VLBA_FRMTR_SYS_TRK},
  {"VLBA_trnsprt_sys_trak", T_VLBA_TRNSPRT_SYS_TRAK},
  {"S2_data_def", T_S2_DATA_DEF},
  {"S2_record_mode", T_S2_RECORD_MODE},
  {"S2_data_source", T_S2_DATA_SOURCE},
  {NULL, 0}
};

struct llist *add_list(struct llist *start,void *ptr)
{
  struct llist *last;
  NEWSTRUCT(new,llist);

  new->ptr=ptr;
  new->next=NULL;
  
  if(start == NULL)
    return new;
  
  for (last=start;last->next !=NULL;last=last->next)
    ;

  last->next=new;
  
  return start;
}
struct llist *ins_list(void *ptr, struct llist *start)
{
  NEWSTRUCT(new,llist);

  new->ptr=ptr;
  new->next=start;
  
  return new;
}

struct qref *make_qref(int primitive,char *name,struct llist *qualifiers)
{
  NEWSTRUCT(new,qref);

  new->primitive=primitive;
  new->name=name;
  new->qualifiers=qualifiers;

  return new;
}

struct def *make_def(char *name, struct llist *refs)
{
  NEWSTRUCT(new,def);

  new->name=name;
  new->refs=refs;

  return new;
}

struct block *make_block(int block,struct llist *items)
{
  NEWSTRUCT(new,block);

  new->block=block;
  new->items=items;

  return new;
}

struct vex *make_vex(struct llist *version, struct llist *blocks)
{
  NEWSTRUCT(new,vex);

  new->version=version;
  new->blocks=blocks;

  return new;
}

struct lowl *make_lowl(int statement,void *item)
{
  NEWSTRUCT(new,lowl);

  new->statement=statement;
  new->item=item;

  return new;
}

struct chan_def  *make_chan_def(char *band_id, char *polar,
				struct dvalue *sky_freq, char *net_sb,
				struct dvalue *bw, char *chan_id, char *bbc_id,
				char *pcal_id, struct llist *states)
{
  NEWSTRUCT(new,chan_def);

  new->band_id=band_id;
  new->polar=polar;
  new->sky_freq=sky_freq;
  new->net_sb=net_sb;
  new->bw=bw;
  new->chan_id=chan_id;
  new->bbc_id=bbc_id;
  new->pcal_id=pcal_id;
  new->states=states;

  return new;
}

struct dvalue *make_dvalue(char *value, char *units)
{
  NEWSTRUCT(new,dvalue);

  new->value=value;
  new->units=units;

  return new;
}
struct external *make_external(char *file, int primitive, char *name)
{
  NEWSTRUCT(new,external);

  new->file=file;
  new->primitive=primitive;
  new->name=name;

  return new;
}
struct switching_cycle *make_switching_cycle(char *origin,
					      struct llist *periods)
{
  NEWSTRUCT(new,switching_cycle);

  new->origin=origin;
  new->periods=periods;

  return new;
}

struct station  *make_station(char *key, struct dvalue *start,
			      struct dvalue *stop, struct dvalue *start_pos,
			      char *pass, char *sector, struct llist *drives)
{
  NEWSTRUCT(new,station);

  new->key=key;
  new->start=start;
  new->stop=stop;
  new->start_pos=start_pos;
  new->pass=pass;
  new->sector=sector;
  new->drives=drives;
  return new;
}

struct axis_type *make_axis_type(char *axis1, char *axis2)
{
  NEWSTRUCT(new,axis_type);

  new->axis1=axis1;
  new->axis2=axis2;

  return new;
}

struct ant_motion *make_ant_motion(char *axis,struct dvalue *rate,
				   struct dvalue *offset)
{
  NEWSTRUCT(new,ant_motion);

  new->axis=axis;
  new->rate=rate;
  new->offset=offset;

  return new;
}

struct pointing_sector *make_pointing_sector(char *sector, char *axis1,
					     struct dvalue *lolimit1,
					     struct dvalue *hilimit1,
					     char *axis2,
					     struct dvalue *lolimit2,
					     struct dvalue *hilimit2)
{
  NEWSTRUCT(new,pointing_sector);

  new->sector=sector;
  new->axis1=axis1;
  new->lolimit1=lolimit1;
  new->hilimit1=hilimit1;
  new->axis2=axis2;
  new->lolimit2=lolimit2;
  new->hilimit2=hilimit2;

  return new;
}
struct bbc_assign *make_bbc_assign(char *bbc_id,struct dvalue *physical,
				   char *if_id)
{
  NEWSTRUCT(new,bbc_assign);

  new->bbc_id=bbc_id;
  new->physical=physical;
  new->if_id=if_id;

  return new;
}
struct headstack *make_headstack(struct dvalue *stack,char *type,
				 char *drive_id)
{
  NEWSTRUCT(new,headstack);

  new->stack=stack;
  new->type=type;
  new->drive_id=drive_id;

  return new;
}
struct data_source *make_data_source(char *source,char *input1, char *input2,
				     char *input3, char *input4, char *input5,
				     char *input6, char *input7, char *input8)
{
  NEWSTRUCT(new,data_source);
 
  new->source=source;
  new->input[0]=input1;
  new->input[1]=input2;
  new->input[2]=input3;
  new->input[3]=input4;
  new->input[4]=input5;
  new->input[5]=input6;
  new->input[6]=input7;
  new->input[7]=input8;

  return new;
}
    
struct tape_length *make_tape_length(struct dvalue *duration, char *speed,
				     struct dvalue *tapes)
{
  NEWSTRUCT(new,tape_length);
 
  new->duration=duration;
  new->speed=speed;
  new->tapes=tapes;

  return new;
}
    
struct tape_motion *make_tape_motion(char *type, struct dvalue *early,
				     struct dvalue *late, struct dvalue *gap)
{
  NEWSTRUCT(new,tape_motion);
 
  new->type=type;
  new->early=early;
  new->late=late;
  new->gap=gap;

  return new;
}
struct headstack_pos *make_headstack_pos(struct dvalue *index,
					 struct llist *positions)
{
  NEWSTRUCT(new,headstack_pos);

  new->index=index;
  new->positions=positions;

  return new;
}

struct if_def *make_if_def(char *if_id, struct dvalue *lo, char *sb)
{
  NEWSTRUCT(new,if_def);

  new->if_id=if_id;
  new->lo=lo;
  new->sb=sb;

  return new;
}
struct pcal_freq *make_pcal_freq(char *pcal_id,char *state,
				 struct dvalue *primary,
				 struct dvalue *increment)
{
  NEWSTRUCT(new,pcal_freq);

  new->pcal_id=pcal_id;
  new->state=state;
  new->primary=primary;
  new->increment=increment;

  return new;
}
struct setup_always *make_setup_always(char *state, struct dvalue *time)
{
  NEWSTRUCT(new,setup_always);

  new->state=state;
  new->time=time;

  return new;
}
struct parity_check *make_parity_check(char *state, struct dvalue *time)
{
  NEWSTRUCT(new,parity_check);

  new->state=state;
  new->time=time;

  return new;
}
struct tape_prepass *make_tape_prepass(char *state, struct dvalue *time)
{
  NEWSTRUCT(new,tape_prepass);

  new->state=state;
  new->time=time;

  return new;
}
struct preob_cal *make_preob_cal(char *state, struct dvalue *time,
				 char *name)
{
  NEWSTRUCT(new,preob_cal);

  new->state=state;
  new->time=time;
  new->name=name;

  return new;
}
struct midob_cal *make_midob_cal(char *state, struct dvalue *time,
				 char *name)
{
  NEWSTRUCT(new,midob_cal);

  new->state=state;
  new->time=time;
  new->name=name;

  return new;
}
struct postob_cal *make_postob_cal(char *state, struct dvalue *time,
				 char *name)
{
  NEWSTRUCT(new,postob_cal);

  new->state=state;
  new->time=time;
  new->name=name;

  return new;
}
struct sefd *make_sefd(char *if_id, struct dvalue *flux, struct llist *params)
{
  NEWSTRUCT(new,sefd);

  new->if_id=if_id;
  new->flux=flux;
  new->params=params;

  return new;
}

struct site_position *make_site_position(struct dvalue *x, struct dvalue *y,
					 struct dvalue *z,
					 struct dvalue *epoch, char *ref)
{
  NEWSTRUCT(new,site_position);

  new->x=x;
  new->y=y;
  new->z=z;
  new->epoch=epoch;
  new->ref=ref;

  return new;
}
struct ocean_load_vert *make_ocean_load_vert(struct dvalue *amp,
					     struct dvalue *phase)
{
  NEWSTRUCT(new,ocean_load_vert);

  new->amp=amp;
  new->phase=phase;

  return new;
}
struct ocean_load_horiz *make_ocean_load_horiz(struct dvalue *amp,
					       struct dvalue *phase)
{
  NEWSTRUCT(new,ocean_load_horiz);

  new->amp=amp;
  new->phase=phase;

  return new;
}
struct source_model *make_source_model(struct dvalue *component,
				       char *band_id, struct dvalue *flux,
				       struct dvalue *majoraxis,
				       struct dvalue *ratio,
				       struct dvalue *angle,
				       struct dvalue *raoff,
				       struct dvalue *decoff)
{
  NEWSTRUCT(new,source_model);

  new->component=component;
  new->band_id=band_id;
  new->flux=flux;
  new->majoraxis=majoraxis;
  new->ratio=ratio;
  new->angle=angle;
  new->raoff=raoff;
  new->decoff=decoff;

  return new;
}
struct vsn *make_vsn(struct dvalue *drive, char *label, char *start,
		     char *stop)
{
  NEWSTRUCT(new,vsn);

  new->drive=drive;
  new->label=label;
  new->start=start;
  new->stop=stop;

  return new;
}
struct fanin_def *make_fanin_def(char *subpass, struct dvalue *hdstk,
				 struct dvalue *track,
				 struct llist *bitstreams)
{
  NEWSTRUCT(new,fanin_def);

  new->subpass=subpass;
  new->hdstk=hdstk;
  new->track=track;
  new->bitstreams=bitstreams;

  return new;
}
struct fanout_def *make_fanout_def(char *subpass, struct llist *bitstream,
				   struct dvalue *hdstk, struct llist *tracks)
{
  NEWSTRUCT(new,fanout_def);

  new->subpass=subpass;
  new->bitstream=bitstream;
  new->hdstk=hdstk;
  new->tracks=tracks;

  return new;
}
struct vlba_frmtr_sys_trk *make_vlba_frmtr_sys_trk(struct dvalue *output,
						   char *use,
						   struct dvalue *start,
						   struct dvalue *stop)
{
  NEWSTRUCT(new,vlba_frmtr_sys_trk);

  new->output=output;
  new->use=use;
  new->start=start;
  new->stop=stop;

  return new;
}
struct s2_data_def *make_s2_data_def(struct llist *bitstream,char *input)
{
  NEWSTRUCT(new,s2_data_def);

  new->bitstream=bitstream;
  new->input=input;

  return new;
}
struct s2_record_mode *make_s2_record_mode(char *mode, struct dvalue *groups,
					   struct llist *inputs)
{
  NEWSTRUCT(new,s2_record_mode);

  new->mode=mode;
  new->groups=groups;
  new->inputs=inputs;

  return new;
}

int
lowl2int(char *lowl)
{
  int i;

  for(i=0;lowls[i].str!=NULL;i++)
    if(0==strcmp(lowls[i].str,lowl))
      return lowls[i].value;

  return 0;
}
int
block2int(char *block)
{
  int i;

  for(i=0;blocks[i].str!=NULL;i++)
    if(0==strcmp(blocks[i].str,block))
      return blocks[i].value;

  return 0;
}
char *
int2lowl(int lowl)
{
  int i;

  for(i=0;lowls[i].str!=NULL;i++)
    if(lowls[i].value==lowl)
      return lowls[i].str;

  return NULL;
}
char *
int2block(int block)
{
  int i;

  for(i=0;blocks[i].str!=NULL;i++)
    if(blocks[i].value==block)
      return blocks[i].str;

  return NULL;
}
int
vex_field(int statement,void *ptr,int n,int *link,int *name,char **value,
char **units)
{
  int ierr;

  *link=0;
  *name=1;
  *units=NULL;
  *value=NULL;

  if(n==0) {
    *value=int2lowl(statement);
    if(*value==NULL)
      return -1;

    return 0;
  }

  switch (statement){
  case T_CHAN_DEF:
    ierr=get_chan_def_field(ptr,n,link,name,value,units);
    break;
  case T_VEX_REV:
  case T_SAMPLE_RATE:
  case T_BITS_PER_SAMPLE:
  case T_ANT_DIAM:
  case T_AXIS_OFFSET:
  case T_CLOCK_EARLY:
  case T_CLOCK_RATE:
  case T_NUMBER_DRIVES:
  case T_RECORD_DENSITY:
  case T_RECORDING_SYSTEM_ID:
  case T_TAI_UTC:
  case T_A1_TAI:
  case T_NUM_EOP_POINTS:
  case T_EOP_INTERVAL:
  case T_EXPER_NUM:
  case T_TAPE_CHANGE:
  case T_HEADSTK_MOTION:
  case T_NEW_SOURCE_COMMAND:
  case T_NEW_TAPE_SETUP:
  case T_REINIT_PERIOD:
  case T_INC_PERIOD:
  case T_ZEN_ATMOS:
  case T_INCLINATION:
  case T_ECCENTRICITY:
  case T_ARG_PERIGEE:
  case T_ASCENDING_NODE:
  case T_MEAN_ANOMALY:
  case T_SEMI_MAJOR_AXIS:
  case T_MEAN_MOTION:
  case T_RA_RATE:
  case T_DEC_RATE:
  case T_VELOCITY_WRT_LSR:
    ierr=get_dvalue_field(ptr,n,link,name,value,units);
    break;
  case T_SWITCHING_CYCLE:
    ierr=get_switching_cycle_field(ptr,n,link,name,value,units);
    break;
  case T_START:
  case T_CLOCK_EARLY_EPOCH:
  case T_EOP_REF_EPOCH:
  case T_EXPER_NOMINAL_START:
  case T_EXPER_NOMINAL_STOP:
  case T_ORBIT_EPOCH:
    ierr=get_date_field(ptr,n,link,name,value,units);
    break;
  case T_MODE:
  case T_SOURCE:
  case T_RECORD_TRANSPORT:
  case T_ELECTRONICS_RACK:
  case T_TAPE_CONTROL:
  case T_EXPER_NAME:
  case T_PI_NAME:
  case T_PI_EMAIL:
  case T_CONTACT_NAME:
  case T_CONTACT_EMAIL:
  case T_SCHEDULER_NAME:
  case T_SCHEDULER_EMAIL:
  case T_TARGET_CORRELATOR:
  case T_SEFD_MODEL:
  case T_SITE_TYPE:
  case T_SITE_NAME:
  case T_SITE_ID:
  case T_OCCUPATION_CODE:
  case T_SOURCE_NAME:
  case T_IAU_NAME:
  case T_EPOCH:
  case T_SOURCE_POS_REF:
  case T_TRACK_FRAME_FORMAT:
  case T_DATA_MODULATE:
    ierr=get_svalue_field(ptr,n,link,name,value,units);
    break;
  case T_STATION:
    ierr=get_station_field(ptr,n,link,name,value,units);
    break;
  case T_AXIS_TYPE:
    ierr=get_axis_type_field(ptr,n,link,name,value,units);
    break;
  case T_ANT_MOTION:
    ierr=get_ant_motion_field(ptr,n,link,name,value,units);
    break;
  case T_POINTING_SECTOR:
    ierr=get_pointing_sector_field(ptr,n,link,name,value,units);
    break;
  case T_BBC_ASSIGN:
    ierr=get_bbc_assign_field(ptr,n,link,name,value,units);
    break;
  case T_HEADSTACK:
    ierr=get_headstack_field(ptr,n,link,name,value,units);
    break;
  case T_DATA_SOURCE:
    ierr=get_data_source_field(ptr,n,link,name,value,units);
    break;
  case T_TAPE_LENGTH:
    ierr=get_tape_length_field(ptr,n,link,name,value,units);
    break;
  case T_TAPE_MOTION:
    ierr=get_tape_motion_field(ptr,n,link,name,value,units);
    break;
  case T_UT1_UTC:
  case T_X_WOBBLE:
  case T_Y_WOBBLE:
  case T_S2_GROUP_ORDER:
  case T_ROLL:
  case T_HORIZON_MAP_AZ:
  case T_HORIZON_MAP_EL:
  case T_VLBA_TRNSPRT_SYS_TRAK:
    ierr=get_dvalue_list_field(ptr,n,link,name,value,units);
    break;
  case T_HEADSTACK_POS:
    ierr=get_headstack_pos_field(ptr,n,link,name,value,units);
    break;
  case T_IF_DEF:
    ierr=get_if_def_field(ptr,n,link,name,value,units);
    break;
  case T_PASS_ORDER:
  case T_SOURCE_TYPE:
  case T_S2_DATA_SOURCE:
    ierr=get_svalue_list_field(ptr,n,link,name,value,units);
    break;
  case T_PCAL_FREQ:
    ierr=get_pcal_freq_field(ptr,n,link,name,value,units);
    break;
  case T_SETUP_ALWAYS:
    ierr=get_setup_always_field(ptr,n,link,name,value,units);
    break;
  case T_PARITY_CHECK:
    ierr=get_parity_check_field(ptr,n,link,name,value,units);
    break;
  case T_TAPE_PREPASS:
    ierr=get_tape_prepass_field(ptr,n,link,name,value,units);
    break;
  case T_PREOB_CAL:
    ierr=get_preob_cal_field(ptr,n,link,name,value,units);
    break;
  case T_MIDOB_CAL:
    ierr=get_midob_cal_field(ptr,n,link,name,value,units);
    break;
  case T_POSTOB_CAL:
    ierr=get_postob_cal_field(ptr,n,link,name,value,units);
    break;
  case T_SEFD:
    ierr=get_sefd_field(ptr,n,link,name,value,units);
    break;
  case T_SITE_POSITION:
    ierr=get_site_position_field(ptr,n,link,name,value,units);
    break;
  case T_OCEAN_LOAD_VERT:
    ierr=get_ocean_load_vert_field(ptr,n,link,name,value,units);
    break;
  case T_OCEAN_LOAD_HORIZ:
    ierr=get_ocean_load_horiz_field(ptr,n,link,name,value,units);
    break;
  case T_RA:
    ierr=get_time_field(ptr,n,link,name,value,units);
    break;
  case T_DEC:
    ierr=get_angle_field(ptr,n,link,name,value,units);
    break;
  case T_SOURCE_MODEL:
    ierr=get_source_model_field(ptr,n,link,name,value,units);
    break;
  case T_VSN:
    ierr=get_vsn_field(ptr,n,link,name,value,units);
    break;
  case T_FANIN_DEF:
    ierr=get_fanin_def_field(ptr,n,link,name,value,units);
    break;
  case T_FANOUT_DEF:
    ierr=get_fanout_def_field(ptr,n,link,name,value,units);
    break;
  case T_VLBA_FRMTR_SYS_TRK:
    ierr=get_vlba_frmtr_sys_trk_field(ptr,n,link,name,value,units);
    break;
  case T_S2_DATA_DEF:
    ierr=get_s2_data_def_field(ptr,n,link,name,value,units);
    break;
  case T_S2_RECORD_MODE:
    ierr=get_s2_record_mode_field(ptr,n,link,name,value,units);
    break;
  default:
    fprintf(stderr,"can't get here in get_field %d\n",statement);
    exit(1);
  }
  if(ierr==-1)
    return -2;
  else if (ierr!=0) {
    fprintf(stderr,"unknown error in vex_field %d\n",ierr);
    exit(1);
  }
  return 0;
}

static int
get_chan_def_field(Chan_def *chan_def,int n,int *link, int *name, 
		   char **value, char **units)
{
  int ierr;

  *link=0;
  *name=1;
  *units=NULL;
  *value=NULL;

  switch(n) {
  case 1:
    *value=chan_def->band_id;
    *link=1;
    break;
  case 2:
    *value=chan_def->polar;
    break;
  case 3:
    *value=chan_def->sky_freq->value;
    *units=chan_def->sky_freq->units;
    *name=0;
    break;
  case 4:
    *value=chan_def->net_sb;
    break;
  case 5:
    *value=chan_def->bw->value;
    *units=chan_def->bw->units;
    *name=0;
    break;
  case 6:
    *value=chan_def->chan_id;
    *link=1;
    break;
  case 7:
    *value=chan_def->bbc_id;
    *link=1;
    break;
  case 8:
    *value=chan_def->pcal_id;
    *link=1;
    break;
  default:
    if(n < 1 )
      return -1;
    ierr=get_dvalue_list_field(chan_def->states,n-8,link,name,value,units);
    if(ierr==-1)
      return -1;
    else if (ierr!=0) {
      fprintf(stderr,"unknown error in get_chan_def_field %d\n",ierr);
      exit(1);
    }
  }
  return 0;
}
static int
get_switching_cycle_field(Switching_cycle *switching_cycle,int n,int *link,
			  int *name, char **value, char **units)
{
  int ierr;

  *link=0;
  *name=1;
  *units=NULL;
  *value=NULL;

  switch(n) {
  case 1:
    *value=switching_cycle->origin;
    break;
  default:
    if(n < 1 )
      return -1;
    ierr=get_dvalue_list_field(switching_cycle->periods,n-1,link,name,
			       value,units);
    if(ierr==-1)
      return -1;
    else if (ierr!=0) {
      fprintf(stderr,"unknown error in get_switching_cycle_field %d\n",ierr);
      exit(1);
    }
  }
  return 0;
}
static int
get_station_field(Station *station,int n,int *link,int *name,char **value,
		   char **units)
{
  int ierr;

  *link=0;
  *name=1;
  *units=NULL;
  *value=NULL;

  switch(n) {
  case 1:
    *value=station->key;
    break;
  case 2:
    *value=station->start->value;
    *units=station->start->units;
    *name=0;
    break;
  case 3:
    *value=station->stop->value;
    *units=station->stop->units;
    *name=0;
    break;
  case 4:
    if(station->start_pos == NULL) {
      *value=NULL;
      *units=NULL;
    } else {
      *value=station->start_pos->value;
      *units=station->start_pos->units;
    }
    *name=0;
    break;
  case 5:
    *value=station->pass;
    break;
  case 6:
    *link=1;
    *value=station->sector;
    break;
  default:
    if(n < 1 )
      return -1;
    ierr=get_dvalue_list_field(station->drives,n-6,link,name,value,units);
    if(ierr==-1)
      return -1;
    else if (ierr!=0) {
      fprintf(stderr,"unknown error in get_station_field %d\n",ierr);
      exit(1);
    }
  }
  return 0;
}
static int
get_axis_type_field(Axis_type *axis_type,int n,int *link,
			  int *name, char **value, char **units)
{
  int ierr;

  *link=0;
  *name=1;
  *units=NULL;
  *value=NULL;

  switch(n) {
  case 1:
    *value=axis_type->axis1;
    break;
  case 2:
    *value=axis_type->axis2;
    break;
  default:
    return -1;
  }
  return 0;
}
static int
get_ant_motion_field(Ant_motion *ant_motion,int n,int *link,
			  int *name, char **value, char **units)
{
  int ierr;

  *link=0;
  *name=1;
  *units=NULL;
  *value=NULL;

  switch(n) {
  case 1:
    *value=ant_motion->axis;
    break;
  case 2:
    *value=ant_motion->rate->value;
    *units=ant_motion->rate->units;
    *name=0;
    break;
  case 3:
    *value=ant_motion->offset->value;
    *units=ant_motion->offset->units;
    *name=0;
    break;
  default:
    return -1;
  }
  return 0;
}

static int
get_pointing_sector_field(Pointing_sector *pointing_sector,int n,int *link,
			  int *name, char **value, char **units)
{
  int ierr;

  *link=0;
  *name=1;
  *units=NULL;
  *value=NULL;

  switch(n) {
  case 1:
    *value=pointing_sector->sector;
    *link=1;
    break;
  case 2:
    *value=pointing_sector->axis1;
    break;
  case 3:
    *value=pointing_sector->lolimit1->value;
    *units=pointing_sector->lolimit1->units;
    *name=0;
    break;
  case 4:
    *value=pointing_sector->hilimit1->value;
    *units=pointing_sector->hilimit1->units;
    *name=0;
    break;
  case 5:
    *value=pointing_sector->axis2;
    break;
  case 6:
    *value=pointing_sector->lolimit2->value;
    *units=pointing_sector->lolimit2->units;
    *name=0;
    break;
  case 7:
    *value=pointing_sector->hilimit2->value;
    *units=pointing_sector->hilimit2->units;
    *name=0;
    break;
  default:
    return -1;
  }
  return 0;
}

static int
get_bbc_assign_field(Bbc_assign *bbc_assign,int n,int *link,
			  int *name, char **value, char **units)
{
  int ierr;

  *link=0;
  *name=1;
  *units=NULL;
  *value=NULL;

  switch(n) {
  case 1:
    *value=bbc_assign->bbc_id;
    *link=1;
    break;
  case 2:
    *value=bbc_assign->physical->value;
    *units=bbc_assign->physical->units;
    *name=0;
    break;
  case 3:
    *value=bbc_assign->if_id;
    *link=1;
    break;
  default:
    return -1;
  }
  return 0;
}
static int
get_headstack_field(Headstack *headstack,int n,int *link,
			  int *name, char **value, char **units)
{
  int ierr;

  *link=0;
  *name=1;
  *units=NULL;
  *value=NULL;

  switch(n) {
  case 1:
    *value=headstack->stack->value;
    *units=headstack->stack->units;
    *name=0;
    break;
  case 2:
    *value=headstack->type;
    break;
  case 3:
    *value=headstack->drive_id;
    *link=1;
    break;
  default:
    return -1;
  }
  return 0;
}
static int
get_data_source_field(Data_Source *data_source,int n,int *link,
			  int *name, char **value, char **units)
{
  int ierr;

  *link=0;
  *name=1;
  *units=NULL;
  *value=NULL;

  switch(n) {
  case 1:
    *value=data_source->source;
    break;
  case 2:
  case 3:
  case 4:
  case 5:
  case 6:
  case 7:
  case 8:
  case 9:
    *value=data_source->input[n-2];
    break;
  default:
    return -1;
  }
  return 0;
}
static int
get_tape_length_field(Tape_Length *tape_length,int n,int *link,
			  int *name, char **value, char **units)
{
  int ierr;

  *link=0;
  *name=1;
  *units=NULL;
  *value=NULL;

  switch(n) {
  case 1:
    *value=tape_length->duration->value;
    *units=tape_length->duration->units;
    *name=0;
    break;
  case 2:
    if(tape_length->speed==NULL)
      return -1;
    *value=tape_length->speed;
    break;
  case 3:
    *value=tape_length->tapes->value;
    *units=tape_length->tapes->units;
    *name=0;
    break;
  default:
    return -1;
  }
  return 0;
}
static int
get_tape_motion_field(Tape_Motion *tape_motion,int n,int *link,
			  int *name, char **value, char **units)
{
  int ierr;

  *link=0;
  *name=1;
  *units=NULL;
  *value=NULL;

  switch(n) {
  case 1:
    *value=tape_motion->type;
    break;
  case 2:
    if(tape_motion->early==NULL)
      return -1;
    *value=tape_motion->early->value;
    *units=tape_motion->early->units;
    *name=0;
    break;
  case 3:
    if(tape_motion->late==NULL)
      return -1;
    *value=tape_motion->late->value;
    *units=tape_motion->late->units;
    *name=0;
    break;
  case 4:
    *value=tape_motion->gap->value;
    *units=tape_motion->gap->units;
    *name=0;
    break;
  default:
    return -1;
  }
  return 0;
}
static int
get_headstack_pos_field(Headstack_pos *headstack_pos,int n,int *link,
			  int *name, char **value, char **units)
{
  int ierr;

  *link=0;
  *name=1;
  *units=NULL;
  *value=NULL;

  switch(n) {
  case 1:
    *value=headstack_pos->index->value;
    *units=headstack_pos->index->units;
    *name=0;
    break;
  default:
    if(n < 1 )
      return -1;
    ierr=get_dvalue_list_field(headstack_pos->positions,n-1,link,name,
			       value, units);
    if(ierr==-1)
      return -1;
    else if (ierr!=0) {
      fprintf(stderr,"unknown error in get_headstack_pos_field %d\n",ierr);
      exit(1);
    }
  }
  return 0;
}
static int
get_if_def_field(If_def *if_def,int n,int *link,
		 int *name, char **value, char **units)
{
  int ierr;

  *link=0;
  *name=1;
  *units=NULL;
  *value=NULL;

  switch(n) {
  case 1:
    *value=if_def->if_id;
    *link=1;
    break;
  case 2:
    *value=if_def->lo->value;
    *units=if_def->lo->units;
    *name=0;
    break;
  case 3:
    *value=if_def->sb;
    break;
  default:
    return -1;
  }
  return 0;
}
static int
get_pcal_freq_field(Pcal_freq *pcal_freq,int n,int *link,
		 int *name, char **value, char **units)
{
  int ierr;

  *link=0;
  *name=1;
  *units=NULL;
  *value=NULL;

  switch(n) {
  case 1:
    *value=pcal_freq->pcal_id;
    *link=1;
    break;
  case 2:
    *value=pcal_freq->state;
    break;
  case 3:
    if(pcal_freq->primary==NULL)
      return -1;
    *value=pcal_freq->primary->value;
    *units=pcal_freq->primary->units;
    *name=0;
    break;
  case 4:
    if(pcal_freq->increment==NULL)
      return -1;
    *value=pcal_freq->increment->value;
    *units=pcal_freq->increment->units;
    *name=0;
    break;
  default:
    return -1;
  }
  return 0;
}
static int
get_setup_always_field(Setup_always *setup_always,int n,int *link,
		 int *name, char **value, char **units)
{
  int ierr;

  *link=0;
  *name=1;
  *units=NULL;
  *value=NULL;

  switch(n) {
  case 1:
    *value=setup_always->state;
    break;
  case 2:
    *value=setup_always->time->value;
    *units=setup_always->time->units;
    break;
  default:
    return -1;
  }
  return 0;
}
static int
get_parity_check_field(Parity_check *parity_check,int n,int *link,
		 int *name, char **value, char **units)
{
  int ierr;

  *link=0;
  *name=1;
  *units=NULL;
  *value=NULL;

  switch(n) {
  case 1:
    *value=parity_check->state;
    break;
  case 2:
    *value=parity_check->time->value;
    *units=parity_check->time->units;
    *name=0;
    break;
  default:
    return -1;
  }
  return 0;
}
static int
get_tape_prepass_field(Tape_prepass *tape_prepass,int n,int *link,
		 int *name, char **value, char **units)
{
  int ierr;

  *link=0;
  *name=1;
  *units=NULL;
  *value=NULL;

  switch(n) {
  case 1:
    *value=tape_prepass->state;
    break;
  case 2:
    *value=tape_prepass->time->value;
    *units=tape_prepass->time->units;
    *name=0;
    break;
  default:
    return -1;
  }
  return 0;
}
static int
get_preob_cal_field(Preob_cal *preob_cal,int n,int *link,
		 int *name, char **value, char **units)
{
  int ierr;

  *link=0;
  *name=1;
  *units=NULL;
  *value=NULL;

  switch(n) {
  case 1:
    *value=preob_cal->state;
    break;
  case 2:
    *value=preob_cal->time->value;
    *units=preob_cal->time->units;
    *name=0;
    break;
  case 3:
    *value=preob_cal->name;
    break;
  default:
    return -1;
  }
  return 0;
}
static int
get_midob_cal_field(Midob_cal *midob_cal,int n,int *link,
		 int *name, char **value, char **units)
{
  int ierr;

  *link=0;
  *name=1;
  *units=NULL;
  *value=NULL;

  switch(n) {
  case 1:
    *value=midob_cal->state;
    break;
  case 2:
    *value=midob_cal->time->value;
    *units=midob_cal->time->units;
    *name=0;
    break;
  case 3:
    *value=midob_cal->name;
    break;
  default:
    return -1;
  }
  return 0;
}
static int
get_postob_cal_field(Postob_cal *postob_cal,int n,int *link,
		 int *name, char **value, char **units)
{
  int ierr;

  *link=0;
  *name=1;
  *units=NULL;
  *value=NULL;

  switch(n) {
  case 1:
    *value=postob_cal->state;
    break;
  case 2:
    *value=postob_cal->time->value;
    *units=postob_cal->time->units;
    *name=0;
    break;
  case 3:
    *value=postob_cal->name;
    break;
  default:
    return -1;
  }
  return 0;
}
static int
get_sefd_field(Sefd *sefd,int n,int *link,
		 int *name, char **value, char **units)
{
  int ierr;

  *link=0;
  *name=1;
  *units=NULL;
  *value=NULL;

  switch(n) {
  case 1:
    *value=sefd->if_id;
    *link=1;
    break;
  case 2:
    *value=sefd->flux->value;
    *units=sefd->flux->units;
    *name=0;
    break;
  default:
    if(n < 1 )
      return -1;
    ierr=get_dvalue_list_field(sefd->params,n-2,link,name,
			       value, units);
    if(ierr==-1)
      return -1;
    else if (ierr!=0) {
      fprintf(stderr,"unknown error in get_sefd_field %d\n",ierr);
      exit(1);
    }
  }
  return 0;
}
static int
get_site_position_field(Site_position *site_position,int n,int *link,
		 int *name, char **value, char **units)
{
  int ierr;

  *link=0;
  *name=1;
  *units=NULL;
  *value=NULL;

  switch(n) {
  case 1:
    *value=site_position->x->value;
    *units=site_position->x->units;
    *name=0;
    break;
  case 2:
    *value=site_position->y->value;
    *units=site_position->y->units;
    *name=0;
    break;
  case 3:
    *value=site_position->z->value;
    *units=site_position->z->units;
    *name=0;
    break;
  case 4:
    *value=site_position->epoch->value;
    *units=site_position->epoch->units;
    *name=0;
    break;
  case 5:
    *value=site_position->ref;
    break;
  default:
    return -1;
  }
  return 0;
}
static int
get_ocean_load_vert_field(Ocean_load_vert *ocean_load_vert,int n,int *link,
		 int *name, char **value, char **units)
{
  int ierr;

  *link=0;
  *name=1;
  *units=NULL;
  *value=NULL;

  switch(n) {
  case 1:
    *value=ocean_load_vert->amp->value;
    *units=ocean_load_vert->amp->units;
    *name=0;
    break;
  case 2:
    *value=ocean_load_vert->phase->value;
    *units=ocean_load_vert->phase->units;
    *name=0;
    break;
  default:
    return -1;
  }
  return 0;
}
static int
get_ocean_load_horiz_field(Ocean_load_horiz *ocean_load_horiz,int n,int *link,
		 int *name, char **value, char **units)
{
  int ierr;

  *link=0;
  *name=1;
  *units=NULL;
  *value=NULL;

  switch(n) {
  case 1:
    *value=ocean_load_horiz->amp->value;
    *units=ocean_load_horiz->amp->units;
    *name=0;
    break;
  case 2:
    *value=ocean_load_horiz->phase->value;
    *units=ocean_load_horiz->phase->units;
    *name=0;
    break;
  default:
    return -1;
  }
  return 0;
}
static int
get_source_model_field(Source_model *source_model,int n,int *link,
		 int *name, char **value, char **units)
{
  int ierr;

  *link=0;
  *name=1;
  *units=NULL;
  *value=NULL;

  switch(n) {
  case 1:
    *value=source_model->component->value;
    *units=source_model->component->units;
    *name=0;
    break;
  case 2:
    *value=source_model->band_id;
    *link=1;
    break;
  case 3:
    *value=source_model->flux->value;
    *units=source_model->flux->units;
    *name=0;
    break;
  case 4:
    *value=source_model->majoraxis->value;
    *units=source_model->majoraxis->units;
    *name=0;
    break;
  case 5:
    *value=source_model->ratio->value;
    *units=source_model->ratio->units;
    *name=0;
    break;
  case 6:
    *value=source_model->angle->value;
    *units=source_model->angle->units;
    *name=0;
    break;
  case 7:
    *value=source_model->raoff->value;
    *units=source_model->raoff->units;
    *name=0;
    break;
  case 8:
    *value=source_model->decoff->value;
    *units=source_model->decoff->units;
    *name=0;
    break;
  default:
    return -1;
  }
  return 0;
}
static int
get_vsn_field(Vsn *vsn,int n,int *link,
	      int *name, char **value, char **units)
{
  int ierr;

  *link=0;
  *name=1;
  *units=NULL;
  *value=NULL;

  switch(n) {
  case 1:
    *value=vsn->drive->value;
    *units=vsn->drive->units;
    *name=0;
    break;
  case 2:
    *value=vsn->label;
    break;
  case 3:
    *value=vsn->start;
    *name=0;
    break;
  case 4:
    *value=vsn->stop;
    *name=0;
    break;
  default:
    return -1;
  }
  return 0;
}
static int
get_fanin_def_field(Fanin_def *fanin_def,int n,int *link,
	      int *name, char **value, char **units)
{
  int ierr;

  *link=0;
  *name=1;
  *units=NULL;
  *value=NULL;

  switch(n) {
  case 1:
    *value=fanin_def->subpass;
    break;
  case 2:
    *value=fanin_def->hdstk->value;
    *units=fanin_def->hdstk->units;
    *name=0;
    break;
  case 3:
    *value=fanin_def->track->value;
    *units=fanin_def->track->units;
    *name=0;
    break;
  default:
    if (n <1)
      return -1;
    ierr=get_bitstream_list_field(fanin_def->bitstreams,n-3,link,name,
			       value, units);
    if(ierr==-1)
      return -1;
    else if (ierr!=0) {
      fprintf(stderr,"unknown error in get_fanin_def_field %d\n",ierr);
      exit(1);
    }
  }
  return 0;
}
static int
get_bitstream_list_field(Llist *list,int n,int *link,int *name,
		      char **value, char **units)
{
  int i;

  *link=0;
  *name=1;
  *units=NULL;
  *value=NULL;

  for(i=1; i<=n; i++) {
    if(list==NULL)
      return -1;
    if(i==n) {
      switch(i%2) {
      case 1:
	*value=list->ptr;
	*link=1;
	return 0;
	break;
      case 0:
	*value=list->ptr;
	return 0;
	break;
      default:
	fprintf(stderr,
		"impossible condition 1 in get_bitstream_list_field %d\n",i);
	exit(1);
      }
    }
    list=list->next;
  }
  fprintf(stderr,"impossible condition 2 in get_bitstream_list_field\n");
  return -999;
}
static int
get_fanout_def_field(Fanout_def *fanout_def,int n,int *link,
	      int *name, char **value, char **units)
{
  int ierr;

  *link=0;
  *name=1;
  *units=NULL;
  *value=NULL;

  switch(n) {
  case 1:
    *value=fanout_def->subpass;
    break;
  case 2:
  case 3:
    ierr=get_bitstream_list_field(fanout_def->bitstream,n-1,link,name,
			       value, units);
    if(ierr==-1)
      return -1;
    else if (ierr!=0) {
      fprintf(stderr,"unknown error 1 in get_fanout_def_field %d\n",ierr);
      exit(1);
    }
    break;
  case 4:
    ierr=get_bitstream_list_field(fanout_def->bitstream,n-1,link,name,
			       value, units);
    if(ierr!=-1) {
      fprintf(stderr,"too many bitstreams in get_fanout_def_field\n");
      exit(1);
    } else if (ierr!=0 && ierr!=-1) {
      fprintf(stderr,"unknown error 2 in get_fanout_def_field %d\n",ierr);
      exit(1);
    }
    *value=fanout_def->hdstk->value;
    *units=fanout_def->hdstk->units;
    *name=0;
    break;
  default:
    if(n < 1 )
      return -1;
    ierr=get_dvalue_list_field(fanout_def->tracks,n-4,link,name,
			       value, units);
    if(ierr==-1)
      return -1;
    else if (ierr!=0) {
      fprintf(stderr,"unknown error 3 in get_fanout_def_field %d\n",ierr);
      exit(1);
    }
  }
  return 0;
}
static int
get_vlba_frmtr_sys_trk_field(Vlba_frmtr_sys_trk *vlba_frmtr_sys_trk,int n,
			     int *link, int *name, char **value, char **units)
{
  int ierr;

  *link=0;
  *name=1;
  *units=NULL;
  *value=NULL;

  switch(n) {
  case 1:
    *value=vlba_frmtr_sys_trk->output->value;
    *units=vlba_frmtr_sys_trk->output->units;
    *name=0;
    break;
  case 2:
    *value=vlba_frmtr_sys_trk->use;
    break;
  case 3:
    *value=vlba_frmtr_sys_trk->start->value;
    *units=vlba_frmtr_sys_trk->start->units;
    *name=0;
    break;
  case 4:
    if (vlba_frmtr_sys_trk->stop==NULL)
      return -1;
    *value=vlba_frmtr_sys_trk->stop->value;
    *units=vlba_frmtr_sys_trk->stop->units;
    *name=0;
    break;
  default:
    return -1;
  }
  return 0;
}
static int
get_s2_data_def_field(S2_data_def *s2_data_def,int n,int *link,
	      int *name, char **value, char **units)
{
  int ierr;

  *link=0;
  *name=1;
  *units=NULL;
  *value=NULL;

  switch(n) {
  case 1:
  case 2:
    ierr=get_bitstream_list_field(s2_data_def->bitstream,n,link,name,
				  value, units);
    if(ierr==-1)
      return -1;
    else if (ierr!=0) {
      fprintf(stderr,"unknown error 1 in get_s2_data_def_field %d\n",ierr);
      exit(1);
    }
    break;
  case 3:
    ierr=get_bitstream_list_field(s2_data_def->bitstream,n,link,name,
			       value, units);
    if(ierr!=-1) {
      fprintf(stderr,"too many bitstreams in get_s2_data_def_field\n");
      exit(1);
    } else if (ierr!=0 &ierr!=-1) {
      fprintf(stderr,"unknown error 2 in get_s2_data_def_field %d\n",ierr);
      exit(1);
    }
    *value=s2_data_def->input;
    break;
  default:
    return -1;
  }
  return 0;
}
static int
get_s2_record_mode_field(S2_record_mode *s2_record_mode,int n,int *link,
	      int *name, char **value, char **units)
{
  int ierr;

  *link=0;
  *name=1;
  *units=NULL;
  *value=NULL;

  switch(n) {
  case 1:
    *value=s2_record_mode->mode;
    break;
  case 2:
    *value=s2_record_mode->groups->value;
    *units=s2_record_mode->groups->units;
    *name=0;
    break;
  default:
    if(n < 1 )
      return -1;
    ierr=get_svalue_list_field(s2_record_mode->inputs,n-2,link,name,value,
			       units);
    if(ierr==-1)
      return -1;
    else if (ierr!=0) {
      fprintf(stderr,"unknown error in get_record_mode_field %d\n",ierr);
      exit(1);
    }
  }
  return 0;
}
static int
get_dvalue_field(Dvalue *dvalue,int n,int *link,int *name,char **value,
		   char **units)
{
  int ierr;

  *link=0;
  *name=0;
  *units=NULL;
  *value=NULL;

  switch(n) {
  case 1:
    *value=dvalue->value;
    *units=dvalue->units;
    break;
  default:
    return -1;
  }
  return 0;
}
static int
get_dvalue_list_field(Llist *list,int n,int *link,int *name,
		      char **value, char **units)
{
  int i;

  *link=0;
  *name=0;
  *units=NULL;
  *value=NULL;

  for(i=1; i<=n; i++) {
    if(list==NULL)
      return -1;
    if(i==n) {
      *value=((Dvalue *) list->ptr)->value;
      *units=((Dvalue *) list->ptr)->units;
      return 0;
    }
    list=list->next;
  }

  fprintf(stderr,"impossible condition in get_dvalue_list_field\n");
  return -999;
}
static int
get_svalue_field(char *svalue,int n,int *link,int *name, char **value,
		   char **units)
{
  int ierr;

  *link=0;
  *name=1;
  *units=NULL;
  *value=NULL;

  switch(n) {
  case 1:
    *value=svalue;
    
    break;
  default:
    if(n != 1 )
      return -1;
  }
  return 0;
}
static int
get_svalue_list_field(Llist *list,int n,int *link,int *name,
		      char **value, char **units)
{
  int i;

  *link=0;
  *name=0;
  *units=NULL;
  *value=NULL;

  for(i=1; i<=n; i++) {
    if(list==NULL)
      return -1;
    if(i==n) {
      *value=(char *) list->ptr;
      return 0;
    }
    list=list->next;
  }
  fprintf(stderr,"impossible condition in get_svalue_list_field\n");
  return -999;
}
static int
get_date_field(char *date,int n,int *link, int *name, char **value,
		   char **units)
{
  int ierr;

  *link=0;
  *name=0;
  *units=NULL;
  *value=NULL;

  switch(n) {
  case 1:
    *value=date;
    
    break;
  default:
    if(n != 1 )
      return -1;
  }
  return 0;
}
static int
get_time_field(char *time,int n,int *link, int *name, char **value,
		   char **units)
{
  int ierr;

  *link=0;
  *name=0;
  *units=NULL;
  *value=NULL;

  switch(n) {
  case 1:
    *value=time;
    
    break;
  default:
    if(n != 1 )
      return -1;
  }
  return 0;
}
static int
get_angle_field(char *angle,int n,int *link, int *name, char **value,
		   char **units)
{
  int ierr;

  *link=0;
  *name=0;
  *units=NULL;
  *value=NULL;

  switch(n) {
  case 1:
    *value=angle;
    
    break;
  default:
    if(n != 1 )
      return -1;
  }
  return 0;
}
