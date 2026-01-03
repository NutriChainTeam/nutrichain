// src/components/ConnectWallet.jsx
import React from "react";
import { appKit } from "../appkitConfig";

const ConnectWallet = () => {
  const handleClick = () => {
    // Ouvre le modal AppKit / WalletConnect
    appKit.open();
  };

  return (
    <button
      onClick={handleClick}
      className="flex items-center gap-2 px-4 py-2 rounded-lg bg-emerald-600 hover:bg-emerald-500 text-white text-sm font-medium shadow-lg shadow-emerald-500/20 transition-all"
    >
      <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round" className="lucide lucide-wallet"><path d="M21 12V7H5a2 2 0 0 1 0-4h14v4"/><path d="M3 5v14a2 2 0 0 0 2 2h16v-5"/><path d="M18 9v4"/><path d="M15 9v4"/></svg>
      Connect Wallet
    </button>
  );
};

export default ConnectWallet;
