      subroutine sctl(cbuf,prog,iwait,ierr)
C
      integer it(5)
      logical kbreak,rn_test
      character*(*) prog
      character*(*) cbuf
      integer*2 ibuf(128)
C
C  SEND THE COMMAND IF THE PROGRAM ISN'T ACTIVE
C
      if (iwait.le.0) return
      if(rn_test(prog(1:5))) goto 500
      if (ip.gt.0) goto 500
      ic=(len(cbuf)+1)/2
      ic=ic*2
      if(ic.gt.256) stop 999
      call char2hol(cbuf,ibuf,1,ic)
      call scmd(ibuf,0,ic/2,ierr)
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
      if(rn_test(prog(1:5))) goto 9
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
      if(.not.rn_test(prog(1:5))) goto 300
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
      call send_break(prog(1:5))
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
