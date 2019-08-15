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
! 2007Dec11 JMGipson.  Doesn't apend recorder if Recorder is Mark5
! 2012Sep13 JMG. Introduced km3form,kvform,km5form
! 2015May08 JMG. Added support for Rack type DBBC/Fila10g
! 2015Jan05 JMG. DBBC-->DBBC_DDC, DBBC/Fila10g-->DBBC_DDC/Fila10g
!                also added support for DBBC_PFB and DBBC_PFB/Fila10g

! Just some notes:
!  The difference between
!  VLBA    VLBA4 and VLBA5
!  Mark3   Mark4 and Mark5
!  Is the formatter.  
! VLBA =VLBA   rack VLBA formmatter
! VLBA4=VLBA  rack Mark4 formmater
! VLBA5=VLBA  rack Mark5 formmater
! Mark3=Mark3 rack Mark3 formattter.
! Mark4=Mark3 Rack Mark4 formatter.
! Mark5=Mark3 Rack Mark5 formatter

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
        km5Crec(i) =cstrec(istn,i)  .eq. "Mark5C"
        Km5APigwire(i) =cstrec(istn,i) .eq. "Mk5APigW"
        Km5Prec(i) =cstrec(istn,i)  .eq. "Mark5P"
        KK5Rec(i)  =cstrec(istn,i) .eq. "K5"
        Knorec(i)  =cstrec(istn,i) .eq. "none"
      end do

      kflexbuff = cstrec(istn,1) .eq. 'FlexBuff'
      if(kflexbuff) then
        km5crec(1)=.true.
      endif
! Note: Flexbuff is like Mark5C, but is not a disk. Hence no bankcheck, etc. 

      cstrack_cap(istn)=cstrack(istn)
      call capitalize(cstrack_cap(istn))

!      km5disk=.false.
!     do i=1,2
!       if(Km5Prec(i).or.Km5Arec(i).or.km5brec(i).or. Km5ApigWire(i))
!    >    Km5disk=.true.
!     end do

      km5A=km5Arec(1) .or. km5Arec(2) .or.
     >     Km5Apigwire(1) .or.Km5APigwire(2)
      km5p=km5prec(1) .or. km5prec(2)
      km5B=km5Brec(1) .or. km5Brec(2)
      km5C=km5Crec(1) .or. km5Crec(2)
      km5disk = km5A .or. km5B .or. Km5C .or. kflexbuff 

      kk4=kk41rec(1) .or. kk41rec(2) .or. kk42rec(1) .or. kk42rec(2)

! set flag to indicate that recorder does not do "passes".
      knopass=km5disk    !Mark5 disks have no passes.
! other kinds of disks do as well
      do i=1,2
        if(ks2rec(i).or.kk41rec(i).or.kk42rec(i)) knopass=.true.
      end do

      do i=1,max_stn
         cstrack_cap(istn)=cstrack(istn)
         call capitalize(cstrack_cap(istn))
      end do 

C Racks     
      knorack = cstrack_cap(istn) .eq. "NONE"
      km3rack = cstrack_cap(istn) .eq. "MARK3A"
      km4rack = cstrack_cap(istn) .eq. "MARK4"
      km5rack = cstrack_cap(istn) .eq. "MARK5"

      kvrack  = cstrack_cap(istn) .eq. "VLBA" .or.
     >          cstrack_cap(istn) .eq. "VLBA/8" .or.
     >          cstrack_cap(istn) .eq. "VLBAG"
      kv4rack = cstrack_cap(istn) .eq. "VLBA4" .or.
     >          cstrack_cap(istn) .eq. "VLBA4/8"
      kv5rack = cstrack_cap(istn) .eq. "VLBA5"

      kvlbac_rack =cstrack_cap(istn) .eq. "VLBAC"
      kcdas_rack  =cstrack_cap(istn) .eq. "CDAS"
      kv5rack=kv5rack .or. kvlbac_rack .or. kcdas_rack



      kk41rack= cstrack_cap(istn)(1:4) .eq. "K4-1"
      kk42rack= cstrack_cap(istn)(1:4) .eq. "K4-2"
      klrack  = cstrack_cap(istn) .eq. "LBA"

      kmracks =km3rack .or. km4rack .or. km5rack
      kvracks =kv4rack .or. kvrack  .or. KV5rack 

      km4fmk4rack =cstrack_cap(istn)(1:3) .eq. "K4-" .and.
     >             cstrack_cap(istn)(5:7) .eq. "/M4"
      kk3fmk4rack =cstrack_cap(istn)(1:3) .eq. "K4-" .and.
     >             cstrack_cap(istn)(5:7) .eq. "/K3"
      k8bbc =   cstrack_cap(istn) .eq. "VLBA/8" .or.
     >          cstrack_cap(istn) .eq. "VLBA4/8"
      kdbbc_rack        = cstrack_cap(istn)(1:4) .eq.  "DBBC"   
      kfila10g_rack     = cstrack_cap(istn)(10:16) .eq. "FILA10G"

      kvform  = kvrack
      km3form = Km3rack .or. kk3fmk4rack
      km4form = km4rack .or. kv4rack .or. km4fmk4rack
      km5form = km5rack .or. kv5rack 


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
      if(km5a .or.km5b .or.km5b) krec_append=.false.

      kbbc=kvracks
      kifp=klrack
      kvc= kmracks .or. kk41rack.or.kk42rack

      return
      end
