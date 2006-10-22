      SUBROUTINE ckroll(ndefs,nsteps,irtrk,inc_period,reinit_period,
     .istn,icode,croll)
C
C     CKROLL stores and checks the barrell roll definition. 
C     If the roll is a canned one then CROLL gets set to
C     a standard name. If the roll is non-standard then
C     CROLL is set to M.
C
      include '../skdrincl/skparm.ftni'
      include '../skdrincl/freqs.ftni'
C
C  History:
C 020112 nrv New. Called by VMOINP.
C
C  INPUT:
      integer ndefs,nsteps,inc_period,reinit_period
      integer irtrk(18,32)
      integer istn,icode
C  OUTPUT
      character*4 croll ! code for this roll, M is non-standard
C
C  LOCAL:
      integer i,j,ir,ii
      logical kmatch
C
C 0. If the roll is OFF then we're done.

      if (croll.eq."off") return

C 1. Initialize the roll type to non-standard. If the roll is
C    determined to be non-standard at any point then just return.
C    Store the roll into common now.

      iroll_inc_period(istn,icode) = inc_period
      iroll_reinit_period(istn,icode) = reinit_period
      nrolldefs(istn,icode) = ndefs
      nrollsteps(istn,icode) = nsteps
! 1. Initialize this roll type for this station, code.
      call init_roll_type(istn,icode,ndefs,nsteps,irtrk)

C 2. Check the roll against the two canned rolls.

      kmatch = .false. ! initialize
      croll = " "
      do ir=1,2 
        if (croll.eq." ".and.inc_period.eq.ircan_inc(ir).and.
     .     reinit_period.eq.ircan_reinit(ir).and.
     .     ndefs.eq.nrcan_defs(ir).and.nrcan_steps(ir).eq.nsteps) then ! continue
          kmatch = .true.
          do i=1,nrcan_defs(ir)
            do j=1,2+nrcan_steps(ir)
              if (irtrk(j,i).ne.icantrk(j,i,ir)) then
                kmatch = .false.
C               write(6,"('bad idef=',i2,' jstep=',i2,' can=',i2,
C    .          ' sk=',i2)") i,j,icantrk(j,i,ir),irtrk(j,i)
              endif
            enddo
          enddo
          if (kmatch.and.ir.eq.1) croll = "8"
          if (kmatch.and.ir.eq.2) croll = "16"
        endif ! continue
      enddo

C 3. Check for canned rolling on the second head. The above check will not
C    match because the number of defs won't match the smaller number.

      if (croll.eq." ") then ! no match with 1 head, check with two
        do ir=1,2
          if (croll.eq." ".and.inc_period.eq.ircan_inc(ir).and.
     .      reinit_period.eq.ircan_reinit(ir).and.
     .      ndefs.eq.2*nrcan_defs(ir).and.
     .      nrcan_steps(ir).eq.nsteps) then ! continue
          kmatch = .true.
C         Check the first set for head 1
          do i=1,nrcan_defs(ir)
            do j=1,2+nrcan_steps(ir)
              if (irtrk(j,i).ne.icantrk(j,i,ir)) then
                kmatch = .false.
C               write(6,"('1bad idef=',i2,' jstep=',i2,' can=',i2,
C    .          ' sk=',i2)") i,j,icantrk(j,i,ir),irtrk(j,i)
              endif
            enddo
          enddo
C         Check for head 2 and the same set
          do i=1,nrcan_defs(ir)
            ii = i+nrcan_defs(ir) ! pick up second set from schedule
            do j=1,2+nrcan_steps(ir)
              if (j.eq.1) then ! check the head
                if (irtrk(j,ii).ne.2) kmatch = .false.
              else ! check rest of steps
                if (irtrk(j,ii).ne.icantrk(j,i,ir)) then
                  kmatch = .false.
C                 write(6,"('2bad idef=',i2,' jstep=',i2,' can=',i2,
C    .            ' sk=',i2)") ii,j,icantrk(j,i,ir),irtrk(j,ii)
                endif
              endif
            enddo
          enddo
          if (kmatch.and.ir.eq.1) croll = "8"
          if (kmatch.and.ir.eq.2) croll = "16"
          endif ! continue
        enddo
      endif ! no match with 1 head, check with two


      if (croll.eq."") croll = "M"
      return
      end

