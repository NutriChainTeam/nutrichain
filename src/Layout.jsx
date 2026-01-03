import React from "react";
import { Link, useLocation } from "react-router-dom";
import { FaXTwitter, FaTelegram, FaDiscord } from "react-icons/fa6";
// On utilise des emojis pour simplifier si tu n'as pas Lucide installé en React
// Sinon tu peux importer tes icônes ici.

export function Layout({ children }) {
  return (
    <div className="flex min-h-screen bg-slate-950 text-white">
      
      {/* --- SIDEBAR (Le "Slider" à gauche) --- */}
      <aside className="w-64 bg-slate-900 border-r border-slate-800 flex flex-col fixed inset-y-0 z-50">
        
        {/* 1. Logo du Sidebar */}
        <div className="p-6 flex items-center gap-3 border-b border-slate-800">
          <img 
            src="/assets/logo-nutrichain.png" 
            alt="NutriChain" 
            className="h-8 w-8 rounded-full"
            onError={(e) => { e.target.style.display = 'none'; }} 
          />
          <span className="font-bold text-lg tracking-tight">NutriChain</span>
        </div>

        {/* 2. Menu de Navigation */}
        <nav className="flex-1 p-4 space-y-1 mt-2 overflow-y-auto">
          
          <NavItem to="/" icon="📊">Dashboard</NavItem>
          
          {/* Section Governance */}
          <div className="pt-6 mt-2 mb-2 px-3 text-xs font-semibold text-slate-500 uppercase tracking-wider">
            Governance Info
          </div>

          <NavItem to="/about-governance" icon="ℹ️">About Gov</NavItem>
          <NavItem to="/how-it-works" icon="❓">How It Works</NavItem>
          <NavItem to="/validators" icon="🛡️">Validators</NavItem>

        </nav>

        {/* 3. Footer du Sidebar (Socials) */}
        <div className="p-4 border-t border-slate-800 bg-slate-900">
          <div className="flex justify-around text-slate-400">
            <a href="https://x.com/nutrichain_" target="_blank" className="hover:text-emerald-400"><FaXTwitter /></a>
            <a href="https://t.me/NutriChainTeam" target="_blank" className="hover:text-sky-400"><FaTelegram /></a>
            <a href="https://discord.gg/MZ39wQwb" target="_blank" className="hover:text-indigo-400"><FaDiscord /></a>
          </div>
          <p className="text-[10px] text-center text-slate-600 mt-2">© NutriChain 2025</p>
        </div>
      </aside>

      {/* --- CONTENU PRINCIPAL (À droite) --- */}
      <div className="flex-1 ml-64 flex flex-col">
        {/* Header Mobile / Top Bar (Optionnel, ici simplifié) */}
        <header className="h-16 border-b border-slate-800 bg-slate-950/50 backdrop-blur flex items-center px-8 justify-between sticky top-0 z-40">
           <h2 className="text-xl font-bold text-white">Dashboard</h2>
           <div className="text-sm text-slate-400">Welcome back</div>
        </header>

        {/* Le contenu de ta page change ici */}
        <main className="flex-1 p-8 overflow-y-auto">
          {children}
        </main>
      </div>

    </div>
  );
}

// Petit composant pour gérer le style "Actif / Inactif" des boutons
function NavItem({ to, children, icon }) {
  const location = useLocation();
  const isActive = location.pathname === to;

  return (
    <Link 
      to={to} 
      className={`flex items-center gap-3 px-3 py-2.5 rounded-lg font-medium transition-all ${
        isActive 
          ? "bg-emerald-500/10 text-emerald-400 border border-emerald-500/20" 
          : "text-slate-400 hover:text-white hover:bg-slate-800 border border-transparent"
      }`}
    >
      <span className="text-lg">{icon}</span>
      <span>{children}</span>
    </Link>
  );
}
