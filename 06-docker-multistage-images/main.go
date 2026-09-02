package main

import (
	"fmt"
	"log"
	"net/http"
)

func handler(w http.ResponseWriter, r *http.Request) {
	htmlResponse := `<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Docker Multi-Stage Build</title>
    <style>
        body {
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            background: linear-gradient(135deg, #0f172a, #1e1b4b);
            color: #fff;
            display: flex;
            align-items: center;
            justify-content: center;
            height: 100vh;
            margin: 0;
        }
        .card {
            background: rgba(255, 255, 255, 0.08);
            padding: 3rem 4rem;
            border-radius: 18px;
            box-shadow: 0 10px 35px 0 rgba(0, 0, 0, 0.4);
            backdrop-filter: blur(10px);
            text-align: center;
            border: 1px solid rgba(255, 255, 255, 0.2);
        }
        h1 { color: #38bdf8; font-size: 2rem; margin-bottom: 0.8rem; }
        p { color: #cbd5e1; font-size: 1.15rem; margin-bottom: 1.5rem; }
        .badge { background: #0284c7; color: white; padding: 8px 18px; border-radius: 20px; font-weight: 600; }
    </style>
</head>
<body>
    <div class="card">
        <h1>Hello World from Docker multi-stage build</h1>
        <p>DevOps Engineering Lab - Multi-Stage Optimization</p>
        <span class="badge">Listening on Port 8080 | Ultra-lean Container</span>
    </div>
</body>
</html>`

	w.Header().Set("Content-Type", "text/html; charset=utf-8")
	w.WriteHeader(http.StatusOK)
	fmt.Fprint(w, htmlResponse)
}

func main() {
	port := ":8080"
	http.HandleFunc("/", handler)
	fmt.Printf("Server starting on port %s...\n", port)
	if err := http.ListenAndServe(port, nil); err != nil {
		log.Fatalf("Server failed: %v", err)
	}
}
