// src/wagmiConfig.js
import { http, createConfig } from "wagmi";
import { mainnet } from "wagmi/chains";
import { injected, walletConnect } from "wagmi/connectors";

const projectId = "c75338eb5c9eb1b462e8a9bd7229afdf";

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
