      integer function iaddk4(ibuf,nc1,it,ib,isb,
     .kk41rack,kk42rack,km3rack,km4rack,kvrack,kv4rack)

C     IADDK4 adds a track to the RECPATCH= command line buffer
C     NOTE: ibuf is modified upon return.

C History
C 990304 nrv Created. Copied from iaddtr.

      include '../skdrincl/skparm.ftni'

C Called by: PROCS

C Input:
      integer*2 ibuf(*)
      integer nc1,it,ib,isb
      logical kk41rack,kk42rack,km3rack,km4rack,kvrack,kv4rack

C Local:
      character*1 csb(2)
      integer nch
      integer ib2as,ichmv_ch,mcoma
      integer z8000,izero2
      data csb(1)/'u'/,csb(2)/'l'/
      data z8000/z'8000'/

      izero2 = 2+Z8000 
      nch = nc1
      nch = nch + ib2as(it,ibuf,nch,izero2)
      nch = mcoma(ibuf,nch)
      if (kk41rack.or.km3rack.or.km4rack.or.kvrack.or.kv4rack) then
        nch = nch + ib2as(ib,ibuf,nch,izero2) ! BBC number
      endif
      if (kk42rack) then ! a1-a8 or b1-b8
        if (ib.le.8) then
          nch = ichmv_ch(ibuf,nch,'a')
          nch = nch + ib2as(ib,ibuf,nch,1) ! BBC number
        else
          nch = ichmv_ch(ibuf,nch,'b')
          nch = nch + ib2as(ib-8,ibuf,nch,1) ! BBC number
        endif
      endif
      nch = ichmv_ch(ibuf,nch,csb(isb))
      nch = mcoma(ibuf,nch) ! trailing comma
      
      iaddk4=nch

      return
      end
