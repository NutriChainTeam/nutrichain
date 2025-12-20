import {
  HederaJsonRpcMethod,
  HederaSessionEvent,
  HederaChainId,
  DAppConnector,
  hederaNamespace,
} from "@hashgraph/hedera-wallet-connect";
import { LedgerId, AccountId, TransferTransaction, Hbar, Client } from "@hashgraph/sdk";

// --- DOM Elements ---
const connectBtn   = document.getElementById("wcConnectBtn");
const linkedLabel  = document.getElementById("linkedWalletSpan");
const userAddress  = document.getElementById("userAddress");
const disconnectBtn = document.getElementById("wcDisconnectBtn");
const signMsgBtn    = document.getElementById("signMsgBtn");
const sendHbarBtn   = document.getElementById("sendHbarBtn");
const logsArea      = document.getElementById("logsArea");

// --- Config ---
const PROJECT_ID = "ef7581e5a1a2d52c07a09b2be5641ee4";
const metadata = {
  name: "NutriChain",
  description: "NutriChain Wallet Test",
  url: "https://www.nutrichain.org",
  icons: ["https://www.nutrichain.org/favicon.ico"],
};

let dAppConnector = null;
let currentSession = null;

// --- Logger ---
function log(msg, data = null) {
    const time = new Date().toLocaleTimeString();
    let text = `[${time}] ${msg}`;
    if(data) text += ` | ${JSON.stringify(data)}`;
    console.log(text);
    if(logsArea) logsArea.value += text + "\n";
}

// --- INIT ---
async function initWallet() {
  log("INIT WALLET...");
  log("Using Project ID: " + PROJECT_ID);

  try {
    dAppConnector = new DAppConnector(
      metadata,
      LedgerId.TESTNET,
      PROJECT_ID,
      Object.values(HederaJsonRpcMethod),
      [HederaSessionEvent.ChainChanged, HederaSessionEvent.AccountsChanged],
      [HederaChainId.Testnet]
    );

    await dAppConnector.init({ logger: "error" });
    log("INIT DONE");

    // Check if valid session exists
    if (dAppConnector.walletConnectClient?.session?.length) {
        const lastSession = dAppConnector.walletConnectClient.session.getAll().pop();
        if(lastSession) {
             log("Restoring session...");
             handleNewSession(lastSession);
        }
    }

  } catch (err) {
    log("FATAL: Init failed", err);
    console.error(err);
  }

  // Bind Events
  if (connectBtn) connectBtn.addEventListener("click", onClickConnect);
  if (disconnectBtn) disconnectBtn.addEventListener("click", onClickDisconnect);
  if (signMsgBtn) signMsgBtn.addEventListener("click", onSignMessage);
  if (sendHbarBtn) sendHbarBtn.addEventListener("click", onSendHbar);
}

// --- CONNECT ---
async function onClickConnect() {
  log("CLICK CONNECT");
  try {
    if (!dAppConnector) return;
    const session = await dAppConnector.openModal().catch(e => {
        log("Modal closed or error", e);
        return null;
    });
    if (!session) return;
    handleNewSession(session);
  } catch (e) {
    log("Connect failed", e);
  }
}

// --- DISCONNECT ---
async function onClickDisconnect() {
    if(!dAppConnector) return;
    try {
        await dAppConnector.disconnectAll();
        currentSession = null;
        if(userAddress) userAddress.innerText = "Not Connected";
        if(linkedLabel) linkedLabel.style.display = "none";
        if(connectBtn) connectBtn.style.display = "inline-block";
        if(disconnectBtn) disconnectBtn.style.display = "none";
        log("Disconnected");
    } catch(e) {
        log("Disconnect Error", e);
    }
}

// --- SESSION HANDLER ---
function handleNewSession(session) {
  log("NEW SESSION ESTABLISHED");
  currentSession = session;
  
  const ns = session?.namespaces?.[hederaNamespace];
  const accounts = Array.isArray(ns?.accounts) ? ns.accounts : [];
  const first = accounts[0] || "";
  // Format: "hedera:testnet:0.0.12345" -> "0.0.12345"
  const accountId = first.split(":").pop();

  if(userAddress) userAddress.innerText = accountId;
  if(linkedLabel) linkedLabel.style.display = "inline";
  if(connectBtn) connectBtn.style.display = "none";
  if(disconnectBtn) disconnectBtn.style.display = "inline-block";
}

// --- ACTIONS (Test) ---
async function onSignMessage() {
    if(!dAppConnector || !currentSession) return alert("Not connected");
    // Implementation simple pour test
    alert("Sign Message clicked (Not implemented in this minimal test)");
}

async function onSendHbar() {
    if(!dAppConnector || !currentSession) return alert("Not connected");
    // Implementation simple pour test
    alert("Send HBAR clicked (Not implemented in this minimal test)");
}

// --- BOOTSTRAP ---
document.addEventListener('DOMContentLoaded', initWallet);
