      subroutine fitot(cmess,ltpar,ierr,lbuf,isbuf)
      real ltpar
      dimension ltpar(5)
      integer*2 lbuf(1)
      character*(*) cmess
C 
C WRITE XXXFIT LOG ENTRY
C 
       include '../include/fscom.i'
       include '../include/dpi.i'
C 
C INPUT:
C 
C       LTPAR = ARRAY OF FIT PARAMETERS 
C 
C       IERR  = FIT CODE FROM FITTING ROUTINE 
C 
C XXXFIT LOG ENTRY IDENTIFIER 
C 
       icnext=1 
       icnext=ichmv_ch(lbuf,icnext,cmess) 
       icnext=ichmv_ch(lbuf,icnext,' ') 
C 
C  OFFSET 
C 
       icnext=icnext+jr2as(ltpar(2)*180.0/RPI,lbuf,icnext,-9,5,isbuf)    
       icnext=ichmv_ch(lbuf,icnext,' ') 
C 
C HALF-WIDTH
C 
       icnext=icnext+jr2as(ltpar(3)*180.0/RPI,lbuf,icnext,-7,4,isbuf)  
       icnext=ichmv_ch(lbuf,icnext,' ') 
C 
C  TEMPERATURE PEAK   
C 
       icnext=icnext+jr2as(ltpar(1),lbuf,icnext,-7,4,isbuf) 
       icnext=ichmv_ch(lbuf,icnext,' ') 
C 
C TEMPERATURE OFFSET
C 
       icnext=icnext+jr2as(ltpar(4),lbuf,icnext,-7,4,isbuf)   
       icnext=ichmv_ch(lbuf,icnext,' ') 
C 
C TEMPERATURE SLOPE 
C 
       icnext=icnext+jr2as(ltpar(5),lbuf,icnext,-7,4,isbuf)     
       icnext=ichmv_ch(lbuf,icnext,' ') 
C 
C FIT CODE
C 
       icnext=icnext+ib2as(ierr,lbuf,icnext,3)
       icnext=ichmv_ch(lbuf,icnext,' ') 
C 
C CLEAN UP AND SEND DATA
C 
      nchars=icnext-1 
      if (1.ne.mod(icnext,2)) icnext=ichmv_ch(lbuf,icnext,' ') 
      call logit2(lbuf,nchars) 

      return
      end 
