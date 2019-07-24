      subroutine endis(ip,iclcm)
C track enable display
C 
C 1.1.   ENDIS gets data from the tape controller regarding enabled tracks
C 
C     INPUT VARIABLES:
      dimension ip(1) 
C        IP(1)  - class number of buffer from MATCN 
C        IP(2)  - number of records in class
C        IP(3)  - error return from MATCN 
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
C     CALLED SUBROUTINES: character utilities 
C 
C 3.  LOCAL VARIABLES 
      integer*2 ibuf(20),ibuf2(50)
C               - input class buffers, output display buffer
C        ILEN   - length of buffers, chars
C        NCH    - character counter 
C        I      - bit, converted to 0 or 1
C        IA     - hex char from MAT 
      integer itrk(28)
      logical kcom,kdata
C              - true if COMMON variables wanted
      dimension ireg(2) 
      integer get_buf
      integer z1
C 
C 5.  INITIALIZED VARIABLES 
      data ilen/40/ 
      data z1/z'01'/
C 
C 6.  PROGRAMMER: NRV 
C     LAST MODIFIED: CREATED 790319 
C  HISTORY:
C  WHO  WHEN    WHAT
C  gag  920724  Added Mark IV code.
C
C 
C     PROGRAM STRUCTURE 
C 
C     1. First check error return from MATCN.  If not 0, get out
C     immediately.  If setup data wanted ( ? ), skip class read.
C 
C 
      kcom = (ichcm_ch(ip(4),1,'?').eq.0)
C 
      iclass = ip(1)
      ncrec = ip(2) 
      ierr = ip(3)
      nrec = 0
C 
      if (kcom) goto 200
      if (ierr.lt.0) return 
      if (iclass.eq.0.or.iclcm.eq.0) return 
C 
C     2. Get class buffer with command in it.  Set up first part
C     of output buffer.  Get first buffer from MATCN. 
C 
200   ireg(2) = get_buf(iclcm,ibuf2,-ilen,idum,idum)
C 
      nchar = ireg(2) 
      nch = iscn_ch(ibuf2,1,nchar,'=')
      kdata = nch.eq.0
C                   If our command was only "device" we are waiting for 
C                   data and know what to expect. 
      if (nch.eq.0) nch = nchar+1 
C                   If no "=" found, position after last character
      nch = ichmv(ibuf2,nch,2h/ ,1,1) 
C                   Put / to indicate a response
C 
      if (kcom) goto 310
      if (kdata) goto 230 
C 
      do 220 i=1,ncrec
        if (i.ne.1) nch=ichmv(ibuf2,nch,2h, ,1,1) 
C                   If not first parm, put comma before 
        ireg(2) = get_buf(iclass,ibuf,-ilen,idum,idum)
        nchar = ireg(2) 
        nch = ichmv(ibuf2,nch,ibuf(2),1,nchar-2)
C                   Move buffer contents into output list 
220     continue
      goto 500
C 
230   ireg(2) = get_buf(iclass,ibuf,-ilen,idum,idum)
C 
C 
C     3. Now the buffer contains: ENABLE=, and we want to add the data. 
C     Format of data received from tape controller: 
C 
C     For Mark III:
C     % data:       TPtttttttt
C     where each "t" contains 3 or 4 bits regarding tape track status 
C
C     For Mark IV:
C     % data:       TPrxxxxyxz
C                rxxxxxxt represents bits 0 - 31, 0 starting at z
C     where the r will have   bit31 = 1 for record enabled.
C                             remaining bits will be 0.
C               y will have   bit8 = 1 for stack1 enabled 
C               z will have   bit0 = 1 for stack2 enabled 
C                             remaining bits will be 0.
C
      call fs_get_drive(drive)
      if (MK4.eq.iand(MK4,drive)) then
        ncx=nch
        if (z1.eq.iand(ia2hx(ibuf,10),z1)) then
          nch = ichmv(ibuf2,nch,6Hstack1,1,6)
          nch = mcoma(ibuf2,nch)
        endif
        if (z1.eq.iand(ia2hx(ibuf,8),z1)) then
          nch = ichmv(ibuf2,nch,6Hstack2,1,6)
          nch = mcoma(ibuf2,nch)
        endif
        if (nch.eq.ncx) then
          nch = ichmv(ibuf2,nch,4Hnull,1,4)
          nch = mcoma(ibuf2,nch)
        endif
        nch=nch-1
        goto 500
      endif

      call ma2en(ibuf,iena,itrk,ntrk)
      goto 400
C
310   continue
      call fs_get_drive(drive)
      if (MK4.eq.iand(MK4,drive)) then
        call fs_get_kena(kenastk)
        if (kenastk(1)) then
          nch = ichmv(ibuf2,nch,6Hstack1,1,6)
          nch = mcoma(ibuf2,nch)
        endif
        if (kenastk(2)) then
          nch = ichmv(ibuf2,nch,6Hstack2,1,6)
          nch = mcoma(ibuf2,nch)
        endif
        if ((.not.kenastk(1)).and.(.not.kenastk(2))) then
          nch = ichmv(ibuf2,nch,4Hnull,1,4)
          nch = mcoma(ibuf2,nch)
        endif
        nch=nch-1
        goto 500
      endif
      ntrk = 0
      do 311 i=1,28
        itrk(i) = itrkenus_fs(i)
        if (itrk(i).eq.1) ntrk = ntrk + 1
311     continue
      call fs_get_ienatp(ienatp)
      iena = ienatp
C
C
C     4. Format up the buffer for display.
C
400   continue
      ierr = 0
      if (ntrk.ne.0) goto 401
      nch = ichmv(ibuf2,nch,8hdisabled,1,8)
      goto 500
C
401   continue
      do 410 i=1,28
        if (itrk(i).ne.itrken(i).and..not.kcom) ierr = -300-i
        if (itrk(i).eq.0) goto 410
        ncx = ib2as(i,ibuf2,nch,o'100000'+2)
        nch = ichmv(ibuf2,nch+ncx,2h, ,1,1)
410   continue
      nch = nch-1
C
C
C     5. Now send the buffer to SAM.
C
500   iclass = 0
      nch = nch - 1
      call put_buf(iclass,ibuf2,-nch,2hfs,0)
C                   Send buffer starting with TP to display
C
      if (.not.kcheck) ierr = 0 
C 
      ip(1) = iclass
      ip(2) = 1 
      ip(3) = ierr
      call char2hol('qe',ip(4),1,2)
      return
      end 
