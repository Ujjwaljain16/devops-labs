"""A small Flask app - the demo target for the DevSecOps pipeline."""
import os
import time

from flask import Flask, jsonify, request

app = Flask(__name__)
START_TIME = time.time()


@app.route("/")
def home():
    return jsonify(message="DevSecOps demo app", status="ok")


@app.route("/health")
def health():
    return jsonify(status="healthy")


@app.route("/api/status")
def status():
    return jsonify(
        uptime_seconds=round(time.time() - START_TIME, 2),
        pid=os.getpid(),
    )


@app.route("/api/add", methods=["POST"])
def add():
    data = request.get_json(silent=True) or {}
    if "a" not in data or "b" not in data:
        return jsonify(error="missing 'a' or 'b'"), 400
    return jsonify(result=data["a"] + data["b"])


@app.route("/api/calculate", methods=["POST"])
def calculate():
    data = request.get_json(silent=True) or {}
    a = data.get("a")
    b = data.get("b")
    op = data.get("operation")
    if a is None or b is None or op is None:
        return jsonify(error="missing 'a', 'b', or 'operation'"), 400

    if op == "add":
        result = a + b
    elif op == "subtract":
        result = a - b
    elif op == "multiply":
        result = a * b
    elif op == "divide":
        if b == 0:
            return jsonify(error="division by zero"), 400
        result = a / b
    else:
        return jsonify(error=f"unknown operation '{op}'"), 400

    return jsonify(result=result)


if __name__ == "__main__":
    # nosec B104 - binding to 0.0.0.0 is required for the app to be reachable
    # from outside its Docker container; this isn't a real exposure risk here
    # because the container itself is only published on the port we choose.
    app.run(host="0.0.0.0", port=5001)  # nosec B104
