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
      time = xx 
      lxday = time
      time = time - lxday 
      time = time * 24.d0 
      lxhr = time 
      time = time - lxhr
      time = time * 60.d0 
      lxmin = time
      time = time - lxmin 
      time = time * 60.d0 
      lxsec = time
      call ib2as(lxday,line,nch,3)
      nch=nch+3 
      call ifill_ch(line,nch,1,'-')
      nch=nch+1 
      call ib2as(lxhr,line,nch,o'40000'+o'400'+2) 
      nch=nch+2 
      call ib2as(lxmin,line,nch,o'40000'+o'400'+2)
      nch=nch+2 
      if (ikey.ne.13) then
        call ib2as(lxsec,line,nch,o'40000'+o'400'+2)
        nch=nch+2 
      end if
C
      return
      end 
