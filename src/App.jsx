import React from 'react';
import { BrowserRouter as Router, Routes, Route } from 'react-router-dom';
import Validators from './Validators';
import './input.css'; // Importe input.css pour TailwindCSS
import AboutGovernance from "./AboutGovernance";


// Composant temporaire pour la page d'accueil (Dashboard)
function Dashboard() {
  return (
    <div style={{ padding: '20px', color: 'white' }}>
      <h1>Dashboard NutriChain</h1>
      <p>Bienvenue sur le tableau de bord.</p>
    </div>
  );
}

function App() {
  return (
    <Router>
      <Routes>
        {/* Route pour l'accueil (ne touche pas à ton dashboard existant si tu en as un autre) */}
        <Route path="/" element={<Dashboard />} />
        
        {/* Route pour ta nouvelle page Validateurs */}
        <Route path="/validators" element={<Validators />} />
        <Route path="/about-governance" element={<AboutGovernance />} />
      </Routes>
    </Router>
  );
}

export default App;
