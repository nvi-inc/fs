/* header file for ds SNAP command data structure etc.*/

#define DS_MON	0	/* AT_DS monitor request - see ds_cmd.type */
#define DS_CMD	1	/* AT_DS command request */

struct ds_cmd {	/* Standard ds SNAP command structure */
    unsigned short type;	/* command type : 0=MON, 1=CMD */
    char mnem[3];		/* dataset mnemonic: 2 chars */
    unsigned short cmd;		/* dataset command: 0..511 */
    unsigned short data;	/* data for AT_DS CMD request */
};

#pragma pack(1)
struct ds_mon {	/* Standard ds SNAP response structure */
    unsigned short resp;		/* response type ACK/BEL/NAK/NUL */
    union ds_ret {
        unsigned short value;		/* monitor response data */
        struct regs {
            unsigned char error;	/* error register response */
            unsigned char warning;	/* warning register response */
        } reg;
    } data;
};
#pragma pack()
