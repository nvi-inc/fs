      subroutine wait_abst(name,ip,ih,im,is,ics)
      implicit none
      character*(*) name
      integer*4 ip(5)
      integer ih,im,is,ics
c
      integer it(6)
      integer*4 centisec
c
      call fc_rte_time(it,it(6))
      centisec=ics-it(1)
      centisec=centisec+(is-it(2))*100
      centisec=centisec+(im-it(3))*60*100
      centisec=centisec+(ih-it(4))*60*60*100
      if(centisec.lt.0) centisec=centisec+24*60*60*100
      call fc_skd_wait(name,ip,centisec)
c
      return
      end
