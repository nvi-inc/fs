#
# Copyright (c) 2020 NVI, Inc.
#
# This file is part of FSL10 Linux distribution.
# (see http://github.com/nvi-inc/fsl10).
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program. If not, see <http://www.gnu.org/licenses/>.
#

.PHONY: all

all: index.html 64-bit_conversion.html font_conventions.html env_vars.html

index.html: index.adoc
64-bit_conversion.html: 64-bit_conversion.adoc
font_conventions.html: font_conventions.adoc
env_vars.html: env_vars.adoc


%.html: %.adoc
	asciidoctor -a toc $^

