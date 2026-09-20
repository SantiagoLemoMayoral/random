from http.server import BaseHTTPRequestHandler, HTTPServer
from urllib.parse import parse_qs, urlparse


class App(BaseHTTPRequestHandler):
    def do_GET(self):
        url = urlparse(self.path)

        if url.path == "/":
            self.send_text(
                "<h1>Random App</h1>"
                "<p>It works.</p>"
                '<p><a href="/hello?name=Santi">Say hello</a></p>'
                '<p><a href="/health">Health</a></p>'
            )

        elif url.path == "/hello":
            params = parse_qs(url.query)
            name = params.get("name", ["World"])[0]
            self.send_text(f"Hello, {name}!")

        elif url.path == "/health":
            self.send_json('{"status": "ok"}')

        else:
            self.send_text("Not found", status=404)

    def send_text(self, body, status=200):
        self.send_response(status)
        self.send_header("Content-Type", "text/html; charset=utf-8")
        self.end_headers()
        self.wfile.write(body.encode("utf-8"))

    def send_json(self, body, status=200):
        self.send_response(status)
        self.send_header("Content-Type", "application/json")
        self.end_headers()
        self.wfile.write(body.encode("utf-8"))


if __name__ == "__main__":
    server = HTTPServer(("0.0.0.0", 8000), App)
    print("Running on http://localhost:8000")
    server.serve_forever()
    ans = input(f">> ")