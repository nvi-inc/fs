      subroutine setup_name(icode,isubpass,cnamep)

C SETUP_NAME generates the setup procedure name.

      include 'hardware.ftni'
      include '../skdrincl/freqs.ftni'
      include '../skdrincl/statn.ftni'
      include 'drcom.ftni'

C History
C 991102 nrv New. Removed from PROCS and SNAP.
C 991205 nrv Use letter codes for passes and not numbers.
! 2006Sep26 JMG. changed lnamep to ASCII. Got rid of all hollerith stuff.
! 2007Jul26 JMG. changed itype to logical knopass. Put in hardware.ftni

! functions
!
      integer trimlen
      character*1 cband_char

C Input
      integer icode,isubpass
C Output
!      integer*2 lnamep(*)
      character*12 cnamep
      integer nch
C Local
      integer npmode,nco
      character*4 cpmode
      character*28 cvpass
      character*1 cp ! selection from cpass or cvpass
!      integer iflch,ichmv_ch,ichmv
      integer num_trk_rec
      data cvpass /'ABCDEFGHIJKLMNOPQRSTUVWXYZAB'/

!      nco = iflch(lcode(icode),2)
      nco=trimlen(ccode(icode))
      if (knopass) then ! setup name
        cnamep="setup"//ccode(icode)(1:nco)
        nch=nco+6
      else ! mnemonic name
        call trkall(isubpass,istn,icode,cmode(istn,icode),
     >   itrk,cpmode,npmode,ifan(istn,icode),num_trk_rec)
!        nch = ICHMV(lnamep,1,LCODE(ICODE),1,nco)   ! ff
         cnamep=ccode(icode)(1:nco)//cband_char(vcband(1,istn,icode))
     >     //cpmode(1:npmode)//cvpass(isubpass:isubpass)
         nch=nco+npmode+3
C       Convert pass index to integer or alpha
C       if (jchar(lmode,1).eq.ocapv) then         ! p
          cp=cvpass(isubpass:isubpass)
C       else
C         cp=cpass(isubpass:isubpass)
C       endif
!        NCH=ICHMV_ch(lnamep,NCH,cp)
      endif  ! setup or mnemonic
! if two recorders, append the recorder number.
      if(krec_append) then
        cnamep(nch:nch)=crec(irec)
        nch=nch+1
      endif
!       nch=ichmv_ch(lnamep,nch,crec(irec))

      return
      end
