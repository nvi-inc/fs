      subroutine dprox(luop,idebug,idata,ilog,iblk,ibuf,nbytes,ipar,
     . icrcc,ltime,ischar,ksplit)
C 
C     ROUTINE TO GET TIME AND CHECK SYNC WORD FROM RAW DATA BLOCK 
C     IF APPROPRIATE
C 
C     ON ENTRY--
C       LUOP,    OPERATOR LU
C       IDATA,   BUFFER OF DATA TO BE PROCESSED 
C       ILOG,    #CHARS IN IDATA
C       IBLK,    BLOCK# ASSOCIATED WITH IDATA 
C       IBUF,    SCRATCH BUFFER OF MINIMUM LENGTH 625 WORDS 
C 
C     ON RETURN-- 
C       NBYTES,  #BYTES 
C       IPAR,    #PARITY ERROR DETECTED IN IDATA
C       ICRCC,   SYNC-BLOCK CRCC ERROR FLAG 
C                 1 - SYNC BLOCK PRESENT WITH NO CRCC ERROR 
C                 0 - NO SYNC BLOCK IN DATA 
C                -1 - CRCC ERROR IN SYNC BLOCK
C       LTIME    8-WORD ASCII ARRAY CONTAINING DECODED PRINTABLE TIME,
C                IF AVAILABLE.
C       ISCHAR,  CHARACTER # WITHIN IDATA AT WHICH SYNC BLOCK BEGINS, 
C                IF SYNC BLOCK FULLY CONTAINED WITHIN IDATA (I.E. ICRCC<>0) 
C 
C     ARW 790724  MODIFIED NRV 800222 
C     MODIFIED MAH DEC '81
C 
      logical ksplit,kbit
      integer itabl(256)
      integer*2 ibuf(1),idata(1),istate,mask,isync(10),idum,jstate
      integer*2 ltime(8)
C 
      nbytes=0
      ipar=0
      if (ilog .le. 0) return 
C 
      if (.not.ksplit) goto 99
      call bsplt(idata,ilog)
      goto 180
C 
99    abit=iblk*4096. 
C     COMPUTE BIT# (IN IDATA) OF FIRST FULL BYTE IN IDATA (STARTING AT BIT#0) 
      ibit=9.-amod(abit,9.) 
      if (ibit .eq. 9) ibit=0 
C     COMPUTE FRAME# (WITHIN DATA BUFFER) IN WHICH THIS BIT OCCURS
      iframe=(abit+ibit)/22500. 
C     COMPUTE BYTE# WITHIN FRAME
      ibyte=amod((abit+ibit)/9.,2500.)
      nbytes=(ilog*8-ibit)/9
      if(idebug.gt.1)write(luop,9100) abit,iblk,ibit,iframe,ibyte,nbytes 
9100  format(/"abit,iblk,ibit,iframe,ibyte,nbytes=",/,f12.1,5i6)
C 
C 
C     CHECK IF COMPLETE SYNC BLOCK IS PRESENT WITHIN IDATA
      icrcc=0 
      ischar = 0
      if ((ibyte.eq.0.or.ibyte+nbytes.ge.2520).and.nbytes.ge.20) then
        goto 150
      else
        goto 180
      end if
150   continue
      call tabgn(itabl) 
C     SQUEEZE OUT PARITY BITS AND COUNT PARITY ERRORS 
      iwbit=ibit+1
      jwbyt=1 
      call sqish(idata,iwbit,ibuf,jwbyt,nbytes,ipar,itabl)
      if (idebug.lt.2) goto 120 
      write(luop,9110)nbytes,ipar 
9110  format("squished data, nbytes="i5", #pe="i5)
      do i=1,nbytes 
        l=jchar(ibuf,i) 
        l=ih22a(l) 
C                   Convert from hex bits to ASCII for printing 
        write(luop,9120) l
9120    format(1x,a2," ",$)
      enddo
C 
120   continue
      jbyt=mod(2500-ibyte,2500) 
      ischar=jbyt+1 
C     MOVE SYNC BLOCK TO SEPARATE BUFFER
      call ichmv(isync,1,ibuf,ischar,20)
C     DECODE TIME 
      do i=1,8
        ltime(i)=ih22a(jchar(isync,i+12)) 
      enddo
      ltime(7)=iand(ltime(7),o'177400') 
      ltime(8)=0
      call char2hol(' ',ltime,14,16)
      n=12
      mask=o'7003'
      istate=0
      idbit=1 
      nbits=148 
      call crcc(n,mask,istate,isync,idbit,nbits,idum,0) 
C     REVERSE ORDER OF BITS IN ISYNC TO compare to ISTATE
      jstate=0
      do i=1,12 
        call sbit(jstate,i,igetb(isync(10),4+i))
      enddo
C     COMPARE WITH CRC CHARACTER IN ISYNC 
      icrcc=1 
      if (iand(istate,o'7777').ne.iand(jstate,o'7777')) icrcc=-1 
      if(idebug.gt.0) write(luop,9130) ischar,icrcc
9130  format(/"ischar,icrcc=",2i6)
      call ifill(ibuf,1,nbytes,o'377')
      call ifill(ibuf,ischar,20,0)
180   continue
C 
      return
      end 
