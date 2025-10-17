#!/usr/bin/env python3
"""
Simple debug server for Crafta app debugging
Run this on your computer to receive debug logs from your phone
"""

import json
import datetime
from http.server import HTTPServer, BaseHTTPRequestHandler
from urllib.parse import urlparse, parse_qs
import threading
import webbrowser

class DebugHandler(BaseHTTPRequestHandler):
    def do_POST(self):
        try:
            content_length = int(self.headers['Content-Length'])
            post_data = self.rfile.read(content_length)
            data = json.loads(post_data.decode('utf-8'))
            
            if self.path == '/debug':
                self.handle_single_log(data)
            elif self.path == '/debug/batch':
                self.handle_batch_logs(data)
            else:
                self.send_error(404)
                
        except Exception as e:
            print(f"❌ Error handling request: {e}")
            self.send_error(500)
    
    def handle_single_log(self, data):
        timestamp = data.get('timestamp', datetime.datetime.now().isoformat())
        level = data.get('level', 'INFO')
        message = data.get('message', '')
        log_data = data.get('data', {})
        device_info = data.get('device_info', {})
        
        # Color coding for different log levels
        colors = {
            'INFO': '\033[94m',      # Blue
            'WARNING': '\033[93m',    # Yellow
            'ERROR': '\033[91m',      # Red
            'SUCCESS': '\033[92m',    # Green
            'AI': '\033[95m',         # Magenta
            'USER': '\033[96m',       # Cyan
            'EXPORT': '\033[97m',     # White
        }
        reset_color = '\033[0m'
        
        color = colors.get(level, '\033[97m')
        
        print(f"{color}[{timestamp}] {level}: {message}{reset_color}")
        
        if log_data:
            print(f"    Data: {json.dumps(log_data, indent=2)}")
        
        if device_info:
            print(f"    Device: {device_info.get('platform', 'Unknown')} {device_info.get('version', '')}")
        
        self.send_response(200)
        self.send_header('Content-type', 'application/json')
        self.send_header('Access-Control-Allow-Origin', '*')
        self.end_headers()
        self.wfile.write(json.dumps({'status': 'success'}).encode())
    
    def handle_batch_logs(self, data):
        logs = data.get('logs', [])
        print(f"📦 Received batch of {len(logs)} logs")
        
        for log in logs:
            timestamp = log.get('timestamp', datetime.datetime.now().isoformat())
            level = log.get('level', 'INFO')
            message = log.get('message', '')
            
            colors = {
                'INFO': '\033[94m',
                'WARNING': '\033[93m',
                'ERROR': '\033[91m',
                'SUCCESS': '\033[92m',
                'AI': '\033[95m',
                'USER': '\033[96m',
                'EXPORT': '\033[97m',
            }
            reset_color = '\033[0m'
            color = colors.get(level, '\033[97m')
            
            print(f"{color}[{timestamp}] {level}: {message}{reset_color}")
        
        self.send_response(200)
        self.send_header('Content-type', 'application/json')
        self.send_header('Access-Control-Allow-Origin', '*')
        self.end_headers()
        self.wfile.write(json.dumps({'status': 'success'}).encode())
    
    def log_message(self, format, *args):
        # Suppress default logging
        pass

def start_debug_server(port=8080):
    server_address = ('', port)
    httpd = HTTPServer(server_address, DebugHandler)
    
    print(f"🚀 Debug server starting on port {port}")
    print(f"📱 Configure your app to send logs to: http://192.168.1.100:{port}/debug")
    print("🔍 Waiting for debug logs from your phone...")
    print("Press Ctrl+C to stop")
    
    try:
        httpd.serve_forever()
    except KeyboardInterrupt:
        print("\n🛑 Debug server stopped")
        httpd.server_close()

if __name__ == '__main__':
    import sys
    
    port = 8080
    if len(sys.argv) > 1:
        port = int(sys.argv[1])
    
    start_debug_server(port)
