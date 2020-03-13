/*
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
 */
/* header file for mcbcn communication request buffers */

/* rcl_req_buf contains information pertaining to all request buffers */
/* these structures are manipulated buy rcl_req_util.c  */

#define RCLCN_REQ_BUF_MAX   512       /* maximum size of request buffer */

struct rclcn_req_buf {            /* buffer structure */
  int count;                 /* number of buffers in class */
  int class_fs;                /* class number containing buffers */
  int nchars;                /* number of characters in buf */
  int prev_nchars;
  unsigned char buf[ RCLCN_REQ_BUF_MAX];    /* actual buffer */
};

