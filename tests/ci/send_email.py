#!/usr/bin/env python

import smtplib, os.path
from email.mime.multipart import MIMEMultipart 
from email.mime.text import MIMEText 
from email.mime.base import MIMEBase 
from email import encoders
from os import path

arr = {}
with open("/tmp/tests/ci/build_info") as f:
 for line in f:
   name, value = line.partition(":")[::2]
   arr[name.strip()] = value

fromaddr = arr["from_address"].strip()
toaddr = arr["to_address"].strip().split(",")
release = arr["release"].strip()
build_url = arr["build_url"].strip()
status = arr["status"].strip()
subject = arr["subject"].strip()
password = arr["email_password"].strip()

s = smtplib.SMTP('smtp.gmail.com', 587) 
s.starttls() 
s.login(fromaddr, password)

if status == "Success":
 bgcolor = "#51CA5E"
else:
 bgcolor = "#E33F3A"

body = """
<table style="height: 109px;" border="1" width="709" cellspacing="0" cellpadding="0">
<tbody>
<tr style="background-color: %s; height: 28px;">
<td style="width: 227.841px; height: 28px; text-align: center;"><span style="text-decoration: underline;"><strong>Release</strong></span></td>
<td style="width: 228.75px; height: 28px; text-align: center;"><span style="text-decoration: underline;"><strong>Status</strong></span></td>
<td style="width: 228.75px; height: 28px; text-align: center;"><span style="text-decoration: underline;"><strong>Build Log URL</strong></span></td>
</tr>
<tr style="height: 28px;">
<td style="width: 227.841px; height: 28px; text-align: center;"><strong>&nbsp;%s</strong></td>
<td style="width: 228.75px; height: 28px; text-align: center;">&nbsp;<strong>%s</strong></td>
<td style="width: 228.75px; height: 28px; text-align: center;"><strong><a href="%s" target="_blank" rel="noopener">Click Here!</a></strong>&nbsp;</td>
</tr>
</tbody>
</table>
<p>If you do not wish to receive these emails, please <a href="mailto:msknext@gmail.com?subject=CI-Notification-Unsubscribe">click here</a></p>
<p>If you wish to add someone to receive these notifications, please <a href="mailto:msknext@gmail.com?subject=CI-Notification-Add">click here</a></p>
""" % (bgcolor, release, status, build_url)

for i in range(len(toaddr)):
  msg = MIMEMultipart()
  msg['From'] = "Sunbird CI Mailer"
  msg['To'] = toaddr[i]
  msg['Subject'] = subject
  msg.attach(MIMEText(body, 'html'))
  filename = "serverlogs.zip"
  p = MIMEBase('application', 'octet-stream')
  if path.exists("/tmp/serverlogs.zip"):
   attachment = open("/tmp/serverlogs.zip", "rb")
   p.set_payload((attachment).read())
   encoders.encode_base64(p)
   p.add_header('Content-Disposition', "attachment; filename= %s" % filename)
   msg.attach(p)
  text = msg.as_string()
  s.sendmail(fromaddr, toaddr[i], text) 
s.quit()
