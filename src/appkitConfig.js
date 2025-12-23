// src/appkitConfig.js
import { createConfig } from "wagmi";
import { mainnet } from "wagmi/chains";
import { http } from "wagmi";
import { createAppKit } from "@reown/appkit/react";

const projectId = "c75338eb5c9eb1b462e8a9bd7229afdf";

// Crée la configuration wagmi
export const wagmiConfig = createConfig({
  chains: [mainnet],
  transports: {
    [mainnet.id]: http(),
  },
});

// Crée AppKit avec la configuration wagmi
export const appKit = createAppKit({
  config: wagmiConfig,
  projectId,
  networks: [mainnet],
  metadata: {
    name: "NutriChain",
    description: "NutriChain dApp",
    url: "http://app.nutrichain.com",,
    icons: ["https://avatars.githubusercontent.com/u/37784886"],
  },
});
