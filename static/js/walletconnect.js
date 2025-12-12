// static/js/walletconnect.js

// -----------------------------------------------------------------------------
// CONFIG
// -----------------------------------------------------------------------------

// TODO : quand tu auras ton SDK Hedera Wallet Connect bundlé,
// tu pourras remplacer cette fonction par un vrai flux dAppConnector.openModal()
// qui renvoie un vrai accountId Hedera.
async function connectWithHederaWallet() {
  // Pour l'instant, on garde un flux temporaire pour ne rien casser :
  // on demande un Hedera ID comme avant, mais TOUT le reste du fichier
  // (link_wallet, UI, etc.) reste identique.
  const input = prompt("Enter your Hedera account (format shard.realm.num):");
  if (!input) return null;

  const trimmed = input.trim();
  if (!/^\d+\.\d+\.\d+$/.test(trimmed)) {
    alert("Invalid Hedera account format. Expected e.g. 0.0.1234");
    return null;
  }

  return {
    accountId: trimmed,
    evmAddress: null,
    walletType: "manual",
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
}

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

      await linkWalletOnBackend(treasuryId, accountId);
      updateUIAfterConnect(accountId, wcConnectBtn, linkedLabelEl);

      // On peut mémoriser localement l’accountId pour le vote, etc.
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
