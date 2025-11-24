from flask import Flask, render_template
from blockchain import Blockchain

app = Flask(__name__)
blockchain = Blockchain()

@app.route('/')
def index():
    return render_template('dashboard.html')

if __name__ == '__main__':
    print("\n🍽️  NutriChain - Aide Humanitaire avec Carte Mondiale")
    print("📧 contact@nutrichain.org")
    print("🌐 http://localhost:5000\n")
    app.run(host='0.0.0.0', port=5000, debug=True)
