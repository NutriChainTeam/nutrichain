import {
  DAppConnector,
  HederaChainId,
  HederaJsonRpcMethod,
  HederaSessionEvent,
} from "@hashgraph/hedera-wallet-connect";
import { LedgerId } from "@hashgraph/sdk";

// Ton Project ID
const projectId = "cf4c859325a68c116eb90b8ec51e07f2";

// Créer le bouton tout de suite
const button = document.createElement("button");
button.textContent = "Connecting...";
button.disabled = true;
button.style.padding = "10px 16px";
button.style.fontSize = "16px";
document.body.appendChild(button);

// Créer l'instance DAppConnector
const dAppConnector = new DAppConnector({
  projectId,
  chainId: HederaChainId.Testnet,
  network: {
    name: "hedera-testnet",
    ledgerId: LedgerId.TESTNET,
  },
});

// Initialisation au chargement
async function initWalletConnect() {
  try {
    await dAppConnector.init({
      methods: Object.values(HederaJsonRpcMethod),
      events: [HederaSessionEvent.ChainChanged, HederaSessionEvent.AccountsChanged],
      chains: [HederaChainId.Testnet],
      logger: "error",
    });

    console.log("WalletConnect initialisé");
    button.textContent = "Connect Wallet";
    button.disabled = false;
  } catch (e) {
    console.error("Erreur d'init WalletConnect:", e);
    button.textContent = "Init failed";
  }
}

initWalletConnect();

// Clic = ouvrir le modal Hedera Wallet Connect
button.addEventListener("click", async () => {
  try {
    const session = await dAppConnector.openModal();
    console.log("Session connectée:", session);
    alert("Wallet connecté !");
  } catch (e) {
    console.error("Erreur de connexion wallet:", e);
  }
});
