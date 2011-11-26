#!/bin/bash
/usr/bin/sendemail -f "Transmission@" -t "" -s "" -o username= -o password= -u "Transmission completed download: $TR_TORRENT_NAME" <<EOF
Transmission has completed downloading $TR_TORRENT_NAME.

The downloaded files can be found here: $TR_TORRENT_DIR




($TR_APP_VERSION)
EOF