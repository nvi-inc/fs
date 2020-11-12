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

all: index.html beta2.html beta1_to_beta2.html latest_commit.html 64-bit_conversion.html

index.html: index.adoc
beta2.html: beta2.adoc
beta1_to_beta2.html: beta1_to_beta2.adoc
latest_commit.html: latest_commit.adoc
64-bit_converion.html: 64-bit_converion.adoc

%.html: %.adoc
	asciidoctor -a toc $^

