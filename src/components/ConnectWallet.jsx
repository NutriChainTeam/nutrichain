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
      style={{
        padding: "8px 12px",
        borderRadius: "999px",
        border: "1px solid #475569",
        background: "#020617",
        color: "#e5e7eb",
        fontSize: "12px",
        fontWeight: 500,
      }}
    >
      Connect wallet (WalletConnect / HashPack)
    </button>
  );
};

export default ConnectWallet;
