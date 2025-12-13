// src/main.jsx
import React from "react";
import ReactDOM from "react-dom/client";
import App from "./App";

import { WagmiProvider } from "wagmi";
import { wagmiConfig } from "./appkitConfig"; // <- ici, plus "./wagmiConfig"

ReactDOM.createRoot(document.getElementById("root")).render(
  <React.StrictMode>
    <WagmiProvider config={wagmiConfig}>
      <App />
    </WagmiProvider>
  </React.StrictMode>
);
