      integer function iaddpc(ibuf,nc1,ibbc,isb,itone,ntone)

C     IADDPC puts the channel and tones on the PCALFORM= command. 
C     NOTE: ibuf is modified upon return.

C History
C 971208 nrv New. Copied from iaddtr.

      include '../skdrincl/skparm.ftni'

C Called by: PROCS

C Input:
      integer*2 ibuf(*)
      integer nc1,ibbc,isb,itone(*),ntone
C     nc1 is the next char in ibuf to use
C     isb=1 for upper, =2 for lower

C Local:
      character*1 csb(2)
      integer nch,i
      integer ib2as,ichmv_ch,mcoma
      integer z8000,izero2
      data csb(1)/'u'/,csb(2)/'l'/
      data z8000/z'8000'/

      izero2 = 2+Z8000 
      nch = nc1
      nch = nch + ib2as(ibbc,ibuf,nch,izero2)
      nch = ichmv_ch(ibuf,nch,csb(isb))
      nch = mcoma(ibuf,nch)
      do i=1,ntone
        nch = nch + ib2as(itone(i),ibuf,nch,izero2)
        if (i.lt.ntone) nch = mcoma(ibuf,nch)
      enddo
      
      iaddpc=nch

      return
      end
