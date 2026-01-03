import { createAppKit } from '@reown/appkit'
import { WagmiAdapter } from '@reown/appkit-adapter-wagmi'

export const projectId = '6ada14d4e40d08d278a39c212bf50ce9'

// Réseau Hedera Mainnet
export const hederaMainnet = {
  id: 295,
  chainNamespace: 'eip155',
  name: 'Hedera Mainnet',
  nativeCurrency: {
    decimals: 18,
    name: 'HBAR',
    symbol: 'HBAR'
  },
  rpcUrls: {
    default: { http: ['https://mainnet.hashio.io/api'] }
  },
  blockExplorers: {
    default: { name: 'HashScan', url: 'https://hashscan.io/mainnet' }
  }
}

export const networks = [hederaMainnet]

export const wagmiAdapter = new WagmiAdapter({
  networks,
  projectId
})

export const appKit = createAppKit({
  adapters: [wagmiAdapter],
  networks,
  projectId,
  defaultNetwork: hederaMainnet,
  metadata: {
    name: 'NutriChain DApp',
    description: 'Nutrition-powered blockchain rewards',
    url: 'https://nutrichain.com',
    icons: ['https://ipfs.io/ipfs/bafkreib62hwjjjajciix7mdzb4eygsxfkjr3ryl3mgytn3iusnuvi5wbji']
  }
})
