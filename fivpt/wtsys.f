      subroutine wtsys(temps,sigts,az,el,np,lbuf,isbuf) 
      integer*2 lbuf(1) 
C 
       include '../include/fscom.i'
       include '../include/dpi.i'
C 
C  WRITE TSYS LOG ENTRY 
C 
      icnext=1
C 
C RECORD IDENTIFIER 
C 
      icnext=ichmv_ch(lbuf,icnext,'tsys ')
C 
C AZIMUTH 
C 
      icnext=icnext+jr2as(az*180.0/RPI,lbuf,icnext,-7,3,isbuf) 
      icnext=ichmv_ch(lbuf,icnext,' ')  
C 
C  ELEVATION
C 
      icnext=icnext+jr2as(el*180.0/RPI,lbuf,icnext,-7,3,isbuf) 
      icnext=ichmv_ch(lbuf,icnext,' ')  
C 
C SYSTEM TEMPERATURE
C 
      icnext=icnext+jr2as(temps,lbuf,icnext,-7,3,isbuf) 
      icnext=ichmv_ch(lbuf,icnext,' ')  
C 
C SYSTEM TEMPERATURE SIGMA
C 
      if (np.le.1) goto 100 
      icnext=icnext+jr2as(sigts,lbuf,icnext,-7,4,isbuf) 
      icnext=ichmv_ch(lbuf,icnext,' ')  
C 
C CLEAN AND SEND BUFFER 
C 
100   continue
      nchars=icnext-1 
      if (1.ne.mod(icnext,2)) icnext=ichmv_ch(lbuf,icnext,' ') 
      call logit2(lbuf,nchars) 
C 
      return
      end 
