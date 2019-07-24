      subroutine wx(ip)
C  weather module c#870115:04:36#
C 
C 1.1.   WX controls the weather module 
C 
C     INPUT VARIABLES:
      dimension ip(1) 
C        IP(1)  - class number of input parameter buffer. 
C 
C     OUTPUT VARIABLES: 
C        IP(1) - error
C        IP(2) - class
C        IP(3) - number of records
C        IP(4) - who we are 
C 
C 2.2.   COMMON BLOCKS USED 
      include '../include/fscom.i'
C 
C 2.5.   SUBROUTINE INTERFACE:
C     CALLING SUBROUTINES: QUIKR
C     CALLED SUBROUTINES: GTPRM
C 
C 3.  LOCAL VARIABLES 
C        NCHAR  - number of characters in buffer
C        IMMODE - mode for MAT
C        ICH    - character counter 
      integer*2 ibuf2(40),ibuf(20)             !  class buffers
      integer*2 lchar(4)
      dimension iparm(2)           !  parameters returned from gtprm
      dimension ireg(2)       !  registers from exec calls
      integer get_buf
      character cjchar
      equivalence (reg,ireg(1)),(parm,iparm(1)) 
C 
C 5. INITIALIZED VARIABLES
      data ilen/40/,ilen2/80/          !  lengths of class buffers
      data il/10/,lchar/2h+ ,2h% ,2h! ,2h? /
C 
C 6.  PROGRAMMER: NRV 
C     LAST MODIFIED:  800315
C 
C     PROGRAM STRUCTURE 
C 
C   1. We have been requested to read the WX module.
C 
      iclcm = ip(1) 
      do i=1,3
        ip(i) = 0
      enddo
      call char2hol('qx',ip(4),1,2)
      if (iclcm.eq.0) then
        ip(3) = -1
        return
      endif
      ireg(2) = get_buf(iclcm,ibuf2,-ilen2,idum,idum)
      nchar = ireg(2) 
      ieq = iscn_ch(ibuf2,1,nchar,'=')
      if (ieq.ne.0) then
        ip(3) = -1              !  it is an error to specify parameters
        return
      endif
C 
C     2. Fill up a request for the three numbers: + (temp), % (humidity), 
C     and ! (pressure). 
C 
      call char2hol('wx',ibuf(2),1,2)
      nch = 5 
      nrec = 1
      ibuf(1) = 8 
      do i=1,3
        iclass = 0
        ibuf(3) = lchar(i)
        call put_buf(iclass,ibuf,-nch,2hfs,0)
        call run_matcn(iclass,nrec)
        call rmpar(ip)
        if(ip(3).lt.0) return 
        iclass = 0
        call susp(2,1)
        ibuf(3) = lchar(4)
        call put_buf(iclass,ibuf,-nch,2hfs,0)
        call run_matcn(iclass,nrec)
        call rmpar(ip)
        iclass = ip(1)
        if(ip(3).lt.0) return 
        ireg(2) = get_buf(iclass,ibuf(i*5+1),-il,idum,idum)
      enddo
C 
C     4. Now decode the message to get temp, humid, pres. 
C     The temperature buffer: 
C                   WX000atttt   (in degrees C*10)
C     where a=B for t>0, a=C for t<0. 
C     The humidity buffer:
C                   WX00000hhh   (in percent*10)
C     The pressure buffer:
C                   WX000Ppppp   (in mbars*10)
C     If the response is FFFFF, the instrument is down. 
C     After conversion, store parameters in common. 
C 
      tempwx = das2b(ibuf,17,4,ierr)/10.0 
      if (cjchar(ibuf,16).eq.'C') tempwx = -tempwx  
      if (ierr.ne.0) then
        ierr = -301
        tempwx = 1.0E10
      endif
      humiwx = das2b(ibuf,27,4,ierr)/10.0
      if (ierr.ne.0) then
        ierr = -302
        humiwx = 1.0E10
      endif
C     The additional .001 is to fix the problem of 1000.0 
C     which IR2AS doesn't handle properly.
      preswx = das2b(ibuf,36,5,ierr)/10.0  + .001
      if (ierr.ne.0) then
        ierr = -303
        preswx = 1.0E10
      endif
C 
C     5. Finally, code up the message for BOSS and the display and log. 
C 
      nch = ichmv(ibuf2,nchar+1,2h/ ,1,1)
      nch = nch + ir2as(tempwx,ibuf2,nch,5,1) 
      nch = mcoma(ibuf2,nch)
      nch = nch + ir2as(preswx,ibuf2,nch,7,1) 
      nch = mcoma(ibuf2,nch)
      nch = nch + ir2as(humiwx,ibuf2,nch,5,1) 
C 
      nch = nch - 1 
      iclass = 0
      call put_buf(iclass,ibuf2,-nch,2hfs,0)
C 
      ip(1) = iclass
      ip(2) = 1
      ip(3) = ierr
      call char2hol('qx',ip(4),1,2)
      return
      end 
