c commonf for mode communication between iat and matcn
c
      integer imode              !mode matcn being run in
      integer it1(13)            !for mode=-53 time before/after communication
c                                 last word is the time-out in use
      common/matcm/imode,it1
