      subroutine onsor(nwait,ierr)
      dimension it(5) 
C 
C  WAIT FOR ONSOURCE CONDITION
C 
C  INPUT: 
C 
C         NWAIT  = NUMBER OF SECONDS TO WAIT AT MOST FOR CONDITION
C               < 0 MEANS WAIT INDEFINITELY 
C  OUTPUT:
C 
C        IERR = 0 IF NO ERROR OCCURRED
C 
      include '../include/fscom.i'
C 
C  THE FOLLOWING VARIABLES ARE READ FROM FSCOM: 
C 
C         IONSOR
C 
C  MAIN LOOP
C 
      call fc_rte_time(it,idum)
      tim=float(it(4))*3600.+float(it(3))*60.+float(it(2))
10    continue
C 
C  TRY TO DETERMINE ONSOURCE STATUS 
C 
      call antcn(5,ierr)
      if (ierr.ne.0) return
      call fs_get_ionsor(ionsor)
      if (ionsor.ne.0) return
      call fc_rte_time(it,idum)
      tim2=float(it(4))*3600.+float(it(3))*60.+float(it(2)) 
      if (tim2.lt.tim) tim2=tim2+86400.
      if (tim2.lt.tim+float(nwait).or.nwait.lt.0) goto 10 
C 
C  DIDN'T REACH ONSOURCE
C 
      ierr=-20

      return
      end 
