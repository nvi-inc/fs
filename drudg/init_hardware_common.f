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
!
C Input
      integer istn

C Called by: PROCS, SNAP
C  LOCAL:

      crec(1)="1"
      crec(2)="2"
C Equipment type has been set by schedule file, Option 11, or control file.
! S2
      ks2rec(1)= cstrec(istn)  .eq. "S2"
      ks2rec(2)= cstrec2(istn) .eq. "S2"
C This is for VLBA but not for VLBA4
      kvrec(1)=  cstrec(istn)  .eq. "VLBA"
      kvrec(2)=  cstrec2(istn) .eq. "VLBA"
C This is only for VLBA4
      kv4rec(1)=  cstrec(istn)  .eq. "VLBA4"       !Note: including space differentiates between VLBA and VLBA4
      kv4rec(2)=  cstrec2(istn) .eq. "VLBA4"
C This is for Mark3A
      km3rec(1)= cstrec(istn) 	.eq. "Mark3A"
      km3rec(2)= cstrec2(istn) 	.eq. "Mark3A"
C This is for Mark4
      km4rec(1)  = cstrec(istn)  .eq. "Mark4"
      km4rec(2)  = cstrec2(istn) .eq. "Mark4"
C Mark5 recorders
      km5rec(1)  =cstrec(istn)   .eq. "Mark5A"
      km5rec(2)  =cstrec2(istn)  .eq. "Mark5A"
! Mark5P
      km5prec(1)  =cstrec(istn)  .eq. "Mark5P"         !note capital P
      km5prec(2)  =cstrec2(istn) .eq. "Mark5P"

      km5 =km5rec(1) .or. km5rec(2)
      km5p=km5prec(1) .or. km5prec(2)

C K4 recorders
      kk41rec(1)  = cstrec(istn)  .eq. "K4-1"
      kk41rec(2)  = cstrec2(istn) .eq. "K4-1"
      kk42rec(1)  = cstrec(istn)  .eq. "K4-2"
      kk42rec(2)  = cstrec2(istn) .eq. "K4-2"
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
