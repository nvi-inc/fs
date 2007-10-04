      subroutine proc_load_unload()
! Write out standard load & unload procedures
      include 'hardware.ftni'
      include '../skdrincl/statn.ftni'
      include 'drcom.ftni'

! History
! 2007Jul13 JMGipson Separated from procs.f

! local
      character*12 cnamep

C UNLOADER procedure
      do irec=1,nrecst(istn) ! loop on recorders
        if(ks2rec(irec)) then
          itime2stop=0   !time to stop the tape in seconds.
        else
          itime2stop=3
        endif
        if (kuse(irec) .and. .not.Km5disk) then
          cnamep="unloader"
          if (krec_append) cnamep(9:9)=crec(irec)
          call proc_write_define(lu_outfile,luscn,cnamep)

          if (ks2rec(irec)) then
            call snap_et()
            call snap_rec('=eject')
          else if (kk41rec(irec).or.kk42rec(irec)) then
            call snap_rec('=eject')
            write(lu_outfile,"('!+10s')")
            if (krec_append) then
              write(lu_outfile,'(a)') "oldtape"//crec(irec)//"=$"
            else
              write(lu_outfile,'(a)') "oldtape"//"=$"
            endif

            write(lu_outfile,"('!+20s')")
          else if (kvrec(irec).or.kv4rec(irec).or.km3rec(irec).or.
     .      km4rec(irec)) then
            write(lu_outfile,"('!+5s')")

            call snap_enable()
            call snap_tape('=off ')

            if (kvrec(irec).or.kv4rec(irec)) then
              call snap_rec('=unload')
            endif
            if (km3rec(irec).or.km4rec(irec)) then
              call snap_st('=rev,80,off ')
            endif
          endif
C       endif ! non-empty proces for single recorder
        write(lu_outfile,"('enddef')")
        endif ! procs for this recorder
      enddo ! loop on recorders
     
C LOADER procedure
      do irec=1,nrecst(istn) ! loop on recorders
        if(ks2rec(irec)) then
          itime2stop=0   !time to stop the tape in seconds.
        else
          itime2stop=3
        endif
        if (kuse(irec).and..not.Km5Disk) then
          cnamep="loader"
          if (krec_append) cnamep(7:7)=crec(irec)
          call proc_write_define(lu_outfile,luscn,cnamep)

          if (ks2rec(irec)) then
            call snap_rw()
            write(lu_outfile,"('!+10s')")
            call snap_et()
            call snap_tape('=reset')
          endif
          if (kk41rec(irec).or.kk42rec(irec)) then
            write(lu_outfile,"('!+25s')")
            call snap_tape('=reset')
            write(lu_outfile,"('!+6s')")
          endif

          if (kvrec(irec).or.kv4rec(irec)) then
            call snap_rec('=load')
            write(lu_outfile,"('!+10s')")
            call snap_tape('=low,reset')
          endif
          if (kvrec(irec).or.kv4rec(irec).or.km3rec(irec).or.
     .      km4rec(irec)) then
            call snap_st('=for,135,off ')
C jfq  loader now winds on 200ft for thin tapes !!
            if (maxtap(istn).gt.17000) then
              write(lu_outfile,"('!+22s')")
            else
              write(lu_outfile,"('!+11s')")
            endif
C jfq ends
            call snap_et()
          endif
          write(lu_outfile,"(a)") 'enddef'

        endif ! procs for this recorder
      enddo ! loop on recorders

C MOUNTER procedure
      if (krec_append) then ! only for 2-rec stations
       do irec=1,nrecst(istn) ! loop on recorders
        if (kuse(irec)) then ! procs for this recorder
          cnamep="mounter"
          if (krec_append) cnamep(8:8)=crec(irec)
          call proc_write_define(lu_outfile,luscn,cnamep)

          if (kvrec(irec).or.kv4rec(irec)) then
             call snap_rec('=load')
          endif ! non-empty only for VLBA/4
          write(lu_outfile,"(a)") 'enddef'
        endif ! procs for this recorder
      enddo ! loop on recorders
      endif ! only for 2-rec stations
      return
      end

