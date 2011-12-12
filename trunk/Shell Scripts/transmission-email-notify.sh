#!/bin/bash
/usr/bin/sendemail -f "Transmission@.co.uk" -t "" -s "" -o username= -o password= -u "Transmission completed download: $TR_TORRENT_NAME" <<EOF
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Frameset//EN" "http://www.w3.org/TR/html4/frameset.dtd">

<html>

<body>
    <font face="Lucida Grande" color="#000000">
        <h2>Transmission has completed downloading "$TR_TORRENT_NAME"</h2>
    </font>

    <font face="Lucida Grande" color="#000000" size="3">
        <p>The downloaded files can be found here: $TR_TORRENT_DIR</p>
    </font>
    <font face="Lucida Grande" color="#C0C0C0" size="1">
        </br>
        </br>
        </br>
        <a href="http://www.transmissionbt.com"><img src="http://www.transmissionbt.com/images/transmission.png" alt="Transmission" height="16px" width="155px"/><img src="http://www.transmissionbt.com/images/transmission-74x74.png" alt="Transmission" height="24px" width="24px"/></a>
        </br>
        (v$TR_APP_VERSION)
    </font>
</body>

</html>
EOF