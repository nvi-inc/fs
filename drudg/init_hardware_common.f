      subroutine init_hardware_common(istn)

C SET_TYPE sets the logical variables indicating equipment types.
      include 'hardware.ftni'
      include '../skdrincl/statn.ftni'
C History
C 991102 nrv New. Removed from PROCS.
C 991205 nrv Correct spelling of 8-BBC rack names. Remove VLBAG.
C 991214 nrv Add kkfmk4rack for K3 formatters
C 000329 nrv VLBAG rack same as VLBA
C 020923 nrv Add Mark5 recorders.
C 021111 jfq Add LBA racks.
! Based on old set_type.  Initializes a common block which contains Hardware info.
! 2004Feb15 JMGipson  Added KK5 recorder type.
!                     Rearranged flag setting to make it tighter.
!
C Input
      integer istn

C Called by: PROCS, SNAP
      integer i

      crec(1)="1"
      crec(2)="2"
C Equipment type has been set by schedule file, Option 11, or control file.

! set the flags for the recorder type.
      do i=1,2
        km3rec(i) = cstrec(istn,i)  .eq. "Mark3A"
        kvrec(i) =  cstrec(istn,i)  .eq. "VLBA"    !VLBA but not VLBA4
        kv4rec(i) = cstrec(istn,i)  .eq. "VLBA4"
        km4rec(i) = cstrec(istn,i)  .eq. "Mark4"
        ks2rec(i) = cstrec(istn,i)  .eq. "S2"      !S2
        KK41rec(i) =cstrec(istn,i)  .eq. "K4-1"
        KK42rec(i) =cstrec(istn,i)  .eq. "K4-2"
        km5Arec(i) =cstrec(istn,i)  .eq. "Mark5A"
        km5Brec(i) =cstrec(istn,i)  .eq. "Mark5B"
        Km5APigwire(i) =cstrec(istn,i) .eq. "Mk5APigW"
        Km5Prec(i) =cstrec(istn,i)  .eq. "Mark5P"
        KK5Rec(i)  =cstrec(istn,i) .eq. "K5"
        Knorec(i)  =cstrec(istn,i) .eq. "none"
      end do

      km5disk=.false.
      do i=1,2
        if(Km5Prec(i).or.Km5Arec(i).or.km5brec(i).or. Km5ApigWire(i))
     >    Km5disk=.true.
      end do

      km5A=km5Arec(1) .or. km5Arec(2) .or.
     >     Km5Apigwire(1) .or.Km5APigwire(2)
      km5p=km5prec(1) .or. km5prec(2)
      km5B=km5Brec(1) .or. km5Brec(2)

      kk4=kk41rec(1) .or. kk41rec(2) .or. kk42rec(1) .or. kk42rec(2)

! set flag to indicate that recorder does not do "passes".
      knopass=km5disk    !Mark5 disks have no passes.
! other kinds of disks do as well
      do i=1,2
        if(ks2rec(i).or.kk41rec(i).or.kk42rec(i)) knopass=.true.
      end do

C Racks
      km3rack = cstrack(istn) .eq. "Mark3A"
      km4rack = cstrack(istn) .eq. "Mark4"
      km5rack = cstrack(istn) .eq. "Mark5"

      kvrack  = cstrack(istn) .eq. "VLBA" .or.
     >          cstrack(istn) .eq. "VLBA/8" .or.
     >          cstrack(istn) .eq. "VLBAG"
      kv4rack = cstrack(istn) .eq. "VLBA4" .or.
     >          cstrack(istn) .eq. "VLBA4/8"
      kv5rack = cstrack(istn) .eq. "VLBA5"


      kk41rack= cstrack(istn)(1:4) .eq. "K4-1"
      kk42rack= cstrack(istn)(1:4) .eq. "K4-2"
      klrack  = cstrack(istn) .eq. "LBA"

      kmracks =km3rack  .or. km4rack .or. km5rack
      kvracks =kv4rack.or.kvrack

      km4fmk4rack =cstrack(istn)(1:3) .eq. "K4-" .and.
     >             cstrack(istn)(5:7) .eq. "/M4"
      kk3fmk4rack =cstrack(istn)(1:3) .eq. "K4-" .and.
     >             cstrack(istn)(5:7) .eq. "/K3"
      k8bbc =   cstrack(istn) .eq. "VLBA/8" .or.
     >          cstrack(istn) .eq. "VLBA4/8"

      km4form = km4rack .or. kv4rack .or. km4fmk4rack

! Set up krec_append flag.
      if(cstrec(istn,2) .eq. "none") then
        krec_append=.false.
        nrecst(istn)=1
        kuse(1) = .true.
        kuse(2) = .false.
      else
        nrecst(istn)=2
        krec_append=.true.
        do i=1,2
         kuse(i)= cstrec(istn,i) .ne. "unused" .and.
     >            cstrec(istn,i) .ne. "none"
        end do
      endif

      kbbc=kvracks.or.kv5rack
      kifp=klrack
      kvc= kmracks .or. kk41rack.or.kk42rack

      return
      end
