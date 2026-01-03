/* Connexion MetaMask et wallets Web3 */
let userAddress = null;
let web3 = null;

async function connectWallet() {
  if (typeof window.ethereum !== 'undefined') {
    try {
      const accounts = await window.ethereum.request({ method: 'eth_requestAccounts' });
      userAddress = accounts[0];
      web3 = new Web3(window.ethereum);
      showAlert('success', translations[currentLang].walletconnected);
      updateWalletUI();
      loadUserBalance();
      return userAddress;
    } catch (error) {
      showAlert('error', translations[currentLang].walleterror);
      console.error(error);
    }
  } else {
    showAlert('warning', translations[currentLang].installmetamask);
    window.open('https://metamask.io/download', '_blank');
  }
}

function disconnectWallet() {
  userAddress = null;
  showAlert('info', translations[currentLang].walletdisconnected);
  updateWalletUI();
}

function updateWalletUI() {
  const walletBtn = document.getElementById('walletButton');
  const walletAddress = document.getElementById('walletAddress');
  const userBalance = document.getElementById('userBalance');

  if (!walletBtn || !walletAddress) return;

  if (userAddress) {
    walletBtn.textContent = translations[currentLang].disconnect;
    walletBtn.onclick = disconnectWallet;
    walletBtn.classList.add('connected');
    walletAddress.textContent = userAddress.slice(0, 6) + '...' + userAddress.slice(-4);
    walletAddress.style.display = 'inline-block';
  } else {
    walletBtn.textContent = translations[currentLang].connectwallet;
    walletBtn.onclick = connectWallet;
    walletBtn.classList.remove('connected');
    walletAddress.style.display = 'none';
    if (userBalance) userBalance.textContent = '';
  }
}

async function loadUserBalance() {
  if (!userAddress) return;
  try {
    const response = await fetch(`/balance/${userAddress}`);
    const data = await response.json();
    const userBalance = document.getElementById('userBalance');
    if (userBalance) {
      userBalance.textContent = data.balance + ' NUTRI';
    }
  } catch (error) {
    console.error('Error loading balance', error);
  }
}

if (typeof window !== 'undefined' && typeof window.ethereum !== 'undefined') {
  window.ethereum.on('accountsChanged', (accounts) => {
    if (accounts.length === 0) {
      disconnectWallet();
    } else {
      userAddress = accounts[0];
      updateWalletUI();
      loadUserBalance();
    }
  });
}
