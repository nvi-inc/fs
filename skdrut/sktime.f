C@skTIME
      subroutine sktime(iobs,itim)
C
C     sktime: returns the time field for an observation record

      include '../skdrincl/skparm.ftni'

C  INPUT VARIABLES
      integer*2 itim(6)
      integer*2 iobs(ibuf_len)

C  LOCAL
      integer ic1,ic2,ich,idum,ichmv
C
C  LOCAL VARIABLES
C
C  HISTORY
C  900327  nrv  created
C  900328  gag  modified for use with ptobs
C  930219  nrv  re-name to "sktime" to avoid system conflict
C

      ICH = 1
      CALL GTFLD(iobs,ICH,IBUF_LEN*2,IC1,IC2) !source
      CALL GTFLD(iobs,ICH,IBUF_LEN*2,IC1,IC2) !cal time
      CALL GTFLD(iobs,ICH,IBUF_LEN*2,IC1,IC2) !frequency code
      CALL GTFLD(iobs,ICH,IBUF_LEN*2,IC1,IC2) !preob
      CALL GTFLD(iobs,ICH,IBUF_LEN*2,IC1,IC2) !time
      call ifill(itim,1,12,oblank)
      idum= ichmv(itim,1,iobs,ic1,11)

      return
      end

