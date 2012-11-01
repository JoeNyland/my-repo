#!/usr/bin/env python

import argparse
import urllib2
import time
import calendar
import smtplib
from email.mime.multipart import MIMEMultipart
from email.mime.text import MIMEText
from email.MIMEImage import MIMEImage
from datetime import datetime
from dateutil import tz
from socket import getfqdn
from socket import gethostbyname
from lxml import etree

# User configurable variables:
# Define MythWeb URL:
mythweb = ""
# Define SMTP server:
smtpserver = ""

# Parse the supplied arguments:
parser = argparse.ArgumentParser()
parser.add_argument("-v", "--verbose", action="store_true", help="Enable verbose output")
parser.add_argument("--chanid", type=int, help="The %%CHANID%% for the recording to query for", required=True)
parser.add_argument("--starttime", help="The %%STARTTIMEISOUTC%% for the recording to query for", required=True)
parser.add_argument("--to", help="The email address to send the notification to", metavar="email address", required=True)
args = parser.parse_args()

# Define the server name/address:
# Localhost IP address for MythTV Services API access:
server = gethostbyname("localhost")
# Get the FQDN for the local machine:
servername = getfqdn("")

# Convert supplied "starttime" (UTC) to Unix time:
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

# Check that required info fileds are populated with text and try to encode as "UTF-8":
if title_tag[0].text is None:
	title = ""
	title_exists = "False"
else:
	title_exists = "True"
	try:
		title = title_tag[0].text.encode("utf-8")
	except AttributeError:
		title = title_tag[0].text

if subtitle_tag[0].text is None:
	subtitle = ""
	subtitle_exists = "False"
else:
	subtitle_exists = "True"
	try:
		subtitle = subtitle_tag[0].text.encode("utf-8")
		subtitle = ': "{subtitle}"'.format(subtitle=subtitle)
	except AttributeError:
		subtitle = subtitle_tag[0].text
		subtitle = ': "{subtitle}"'.format(subtitle=subtitle)
	
if desc_tag[0].text is None:
	desc = "No description for this recording was found in the guide."
	desc_exists = "False"
else:
	desc_exists = "True"
	try:
		desc = desc_tag[0].text.encode("utf-8")
	except AttributeError:
		desc = desc_tag[0].text

# Scrape the MythTV system data page to "mythresponse" and create XML tree:
mythresponse = urllib2.urlopen(myth_url)
mythhtml_data = mythresponse.read()
mythresponse.close()
mythtree = etree.XML(mythhtml_data)

# Extract required info from "mythresponse" XML tree
version_tag = mythtree.xpath("//ConnectionInfo/Version/Version")
version = version_tag[0].text

# Read MythTV logo to "mythtvlogo_data":
mythtvlogoresponse = urllib2.urlopen("http://www.mythtv.org/img/mythtv.png")
mythtvlogo_data = mythtvlogoresponse.read()
mythtvlogoresponse.close()

# Read the preview icon to "preview_data":
previewresponse = urllib2.urlopen(preview_url)
preview_data = previewresponse.read()
previewresponse.close()

# Read the channel icon to "channelicon_data":
channeliconresponse = urllib2.urlopen(channelicon_url)
channelicon_data = channeliconresponse.read()
channeliconresponse.close()

# Define the text version of the email:
text = 'MythTV has completed recording {title}{subtitle}\r\n\r\n{desc}\r\n\r\n{title}{subtitle} was recorded at {starttime} on {startdate}\r\n\r\nMythTV {version} on {server}'.format(title=title, subtitle=subtitle, desc=desc, starttime=starttime_local, startdate=startdate_local, version=version, server=servername)
# Define the HTML version of the email:
html = """
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Frameset//EN" "http://www.w3.org/TR/html4/frameset.dtd">

<html>
<head>
	<!-- My CSS -->
	<style type="text/css">
		html, body {{height: 100%;}}
		
		div#wrap {{min-height: 100%;}}
		
		div#header {{
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
		}}
				
		div#header img.channel_icon {{
			float: right;
			margin-right: 25px;
			margin-top: -5px;
			max-height: 70px;
		}}
		
		div#main {{
			overflow:auto;
			padding-top: 80px;
			padding-left: 10px;
			padding-bottom: 2em;  /* must be same height as the footer */
		}}
		
		div#main p {{
			width: 75%;
		}}
		
		div#main img {{
			float: right;
			margin-right: 25px;
			margin-top: -20px;
			width: 20%;
		}}
		
		div#footer {{
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
		}}
		
		/*Opera Fix*/
		body:before {{
			content:"";
			height:100%;
			float:left;
			width:0;
			margin-top:-32767px;/
		}}
	</style>
	<!-- MythWeb CSS -->
	<style type="text/css">
		/*
		 * Global page handlers.
		/*/

			html,body {{
				// border:           0;
				margin:           0;
				padding:          0;
				font-size:        9pt;
				font-family:      Arial, Helvetica, sans-serif;
				background-color: #191c26;
				color:            #dedede;
			}}

			/* For some reason, settings for the main body element doesn't always work for
			 * text inside of tables
			/*/
			.body {{
				font-size: 12px;
				font-family: Arial, Helvetica, sans-serif;
			}}

		/*
		 * We should try to keep links and labels looking consistent across the app.
		/*/

			a, a:link, .link {{ color: #E0E0FF; text-decoration: none; cursor: pointer;}}
			a:active  {{ color: #990033; text-decoration: none; }}
			a:visited {{ color: #E0E0FF; text-decoration: none; }}
			a:hover   {{ color: #F0F000; text-decoration: underline; }}

			label       {{ color: #E0E0FF; text-decoration: none; }}
			label:hover {{ color: #F0F000; text-decoration: underline; }}

		/* a class for the menu across the top of the page as well as menu headers throughout the page */
			.menu {{          background-color: #265990 }}
			.menu_border_t {{ border-top:    2px solid #9090B0 }}
			.menu_border_b {{ border-bottom: 2px solid #9090B0 }}
			.menu_border_l {{ border-left:   2px solid #9090B0 }}
			.menu_border_r {{ border-right:  2px solid #9090B0 }}

		/* a class for commands and other user input boxes */

		/* @deprecated old classes */
		.command {{ background-color: #1040A0 }}
		.command_border_t {{ border-top:    2px solid #9090B0 }}
		.command_border_b {{ border-bottom: 2px solid #9090B0 }}
		.command_border_l {{ border-left:   2px solid #9090B0 }}
		.command_border_r {{ border-right:  2px solid #9090B0 }}
		.activecommand    {{ background-color: #108040 }}

		/* New command classes */

			/* Box to hold commands */
			.commandbox {{
				background-color:   #102923;
				color:              #E0E0FF;
				border:             1px solid #9090B0;
			}}

			/* Commands themselves */

			.commands {{ /* Placeholder for handling sub-elements */ }}

			.commands input.x-submit {{
				border:             2px outset #7b8;
				padding:            0 .5em;
				height:             2em;
				background-color:   #263;
				color:              #E0E0FF;
			}}
			.commands input.x-submit:hover {{
				border:             1px outset #9da;
				background-color:   #485;
				color:              #F0F000;
				text-decoration:    underline;
			}}

			.commands a {{
				font-weight:        bold;
				border:             1px solid #7b8;
				padding:            .15em .5em;
				background-color:   #263;
			}}
			.commands a:hover {{
				border:             1px solid #9da;
				background-color:   #485;
			}}

		/*
		 * The following styles refer to forms and form elements throughout MythWeb
		/*/

			/* Avoid those nasty extra linefeeds in IE form tags */
			form {{ display: inline; }}

			/* A special class for submit buttons */
			.submit {{
				border:             2px outset #7b8;
				padding:            0 .5em;
				background-color:   #263;
				color:              #E0E0FF;
				font-weight:        bold;
				height:             2em;
			}}
			.submit:hover {{
				border:             2px outset #9da;
				background-color:   #485;
				color:              #F0F000;
				text-decoration:    underline;
			}}

			/* A special class for radio buttons and check boxes because some browsers render them weirdly */
			.radio {{
				height:             14px !important;
				width:              14px !important;
				color:              #002000;
				background-color:   #C0D0C0;
			}}

			/* Default styles for form fields */
			select {{
				font-family:        Arial, Helvetica, sans-serif;
				color:              #002000;
				background-color:   #C0D0C0;
				font-size:          9pt;
			}}

			input {{
				padding-left:       .25em;
				font-family:        Arial, Helvetica, sans-serif;
				color:              #002000;
				background-color:   #C0D0C0;
				font-size:          9pt;
			}}

			textarea {{
				font-family:        courier, courier-new;
				color:              #002000;
				background-color:   #C0D0C0;
				font-size:          9pt;
			}}

			/* Quantity-sized elements look better with the text centered */
			input.quantity {{
				width:              2em !important;
				text-align:         center;
			}}

		/*
		 * A special class for error stuff, so all page errors look the same.
		/*/

			#error, .error {{
				color:              #F03030;
				background-color:   #360000;
				border-color:       #F03030;
				border:             thin groove #F03030;
				padding:            8px;
			}}

		/*
		 * The following represent some global classes to accommodate minor but
		 * oft-used manipulations like font sizes.0
		/*/

			/* font size classes */
			.tiny   {{ font-size: 9px; }}
			.small  {{ font-size: 9pt; }}
			.normal {{ font-size: 10pt; }}
			.large  {{ font-size: 12pt; }}
			.huge   {{ font-size: 24px; }}

			/* fony style classes */
			.bold, .bold a, .bold a:link, .bold a:visited, .bold a:active, .bold a:hover {{
				font-weight: bold !important;
			}}
			.italic, .italic a, .italic a:link, .italic a:visited, .italic a:active, .italic a:hover {{
				font-style: italic !important;
			}}

			/* Handy for, well, hiding things..  Also for mouseover popup menus */
			.hidden {{
				visibility: hidden;
				display:    none;
			}}

		/*
		 * clearfix -- see http://positioniseverything.net/easyclearing.html for details on how/why this works
		/*/

			.clearfix:after {{
				content:    ".";
				display:    block;
				height:     0;
				clear:      both;
				visibility: hidden;
			}}
			.clearfix {{display: inline-block;}}
			/* Hides from IE-mac \*/
			* html .clearfix {{height: 1%;}}
			.clearfix {{display: block;}}
			/* End hide from IE-mac */

			/* Ajax little popup request thing style */
			#ajax_working {{
				position:           fixed;
				background-color:   green;
				bottom:             0px;
				left:               1em;
				padding:            1em;
				width:              10em;
				text-align:         center;
			}}

			.link {{
				cursor:             pointer;
			}}

		/* I don't think we have a single image with a border in the default template, so disable it */
			a img {{
				border:             0px;
			}}

			.nowrap {{
				white-space:        nowrap;
			}}

		#feed_buttons {{
			padding-top:        1em;
			padding-bottom:     1em;
			padding-left:       1.35em;
		}}

		#feed_buttons a {{
			padding-right:      1em;
		}}

		#dialog-overlay {{
			background-color:   #506090;
		}}

		#dialog-top {{
			background-color:   #203670;
			border:             1px solid #203670;
		}}

		#dialog-title {{
			color:              white;

		}}

		#dialog-content {{
			background-color:   #265990;
			text-align:         center;
		}}
	</style>
</head>

<body>
	<div id="wrap">
		<div id="header">	
			<img src="cid:channelicon" style="float: right;margin-right: 25px;margin-top: 0px;" width="86x" height="64px" alt="{channel}">
			<a href="http://www.mythtv.org/"><img src="cid:mythtvicon" alt="MythTV" width="180px" height="64px" ></a>
		</div>
		<div id="main">
			</br>
			<h3>MythTV has completed recording {title}{subtitle}</h3>
			<img src="cid:previewicon" alt="{title}" style="float: right;margin-right: 25px;margin-top: -20px;">
			<p>
			{desc}
			</p>
			<p>
			{title}{subtitle} was recorded at {starttime} on {startdate}.
			</p>
			<p style="padding-top:70px;">
			<a href="{url}" target="_blank">View the recording in MythWeb</a>.
			</p>
		</div>
	</div>
	<div id="footer">
		<a href="http://www.mythtv.org/">MythTV</a> {version} on {server}
	</div>
</body>
</html>
""".format(title=title, subtitle=subtitle, desc=desc, starttime=starttime_local, startdate=startdate_local, url=mythweb_url, version=version, server=servername, channel=args.chanid)

# Setup the email, stored in "msgRoot":
smtphost = getfqdn(smtpserver)
subject = 'MythTV has finished recording {title}{subtitle}'.format(title=title, subtitle=subtitle)
to = args.to
sender = "MythTV@{servername}".format(servername=servername)

# Create the root message and fill in the from, to, and subject headers
msgRoot = MIMEMultipart()
msgRoot["Subject"] = subject
msgRoot["From"] = '"MythTV" <{sender}>'.format(sender=sender)
msgRoot["To"] = to
msgRoot.preamble = 'This is a multi-part message in MIME format.'

# Encapsulate the plain and HTML versions of the message body in an 'alternative' part.
# Initialise the main 'alternative' boundary:
msgAlternative = MIMEMultipart('alternative')
msgRoot.attach(msgAlternative)

# Attach the text version of the message in the 'alternative' boundary:
msgText = MIMEText(text)
msgAlternative.attach(msgText)

# Create the 'related' boundary under the 'alternative' boundary:
msgRelated = MIMEMultipart('related')
msgAlternative.attach(msgRelated)

# Attach the html version of the message in the 'related' boundary:
msgText = MIMEText(html, 'html')
msgRelated.attach(msgText)

# Define the image's ID as referenced above.
# Attach MIMEImages in the 'related' boundary:
msgImage = MIMEImage(channelicon_data)
msgImage.add_header('Content-ID', '<channelicon>')
msgRelated.attach(msgImage)
msgImage = MIMEImage(mythtvlogo_data)
msgImage.add_header('Content-ID', '<mythtvicon>')
msgRelated.attach(msgImage)
msgImage = MIMEImage(preview_data)
msgImage.add_header('Content-ID', '<previewicon>')
msgRelated.attach(msgImage)

# Send the message
smtp = smtplib.SMTP(smtphost)
smtp.sendmail(sender, to, msgRoot.as_string())
smtp.quit

# Verbose output:
if args.verbose:
	print """
__________________________________________________________________________________________
Verbose output:

Channel ID: {chanid}
Raw Start Date/Time: {starttime}
Local Start Time: {starttime_local}
Local Start Date: {startdate_local}
Title: {title}
Subtitle: {subtitle}
Description: {desc}

MythWeb URL: {mythweb_url}
Services URL: {recording_url}
Services Response: 
{recordinghtml_data}

Preview URL: {preview_url}
Channel Icon URL: {channelicon_url}
MythTV Version: {version}

Email source:
{msg}""".format(chanid=str(args.chanid), starttime=args.starttime, starttime_local=starttime_local, startdate_local=startdate_local, title=title, subtitle=subtitle.lstrip(": "), desc=desc, mythweb_url=mythweb_url, recording_url=recording_url, recordinghtml_data=recordinghtml_data, preview_url=preview_url, channelicon_url=channelicon_url, version=version, msg=msgRoot)
