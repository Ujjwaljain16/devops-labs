from flask import Flask
import os
import socket

app = Flask(__name__)

@app.route('/')
def hello_world():
    hostname = socket.gethostname()
    return f"""
    <!DOCTYPE html>
    <html lang="en">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Python Flask - Hello World</title>
        <style>
            body {{
                font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
                background: linear-gradient(135deg, #0f172a, #1e293b);
                color: #fff;
                display: flex;
                align-items: center;
                justify-content: center;
                height: 100vh;
                margin: 0;
            }}
            .card {{
                background: rgba(255, 255, 255, 0.08);
                padding: 2.5rem 3.5rem;
                border-radius: 16px;
                box-shadow: 0 8px 32px 0 rgba(0, 0, 0, 0.37);
                backdrop-filter: blur(8px);
                text-align: center;
                border: 1px solid rgba(255, 255, 255, 0.18);
            }}
            h1 {{ color: #38bdf8; margin-bottom: 0.5rem; }}
            p {{ color: #cbd5e1; font-size: 1.1rem; }}
            .badge {{ background: #334155; padding: 6px 14px; border-radius: 20px; font-size: 0.9rem; }}
        </style>
    </head>
    <body>
        <div class="card">
            <h1>Hello World from Python Flask! 🐍</h1>
            <p>DevOps Containerization Lab - Section B</p>
            <span class="badge">Container Host: {hostname}</span>
        </div>
    </body>
    </html>
    """

if __name__ == '__main__':
    port = int(os.environ.get('PORT', 5000))
    app.run(host='0.0.0.0', port=port)
