      SUBROUTINE vunps2m(modef,stdef,ivexnum,iret,ierr,lu,
     .ls2m)
C
C     VUNPS2M gets the S2 mode from the $TRACKS section 
C     for station STDEF and mode MODEF. 
C     All statements are gotten and checked before returning.
C     Any invalid values are not loaded into the returned
C     parameters.
C     Only generic error messages are written. The calling
C     routine should list the station name for clarity.
C
      include '../skdrincl/skparm.ftni'
C
C  History:
C 960817 nrv New.
C 961122 nrv Change fget_mode_lowl to fget_all_lowl
C 970117 nrv Remove "track_frame_format", irrelevant for S2.
C 970124 nrv Remove "lsm" from call.
C
C  INPUT:
      character*128 stdef ! station def to get
      character*128 modef ! mode def to get
      integer ivexnum ! vex file ref
      integer lu ! unit for writing error messages
C
C  OUTPUT:
      integer iret ! error return from vex routines, !=0 is error
      integer ierr ! error from this routine, >0 indicates the
C                    statement to which the VEX error refers,
C                    <0 indicates invalid value for a field
      integer*2 ls2m(8) ! recording format
C
C  LOCAL:
      character*128 cout
      integer nch,idumy
      integer ichmv_ch,fvex_len,fvex_field,fget_all_lowl,ptr_ch
C
C    Initialize.
      CALL IFILL(Ls2M,1,16,oblank)
C
C  1. The S2 record mode
C
      ierr = 1
      iret = fget_all_lowl(ptr_ch(stdef),ptr_ch(modef),
     .ptr_ch('S2_recording_mode'//char(0)),
     .ptr_ch('TRACKS'//char(0)),ivexnum)
      if (iret.ne.0) return
      iret = fvex_field(1,ptr_ch(cout),len(cout))
      NCH = fvex_len(cout)
      IF  (NCH.GT.8.or.NCH.le.0) THEN  !
        write(lu,'("VUNPS2M01 - Record mode name too long")')
        iret=-1
      else
        IDUMY = ICHMV_ch(LS2M,1,cout(1:NCH))
      END IF  !
C
      if (ierr.gt.0) ierr=0
      return
      end
