from flask import Flask, request, jsonify
from ipwhois import IPWhois

app = Flask(__name__)

@app.route('/')
def index():
    return app.send_static_file('index.html')

@app.route('/get_asn', methods=['POST'])
def get_asn():
    ips = request.json.get('ips', [])
    results = {}
    for ip in ips:
        try:
            obj = IPWhois(ip)
            results[ip] = obj.lookup_rdap(depth=1)['asn_description']
        except Exception as e:
            results[ip] = f"Error: {str(e)}"
    return jsonify(results)

if __name__ == '__main__':
    app.run(debug=True, port=5000)
