// src/appkitConfig.js
import { http, createConfig } from "wagmi";
import { mainnet } from "wagmi/chains";
import { WagmiAdapter } from "@reown/appkit-adapter-wagmi";
import { createAppKit } from "@reown/appkit/react";

const projectId = "c75338eb5c9eb1b462e8a9bd7229afdf";

export const wagmiAdapter = new WagmiAdapter({
  projectId,
  networks: [mainnet],
  transports: {
    [mainnet.id]: http(),
  },
});

// Important : on utilise wagmiAdapter.wagmiConfig
export const wagmiConfig = createConfig(wagmiAdapter.wagmiConfig);

export const appKit = createAppKit({
  adapters: [wagmiAdapter],
  projectId,
  networks: [mainnet],
  metadata: {
    name: "NutriChain",
    description: "NutriChain dApp",
    url: "https://nutrichain.local",
    icons: ["https://avatars.githubusercontent.com/u/37784886"],
  },
});
