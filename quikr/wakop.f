      subroutine wakop(ip)
C  wake up operator c#870115:04:37# 
      dimension ip(1) 

      include '../include/fscom.i'

      integer*2 lmsg(30)
      data lmsg/10*2h  ,2H !,2H!!,2H! ,2Hwa,2Hke,2H u,2Hp ,2H!!,2H!!,
     .          11*2H  /
      data nmsg/60/ 

      call bell(lu,1) 
      call bell(lu,0) 
      call bell(lu,1) 
      call bell(lu,0) 
      iclass = 0
      call put_buf(iclass,lmsg,-nmsg,'fs','  ')
      ip(1) = iclass
      ip(2) = 1 
      ip(3) = 0 
      call char2hol('qo',ip(4),1,2)
      ip(5) = 0 

      return
      end 
