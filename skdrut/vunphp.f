      SUBROUTINE vunphp(modef,stdef,ivexnum,iret,ierr,lu,
     .index,pos1,pos2,nhdpos,cpassl,indexl,csubl,npassl)
C
C     VUNPHP gets the head positions and pass information
C     for station STDEF and mode MODEF and converts it.
C     All statements are gotten and checked before returning.
C     Any invalid values are not loaded into the returned
C     parameters.
C     Only generic error messages are written. The calling
C     routine should list the station name for clarity.
C
      include '../skdrincl/skparm.ftni'
C
C  History:
C 960520 nrv New.
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
      integer index(max_index) ! list of index positions
      double precision pos1(max_index),pos2(max_index) ! head offsets
      integer nhdpos ! number of head positions found
      integer indexl(max_pass) ! list of index positions
      character*1 csubl(max_pass) ! list of subpasses
      character*3 cpassl(max_pass) ! list of passes
      integer npassl ! number of passes found
C
C  LOCAL:
      character*128 cout,cunit
      double precision d
      character*12 cx
      integer*2 ldum(6)
      integer il,ih,i,j
      integer fvex_len,fvex_double,fvex_int,fvex_field,fget_mode_lowl,
     .fvex_units,ias2b,ptr_ch
C
C
C  1. Headstack positions
C
      ierr = 1
      iret = fget_mode_lowl(ptr_ch(stdef),ptr_ch(modef),
     .ptr_ch('headstack_pos'//char(0)),
     .ptr_ch('HEAD_POS'//char(0)),ivexnum)
      ih=0
      do while (ih.lt.max_index.and.iret.eq.0) ! get all head pos 
        ih=ih+1

C  1.1 Index number

        ierr = 11
        iret = fvex_field(1,ptr_ch(cout),len(cout)) ! get index
        if (iret.ne.0) return
        index(ih)=0
        iret = fvex_int(ptr_ch(cout),i)
        if (iret.ne.0) return
        if (i.le.0.or.i.gt.max_index) then
          ierr = -1
          write(lu,'("VUNPHP02 - Invalid index value ",i5,
     .    "must be 1 to ",i3)') i,max_index
        else
          index(ih)=i
        endif
C
C  1.2 List of head positions

        ierr = 12
        i=2
        do while (i.le.3.and.iret.eq.0)
          iret = fvex_field(i,ptr_ch(cout),len(cout)) ! get position
          if (iret.eq.0) then 
            iret = fvex_units(ptr_ch(cunit),len(cunit))
            if (iret.ne.0) return
            iret = fvex_double(ptr_ch(cout),ptr_ch(cunit),d) ! convert to binary
            if (iret.eq.0) then
              if (i.eq.2) pos1(ih) = d*1.d06
              if (i.eq.3) pos2(ih) = d*1.d06
            endif
          endif
          i=i+1
        enddo

        iret = fget_mode_lowl(ptr_ch(stdef),ptr_ch(modef),
     .  ptr_ch('headstack_pos'//char(0)),
     .  ptr_ch('HEAD_POS'//char(0)),0)
      enddo
      nhdpos = ih

C  2. Pass order list
C
      ierr = 2
      iret = fget_mode_lowl(ptr_ch(stdef),ptr_ch(modef),
     .ptr_ch('pass_order'//char(0)),
     .ptr_ch('PASS_ORDER'//char(0)),ivexnum)
      if (iret.ne.0) return

C  2.1 <index><subpass>

      ierr = 21
      i=1
      do while (i.le.max_pass.and.iret.eq.0)
        iret = fvex_field(i,ptr_ch(cout),len(cout)) ! get field 
        if (iret.eq.0) then
          il=fvex_len(cout)
          cpassl(i)=cout(1:il) ! save the pass-order list
          csubl(i)=cout(il:il) ! one-character subpass
          cx = cout(1:il-1)
          call char2hol(cx,ldum,1,il-1)
          j=ias2b(ldum,1,il-1)
          if (j.lt.0.or.j.gt.nhdpos) then
            ierr=-3
            write(lu,'("VUNPHP03 - Invalid index in pass list",i5)') j
          else
            indexl(i)=j
          endif
          i=i+1
        endif
      enddo
      npassl = i-1

      if (ierr.gt.0) ierr=0
      return
      end
