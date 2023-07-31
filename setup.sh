#!/bin/bash

# Checking if python3 is installed
if ! command -v python3 &> /dev/null
then
    echo "python3 could not be found. Please install it and try again."
    exit
fi

# Checking if pip3 is installed
if ! command -v pip3 &> /dev/null
then
    echo "pip3 could not be found. Please install it and try again."
    exit
fi

# Install required python packages
pip3 install flask ipwhois

# Creating server script
cat <<EOL > server.py
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
EOL

# Creating frontend
mkdir -p static
cat <<EOL > static/index.html
<html>
<body>
    <h2>Upload IP Addresses</h2>
    <textarea id="ipList" rows="10" cols="30"></textarea><br><br>
    <button onclick="getASN()">Get AS Numbers</button>
    <h3>Results</h3>
    <pre id="results"></pre>
    <script>
    async function getASN() {
        const ips = document.getElementById('ipList').value.split("\\n");
        const response = await fetch('/get_asn', {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json'
            },
            body: JSON.stringify({ ips: ips })
        });
        const data = await response.json();
        document.getElementById('results').textContent = JSON.stringify(data, null, 2);
    }
    </script>
</body>
</html>
EOL

# Notify user and start the server
echo "Files have been created. Starting the server..."
python3 server.py

