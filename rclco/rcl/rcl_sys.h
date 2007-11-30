#ifndef RCL_SYS_DEFD
#define RCL_SYS_DEFD

/*
 * This header file applies to two versions of the 'rcl_sys' routine:
 *   rcl_syss.c   --RCL system-dependent serial port handling code.
 *   rcl_sysn.c   --RCL system-dependent network socket handling code.
 */


int rcl_portinit(void);
int rcl_portshutdown(void);

#ifdef UNIX
int rcl_open(const char* hostname, int* addr, char* errmsg);
int rcl_close(int addr);
#endif 

int rcl_setbaud(int baudrate);

int rcl_delay(int msec);

int rcl_getch(int addr, unsigned char* c);
ibool rcl_checkch(int addr);

int rcl_putch(int addr, unsigned char c);
int rcl_flushout(int addr);

#ifdef UNIX
void rcl_open_list(int* num, int addrs[]);
const char* rcl_addr_to_hostname(int addr);
#endif

#endif /* RCL_SYS_DEFD */
