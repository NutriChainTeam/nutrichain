let web3Modal;
let provider;
let web3;

async function init() {
  const providerOptions = {
    walletconnect: {
      package: window.WalletConnectProvider.default,
      options: {
        infuraId: "5efc19eea03745a58fd5aa555075765c" # Remplacez par votre Infura ID
      }
    }
  };

  web3Modal = new window.Web3Modal.default({
    cacheProvider: false,
    providerOptions
  });
}

async function connectWallet() {
  try {
    provider = await web3Modal.connect();
    web3 = new Web3(provider);

    const accounts = await web3.eth.getAccounts();
    const address = accounts[0];

    document.getElementById("walletAddress").textContent = address;
    document.getElementById("walletAddress").style.display = "inline-block";
  } catch(e) {
    console.error("Erreur de connexion wallet", e);
  }
}

window.addEventListener('load', async () => {
  await init();
  document.getElementById("walletButton").addEventListener("click", connectWallet);
});
