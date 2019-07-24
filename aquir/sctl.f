      subroutine sctl(ibuf,ic,iprog,iwait,ierr)
C
      integer it(5)
      integer*2 ibufm(1), iprog(1), ibuf(1)
      logical kbreak,rn_test
      character*5 prog
C
C  SEND THE COMMAND IF THE PROGRAM ISN'T ACTIVE
C
      if (iwait.le.0) return
      call hol2char(iprog,1,ic,prog)
      if(rn_test(prog)) goto 500
      if (ip.gt.0) goto 500
      call scmd(ibuf,0,(ic+1)/2,ierr)
      if (ierr.ne.0) return
C
C  GIVE THE FIELD SYSTEM UPTO 1 MINUTE TO GET THE PROGRAM GOING
C
      call fc_rte_time(it,idum)
      tim=float(it(4))*60.0+float(it(3))+float(it(2))/60.0
C
5     continue
      if(kbreak('aquir')) goto 100
      call susp(2,2)
      if(rn_test(prog)) goto 9
      call fc_rte_time(it,idum)
      tim2=float(it(4))*60.0+float(it(3))+float(it(2))/60.0
      if (tim2.lt.tim) tim2=tim2+1440.
      if (tim2.gt.tim+1.0) goto 600
      goto 5
C
C  GIVE THE PROGRAM IWAIT MINUTES TO COMPLETE
C
9     continue
      call fc_rte_time(it,idum)
      tim=float(it(4))*60.0+float(it(3))+float(it(2))/60.0
C
10    continue
      if(kbreak('aquir')) goto 100
      call susp(2,2)
      if(.not.rn_test(prog)) goto 300
      call fc_rte_time(it,idum)
      tim2=float(it(4))*60.0+float(it(3))+float(it(2))/60.0
      if (tim2.lt.tim) tim2=tim2+1440.
      if (tim2.gt.tim+iwait) goto 200
      goto 10
C
100   continue
      ierr=-1
      return
C
200   continue
      call send_break(prog)
      ierr=-10
      return
C
300   continue
      ierr=0
      return
C 
400   continue
      ierr=-11
      return
C 
500   continue
      ierr=-12
      return
C 
600   continue
      ierr=-13
C
      return
      end 
