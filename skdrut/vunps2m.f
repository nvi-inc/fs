      SUBROUTINE vunps2m(modef,stdef,ivexnum,iret,ierr,lu,
     .ls2m,lm)
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
      integer*2 lm(4) ! formatter mode 
C
C  LOCAL:
      character*128 cout
      integer nch,idumy
      integer ichmv_ch,fvex_len,fvex_field,fget_mode_lowl,ptr_ch
C
C
C  1. The S2 record mode
C
      ierr = 1
      CALL IFILL(Ls2M,1,16,oblank)
      iret = fget_mode_lowl(ptr_ch(stdef),ptr_ch(modef),
     .ptr_ch('S2_record_mode'//char(0)),
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
C  2. The track frame format
C
      ierr = 1
      CALL IFILL(LM,1,8,oblank)
      iret = fget_mode_lowl(ptr_ch(stdef),ptr_ch(modef),
     .ptr_ch('track_frame_format'//char(0)),
     .ptr_ch('TRACKS'//char(0)),ivexnum)
      if (iret.ne.0) return
      iret = fvex_field(1,ptr_ch(cout),len(cout))
      NCH = fvex_len(cout)
      IF  (NCH.GT.8.or.NCH.le.0) THEN  !
        write(lu,'("VUNPTRK01 - Track format name too long")')
        iret=-1
      else
        IDUMY = ICHMV_ch(LM,1,cout(1:NCH))
      END IF  !

      if (ierr.gt.0) ierr=0
      return
      end
