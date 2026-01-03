import React from "react";
import { BrowserRouter as Router, Routes, Route } from "react-router-dom";
import Validators from "./Validators";
import AboutGovernance from "./AboutGovernance";
import HowItWorks from "./HowItWorks"; // <--- NOUVEL IMPORT
import { Layout } from "./Layout";
import "./input.css";

// Composant temporaire Dashboard
function Dashboard() {
  return (
    <div style={{ padding: "20px", color: "white" }}>
      <h1>Dashboard NutriChain</h1>
      <p>Bienvenue sur le tableau de bord.</p>
    </div>
  );
}

function App() {
  return (
    <Router>
      <Routes>
        {/* Route Dashboard (avec Layout si tu veux le menu, sinon sans) */}
        <Route path="/" element={<Layout><Dashboard /></Layout>} />

        {/* Route Validateurs (SANS Layout comme tu l'as configuré) */}
        <Route path="/validators" element={<Validators />} />

        {/* Routes avec le menu latéral (Layout) */}
        <Route path="/about-governance" element={<Layout><AboutGovernance /></Layout>} />
        <Route path="/how-it-works" element={<Layout><HowItWorks /></Layout>} />
      </Routes>
    </Router>
  );
}

export default App;
