#ifndef RCL_PKT_DEFD
#define RCL_PKT_DEFD


int rcl_init(void);

int rcl_shutdown(void);

int rcl_getchar(int addr, unsigned char* c, int timeout);

int rcl_putchar(int addr, unsigned char c);

void rcl_clearbuf(int addr);

int rcl_packet_read(int addr, int* code, char* data, int maxlength,
                    int* length, int timeout);

int rcl_packet_write(int addr, int code, const char* data, int length);



#endif /* not RCL_PKT_DEFD */
