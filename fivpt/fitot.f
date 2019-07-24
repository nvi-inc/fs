      subroutine fitot(lmess,mchars,ltpar,ierr,lbuf,isbuf)
      real ltpar
      dimension ltpar(5)
      integer*2 lbuf(1),lmess(1)
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
       icnext=ichmv(lbuf,icnext,lmess,1,mchars) 
       icnext=ichmv(lbuf,icnext,2H  ,1,1) 
C 
C  OFFSET 
C 
       icnext=icnext+jr2as(ltpar(2)*180.0/RPI,lbuf,icnext,-9,5,isbuf)    
       icnext=ichmv(lbuf,icnext,2H  ,1,1) 
C 
C HALF-WIDTH
C 
       icnext=icnext+jr2as(ltpar(3)*180.0/RPI,lbuf,icnext,-7,4,isbuf)  
       icnext=ichmv(lbuf,icnext,2H  ,1,1) 
C 
C  TEMPERATURE PEAK   
C 
       icnext=icnext+jr2as(ltpar(1),lbuf,icnext,-7,4,isbuf) 
       icnext=ichmv(lbuf,icnext,2H  ,1,1) 
C 
C TEMPERATURE OFFSET
C 
       icnext=icnext+jr2as(ltpar(4),lbuf,icnext,-7,4,isbuf)   
       icnext=ichmv(lbuf,icnext,2H  ,1,1) 
C 
C TEMPERATURE SLOPE 
C 
       icnext=icnext+jr2as(ltpar(5),lbuf,icnext,-7,4,isbuf)     
       icnext=ichmv(lbuf,icnext,2H  ,1,1) 
C 
C FIT CODE
C 
       icnext=icnext+ib2as(ierr,lbuf,icnext,3)
       icnext=ichmv(lbuf,icnext,2H  ,1,1) 
C 
C CLEAN UP AND SEND DATA
C 
      nchars=icnext-1 
      if (1.ne.mod(icnext,2)) icnext=ichmv(lbuf,icnext,2H  ,1,1) 
      call logit2(lbuf,nchars) 

      return
      end 
