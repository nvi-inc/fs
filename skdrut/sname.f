      subroutine sname(idayr,ihr,imin,scan_namep,scan_name,
     .idayr_next,ihr_next,imin_next)

C SNAME creates the scan ID for the scan_name command in the SNAP file.

      include '../skdrincl/skparm.ftni'
C History
C 000602 nrv New.
C 000616 nrv Check next scan name to see if the current one needs
C            a suffix.
C Input
      integer idayr,ihr,imin
      integer idayr_next,ihr_next,imin_next
      integer*2 scan_namep(5)
C Output
      integer*2 scan_name(5)
C Local
      integer z4000,z100,ix,nch
      character*1 cx
      integer*2 scan_next(4)
      integer ichmv_ch,ib2as,ichcm,ichcm_ch ! functions
      data z4000/z'4000'/,z100/z'100'/

C Create scan ID as ddd-hhmm. If this scan time is a duplicate in the
C schedule, then append a letter suffix.
C Format:     ddd-hhmma  ('a' is used for duplicates)
C             123456789  (9th is optional)
C Example:    145-1257
C             145-1304a    | ===========
C             145-1304b    | all scans with duplicate ddd-hhmm have a suffix
C             145-1304c    | ===========
C             145-1312
C             145-1402

      call ifill(scan_next,1,8,oblank)
      if (idayr_next.ge.0) then ! valid next
        nch = 1 + ib2as(idayr_next,scan_next,1,Z4000+3*Z100+3)
        nch = ichmv_ch(scan_next,nch,"-")
        nch = nch + ib2as(ihr_next,scan_next,nch,Z4000+2*Z100+2)
        nch = nch + ib2as(imin_next,scan_next,nch,Z4000+2*Z100+2)
      endif
      call ifill(scan_name,1,10,oblank)
      nch = 1 + ib2as(idayr,scan_name,1,Z4000+3*Z100+3)
      nch = ichmv_ch(scan_name,nch,"-")
      nch = nch + ib2as(ihr,scan_name,nch,Z4000+2*Z100+2)
      nch = nch + ib2as(imin,scan_name,nch,Z4000+2*Z100+2)
      if (ichcm_ch(scan_namep,1,' ').eq.0) then ! no previous scan name
        if (idayr_next.ge.0.and.ichcm(scan_name,1,scan_next,1,8).eq.0) 
     .    nch = ichmv_ch(scan_name,nch,'a') ! next one is duplicate
      else ! got a previous scan
        if (ichcm(scan_name,1,scan_namep,1,8).eq.0) then ! same as previous
C         Increment the suffix of the previous name and append to current name
          call hol2char(scan_namep,9,9,cx)
          ix = ichar(cx) + 1 ! increment last character
          nch = ichmv_ch(scan_name,nch,char(ix))
        else if (idayr_next.ge.0.and.
     .    ichcm(scan_name,1,scan_next,1,8).eq.0) then ! same as next
C         Use suffix "a" for the first of the duplicate set
          nch = ichmv_ch(scan_name,nch,'a') ! next one is duplicate
        endif ! same as previous/next
      endif ! no/got a previous scan name
      return
      end
