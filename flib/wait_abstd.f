      subroutine wait_abstd(name,ip,id,ih,im,is,ics)
      implicit none
      character*(*) name
      integer*4 ip(5)
      integer id,ih,im,is,ics
c
      integer it(6), ileap
      integer*4 centisec
c
      call fc_rte_time(it,it(6))
      centisec=ics-it(1)
      centisec=centisec+(is-it(2))*100
      centisec=centisec+(im-it(3))*60*100
      centisec=centisec+(ih-it(4))*60*60*100
      centisec=centisec+(id-it(5))*24*60*60*100
C
c if the calculated wait is less than zero, check for wrapping
c around the year, and try to fix it we are on the last day
c otherwise return because the time must be past
c
      if(centisec.le.0) then
        if(mod(it(5),4).eq.0) then
          ileap=1
        else
          ileap=0
        endif
        if(it(5).eq.365+ileap.and.id.eq.0) then
          centisec=centisec+it(5)*86400*100
        else
          return
        endif
      endif
      call fc_skd_wait(name,ip,centisec)
c
      return
      end
