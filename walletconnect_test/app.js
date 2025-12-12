import {
  DAppConnector,
  HederaJsonRpcMethod,
  HederaSessionEvent,
  HederaChainId
} from "@hashgraph/hedera-wallet-connect";

const connectBtn = document.getElementById("connectBtn");
const statusEl = document.getElementById("status");
const accountEl = document.getElementById("account");
const evmEl = document.getElementById("evm");

// TODO: remplace par ton vrai projectId WalletConnect
const projectId = 'd9eaeeaca2b27758fb8cdc39315ed00e'


const metadata = {
  name: "NutriChain WalletConnect test",
  description: "Minimal Hedera WalletConnect test page",
  url: "https://nutrichain.org",
  icons: ["https://nutrichain.org/favicon.ico"]
};

const dAppConnector = new DAppConnector(
  metadata,
  HederaChainId.Testnet,
  WALLETCONNECT_PROJECT_ID,
  Object.values(HederaJsonRpcMethod),
  [HederaSessionEvent.ChainChanged, HederaSessionEvent.AccountsChanged],
  [HederaChainId.Testnet]
);

async function initConnector() {
  statusEl.textContent = "Initializing connector...";
  await dAppConnector.init({ logger: "error" });
  statusEl.textContent = "Ready. Click the button to connect.";
}

async function connectWallet() {
  try {
    statusEl.textContent = "Opening WalletConnect modal...";
    const session = await dAppConnector.openModal();
    statusEl.textContent = "Wallet connected.";

    const signers = await dAppConnector.getSigners();
    const signer = signers[0];

    const hederaAccountId = await signer.getAccountId();
    const evmAddress = signer.getEvmAddress
      ? await signer.getEvmAddress()
      : null;

    accountEl.textContent = `Hedera accountId: ${hederaAccountId.toString()}`;
    evmEl.textContent = evmAddress
      ? `EVM address: ${evmAddress}`
      : "EVM address: (not provided)";
  } catch (err) {
    console.error(err);
    statusEl.textContent = "Connection cancelled or failed.";
  }
}

connectBtn.addEventListener("click", connectWallet);

initConnector();
