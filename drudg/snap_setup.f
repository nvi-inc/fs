      subroutine snap_setup(ipas,istnsk,icod,iobs,kerr)
! include files.
      include '../skdrincl/skparm.ftni'
      include 'drcom.ftni'
      include '../skdrincl/statn.ftni'
      include '../skdrincl/sourc.ftni'
      include '../skdrincl/freqs.ftni'
      include '../skdrincl/skobs.ftni'
      include 'hardware.ftni'           !This contains info only about the recorders.
! functions

! passed variables
      integer istnsk    !index #.
      integer ipas(*)   !Pass number
      integer icod
      integer iobs
      logical kerr

! local variables.
      integer itype
      integer ndx

      integer*2 LNAMEP(6)
      character*12 cnamep
      equivalence (lnamep,cnamep)

      character*80 ldum

! start of code
      if (km5.or. km5p .or.ks2.or.kk4) then ! setup proc names
        itype=1
      else ! mnemonic proc names
        itype=2
        if (ipas(istnsk).le.0) then ! invalid pass
          write(luscn,9912) ipas(istnsk),icod
          return
        endif ! invalid pass
        ndx = ihddir(1,ipas(istnsk),istn,icod) 	! subpass
        if (ndx.le.0) then 			! invalid head position
          write(luscn,9912) ipas(istnsk),icod,iobs
9912      format(/'SNAP_SETUP - Illegal head position or pass',
     .    ' for pass ',i3,' in mode ',i2, ' scan ',i3)
          return
        endif
      endif

      cnamep=" "
      call setup_name(itype,icod,ndx,lnamep)
      call c2lower(cnamep,cnamep)  		!make it lower case
C     Don't use the pass number for Mk5-only
      if(km5) then
         write(lufile,"(a)") cnamep
      else
         write(ldum,"(a,'=',i3)") cnamep,ipas(istnsk)
         call squeezewrite(lufile,ldum)
      endif
      return
      end



