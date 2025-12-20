// static/js/walletconnect.js

import { DAppConnector, LedgerId } from "@hashgraph/hedera-wallet-connect";

// -----------------------------------------------------------------------------
// CONFIG NUTRICHAIN / HEDERA WALLET CONNECT
// -----------------------------------------------------------------------------

// Choisis le réseau : TESTNET pendant le dev, MAINNET pour la prod.
const NUTRICHAIN_LEDGER = LedgerId.TESTNET; // ou LedgerId.MAINNET

// Si tu as un projectId Reown/AppKit, mets-le ici, sinon laisse null pour l’instant.
const NUTRICHAIN_PROJECT_ID = null;

// Infos d’identification de la dApp côté wallet
const dAppConnector = new DAppConnector({
  name: "NutriChain",
  description: "NutriChain humanitarian treasury on Hedera",
  url: window.location.origin,
  icons: ["https://www.nutrichain.org/static/icon.png"],
  // projectId: NUTRICHAIN_PROJECT_ID, // décommente si tu as un projectId
});

// Initialisation au chargement du module
await dAppConnector.init();

// -----------------------------------------------------------------------------
// CONNEXION WALLET (REMPLACE L’ANCIEN PROMPT MANUEL)
// -----------------------------------------------------------------------------

async function connectWithHederaWallet() {
  // Ouvre le flux Hedera Wallet Connect (HashPack, etc.)
  const session = await dAppConnector.connect(NUTRICHAIN_LEDGER);

  if (!session || !session.accounts || !session.accounts.length) {
    throw new Error("No account returned by Hedera Wallet Connect");
  }

  const accountId = session.accounts[0]; // ex: "0.0.123456"

  return {
    accountId,
    evmAddress: null,
    walletType: "hedera-wallet-connect",
  };
}

// -----------------------------------------------------------------------------
// HELPER API / UI
// -----------------------------------------------------------------------------

async function linkWalletOnBackend(treasuryId, accountId) {
  const res = await fetch("/link_wallet", {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify({
      treasury_account_id: treasuryId,
      wallet_account_id: accountId,
    }),
  });

  if (!res.ok) {
    throw new Error(`link_wallet error: ${res.status}`);
  }

  return res.json();
}

function updateUIAfterConnect(accountId, wcConnectBtn, linkedLabelEl) {
  if (wcConnectBtn) {
    wcConnectBtn.textContent = `Connected: ${accountId}`;
    wcConnectBtn.classList.remove("bg-slate-900/70", "text-slate-100");
    wcConnectBtn.classList.add("bg-emerald-600", "text-white");
  }

  if (linkedLabelEl) {
    linkedLabelEl.textContent = accountId;
  }

  const addrEl = document.getElementById("userAddress");
  if (addrEl) {
    addrEl.textContent = accountId;
  }

  // Informer éventuellement d’autres blocs du dashboard
  if (typeof window !== "undefined" && typeof window.onWalletConnected === "function") {
    try {
      window.onWalletConnected(accountId);
    } catch (e) {
      console.warn("onWalletConnected callback threw an error:", e);
    }
  }
}

// -----------------------------------------------------------------------------
// EXPORTS UTILISÉS DANS TON TEMPLATE HTML
// -----------------------------------------------------------------------------

export async function loadTreasuryLinkedWallet(treasuryId, wcConnectBtn, linkedLabelEl) {
  if (!linkedLabelEl || !treasuryId) return;

  try {
    const res = await fetch(`/linked_wallet/${treasuryId}`);
    if (res.status === 404) {
      linkedLabelEl.textContent = "No wallet linked";
      return;
    }
    if (!res.ok) {
      linkedLabelEl.textContent = "Error loading linked wallet";
      return;
    }
    const data = await res.json();

    if (!data || !data.wallet_account_id) {
      linkedLabelEl.textContent = "No wallet linked";
      return;
    }

    const acc = data.wallet_account_id;
    updateUIAfterConnect(acc, wcConnectBtn, linkedLabelEl);
  } catch (err) {
    console.error(err);
    linkedLabelEl.textContent = "Error loading wallet";
  }
}

export function setupWalletConnect(treasuryId, wcConnectBtn, linkedLabelEl) {
  if (!wcConnectBtn) return;

  wcConnectBtn.addEventListener("click", async () => {
    try {
      const result = await connectWithHederaWallet();
      if (!result || !result.accountId) return;

      const accountId = result.accountId;

      // Lier le wallet côté backend
      await linkWalletOnBackend(treasuryId, accountId);

      // Mettre à jour l’UI
      updateUIAfterConnect(accountId, wcConnectBtn, linkedLabelEl);

      // Optionnel : stocker localement pour d’autres pages
      try {
        localStorage.setItem("hederaAccountId", accountId);
      } catch (e) {
        console.warn("Unable to store accountId in localStorage", e);
      }
    } catch (err) {
      console.error("Error while connecting wallet", err);
      alert("Error while linking wallet. Please try again.");
    }
  });
}

export function initNutriWalletConnect(treasuryId: string) {
  const wcConnectBtn  = document.getElementById("wcConnectBtn");
  const linkedLabelEl = document.getElementById("linkedWalletSpan");
  setupWalletConnect(treasuryId, wcConnectBtn, linkedLabelEl);
  loadTreasuryLinkedWallet(treasuryId, wcConnectBtn, linkedLabelEl);
}
