      subroutine tpform(ip)
C  specify tape format
C 
C   TPFORM reads the a priori head offsets for each tape pass number
C 
C     INPUT VARIABLES:
      dimension ip(1) 
C        IP(1)  - class number of input parameter buffer. 
C 
C     OUTPUT VARIABLES: 
C        IP(1) - class (called ICLASS internally)
C        IP(2) - # rec
C        IP(3) - error
C        IP(4) - who we are 
C 
C   LOCAL CONSTANTS
      parameter (maxpass = 100)     ! maximum head pass number
      parameter (maxpass4 = 312)    ! maximum head pass number for MK4
      parameter (maxtens4 = 12)     ! maximum head pass number for MK4
      parameter (maxoff = 4000)     ! maximum head offset
      parameter (minoff = -4000)    ! minimum head offset
      parameter (ilen = 80)         ! size of local class buffer
C
C   COMMON BLOCKS USED
      include '../include/fscom.i'
C       contains array ITAPOF
C
C     CALLED SUBROUTINES: GTPRM
C
C   LOCAL VARIABLES
C        NCHAR  - number of characters in buffer
C        ICH    - character counter
      integer*2 ibuf(40)            !  class buffer
      logical kpassno
C               - keeps track of whether parameter is a pass # or head offset
      dimension iparm(2)      !  parameters returned from gtprm
      dimension ireg(2)
      integer get_buf
      dimension ipass(20),ioffset(20)
C               - paired pass numbers and head offsets
      equivalence (reg,ireg(1)),(parm,iparm(1)) 
C 
C 
C  PROGRAMMER: LAR     LAST MODIFIED: <910329.1842>
C  HISTORY:
C  WHO  WHEN    WHAT
C  gag  920720  Added Mark IV code.
C 
C
C     1. Set output parameters (except error flag) and read from input
C     class into local buffer IBUF.
C 
      iclcm = ip(1) 
      iclass = 0
      ip(1)=iclass
      ip(2)=0
      call char2hol('q^',ip(4),1,2)
      if (iclcm.eq.0) then
        ip(3) = -1
        return
      endif
      ireg(2) = get_buf(iclcm,ibuf,-ilen,idum,idum)
      nchar = ireg(2) 
C           Scan for "="; its absence indicates a request to see
C             the contents of the ITAPOF array.
      ieq = iscn_ch(ibuf,1,nchar,'=') 
      if (ieq.eq.0) then
        nchar = 1
        nrec = 0
        nchar = ichmv(ibuf,nchar,10Htapeform/ ,1,9)
        do i=1,maxpass
          if (itapof(i).ge.minoff .and. itapof(i).le.maxoff) then
            nchar = nchar + ib2as(i,ibuf,nchar,o'100003')
            nchar = ichmv(ibuf,nchar,2h->,1,2)
            nchar = nchar + ib2as(itapof(i),ibuf,nchar,o'100005')
            nchar = ichmv(ibuf,nchar,2h  ,1,2)
            if (nchar.gt.68) then
              call put_buf(iclass,ibuf,1-nchar,2hfs,0)
              nchar = 1
              nchar = ichmv(ibuf,nchar,10Htapeform/ ,1,9)
              nrec = nrec + 1
            endif
          endif
        enddo
        if (nchar.gt.10) then
          call put_buf(iclass,ibuf,1-nchar,2hfs,0)
          nrec = nrec + 1
        endif
        if (kpass4) then
          nchar = 1
          nchar = ichmv(ibuf,nchar,10Htapeform/ ,1,9)
          do i=1,3
            do j=1,12
              if(itapof4(j,i).ge.minoff.and.itapof4(j,i).le.maxoff) then
                inumb = i*100 + j
                nchar = nchar + ib2as(inumb,ibuf,nchar,o'100004')
                nchar = ichmv(ibuf,nchar,2h->,1,2)
                nchar = nchar + ib2as(itapof4(j,i),ibuf,nchar,o'100005')
                nchar = ichmv(ibuf,nchar,2h  ,1,2)
                if (nchar.gt.68) then
                  call put_buf(iclass,ibuf,1-nchar,2hfs,0)
                  nchar = 1
                  nchar = ichmv(ibuf,nchar,10Htapeform/ ,1,9)
                  nrec = nrec + 1
                endif
              endif
            enddo
          enddo         
        endif
        if (nchar.gt.10) then
          call put_buf(iclass,ibuf,1-nchar,2hfs,0)
          nrec = nrec + 1
        endif
        ip(1)=iclass
        ip(2)=nrec
        ip(3)=0
        return
      endif
C 
C     2. Step through buffer getting each parameter and decoding it.
C     Command from user has these parameters: 
C           TAPEFORM=<pass>,<offset>,<pass>,<offset>, ...
C 
      ich = 1+ieq
      call fs_get_drive(drive)
      do n=1,40
        m=(n+1)/2
        kpassno = (m+m.ne.n)
        call gtprm(ibuf,ich,nchar,1,parm,ierr)
C  Check if the pass number is a legal Mark IV pass
        if (kpassno.and.(iparm(1).gt.maxpass).and.
     .      (iparm(1).le.maxpass4).and.(MK4.eq.iand(drive,MK4))) then
          itens = MOD(iparm(1),100)
          ihunds = iparm(1)/100
          if (itens.le.0 .or. itens.gt.maxtens4) then
            ip(3)=-201
            return
          endif
          kpass4=.true.
          goto 700
        endif
        if (iparm(1).lt.minoff .or. iparm(1).gt.maxoff .or.
     &     (kpassno.and.(iparm(1).gt.maxpass.or.iparm(1).le.0))) then
          ip(3) = -201
          return
        endif
700     continue
        if (kpassno) then
          ipass(m)=iparm(1)
        else
          ioffset(m)=iparm(1)
        endif
        if (ich.gt.nchar) then             ! last parameter
          if (kpassno) then                ! abnormal end; error
            ip(3) = -3
          else                             ! normal end of list
            do i=1,m
              if ((ipass(i).gt.maxpass).and.(kpass4)) then
                itens=MOD(ipass(i),100)
                ihunds = ipass(i)/100
                itapof4(itens,ihunds)=ioffset(i)
              else
                itapof(ipass(i)) = ioffset(i)
              endif
            enddo
            ip(3) = 0
          endif
          return
        endif
      enddo               
C
      ip(3) = -42          ! get here only if line is unusually long
C
      return
      end 
