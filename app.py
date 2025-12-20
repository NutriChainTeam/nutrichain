import os
from flask import Flask, render_template
from flask_cors import CORS
import firebase_admin
from firebase_admin import credentials, firestore

# Initialisation Firebase (une seule fois)
SERVICE_ACCOUNT_FILE = os.environ.get("FIREBASE_SERVICE_ACCOUNT", "serviceAccountKey.json")
firebase_cred = credentials.Certificate(SERVICE_ACCOUNT_FILE)
firebase_app = firebase_admin.initialize_app(firebase_cred)
db = firestore.client()

def create_app():
    """Application Factory Pattern"""
    app = Flask(__name__, template_folder='templates', static_folder='static')
    CORS(app)
    
    # Configuration
    app.config['SECRET_KEY'] = os.environ.get('SECRET_KEY', 'dev-key-change-in-production')
    
    # Import et enregistrement des Blueprints
    from api_blueprint import api_bp
    from proposals_blueprint import proposals_bp
    from staking_blueprint import staking_bp
    
    app.register_blueprint(api_bp, url_prefix='/api')
    app.register_blueprint(proposals_bp, url_prefix='/api')
    app.register_blueprint(staking_bp, url_prefix='/api')
    
    # Route principale pour le dashboard
    @app.route('/')
    def index():
        return render_template('dashboard.html')
    
    return app

# Point d'entrée pour Gunicorn
app = create_app()

if __name__ == '__main__':
    app.run(debug=True, port=5001)
