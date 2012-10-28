#!/usr/bin/env python

import argparse
import urllib2
import time
import calendar
import smtplib
import base64
from email.mime.multipart import MIMEMultipart
from email.mime.text import MIMEText
from datetime import datetime
from dateutil import tz
from socket import getfqdn
from lxml import etree

"""
User configurable variables:
"""
# Define MythWeb URL:
mythweb = ""

# Define SMTP server:
smtpserver = ""

"""
Main script:
"""
# Parse the supplied arguments:
parser = argparse.ArgumentParser()
parser.add_argument("-v", "--verbose", action="store_true", help="Enable verbose output")
parser.add_argument("--chanid", type=int, help="The %%CHANID%% for the recording to query for", required=True)
parser.add_argument("--starttime", help="The %%STARTTIMEISOUTC%% for the recording to query for", required=True)
parser.add_argument("--to", help="The email address to send the notification to", metavar="email address", required=True)
args = parser.parse_args()

# Define the server name/address:
# Localhost IP address for MythTV Services API access:
server = "127.0.0.1"	# 127.0.0.1 hardcoded, as FQDN resolves to 127.0.1.1, but MythTV Services API runs under 127.0.0.1 and LAN IP.
# Get the FQDN for the local machine:
servername = getfqdn()

# Convert supplied "starttime" to Unix time:
starttime_tuple = time.strptime(args.starttime, "%Y-%m-%dT%H:%M:%SZ")
starttime_unix = calendar.timegm(starttime_tuple)

# Convert supplied "starttime" (UTC) to local time:
starttime_utc = datetime.strptime(args.starttime, "%Y-%m-%dT%H:%M:%SZ")
starttime_utc = starttime_utc.replace(tzinfo=tz.tzutc())
starttime_local = starttime_utc.astimezone(tz.tzlocal())
starttime_local = starttime_local.replace(tzinfo=None)
startdatetime_local = str(starttime_local).split()

# Split localised "starttime" to date and time:
startdate_local = datetime.strptime(str(starttime_local), "%Y-%m-%d %H:%M:%S").strftime("%d/%m/%Y")
starttime_local = startdatetime_local[1]

# Construct required URLs:
recording_url = "http://" + server + ":6544/Dvr/GetRecorded?StartTime=" + args.starttime + "&ChanId=" + str(args.chanid)
myth_url = "http://" + server + ":6544/Myth/GetConnectionInfo"
preview_url = "http://" + server + ":6544/Content/GetPreviewImage?StartTime=" + args.starttime + "&ChanId=" + str(args.chanid)
channelicon_url = "http://" + server + ":6544/Guide/GetChannelIcon?" + "ChanId=" + str(args.chanid)
mythweb_url = mythweb + "/tv/detail/" + str(args.chanid) + "/" + str(starttime_unix)

# Scrape the recording details page to "recordingresponse" and create XML tree:
recordingresponse = urllib2.urlopen(recording_url)
recordinghtml_data = recordingresponse.read()
recordingresponse.close()
recordingtree = etree.XML(recordinghtml_data)

# Extract required info from "recordingresponse" XML tree
title_tag = recordingtree.xpath('//Program/Title')
subtitle_tag = recordingtree.xpath('//Program/SubTitle')
desc_tag = recordingtree.xpath('//Program/Description')
title = title_tag[0].text.encode('utf-8')
subtitle = subtitle_tag[0].text.encode('utf-8')
desc = desc_tag[0].text.encode('utf-8')

# Scrape the MythTV data page to "mythresponse" and create XML tree:
mythresponse = urllib2.urlopen(myth_url)
mythhtml_data = mythresponse.read()
mythresponse.close()
mythtree = etree.XML(mythhtml_data)

# Extract required info from "mythresponse" XML tree
version_tag = mythtree.xpath("//ConnectionInfo/Version/Version")
version = version_tag[0].text.encode('utf-8')

# Read the preview icon to "preview_data" and base64 encode:
previewresponse = urllib2.urlopen(preview_url)
preview_data = previewresponse.read()
previewresponse.close()
preview_encoded = base64.b64encode(preview_data)

# Read the channel icon to "channelicon_data" and base64 encode:
channeliconresponse = urllib2.urlopen(channelicon_url)
channelicon_data = channeliconresponse.read()
channeliconresponse.close()
channelicon_encoded = base64.b64encode(channelicon_data)

# Setup the email, stored in "msg":
smtphost = getfqdn(smtpserver)
subject = 'MythTV has finished recording %s: "%s"' %(title, subtitle)
to = args.to
sender = "MythTV@%s" %(servername)
msg = MIMEMultipart('alternative')
msg["To"] = to
msg["From"] = sender
msg["Subject"] = subject

# Define the text version of the message:
text = "MythTV has completed recording %s: %s\r\n\r\n%s\r\n\r\n%s: %s was recorded at %s on %s" %(title, subtitle, desc, title, subtitle, starttime_local, startdate_local)
# Define the HTML version of the message:
html = """
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Frameset//EN" "http://www.w3.org/TR/html4/frameset.dtd">

<html>
<head>
	<!-- My CSS -->
	<style>
		html, body {height: 100%%;}
		
		div#wrap {min-height: 100%%;}
		
		div#header {
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
			width: 100%%; 
			margin: 0 auto; 
			padding: 15px;
		}
				
		div#header img.channel_icon {
			float: right;
			margin-right: 25px;
			margin-top: -5px;
			max-height: 70px;
		}
		
		div#main {
			overflow:auto;
			padding-top: 80px;
			padding-left: 10px;
			padding-bottom: 2em;  /* must be same height as the footer */
		}
		
		div#main p {
			width: 75%%;
		}
		
		div#main img {
			float: right;
			margin-right: 25px;
			margin-top: -20px;
			width: 20%%;
		}
		
		div#footer {
			position: relative;
			margin-top: -2em; /* negative value of footer height */
			height: 1em;
			clear:both;
	
			background-color: #B9B9B9; /* fallback color if gradients are not supported */
			background-image: -webkit-gradient(linear, left top, left bottom, from(#C9C9C9), to(#A7A7A7)); 
			background-image: -webkit-linear-gradient(top, #C9C9C9, #A7A7A7); 
			background-image:    -moz-linear-gradient(top, #C9C9C9, #A7A7A7); 
			background-image:     -ms-linear-gradient(top, #C9C9C9, #A7A7A7); 
			background-image:      -o-linear-gradient(top, #C9C9C9, #A7A7A7); 
			background-image:         linear-gradient(top, #C9C9C9, #A7A7A7); /* standard, but currently unimplemented */
			padding: 5px;
			color: #E1E1E1;
			font-size: x-small;
		} 
		
		/*Opera Fix*/
		body:before {
			content:"";
			height:100%%;
			float:left;
			width:0;
			margin-top:-32767px;/
		}
	</style>
	<!-- MythWeb CSS -->
	<style type="text/css">
		/*
		 * Global page handlers.
		/*/

			html,body {
				// border:           0;
				margin:           0;
				padding:          0;
				font-size:        9pt;
				font-family:      Arial, Helvetica, sans-serif;
				background-color: #191c26;
				color:            #dedede;
			}

			/* For some reason, settings for the main body element doesn't always work for
			 * text inside of tables
			/*/
			.body {
				font-size: 12px;
				font-family: Arial, Helvetica, sans-serif;
			}

		/*
		 * We should try to keep links and labels looking consistent across the app.
		/*/

			a, a:link, .link { color: #E0E0FF; text-decoration: none; cursor: pointer;}
			a:active  { color: #990033; text-decoration: none; }
			a:visited { color: #E0E0FF; text-decoration: none; }
			a:hover   { color: #F0F000; text-decoration: underline; }

			label       { color: #E0E0FF; text-decoration: none; }
			label:hover { color: #F0F000; text-decoration: underline; }

		/* a class for the menu across the top of the page as well as menu headers throughout the page */
			.menu {          background-color: #265990 }
			.menu_border_t { border-top:    2px solid #9090B0 }
			.menu_border_b { border-bottom: 2px solid #9090B0 }
			.menu_border_l { border-left:   2px solid #9090B0 }
			.menu_border_r { border-right:  2px solid #9090B0 }

		/* a class for commands and other user input boxes */

		/* @deprecated old classes */
		.command { background-color: #1040A0 }
		.command_border_t { border-top:    2px solid #9090B0 }
		.command_border_b { border-bottom: 2px solid #9090B0 }
		.command_border_l { border-left:   2px solid #9090B0 }
		.command_border_r { border-right:  2px solid #9090B0 }
		.activecommand    { background-color: #108040 }

		/* New command classes */

			/* Box to hold commands */
			.commandbox {
				background-color:   #102923;
				color:              #E0E0FF;
				border:             1px solid #9090B0;
			}

			/* Commands themselves */

			.commands { /* Placeholder for handling sub-elements */ }

			.commands input.x-submit {
				border:             2px outset #7b8;
				padding:            0 .5em;
				height:             2em;
				background-color:   #263;
				color:              #E0E0FF;
			}
			.commands input.x-submit:hover {
				border:             1px outset #9da;
				background-color:   #485;
				color:              #F0F000;
				text-decoration:    underline;
			}

			.commands a {
				font-weight:        bold;
				border:             1px solid #7b8;
				padding:            .15em .5em;
				background-color:   #263;
			}
			.commands a:hover {
				border:             1px solid #9da;
				background-color:   #485;
			}

		/*
		 * The following styles refer to forms and form elements throughout MythWeb
		/*/

			/* Avoid those nasty extra linefeeds in IE form tags */
			form { display: inline; }

			/* A special class for submit buttons */
			.submit {
				border:             2px outset #7b8;
				padding:            0 .5em;
				background-color:   #263;
				color:              #E0E0FF;
				font-weight:        bold;
				height:             2em;
			}
			.submit:hover {
				border:             2px outset #9da;
				background-color:   #485;
				color:              #F0F000;
				text-decoration:    underline;
			}

			/* A special class for radio buttons and check boxes because some browsers render them weirdly */
			.radio {
				height:             14px !important;
				width:              14px !important;
				color:              #002000;
				background-color:   #C0D0C0;
			}

			/* Default styles for form fields */
			select {
				font-family:        Arial, Helvetica, sans-serif;
				color:              #002000;
				background-color:   #C0D0C0;
				font-size:          9pt;
			}

			input {
				padding-left:       .25em;
				font-family:        Arial, Helvetica, sans-serif;
				color:              #002000;
				background-color:   #C0D0C0;
				font-size:          9pt;
			}

			textarea {
				font-family:        courier, courier-new;
				color:              #002000;
				background-color:   #C0D0C0;
				font-size:          9pt;
			}

			/* Quantity-sized elements look better with the text centered */
			input.quantity {
				width:              2em !important;
				text-align:         center;
			}

		/*
		 * A special class for error stuff, so all page errors look the same.
		/*/

			#error, .error {
				color:              #F03030;
				background-color:   #360000;
				border-color:       #F03030;
				border:             thin groove #F03030;
				padding:            8px;
			}

		/*
		 * The following represent some global classes to accommodate minor but
		 * oft-used manipulations like font sizes.0
		/*/

			/* font size classes */
			.tiny   { font-size: 9px; }
			.small  { font-size: 9pt; }
			.normal { font-size: 10pt; }
			.large  { font-size: 12pt; }
			.huge   { font-size: 24px; }

			/* fony style classes */
			.bold, .bold a, .bold a:link, .bold a:visited, .bold a:active, .bold a:hover {
				font-weight: bold !important;
			}
			.italic, .italic a, .italic a:link, .italic a:visited, .italic a:active, .italic a:hover {
				font-style: italic !important;
			}

			/* Handy for, well, hiding things..  Also for mouseover popup menus */
			.hidden {
				visibility: hidden;
				display:    none;
			}

		/*
		 * clearfix -- see http://positioniseverything.net/easyclearing.html for details on how/why this works
		/*/

			.clearfix:after {
				content:    ".";
				display:    block;
				height:     0;
				clear:      both;
				visibility: hidden;
			}
			.clearfix {display: inline-block;}
			/* Hides from IE-mac \*/
			* html .clearfix {height: 1%%;}
			.clearfix {display: block;}
			/* End hide from IE-mac */

			/* Ajax little popup request thing style */
			#ajax_working {
				position:           fixed;
				background-color:   green;
				bottom:             0px;
				left:               1em;
				padding:            1em;
				width:              10em;
				text-align:         center;
			}

			.link {
				cursor:             pointer;
			}

		/* I don't think we have a single image with a border in the default template, so disable it */
			a img {
				border:             0px;
			}

			.nowrap {
				white-space:        nowrap;
			}

		#feed_buttons {
			padding-top:        1em;
			padding-bottom:     1em;
			padding-left:       1.35em;
		}

		#feed_buttons a {
			padding-right:      1em;
		}

		#dialog-overlay {
			background-color:   #506090;
		}

		#dialog-top {
			background-color:   #203670;
			border:             1px solid #203670;
		}

		#dialog-title {
			color:              white;

		}

		#dialog-content {
			background-color:   #265990;
			text-align:         center;
		}
	</style>
</head>

<body>
	<div id="wrap">
		<div id="header">	
			<img src="data:image/png;base64,%s" class="channel_icon" />
			<a href="http://www.mythtv.org/"><img src="data:image/png;base64,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" alt="MythTV" width="180px" height="64px" /></a>
		</div>
		
		<div id="main">
			</br>
			<h3>MythTV has completed recording %s: "%s"</h3>
			<img src="data:image/png;base64,%s" />
			<p>
			%s
			</p>
			<p>
			%s: "%s" was recorded at %s on %s.
			</p>
			</br>
			<p>
			<a href="%s" target="_blank">View the recording in MythWeb</a>.
			</p>
		</div>
		
	</div>
	<div id="footer">
		<a href="http://www.mythtv.org/">MythTV</a> %s on %s
	</div>
</body>
</html>
""" %(channelicon_encoded, title, subtitle, preview_encoded, desc, title, subtitle, starttime_local, startdate_local, mythweb_url, version, servername)
part1 = MIMEText(text, 'text')
part2 = MIMEText(html, 'html')
msg.attach(part1)
msg.attach(part2)
smtp = smtplib.SMTP(smtphost)
smtp.sendmail(sender, to, msg.as_string())
smtp.quit

# Verbose output:
if args.verbose:
	print """
__________________________________________________________________________________________
Verbose output:

Channel ID: %s
Raw Start Date/Time: %s
Local Start Time: %s
Local Start Date: %s
Title: %s
Subtitle: %s
Description: %s

MythWeb URL: %s
Services URL: %s
Services HTML: 
%s

Preview URL: %s
Channel Icon URL: %s
MythTV Version: %s

Email HTML:
%s""" %(str(args.chanid), args.starttime, starttime_local, startdate_local, title, subtitle, desc, mythweb_url, recording_url, recordinghtml_data, preview_url, channelicon_url, version, msg)