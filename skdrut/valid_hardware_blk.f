      block data
      include "../skdrincl/valid_hardware.ftni"

      data (crack_type(i),crack_type_cap(i), i=1, max_rack_type) /
     >  'none'   ,    'NONE'       ,               ! 1
     >  'Mark3A' ,    'MARK3A'     ,               ! 2
     >  'VLBA'   ,    'VLBA'       ,               ! 3
     >  'VLBAG'  ,    'VLBAG'      ,               ! 4
     >  'VLBA/8' ,    'VLBA/8'     ,               ! 5
     >  'VLBA4/8',    'VLBA4/8'    ,               ! 6
     >  'Mark4'  ,    'MARK4'      ,               ! 7
     >  'VLBA4'  ,    'VLBA4'      ,               ! 8
     >  'K4-1'   ,    'K4-1'       ,               ! 9
     >  'K4-2'   ,    'K4-2'       ,               ! 10
     >  'K4-1/K3',    'K4-1/K3'    ,               ! 11
     >  'K4-2/K3',    'K4-2/K3'    ,               ! 12
     >  'K4-1/M4',    'K4-1/M4'    ,               ! 13
     >  'K4-2/M4',    'K4-2/M4'    ,               ! 14
     >  'LBA'    ,    'LBA'        ,               ! 15
     >  'Mark5'  ,    'Mark5'      ,               ! 16
     >  'VLBA5'  ,    'VLBA5'      ,               ! 17
     >  'unknown',    'UNKNOWN' /

      data (crec_type(i),crec_type_cap(i), i=1, max_rec_type) /
     >   'none'     ,    'NONE'      ,                 ! 1
     >   'unused'   ,    'UNUSED'    ,                 ! 2
     >   'Mark3A'   ,    'MARK3A'    ,                 ! 3
     >   'VLBA'     ,    'VLBA'      ,                 ! 4
     >   'VLBA4'    ,    'VLBA4'     ,                 ! 5
     >   'Mark4'    ,    'MARK4'     ,                 ! 6
     >   'S2'       ,    'S2'        ,                 ! 7
     >   'K4-1'     ,    'K4-1'      ,                 ! 8
     >   'K4-2'     ,    'K4-2'      ,                 ! 9
     >   'Mark5A'   ,    'MARK5A'    ,                 ! 10
     >   'Mk5APigW' ,    'MK5APIGW'  ,                 ! 11
     >   'Mark5P'   ,    'MARK5P'    ,                 ! 12
     >   'K5'       ,    'K5'        ,                 ! 13
     >   'Mark5B'   ,    'MARK5B'    ,                 ! 14
     >   'unknown'  ,    'UNKNOWN' /                   ! 15
                                                       ! 16
                                                       ! 17
      End
