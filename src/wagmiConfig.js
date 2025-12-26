// src/wagmiConfig.js
import { http, createConfig } from "wagmi";
import { mainnet } from "wagmi/chains";
import { injected, walletConnect } from "wagmi/connectors";

const projectId = "cf4c859325a68c116eb90b8ec51e07f2";

export const wagmiConfig = createConfig({
  chains: [mainnet],
  connectors: [
    injected(),
    walletConnect({ projectId })
  ],
  transports: {
    [mainnet.id]: http()
  }
});
