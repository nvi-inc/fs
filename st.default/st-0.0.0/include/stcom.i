*
* This file is part of the station example code
*
* To the extent possible under law, the author(s) have dedicated all
* copyright and related and neighboring rights to this software to the public
* domain worldwide. This software is distributed without any warranty.
*
* You should have received a copy of the CC0 Public Domain Dedication along
* with this software. If not, see <http://creativecommons.org/publicdomain/zero/1.0/>.
*
c stcom.i
c
c  This include file includes all the sections of stcom.
c  By convention each section is a named common block with a name of the
c  form 'stcom_x' where 'x' is the name of the section, e.g. 'stcom_init'
c  for the initialization section.
c
c  Each part must have as its first and last variables, integers (no *)
c  with names of the form 'b_x' and 'e_x' respectively (b for begin,
c  e for end), where 'x' again is the name of the section.
c
c  See fscom_init.i for an example.
c
      include '../fs/include/params.i'
      include 'st_com.i'
      include 'tr_com.i'
