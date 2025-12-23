from flask import Flask
from prometheus_flask_exporter import PrometheusMetrics  # <--- NEW 1

app = Flask(__name__)
metrics = PrometheusMetrics(app)  # <--- NEW 2 (This adds the /metrics page automatically)

@app.route('/')
def hello():
    return 'Hello! I am a Junior DevOps Engineer. This app was deployed automatically!'

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)