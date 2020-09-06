int open_mcast(char mcast_addr[], int mcast_port, char mcast_if[], int *error_no);
int get_if_addr(char *name, char **address, int *error_no);
size_t read_mcast(int sock, char buf[], size_t buf_size);
void log_mcast(dbbc3_ddc_multicast_t *packet);
