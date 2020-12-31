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

all: index.html beta2.html beta1_to_beta2.html beta2_to_beta3.html\
    beta3.html beta3_to_10.0.0.html rdbe.html mk6.html dbbc3.html\
    changes_10.0.0.html fesh_changes.html fsserver_changes.html\
    10.0.0.html 10.0.0_to_latest.html

index.html: index.adoc
beta2.html: beta2.adoc
beta3.html: beta3.adoc
10.0.0.html: 10.0.0.adoc
beta1_to_beta2.html: beta1_to_beta2.adoc
beta2_to_beta3.html: beta2_to_beta3.adoc
beta3_to_10.0.0.html: beta3_to_10.0.0.adoc
10.0.0_to_latest.html: 10.0.0_to_latest.adoc
rdbe.html: rdbe.adoc
mk6.html: mk6.adoc
dbbc3.html: dbbc3.adoc
changes_10.0.0.html: changes_10.0.0.adoc
fesh_changes.html: fesh_changes.adoc
fsserver_changes.html: fsserver_changes.adoc

%.html: %.adoc
	asciidoctor -a toc $^

