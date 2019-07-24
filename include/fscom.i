c fscom.i
c
c  This include file includes all the sections of fscom.
c  By convention each section is a named common block with a name of the
c  form 'fscom_x' where 'x' is the name of the section, e.g. 'fscom_init'
c  for the initialization section.
c
c  Each part must have as its first and last variables, integers (no *)
c  with names of the form 'b_x' and 'e_x' respectively (b for begin,
c  e for end), where 'x' again is the name of the section.
c
c  See fscom_init.i for an example.
c
      include '/usr2/fs/include/params.i'
      include '/usr2/fs/include/fscom_init.i'
      include '/usr2/fs/include/fscom_quik.i'
      include '/usr2/fs/include/fscom_dum.i'
