      subroutine equip_type(cr1)
C  equip_set displays the current equipment and prompts the user
C  to change if desired.
      include '../skdrincl/skparm.ftni'
      include 'drcom.ftni'
      include '../skdrincl/statn.ftni'
      include '../skdrincl/freqs.ftni'
      include 'hardware.ftni'
C History
C 990730 nrv New.
C 990910 nrv Add warning message. Change LMODE and LMFMT from 'v' to
C            'm' or vice versa when needed.
C 990914 nrv Force bit density to 33333 for V-->M.
C 990914 nrv Force bit density to 34020 for M-->V.
C 991028 nrv Second recorder. Fix index bugs.
C 991101 nrv Starting recorder.
C 991102 nrv Don't print CHANGE message if no change. Don't change to
C            a recorder that is set to 'none'.
C 991103 nrv Force first recorder to A or B if the other one is 'none'.
C 991110 nrv K4, S2, and Mk3 can only be A and B must be none.
C 991123 nrv Recorders 1 and 2.
C 991208 nrv Check for 'unused' type.
C 991210 nrv Remove restriction on K4,S2,Mk3 as first recorder, i.e.
C            second recorder can be whatever is legal.
C 991211 nrv Mk3A is legal rec 2. Use max_rec2_type instead of a number.
C 000321 nrv For non-K4 FS restrict types to be displayed.
C 000814 nrv For FS 9.5 display all types.
C 010820 nrv Don't switch mode M to V, ok to switch V to M.
C 020515 nrv Check length of rack/rec name as well as letters, so
C            that "VLBA" does not match "VLBA4" if only the first
C            four letters are checked.
C 17Apr2003  JMG.  Added Mark5 option.
! 2005Feb15  JMG. Got rid of most holleriths.
! 2006Jul20. JMG. Disabled switching to Mark3 rack if not Mark3 mode.

C Input:
      character*(*) cr1
! functions
      integer trimlen
      integer iwhere_in_string_list
C LOCAL:
      integer ich,ic1,ic2,i,nch,irack,irec1,irec2,ic,ix
      integer irack_in,irec1_in,irec2_in
      integer ias2b
      integer max_rack_local,max_rec_local,max_rec2_local
      character*2 crec1
      character*1 cx(20),cit_rack(20),cit_rec1(20),cit_rec2(20),
     .            cy(20)
      character*1 lchar
      data cx/'1','2',18*' '/

C 0. Determine current types.

C       max_rack_local = 8
C       max_rec_local = 7
        max_rack_local = max_rack_type

        max_rec_local = max_rec_type
        if(Km5A_piggy .or.km5p_piggy) then
          max_rec_local=max_rec_local-3   !exclude Mark5A & Mark5P modes.
        endif

        max_rec2_local = max_rec2_type
        ix=max(max_rack_local,max_rec_local)
        do i=1,ix
          cit_rack(i)=' '
          cit_rec1(i)=' '
          cit_rec2(i)=' '
          cy(i)=' '
        enddo
        if(cfirstrec(istn) .eq. '1') cy(1)='*'
        if(cfirstrec(istn) .eq. '2') cy(2)='*'

        irack_in=iwhere_in_string_list(crack_type,max_rack_local,
     >    cstrack(istn))
        if(irack_in .eq. 0) then
           write(*,*) "Equip_type: Should never get here 1"
        else
           cit_rack(irack_in)="*"
        endif

        irec1_in=iwhere_in_string_list(crec_type,max_rec_local,
     >    cstrec(istn))
        if(irec1_in .eq. 0) then
          write(*,*) "Equip_type2: Should never get here 2"
        else
          cit_rec1(irec1_in)="*"
        endif

        irec2_in=iwhere_in_string_list(crec_type,max_rec_local,
     >    cstrec2(istn))
        if(irec2_in .eq. 0) then
          write(*,*) "Equip_type2: Should never get here 3"
        else
          cit_rec2(irec2_in)="*"
        endif
C 1. Batch input

      if (kbatch) then
        read(cr1,*,err=991) irack,irec1,irec2,crec1
991     if (irack.lt.1.or.irack.gt.max_rack_local) then
          write(luscn,9991)
9991      format('EQUIP04 - Invalid rack type.')
          return
        endif
        if (irec1.lt.1.or.irec1.gt.max_rec_local) then
          write(luscn,9992)
9992      format('EQUIP05 - Invalid recorder 1 type.')
          return
        endif
        if (irec2.lt.1.or.irec2.gt.max_rec_local.or.
     .    irec2.gt.max_rec2_local) then
          write(luscn,9993)
9993      format('EQUIP05 - Invalid recorder 2 type.')
          return
        endif
        if (crec1.ne.'1'.and.crec1.ne.'2') then
          write(luscn,9994)
9994      format('EQUIP06 - Invalid starting recorder.')
          return
        else
          crec1=" "
        endif

C 2. Interactive input

      else ! interactive
 1      WRITE(LUSCN,9019) cantna(ISTN),
     >  cstrack(istn),cstrec(istn),cstrec2(istn),lfirstrec(istn)

9019    FORMAT(
     .       ' Equipment set for ',a8,' is: '/
     .       '   Rack: ',a8,' Recorder 1: ',a8, ' Recorder 2: ',a8/
     .       '   Schedule will start with recorder ',a1/
     .       '|Select rack  |Select Rec 1 |Select Rec 2 '
     .       '|Select starting recorder')
          do i=1,ix ! write each line
            if (i.le.max_rack_local.and.i.le.max_rec_local) then ! full
              if (i.gt.max_rec2_local) then ! no rec 2 (3=Mk3)
                write(luscn,9018) cit_rack(i),i,crack_type(i),
     .          cit_rec1(i),i,crec_type(i),   cy(i),cx(i)
9018            format('|',a1,i2,'=',a8,' |',a1,i2,'=',a8,' |',
     .          12x,         ' |',4x,a1,a1)
              else ! write them all
                write(luscn,9020) cit_rack(i),i,crack_type(i),
     .          cit_rec1(i),i,crec_type(i),
     .          cit_rec2(i),i,crec_type(i),cy(i),cx(i)
9020            format('|',a1,i2,'=',a8,' |',a1,i2,'=',a8,' |',
     .          a1,i2,'=',a8,' |',4x,a1,a1)
              endif
            else if (i.le.max_rack_local.and.i.gt.max_rec_local) then ! rack only
              write(luscn,9021) cit_rack(i),i,crack_type(i),
     .        cy(i),cx(i)
9021          format('|',a1,i2,'=',a8,' |',12x,' |',12x,' |',4x,a1,a1)
            else if (i.gt.max_rack_local.and.i.le.max_rec_local) then ! rec only
              write(luscn,9022) cit_rec1(i),i,crec_type(i),
     .        cit_rec2(i),i,crec_type(i),cy(i),cx(i)
9022          format('|',12x,' |',a1,i2,'=',a8,' |',a1,i2,'=',a8,' |',
     .        4x,a1,a1)
            endif
          enddo
          write(luscn,9023)
9023      format('|  0=no change|  0=no change|  0=no change|'/
     .       ' Press <return> or type 0 for no change,'
     .       ' else type <rack> <rec1> <rec2> <start>'/ 
     .       '   ********************************************',
     .       '***********************'/
     .       '   ** CAUTION: Use these selections with care, ',
     .       'because the schedule **'/
     .       '   ** as written may not be consistent with ',
     .       'your choices.           **'/
     .       '   ********************************************',
     .       '***********************'/
     .       ' ? ',$)

        irack=0
        irec1=0
        irec2=0
        crec1="0 "
        read(luusr,'(a)') cbuf
        nch=trimlen(cbuf)
        ich=1
        call gtfld(ibuf,ich,nch,ic1,ic2) ! rack field
        if (ic1.eq.0) return
        irack= ias2b(ibuf(1),ic1,ic2-ic1+1)
        IF (irack.LT.0.OR.(irack.GT.max_rack_local)) then
          write(luscn,9991)
          GOTO 1
        endif
        call gtfld(ibuf,ich,nch,ic1,ic2) ! rec1 field
        if (ic1.ne.0) then ! rec1 specified
          irec1= ias2b(ibuf(1),ic1,ic2-ic1+1)
          IF (irec1.LT.0.OR.(irec1.GT.max_rec_local)) then
            write(luscn,9992)
            GOTO 1
          endif
          call gtfld(ibuf,ich,nch,ic1,ic2) ! rec2 field
          if (ic1.ne.0) then ! rec2 specified
            irec2= ias2b(ibuf(1),ic1,ic2-ic1+1)
            IF (irec2.LT.0.OR.(irec2.GT.max_rec_local).or.
     .        irec2.gt.max_rec2_local) then
              write(luscn,9993)
              GOTO 1
            endif
            call gtfld(ibuf,ich,nch,ic1,ic2) ! starting rec field
            if (ic1.ne.0) then ! rec1 specified
!              idum = ichmv(lrec1,1,ibuf,ic1,1)
              crec1=cbuf(ic1:ic1)
              if (crec1 .ne. "0" .and. crec1 .ne. "1" .and.
     >            crec1 .ne. "2") then
                write(luscn,9994)
                GOTO 1
              endif
            endif ! rec1 specified
          endif ! rec2 specified
        endif ! rec1 specified
      endif ! batch/interactive

C 3. Modify rack type

C Now modify the common variables and send warnings.
        if (irack.ne.0) then ! modify
          if (crack_type(irack) .eq. "unknown") then
            call write_error_and_pause(luscn,
     >       "EQUIP_TYPE: Warning! Can't change to unknown rack type!")
          else if (irack.ge.1.and.irack.le.max_rack_local) then
            lchar=cmode(istn,1)
            call capitalize(lchar)
            if(irack .eq. 2) then
              if(cstrack(istn) .ne. "Mark4" .and.
     >           cstrack(istn) .ne. "Mark3A") then
                nch=trimlen(cstrack(istn))
                call write_error_and_pause(luscn,
     >             "WARNING: Can not change "//cstrack(istn)(1:nch)//
     >             " rack to Mark3A!")
                return
              else if(.not. (lchar.ge."A".and.lchar.le."E") ) then
                call write_error_and_pause(luscn,
     >          "Can't change to Mark3A rack with non-Mark3A Mode: "//
     >           cmode(istn,1))
               return
              endif
            endif
            if (cstrack(istn) .ne. crack_type(irack)) then
              write(luscn,901) cantna(istn),
     >          cstrack(istn),crack_type(irack)
901           format('EQUIP05 - CHANGED ',a,' rack from ',
     >        a8,' to ',a)
              cstrack(istn)=crack_type(irack)
            endif ! change
C Retain switching from V mode to M if it's a Mk4 or VLBA4 
C formatter because they can't record V modes.
            if( cmode(istn,1) .eq. "VLBA" .and.
     >          (cstrack(istn)(1:5) .eq. "Mark4" .or.
     >           cstrack(istn)(1:5) .eq. "Mark3" .or.
     >           cstrack(istn)(1:5) .eq. "VLBA4")) then
              do ic=1,ncodes
                write(luscn,903) cnafrq(ic)
903             format('EQUIP01 - WARNING: changed recording ',
     .           'format for mode ',a,' from VLBA to Mk4.')
!                idum = ichmv_ch(lmfmt(1,istn,ic),1,'M       ')
                cmfmt(istn,ic)='M'
                if (bitdens(istn,ic).lt.40000.d0) then
                  bitdens(istn,ic) = 33333.0
                else
                  bitdens(istn,ic) = 56250.0
                endif
                write(luscn,907) bitdens(istn,ic)
907             format('EQUIP06 - WARNING: changed recording ',
     .           'bit density to ',f8.0)
                write(luscn,905)
905             format('NOTE: The schedule may not be consistent ',
     .           ' with this change.')
              enddo
            endif ! v--> M
          endif
        endif

C 4. Modify rec 1

      if((irec1.ge.1.and.irec1.le.max_rec_local) .and.
     >     (cstrec(istn) .ne. crec_type(irec1))) then
         if(crec_type(irec1) .eq. "unknown") then
            call write_error_and_pause(luscn,
     >    "EQUIP_TYPE: Warning! Can't change to recorder type unknown!")
         else
            write(luscn,902) cantna(istn),cstrec(istn),crec_type(irec1)
902         format('EQUIP03-CHANGED ',a,' recorder 1 from ',a,' to ',a)
            cstrec(istn)=crec_type(irec1)
         endif
      endif

C 5. Modify rec 2
C    If rec 1 is K4, S2 or Mk3 then can't have rec 2
      if((irec2.ge.1.and.irec2.le.max_rec2_local) .and.
     >    (cstrec2(istn) .ne. crec_type(irec2))) then
        write(luscn,909) cantna(istn),cstrec2(istn),crec_type(irec2)
909     format('EQUIP09 - CHANGED ',a,' recorder 2 from ',a,' to ',a)
        cstrec2(istn)=crec_type(irec2)
        if (nrecst(istn).eq.1.and.irec2.gt.1) then
          write(luscn,910) cantna(istn)
910       format('EQUIP10 - WARNING: Second recorder was added to ',
     .        'the equipment for ',a,'.')
              nrecst(istn)=2
        else if (nrecst(istn).eq.2.and.irec2.eq.1) then
           write(luscn,911) cantna(istn)
911        format('EQUIP11 - WARNING: Second recorder was removed ',
     .        'from equipment for ',a8,'.')
              nrecst(istn)=1
         endif
      endif ! modify rec2

C 6. Modify first recorder

      if(crec1 .eq.'0' .or. cfirstrec(istn) .eq. crec1) then
         continue       ! no change.
      else if((crec1 .eq. '1' .and.
     >   (cstrec(istn).eq.'unused'.or.cstrec(istn).eq.'none'))
     >    .or. (crec1 .eq. '2' .and.
     >   (cstrec2(istn).eq.'unused'.or.cstrec2(istn).eq.'none'))) then
            write(luscn,'(a,a,/,a)')
     >   "EQUIP12 - Can't start the schedule with Recorder ",crec1,
     >   " because it is set to 'none' or 'unused'."
      else
        write(luscn,912) cantna(istn), cfirstrec(istn),crec1
912     format('EQUIP13: CHANGED ',a,' first recorder from ',a,' to ',a)
        cfirstrec(istn)=crec1
      endif !modify firstrec
      return
      end
