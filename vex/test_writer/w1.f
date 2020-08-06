*
* Copyright (c) 2020 NVI, Inc.
*
* This file is part of VLBI Field System
* (see http://github.com/nvi-inc/fs).
*
* This program is free software: you can redistribute it and/or modify
* it under the terms of the GNU General Public License as published by
* the Free Software Foundation, either version 3 of the License, or
* (at your option) any later version.
*
* This program is distributed in the hope that it will be useful,
* but WITHOUT ANY WARRANTY; without even the implied warranty of
* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
* GNU General Public License for more details.
*
* You should have received a copy of the GNU General Public License
* along with this program. If not, see <http://www.gnu.org/licenses/>.
*
      program w1
      integer ptr_ch
      call fcreate_version(ptr_ch('1.5'//char(0)))
      call fcreate_comment(ptr_ch(char(0)),ptr_ch('* comment'//char(0)))

C  2. $GLOBAL

      call fcreate_block(ptr_ch('GLOBAL'//char(0)))
      call fcreate_ref(ptr_ch('EXPER'//char(0)),
     &     ptr_ch('DBETST'//char(0))) 
      call fcreate_ref(ptr_ch('SCHEDULING_PARAMS'//char(0)),
     &     ptr_ch('SKED_PARAMS'//char(0))) 

      call fcreate_block(ptr_ch('EXPER'//char(0)))     
      call fcreate_comment(ptr_ch(char(0)),
     &     ptr_ch('* comment 2'//char(0)))
c
      call fcreate_block(ptr_ch('SCHED'//char(0)))     
c
      call fcreate_scan(ptr_ch('No001'//char(0)))
      call fcreate_start(ptr_ch('2005y039d16h47m53s'//char(0)))
      call fcreate_station(ptr_ch('Wf'//char(0)),
     &     ptr_ch('0'//char(0)),
     &     ptr_ch('sec'//char(0)),
     &     ptr_ch('40'//char(0)),
     &     ptr_ch('sec'//char(0)),
     &     ptr_ch('10877'//char(0)),
     &     ptr_ch('ft'//char(0)),
     &     ptr_ch('3A'//char(0)),
     &     ptr_ch('n'//char(0)))
      call fcreate_station_drive_list(ptr_ch('1'//char(0)))
      call fcreate_station_drive_list(ptr_ch(char(0)))
      call fend_scan
      call fcreate_comment(ptr_ch('t'//char(0)),
     &     ptr_ch('* comment 3'//char(0)))
c
      call fcreate_scan(ptr_ch('No002'//char(0)))
      call fcreate_start(ptr_ch('2006y039d16h47m53s'//char(0)))
      call fcreate_station(ptr_ch('Wz'//char(0)),
     &     ptr_ch('0'//char(0)),
     &     ptr_ch('sec'//char(0)),
     &     ptr_ch('40'//char(0)),
     &     ptr_ch('sec'//char(0)),
     &     ptr_ch('10877'//char(0)),
     &     ptr_ch('ft'//char(0)),
     &     ptr_ch('3A'//char(0)),
     &     ptr_ch('n'//char(0)))
      call fcreate_station_drive_list(ptr_ch('1'//char(0)))
      call fcreate_station_drive_list(ptr_ch(char(0)))
      call fend_scan
      call fcreate_comment(ptr_ch(char(0)),
     &     ptr_ch('* comment 4'//char(0)))
c
      call fcreate_block(ptr_ch('STATION'//char(0)))     

      call fcreate_block(ptr_ch('ANTENNA'//char(0)))
      call fcreate_def(ptr_ch('Hb'//char(0)))
      call fcreate_axis_type(ptr_ch('az'//char(0)),
     &                       ptr_ch('el'//char(0)),
     &                       ptr_ch(char(0)),
     &                       ptr_ch(char(0)))
      call fcreate_axis_type(ptr_ch('az'//char(0)),
     &                       ptr_ch('el'//char(0)),
     &                       ptr_ch('1'//char(0)),
     &                       ptr_ch('deg'//char(0)))
      call fcreate_axis_type(ptr_ch('az'//char(0)),
     &                       ptr_ch(char(0)),
     &                       ptr_ch(char(0)),
     &                       ptr_ch(char(0)))
c      call fcreate_pointing_sector(ptr_ch('ccw'//char(0)),
c     &                       ptr_ch('az'//char(0)),
c     &                       ptr_ch('-90'//char(0)),
c     &                       ptr_ch('deg'//char(0)),
c     &                       ptr_ch('90'//char(0)),
c     &                       ptr_ch('deg'//char(0)),
c     &                       ptr_ch(char(0)),
c     &                       ptr_ch(char(0)),
c     &                       ptr_ch(char(0)),
c     &                       ptr_ch(char(0)),
c     &                       ptr_ch(char(0)))
      call fcreate_pointing_sector(ptr_ch('cw'//char(0)),
     &                       ptr_ch('az'//char(0)),
     &                       ptr_ch('270'//char(0)),
     &                       ptr_ch('deg'//char(0)),
     &                       ptr_ch('450'//char(0)),
     &                       ptr_ch('deg'//char(0)),
     &                       ptr_ch('el'//char(0)),
     &                       ptr_ch('0'//char(0)),
     &                       ptr_ch('deg'//char(0)),
     &                       ptr_ch('88'//char(0)),
     &                       ptr_ch('deg'//char(0)))
      call fend_def
      call fcreate_block(ptr_ch('CLOCK'//char(0)))
      call fcreate_def(ptr_ch('Hb'//char(0)))

      call fcreate_clock(ptr_ch('1995y263d06h00m'//char(0)),
     &     ptr_ch('2.5'//char(0)),
     &     ptr_ch('usec'//char(0)),
     &     ptr_ch(char(0)),
     &     ptr_ch(char(0)))
      call fcreate_clock(ptr_ch(char(0)),
     &     ptr_ch('3.5'//char(0)),
     &     ptr_ch('usec'//char(0)),
     &     ptr_ch(char(0)),
     &     ptr_ch(char(0)))
      call fcreate_clock(ptr_ch('1995y263d05h00m'//char(0)),
     &     ptr_ch('2.5'//char(0)),
     &     ptr_ch('usec'//char(0)),
     &     ptr_ch('1995y263d06h20m'//char(0)),
     &     ptr_ch('1e-12'//char(0)))

      call fcreate_clock_early(ptr_ch('1995y263d06h00m'//char(0)),
     &     ptr_ch('2.5'//char(0)),
     &     ptr_ch('usec'//char(0)),
     &     ptr_ch(char(0)),
     &     ptr_ch(char(0)))
      call fcreate_clock_early(ptr_ch(char(0)),
     &     ptr_ch('3.5'//char(0)),
     &     ptr_ch('usec'//char(0)),
     &     ptr_ch(char(0)),
     &     ptr_ch(char(0)))
      call fcreate_clock_early(ptr_ch('1995y263d05h00m'//char(0)),
     &     ptr_ch('2.5'//char(0)),
     &     ptr_ch('usec'//char(0)),
     &     ptr_ch('1995y263d06h20m'//char(0)),
     &     ptr_ch('1e-12'//char(0)))
      call fend_def

      call fcreate_block(ptr_ch('FREQ'//char(0)))
      call fcreate_def(ptr_ch('SX'//char(0)))
      call fcreate_chan_def(ptr_ch('X'//char(0)),
     &                      ptr_ch('8500.99'//char(0)),
     &                      ptr_ch('MHz'//char(0)),
     &                      ptr_ch('U'//char(0)),
     &                      ptr_ch('2'//char(0)),
     &                      ptr_ch('MHz'//char(0)),
     &                      ptr_ch('CH1'//char(0)),
     &                      ptr_ch('BBCa'//char(0)),
     &                      ptr_ch('USB_CAL'//char(0)))
      call fcreate_chan_def_states(ptr_ch(char(0)))
c
      call fcreate_chan_def(ptr_ch(char(0)),
     &                      ptr_ch('8500.99'//char(0)),
     &                      ptr_ch('MHz'//char(0)),
     &                      ptr_ch('U'//char(0)),
     &                      ptr_ch('2'//char(0)),
     &                      ptr_ch('MHz'//char(0)),
     &                      ptr_ch('CH1'//char(0)),
     &                      ptr_ch('BBCa'//char(0)),
     &                      ptr_ch('USB_CAL'//char(0)))
      call fcreate_chan_def_states(ptr_ch(char(0)))
c
      call fcreate_chan_def(ptr_ch('X'//char(0)),
     &                      ptr_ch('8500.99'//char(0)),
     &                      ptr_ch('MHz'//char(0)),
     &                      ptr_ch('U'//char(0)),
     &                      ptr_ch('2'//char(0)),
     &                      ptr_ch('MHz'//char(0)),
     &                      ptr_ch(char(0)),
     &                      ptr_ch('BBCa'//char(0)),
     &                      ptr_ch('USB_CAL'//char(0)))
      call fcreate_chan_def_states(ptr_ch(char(0)))
c
      call fcreate_chan_def(ptr_ch('X'//char(0)),
     &                      ptr_ch('8500.99'//char(0)),
     &                      ptr_ch('MHz'//char(0)),
     &                      ptr_ch('U'//char(0)),
     &                      ptr_ch('2'//char(0)),
     &                      ptr_ch('MHz'//char(0)),
     &                      ptr_ch('CH1'//char(0)),
     &                      ptr_ch('BBCa'//char(0)),
     &                      ptr_ch(char(0)))
      call fcreate_chan_def_states(ptr_ch(char(0)))
c
      call fcreate_chan_def(ptr_ch('S'//char(0)),
     &                      ptr_ch('2500.99'//char(0)),
     &                      ptr_ch('MHz'//char(0)),
     &                      ptr_ch('U'//char(0)),
     &                      ptr_ch('2'//char(0)),
     &                      ptr_ch('MHz'//char(0)),
     &                      ptr_ch('CH1'//char(0)),
     &                      ptr_ch('BBCa'//char(0)),
     &                      ptr_ch('USB_CAL'//char(0)))
      call fcreate_chan_def_states(ptr_ch('1'//char(0)))
      call fcreate_chan_def_states(ptr_ch('2'//char(0)))
      call fcreate_chan_def_states(ptr_ch(char(0)))
c
      call fcreate_chan_def(ptr_ch('S'//char(0)),
     &                      ptr_ch('2500.99'//char(0)),
     &                      ptr_ch('MHz'//char(0)),
     &                      ptr_ch('U'//char(0)),
     &                      ptr_ch('2'//char(0)),
     &                      ptr_ch('MHz'//char(0)),
     &                      ptr_ch('CH1'//char(0)),
     &                      ptr_ch('BBCa'//char(0)),
     &                      ptr_ch(char(0)))
      call fcreate_chan_def_states(ptr_ch('1'//char(0)))
      call fcreate_chan_def_states(ptr_ch('2'//char(0)))
      call fcreate_chan_def_states(ptr_ch(char(0)))
      call fend_def
c
      call fcreate_block(ptr_ch('IF'//char(0)))
      call fcreate_def(ptr_ch('SX'//char(0)))
      call fcreate_if_def(ptr_ch('IF_XR1'//char(0)),
     &                    ptr_ch('1A'//char(0)),
     &                    ptr_ch('R'//char(0)),
     &                    ptr_ch('7600'//char(0)),
     &                    ptr_ch('MHz'//char(0)),
     &                    ptr_ch('U'//char(0)),
     &                    ptr_ch('1'//char(0)),
     &                    ptr_ch('MHz'//char(0)),
     &                    ptr_ch('0'//char(0)),
     &                    ptr_ch('Hz'//char(0)))
      call fcreate_if_def(ptr_ch('IF_XR1'//char(0)),
     &                    ptr_ch('1A'//char(0)),
     &                    ptr_ch('R'//char(0)),
     &                    ptr_ch('7600'//char(0)),
     &                    ptr_ch('MHz'//char(0)),
     &                    ptr_ch('U'//char(0)),
     &                    ptr_ch('1'//char(0)),
     &                    ptr_ch('MHz'//char(0)),
     &                    ptr_ch(char(0)),
     &                    ptr_ch(char(0)))
      call fcreate_if_def(ptr_ch('IF_XR1'//char(0)),
     &                    ptr_ch('1A'//char(0)),
     &                    ptr_ch('R'//char(0)),
     &                    ptr_ch('7600'//char(0)),
     &                    ptr_ch('MHz'//char(0)),
     &                    ptr_ch('U'//char(0)),
     &                    ptr_ch(char(0)),
     &                    ptr_ch(char(0)),
     &                    ptr_ch(char(0)),
     &                    ptr_ch(char(0)))
      call fend_def
c
      call fcreate_vex(ptr_ch(char(0)))
c
      END

