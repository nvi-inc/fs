      SUBROUTINE unphd(IBUF,ILEN,IERR,lstn,lcod,ipass,
     .idir,ihd,nent)
C
C     unphd unpacks a record containing head information
C
      include '../skdrincl/skparm.ftni'
C
C  Called by: HDINP

C  INPUT:
      integer*2 IBUF(*)
      integer ilen
C           - buffer containing the record
C     ILEN  - length of IBUF in words
C
C  OUTPUT:
      integer ierr,ipass(max_pass),idir(max_pass),ihd(max_pass),
     .        nent
      integer*2 lstn,lcod
C     IERR    - error return, 0=ok, -100-n=error in nth field
C     lstn - station ID, 1 character   
C     lcod - frequency code, 2 characters
C     ipass,idir,ihd - pass, direction, head position
C     nent - number on this line
C
C  LOCAL:
      integer ich,ic1,ic2,nc,nch,idumy
      integer iinc,il,ir,ih,ip,id
      integer iscnc,ias2b,ichmv ! function
      character*62 cpass
      character*1 cp
C
C  INITIALIZED:
      data cpass/'123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrs
     .tuvwxyz'/
C
C  Modifications:
C  930707 NRV Created, copied from UNPFL
C 960409 nrv Allow preceding '1' to indicate second headstack position
C
C
C     Start the unpacking with the first character of the buffer.
C
      ICH = 1
C
C     The station ID
C
      CALL GTFLD(IBUF,ICH,ILEN*2,IC1,IC2)
      NCH = IC2-IC1+1
      IF  (NCH.ne.1) THEN
        IERR = -101
        RETURN
      END IF  !
      call char2hol('  ',lstn,1,2)
      IDUMY = ICHMV(lstn,1,IBUF,ic1,nch)
C
C     The band ID.
C
      CALL GTFLD(IBUF,ICH,ILEN*2,IC1,IC2)
      NCH = IC2-IC1+1
      IF  (NCH.gt.2) THEN
        IERR = -102
        RETURN
      END IF  !
      call char2hol('  ',lcod,1,2)
      IDUMY = ICHMV(lcod,1,IBUF,IC1,nch)
C
C    Lines with head positions are in the form
C      index-subpass(headpos)
C    Example: 11(-350) is index 1, subpass 1, offset -350 microns
C             42(55) is index 4, subpass 2, offset 55 microns
C            142(55) is same as above but for headstack 2
C    The subpass goes from 1 to the number of passes in the
C    mode that are required to get all tracks recorded. 
C    For example, mode A is a one-pass mode so the number is always 1; 
C    mode C is a two-pass mode so the number is always 1 or 2.
C
      nent = 0
      do while (ic1.gt.0)
        CALL GTFLD(IBUF,ICH,ILEN*2,IC1,IC2)
        IF (IC1.EQ.0) return
        il = ISCNC(IBUF,IC1,IC2,OLPAREN) ! find (
        NC = il-IC1  ! number of char in pass/subpass
        if (nc.eq.3) then ! headstack 2
          iinc=100
          ic1=ic1+1 ! skip over this character
        else
          iinc=0
        endif 
        call hol2char(ibuf,ic1,ic1,cp) ! pass is first char
        ip = index(cpass,cp)
        if (ip.eq.0) then
          ierr=-103-nent
          return
        endif
        id = ias2b(ibuf,ic1+1,1) ! sub-pass is second char
        if (id.le.0) then
          ierr = -103-nent
          return
        endif
        ir = ISCNC(IBUF,IC1,IC2,ORPAREN)
        ih = ias2b(ibuf,il+1,ir-il-1) ! head offset position
        if (ih.lt.-2000.or.ih.gt.2000) then
          IERR = -103-nent
          RETURN
        ENDIF
        nent = nent + 1
        ipass(nent) = ip+iinc
        idir(nent) = id
        ihd(nent) = ih
      enddo
C
      RETURN
      END

