import { createAppKit } from '@reown/appkit'
import { WagmiAdapter } from '@reown/appkit-adapter-wagmi'

export const projectId = '6ada14d4e40d08d278a39c212bf50ce9'

// Réseau Hedera Mainnet
export const hederaMainnet = {
  id: 295, // Chain ID de Hedera Mainnet
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

// Configuration de votre token NutriChain
export const NUTRICHAIN_TOKEN = {
  tokenId: '0.0.10136204',
  evmAddress: '0x00000000000000000000000000000009aaa8c',
  name: 'NutriChain',
  symbol: 'NCHAIN',
  decimals: 6,
  totalSupply: 100000000,
  maxSupply: 1000000000,
  treasuryAccount: '0.0.10128148'
}

export const networks = [hederaMainnet]

export const wagmiAdapter = new WagmiAdapter({
  networks,
  projectId
})

// ... (reste du code identique)
export const appKit = createAppKit({
  adapters: [wagmiAdapter],
  networks,
  projectId,
  defaultNetwork: hederaMainnet,
  metadata: {
    name: 'NutriChain DApp',
    description: 'Nutrition-powered blockchain rewards',
    url: 'https://www.nutrichain.org', // <--- CHANGEZ CECI ICI
    icons: ['https://ipfs.io/ipfs/bafkreib62hwjjjajciix7mdzb4eygsxfkjr3ryl3mgytn3iusnuvi5wbji']
  }
})
