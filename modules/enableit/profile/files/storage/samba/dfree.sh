#!/bin/bash
# When Samba serves files residing on an NFS mount the free space may not be
# calculated correctly. Instead we can use this script to force Samba to report whatever free space df reports.
#
# See the `dfree` smb.conf option.
df "${PWD}/${1}" | tail -1 | awk '{print $(NF-4),$(NF-2)}'
