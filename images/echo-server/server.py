#!/usr/bin/python
import os
from BaseHTTPServer import BaseHTTPRequestHandler,HTTPServer

PORT_NUMBER = int(os.environ['ECHO_SERVER_PORT'])

class EchoRequestHandler(BaseHTTPRequestHandler):

	def do_GET(self):
		self.send_response(200)
		self.send_header("Content-type", "text/plain")
		self.end_headers()
		self.wfile.write(self.path)
		return

try:
	server = HTTPServer(('', PORT_NUMBER), EchoRequestHandler)
	print 'Started httpserver on port ' , PORT_NUMBER
	server.serve_forever()
except KeyboardInterrupt:
	print '^C received, shutting down the web server'
	server.socket.close()