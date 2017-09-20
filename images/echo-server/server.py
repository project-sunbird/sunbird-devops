#!/usr/bin/python
import os, sys
from BaseHTTPServer import BaseHTTPRequestHandler,HTTPServer

PORT_NUMBER = int(os.environ['ECHO_SERVER_PORT'])

class EchoRequestHandler(BaseHTTPRequestHandler):

    def do_GET(self):
        self.send_response(200)
        self.send_header("Content-type", "text/plain")
        self.end_headers()
        self.wfile.write(self.path)
        return

    def log_message(self, format, *args):
        sys.stdout.write("%s - - [%s] %s\n" % (self.address_string(), self.log_date_time_string(), format%args))
        sys.stdout.flush()

try:
    server = HTTPServer(('', PORT_NUMBER), EchoRequestHandler)
    print 'Started httpserver on port ' , PORT_NUMBER
    server.serve_forever()
except KeyboardInterrupt:
    print '^C received, shutting down the web server'
    server.socket.close()