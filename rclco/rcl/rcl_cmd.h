#ifndef RCL_CMD_DEFD
#define RCL_CMD_DEFD


/* RCL commands */

int rcl_ping(int addr, int timeout);
int rcl_stop(int addr);
int rcl_play(int addr);
int rcl_record(int addr);
int rcl_rewind(int addr);
int rcl_ff(int addr);
int rcl_pause(int addr);
int rcl_unpause(int addr);
int rcl_eject(int addr);
int rcl_state_read(int addr, int* rstate);

int rcl_speed_set(int addr, int speed);
int rcl_speed_read(int addr, int* speed);
int rcl_speed_read_pb(int addr, int* speed);

int rcl_time_set(int addr, int year, int day, int hour, int min, int sec);
int rcl_time_read(int addr, int* year, int* day, int* hour, int* min,
                  int* sec, ibool* validated);
int rcl_time_read_pb(int addr, int* year, int* day, int* hour, int* min,
                     int* sec, ibool* validated);

int rcl_mode_set(int addr, const char* mode);
int rcl_mode_read(int addr, char* mode);

int rcl_tapeid_set(int addr, const char* tapeid);
int rcl_tapeid_read(int addr, char* tapeid);
int rcl_tapeid_read_pb(int addr, char* tapeid);

int rcl_user_info_set(int addr, int fieldnum, ibool label,
                      const char* user_info);
int rcl_user_info_read(int addr, int fieldnum, ibool label, char* user_info);
int rcl_user_info_read_pb(int addr, int fieldnum, ibool label, char* user_info);

int rcl_user_dv_set(int addr, ibool user_dv, ibool pb_enable);
int rcl_user_dv_read(int addr, ibool* user_dv, ibool* pb_enable);
int rcl_user_dv_read_pb(int addr, ibool* user_dv);

int rcl_group_set(int addr, int newgroup);
int rcl_group_read(int addr, int* group, int* num_groups);

int rcl_tapeinfo_read_pb(int addr, unsigned char* table);

int rcl_delay_set(int addr, ibool relative, long int nanosec);
int rcl_delay_read(int addr, long int* nanosec);
int rcl_delaym_read(int addr, long int* nanosec);

int rcl_errmes(int addr, long int error);

int rcl_align_abs(int addr, int year, int day, int hour, int min, int sec,
                  long int nanosec);
int rcl_align_rel(int addr, ibool negative, int hour, int min, int sec,
                  long int nanosec);
int rcl_align_realign(int addr);
int rcl_align_selfalign(int addr);

int rcl_position_set(int addr, int code, long int position);
int rcl_position_set_ind(int addr, int code, long int position[]);
int rcl_position_reestablish(int addr);
int rcl_position_read(int addr, long int* position, long int* posvar);
int rcl_position_read_ind(int addr, int* num_entries, long int position[]);

int rcl_esterr_read(int addr, ibool order_chantran, int* num_entries,
                    char* esterr_list);
int rcl_pdv_read(int addr, ibool order_chantran, int* num_entries,
                 char* pdv_list);

int rcl_scpll_mode_set(int addr, int scpll_mode);
int rcl_scpll_mode_read(int addr, int* scpll_mode);

int rcl_tapetype_set(int addr, const char* tapetype);
int rcl_tapetype_read(int addr, char* tapetype);

int rcl_station_info_read(int addr, int* station, long int* serialnum,
                          char* nickname);

int rcl_consolecmd(int addr, const char* command);

int rcl_postime_read(int addr, int tran, int* year, int* day, int* hour,
                     int* min, int* sec, int* frame, long int* position);

int rcl_status(int addr, int* summary, int* num_entries,
               unsigned char* status_list);
int rcl_status_detail(int addr, int stat_code, ibool reread,
                      ibool shortt, int* summary, int* num_entries,
                      unsigned char* status_det_list);
int rcl_status_decode(int addr, int stat_code, ibool shortt, char* stat_msg);

int rcl_error_decode(int addr, int err_code, char* err_msg);

int rcl_version(int addr, char* version);

/* HIDDEN */
int rcl_general_cmd(int addr, int cmd_code, const char* cmd_data,
                    int cmd_length, int* resp_code, char* resp_data,
                    int resp_maxlength, int* resp_length, int timeout);

int rcl_simple_cmd(int addr, int cmd_code, const char* cmd_data,
                   int cmd_length, int timeout);


#endif /* not RCL_CMD_DEFD */
