      subroutine de(ip)
C  decoder controller c#870115:04:37#
C
C 1.1.   DE controls the DECODER
C
C     INPUT VARIABLES:
      dimension ip(1)
C        IP(1)  - class number of input parameter buffer.
C
C     OUTPUT VARIABLES:
C        IP(1) - CLASS
C        IP(2) - # REC
C        IP(3) - ERROR
C        IP(4) - who we are
C
C 2.2.   COMMON BLOCKS USED
      include '../include/fscom.i'
C
C 2.5.   SUBROUTINE INTERFACE:
C     CALLING SUBROUTINES:
C     CALLED SUBROUTINES: GTPRM
C
C 3.  LOCAL VARIABLES
C        NCHAR  - number of characters in buffer
C        IMMODE - mode for MAT
C        ICH    - character counter
      integer*2 ibuf(20)
C               - class buffer
      integer*2 lmode(12)
C               - modes for type of data from decoder
C        ILEN    - length of IBUF in chars
      integer*2 iem(3),iemc(3) !error counter modes
      dimension nr(6),n1(6),n2(5),n3(2)
C                - number of requests, first code number, for
C                  each of the types of data
      integer*2 iparm(2)
C               - parameters returned from GDECRM
      dimension ireg(2)
      integer get_buf
C               - registers from EXEC calls
      character cjchar
      equivalence (reg,ireg(1)),(parm,iparm(1))
C
C 5.  INITIALIZED VARIABLES
      data ilen/40/
      data lmode  /2hau,2hx ,2hsy,2hn ,2hti,2hme,2hda,2hta,2her,2hr ,
     &             2hcr,2hc /
      data iem    /2hb  ,2hf  ,2hr /
      data iemc   /2h(  ,2h)  ,2h% /
      data nr/2,1,2,3,1,5/
      data n1/0,2,3,5,8,0/
      data n2/0,1,2,3,9/
      data n3/3,9/
C
C 6.  PROGRAMMER: NRV
C     LAST MODIFIED:  790320
C
C     PROGRAM STRUCTURE
C
C     1. If we have a class buffer, then we are to set up the data type.
C     If no class buffer, we have been requested to read the data.
C
      iclcm = ip(1)
      if (iclcm.ne.0) goto 110
      ierr = -1
      goto 990
110   continue
      if(decoder4.ne.3) then
         ierr=-302
         goto 990
      endif
      call ifill_ch(ibuf,1,ilen,' ')
      ireg(2) = get_buf(iclcm,ibuf,-ilen,idum,idum)
      nchar = ireg(2)
      ieq = iscn_ch(ibuf,1,nchar,'=')
      if (ieq.eq.0) goto 500
C                   If no parameters, go read device
      if (cjchar(ibuf,ieq+1).ne.'?') goto 140
      ip(1) = 0 
      ip(4) = o'77' 
      call dedis(ip,iclcm)
      return
C 
140   if (ichcm(ibuf,ieq+1,ltsrs,1,ilents).eq.0) goto 600 
      if (ichcm(ibuf,ieq+1,lalrm,1,ilenal).eq.0) goto 700 
C 
C 
C     2. Step through buffer getting each parameter and decoding it.
C     Command from user has these parameters:
C                   DECODE=<chan>,<datatype>,<counter>
C     where <chan>=A or B, default A.
C           <datatype>=AUX,SYN,TIME,DATA,ERR, or CRC.  Default ERR.
C           <counter>=B, F, R for BYTE, FRAME, RESET for error mode
C
C     2.1 CHAN, PARAMETER 1
C
210   ich = 1+ieq
      ichan = -1
      call gtprm(ibuf,ich,nchar,0,parm,ierr)
      if (cjchar(parm,1).eq.'*') ichan = ichand
      if (cjchar(parm,1).eq.',') ichan = 0
C                   Default is channel A
      if (cjchar(parm,1).eq.'a') ichan = 0
C                   Channel A
      if (cjchar(parm,1).eq.'b') ichan = 1
C                   Channel B
      if (ichan.ne.-1) goto 220
      ierr = -201
      goto 990
C
C     2.2 DATA MODE, PARAMETERS 2
C
220   call gtprm(ibuf,ich,nchar,0,parm,ierr)
      if (cjchar(parm,1).ne.'*'.and.cjchar(parm,1).ne.',') goto 221
      if (cjchar(parm,1).eq.'*') im = imoddc
      if (cjchar(parm,1).eq.',') im = 5
C                   Default mode is 5, ERROR
      goto 230
221   do 222 i=1,6
        if (iparm(1).eq.lmode(i*2-1).and.iparm(2).eq.lmode(i*2))
     .        goto 223
222     continue
      ierr = -202
      goto 990
223   im =i
C
C     2.3 ERROR COUNTER CONTROL
C
230   continue
      call gtprm(ibuf,ich,nchar,0,parm,ierr)
      if (cjchar(parm,1).ne.'*'.and.cjchar(parm,1).ne.',') goto 231
      if (cjchar(parm,1).eq.'*') ie = ierrdc_fs
      if (cjchar(parm,1).eq.',') ie = 1
C                   Default mode is 1, BYTE
      goto 233
231   continue
      do i=1,3
        ie=i
        if(ichcm(parm,1,iem(i),1,1).eq.0) go to 233
      enddo
      ierr = -203
      goto 990
233   continue
C
C
C     3. Now plant these values into COMMON.
C
300   imoddc = im
      ichand = ichan
      ierrdc_fs=ie
      ierr = 0
C
C     4. now set decode error counter mode
C
      ibuf(1)=0
      call char2hol('de',ibuf(2),1,2)
      idumm1 = ichmv(ibuf,5,iemc(ierrdc_fs),1,1)
      iclass=0
      call put_buf(iclass,ibuf,-5,'fs','  ')
      nrec=1
      goto 800
C
C
C     5.  This is the read device section.
C     Fill up NR*3 buffers, using data modes starting with N1.
C     Format the buffer for the controller as follows.
C                   mmDE000000dd
C     where the first "d" has one bit telling the channel,
C     and the second "d" has the 4 bits for data type.
C     Then send ">" to transfer control and load the data, then
C      "/" to read back the data.
C
500   ibuf(1) = 0
      call char2hol('de',ibuf(2),1,2)
C                   Move in the channel bit
      iclass = 0
      do 510 i=1,nr(imoddc)
        idumm1 = ichmv_ch(ibuf,5,'000000')
        idumm1 = ichmv(ibuf,11,ihx2a(ichand),2,1)
        if(imoddc.eq.3) then
          idumm1 = ichmv(ibuf,12,ihx2a(n3(i)),2,1)
        else if(imoddc.eq.6) then
          idumm1 = ichmv(ibuf,12,ihx2a(n2(i)),2,1)
        else
          idumm1 = ichmv(ibuf,12,ihx2a(n1(imoddc)+i-1),2,1)
        endif
C                   Put the proper mode number into buffer
        ibuf(1) = 0
        call char2hol('de',ibuf(2),1,2)
        call put_buf(iclass,ibuf,-12,'fs','  ')
        ibuf(1) = 8
        call char2hol('de> ',ibuf(2),1,4)
        call put_buf(iclass,ibuf,-5,'fs','  ')
        call char2hol('/ ',ibuf(3),1,2)
        call put_buf(iclass,ibuf,-5,'fs','  ')
510     continue
C
      nrec = 3*nr(imoddc)
      goto 800
C
C
C     6. This is the test/reset device section. 
C 
600   ibuf(1) = 6 
      call char2hol('de',ibuf(2),1,2)
      iclass=0
      call put_buf(iclass,ibuf,-4,'fs','  ') 
      nrec = 1
      goto 800
C 
C 
C     7. This is the alarm query and reset request. 
C 
700   ibuf(1) = 7 
      call char2hol('de',ibuf(2),1,2)
      iclass=0
      call put_buf(iclass,ibuf,-4,'fs','  ') 
      nrec = 1
      goto 800
C 
C 
C     8. All MATCN requests are scheduled here, and then DEDIS called.
C 
800   call run_matcn(iclass,nrec)
      call rmpar(ip)
      call dedis(ip,iclcm)
      return
C
990   ip(1) = 0
      ip(2) = 0
      ip(3) = ierr
      call char2hol('qd',ip(4),1,2)
      return
      end
