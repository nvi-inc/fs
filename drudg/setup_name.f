      subroutine setup_name(itype,icode,isubpass,lnamep,nch)

C SETUP_NAME generates the setup procedure name.

      include '../skdrincl/skparm.ftni'
      include '../skdrincl/statn.ftni'
      include '../skdrincl/freqs.ftni'
      include 'drcom.ftni'

C History
C 991102 nrv New. Removed from PROCS and SNAP.
C 991205 nrv Use letter codes for passes and not numbers.
C Input
      integer itype ! 1=SETUP 2=mnemonic name
      integer icode,isubpass
C Output
      integer*2 lnamep(*)
      integer nch
C Local
      integer itrk(max_track,max_headstack),npmode,nco,ib
      integer*2 lpmode(2) ! mode for procedure names
      real spdips
      character*28 cpass,cvpass
      character*1 cp ! selection from cpass or cvpass
      integer iflch,ichmv_ch,ichmv,jchar
      data cpass  /'123456789ABCDEFGHIJKLMNOPQRS'/
      data cvpass /'ABCDEFGHIJKLMNOPQRSTUVWXYZAB'/

      nco = iflch(lcode(icode),2)
      if (itype.eq.1) then ! setup name
        nch = ichmv_ch(lnamep,1,'SETUP')
        nch = ICHMV(lnamep,nch,LCODE(ICODE),1,nco)   ! ff
      else ! mnemonic name
        call trkall(itras(1,1,1,1,isubpass,istn,icode),
     .  lmode(1,istn,icode),
     .  itrk,lpmode,npmode,ifan(istn,icode))
        nch = ICHMV(lnamep,1,LCODE(ICODE),1,nco)   ! ff
        CALL M3INF(ICODE,SPDIPS,IB)
C       choices in LBNAME are D,8,4,2,1,H,Q,E
        NCH=ICHMV(lnamep,NCH,LBNAME,IB,1)          ! b
        NCH=ICHMV(lnamep,NCH,Lpmode,1,npmode)      ! m
C       Convert pass index to integer or alpha
C       if (jchar(lmode,1).eq.ocapv) then         ! p
          cp=cvpass(isubpass:isubpass)
C       else
C         cp=cpass(isubpass:isubpass)
C       endif
        NCH=ICHMV_ch(lnamep,NCH,cp)
      endif  ! setup or mnemonic 

      return
      end
