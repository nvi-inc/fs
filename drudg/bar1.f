	SUBROUTINE BAR1(JBUF,IC1,IC2,IBUF,LLBUF,IBYTE,PARMS)

C     Bar code on Epson MX-80/MX-100/HP82905B
C     (original version by ARW 830812)
C
C     Generate graphics buffer for text string between characters
C     IC1 and IC2 in JBUF.
C
C     On entry:
C         JBUF,   input buffer
C         IC1,    start of text in JBUF (char# of '<')
C         IC2,    end of text in JBUF (char# of '>')
C         IBUF,   buffer for barcode graphics data
C         LLBUF,  length of IBUF (bytes)
C         IBYTE,  current byte count in IBUF
C         PARMS,  bar code parameters
C
C     On return:
C         IBUF,   graphics output buffer
C         IBYTE,  current byte count (points to next byte in IBUF)
C
	IMPLICIT none
	INTEGER PARMS(1)
        integer ic1,ic2,llbuf,ibyte
	LOGICAL LSPACE
	integer*2 jbuf(7),ibuf(*),ic,nbmod,nb2
        integer ip,idum,i,nb,ichmv,ichmv_ch,ibyte1
	character*1 cx
	character*46 cCHAR
	DATA cCHAR/'0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ-. $/+%<> '/
C
C     Set up the preliminaries
	idum = ichmv_ch(ibuf,ibyte,char(27))  !<esc>
	IBYTE=IBYTE+1
	idum = ichmv_ch(ibuf,ibyte,'L')
	IBYTE=IBYTE+3   !Leave space for N1,N2
	IBYTE1=IBYTE
C
C     Create bar code for text
	LSPACE=.FALSE.
	DO I=IC1,IC2
	  idum = ichmv(ic,1,jbuf,i,1)
	  call hol2char(ic,1,1,cx)
	  if (cx.eq.',') cx = ' '
	  ip = index(cchar,cx)
	  CALL B3OF9(IP,IBUF,LLBUF,IBYTE,PARMS,LSPACE)
	  LSPACE=.TRUE.
	enddo
	NB=IBYTE-IBYTE1             !#graphics bytes
        nbmod=mod(nb,256)
        nb2=nb/256
        idum = ichmv(ibuf,ibyte-nb-2,nbmod,1,1) !N1
        idum = ichmv(ibuf,ibyte-nb-1,nb2,1,1)      !N2
Cidum = ichmv(ibuf,ibyte-nb-2,mod(nb,256),1,1) !N1
Cidum = ichmv(ibuf,ibyte-nb-1,nb/256,1,1)      !N2
C
	return
	END
