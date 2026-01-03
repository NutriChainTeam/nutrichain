import {
  HederaJsonRpcMethod,
  HederaSessionEvent,
  HederaChainId,
  DAppConnector,
  hederaNamespace,
} from "@hashgraph/hedera-wallet-connect";
import "./style.css";

const connectBtn = document.getElementById("connectWallet");
const disconnectBtn = document.getElementById("disconnectWallet");
const accountInfo = document.getElementById("accountInfo");

let dAppConnector = null;

async function initWallet() {
  console.log("INIT WALLET...");

  dAppConnector = new DAppConnector(
    "cf4c859325a68c116eb90b8ec51e07f2", // remplace par ton vrai projectId
    Object.values(HederaJsonRpcMethod),
    [HederaSessionEvent.ChainChanged, HederaSessionEvent.AccountsChanged],
    [HederaChainId.Testnet, HederaChainId.Mainnet]
  );

  await dAppConnector.init({ logger: "error" });

  console.log("INIT DONE");

  connectBtn.addEventListener("click", async () => {
    console.log("CLICK CONNECT");
    try {
      const session = await dAppConnector.openModal();
      handleNewSession(session);
    } catch (e) {
      console.error("Connect failed", e);
    }
  });

  disconnectBtn.addEventListener("click", async () => {
    console.log("CLICK DISCONNECT");
    try {
      await dAppConnector.disconnect();
      accountInfo.textContent = "Disconnected";
      connectBtn.style.display = "inline-block";
      disconnectBtn.style.display = "none";
    } catch (e) {
      console.error("Disconnect failed", e);
    }
  });
}

function handleNewSession(session) {
  console.log("NEW SESSION", session);
  const accountIds = session.namespaces[hederaNamespace].accounts;
  accountInfo.textContent = JSON.stringify(accountIds, null, 2);
  connectBtn.style.display = "none";
  disconnectBtn.style.display = "inline-block";
}

// on lance l'init et on log l'erreur si ça casse
initWallet().catch((e) => {
  console.error("Init failed", e);
});

