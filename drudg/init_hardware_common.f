      subroutine init_hardware_common(istn)

C SET_TYPE sets the logical variables indicating equipment types.
      include '../skdrincl/skparm.ftni'
      include '../skdrincl/statn.ftni'
      include 'hardware.ftni'
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
C  LOCAL:
      character*8 cstrectmp(2)
      integer i

      crec(1)="1"
      crec(2)="2"
C Equipment type has been set by schedule file, Option 11, or control file.
      cstrectmp(1)=cstrec(istn)
      cstrectmp(2)=cstrec2(istn)

! set the flags for the recorder type.
      do i=1,2
        km3rec(i)= cstrectmp(i)  .eq. "Mark3A"
        kvrec(i)=  cstrectmp(i)  .eq. "VLBA"    !VLBA but not VLBA4
        kv4rec(i)= cstrectmp(i)  .eq. "VLBA4"
        km4rec(i)= cstrectmp(i)  .eq. "Mark4"
        ks2rec(i)= cstrectmp(i)  .eq. "S2"      !S2
        KK41rec(i)=cstrectmp(i)  .eq. "K4-1"
        KK42rec(i)=cstrectmp(i)  .eq. "K4-2"
        km5Arec(i)=cstrectmp(i)  .eq. "Mark5A"
        Km5APigwire(i) =cstrectmp(i) .eq. "Mk5APigW"
        Km5Prec(i)=cstrectmp(i)  .eq. "Mark5P"
        KK5Rec(I) =cstrectmp(i) .eq. "K5"
      end do

      km5A=km5Arec(1) .or. km5Arec(2) .or.
     >     Km5Apigwire(1) .or.Km5APigwire(2)
      km5p=km5prec(1) .or. km5prec(2)

C Racks
      kvrack = cstrack(istn) .eq. "VLBA" .or.
     >         cstrack(istn) .eq. "VLBA/8" .or.
     >         cstrack(istn) .eq. "VLBAG"
      k8bbc =  cstrack(istn) .eq. "VLBA/8" .or.
     >         cstrack(istn) .eq. "VLBA4/8"
      kv4rack = cstrack(istn) .eq. "VLBA4" .or.
     >          cstrack(istn) .eq. "VLBA4/8"
      km3rack = cstrack(istn) .eq. "Mark3A"
      km4rack = cstrack(istn) .eq. "Mark4"

      kk41rack = cstrack(istn)(1:4) .eq. "K4-1"
      kk42rack = cstrack(istn)(1:4) .eq. "K4-2"

      km4fmk4rack =cstrack(istn)(1:3) .eq. "K4-" .and.
     >             cstrack(istn)(5:7) .eq. "/M4"
      kk3fmk4rack =cstrack(istn)(1:3) .eq. "K4-" .and.
     >             cstrack(istn)(5:7) .eq. "/K3"
      klrack      =cstrack(istn) .eq. "LBA"

      km4form = km4rack .or. kv4rack .or. km4fmk4rack

! Set up krec_append flag.
      if (nrecst(istn).eq.1) then ! use rec 1 only
        kuse(1) = .true.
        kuse(2) = .false.
        krec_append = .false. ! don't append '1' or '2' to rec commands
      endif ! use rec 1 only
      if (nrecst(istn).eq.2) then ! one rec might be unused or 'none'
        kuse(1) = cstrec(istn) .ne. "unused" .and.
     >            cstrec(istn) .ne. "none"
        kuse(2) = cstrec2(istn) .ne. "unused" .and.
     >            cstrec2(istn) .ne. "none"
        krec_append = .true. ! do append '1' or '2' to rec commands
        if(cstrec(istn) .eq. "none") krec_append=.false.
      endif

      return
      end
