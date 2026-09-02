const express = require('express');
const app = express();
const PORT = process.env.PORT || 3000;

app.get('/', (req, res) => {
    res.send(`
        <!DOCTYPE html>
        <html lang="en">
        <head>
            <meta charset="UTF-8">
            <meta name="viewport" content="width=device-width, initial-scale=1.0">
            <title>Node.js - Hello World</title>
            <style>
                body {
                    font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
                    background: linear-gradient(135deg, #1e1e2f, #2d3748);
                    color: #fff;
                    display: flex;
                    align-items: center;
                    justify-content: center;
                    height: 100vh;
                    margin: 0;
                }
                .card {
                    background: rgba(255, 255, 255, 0.08);
                    padding: 2.5rem 3.5rem;
                    border-radius: 16px;
                    box-shadow: 0 8px 32px 0 rgba(0, 0, 0, 0.37);
                    backdrop-filter: blur(8px);
                    text-align: center;
                    border: 1px solid rgba(255, 255, 255, 0.18);
                }
                h1 { color: #68a063; margin-bottom: 0.5rem; }
                p { color: #cbd5e1; font-size: 1.1rem; }
                .badge { background: #334155; padding: 6px 14px; border-radius: 20px; font-size: 0.9rem; }
            </style>
        </head>
        <body>
            <div class="card">
                <h1>Hello World from Node.js Web Application! 🚀</h1>
                <p>DevOps Containerization Lab - Section B</p>
                <span class="badge">Running on Node.js ${process.version} inside Docker Container</span>
            </div>
        </body>
        </html>
    `);
});

app.listen(PORT, '0.0.0.0', () => {
    console.log(`Node.js web application listening on port ${PORT}`);
});
