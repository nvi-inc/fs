	SUBROUTINE B3OF9(ICHAR,IBUF,LLBUF,IBYTE,PARMS,LSPACE)
C     Bar code on Epson MX-80/MX-100/HP82905B
C      (original version by ARW 830812)
C NRV 950829 for linux use iishft and and
C
C     Assemble the graphics data to print ICHAR in 3-of-9 barcode,
C     starting at character IBYTE in IBUF and using the parameters
C     in  PARMS.
C
C     On entry:
C         ICHAR,  code of character to be assembled (1-45).
C                 Assumed to be valid.
C         IBUF,   buffer in which code is to be assembled.
C         LLBUF,  length if IBUF (bytes)
C         IBYTE,  first byte of IBUF to be used
C         PARMS,  bar/space width parameters
C         LSPACE, if .TRUE., leading narrow space is inserted before
C                 character
C
C     On return:
C         IBUF,   has specified character added as graphics data
C         IBYTE,  updated to point one byte beyond last byte used
C
	IMPLICIT none
	INTEGER CODE(2,45),bar,space
        integer PARMS(4),llbuf
        integer*2 IBUF(1)
        integer ibyte,ichar,i,ns,j,idum,ip,ichmv
        integer*4 jishft
	LOGICAL LSPACE
	integer*2 ZFF,zero
	data ZFF/Z'FF'/,zero/0/
C      DATA CODE/06B,04B,21B,04B,11B,04B,30B,04B,05B,04B,   !01234
c     .          24B,04B,14B,04B,03B,04B,22B,04B,12B,04B,   !56789
c     .          21B,02B,11B,02B,30B,02B,05B,02B,24B,02B,   !ABCDE
c     .          14B,02B,03B,02B,22B,02B,12B,02B,06B,02B,   !FGHIJ
c     .          21B,01B,11B,01B,30B,01B,05B,01B,24B,01B,   !KLMNO
c     .          14B,01B,03B,01B,22B,01B,12B,01B,06B,01B,   !PQRST
c     .          21B,10B,11B,10B,30B,10B,05B,10B,24B,10B,   !UVWXY
c     .          14B,10B,03B,10B,22B,10B,12B,10B,           !Z-.<space>
c     .          00B,16B,00B,15B,00B,13B,00B,07B,           !$/+%
c     .          06B,10B,06B,10B/                           !<> (start/stop)
	data code/6,4,17,4,9,4,24,4,5,4,
     .          20,4,12,4,3,4,18,4,10,4,
     .          17,2,9,2,24,2,5,2,20,2,
     .          12,2,3,2,18,2,10,2,6,2,
     .          17,1,9,1,24,1,5,1,20,1,
     .          12,1,3,1,18,1,10,1,6,1,
     .          17,8,9,8,24,8,5,8,20,8,
     .          12,8,3,8,18,8,10,8,
     .          0,14,0,13,0,11,0,7,
     .          6,8,6,8/
C
	BAR=CODE(1,ICHAR)
	SPACE=CODE(2,ICHAR)
	DO I=1,5
C       Space
	  IF (I .EQ. 1) THEN ! Intercharacter leading space
	    IF (LSPACE) THEN
		NS=PARMS(4)*3/2
		DO J=1,NS
		  idum = ichmv(ibuf,ibyte,zero,1,1)
		  IBYTE=IBYTE+1
		enddo
	    ENDIF
	  ELSE
	    IP=4-AND(jISHFT(SPACE,I-5),1)    !3-wide space, 4-narrow space
	    DO J=1,PARMS(IP)
		idum = ichmv(ibuf,ibyte,zero,1,1)
		IBYTE=IBYTE+1
	    enddo
	  ENDIF
C
C     Bar
	  IP=2-AND(jISHFT(BAR,I-5),1)     !1-Wide bar, 2-Narrow bar
	  DO J=1,PARMS(IP)
	    idum = ichmv(ibuf,ibyte,ZFF,1,2)
	    IBYTE=IBYTE+1
	  enddo
	enddo
C
	RETURN
	END

