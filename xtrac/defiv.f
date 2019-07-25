      subroutine defiv(jbuf,ifc,ilc,laxis,nrep,npts,step,intp,ldev,cal, 
     +                 freq,iferr)
C
      integer*2 jbuf(1),laxis(1),ldev
C 
      iferr=1 
      ifield=0
C 
C  AXIS TYPE
C 
      call gtchr(laxis,1,4,jbuf,ifc,ilc,ifield,iferr) 
C 
C  NUMBER OF REPTITIONS 
C 
      nrep=igtbn(jbuf,ifc,ilc,ifield,iferr) 
C 
C  NUMBER OF POINTS 
C 
      npts=igtbn(jbuf,ifc,ilc,ifield,iferr) 
C 
C  STEP SIZE
C 
      step=gtrel(jbuf,ifc,ilc,ifield,iferr) 
C 
C INTEGRATION PERIOD
C 
      intp=igtbn(jbuf,ifc,ilc,ifield,iferr) 
C 
C DETECTOR DEVICE 
C 
      call gtchr(ldev,1,2,jbuf,ifc,ilc,ifield,iferr)
C 
C CALIBRATION NOISE TEMP
C 
      cal=gtrel(jbuf,ifc,ilc,ifield,iferr)
C 
C  FREQUENCY
C 
      freq=gtrel(jbuf,ifc,ilc,ifield,iferr) 
C 
      return
      end 
