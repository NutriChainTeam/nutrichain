/* Traductions multilingues */
const translations = {
  fr: {
    title: "NutriChain - Blockchain Humanitaire",
    connectwallet: "Connecter Wallet",
    disconnect: "Déconnecter",
    walletconnected: "Wallet connecté avec succès !",
    walleterror: "Erreur de connexion au wallet",
    walletdisconnected: "Wallet déconnecté",
    installmetamask: "Veuillez installer MetaMask pour continuer",
    donate: "Faire un don",
    donatenow: "Donner maintenant",
    amount: "Montant",
    mealsdonated: "repas donnés",
    statstitle: "Statistiques en temps réel",
    totalblocks: "Blocs minés",
    totaldonations: "Total des dons",
    staketokens: "Staker des tokens",
    stakenow: "Staker maintenant",
    apy: "APY",
    yourbalance: "Votre solde",
    transactions: "Transactions",
    blockchain: "Blockchain",
    transparency: "Transparence",
    verified: "Vérifié",
    maptitle: "Carte Mondiale des Aides",
    mealsdistributed: "Repas distribués",
    activecountries: "Pays actifs",
    donationsuccess: "Don effectué avec succès !",
    stakesuccess: "Tokens stakés avec succès !",
    loading: "Chargement..."
  },
  en: {
    title: "NutriChain - Humanitarian Blockchain",
    connectwallet: "Connect Wallet",
    disconnect: "Disconnect",
    walletconnected: "Wallet connected successfully!",
    walleterror: "Wallet connection error",
    walletdisconnected: "Wallet disconnected",
    installmetamask: "Please install MetaMask to continue",
    donate: "Make a donation",
    donatenow: "Donate now",
    amount: "Amount",
    mealsdonated: "meals donated",
    statstitle: "Real-time Statistics",
    totalblocks: "Blocks mined",
    totaldonations: "Total donations",
    staketokens: "Stake tokens",
    stakenow: "Stake now",
    apy: "APY",
    yourbalance: "Your balance",
    transactions: "Transactions",
    blockchain: "Blockchain",
    transparency: "Transparency",
    verified: "Verified",
    maptitle: "World Aid Map",
    mealsdistributed: "Meals distributed",
    activecountries: "Active countries",
    donationsuccess: "Donation successful!",
    stakesuccess: "Tokens staked successfully!",
    loading: "Loading..."
  }
};

let currentLang = 'fr';

function changeLanguage(lang) {
  currentLang = lang;
  localStorage.setItem('nutrichain_lang', lang);
  updatePageTranslations();
  updateWalletUI();
  document.documentElement.dir = lang === 'ar' ? 'rtl' : 'ltr';
  document.documentElement.lang = lang;
}

function updatePageTranslations() {
  document.querySelectorAll('[data-i18n]').forEach(element => {
    const key = element.getAttribute('data-i18n');
    if (translations[currentLang][key]) {
      if (element.tagName === 'INPUT' || element.tagName === 'TEXTAREA') {
        element.placeholder = translations[currentLang][key];
      } else {
        element.textContent = translations[currentLang][key];
      }
    }
  });
  document.title = translations[currentLang].title;
}

window.addEventListener('DOMContentLoaded', () => {
  const savedLang = localStorage.getItem('nutrichain_lang') || 'fr';
  changeLanguage(savedLang);
});
