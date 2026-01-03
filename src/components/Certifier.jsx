import { ethers } from 'ethers';

const contractAddress = "0xb2B4DD7D075DF8302e0c155e7a7E082D6d788311";
const abi = [
  "function logProof(string _data) public"
];

export function Certifier() {
  async function handleCertify() {
    if (!window.ethereum) return alert("Installez MetaMask !");
    
    try {
      const provider = new ethers.providers.Web3Provider(window.ethereum);
      await provider.send("eth_requestAccounts", []);
      const signer = provider.getSigner();
      const contract = new ethers.Contract(contractAddress, abi, signer);

      const tx = await contract.logProof("Certification NutriChain Lot #" + Date.now());
      await tx.wait();
      alert("Succès ! Preuve enregistrée sur Hedera.");
    } catch (err) {
      console.error(err);
      alert("Erreur lors de la signature.");
    }
  }

  return (
    <button 
      onClick={handleCertify}
      className="bg-blue-600 text-white px-4 py-2 rounded-lg hover:bg-blue-700 transition"
    >
      Certifier sur la Blockchain
    </button>
  );
}
