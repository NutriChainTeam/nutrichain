// static/js/walletconnect.js

// -----------------------------------------------------------------------------
// CONFIG
// -----------------------------------------------------------------------------
//
// TODO: when you bundle a real Hedera WalletConnect / HashConnect SDK,
// replace connectWithHederaWallet() with the actual connection flow
// (QR / deep-link to HashPack, etc.) and return a real accountId.
// -----------------------------------------------------------------------------

async function connectWithHederaWallet() {
  // Temporary simple flow: manual Hedera account prompt.
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

  // Inform the simple wallet block on the dashboard, if present
  if (typeof window !== "undefined" && typeof window.onWalletConnected === "function") {
    try {
      window.onWalletConnected(accountId);
    } catch (e) {
      console.warn("onWalletConnected callback threw an error:", e);
    }
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

      // Optional: store locally for other pages if needed
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
