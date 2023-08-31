#
# Copyright (c) 2020, 2022, 2023 NVI, Inc.
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

all: index.html dbbc3_ops.html\
    10.1.0-beta1.html 10.1.0-beta2.html beta1_to_beta2.html 10.1.0.html beta2_to_10.1.0.html 10.1.1.html

index.html: index.adoc
	asciidoctor $^

%.html: %.adoc
	asciidoctor -a toc $^

