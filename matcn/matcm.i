c commonf for mode communication between iat and matcn
c
      integer imode              !mode matcn being run in
      integer*4 centisec(2)      !for mode=-53 time before/after communication
c                                 last word is the time-out in use
      common/matcm/centisec,imode
