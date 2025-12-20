import {
  HederaJsonRpcMethod,
  HederaSessionEvent,
  HederaChainId,
  DAppConnector,
  hederaNamespace,
} from "@hashgraph/hedera-wallet-connect";
import "./style.css";

const connectBtn   = document.getElementById("wcConnectBtn");
const linkedLabel  = document.getElementById("linkedWalletSpan");
const userAddress  = document.getElementById("userAddress");

let dAppConnector = null;

async function initWallet() {
  console.log("INIT WALLET...");

  dAppConnector = new DAppConnector(
    "6ada14d4e40d08d278a39c212bf50ce9", // ton projectId Reown
    Object.values(HederaJsonRpcMethod),
    [HederaSessionEvent.ChainChanged, HederaSessionEvent.AccountsChanged],
    [HederaChainId.Testnet, HederaChainId.Mainnet]
  );

  await dAppConnector.init({ logger: "error" });
  console.log("INIT DONE");

  if (!connectBtn) {
    console.warn("wcConnectBtn not found in DOM");
    return;
  }

  connectBtn.addEventListener("click", async () => {
    console.log("CLICK CONNECT");
    try {
      const session = await dAppConnector.openModal();
      handleNewSession(session);
    } catch (e) {
      console.error("Connect failed", e);
    }
  });
}

function handleNewSession(session) {
  console.log("NEW SESSION", session);

  const accounts = session.namespaces[hederaNamespace].accounts || [];
  const first = accounts[0] || "";

  if (connectBtn) {
    connectBtn.textContent = first ? `Connected: ${first}` : "Connected";
    connectBtn.classList.remove("bg-slate-900/70", "text-slate-100");
    connectBtn.classList.add("bg-emerald-600", "text-white");
  }

  if (linkedLabel) {
    linkedLabel.textContent = first;
  }

  if (userAddress) {
    userAddress.textContent = first;
  }
}

// lancer l'init
initWallet().catch((e) => {
  console.error("Init failed", e);
});
