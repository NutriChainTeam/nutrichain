import React from "react";
import logo from "./assets/logo-nutrichain.png";
import { FaXTwitter, FaTelegram, FaDiscord } from "react-icons/fa6";

export function Layout({ children }) {
  return (
    <div className="p-6 bg-slate-950 min-h-screen text-white flex flex-col">
      <Header />
      <main className="flex-1">{children}</main>
      <Footer />
    </div>
  );
}

function Header() {
  return (
    <header className="flex items-center justify-between mb-8">
      <div className="flex items-center gap-3">
        <img src={logo} alt="NutriChain" className="h-10 w-10 rounded-full" />
        <div>
          <h1 className="text-2xl font-bold">NutriChain</h1>
          <p className="text-xs text-slate-400">
            On‑chain transparency for every donated meal.
          </p>
        </div>
      </div>
    </header>
  );
}

function Footer() {
  return (
    <footer className="mt-auto pt-6 border-t border-slate-800 text-sm text-slate-400 flex flex-col md:flex-row items-center justify-between gap-3">
      <span>© {new Date().getFullYear()} NutriChain. All rights reserved.</span>
      <div className="flex items-center gap-4">
        <a
          href="https://x.com/nutrichain_"
          target="_blank"
          rel="noreferrer"
          className="flex items-center gap-1 hover:text-white"
        >
          <FaXTwitter /> X
        </a>
        <a
          href="https://t.me/NutriChainTeam"
          target="_blank"
          rel="noreferrer"
          className="flex items-center gap-1 hover:text-white"
        >
          <FaTelegram /> Telegram
        </a>
        <a
          href="https://discord.gg/MZ39wQwb"
          target="_blank"
          rel="noreferrer"
          className="flex items-center gap-1 hover:text-white"
        >
          <FaDiscord /> Discord
        </a>
      </div>
    </footer>
  );
}
