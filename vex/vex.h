/* structure declarations */

struct llist {
  struct llist *next;
  void *ptr;
};

typedef struct llist Llist;

struct vex {
  struct llist *version;
  struct llist *blocks;
};

typedef struct vex Vex;

struct block {
  int block;
  struct llist *items;
};

struct qref {
  int primitive;
  char *name;
  struct llist *qualifiers;
};

typedef struct qref Qref;

struct def {
  char *name;
  struct llist *refs;
};

typedef struct def Def;

struct dvalue {
  char *value;
  char *units;
};

typedef struct dvalue Dvalue;

struct lowl {
  int statement;
  void *item;
};

typedef struct lowl Lowl;

struct chan_def {
  char *band_id;
  char *polar;
  struct dvalue *sky_freq;
  char *net_sb;
  struct dvalue *bw;
  char *chan_id;
  char *bbc_id;
  char *pcal_id;
  struct llist *states;
};

typedef struct chan_def Chan_def;

struct external {
  char *file;
  int primitive;
  char *name;
};

struct switching_cycle {
  char *origin;
  struct llist *periods;
};

typedef struct switching_cycle Switching_cycle;

struct station {
  char *key;
  struct dvalue *start;
  struct dvalue *stop;
  struct dvalue *start_pos;
  char *pass;
  char *sector;
  struct llist *drives;
};
	
typedef struct station Station;

struct axis_type {
  char *axis1;
  char *axis2;
};

typedef struct axis_type Axis_type;

struct ant_motion {
  char *axis;
  struct dvalue *rate;
  struct dvalue *offset;
};

typedef struct ant_motion Ant_motion;

struct pointing_sector {
  char *sector;
  char *axis1;
  struct dvalue *lolimit1;
  struct dvalue *hilimit1;
  char *axis2;
  struct dvalue *lolimit2;
  struct dvalue *hilimit2;
};

typedef struct pointing_sector Pointing_sector;

struct bbc_assign {
  char *bbc_id;
  struct dvalue *physical;
  char *if_id;
};

typedef struct bbc_assign Bbc_assign;

struct headstack {
  struct dvalue *stack;
  char *type;
  char *drive_id;
};

typedef struct headstack Headstack;

struct data_source {
  char *source;
  char *input[8];
};

typedef struct data_source Data_Source;

struct tape_motion {
  char *type;
  struct dvalue *early;
};

typedef struct tape_motion Tape_Motion;

struct headstack_pos {
  struct dvalue *index;
  struct llist *positions;
};

typedef struct headstack_pos Headstack_pos; 

struct if_def {
  char *if_id;
  struct dvalue *lo;
  char *sb;
};

typedef struct if_def If_def; 

struct pcal_freq {
  char *pcal_id;
  char *state;
  struct dvalue *primary;
  struct dvalue *increment;
};

typedef struct pcal_freq Pcal_freq; 

struct setup_always {
  char *state;
  struct dvalue *time;
};

typedef struct setup_always Setup_always; 

struct parity_check {
  char *state;
  struct dvalue *time;
};

typedef struct parity_check Parity_check; 

struct tape_prepass {
  char *state;
  struct dvalue *time;
};

typedef struct tape_prepass Tape_prepass; 

struct preob_cal {
  char *state;
  struct dvalue *time;
  char *name;
};

typedef struct preob_cal Preob_cal; 

struct midob_cal {
  char *state;
  struct dvalue *time;
  char *name;
};

typedef struct midob_cal Midob_cal; 

struct postob_cal {
  char *state;
  struct dvalue *time;
  char *name;
};

typedef struct postob_cal Postob_cal; 

struct sefd {
  char *if_id;
  struct dvalue *flux;
  struct llist *params;
};

typedef struct sefd Sefd;

struct site_position {
  struct dvalue *x;
  struct dvalue *y;
  struct dvalue *z;
  struct dvalue *epoch;
  char *ref;
};

typedef struct site_position Site_position;

struct ocean_load_vert {
  struct dvalue *amp;
  struct dvalue *phase;
};

typedef struct ocean_load_vert Ocean_load_vert;

struct ocean_load_horiz {
  struct dvalue *amp;
  struct dvalue *phase;
};

typedef struct ocean_load_horiz Ocean_load_horiz;

struct source_model {
  struct dvalue *component;
  char *band_id;
  struct dvalue *flux;
  struct dvalue *majoraxis;
  struct dvalue *ratio;
  struct dvalue *angle;
  struct dvalue *raoff;
  struct dvalue *decoff;
};

typedef struct source_model Source_model;

struct vsn {
  struct dvalue *drive;
  char *label;
  char *start;
  char *stop;
};

typedef struct vsn Vsn;

struct fanin_def {
  char *subpass;
  struct dvalue *hdstk;
  struct dvalue *track;
  struct llist *bitstreams;
};

typedef struct fanin_def Fanin_def;

struct fanout_def {
  char *subpass;
  struct llist *bitstream;
  struct dvalue *hdstk;
  struct llist *tracks;
};

typedef struct fanout_def Fanout_def;

struct vlba_frmtr_sys_trk {
  struct dvalue *output;
  char *use;
  struct dvalue *start;
  struct dvalue *stop;
};

typedef struct vlba_frmtr_sys_trk Vlba_frmtr_sys_trk;

struct s2_data_def {
  struct llist *bitstream;
  char *input;
};

typedef struct s2_data_def S2_data_def;

/* prototypes */

struct llist     *add_list(struct llist *start,void *ptr);
struct llist     *ins_list(void *ptr, struct llist *start);
struct qref      *make_qref(int primitive,char *name,struct llist *qualifiers);
struct def       *make_def(char *name, struct llist *refs);
struct block     *make_block(int block,struct llist *items);
struct vex *make_vex(struct llist *version, struct llist *blocks);
struct lowl 	 *make_lowl(int statement,void *items);
struct chan_def  *make_chan_def(char *band_id, char *polar,
				struct dvalue *sky_freq, char *net_sb,
				struct dvalue *bw, char *chan_id, char *bbc_id,
				char *pcal_id, struct llist *states);
struct dvalue *make_dvalue(char *value, char *units);
struct external *make_external(char *file, int primitive, char *name);
struct switching_cycle *make_switching_cycle(char *origin,
					     struct llist *periods);
struct station  *make_station(char *key, struct dvalue *start,
			      struct dvalue *stop, struct dvalue *start_pos,
			      char *pass, char *sector, struct llist *drives);
struct axis_type *make_axis_type(char *axis1, char *axis2);
struct ant_motion *make_ant_motion(char *axis,struct dvalue *rate,
				   struct dvalue *offset); 
struct pointing_sector *make_pointing_sector(char *sector, char *axis1,
					     struct dvalue *lolimit1,
					     struct dvalue *hilimit1,
					     char *axis2,
					     struct dvalue *lolimit2,
					     struct dvalue *hilimit2);
struct bbc_assign *make_bbc_assign(char *bbc_id,struct dvalue *physical,
				   char *if_id);
struct headstack *make_headstack(struct dvalue *stack,char *type,
				 char *drive_id);
struct data_source *make_data_source(char *source,char *input1, char *input2,
				     char *input3, char *input4, char *input5,
				     char *input6, char *input7, char *input8);
struct tape_motion *make_tape_motion(char *type, struct dvalue *early);
struct headstack_pos *make_headstack_pos(struct dvalue *index,
					 struct llist *positions);
struct if_def *make_if_def(char *if_id, struct dvalue *lo, char *sb);
struct pcal_freq *make_pcal_freq(char *pcal_id,char *state,
				 struct dvalue *primary,
				 struct dvalue *increment);
struct setup_always *make_setup_always(char *state, struct dvalue *time);
struct parity_check *make_parity_check(char *state, struct dvalue *time);
struct tape_prepass *make_tape_prepass(char *state, struct dvalue *time);
struct preob_cal *make_preob_cal(char *state, struct dvalue *time,
				 char *name);
struct midob_cal *make_midob_cal(char *state, struct dvalue *time,
				 char *name);
struct postob_cal *make_postob_cal(char *state, struct dvalue *time,
				 char *name);
struct sefd *make_sefd(char *if_id, struct dvalue *flux, struct llist *params);
struct site_position *make_site_position(struct dvalue *x, struct dvalue *y,
					 struct dvalue *z,
					 struct dvalue *epoch, char *ref);
struct ocean_load_vert *make_ocean_load_vert(struct dvalue *amp,
					     struct dvalue *phase);
struct ocean_load_horiz *make_ocean_load_horiz(struct dvalue *amp,
					       struct dvalue *phase);
struct source_model *make_source_model(struct dvalue *component,
				       char *band_id, struct dvalue *flux,
				       struct dvalue *majoraxis,
				       struct dvalue *ratio,
				       struct dvalue *angle,
				       struct dvalue *raoff,
				       struct dvalue *decoff);
struct vsn *make_vsn(struct dvalue *drive, char *label, char *start,
		     char *stop);
struct fanin_def *make_fanin_def(char *subpass, struct dvalue *hdstk,
				 struct dvalue *track,
				 struct llist *bitstreams);
struct fanout_def *make_fanout_def(char *subpass, struct llist *bitstream,
				   struct dvalue *hdstk, struct llist *tracks);
struct vlba_frmtr_sys_trk *make_vlba_frmtr_sys_trk(struct dvalue *output,
						   char *use,
						   struct dvalue *start,
						   struct dvalue *stop);
struct s2_data_def *make_s2_data_def(struct llist *bitstream,char *input);

int
lowl2int(char *lowl);

int
block2int(char *block);

char *
int2lowl(int lowl);

char *
int2block(int block);

int
vex_field(int statement,void *ptr,int i,int *link,int *name, char **value,
	  char **units);

void print_vex(struct vex *vex);
void print_vex_blocks(struct llist *blocks);
void print_block_name(int block);
void print_qref_block(struct llist *items);
void print_qualifiers(struct llist *items);
void print_lowl(struct llist *items);
void print_lowl_st(int statement, void *ptr);

void print_def_block(struct llist *items, void func());
void print_external(struct external *this);

void print_svalue(char *svalue);

void print_literal_list(struct llist *svalues);

void print_comment(char *comment);
void print_comment_trailing(char *comment_trailing);

char *
get_source_def_next();

char *
get_source_def(struct vex *vex_in);

char *
get_mode_def_next();

char *
get_mode_def(struct vex *vex_in);

char *
get_station_def_next();

char *
get_station_def(struct vex *vex_in);

void *
get_all_lowl_next();

void *
get_all_lowl(char *station, char *mode, int statement,
	     int primitive, struct vex *vex_in);

void *
get_mode_lowl(char *station_in, char *mode_in, int statement,
	      int primitive, struct vex *vex_in);
void *
get_mode_lowl_next();

void *
get_station_lowl(char *station_in, int statement_in,
	      int primitive_in, struct vex *vex_in);

void *
get_station_lowl_next();

void *
get_source_lowl(char *source_in, int statement_in, struct vex *vex_in);

void *
get_source_lowl_next();

void *
get_global_lowl(int primitive_in, int statement_in, struct vex *vex_in);

void *
get_global_lowl_next();

struct llist *
find_block(int block,struct vex *vex);

struct llist *
find_def(struct llist *defs,char *mode);

struct llist *
find_lowl(struct llist *lowls,int statement);

void *
get_scan_start(Llist *lowls);

void *
get_scan_mode(Llist *lowls);

void *
get_scan_source_next();

void *
get_scan_source(Llist *lowls_scan_in);

void *
get_scan_station_next(Llist **lowls_scan);

void *
get_scan_station(Llist **lowls_scan, char *station_in,
		 struct vex *vex_in);

Llist *
find_next_def(Llist *defs);

int vex_open(char *name, struct vex **vex);




