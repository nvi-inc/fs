      subroutine lxhms(xx,line,nch)
C 
C LXHMS - Convert log time from double precision to ASCII.
C 
C MODIFICATIONS:
C 
C    DATE     WHO  DESCRIPTION
C    820917   KNM  SUBROUTINE CREATED 
C 
C INPUT VARIABLES:
C 
      double precision xx 
C        - Contains the log time
C 
C OUTPUT VARIABLES: 
C 
      integer*2 line(1) 
C        - Plotting output array
C     NCH - Character count 
C 
C COMMON BLOCKS USED: 
C 
      include 'lxcom.i'
C 
C SUBROUTINE INTERFACES:
C 
C     CALLING SUBROUTINES:
C 
C     LXPLT - Plotting routine
C 
C LOCAL VARIABLES:
C 
C     LXDAY,LXHR,LXMIN,LXSEC - Day, Hours, Minutes, & Seconds 
C     TIME - Contains log time
      integer it(6)
      integer*4 secs
C 
C INITIALIZED VARIABLES:
C 
C 
C ******************************************************************* 
C 
C Convert the double precision variable TIME ( which is the log day & 
C fraction of a day to log day, hours, minutes, & seconds.
C 
C ******************************************************************* 
C 
C 
      secs=int(xx/100.0d0+0.005d0)
      call fc_secs2rte(secs,it)
      it(1)=(xx-secs*100.0d0)+.5
      nch=nch+ib2as(it(6),line,nch,4)
      nch=ichmv_ch(line,nch,'.')
      nch=nch+ib2as(it(5),line,nch,o'40000'+o'400'*2+3) 
      nch=ichmv_ch(line,nch,'.')
      nch=nch+ib2as(it(4),line,nch,o'40000'+o'400'+2) 
      nch=ichmv_ch(line,nch,':')
      nch=nch+ib2as(it(3),line,nch,o'40000'+o'400'+2)
      nch=ichmv_ch(line,nch,':')
      nch=nch+ib2as(it(2),line,nch,o'40000'+o'400'+2)
      nch=ichmv_ch(line,nch,'.')
      nch=nch+ib2as(it(1),line,nch,o'40000'+o'400'+2)

C
      return
      end 
