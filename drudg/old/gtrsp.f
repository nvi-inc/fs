C@GTRSP
      SUBROUTINE GTRSP(IBUF,IBLEN,LUUSR,NCH)
C   GET RESPONSE FROM USER
C
      implicit none
      integer*2 IBUF(*)
      integer iblen,luusr,nch
C Local
      integer i,ic1,ic2,ich
      integer oblank
      integer idum,ichmv
      data oblank/O'40'/
C
      CALL IFILL(IBUF,1,IBLEN*2,oblank)
      read(luusr,'(512a2)') (ibuf(i),i=1,iblen)
      ICH = 1
      CALL GTFLD(IBUF,ICH,iblen*2,IC1,IC2)
      NCH = IC2-IC1+1
      IF  (IC1.eq.0) then
          NCH = 0
          RETURN
      endif
      idum= ICHMV(IBUF,1,IBUF,IC1,NCH)
      CALL IFILL(IBUF,NCH+1,IBLEN*2-NCH,oblank)
      RETURN
      END
