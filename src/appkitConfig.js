// src/appkitConfig.js
import { createConfig } from "wagmi";
import { mainnet } from "wagmi/chains";
import { http } from "wagmi";
import { createAppKit } from "@reown/appkit/react";

const projectId = "cf4c859325a68c116eb90b8ec51e07f2";

// Configuration wagmi
export const wagmiConfig = createConfig({
  chains: [mainnet],
  transports: {
    [mainnet.id]: http(),
  },
});

// Configuration Reown AppKit
export const appKit = createAppKit({
  config: wagmiConfig,
  projectId,
  networks: [mainnet],
  metadata: {
    name: "NutriChain",
    description: "NutriChain dApp",
    url: "https://www.nutrichain.org",
    icons: ["https://avatars.githubusercontent.com/u/37784886"],
  },
});
