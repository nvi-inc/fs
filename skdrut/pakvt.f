      subroutine pakvt(ibuf)
C Format the "T" line 
C 990621 nrv New, actually re-new. Removed from snapintr.

      include '../skdrincl/skparm.ftni'
      include '../skdrincl/statn.ftni'

C Input
      integer*2 ibuf(*)

C     Write terminal line
C Example:
C T 102  KO-VLBA  1x56000  17640   X   900   S   750 
C          X 1.0 0.9453 0.0547 S 1.0 0.9 695 0.0305

C     begin PAKVT
C
      call ifill(ibuf,1,iblen,32)
      nch = 3 ! leave first two spaces blank
      nch=ichmv(ibuf,nch+1,lterid(1,istn),1,4)
      nch=ichmv(ibuf,nch+1,lterna(1,istn),1,8)
      nch=nch+ib2as(maxpas(istn),ibuf,nch+1,2)
      if (idens
      nch=ichmv_ch(ibuf,nch,'x')
      nch=nch+1+ib2as(maxtap(istn),ibuf,nch+1,5)
C
C     end PAKVT
      return
      end
