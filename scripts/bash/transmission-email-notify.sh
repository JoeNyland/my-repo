#!/bin/bash
/usr/bin/sendemail -f "Transmission@`hostname -f`" -t "" -s "" -u "Transmission completed download of: $TR_TORRENT_NAME" <<EOF
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Frameset//EN" "http://www.w3.org/TR/html4/frameset.dtd">

<html>

<head>
	<style type="text/css">
		html {
			margin: 0;
		/* setting border: 0 hoses ie6 win window inner well border */
			padding: 0;
			height: 100%;
		}

		body {
			font: 100% "lucida grande", Tahoma, Verdana, Arial, Helvetica, sans-serif; /* Resets 1em to 10px */
			font-size: medium;
			color: #222;/* !important; */
			background: #FFF;
			text-align: left;
			margin: 0 15px 30px;
			overflow: hidden;
		}

		a {
			outline: 0;
		}
		div#banner {
			position: fixed;
			top: 0;
			left: 0;
			background-color: #B9B9B9; /* fallback color if gradients are not supported */
			background-image: -webkit-gradient(linear, left top, left bottom, from(#C9C9C9), to(#A7A7A7));
			background-image: -webkit-linear-gradient(top, #C9C9C9, #A7A7A7);
			background-image:    -moz-linear-gradient(top, #C9C9C9, #A7A7A7);
			background-image:     -ms-linear-gradient(top, #C9C9C9, #A7A7A7);
			background-image:      -o-linear-gradient(top, #C9C9C9, #A7A7A7);
			background-image:         linear-gradient(top, #C9C9C9, #A7A7A7); /* standard, but currently unimplemented */
			width: 100%;
			margin: 0 auto;
			padding: 15px;
     	}
     	div#main-content {
			padding-top: 65px;
		}
		div#banner-bottom {
			position: fixed;
			bottom: 0;
			left: 0;
			background-color: #B9B9B9; /* fallback color if gradients are not supported */
			background-image: -webkit-gradient(linear, left top, left bottom, from(#C9C9C9), to(#A7A7A7));
			background-image: -webkit-linear-gradient(top, #C9C9C9, #A7A7A7);
			background-image:    -moz-linear-gradient(top, #C9C9C9, #A7A7A7);
			background-image:     -ms-linear-gradient(top, #C9C9C9, #A7A7A7);
			background-image:      -o-linear-gradient(top, #C9C9C9, #A7A7A7);
			background-image:         linear-gradient(top, #C9C9C9, #A7A7A7); /* standard, but currently unimplemented */
			width: 100%;
			margin: 0 auto;
			padding: 5px;
			color: #E1E1E1;
			font-size: x-small;
     	}
	</style>
</head>

<body>
	<div id=banner>
		<a href="http://www.transmissionbt.com"><img src="http://www.transmissionbt.com/images/transmission.png" alt="Transmission" height="32px" width="310px"/><img src="http://www.transmissionbt.com/images/transmission-74x74.png" alt="Transmission" height="48px" width="48px"/></a>
	</div>

    <div id=main-content>
		</br>
		<h3>Transmission has completed downloading "$TR_TORRENT_NAME"</h3>

		<p>
		Your download can be found on ,
		</br>in the following location:
		</br>
		</br>
		$TR_TORRENT_DIR/$TR_TORRENT_NAME
		</p>
	</div>

	<div id=banner-bottom>
        (v$TR_APP_VERSION)
    </div>
</body>

</html>
EOF
