from flask import Flask, jsonify
import sys
import os

app = Flask(__name__)

counter = 0
port = int(sys.argv[1]) if len(sys.argv) > 1 else 5000


@app.route("/")
def index():
    global counter
    counter += 1
    return jsonify({"counter": str(counter)})


@app.route("/info")
def info():
    return jsonify({
        "port": port,
        "counter": counter,
        "pid": os.getpid()
    })


@app.route("/reset", methods=["POST"])
def reset():
    global counter
    counter = 0
    return jsonify({"status": "reset", "port": port})


if __name__ == "__main__":
    app.run(host="0.0.0.0", port=port, threaded=True)
