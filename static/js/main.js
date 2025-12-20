import { setupWalletConnect, loadTreasuryLinkedWallet } from "/static/js/walletconnect.js";

document.addEventListener("DOMContentLoaded", () => {
  const treasuryId    = document.body.dataset.treasuryId;
  const wcConnectBtn  = document.getElementById("wcConnectBtn");
  const linkedLabelEl = document.getElementById("linkedWalletSpan");

  setupWalletConnect(treasuryId, wcConnectBtn, linkedLabelEl);
  loadTreasuryLinkedWallet(treasuryId, wcConnectBtn, linkedLabelEl);
});
