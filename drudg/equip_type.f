      subroutine equip_type(cr1)
C  equip_set displays the current equipment and prompts the user
C  to change if desired.
      include '../skdrincl/skparm.ftni'
      include 'drcom.ftni'
      include '../skdrincl/statn.ftni'
      include '../skdrincl/freqs.ftni'
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

C Input:
      character*(*) cr1
C LOCAL:
      integer ich,ic1,ic2,i,nch,irack,irec1,irec2,ic,il,ix
      integer irack_in,irec1_in,irec2_in,irec2_fix
      integer idum,ias2b,ichmv_ch,ichcm_ch,iflch,ichmv,trimlen,ichcm
      integer max_rack_local,max_rec_local,max_rec2_local
      integer*2 lrec1
      character*80 cbuf
      character*1 crec1
      character*1 cx(20),cit_rack(20),cit_rec1(20),cit_rec2(20),
     .            cy(20)
      data cx/'1','2',18*' '/

C 0. Determine current types.

C       max_rack_local = 8
C       max_rec_local = 7
        max_rack_local = max_rack_type
        max_rec_local = max_rec_type
        max_rec2_local = max_rec2_type
        ix=max(max_rack_local,max_rec_local)
        do i=1,ix
          cit_rack(i)=' '
          cit_rec1(i)=' '
          cit_rec2(i)=' '
          cy(i)=' '
        enddo
        if (ichcm_ch(lfirstrec(istn),1,'1').eq.0) cy(1)='*'
        if (ichcm_ch(lfirstrec(istn),1,'2').eq.0) cy(2)='*'
        irack_in=1
        do while (irack_in.le.max_rack_local.and.
     .    ichcm_ch(lstrack(1,istn),1,rack_type(irack_in)(1:8)).ne.0)
          irack_in=irack_in+1
        enddo
        if (irack_in.le.max_rack_local) cit_rack(irack_in)='*'
        irec1_in=1
        do while (irec1_in.le.max_rec_local.and.
     .    ichcm_ch(lstrec(1,istn),1,rec_type(irec1_in)(1:8)).ne.0)
          irec1_in=irec1_in+1
        enddo
        if (irec1_in.le.max_rec_local) cit_rec1(irec1_in)='*'
        irec2_in=1
        do while (irec2_in.le.max_rec_local.and.
     .    ichcm_ch(lstrec2(1,istn),1,rec_type(irec2_in)(1:8)).ne.0)
          irec2_in=irec2_in+1
        enddo
        if (irec2_in.le.max_rec_local) cit_rec2(irec2_in)='*'

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
          call ifill(lrec1,1,2,oblank)
          call char2hol(crec1,lrec1,1,1)
        endif

C 2. Interactive input

      else ! interactive
 1      WRITE(LUSCN,9019) (lantna(I,ISTN),I=1,4),
     .  (lstrack(i,istn),i=1,4),(lstrec(i,istn),i=1,4),
     .  (lstrec2(i,istn),i=1,4),lfirstrec(istn)

9019    FORMAT(
     .       ' Equipment set for ',4a2,' is: '/
     .       '   Rack: ',4a2,' Recorder 1: ',4a2, ' Recorder 2: ',4a2/
     .       '   Schedule will start with recorder ',a1/
     .       '|Select rack  |Select Rec 1 |Select Rec 2 '
     .       '|Select starting recorder')
          do i=1,ix ! write each line
            if (i.le.max_rack_local.and.i.le.max_rec_local) then ! full
              if (i.gt.max_rec2_local) then ! no rec 2 (3=Mk3)
                write(luscn,9018) cit_rack(i),i,rack_type(i)(1:8),
     .          cit_rec1(i),i,rec_type(i)(1:8),
     .          cy(i),cx(i)
9018            format('|',a1,i2,'=',a8,' |',a1,i2,'=',a8,' |',
     .          12x,         ' |',4x,a1,a1)
              else ! write them all
                write(luscn,9020) cit_rack(i),i,rack_type(i)(1:8),
     .          cit_rec1(i),i,rec_type(i)(1:8),
     .          cit_rec2(i),i,rec_type(i)(1:8),cy(i),cx(i)
9020            format('|',a1,i2,'=',a8,' |',a1,i2,'=',a8,' |',
     .          a1,i2,'=',a8,' |',4x,a1,a1)
              endif
            else if (i.le.max_rack_local.and.i.gt.max_rec_local) then ! rack only
              write(luscn,9021) cit_rack(i),i,rack_type(i)(1:8),
     .        cy(i),cx(i)
9021          format('|',a1,i2,'=',a8,' |',12x,' |',12x,' |',4x,a1,a1)
            else if (i.gt.max_rack_local.and.i.le.max_rec_local) then ! rec only
              write(luscn,9022) cit_rec1(i),i,rec_type(i)(1:8),
     .        cit_rec2(i),i,rec_type(i)(1:8),cy(i),cx(i)
9022          format('|',12x,' |',a1,i2,'=',a8,' |',a1,i2,'=',a8,' |',
     .        4x,a1,a1)
            endif
          enddo
          write(luscn,9023)
9023      format('|  0=no change|  0=no change|  0=no change|'/
     .       ' Press <return> or type 0 0 0 0 for no change,'/
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
        idum = ichmv_ch(lrec1,1,'0 ')
        read(luusr,'(a)') cbuf
        call ifill(ibuf,1,80,oblank)
        call char2hol(cbuf,ibuf,1,ibuf_len)
        nch = iflch(ibuf,80)
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
              idum = ichmv(lrec1,1,ibuf,ic1,1)
              if (ichcm_ch(ibuf,ic1,'0').ne.0.and.
     .          ichcm_ch(ibuf,ic1,'1').ne.0.and.
     .          ichcm_ch(ibuf,ic1,'2').ne.0) then
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
          if ((irack.ge.1.and.irack.le.max_rack_local)) then 
            il=trimlen(rack_type(irack))
            if (ichcm_ch(lstrack(1,istn),1,
     .          rack_type(irack)(1:il)).ne.0) then ! change
              write(luscn,901) (lantna(i,istn),i=1,4),
     .        (lstrack(i,istn),i=1,4),rack_type(irack)(1:il)
901           format('EQUIP05 - CHANGED ',4a2,' rack from ',
     .        4a2,' to ',a)
              call ifill(lstrack(1,istn),1,8,oblank)
              idum = ichmv_ch(lstrack(1,istn),1,rack_type(irack)(1:il))
            endif ! change
C Retain switching from V mode to M if it's a Mk4 or VLBA4 
C formatter because they can't record V modes.
            if (ichcm_ch(lmode(1,istn,1),1,'VLBA').eq.0.and.
     .         (ichcm_ch(lstrack(1,istn),1,'Mark4').eq.0.or.
     .          ichcm_ch(lstrack(1,istn),1,'Mark3').eq.0.or.
     .          ichcm_ch(lstrack(1,istn),1,'VLBA4').eq.0)) then ! swap V->M
              do ic=1,ncodes
                write(luscn,903) (lnafrq(i,ic),i=1,4)
903             format('EQUIP01 - WARNING: changed recording ',
     .           'format for mode ',4a2,' from VLBA to Mk4.')
C               don't change because it could be a Mk3 mode??
C               idum = ichmv_ch(lmode(1,istn,ic),1,'M       ')
                idum = ichmv_ch(lmfmt(1,istn,ic),1,'M       ')
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
C Remove switching from M to V because both Mk4 and VLBA formatters
C can record M modes.
C            if (ichcm_ch(lmode(1,istn,1),1,'M').eq.0.and.
C     .          ichcm_ch(lstrack(1,istn),1,'VLBA').eq.0) then ! swap M->V
C              do ic=1,ncodes
C                write(luscn,904) (lnafrq(i,ic),i=1,4)
C904             format('EQUIP02 - WARNING: changed recording ',
C     .          'format for mode ',4a2,' from Mk4 to VLBA.')
C                idum = ichmv_ch(lmfmt(1,istn,ic),1,'V       ')
C                if (bitdens(istn,ic).lt.40000.d0) then
C                  bitdens(istn,ic) = 34020.0
C                else
C                  bitdens(istn,ic) = 56700.0
C                endif
C                write(luscn,908) bitdens(istn,ic)
C908             format('EQUIP07 - WARNING: changed recording ',
C     .           'bit density to ',f8.0)
C                write(luscn,905)
C              enddo
C            endif ! v--> M
          endif
        endif

C 4. Modify rec 1

        if (irec1.ne.0) then ! modify
          if (irec1.ge.1.and.irec1.le.max_rec_local) then
            il=trimlen(rec_type(irec1))
            if (ichcm_ch(lstrec(1,istn),1,
     .          rec_type(irec1)(1:il)).ne.0) then ! change
              write(luscn,902) (lantna(i,istn),i=1,4),
     .        (lstrec(i,istn),i=1,4),rec_type(irec1)(1:il)
902           format('EQUIP03 - CHANGED ',4a2,' recorder 1 from ',
     .        4a2,' to ',a)
              call ifill(lstrec(1,istn),1,8,oblank)
              idum = ichmv_ch(lstrec(1,istn),1,rec_type(irec1)(1:il))
            endif ! change
          endif
        endif

C 5. Modify rec 2
C    If rec 1 is K4, S2 or Mk3 then can't have rec 2
C       if ((ichcm_ch(lstrec(1,istn),1,'K4').eq.0.or.
C    .    ichcm_ch(lstrec(1,istn),1,'Mark3A').eq.0.or.
C    .    ichcm_ch(lstrec(1,istn),1,'S2').eq.0).and.
C    .    irec2_in.gt.1) then !  force rec 2 to none
C           irec2 = 1
C           irec2_fix = 1
C       endif
        if (irec2.ne.0) then ! modify
          if (irec2.ge.1.and.irec2.le.max_rec2_local) then
            il=trimlen(rec_type(irec2))
            if (ichcm_ch(lstrec2(1,istn),1,
     .            rec_type(irec2)(1:il)).ne.0) then ! try to change
C             If rec 1 is K4, S2 or Mk3 then can't have rec 2
C             if ((ichcm_ch(lstrec(1,istn),1,'K4').eq.0.or.
C    .             ichcm_ch(lstrec(1,istn),1,'Mark3A').eq.0.or.
C    .             ichcm_ch(lstrec(1,istn),1,'S2').eq.0).and.
C    .          (irec2.gt.1.or.(irec2.eq.1.and.irec2_fix.eq.1))) then ! 
C               write(luscn,915)
C915             format('EQUIP15 - Currently only recorder 1 is'
C    .          ' supported for K4, S2, and Mark3A.'/
C    .                 '          Recorder 2 set to none.')
C               irec2 = 1
C               call ifill(lstrec2(1,istn),1,8,oblank)
C               idum = ichmv_ch(lstrec2(1,istn),1,rec_type(irec2)(1:il))
C             else ! change
                write(luscn,909) (lantna(i,istn),i=1,4),
     .          (lstrec2(i,istn),i=1,4),rec_type(irec2)(1:il)
909             format('EQUIP09 - CHANGED ',4a2,' recorder 2 from ',
     .          4a2,' to ',a)
                call ifill(lstrec2(1,istn),1,8,oblank)
                idum = ichmv_ch(lstrec2(1,istn),1,rec_type(irec2)(1:il))
C             endif
            endif ! try to change
            if (nrecst(istn).eq.1.and.irec2.gt.1) then
              write(luscn,910) (lantna(i,istn),i=1,4)
910           format('EQUIP10 - WARNING: Second recorder was added to ',
     .        'the equipment for ',4a2,'.')
              nrecst(istn)=2
            else if (nrecst(istn).eq.2.and.irec2.eq.1) then
              write(luscn,911) (lantna(i,istn),i=1,4)
911           format('EQUIP11 - WARNING: Second recorder was removed ',
     .        'from equipment for ',4a2,'.')
              nrecst(istn)=1
            endif
          endif
        else ! check rec 2 anyway because rec 1 may have changed
        endif ! modify rec2

C 6. Modify first recorder

        if (ichcm_ch(lrec1,1,'0').ne.0) then ! modify firstrec
          call hol2upper(lrec1,2)
          if (ichcm(lfirstrec(istn),1,lrec1,1,1).ne.0) then ! change
            write(luscn,912) (lantna(i,istn),i=1,4),
     .      lfirstrec(istn),lrec1
912         format('EQUIP12 - CHANGED ',4a2,' first recorder from '
     .      a1,' to ',a1)
            call ifill(lfirstrec(istn),1,2,oblank)
            idum = ichmv(lfirstrec(istn),1,lrec1,1,1)
          endif ! change
        endif !modify firstrec
C       Now check firstrec
        if (ichcm_ch(lfirstrec(istn),1,'2').eq.0.and.
     .    (ichcm_ch(lstrec2(1,istn),1,'unused').eq.0.or.
     .    ichcm_ch(lstrec2(1,istn),1,'none').eq.0)) then ! can't do
          write(luscn,913)
913       format("EQUIP13 - Can't start the schedule with ",
     .    "Recorder 2 because it is "/" set to 'none' or 'unused'."/
     .    " First recorder has been reset to 1.") 
          idum = ichmv_ch(lfirstrec(istn),1,'1 ')
        elseif (ichcm_ch(lfirstrec(istn),1,'1').eq.0.and.
     .    (ichcm_ch(lstrec(1,istn),1,'unused').eq.0.or.
     .    ichcm_ch(lstrec(1,istn),1,'none').eq.0)) then ! can't do
          write(luscn,914)
914       format("EQUIP14 - Can't start the schedule with ",
     .    "Recorder 1 because it is "/" set to 'none' or 'unused'."/
     .    " First recorder has been reset to 2.") 
          idum = ichmv_ch(lfirstrec(istn),1,'2 ')
        else ! ok
        endif ! can't / ok
      return
      end
